---
type: how-to
tags: [how-to, users, roles, business-rule]
status: documented
source: ServiceNow Australia Platform Administration PDF, "User administration", topic "Creating groups" (pp. 363-366), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Create a group and add members

**Goal:** create a group, give it members (and roles), and optionally hide it from non-members.
**Prerequisites:** role `user_admin`.
**Navigation:** All > User Administration > Groups

## Steps: create

1. Open **All > User Administration > Groups** and select **New**.
2. Fill **Name**, **Manager**, **Group email**, **Parent**, **Type** (personalize the form if Type is missing), **Description**.
3. Submit.

## Steps: add or remove members

1. Open the group.
2. In the **Group Members** related list select **Edit**, move users from the collection, **Save**.
3. To remove: tick the members in the related list, **Actions on selected rows > Delete**.

## Steps: hide a group from non-members (guide's pattern)

1. Add a True/False field **Hidden** to the Group form (creates `u_hidden`).
2. Create a **before query** business rule on Group (`sys_user_group`):

```javascript
if (!gs.hasRole("admin") && !gs.hasRole("groups_admin") && gs.getSession().isInteractive()) {
    var qc = current.addQuery("u_hidden", "!=", "true");            // cannot see hidden groups...
    qc.addOrCondition("sys_id", "javascript:getMyGroups()");        // ...unless a member
}
```

## Result / how to check it worked

Members inherit the group's roles. With the business rule, a non-member no longer finds the hidden group in reference fields.

## Example

Group *Example Network Team*, type `itil`, parent *Example Infrastructure*, three test users as members. Tasks can be assigned to it because of the `itil` type.

## Tables / fields involved

- [[sys_user_group]], `sys_user_grmember`, `sys_group_has_role`

## Gotchas

- Members of a child group are not members of the parent, although the child inherits the parent's roles.
- You cannot add users to a group carrying `admin` unless you are admin, nor one carrying `security_admin` without that role.
- Check the selected rows before deleting memberships.
- A group with a type other than `itil` (and not empty) is not offered in **Assignment group** on tasks by default.
