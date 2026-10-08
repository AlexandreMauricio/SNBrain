---
type: reference
tags: [reference, platform, schema, service-catalog, workspace, portal, import-sets, flows, roles, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Developing your application > App Engine Studio > Build (read 2026-10-08 through the docs site): Building apps in App Engine Studio, Plan your app development, Enhance your app, Resources for enhancing your app, Create a data model (create a blank table, use a spreadsheet: import, new table, table from an extensible table, modify a table; use a PDF; create a data integration; modify data tables), Add an application experience (record producers vs. catalog items, add a record producer, add a standard catalog item, add a workspace, add a portal and its default pages, add a mobile experience, samples, editing / previewing / deleting an experience), Add logic and automation (pre-built flow, flow from scratch, modify a flow, add / edit a decision, add / modify an email notification, edit a process), Add application security (build a new role, use an existing role, change access, delete a role), Collaborate with other developers (add, change permissions, permission list, remove), Use AES with a Git source control repository (operations, import, pull, commit, tags and branches, default branch, stash, resolve conflicts, commit history, move application files), Publish your app (submit for approval, publish when linked to source control), Remove an app, Using the App Engine Management Center, Reference (glossary, properties, supported features and metadata in custom templates: the lists of about 290 supported and 45 skipped record types are condensed to families). With App Engine Studio Overview, Setup and Roles, App Engine Studio Templates and the how-to this covers the whole section (9,659 cleaned lines). https://www.servicenow.com/docs/r/application-development/app-engine-studio/aes-app-creation.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# App Engine Studio Building Reference

**What it is:** what can be added to an App Engine Studio application under each of its four headings, the options each wizard asks for, and which builder finishes the job.

From the Brazil docs. Setup and roles: [[App Engine Studio Overview, Setup and Roles]]; templates: [[App Engine Studio Templates]]; worked example: [[Build an App in App Engine Studio]]. Roles for everything here: admin, `sn_app_eng_studio.user`, or delegated developer with the matching permission. URL: `<instance>.service-now.com/now/appenginestudio`. The current application scope follows whichever application is open.

## Before building

| Good fit for the platform | Poor fit |
|---|---|
| simple forms, task and request management, spreadsheet-driven or repeatable processes, integrations, orchestration across systems, same data on web and mobile | unstructured data, unrepeatable processes, graphics processing, streaming audio or video, highly customised UI |

Decisions that cannot be undone:

- **Scope name** (`x_<company code>_<app_name>`): fixed at creation; the display name can change. Everything created inherits it ([[Application Scope and Namespace Identifiers]]).
- **Table and column names**: edit only at creation.
- **Instance**: prototypes on a PDI (rebuild later, do not import); real applications on the development instance.
- Scoped, not global, for citizen developers.

## Data

**Data > Add** offers:

| Option | Notes |
|---|---|
| **Create a blank table** | *Create new table* or *Create from an extensible table* (tables of the application first, then recommended platform tables). Then **Table label**, **Table name**, **Make extensible**, **Auto number** (**Prefix**, **Starting number**, **Number of digits**), and per role the create / read / write / delete permissions (at least one role needs read to preview). Columns inherited from the parent show a lock and cannot be changed |
| **Import a spreadsheet** | .xlsx with a header row; pick the worksheet and the header row number; *Import spreadsheet data* or headers only. Then: a new table, a new table extending another, or an existing table |
| **Create a data integration** | Integration Hub - Import: a repeatable, schedulable import into existing tables |
| PDF | the PDF extractor is **deprecated in Brazil** (hidden); creating tables from a PDF is now a Build Agent capability |

Commonly extended tables named by the docs: `task`, `planned_task`, `incident`, `sysapproval`, `cmdb_ci`, `cmdb_ci_service`, `cmdb_model`, `alm_asset`, `sn_customerservice_case`, `sm_order`, `sm_task`, `sys_user`, `sys_user_group`, `core_company`, `cmn_location`, `cmn_department`, `cmn_cost_center`, `cmn_schedule`, `life_cycle_stage`, `life_cycle_stage_status` ([[Table Extension and Extension Models]]).

Column properties in Table Builder: **Column label**, **Column name**, **Type**, **Reference** (for reference types), **Max length**, **Default value**, **Mandatory**, **Display** (the one column shown when another table references this one; only one per table).

### Mapping imported data

Used by spreadsheet imports into existing or extended tables and by data integrations.

| Control | Effect |
|---|---|
| **Automap** | maps source columns to similarly named target fields (80 % name similarity by default: `glide.ih.automap.minimum.score`; one source per target: `glide.ih.automap.extractone`). Leaves already mapped fields alone |
| Drag pills / pill picker | manual mapping; several values or literal text allowed |
| **Match** toggle on a target field | on = a row with the same value **updates** the existing record; off = always inserts (duplicates possible) |
| Gear on choice and reference fields | which column of the referenced table to match, and if nothing matches: create the choice or record, ignore the field, or skip the row |
| **fx** | transform functions applied in order (a subset of the flow ones: [[Flow Data Types and Transform Functions]]) |
| **Add fields** | create target columns from unmapped source columns |

Data integration specifics: source is a file (Excel, CSV, zip) or a spoke's **data stream** action with a connection alias; one or more target tables, processed in card order (not the same table twice, nor a parent and its child); per target **Run table's business rules when importing** and **Run the import synchronously** (prevents duplicate inserts for the same coalesce value when rows are processed in parallel); then **Run Import** or **Schedule an import**. Import sets and transform maps are the classic equivalent (no note yet).

Editing later: the table's *Edit* opens Table Builder (data, fields, forms, and with the right licence a schema view and table-triggered flows). Form views appear under Experience.

## Experiences

| Experience | Is | Finished in |
|---|---|---|
| **Record producer** | catalog form that inserts a record in a table of your choice; no request | Catalog Builder: details, **Destination** (record submission table), location (catalogs, categories, topics), questions, settings, access |
| **Standard catalog item** | catalog form producing a request with requested item, flow, tasks, approvals; cart | Catalog Builder: as above plus **Request method** (*Order*, *Request*, *Submit*; the last two hide the cart, Submit also hides delivery time), hide quantity, and **Fulfillment** flow |
| **Workspace** | agent-style UI for a primary table and secondary tables (tables need a default view); a record page is generated | Workspace Builder (home page, lists, record pages, analytics); UI Builder for anything beyond. Name, URL, at least one role |
| **Portal** | self-service site on the Next Experience framework (not Service Portal) | UI Builder. Default pages: landing, login, search, catalog item, article, order success, record (request), record (task), task approved, task rejected, settings |
| **Mobile** | screens in *Now Mobile* or *Mobile Agent* (offline only in Mobile Agent): a **List** of a table, with optional conditions, or a **Webpage** | Mobile App Builder; a QR code opens the result |

Default workspace and portal pages are read-only: create a **page variant** to change one.

### Record producer or catalog item

| | Record producer | Catalog item |
|---|---|---|
| Use for | a custom process on your own tables, built with App Engine automation | simple requests that fit the existing request fulfilment process |
| Data | your own model: easy reporting | variables: reporting needs database views or scripts |
| Ownership | the application's team, delegated | usually a catalog team |
| Example | password reset | parking permit |

Question sets (variable sets) inside either cannot be edited there; those coming from the template cannot be removed. Preview works for portal and Now Mobile without submitting. Background: [[Request Management Data Model and Process]].

## Logic and automation

| Item | Wizard asks | Finished in |
|---|---|---|
| **Flow** | a pre-built flow template, or *Build from scratch*: **Name**, **Description**, **Protection** (none or read-only), **Run as** (system user, or *User who initiates session* with **Run with roles**) | Workflow Studio: trigger, actions, flow logic, subflows, error handler; test; **Activate** (only active flows are triggered). Record-triggered flows open in Table Builder's Flows tab when that licence is present ([[Building Flows - Properties, Triggers, Stages and Error Handling]]) |
| **Decision** | **Name**, **Accessible From** (all scopes, or this scope only) | Workflow Studio decision tables ([[Decision Tables]]) |
| **Email** notification | name; **Send email notification**: record created or updated / only created / only updated / *When triggered via Flow Action* / *When event is fired*; **Table** or **Event name**; conditions (not for flow-action triggers); recipients from table fields (dot-walk allowed, for example Opened by > Manager) and fixed people or groups; **Email template** with optional **Override template**, subject, message, variables | preview against a record. Saved in the application only. When one trigger produces several notifications to the same person only one is sent (business rule *Ignore Duplicates*). Email only, no SMS. Changing template discards overrides |
| **Process** | must first exist in Playbooks | Playbooks ([[Playbooks Overview and Components]]) |

With Git linked, a new flow is visible to other developers only after it is committed.

## Security

**Security > Add**: *Build a new role* (name in lower case with underscores; needs admin elevated to `security_admin`, or the Manage ACLs and Roles permission) or *Use an existing role* (only once the application has data or experiences). Per role: for each table tick **Create**, **Read**, **Write**, **Delete**; on the *Experience* tab tick the experiences it may open. An admin assigns the roles to people after deployment.

## Collaboration

**Manage collaborators** on the application home. What a person can do there:

| Holder of | Can |
|---|---|
| *Manage collaborators* permission | see, search, invite, change descriptor, remove (not customised entries) |
| *Invite collaborators* | see, search, invite (as Editor) |
| neither | read-only list |
| admin (elevated to `security_admin`) | everything, including **Customize Permissions** per user and removing the last owner |

An invitation creates a collaboration task and runs the *Collaboration Request* flow. The docs state the rule two ways: the overview says a request is auto-approved when the invitee has AES or delegated developer permissions and is not new to the platform, and needs approval when they have neither and are new; the procedure says approval is needed when they have the permissions but are new. The task lands on the controller instance when one is configured ([[AEMC Pipelines and Deployments]]). Permission list and defaults: [[Delegated Development and Deployment]], [[Creator Studio Administration, Building and Reference]].

## Git operations

Linking and configuration: [[App Engine Studio Overview, Setup and Roles]]. Menu **Source control** on the application (admin unless noted):

| Operation | Notes |
|---|---|
| **Import app** (home page) | same fields as linking; validates and sanitises when the checksum differs; check the upgrade log afterwards |
| **Pull from repository** | first stash or discard uncommitted local changes; then fetch, apply, and resolve conflicts. Delta loading is on by default so data is not removed |
| **Commit changes** | pick file changes (from all update sets; current one shown first) and a comment. Checkbox *Include changes not tracked via the Customer Update table*: default from `glide.sourcecontrol.default_commit_mode` (`exclude_untracked` shipped, or `include_untracked`); hide the checkbox with `sn_devstudio.vcs.allow_commit_mode_selection` = false. Untracked changes are always included on first link and on publish |
| **Create tag**, **Create branch** (optionally from a tag) | admin or the app creator role (the page writes `sn_group_creator.app_creator`; the role listed elsewhere is `sn_g_app_creator.app_creator`: check) |
| **Switch branch** | save or discard local changes first. Discard removes all local changes on the instance, whoever made them: credentials and the working copy are shared |
| **Stash local changes**, **Manage stashes** | apply (with conflict check) or delete |
| Resolve conflicts | take stashed / discard stashed for all, or *Manually Apply* and choose field by field, **Save Merge** |
| History | **All > Source Control > View History**: committer, date, SHA-1, message, files |

Properties: default branch `glide.source_control.default_branch_name` (otherwise `sn_instances/<instance_name>`; the linking page instead names `glide.source_control.git_default_branch` with default "main": two pages, two names); `glide.source_control.checksum_required`, `glide.source_control.checksum_quick_install`. Application files can be moved to a subfolder by editing `path=` in `sn_source_control.properties`, which lets tests live in the same repository.

## Submitting and publishing

- **Submit** on the application home (needs *Submit for deployment*, *Publish to app repo* or *Publish to app store*): status on the home page goes **Pending Approval** > **In Validation** > **Published** or **Rejected** (with the reviewer's comments by email; fix and resubmit). The admin may hand out test accounts per role, and assigns roles to the requesting team after publishing.
- **Publish** when linked to Git (admin): version, release notes, target (own repository or Store). Everything, untracked changes included, is committed first and a **tag** is created for the version. Publishing from the `sys_app` record instead creates no commit and no tag.
- Delete: *Edit application properties* > **Delete application** (permission needed).

## Properties

**App Engine Studio > Configuration > Properties**:

| Property | Effect |
|---|---|
| `sn_app_eng_studio.show_servicenow_studio_banner` | show the "try ServiceNow Studio" banner (default true) |
| `sn_app_eng_studio.aes_admin_contact` | email addresses that receive deployment request notifications |
| `sn_app_eng_studio.illustration_supported_content_types` | read-only; `image/svg+xml` |
| `sn_app_intake.instance_can_provision_users` | whether this instance provisions users to another (default false) |

## What a custom template can contain

Scanned when a template is made from an application ([[App Engine Studio Templates]]). The page says an application **containing a workspace cannot be made into a template**, although workspace record types appear in its supported list.

| Outcome | Record families (table name prefixes) |
|---|---|
| **Supported** (about 290 record types) | data model (`sys_db_object`, `sys_dictionary`, overrides, choices, `sys_number`, `sys_index`, `sys_m2m`, `sys_relationship`); security (`sys_user_role`, contained roles, `sys_security_acl`, cross-scope privileges, data policies); UI (forms, sections, lists, views, related lists, UI actions, policies, scripts, pages, formatters, styles, modules and menus); scripts (`sys_script`, `sys_script_client`, `sys_script_include`, scheduled scripts, script actions, events, extension points, properties); catalog (`sc_cat_item`, `sc_cat_item_producer`, variables, variable sets, catalog UI policies and client scripts, fulfilment steps); flows and actions (`sys_hub_*`), decision tables (`sys_decision*`), playbooks and process definitions (`sys_pd_*`, `sys_playbook_*`); notifications and email (`sysevent_email_action`, templates, layouts, email scripts, inbound actions, filters, push); integration (`sys_rest_message*`, scripted REST `sys_ws_*`, import/export maps, export sets, basic auth profile); reporting (`sys_report`, colours); SLA (`contract_sla`, timer configuration); search configuration; mobile (`sys_sg_*`); Next Experience and workspace configuration (`sys_ux_*`, `sys_aw_*`, `sys_uib_*`) |
| **Skipped** silently (about 45) | legacy workflow (`wf_*`), CMS (`content_*`, `menu_*`), database views (`sys_db_view*`), processors, the template machinery itself (`sys_app_template*`, scan payloads) |
| **Denied** | anything with a deny rule; tables extending `sys_metadata`; application administration on |

## Related

- [[App Engine Studio Overview, Setup and Roles]] · [[App Engine Studio Templates]] · [[Build an App in App Engine Studio]] · [[Tables, Records and Table Relationships]] · [[Decision Tables]]
