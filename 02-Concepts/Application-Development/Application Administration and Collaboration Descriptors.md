---
type: concept
tags: [concept, platform, roles, access-control, security, script-include, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Learning about developing (read 2026-10-08 through the docs site): Application collaboration (install, create collaboration descriptors, add permissions, assign descriptors to users and to groups, collaboration permissions), Script protection policy, Application administration, Restrict access to an application, Access control rules in application administration apps, Configure a table in an application administration app to inherit global ACL rules, Access enforcement for ServiceNow Store apps. https://www.servicenow.com/docs/r/application-development/application-administration.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Application Administration and Collaboration Descriptors

**In one line:** two ways to control *people* around a custom application: **application administration** keeps even system admins out of a sensitive application's roles and data, and **collaboration descriptors** hand out development permissions per application.

From the Brazil docs. Scope-to-scope control is separate: [[Application Access Settings and Cross-Scope Privileges]].

## Application administration

For applications holding sensitive data (finance, personal data). With it on, a system `admin` can no longer:

- give themselves a protected application role, or join a group that has one, or inherit it;
- write or override ACLs to get into the application;
- impersonate a user holding the application's admin role (unless they hold it too).

Roles, by convention:

| Role | Does |
|---|---|
| `<application>.admin` (any role with **Application Administrator** ticked on the role record) | assigns the application's roles. Gives no other admin right: layouts, tables and fields still need system admin, or the developer role below |
| `<application>.developer` | works on the application; needs delegated development permissions as well |

Setup (admin):

1. Create the application admin role; on the role form add and tick **Application Administrator** (it replaced the old *Assignable by* field at Kingston).
2. Give the role to at least two users.
3. Log in as one of them; **System Applications > My Company Applications** > the application > tick **Application administration** > **Update**. The system refuses unless an application-admin role exists and you hold it.
4. Related links: **Manage Developers** (name developers, or make yourself one), **Grant application administration to all admins** (adds the role as contained in `admin` through `sys_user_role_contains`; published with the application, admins of the installing instance get in).

- Turn it on after development and **before** real records exist.
- Enabled with nobody holding the role = nobody can access the application. The only remaining holder cannot be removed.
- Property `<scoped_app_name>.min_admin_count` raises the minimum number of holders; holders cannot be removed down to or below it.
- Deploying: system admin on both instances. Create the role, give it to all admins, enable, publish, install on production, hand the role to the right people, then take it away from the system admins.

### ACLs in such applications

For configuration records (tables extending `sys_metadata`) of the application: its own scoped ACLs apply; where it defines none, global ACLs can apply if property `glide.security.scoped_administration.honor_global_acl` is true (default) **and** the table is listed in Application Administration ACL Inheritances (`sys_scoped_admin_acl_inheritance`), which only the application's administrator can maintain.

## Collaboration descriptors (App Engine)

A named bundle of development permissions given to a user or group **for one application**. Needs the application collaboration application (App Engine licence; **System Applications > All Available Applications**). On activation existing delegated developers receive custom descriptors matching what they had. Manage permissions either here or on the old **Manage Developers** screen of the application, never both.

| Descriptor | Meaning |
|---|---|
| **Owner** | manages collaborators, may delete the application |
| **Editor** | the standard invitee |
| custom | **App Engine > Collaboration > Descriptors > New**: **Name**, **Description**, **Application** (must be Global), **Standard** (needed for it to show in App Engine Studio) |

Assignment: related lists *Application collaboration users* and *Application collaboration groups* (**Collaboration Application**, user or group, **Collaboration Descriptor**). One descriptor per user per application directly; more can arrive through groups.

Permissions that can be put in a descriptor: All Metadata, Tables & forms, Workflow Studio, Playbooks (editing activity subflows also needs Workflow Studio), Decision Tables, Workflow (legacy editor), UI Builder, Mobile builders, Service Portal, Service Catalog, Notifications, Reporting, Integrations (web services, REST, data sources, Integration Hub import), Security Management (ACLs, roles), Invite collaborators. Broader groupings in the model: application management (delete, source control), file type access, security, programming tools (script fields), deployment.

## Script protection policy

On script includes published with an application:

| Policy | After installation elsewhere |
|---|---|
| None | readable and editable |
| Read-only | readable, not editable |
| Protected | logic hidden and not editable |

## Store applications: subscription enforcement

Production instances always monitor and report use of Store applications. The usage administrator allocates fulfiller users to the subscription and chooses: monitor only (default), or enforce, in which case non-subscribed users cannot perform fulfiller actions on the application's **fulfillment tables** ([[Application Scope and Namespace Identifiers]], [[Subscription Management]]).

## Related

- [[Application Access Settings and Cross-Scope Privileges]] · [[Application Scope and Namespace Identifiers]] · [[Users, Groups and Roles Overview]] · [[Base System Roles]]
