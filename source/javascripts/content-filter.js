(function () {
  'use strict';

  // ---------------------------------------------------------------------------
  // history.replaceState patch
  //
  // govuk-tech-docs has a debounced scroll handler (~100ms) that calls
  // replaceState with a bare #heading-id. Two problems arise without this patch:
  //
  //   1. It fires after our synchronous scroll handler and drops the filter= param.
  //   2. It queries ALL [id] elements including display:none ones from hidden
  //      content blocks. Hidden elements report position().top === 0 in jQuery so
  //      they always "win", producing wrong IDs like "some-heading-6".
  //
  // Fix: intercept any replaceState call whose fragment has no key=value params
  // (i.e. a bare #anchor from govuk-tech-docs), discard it, and keep the URL
  // that page-toc's synchronous scroll handler already wrote.
  // ---------------------------------------------------------------------------
  var moduleActiveFilter = null; // kept in sync with the active filter via applyFilter()

  var _origReplaceState = history.replaceState.bind(history);
  history.replaceState = function (state, title, url) {
    if (url && typeof url === 'string') {
      var hashIdx = url.indexOf('#');
      if (hashIdx !== -1) {
        var fragment = url.slice(hashIdx + 1);
        // Discard bare #anchor writes from govuk-tech-docs (no key=value params).
        // page-toc has already written the correct #section= or #filter=&section= URL;
        // we preserve it by keeping window.location.hash unchanged.
        if (fragment.indexOf('=') === -1) {
          url = url.slice(0, hashIdx) + window.location.hash;
        }
      }
    }
    return _origReplaceState(state, title, url);
  };

  // ---------------------------------------------------------------------------
  // ContentFilter
  //
  // Replaces a [data-content-filter] placeholder with a radio-button group.
  // Shows/hides [data-filter-values="A B C"] content blocks to match the active
  // selection. Persists the active filter and current heading in the URL hash as
  // #filter=VALUE&section=heading-id so that deep links and browser history work.
  //
  // Usage: add data-filter-values="A B C" to any block that should be shown for
  // categories A, B, or C. Place [data-content-filter] where the buttons should
  // appear. Optionally set data-filter-order="A,B,C" for button order and
  // data-filter-label="..." to customise the prompt text.
  // ---------------------------------------------------------------------------
  function ContentFilter(placeholder) {
    this.placeholder  = placeholder;
    this.container    = placeholder.closest('.technical-documentation') ||
                        placeholder.parentElement;
    this.sections     = []; // { el, filters } for every [data-filter-values] element
    this.activeFilter = null;
    this.filterUI     = null;
    this.filters      = []; // ordered list of unique filter values found on the page
  }

  ContentFilter.prototype.init = function () {
    var filterSet = [];

    // Collect every [data-filter-values] block. Each block may list multiple
    // values, space-separated, e.g. data-filter-values="DEV STE SIT".
    this.sections = Array.from(
      this.container.querySelectorAll('[data-filter-values]')
    ).map(function (el) {
      var filters = el.getAttribute('data-filter-values').trim().split(/\s+/);
      filters.forEach(function (f) {
        if (filterSet.indexOf(f) === -1) filterSet.push(f);
      });
      return { el: el, filters: filters };
    });

    if (this.sections.length === 0) return;

    // Use the order defined on the placeholder (data-filter-order="A,B,C").
    // If not specified, values appear in the order encountered in the DOM.
    var pageOrder = this.placeholder.getAttribute('data-filter-order');
    var filterOrder = pageOrder
      ? pageOrder.split(',').map(function (s) { return s.trim().toUpperCase(); })
      : [];

    this.filters = filterOrder.length
      ? filterSet.sort(function (a, b) {
          var ai = filterOrder.indexOf(a); if (ai === -1) ai = filterOrder.length;
          var bi = filterOrder.indexOf(b); if (bi === -1) bi = filterOrder.length;
          return ai !== bi ? ai - bi : a.localeCompare(b);
        })
      : filterSet;

    this.renderFilterUI();
  };

  ContentFilter.prototype.renderFilterUI = function () {
    var self = this;

    // Build the filter widget and replace the placeholder element.
    var wrapper = document.createElement('div');
    wrapper.className = 'content-filter';
    wrapper.setAttribute('aria-label', 'Filter content');

    var label = document.createElement('p');
    label.className = 'content-filter__label';
    label.textContent = this.placeholder.getAttribute('data-filter-label') || 'Make a selection:';
    wrapper.appendChild(label);

    var btnGroup = document.createElement('div');
    btnGroup.className = 'content-filter__buttons';
    btnGroup.setAttribute('role', 'radiogroup');
    btnGroup.setAttribute('aria-label', 'Content filter');

    this.filters.forEach(function (f) {
      var btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'content-filter__btn';
      btn.setAttribute('data-filter-value', f);
      btn.setAttribute('role', 'radio');
      btn.setAttribute('aria-checked', 'false');
      btn.textContent = f;
      btn.addEventListener('click', function () {
        if (self.activeFilter === f) return;
        self.activeFilter = f;
        self.updateUI();
        self.applyFilter();
      });
      btnGroup.appendChild(btn);
    });

    wrapper.appendChild(btnGroup);
    this.placeholder.replaceWith(wrapper);
    this.filterUI = wrapper;

    // Resolve the initial filter value from the URL:
    //   1. Explicit #filter=VALUE param
    //   2. Value that owns the #section=heading-id heading (filtered content only)
    //   3. Value that owns any plain #anchor (backwards-compatible deep links)
    //   4. null - no selection; placeholder message is shown
    var hashFilter = this.getHashFilter();
    var sectionId  = this.getHashSection();
    var resolved   = hashFilter ||
                     (sectionId ? this.resolveFilterFromId(sectionId)
                                : this.resolveFilterFromAnchor());
    this.activeFilter = (resolved && this.filters.indexOf(resolved) !== -1) ? resolved : null;

    // Only write filter= to the URL if we have a resolved value; static-section
    // URLs carry no filter= param.
    if (this.activeFilter) this.setHashFilter(this.activeFilter);
    this.updateUI();
    this.applyFilter();

    // If the URL referenced a specific section, scroll to it after the filter
    // has applied (setTimeout keeps it off the synchronous call stack).
    if (sectionId) {
      setTimeout(function () {
        var el = document.getElementById(sectionId);
        if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }, 100);
    }

    // Heading anchor-icon clicks: write filter= only for headings inside a
    // content-filter-container; static headings get a plain #section=ID URL.
    self.container.addEventListener('click', function (e) {
      var anchor = e.target.closest('a.anchored-heading__icon');
      if (!anchor) return;
      e.preventDefault();
      var id = (anchor.getAttribute('href') || '').replace(/^#/, '');
      if (!id) return;
      var el = document.getElementById(id);
      var inContainer = el && el.closest('.content-filter-container');
      if (inContainer && self.activeFilter) {
        history.replaceState(null, '', '#filter=' + self.activeFilter + '&section=' + id);
      } else {
        history.replaceState(null, '', '#section=' + id);
      }
    });

    // hashchange fires on browser back/forward navigation.
    window.addEventListener('hashchange', function () {
      var f = self.getHashFilter();
      if (!f) {
        // URL no longer has filter= (e.g. navigated back to a static section).
        if (self.activeFilter !== null) {
          self.activeFilter = null;
          self.updateUI();
          self.applyFilter();
        }
      } else if (self.filters.indexOf(f) !== -1 && f !== self.activeFilter) {
        self.activeFilter = f;
        self.updateUI();
        self.applyFilter();
        var sid = self.getHashSection();
        if (sid) {
          setTimeout(function () {
            var el = document.getElementById(sid);
            if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
          }, 50);
        }
      }
    });
  };

  // Sync button active states and aria-checked with the current activeFilter.
  // activeFilter may be null (no selection); in that case all buttons are unchecked.
  ContentFilter.prototype.updateUI = function () {
    var activeFilter = this.activeFilter;
    this.filterUI.querySelectorAll('.content-filter__btn').forEach(function (btn) {
      var isActive = activeFilter !== null && btn.getAttribute('data-filter-value') === activeFilter;
      btn.classList.toggle('content-filter__btn--active', isActive);
      btn.setAttribute('aria-checked', isActive ? 'true' : 'false');
    });
  };

  // Show only [data-filter-values] blocks matching the active filter; hide others.
  // Dispatches 'filterchange' so page-toc can rebuild its heading list.
  ContentFilter.prototype.applyFilter = function () {
    var activeFilter = this.activeFilter;
    moduleActiveFilter = activeFilter;

    var noSel      = document.querySelectorAll('.content-filter-no-selection');
    var containers = document.querySelectorAll('.content-filter-container');

    if (!activeFilter) {
      // No selection - show placeholder, hide all filtered blocks, remove badge.
      this.sections.forEach(function (s) { s.el.style.display = 'none'; });
      for (var i = 0; i < noSel.length; i++) noSel[i].style.display = '';
      for (var j = 0; j < containers.length; j++) containers[j].removeAttribute('data-active-filter');
    } else {
      // Selection made - hide placeholder, show matching blocks, stamp badge.
      for (var k = 0; k < noSel.length; k++) noSel[k].style.display = 'none';
      this.sections.forEach(function (s) {
        s.el.style.display = s.filters.indexOf(activeFilter) !== -1 ? '' : 'none';
      });
      for (var l = 0; l < containers.length; l++) containers[l].setAttribute('data-active-filter', activeFilter);
    }

    document.dispatchEvent(new CustomEvent('filterchange', { detail: { filter: activeFilter } }));
  };

  // ---------------------------------------------------------------------------
  // URL hash helpers
  // ---------------------------------------------------------------------------

  // Return the filter= value from the URL hash, or null.
  ContentFilter.prototype.getHashFilter = function () {
    var m = window.location.hash.match(/[#&]filter=([A-Z0-9]+)/i);
    return m ? m[1].toUpperCase() : null;
  };

  // Return the section= value from the URL hash, or null.
  ContentFilter.prototype.getHashSection = function () {
    var m = window.location.hash.match(/[#&]section=([^&]+)/);
    return m ? decodeURIComponent(m[1]) : null;
  };

  // Write #filter=VALUE to the URL, preserving any existing section= param.
  ContentFilter.prototype.setHashFilter = function (f) {
    var m = window.location.hash.match(/[#&]section=([^&]+)/);
    history.replaceState(null, '', '#filter=' + f + (m ? '&section=' + m[1] : ''));
  };

  // Given a heading element ID, return the first filter value from its
  // [data-filter-values] ancestor, or null.
  ContentFilter.prototype.resolveFilterFromId = function (id) {
    var el = document.getElementById(id);
    if (!el) return null;
    var block = el.closest('[data-filter-values]');
    if (!block) return null;
    var filters = block.getAttribute('data-filter-values').trim().toUpperCase().split(/\s+/);
    return filters[0] || null;
  };

  // If the URL has a plain #anchor (no filter= or section= params), resolve
  // the filter value from the block that owns that heading. Supports old links.
  ContentFilter.prototype.resolveFilterFromAnchor = function () {
    var hash = window.location.hash;
    if (!hash || hash.indexOf('filter=') !== -1 || hash.indexOf('section=') !== -1) return null;
    return this.resolveFilterFromId(hash.slice(1).split('&')[0]);
  };

  // ---------------------------------------------------------------------------
  // Bootstrap - initialise one ContentFilter per [data-content-filter] placeholder
  // ---------------------------------------------------------------------------
  function initAll() {
    document.querySelectorAll('[data-content-filter]').forEach(function (placeholder) {
      new ContentFilter(placeholder).init();
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initAll);
  } else {
    initAll();
  }
})();
