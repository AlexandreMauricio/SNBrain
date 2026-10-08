---
type: concept
tags: [concept, platform, roles, admin, instance-admin, integrations, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Developing your application > App Engine Studio (read 2026-10-08 through the docs site): Build apps using App Engine Studio, Exploring App Engine Studio, AES user interface, Migrating to Build Agent, Getting started with Build Agent, App Engine Studio and Build Agent feature comparison, Use App Engine instead of customization, Customization vs. configuration with App Engine Studio, Integrated development tools for AES, Get help, App Engine and App Engine Studio, Learning plan, Configuring App Engine Studio and related apps, AES and domain separation, Installing App Engine Studio (instance strategy, AES and the Store, entitlement, first install, product and integrations, update, upgrade), Components installed with AES, Configure App Engine Studio, Configure AES personas and roles, Perform AES configuration tasks (App Engine Admin group, grant user access, manage template access, custom collaboration descriptors), Delegate developers using AES, AES integration with a Git source control repository, Link an application to source control, Edit a Git repository configuration, Cloning instances with AES. https://www.servicenow.com/docs/r/application-development/app-engine-studio/aes-overview.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# App Engine Studio Overview, Setup and Roles

**In one line:** App Engine Studio (AES) is the guided, **low-code** builder: wizards and templates produce a scoped application made of four parts (data, experiences, logic and automation, security), each opened in its own builder tool.

From the Brazil docs. Building in it: [[App Engine Studio Building Reference]]. The no-code sibling: [[Creator Studio Overview, Setup and Roles]]. Open at **All > App Engine > App Engine Studio**.

## What it is and is not

- **App Engine** is the licensed product suite and platform services (governance, lifecycle); **App Engine Studio** is the development tool inside it.
- Scoped applications only; no direct script editing. To script, the application is opened in ServiceNow Studio (converted to Fluent).
- Not domain separated. A subscription is needed on any customer instance; free on a PDI.
- Home page: **Create app**, quick start, *My recent apps*, tabs **My Apps**, **Templates** (hidden for the limited group), **Resources**. An application's home lists its Data, Experience, Logic and automation, and Security items; *Application properties* (name, description, logo, open in ServiceNow Studio, delete); *Repository configuration*.
- The customise / configure / build-new argument is the same text as for Creator Studio: [[Creator Studio Overview, Setup and Roles]].

Intended flow: idea submitted through application intake > admin approves ([[App Engine Management Center]]) > build from a template or from scratch, with collaborators if needed > admin monitors > deployment request through the pipeline > production.

### Tools reachable from AES

| Tool | For |
|---|---|
| **Table Builder** | tables, columns, forms; needed to create applications here |
| Catalog Builder | record producers and catalog items |
| Workflow Studio | flows; decision tables |
| Process Automation Designer / Playbooks | cross-functional processes |
| Workspace Builder, UI Builder | workspaces and portals; UI Builder for advanced changes |
| Mobile App Builder | mobile experiences |
| Integration Hub - Import | import and map data into tables |
| Zero Copy Connector for ERP | model and extract ERP data |
| Email notifications; access control and roles | |

## AES or Build Agent

The docs present [[Build Agent]] as where to go when AES is outgrown (custom logic, scripting, global scope, changing base applications). Nothing is exported: AES artifacts (tables, flows, workspaces, ACLs, playbooks) are already visible in ServiceNow Studio, and the agent converts the application to Fluent.

| | AES | Build Agent in ServiceNow Studio |
|---|---|---|
| Interface | guided wizards | conversation |
| Who | citizen and low-code developers | any level |
| Artifacts | tables, forms, flows, workspaces within the wizards | everything: business rules, script includes, client scripts, ACLs, UI pages, packaging |
| Scripts | not directly | written and read by the agent |
| Scope | scoped only | scoped and global |
| Existing applications | those you created | any, base ones included |
| Session memory | none | accumulates in a session; sessions can be resumed |
| External tools at build time | none | MCP connections |
| AI inside the application | separate later step | agents and skills can be built in |

Changes of habit: describe purpose and workflows instead of filling steps; **read and own the review** of generated output (the wizard no longer limits what can be created); iterate in small prompts; use the agent also to plan and document.

## Installing

1. Decide the instance strategy: who may build (everyone, a group, case by case), and on which non-production instance. Install where people develop; install on production too **before cloning** it over development.
2. Entitle on the Store (Now Support account): **ServiceNow Products > App Engine Studio > Opt-in**, then **Manage Entitlement** per instance.
3. On the instance: **System Applications > All Available Applications > All** > the App Engine Studio **product** (not the single application `com.snc.app-engine-studio`, which would lack Table Builder, Mobile App Builder, templates) > **Install**, optionally with demo data.
4. Updates: same list > **Proceed to update**. A family upgrade updates it automatically.

### Guided setup

**All > App Engine > App Engine Studio > Configuration > Guided Setup**:

| Task | Detail |
|---|---|
| Instance credentials | one alias per instance, type *Credential* (not Connection and Credential) |
| Playbooks | activate; plugin Process Automation Designer for App Engine (`com.glide.pad.license`) |
| Spokes | Gmail, Google Sheets, Jira, Microsoft 365 Excel, Microsoft Teams, Slack, Twilio, X, Zoom |
| Flow Designer and Catalog Builder access | review what builders may edit and which catalogs they may add to |
| Instance scan cadence | schedule scans in Health Center ([[Instance Scan]]) |
| App Engine Admins group (on production; also on development if no pipeline) | members and a contact email for request notifications |
| App Engine Studio Users / User Limited groups (on development) | who builds |
| Collaboration descriptors | custom ones must be Global and **Standard** = true to appear in AES |
| Template admin | role `app_template_admin` |

Related guided setups: App Engine Management Center, Application Intake, Pipelines and Deployments, ReleaseOps ([[AEMC Pipelines and Deployments]]).

## Roles and groups

| Who | Role or group | Can |
|---|---|---|
| Citizen developer | group **App Engine Studio Users** (`sn_app_eng_studio.user`; contains `catalog_builder_editor`, `app_template_runner`, `sn_g_app_creator.app_creator`) | create, build, test, submit |
| Limited developer | group **App Engine Studio User Limited** | collaborate on applications shared with them; cannot create applications or see templates |
| AES admin | group **App Engine Studio Admins** (`app_engine_admin`, `sn_app_eng_studio.admin`, `atf_test_designer`, `scan_admin`, collaboration request admin, Table Builder wizard admin) | approve requests, provision users, review and deploy, run tests and scans |
| Template admin | `app_template_admin` (contains `app_template_author`, `app_template_runner`, flow designer and operator roles) | activate, deactivate, share templates |
| Template author | `app_template_author` | create and edit custom templates |
| Security admin | `security_admin` | needed to change roles and ACLs |
| Professional developer | `delegated_developer`, `sn_app_eng_studio.user`, `atf_test_admin`, `scan_admin` | help with complex builders, tests, scan definitions |

Granular admin roles: `sn_app_eng_studio.admin` (AES tables), `sn_collab_request.collaboration_request_admin`, `sn_table_bldr_wzd.table_bldr_wzd_admin` (permissions set at table creation). They cannot manage platform tables such as `sn_udc_experience_visibility_control`.

Delegated development applies per application ([[Delegated Development and Deployment]]); the admin sends the developer the link to AES.

## Installed tables

| Table | Holds |
|---|---|
| Project (`sn_app_eng_studio_project`), Applications in Projects (`sn_app_eng_studio_project_application_m2m`), App Details (`sn_app_eng_studio_app_details`) | development sessions and what was done; filled automatically |
| Taxonomy, Taxonomy Category, Taxonomy Details (`sn_app_eng_studio_taxonomy...`) | application files and their grouping into data / experience / logic and automation / security |
| Resources Content, Resources Content Topic | the help resources shown |
| Environment (`sn_pipeline_environment`), Pipeline (`sn_pipeline_pipeline`), Deployment Request (`sn_deploy_pipeline_deployment_request`) | pipeline setup and requests. The docs say here only one pipeline can be active at a time; the AEMC pages speak of several ([[AEMC Pipelines and Deployments]]) |

## Git source control

Per application, on **non-production** instances only, set up by `admin`: application > **Source control > Link to source control**.

| Field | Notes |
|---|---|
| **Network protocol** | https (Basic Auth credential; use a personal access token as the password) or SSH (SSH private key credential) |
| **URL**, **Branch** | one dedicated repository per application; default branch "main" (`glide.source_control.git_default_branch`) |
| **MID Server Name** | optional, for repositories behind a firewall; use a MID Server separate from Discovery; its user must be able to write "bundle" attachments |
| **Default email** | committer address when the user's record has none (otherwise `username@<instance>.service-now.com`); can be forced for everyone |
| **Credential** | **one set shared by all developers on the instance** |

Then developers can commit all local changes, apply remote changes, create and switch branches, tag, import an application. In the repository, `sn_source_control.properties` holds `path=` (where the application files live, for example `path=src/app`) and `checksum.txt` detects edits made outside: when it differs, files are validated and sanitised (unsupported files removed, entries in the upgrade log; a system file failing XML validation aborts the whole operation).

## Cloning production over development

- Same plugins on all instances; AEMC everywhere if development data is collected.
- Preserve the ATF and instance scan properties on the target (ATF stays off on production).
- Preserved and excluded by default (global scope): collaboration descriptors and their permissions (`sys_appcollab_descriptor`, `sys_appcollab_permission_m2m`), collaboration users and groups (`sys_appcollab_user`, `sys_appcollab_group`); also pipeline environment, pipeline, order, types, deployment requests.
- After the clone: re-add users to the AES groups; a post-clone script resyncs collaboration permissions for applications present on both; for applications restored afterwards use related links **Resync collaboration permissions** and then **Clean up records with empty references** on the `sys_app` record.
- Custom **templates** are scoped applications in `sys_app`: preserve them like any application in development ([[Clone Options and States]]).
- Consider preserving credential aliases and credentials.

## Related

- [[App Engine Studio Building Reference]] · [[App Engine Management Center]] · [[Application Administration and Collaboration Descriptors]] · [[Application Development Tools and Lifecycle]] · [[Build Agent]]
