---
type: concept
tags: [concept, scripting, client-script, javascript, forms-lists]
status: documented
source: ServiceNow docs, Brazil, API implementation and reference > Scripting > Write client-side scripts, topics "Client scripts", "Display field messages", "General guidelines for client script design and processing", "Client-side scripting for mobile", and Example scripts > "Client-side script use cases", "Field script use cases", https://www.servicenow.com/docs/r/api-reference/scripts/client-scripts.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Client scripts

**In one line:** a client script (`sys_script_client`, table name from general knowledge) is JavaScript that runs in the **browser** on a form (or, for onCellEdit, in the list editor) to show, hide, require, set or validate fields while the user works; it is a convenience, never a security control.

## Types

| Type | Runs | Signature |
|---|---|---|
| **onLoad** | when the form renders, before input | `onLoad()` |
| **onChange** | when the chosen field changes, **and on load** | `onChange(control, oldValue, newValue, isLoading, isTemplate)`; `control` not available in mobile / portal; no old value for HTML fields |
| **onSubmit** | on submit; `return false` cancels | `onSubmit()` |
| **onCellEdit** | when a list cell is edited | `onCellEdit(sysIDs, table, oldValues, newValue, callback)`; `callback(true)` continues, `callback(false)` stops the save |

## The form

**System Definition > Client Scripts**: **Name**, **Table**, **UI Type** (*Desktop* Core UI only; *Mobile / Service Portal* also configurable workspaces; *All*), **Type**, **Field Name** (onChange, onCellEdit), **Application**, **Active**, **Inherited** (also on child tables), **Global** (all views) or **View**, **Description**, **Messages** (one per line, read with `getMessage()` for translation), **Script**, **Isolate script**, **Order** (add to the form; lower runs first).

**Isolate script** (default on new scripts): strict mode with no DOM, `window`, jQuery or Prototype. Untick per script for DOM access; `glide.script.block.client.globals` = false turns isolation off for new global scripts.

## Rules from the guidelines

- Client scripts and UI policies act on forms only (except onCellEdit). Data must also be protected for lists, imports and APIs: disable list editing, or add a business rule, data policy, ACL or onCellEdit script ([[Business Rules]], [[UI Policy or Data Policy]]).
- Prefer a UI policy when it can do the job: it has an order and no code. **UI policies run after client scripts.** See [[UI Policy or Client Script]].
- Wrap all code in the function: top-level variables are shared with every other client script on the page.
- Start onChange scripts with `if (isLoading) return;`, then check `newValue`, then `newValue != oldValue`, then cheap client checks, and only then call the server.
- Get server data with `g_scratchpad` (display business rule) or asynchronous GlideAjax, not `getReference()` or client GlideRecord ([[Script Includes and GlideAjax]]).
- `g_form.setValue('ref', sys_id, displayValue)` avoids a hidden server call.
- Avoid DOM manipulation (breaks on upgrades) and global client scripts (Table = Global loads everywhere; put shared scripts on a base table such as `task` or `cmdb_ci` instead).
- Do not update records before the form loads: it bypasses client logic.
- Show problems with `g_form.showFieldMsg(field, message, 'error' | 'info' | 'warning', scrollForm)` and `hideFieldMsg(field, clearAll)` rather than `alert()`.

## Mobile and Service Portal

Same API with limits:
- Tick the mobile UI type; no `g_form.getControl()`, `getFormElement()`, `getElement()`; no `window`, `document`, jQuery or Prototype; use `setLabel()`, `addDecoration()`, `hasField()` and the Mobile GlideForm methods.
- No synchronous calls: `g_form.getReference(field, callback)`, client `GlideRecord.query(callback)`, asynchronous GlideAjax only.
- No effect on mobile: `showRelatedList()`, `hideRelatedList()`, `flash()`, `getSections()`, `enableAttachments()`, `setReadonly()` (use `setReadOnly()`), `getParameter()`; focusing fields.
- UI policies: **Run scripts in UI type**. Modules must be in `sys_ui_application` / `sys_ui_module`; UI actions in `sys_ui_ng_action` to appear on mobile.
- The client script page also says client scripts are not supported in ServiceNow mobile applications, while the mobile page explains how to make them work: probably the native mobile apps versus the mobile web UI; unconfirmed.

## Examples given by the docs (patterns)

- Limit typing: `g_form.getControl('short_description').maxLength = 80;` (DOM; desktop only).
- Change form colour on state change, flash or bold a label, make fields read-only, auto-fill a short description from the subcategory, trim spaces, set the current date/time, toggle a timer: all in the field and client use-case pages.
- UI action with both client and server code (UI action, **Client** ticked, global scope):

```javascript
// onClick = resolveRecord(); Action name = example_resolve
function resolveRecord() {                 // runs in the browser
    g_form.setValue('state', 6);
    gsftSubmit(null, g_form.getFormElement(), 'example_resolve'); // re-submits, running onSubmit scripts and mandatory checks
}
if (typeof window == 'undefined')          // true only on the server pass
    serverResolve();
function serverResolve() {                 // runs on the server
    current.state = 6;
    current.update();
}
```

  `gsftSubmit(control, form, action_name)` must name the UI action's **Action name**. (Adapted from the docs' incident example, which also sets `resolved_by` from `g_user.userID` / `gs.getUserID()`.)
- "UI routing action": a task-extended *New Call* table whose UI actions create an incident or a RITM from it, so the service desk can log a call before knowing its type.

## Related

- [[UI Policies]] · [[Catalog Client Scripts, UI Policies and Variable Editors]] · [[Debugging Scripts]] (JavaScript log, field watcher)
