---
type: how-to
tags: [how-to, reference-field, encoded-query, scripting, script-include]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Field administration", topics "Configure reference qualifiers", "Constrain the assigned to field by role", "Constrain the assignment group field" (pp. 984-987), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Configure a reference qualifier

**Goal:** limit the records a reference field offers.
**Prerequisites:** role `personalize_dictionary` or admin. Knowledge of the table and column names involved.
**Navigation:** right-click the reference field label, Configure Dictionary, Advanced view

## Steps

1. Right-click the reference field's label and select **Configure Dictionary**.
2. Under Related Links select **Advanced view**.
3. In **Reference Specification**, check **Reference** names the right table.
4. Choose **Use reference qualifier**:
   - **Simple**: build the condition.
   - **Dynamic**: select (or create) a dynamic filter option.
   - **Advanced**: in **Reference qual**, enter an encoded query or `javascript:` that returns one.
5. **Update**.

To limit the change to a child table, do it in a dictionary override on that table instead.

## Result / how to check it worked

Open a record and use the field's lookup: only matching records are listed. Type-ahead is filtered the same way.

## Example

**Users with a given role** (uses the base business rule `getRoledUsers`):

```javascript
javascript:"sys_idIN" + getRoledUsers("IN", "example_role").join(",")
```

**Groups the assignee belongs to**, on Assignment group, with a script include:

```javascript
// Reference qual: javascript:new ExampleRefQualHelper().groupsOfAssignee()
var ExampleRefQualHelper = Class.create();
ExampleRefQualHelper.prototype = {
    groupsOfAssignee: function() {
        var assignee = current.assigned_to;
        if (!assignee)
            return;                      // no filter: all groups
        var ids = [];
        var gm = new GlideRecord('sys_user_grmember');
        gm.addQuery('user', assignee);
        gm.query();
        while (gm.next())
            ids.push(gm.getValue('group'));
        return 'sys_idIN' + ids.join(',');
    },
    type: 'ExampleRefQualHelper'
};
```

Select a user in **Assigned to**, then open the **Assignment group** lookup: only that user's groups show.

## Tables / fields involved

- `sys_user_grmember`: user-to-group membership (`user`, `group`)
- `sys_user_has_role`: user-to-role (`user`, `role`); `sys_user_role`: roles (`name`)
- [[sys_dictionary]]: **Use reference qualifier**, **Reference qual condition**, **Dynamic ref qual**, **Reference qual**

## Gotchas

- The guide's own example calls `getRoledUsers("itil_admin")` with one argument; the function's signature is `getRoledUsers(queryCondition, roleList)` and without both it returns users having any role. Test the result.
- A script include called from a qualifier must be accessible from the field's scope (**Accessible from**), and its name must match the call.
- Returning nothing means no filter.
- Not security: an ACL is still needed to stop access. More in [[Reference Qualifiers]].
