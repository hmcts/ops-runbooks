# Operations runbooks

This repo is a collection of runbooks for common tasks and activities done by the operations / platforms teams, hosted with GitHub Pages on:

[Ops-Runbooks Site](https://hmcts.github.io/ops-runbooks/)

<a href="https://gitpod.io/#https://github.com/hmcts/ops-runbooks">
  <img
    src="https://img.shields.io/badge/Contribute%20with-Gitpod-908a85?logo=gitpod"
    alt="Contribute with Gitpod"
  />
</a>

## Getting started

To preview or build the website, there is two options.

### Gitpod

Gitpod is the easiest way to develop on this repository, you will get a fresh automated dev environment without having to setup anything on your machine.

Click the below button to get started:

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/hmcts/ops-runbooks)

### Local installation

Install Ruby with Rubygems, preferably with a [Ruby version manager][rvm],
and the [Bundler gem][bundler].

In the application folder type the following to install the required gems:

```
bundle install
```

## Making changes

To make changes edit the source files in the `source` folder.

### Single page output

Although a single page of HTML is generated the markdown is spread across
multiple files to make it easier to manage. They can be found in
`source/documentation`.

A new markdown file isn't automatically included in the generated output. If we
add a new markdown file at the location `source/documentation/agile/scrum.md`,
the following snippet in `source/index.html.md.erb`, includes it in the
generated output.

```
<%= partial 'documentation/agile/scrum' %>
```

Including files manually like this lets us specify the position they appear in
the page.

### Multiple pages

To add a completely new page, create a file with a `.html.md` extension in the `/source` directory.

For example, `source/about.html.md` will be accessible on <http://localhost:4567/about.html>.

## Preview

There are 2 options to preview changes:

* Using the bundle middleman server to start up a web server and access it via a browser as it would be normally
* Using a markdown extension in your code editor to preview the html.md.erb files whilst editing.

### Middleman Server

Whilst writing documentation we can run a middleman server to preview how the
published version will look in the browser. After saving a change the preview in
the browser will automatically refresh.

The preview is only available on our own computer. Others won't be able to
access it if they are given the link.

Type the following to start the server:

```
bundle exec middleman server
```

If all goes well something like the following output will be displayed:

```
== The Middleman is loading
== LiveReload accepting connections from ws://192.168.0.8:35729
== View your site at "http://Laptop.local:4567", "http://192.168.0.8:4567"
== Inspect your site configuration at "http://Laptop.local:4567/__middleman", "http://192.168.0.8:4567/__middleman"
```

You should now be able to view a live preview at http://localhost:4567.

### Local preview

To view the markdown files locally you can add a markdown preview extension/add-on to your code editor.

For example VSCode has one built in that allows you to preview markdown (.md) files by right clicking on the file name and selecting `preview`

However this only works when the file suffix is `*.md` but for this repository the files are `.md.erb` so VSCode does not automatically pick these up.

The fix for this is to add an association in settings so that VSCode will offer the preview option.

Set the association in preferences:
<img src="images/markdownAssociation.png" alt="markdown association setting" height="250"/>

Right click on files to see the preview option:
<img src="images/previewOption.png" alt="preview option" height="150"/>

Whilst the local preview offers the fastest feedback it is still a good idea to use the Middleman server as a final confirmation when all changes have been made and you are ready to push to Github.

## Build

If you want to publish the website without using a build script you may need to
build the static HTML files.

Type the following to build the HTML:

```bash
bundle exec middleman build
```

This will create a `build` subfolder in the application folder which contains
the HTML and asset files ready to be published.

[rvm]: https://www.ruby-lang.org/en/documentation/installation/#managers
[bundler]: http://bundler.io/

## Testing external URLs

If you want to check that all external URLs are still valid you can run the following command:

```bash
bundle exec rake check_urls
```

You will need a GitHub token for this to work correctly as the code requires this for private repositories.
To make this easy you can use the GH CLI tool: `brew install gh`

To login in you should run `gh auth login` which will prompt you on how you want to authenticate.

Using `https` and `browser` will allow you to use your current logged in session on GitHub.

Once authenticated you can now create tokens as required with `gh auth token`.

For the script this should be set as an environment variable: `export GH_TOKEN=$(gh auth token)`.

With this complete you can now run the bundle command to check urls in the repo.

## Publishing

Run:

```
bundle exec rake publish
```
