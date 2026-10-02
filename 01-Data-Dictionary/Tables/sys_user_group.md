---
type: table
tags: [table, schema, users, roles]
status: documented
source: ServiceNow Australia Platform Administration PDF, "User administration", topic "Creating groups" (pp. 363-366), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# sys_user_group

**Label:** Group (Groups)
**What it stores:** groups of users: assignment groups, approval groups, notification lists. Roles given to a group are inherited by its members.

## Key columns

Form labels from the guide; column names are not given.

| Label | Name | Meaning | Confidence |
|---|---|---|---|
| Name | ? | group name | documented |
| Manager | ? | group manager or lead (reference to user) | documented |
| Type | ? | group types (list): `catalog`, `itil`, `survey` in the base system. May need adding to the form | documented |
| Group email | ? | distribution list or contact address | documented |
| Parent | ? | parent group. The child inherits the parent's **roles**, not its membership | documented |
| Active | ? | inactive groups are hidden from non-admins in lists and lookups | documented |
| Exclude manager | ? | manager does not receive the group's email notifications | documented |
| Include members | ? | members get individual emails when mail goes to the group email. Approval notifications always go to all members | documented |
| Description | ? | | documented |

## Relations

- `sys_user_grmember` (`user`, `group`): members (related list **Group Members**)
- `sys_group_has_role`: roles of the group
- [[task]].`assignment_group` references this table, filtered by default to **Type equals itil**

## Gotchas

- Removing a parent group adds the parent's roles to the child group, asynchronously if `glide.ui.schedule_job_for_group_parent_change` is true.
- Add group types from the group form: unlock **Type**, open the lookup, **New**.

## Related

- [[Create a Group and Add Members]] · [[Users, Groups and Roles Overview]] · [[sys_user]]
