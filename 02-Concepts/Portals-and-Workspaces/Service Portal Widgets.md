---
type: concept
tags: [concept, portal, scripting, javascript, release-specific]
status: documented
source: ServiceNow Brazil docs, ServiceNow AI Platform user interface > Service Portal > Using portal widgets, Developing custom widgets (overviews of guidelines, tutorial, clone, create, option schema, API reference, Angular Providers, embedded widgets, dependencies, internationalize, troubleshooting, embeddables, diagnostics), read at overview depth 2026-10-30. The whole chapter was read in full on 2026-11-06: detail is in Service Portal Widget Development, Service Portal Embeddables and the troubleshooting note. https://www.servicenow.com/docs/r/platform-user-interface/service-portal/service-portal-roles.html ServiceNow Brazil docs, API reference page GlideSPScriptable - Scoped and spModal - Client, read 2026-11-06 through the docs site API (map ooCZhg2g6YDYvKp3oBwAxA).
sn-release: Brazil
verified:
verified-by:
updated: 2026-11-06
---

# Service Portal Widgets

**In one line:** the components of a portal page, each with an HTML template, CSS, client script and server script, built on AngularJS and Bootstrap.

From the Brazil docs; not tested. See [[Service Portal Overview and Configuration]]. Create or edit needs `admin` or `sp_admin`. A widget is a superset of an Angular directive. Use a base widget, **clone** it to change it, or create your own.

## Where the code runs

| Part | Runs | Language |
|---|---|---|
| HTML Template | client | AngularJS template |
| CSS | client | SCSS or CSS |
| Client Script | client, in the widget controller | AngularJS |
| Server Script | server, in the widget's scope | Glide, with `$sp` |

Each placement is a **widget instance** in `sp_instance`, so options belong to the instance. The **option schema** defines those options; a new instance has none, so give the widget a default state instead of a blank one.

## APIs

- **Client:** `spUtil` (common utilities), `spModal`, `spContextManager` (shares widget data, for example with Agent Chat), `spAriaUtil` (screen reader messages).
- **Server:** `$sp`, class GlideSPScriptable; scoped reference exists.
- **Client to server:** `server.get` sends data and, with `input.action`, runs part of the server script.

```javascript
// Widget server script (server, widget's scope): read a URL parameter
data.table = $sp.getParameter('table');
```

```javascript
// Widget client script (client controller): ask the server to run an action
c.server.get({action: 'refresh'}).then(function(r) {
    c.data.items = r.data.items;
});
```

The Widget API reference confirms `server.get`, `server.update` and `server.refresh` return a promise; reading the result as `r.data` is general knowledge, not on the page. Data cycle, options, providers, embedding and translation: [[Service Portal Widget Development]].

## Reuse

- **Angular Providers** (`sp_angular_provider`): reusable, injected into several widgets; keep persistent data and shared logic here rather than in controllers.
- **Embedded widgets:** `<widget></widget>` in a template, or from a client or server script.
- **Dependencies** (`sp_dependency`): JavaScript, CSS and Angular modules linked to widgets.
- **Angular templates** (`sp_ng_template`).
- **Embeddables:** UI Builder components placed in portal pages and external sites ([[Service Portal Embeddables]]).
- **Translation:** `${}` or `gs.getMessage()` in template and scripts.
- UI macros on a catalog form can be replaced with a widget.

## Troubleshooting

Reduce complexity first, use **Widget diagnostics** from a portal page to see customisation levels, and check `sp_log` (full steps: [[Service Portal Widget Misbehaves or Loads Slowly]]). Portal-side, `glide.sp.show_console_error` shows console errors.

## $sp and spModal methods

From the Brazil API reference (documented, not tested).

**`$sp` (GlideSPScriptable, widget server script):**

| Group | Methods |
|---|---|
| Parameters and options | `getParameter(name)`, `getValue(name)`, `getValues(data, names)`, `getDisplayValue(field)` |
| Records | `getRecord(table, sys_id)`, `canReadRecord(gr)` or `canReadRecord(table, sys_id)`, `getField`, `getFields`, `getFieldsObject`, `getRecordValues`, `getRecordDisplayValues`, `getRecordElements`, `getForm(table, sys_id)`, `getListColumns(table, view)`, `getStream(table, sys_id)` |
| Catalog | `getCatalogItem(sys_id[, isOrdering])`, `getRecordVariables(gr, includeNil)`, `getRecordVariablesArray`, `getVariablesArray` |
| Knowledge | `getKBCount`, `getKBCategoryArticles`, `getKBCategoryArticleSummaries` |
| Portal | `getPortalRecord()`, `canSeePage(pageID)`, `getMenuItems`, `getMenuHREF`, `mapUrlToSPUrl(url)`, `getWidget(sysID, options)` (embed a widget from the server), `getUserInitials()`, `isRTLEnabled()`, `isUserCriteriaEnabled()`, `userCanSeeSearchSourceByCriteria`, `log(message)` |

**`spModal` (widget client script):** `alert(message)`, `confirm(message)`, `prompt(message, default)` and `open(options)`, each followed by `.then(fn)`. Options for `open`: `title`, `message`, `buttons`, `input` and `value`, `size` (`sm` or `lg`), `backdrop` (true, false or `static`), `keyboard`, `noDismiss`, and `widget` with `widgetInput` and `shared` to embed another widget.

```javascript
// Widget client controller
function(spModal) {
    var c = this;
    c.onOpen = function() {
        spModal.open({ title: 'Example dialog', widget: 'example-widget', widgetInput: { sys_id: c.data.sys_id } })
            .then(function() { c.server.update(); });
    };
}
```

## Example

Clone a base catalog widget as *Example Quick Order*, add option *Example Max Items*, read it in the server script, and place an instance on *example_home*.

## Related

- [[Service Portal Overview and Configuration]] · [[Scripting Overview - Script Types and Where They Run]] · [[Service Portal Widget Development]] · [[Service Portal Embeddables]] · [[Service Portal Widget Misbehaves or Loads Slowly]]
