---
type: concept
tags: [concept, portal, scripting, javascript, release-specific]
status: documented
source: ServiceNow Brazil docs, ServiceNow AI Platform user interface > Service Portal > Using portal widgets, Developing custom widgets (overviews of guidelines, tutorial, clone, create, option schema, API reference, Angular Providers, embedded widgets, dependencies, internationalize, troubleshooting, embeddables, diagnostics), read at overview depth 2026-10-30. Tutorial steps and API method detail not read. https://www.servicenow.com/docs/r/platform-user-interface/service-portal/service-portal-roles.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
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

The second snippet's `.then` shape is general knowledge plus the page's `server.get` mention, not checked against the API page.

## Reuse

- **Angular Providers** (`sp_angular_provider`): reusable, injected into several widgets; keep persistent data and shared logic here rather than in controllers.
- **Embedded widgets:** `<widget></widget>` in a template, or from a client or server script.
- **Dependencies** (`sp_dependency`): JavaScript, CSS and Angular modules linked to widgets.
- **Angular templates** (`sp_ng_template`).
- **Embeddables:** UI Builder components placed in portal pages and external sites.
- **Translation:** `${}` or `gs.getMessage()` in template and scripts.
- UI macros on a catalog form can be replaced with a widget.

## Troubleshooting

Reduce complexity first, use **Widget diagnostics** from a portal page to see customisation levels, and check `sp_log`. Portal-side, `glide.sp.show_console_error` shows console errors.

## Example

Clone a base catalog widget as *Example Quick Order*, add option *Example Max Items*, read it in the server script, and place an instance on *example_home*.

## Related

- [[Service Portal Overview and Configuration]] · [[Scripting Overview - Script Types and Where They Run]]
