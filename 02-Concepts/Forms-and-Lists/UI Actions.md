---
type: concept
tags: [concept, forms-lists, ui-action, scripting, workspace]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Form administration", topic "Defining UI actions" (pp. 784-790), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# UI actions

**In one line:** a UI action is a button, link or context menu item on a form or list that runs a script, on the server by default or in the browser when **Client** is ticked.

## Where a UI action can appear

| Form | List |
|---|---|
| Form button | List banner button |
| Form context menu | List bottom button |
| Form link (Related Links) | List context menu (right-click a cell) |
| | List choice (the actions dropdown) |
| | List link |

Workspaces: **Workspace Form Button**, **Workspace Form Menu**, **Format for Configurable Workspace** (cleared means Legacy Workspaces), **Workspace Client Script**.

## Key fields

Defined at **All > System Definition > UI Actions**. Role `ui_action_admin` or admin.

| Field | Notes |
|---|---|
| **Name** | text on the control |
| **Table** | also applies to tables that extend it (a Task action shows on Incident). **Global** = all tables |
| **Action name** | unique name for scripts and for overriding. Two actions with identical Name and Action name are de-duplicated at runtime |
| **Order** | left to right for buttons, top to bottom for menus |
| **Show insert** / **Show update** | on new records / on existing records |
| **Client** / **Onclick** | run in the browser; Onclick names the function defined in **Script** |
| **Condition** | JavaScript, **always evaluated on the server** |
| **Script** | what runs. Function names must be unique |
| **Form style** / **List style** | Primary (blue), Destructive (red), Unstyled |
| **Overrides** | the UI action this one overrides |
| **Messages** | keys for localised messages (`getMessage`) |
| **Hint**, **Comments** | tooltip, notes |
| **Requires role** | user needs at least one |
| **UI Action Visibility** (related list) | per view: no rules = all views; any exclude rule hides it on that view; with at least one include rule it shows only on included views |

## Rules worth remembering

- **A client-side script must be wrapped in a function**, or it runs when the page loads.
- **List banner buttons**: the condition is evaluated on the **first row only**. Do not use record-specific conditions there.
- **List bottom buttons and list choices** show regardless of condition and are evaluated per record when run.
- **List context menu**: `current` is not available in the condition.
- On a related list button, the condition can use `parent` (the record the list is on), e.g. `parent.active`.
- A condition that tests an empty field defaults to true for that part.
- To hide **New** or **Edit** on a related list, use list control, not a UI action.
- Redirect after running: `action.setRedirectURL(record_or_url);` and `action.setReturnURL(current);`

## Overriding for a child table

- **Override**: create a UI action on the child table with the **same Action name** and a script specific to it.
- **Remove for one child**: on the parent's UI action add the condition `current.getRecordClassName() != 'incident'`.
- Not applicable on domain-separated instances.

## Related

- [[Create a UI Action]] · [[UI Policies]] · [[Form Layout, Sections and Views]]
