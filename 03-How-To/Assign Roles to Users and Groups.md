---
type: how-to
tags: [how-to, roles, users, access-control]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Managing roles", topics "Create a role", "Assign a role to a group", "Assign a role to a user", "Add a role to an existing role", "Grant a time-limited user role" (pp. 438-445), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Assign roles to users and groups

**Goal:** give people access through roles: by group, directly, by nesting roles, or for a limited time.
**Prerequisites:** role `user_admin` or admin (admin to create roles or nest them).
**Navigation:** All > User Administration > Groups / Users / Roles / Time-limited user roles

## Steps: role on a group (preferred)

1. **User Administration > Groups**, open the group.
2. In the **Roles** related list select **Edit**, add the roles, **Save**.

## Steps: role on a user

1. **User Administration > Users**, open the user.
2. In the **Roles** related list select **Edit**, add from the collection, **Save**.

## Steps: create a role and nest roles

1. **User Administration > Roles**, **New**: name, application, description. Submit.
2. Open a role, **Contains Roles** related list, **Edit**, add the roles it should include, **Save**.
3. Give the role something to control: add it to an application or module (**System Definition > Applications / Modules**, lock icon on **Roles**) or to ACLs.

## Steps: time-limited role

1. **User Administration > Time-limited user roles**, **New**.
2. Set **Role** (admin, snc_read_only, impersonator or snc_required_script_writer_permission), **User**, **Start Time**, **End Time** (within 5 days), **Active**. Submit.

## Result / how to check it worked

The user's **Roles** related list shows the role (inherited ones marked as such; time-limited ones are not listed). Impersonate the user or have them start a new session.

## Example

Role *example_laptop_manager* contains `personalize_choices`; group *Example Asset Team* holds that role and `asset`; a test user added to the group gets all three on next login.

## Tables / fields involved

- `sys_user_role`, `sys_user_has_role`, `sys_group_has_role`, `sys_user_grmember`

## Gotchas

- New roles apply only to a **new session**.
- Roles from a group cannot be removed on the user: remove the membership.
- Granting `admin` needs admin; granting `security_admin` needs elevation to `security_admin`.
- Role assignments can change subscription usage.
- More in [[Role Management]]; what each role does in [[Base System Roles]].
