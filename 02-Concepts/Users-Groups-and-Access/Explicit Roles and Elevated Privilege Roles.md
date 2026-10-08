---
type: concept
tags: [concept, roles, access-control, security, users, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Security Roles (whole section, 6 topics, 387 cleaned lines, read in full 2026-10-08 through the docs site) - Explicit Roles (plugin behaviour, do_not_fix property, hasRoles, mutual exclusion table, requesting the plugin), Elevated privilege roles, Security_admin role, Elevate to a privileged role, Force administrators to manually elevate. https://www.servicenow.com/docs/r/platform-security/security-roles.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Explicit Roles and Elevated Privilege Roles

**In one line:** two role mechanisms that are about *kind of user* and *moment of use* rather than job function: the **explicit roles** `snc_internal` and `snc_external` separate employees from outsiders, and **elevated privilege** roles (such as `security_admin`) are held but only active after the user elevates for the session.

From the Brazil docs. Roles in general: [[Role Management]], [[Base System Roles]]. ACLs: [[Access Control Lists (ACLs)]].

## Explicit roles

Plugin **Explicit Roles** (`com.glide.explicit_roles`), requested through Now Support (**System Applications > All Available Applications > All > Request plugin**); needs the Contextual Security Manager. Activate in a maintenance window: users already logged in get the role only at their next login.

| With the plugin | |
|---|---|
| Every user | needs `snc_internal` to reach internal resources or `snc_external` for external ones; with neither, only public resources |
| Existing users | all receive `snc_internal` (including outsiders created earlier: **swap them to `snc_external` by hand**) |
| New users | get `snc_internal` at first login unless they already hold `snc_external` (also when the login is an impersonation) |
| ACLs without a role | existing and new ones get `snc_internal`, so nothing changes for internal users |
| Processors of type script without roles | get `snc_internal` |
| The `*` ACLs of type `ui_page` and `processor` | get `snc_internal` |

An external user can reach nothing unless an ACL names `snc_external` or a role that contains it: not tables, not UI pages or processors, not Platform Analytics dashboards. Granting a table: [[Access Control Lists (ACLs)]] (section on `snc_external`).

Rules:

- **No user may hold both** (since Paris). The platform aborts any change that would cause it, directly or through a group, a parent group or role containment, and logs the conflict. Only the first collision is reported: fix it and try again.
- No role can be added as contained in `snc_internal` or `snc_external`. An ACL **may** list both, when the object is for everyone.
- Never mark `snc_internal` as elevated: nobody could log in.
- Do not move update sets between instances with and without the plugin.

| Tried | Result |
|---|---|
| add the other explicit role to a user who has one | aborted |
| add an explicit role to a group whose member (or sub-group member) has the other | aborted |
| add an explicit role to a role already granted to a user holding the other | aborted |
| add an explicit role to a user, an empty group or an unused role that has none | added (and inherited downwards) |
| re-parent a group so that parent and child carry different explicit roles | aborted |

Properties (Xanadu changed the behaviour: `snc_internal` is now the same in memory and in `sys_user_has_role`):

| Property | Effect |
|---|---|
| `glide.security.explicit_roles.do_not_fix` | false: add `snc_internal` at login, in memory and in the table. true: do not add it |
| `glide.security.explicit_roles.ignore.snc_internal.exclude_role_list` | roles whose holders do not receive `snc_internal` |
| `glide.security.explicit_roles.do_not_fix_in_memory` | restores the pre-Xanadu behaviour |

Scripting: `hasRoles()` (deprecated since Geneva) ignores `snc_internal` and returns false for a user with only that role or with `snc_external`; use `hasRole('<role>')`.

## Elevated privilege roles

Any role can be marked **Elevated privilege** on the role form. Its holder does not have it at login: they pick it under the user menu > **Elevate Roles**, and it lasts until logout or session timeout (or until unticked in the same dialog).

- Elevation is per role: elevating to role A that contains elevated role B does **not** give B; elevate to B too.
- Base system: only `security_admin` is elevated. It gives access to ACLs and High Security Settings, and is assigned to the default System Administrator account. The role record is invisible in the roles list until you have elevated.
- The page on elevating says only the base system admin can elevate and that other users given admin cannot (yet the role can be granted to others by an elevated `security_admin`; contradictory (?)).

Granting:

| Role | Who can grant it |
|---|---|
| `admin` | only an admin (a `user_admin` cannot, nor add a user to a group carrying admin) |
| `security_admin` | an admin who has **elevated to** `security_admin`; nobody else can add a user to a group carrying it |

Marking `admin` itself as elevated is **not supported**. To make admins choose deliberately, set `glide.security.strict_elevate_privilege` = true (as `security_admin`, in `sys_properties.list`): at login they get a dialog to select the role to elevate to.

## Related

- [[Role Management]] · [[Base System Roles]] · [[Users, Groups and Roles Overview]] · [[Access Control Lists (ACLs)]] · [[Impersonation]] · [[Non-Interactive Users]]
