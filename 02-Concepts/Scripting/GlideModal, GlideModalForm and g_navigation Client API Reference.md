---
type: reference
tags: [reference, scripting, client-script, ui-action, glide-api]
status: documented
source: ServiceNow Brazil docs, API implementation and reference > Client API reference, pages GlideModal - Client, GlideModalForm - Client, GlideNavigation - Client, GlideGuid - Client, GlideURLV3 - Client, read 2026-11-06 through the docs site API (map ooCZhg2g6YDYvKp3oBwAxA). g_modal and GlideModal (Next Experience) pages not read. ServiceNow Brazil docs, API reference page(s) GlideAgentWorkspace (g_aw) - Client, read 2026-11-06 through the docs site API (map ooCZhg2g6YDYvKp3oBwAxA).
sn-release: Brazil
verified:
verified-by:
updated: 2026-11-06
---

# GlideModal, GlideModalForm and g_navigation Client API Reference

**In one line:** browser-side classes to open dialogs, show a form in a dialog, and move the user to another page or record in Core UI.

From the Brazil docs, not tested. They run in the browser, usually from a UI action with **Client** ticked ([[UI Actions]]). Configurable workspaces use other APIs, `g_modal` and GlideModal (Next Experience), which are not read here. Service Portal uses `spModal` ([[Service Portal Widgets]]).

## GlideModal

- `new GlideModal('<UI page name>', readOnly, width)`, then `setTitle()`, `setWidth()`, `setPreference(name, value)` (read in the UI page), and **`render()`**. Or use `renderWithContent(html)` for passed HTML.
- `get(id)` finds an open modal, `destroy()` closes it, `getPreference()`, `setPreferenceAndReload()`, `switchView()`, `updateTitle()`.

## GlideModalForm

`new GlideModalForm('<title>', '<table or form name>', callback)`, then `setSysID()` (empty means a new record), `addParm(name, value)`, `setOnloadCallback()`, `setCompletionCallback()`, `render()`.

## g_navigation, g_guid, GlideURL

| API | Methods |
|---|---|
| `g_navigation` | `open(url, target)`, `openRecord(table, sys_id)`, `openPopup(url, name, features, ...)`, `refreshNavigator()`, `reloadWindow()` |
| `g_guid` | `generate(length)`: a unique identifier |
| `GlideURL` (GlideURLV3) | `new GlideURL(contextPath)`, `addParam()`, `getURL()`. Only with ListV2 and ListV3; not in Service Portal, Now Mobile or Agent Workspace |

## g_aw (Agent Workspace)

`g_aw.openRecord(table, sysId, params)` opens a record in a subtab, while `g_aw.closeRecord()`, `setSectionExpanded(section, expanded)` and `domainScopeProvider()` handle the rest. It works from UI actions and client scripts in **Agent Workspace**, which [[Migrating from ITSM Agent Workspace to Service Operations Workspace]] treats as being replaced.

## Example

```javascript
// Client UI action on Incident (incident), Client ticked, onclick openExampleDialog()
function openExampleDialog() {
    var dialog = new GlideModalForm('Example Problem', 'problem', function() {
        g_navigation.reloadWindow();
    });
    dialog.addParm('sysparm_query', 'short_description=Example from incident');
    dialog.render();
}
```

`sysparm_query` as a preset for the new record is general knowledge, not from these pages.

## Related

- [[GlideForm and GlideAjax Client API Reference]] · [[UI Actions]] · [[UI Scripts, UI Pages, UI Macros and Jelly]] · [[Service Portal Widgets]]
