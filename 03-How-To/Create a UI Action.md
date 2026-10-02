---
type: how-to
tags: [how-to, forms-lists, ui-action, scripting]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Form administration", topics "Create a UI action" and "Override a UI action for an extended table" (pp. 786-790), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Create a UI action

**Goal:** add a button, link or menu item to a form or list that runs your script.
**Prerequisites:** role `ui_action_admin` or admin. The table must be in the same scope as the UI action, or allow UI actions from other scopes.
**Navigation:** All > System Definition > UI Actions

## Steps

1. Open **All > System Definition > UI Actions** and select **New**.
2. Set **Name**, **Table**, **Action name** and **Order**. Tick **Active**.
3. Choose when it shows: **Show insert**, **Show update**.
4. Choose where: **Form button**, **Form context menu**, **Form link**, or the list options.
5. Add a **Condition** (server-side JavaScript) and, if needed, **Requires role**.
6. Write the **Script**. For browser execution tick **Client**, put the function name in **Onclick**, and wrap the code in that function.
7. Submit. Configure the form if some fields are not visible.

## Result / how to check it worked

Open a record (or list) of the table as a user who meets the condition and role: the control is there and runs the script.

## Example

A form button *Example Create Follow-up* on Incident, shown on update only, condition `current.active`:

```javascript
var followUp = new GlideRecord('incident');
followUp.initialize();
followUp.short_description = 'Follow-up: ' + current.short_description;
followUp.parent = current.sys_id;
followUp.insert();
gs.addInfoMessage('Follow-up ' + followUp.number + ' created');
action.setRedirectURL(followUp);
action.setReturnURL(current);
```

## Tables / fields involved

- the UI action's table and anything the script touches

## Gotchas

- Override on a child table: same **Action name** on the child. Remove for a child: add `current.getRecordClassName() != '<child>'` to the parent action's condition.
- List banner button conditions only look at the first row.
- Field reference and the rest of the rules: [[UI Actions]].
