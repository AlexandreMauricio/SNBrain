---
type: concept
tags: [concept, platform, roles, access-control, admin, update-sets, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Planning your application > Delegated Development (read 2026-10-08 through the docs site; whole section): Delegated Development, Exploring Delegated Development, Delegated development and deployment, Domain separation and Delegated Development, Configuring Delegated Development, Assign source control permissions, Assign delete permissions, Display or hide update set deployment permissions, Instance-specific deployment user roles, Add deployment user roles, System-managed developer and deployment roles, Administer Delegated Development, Delegate development and deployment permissions to personnel, Developer and deployment permissions, Remove a developer. Also the chapter pages Planning your application, Submit your idea for app development, Specify data for your application. https://www.servicenow.com/docs/r/application-development/delegated-development-and-deployment/delegated-development-landing.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Delegated Development and Deployment

**In one line:** lets a user without the `admin` role develop, publish or upgrade **one scoped application**, by ticking permissions in **Manage Developers**; each tick grants a system-managed role.

From the Brazil docs. Related controls: [[Application Administration and Collaboration Descriptors]] (with the collaboration application installed, the link reads **Manage Collaborators** and descriptors carry the same permissions).

## Rules

- Permissions are **per application** and only for **scoped** applications, never Global.
- Who may delegate: `admin`; but when application administration is on for that application, **only its application administrator**, and the delegated developer must also hold the application administrator role to use the permissions.
- Delegated developers can never add or remove the `admin` role.
- Domain separation: not supported.
- The admin setting permissions needs to know the file types: for example advanced business rules need *All File Types* **and** *Allow Scripting*.

## Giving and removing

**System Applications > My Company Applications** > open the application > **Manage Developers** > *Developers* or *Groups* > name > tick permissions (or **Delegated Admin** for all) > **Save**. Remove: same window, point at the name, minus icon; the associated application roles go too.

### Developer permissions

| Permission | Gives |
|---|---|
| **All File Types** | every application file type, including those no other tick covers; close to admin inside the application |
| **Allow Scripting** | write access to script fields (business rules, client scripts, flow script steps); also adds the SNC scripting role |
| **Tables & Forms** | columns, form and list layout |
| **Manage ACLs & Roles** | access controls and roles |
| **Workflow Studio** | flows and actions (script steps need Allow Scripting) |
| **Playbooks** | playbook design (editing activity subflows or actions needs the Workflow Studio permission) |
| **Decision Tables**, **Workflow** (legacy editor and Activity Creator), **UI Builder**, **Mobile Builders**, **Service Portal**, **Service Catalog** (items, record producers, variables), **Notifications**, **Reporting** (reports, scheduled reports), **Integrations** (web service and REST APIs, data sources, Integration Hub import) | the named tool or file types |
| **Source Control** | full source control access; the Source Control menu only shows with it |
| **Delete Application** | may delete the application |
| **Manage Collaborators** / **Invite Collaborators** | manage, or only invite, other developers (collaboration feature only) |
| **Delegated Admin** | all of the above; adds the SNC scripting role |

### Deployment permissions

| Permission | Gives | Shown by default (property) |
|---|---|---|
| **Upgrade App** | upgrade the application once installed here | yes (`com.snc.dd.upgrade_app_enabled`) |
| **Publish To App Repo** | publish to the application repository | yes (`com.snc.dd.publish_to_app_repo_enabled`) |
| **Publish To App Store** | publish to the ServiceNow Store | yes (`com.snc.dd.publish_to_app_store_enabled`) |
| **Publish To Update Set** | publish the application to an update set | no (`com.snc.dd.publish_to_update_set_enabled`) |
| **Manage Update Set** | create, edit, delete local update sets; preview, resolve and commit retrieved ones | no (`com.snc.dd.manage_update_set_enabled`) |
| **Submit for Deployment** | submit for review and deployment ([[AEMC Pipelines and Deployments]]); collaboration feature only | |

*Publish To Update Set* and *Manage Update Set* are mutually exclusive on one user.

## Instance-wide deployment roles

Given by hand on the user record, per instance; meant for people such as change staff on **non-production** instances. Think twice before granting on production.

| Role | Allows |
|---|---|
| `sn_appclient.app_client_company_installer` | **first-time** installation of applications belonging to the same company as the instance. After installing, the system adds an `sn_dd_<app_name>_upgrade_app` role so the user can upgrade that application later |
| `sn_appclient.app_client_user` | install and upgrade everything listed on the application client page ([[Admin Center, Store and Application Manager]]) |

## System-managed roles

Leave these to the system:

| Role | Meaning |
|---|---|
| `delegated_developer` | the user has at least one developer permission |
| `sn_dd_<app_name>_...` | one application-specific permission; the name carries the scope |

Related property `glide.security.add_admin_contained_roles_to_system` (default true): the *system* user gets every role contained in `admin`, scoped admin roles included; false restores the older behaviour where it had only `admin`.

## Planning chapter, the rest

- **Submitting an idea**: **Self-Service > Service Catalog >** category *Can We Help You?* > *Apply for Citizen Development*. Questions: application name, description, is the process repeatable, is there an email or spreadsheet process today, how many users, sensitive or personal data, data needed from other departments, who needs access. **Order Now**; approval is handled in [[App Engine Management Center]].
- **Choosing the data model**: reuse existing tables (normally global ones, or ones opened to all scopes), extend one (inherits the parent's fields: [[Table Extension and Extension Models]]), or create new tables (Table Builder in App Engine Studio, or table administration: [[Tables, Records and Table Relationships]]).
- Parallel work on several instances: [[Team Development]].

## Related

- [[Application Administration and Collaboration Descriptors]] · [[Application Access Settings and Cross-Scope Privileges]] · [[Team Development]] · [[Users, Groups and Roles Overview]] · [[Subscription Management]] · [[Update Sets]] · [[Application Repository, Publishing and Administering Apps]]
