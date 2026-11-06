---
type: reference
tags: [reference, portal, task, service-catalog, ai, release-specific]
status: documented
source: ServiceNow Brazil docs, ServiceNow AI Platform user interface > Service Portal > Configuring Service Portal > Creating portal pages (Designer, subheader, font icons on a page, Standard ticket page and its configuration, tabs, actions, Activity tab options, route map; Redirect a reference to a page ID; Attaching files from portal pages), Configure Service Portal Approval Configuration record, Using portal widgets (widget instances, context menu, Configure widget loading order, deferred AI Search assets), read 2026-11-06 through the docs site API (map 7xQNQY92V5DYmBMD7wXg9g).
sn-release: Brazil
verified:
verified-by:
observed-in:
updated: 2026-11-06
---

# Service Portal Pages, Containers and Page Route Maps

**In one line:** how a portal page is built (page, containers, rows, columns, widget instances), the fields that control access and layout, page route maps, the configurable standard ticket page, attachment directives, approval configuration and deferred widget loading.

From the Brazil docs; not tested. Portal record and styling: [[Service Portal Portal Record, Branding and Themes]]. Roles: `admin` or `sp_admin` unless stated.

## Build a page in the Designer

**Service Portal > Service Portal Configuration > Designer**: pick the portal in the header, open or add a page, drag a **Container**, drop a layout into it (Bootstrap grid, columns add up to 12), then drag widgets into the columns. Widgets with no default content show nothing until their instance options are set. **Preview** switches desktop, tablet and mobile. The **Page Editor** shows the same page as a tree (page, containers, rows, columns, instances). A page is addressed by its ID and can be used by any portal; base pages serve as templates.

**Page** (`sp_page`) fields:

| Field | Does |
|---|---|
| Title | internal name, used to search in the Designer |
| ID | unique; the URL is `/<suffix>?id=<ID>` |
| Public | no login needed; any listed roles are then ignored |
| Draft | only `admin` sees it, others get a 404 |
| Roles | limit by role (users without it still see links but get "page not found") |
| Page Specific CSS | overrides theme and branding |
| Dynamic page title, Human readable url structure, Use SEO script, SEO script | SEO ([[Service Portal SEO, Announcements and Usage Analytics]]) |

**Clone Page** copies a page; cloning a base page creates new instances for each widget.

**Container** (`sp_container`) fields: Name, Order (lowest first), Page, Screen reader title, **Semantic tag** (None puts everything between header and footer in `<main>`; Main, Header, Nav, Section, Article, Details, Summary, Time, Fig caption), Width (Fixed or Fluid), Parent class, CSS class, Background color, image and style (Default, Cover, Contain, Repeating), **Bootstrap alternative** (drops the grid classes, container width and column sizes; supply your own CSS), **Move to header** (sticks under the header as a subheader). The `<main>` tag can go on a container, row or column, never a widget, and only once per page.

Font icons for every widget on one page: attach the font file to the page record and reference `/<attachment_sys_id>.iix` in an `@font-face` rule in Page Specific CSS (per-widget and dependency variants: [[Service Portal Widget Development]]).

## Widget instances and the context menu

Each widget placed on a page is a **Widget Instance** (`sp_instance`) holding the widget reference, its column, predefined option fields and **Additional options, JSON format**. Editing the widget changes every instance; instance options and CSS change only that one. Set options with the edit icon in the Designer or **Ctrl + right-click > Instance Options** on the page.

Context menu (needs `admin` or `sp_admin`; also visible while impersonating a user without them): Widget performance, Instance options, Instance in Page Editor, Page Designer, Show Widget Customizations, Edit Container Background, Widget Options Schema, Widget in Form Modal, Widget in Editor, **Log to console: $scope.data**, **Log to console: $scope**. Base widgets and their options: [[Service Portal Base Widget Library]].

## Deferred widget loading

Designer > Widgets > a widget's form icon > **defer load**: order **Viewport** (when scrolled into view) or **Parallel** (just after the page), Device type (desktop, tablet, mobile), optional placeholder dimensions JSON per device, **Limit widget size to placeholder** (avoids layout shift), and a **Placeholder Template** (skeleton loader). AI Search assets are deferred for the portals listed in `glide.service_portal.ais_defer_load_enable.list` (default: Service Portal), but not when web embeddables are enabled.

## Page route maps

