---
type: concept
tags: [concept, roles, access-control, users, security]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Managing roles" (pp. 422-424, 438-445), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Role management

**In one line:** roles are created, nested, given to groups or users, delegated, time-limited and audited from User Administration; assigning roles also drives subscription (licence) usage.

## Creating and nesting

- **User Administration > Roles > New** (admin). Fields: **Name**, **Requires Subscription** (Yes = measured role; No; Unspecified), **Application**, **Elevated privilege**, **Description**.
- A new role grants nothing until it is added to applications and modules (lock icon on **Roles** in **System Definition > Applications** or **Modules**), to ACLs, or until other roles are put inside it.
- **Contains Roles** related list: adding role B inside role A gives every holder of A the access of B.
- **Elevated privilege** roles are not active at login; the user must elevate (e.g. `security_admin`).
- **Subscription warning**: unless subscriptions are allocated manually, assignments are derived from roles, so creating and assigning roles can change subscription usage.

## Assigning

- **To a group** (preferred): group record, **Roles** related list, **Edit**. Or **User Administration > Group Roles** with **Inherits** ticked (default) so members inherit. Role `user_admin` or admin.
- **To a user**: user record, **Roles** related list, **Edit**. Only roles of installed applications are listed.
- A new role **takes effect at the user's next session** (log out and in).
- Only an admin can grant `admin`; only a user who has **elevated to** `security_admin` can grant `security_admin`.
- A role inherited from a group cannot be removed on the user record: remove the user from the group.
- Large group changes can run in the background with `glide.ui.schedule_slushbucket_save_for_group_roles` = true (records are then written by the system user).

## Role delegation

- A **role delegator** (`role_delegator`) can give other users of a group roles **that the delegator already has**.
- Designate: **User Administration > Designate Role Delegator** (group, user). Delegate: **User Administration > Delegate Roles in Group**.
- The business rule *Group Manager Change* (off by default) gives `role_delegator` to whoever is **Manager** of a group, and removes it when they stop being manager.
- Not delegable by default: `admin`, `public`, `role_delegator`. To block another role, clear **Grantable** or **Can delegate** on the role (add the fields to the form).

## Time-limited roles

- **User Administration > Time-limited user roles** (role `user_admin`): **Role**, **User**, **Start Time**, **End Time**, **Active**.
- Only `admin`, `snc_read_only`, `impersonator` and `snc_required_script_writer_permission`.
- At most **5 days**, and at most four concurrent time-limited roles per user.
- Activated and removed automatically. Not shown on the user's Roles tab; the user gets a notification at login.
- Can consume subscription rights.

## Read-only role (`snc_read_only`)

- Plugin Read-Only User Role (`com.snc.read_only.role`). **Assign to users only.**
- The user can no longer insert, update or delete on **any** table, through the UI or GlideRecord, whatever other roles they have, and **even when impersonating an admin**. They also cannot activate plugins, run SQL, upload XML, or run background scripts.
- Useful for auditors.
- Exempt tables (comma-separated table names; add the properties if missing):

| Property | Default tables |
|---|---|
| `glide.security.snc_read_only_role.tables.exempt_create` | `sys_user_session`, `sysevent`, `syslog`, `syslog_transaction`, `sys_user_preference`, `sys_ui_list`, `sys_ui_list_element`, `sys_db_cache`, `user_multifactor_auth` |
| `glide.security.snc_read_only_role.tables.exempt_write` | same list |
| `glide.security.snc_read_only_role.tables.exempt_delete` | `sys_user_preference`, `sys_ui_list`, `sys_ui_list_element`, `sys_db_cache`, `user_multifactor_auth` |

Test by assigning it to a user and impersonating them.

## Auditing

- Audit Roles (`sys_audit_role`, `sys_audit_role.list`): **User**, **Role**, **Operation** (Added, Removed), **Granted by group**, **Changed by**, **Count after change**.
- Report: **System Security > Reports > Role audit**. Delegators: **User Administration > Role delegators**.

## Where it lives in the data

- `sys_user_role`: roles
- `sys_user_has_role` (`user`, `role`): roles per user
- `sys_group_has_role`: roles per group
- `sys_user_grmember` (`user`, `group`): group membership

## Related

- [[Base System Roles]] · [[Assign Roles to Users and Groups]] · [[Users, Groups and Roles Overview]]
