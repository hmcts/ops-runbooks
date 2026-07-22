(function () {
  'use strict';

  // ---------------------------------------------------------------------------
  // PageTOC
  //
  // Builds a sticky "On this page" right-hand nav for the current page.
  // Integrates with content-filter: rebuilds the heading list whenever the user
  // switches filter so only visible headings appear. Tracks scroll position
  // to highlight the active heading and update the URL (#filter=VALUE&section=id).
  // ---------------------------------------------------------------------------
  function PageTOC() {
    this.content      = null;  // .technical-documentation element
    this.nav          = null;  // <nav class="page-toc"> element
    this.headings     = [];    // currently visible h2/h3 elements
    this.activeFilter = null;  // mirrors content-filter's active filter
  }

  // Locates the content element, does the first build, then listens for filter
  // switches so the heading list stays in sync with visible content.
  PageTOC.prototype.init = function () {
    if (!document.querySelector('[data-page-toc]')) return;
    var content = document.querySelector('.technical-documentation');
    if (!content) return;
    this.content = content;

    // content-filter runs before page-toc in the JS bundle so display:none is
    // already applied to hidden blocks by the time build() runs.
    this.build();

    var self = this;
    document.addEventListener('filterchange', function (e) {
      self.activeFilter = e.detail && e.detail.filter;
      self.rebuild();
    });
  };

  // First-time build: creates the nav element, wraps content and nav in a flex
  // layout, then populates the heading list and wires up event listeners.
  PageTOC.prototype.build = function () {
    var headings = this.getVisibleHeadings();
    if (headings.length < 2) return;

    // content-filter has already written #filter=VALUE to the URL by now.
    var m = window.location.hash.match(/[#&]filter=([A-Z0-9]+)/i);
    if (m) this.activeFilter = m[1];

    var nav = document.createElement('nav');
    nav.className = 'page-toc';
    nav.setAttribute('aria-label', 'On this page');

    var title = document.createElement('p');
    title.className = 'page-toc__title';
    title.textContent = 'On this page';
    nav.appendChild(title);

    var ul = document.createElement('ul');
    ul.className = 'page-toc__list';
    nav.appendChild(ul);

    // Place content and nav side-by-side inside a flex wrapper.
    var wrapper = document.createElement('div');
    wrapper.className = 'page-layout';
    this.content.parentNode.insertBefore(wrapper, this.content);
    wrapper.appendChild(this.content);
    wrapper.appendChild(nav);

    this.nav = nav;
    this.headings = headings;
    this.populateList();
    this.bindScroll();
    this.bindTocClicks();
  };

  // Refresh the heading list after an env switch. The nav wrapper stays in
  // place; only the <ul> contents are replaced by populateList().
  PageTOC.prototype.rebuild = function () {
    if (!this.nav) return;
    this.headings = this.getVisibleHeadings();
    this.populateList();
  };

  // Clear and rebuild the TOC link list from this.headings. Assigns an ID to
  // any heading that the markdown renderer left without one.
  PageTOC.prototype.populateList = function () {
    var ul = this.nav.querySelector('.page-toc__list');
    ul.innerHTML = '';
    this.headings.forEach(function (h) {
      if (!h.id) {
        h.id = h.textContent.trim()
          .toLowerCase()
          .replace(/[^a-z0-9]+/g, '-')
          .replace(/^-|-$/g, '');
      }
      var li = document.createElement('li');
      li.className = 'page-toc__item page-toc__item--' + h.tagName.toLowerCase();
      var a = document.createElement('a');
      a.href = '#' + h.id;
      a.className = 'page-toc__link';
      a.textContent = h.textContent;
      li.appendChild(a);
      ul.appendChild(li);
    });
  };

  // Returns all h2/h3 elements that are not inside a hidden [data-filter-values] block.
  PageTOC.prototype.getVisibleHeadings = function () {
    return Array.from(this.content.querySelectorAll('h2, h3')).filter(function (h) {
      var block = h.closest('[data-filter-values]');
      return block === null || block.style.display !== 'none';
    });
  };

  // TOC link clicks: write #env=ENV&section=ID to the URL and scroll smoothly
  // to the target, rather than letting the browser navigate via the plain
  // #heading-id href which would drop the env= param.
  PageTOC.prototype.bindTocClicks = function () {
    var self = this;
    this.nav.addEventListener('click', function (e) {
      var link = e.target.closest('.page-toc__link');
      if (!link) return;
      e.preventDefault();
      var id = (link.getAttribute('href') || '').replace(/^#/, '');
      if (!id) return;
      var el = document.getElementById(id);
      // Use env= only when the target heading is inside the steps container.
      var inContainer = el && el.closest('.content-filter-container');
      if (inContainer && self.activeFilter) {
        history.replaceState(null, '', '#filter=' + self.activeFilter + '&section=' + id);
      } else {
        history.replaceState(null, '', '#section=' + id);
      }
      if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });
  };

  // Tracks scroll position to highlight the active TOC link and update the URL.
  //
  // Listens on .app-pane__content (govuk-tech-docs' scroll container) rather
  // than window — govuk-tech-docs scrolls the inner pane so window scroll
  // events never fire in this layout.
  //
  // Uses this.activeEnv (kept in sync via envchange events) rather than reading
  // window.location.hash, which may already be overwritten by the time this
  // handler completes.
  PageTOC.prototype.bindScroll = function () {
    var self = this;
    var scrollEl = document.querySelector('.app-pane__content') || window;

    scrollEl.addEventListener('scroll', function () {
      if (!self.nav || !self.headings.length) return;

      // Walk headings to find the last one whose top edge is at or above the
      // upper 80px of the viewport — that is the currently active section.
      var active = self.headings[0];
      self.headings.forEach(function (h) {
        if (h.getBoundingClientRect().top <= 80) active = h;
      });

      // Highlight the matching TOC link. Re-query after each event because
      // rebuild() replaces the <ul> innerHTML, detaching previous link nodes.
      self.nav.querySelectorAll('.page-toc__link').forEach(function (a) {
        a.classList.toggle('page-toc__link--active',
          a.getAttribute('href') === '#' + active.id);
      });

      // Update the URL hash. Use filter= only when scrolled into a filtered container;
      // static section headings get a plain #section=id URL with no filter=.
      if (active.id) {
        var inContainer = active.closest('.content-filter-container');
        if (inContainer && self.activeFilter) {
          history.replaceState(null, '', '#filter=' + self.activeFilter + '&section=' + active.id);
        } else {
          history.replaceState(null, '', '#section=' + active.id);
        }
      }
    }, { passive: true });
  };

  // ---------------------------------------------------------------------------
  // Bootstrap
  // ---------------------------------------------------------------------------
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function () { new PageTOC().init(); });
  } else {
    new PageTOC().init();
  }
})();
