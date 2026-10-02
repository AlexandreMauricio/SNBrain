---
type: concept
tags: [concept, ui-policy, forms-lists, scripting, client-script]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Form administration", topic "Using UI policies" (pp. 790-794), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# UI policies

**In one line:** a UI policy makes fields mandatory, read-only or hidden on a form when conditions are met, without scripting, and can optionally run client-side scripts.

## How it works

- Defined at **All > System UI > UI Policies**. Role `ui_policy_admin`. The form opens in the Advanced view; several fields below exist only there.
- **Conditions** are built with the condition builder and evaluate all fields of the record, **even ones not on the form**.
- Each **UI Policy Action** (related list) names a field and sets **Mandatory**, **Visible** and **Read only** to *True*, *False* or *Leave alone*. If the field is not on the form, the action is applied to a variable of the same name.

## Key fields

| Field | Notes |
|---|---|
| **Table**, **Active**, **Short description** | |
| **Order** | lowest first; **when two policies conflict the higher order wins** (it runs last) |
| **Global** / **View** | global applies to all views; otherwise only the named view (blank = default view) |
| **Reverse if false** | undo the actions when the condition becomes false |
| **On load** | also apply when the form loads, not only when a field changes |
| **Inherit** | child tables inherit the policy. **A child table's policies always run before the parent's, whatever the order**, so the parent's result wins on conflict |
| **Run scripts**, **Execute if true**, **Execute if false** | client-side scripts for each outcome. *Execute if false* needs **Reverse if false** |
| **Run scripts in UI type** | Desktop, Mobile / Service Portal, or Both |

Script shape:

```javascript
function onCondition() {
    alert('Placeholder message shown when the condition is met.');
}
```

## Limits

- **Conditions are only rechecked when a user changes a field by hand on the form.** Changes made by a UI action, a context menu action or the list editor are not evaluated.
- Not supported on search screens.
- To build the condition with a script, use a client script instead.
- A UI policy is a form (client) control, not security: it does not stop a script or an import from writing the field.

## On load example from the guide

To force a comment only when the state is *changed* to Awaiting user info: condition **State is Awaiting user info**, **On load** cleared, action makes **Additional comments** mandatory. With On load ticked it would also fire every time such a record is opened.

## Related

- [[Create a UI Policy]] · [[UI Policy or Client Script]] · [[UI Actions]] · [[Read-Only Field Options]]
