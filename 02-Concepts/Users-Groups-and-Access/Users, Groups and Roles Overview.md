---
type: concept
tags: [concept, users, roles, access-control]
status: documented
source: ServiceNow Australia Platform Administration PDF, "User administration" (pp. 346-355, 363-366), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Users, groups and roles overview

**In one line:** a **user** is a person (or machine or AI identity) with access to the instance, a **group** is a set of users with a shared purpose, and a **role** grants access to features; the recommended pattern is roles on groups, users in groups.

## The three objects

| Object | Table | Module | Who manages |
|---|---|---|---|
| User | [[sys_user]] | **User Administration > Users** | `user_admin` |
| Group | [[sys_user_group]] | **User Administration > Groups** | `user_admin` |
| Role | `sys_user_role` | **User Administration > Roles** | admin |

- **Roles can contain other roles.** Access granted to a role is granted to every role that contains it. `admin` has access to everything.
- A user in a group **automatically gets all roles of the group**. Business rules, assignment rules and notifications that refer to a group apply to all its members.
- Guide's advice, repeated throughout: build groups that carry the roles of a persona, then put users in those groups, instead of giving roles to users one by one.
- Users also link to: delegates (another user acting with their permissions), skills, subscriptions, and user preferences.

## How users get created

- Usually by an **LDAP** directory integration.
- Manually: [[Create a User]].
- **Self-registration**: plugin User Registration Request (`com.snc.user_registration`) adds a request form to the welcome screen. Requests appear under **User Administration > Pending User Registrations** with **Create User** and **Reject** links; the email address becomes the User ID. A request for an email already in the system is not submitted. The property *Enable auto processing of user registration request* (**System Properties > System**) lets the business rule *Auto-Process User Registration* create users without approval. The guide then suggests the Explicit Roles plugin (`com.glide.explicit_roles`) to separate internal from external users.

## Identity types

A user's **Identity type** is Human, Machine or AI.

- **Machine**: a service account making automated requests. Selecting it ticks **Web service access only** (non-interactive): the user cannot log in to the UI.
- **AI**: for an AI agent or agentic workflow that needs more permissions than the invoking user. Changing to or from AI is restricted.

## System and guest users

Records sometimes show as last updated by `system` or `guest`: the first login of the day updates **Last login** as system; failed logins and lockouts update **Failed login attempts** and **Locked out** as guest. Audit the table to see which fields changed.

## Group facts

- **Parent**: a child group **inherits the roles** of its parent, but its members are **not** members of the parent (they are not offered in **Assigned to** when a task is assigned to the parent group).
- **Type**: categories of groups (`catalog`, `itil`, `survey` in the base system). The reference qualifier on `task.assignment_group` filters **Type equals itil**; groups with an empty type are treated as ITIL. Override per table with a dictionary override, or use the `GetGroupFilter` dynamic filter option.
- **Inactive** groups stay on records that already reference them but are hidden from non-admins in lists, lookups and type-ahead. Inactive users behave the same way.
- A non-admin cannot add users to a group that carries the admin role; without `security_admin` you cannot add users to a group that carries it.

## Related

- [[Create a User]] · [[Create a Group and Add Members]] · [[Base System Roles]] · [[Role Management]]