**Service Portal > Page Route Maps** (`sp_page_route_map`) redirect every widget **reference** to a page ID to another page, without cloning widgets; they do not redirect a page ID typed in a URL. Fields: Short Description, Service Portal(s) (none = all), Route from, Route to, Active, Roles (none = everyone; users without a listed role are not redirected), Order (lowest wins; ties go to the oldest). Base route maps to activate after upgrades: **Knowledge Article View**, **Standard Ticket Route**, **Search** (to `sp_search` with facets), **My Request**. The 404 page is set on the portal, not by a route map.

## Standard ticket page

A common page (`standard_ticket`) for any task-based record: header (number, created, updated, state or another field), info section (description, fields, actions), tabs. New instances have it; upgraded ones activate the **Standard Ticket Route** route map. Configure in **Standard Ticket > Standard Ticket Configuration**, one active configuration per table per domain, task-extended tables only:

- **State field**, **Show 'Description'** (None, Always, When no variables), **Description field**, **Info fields** or **Advanced** with an **Info widget** and its parameters, **Action widget** (overrides the standard actions), **Summary fields** (for the Now Assist summary). Number, short description, created, updated, watch list, state and journal input cannot be info fields; workflow-type fields only on `sc_req_item` (for example Stage, always shown last). Date/time widgets show "time ago" only.
- **Tab Configurations** (at most six; only Custom can repeat; Variable Editor (Read-Only) or Variable Summarizer, not both): types Activity, Associated Requests, Attachments, Custom (widget and parameters), Variable Editor (Read-Only), Variable Summarizer; Order (lowest opens first); Visible condition or **Visible(Script)**. Activity tab instance options: **Enable Rich Text Editor** and **Enable @ Mentions** (for `csm_ticket`, edit the `rich_text_editor` widget parameter on the `sn_customerservice_case` configuration instead).
- **Standard Ticket actions**: Name, Ticket configuration, Table, Order, **Applicability condition** or script, **Action script**, **User input** (string inputs only, in *Standard Ticket Action Inputs*). Requesters and scriptable APIs can trigger them.

Cross-scope request types need restricted caller access for the *Standard Ticket Header*, *Attachments* and *Tab* widgets and the Description field, plus a route map. Tab configurations are not domain separated; ticket configurations are process domain separated and searched in the record's domain (table, then parent table), then up the domain hierarchy. RITM detail: [[Service Catalog in Employee Center, Service Portal and Mobile]].

## Attachments from portal pages

Base widgets *Form*, *Ticket Attachments*, *Ticket Conversations* and *SC Catalog Item* accept paste and drop in the **Add attachments** dialog. In a cloned or custom widget:

- `<sp-attachment-button modal="true" supported-extensions="{{::data.supportedAttachmentExtensions}}">` turns paste and drop on in the dialog and lists the extensions from `glide.attachment.extensions`.
- `sp-attachment-picker attachment-handler="attachmentHandler"` as an attribute (a drop zone over part of the widget) or an element (an attachments section). The client script must set `attachmentHandler` to a `nowAttachmentHandler` instance (see the *Form* widget). Options: `disable-picker-overlay="true"`, `on-file-pick="attachFiles($files)"` for custom handling. Hide on mobile with `ng-if="isDesktopBrowser"` built from `cabrillo.isNative()` and `spUtil.isMobile()`.

Not on mobile; pasting not in Firefox. Usage Insights event *SP File Attach* counts each method. See [[Attachments]].

## Approval Configuration

**Service Portal > Approval Configurations**: per table (`sc_request` and `sc_req_item` preconfigured), controls the **Approval assistance** AI agent and the **Approval Info Record** widget. Fields: Name, Table, Application, Active; tab **Display Fields Configuration** (fields and their order shown to the approver); tab **Gen AI Checklist & KB Search**: **Approval checklist** Always, Never or Conditionally, and **KB search fields** used to build the article search. Other sources (SharePoint, Google Drive, a custom table) need an AI Search source linked to the portal's search profile and listed in `sn_na_req_agent.approval_checklist.search_profile_sources`. A custom table without a configuration falls back to default fields. Agent: [[AI Agents Library - Platform and Creator Agents]].

## Example

Page *Example Ticket View* (ID `example_ticket`), not public, roles empty; container with semantic tag Main; a Standard Ticket Configuration for *Example Request* (`x_example_request`, extends `task`) with tabs Activity and Attachments and an action *Example Cancel* with one string input *Reason*; a route map *Example Route* from `ticket` to `example_ticket` for *Example Support Portal* only.

## Related

- [[Service Portal Overview and Configuration]] · [[Service Portal Portal Record, Branding and Themes]] · [[Service Portal Base Widget Library]] · [[Service Portal Widget Development]]
