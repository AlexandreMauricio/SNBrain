---
type: reference
tags: [reference, platform, service-catalog, flows, workspace, notifications, admin, roles, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Developing your application > Creator Studio (read 2026-10-08 through the docs site; with Creator Studio Overview, Setup and Roles this covers the whole section, 5,279 cleaned lines): Administering Creator Studio (approve app creation requests, experience switcher and role access, collaboration: approve requests, manage and customize permissions; catalog templates, question sets, AES template; an app's table: about and change; notification emails; custom activities: workflow, create, reorder, deactivate; disable the App type page; deployments and usage; access to deployed apps; metadata artifacts), Creator Studio tutorial (parts 1 to 9), Building apps (find apps, bookmarks, change experience, create / request / settings / delete, collaborate, forms: add, customize, AI generation, dynamic behavior, states, settings, publish, published forms, delete, hide; automation: workflow, add / copy playbook, activities, decision, parallel process, trigger, edit, activate, delete; workspace lists and records, filtered list, record layout, Request App Workspace; testing and previewing; deploying, versions, request deployment; what happens after; closing requests and notifications), Reference (form settings, question types, form layout options, glossary). https://www.servicenow.com/docs/r/application-development/creator-studio/administering-creator-studio.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Creator Studio Administration, Building and Reference

**What it is:** the working detail of Creator Studio: what admins maintain, what a builder can put in forms and playbooks, what each application gets created with, and the option lists.

From the Brazil docs. Concepts, installation, roles: [[Creator Studio Overview, Setup and Roles]]. Step by step: [[Build a Request App in Creator Studio]]. Open at **All > App Engine > Creator Studio**.

## What each new application creates

| Artifact | Detail |
|---|---|
| Table | `<scope>_request`, label "<App name> Requests", extends Request Task (`sn_creatorstudio_task`). Form answers are stored as **catalog variables** on the record |
| Role | `<scope>.agent`: the fulfiller role |
| ACLs | create / read / update / delete on the table for fulfiller and requester |
| Workspace category | "<App name> Requests" in the Request App Workspace, with lists **Open** (`active=true`), **Open - Unassigned** (`active=true^assigned_toISEMPTY`), **Closed** (`active=false`), **All** |
| Dashboard | scores for open, unassigned, closed in the last 30 days; a list of open requests |
| Config record | one row in Request App Config (`sn_creatorstudio_request_app_config`) |

## Admin tasks

| Task | Where and how |
|---|---|
| Approve a restricted user's request for an application | **App Engine > Request App Administration > Application Tasks** > open > **Approve** / **Reject** (or in App Engine Management Center). Role `app_engine_admin`. The requester becomes owner |
| Approve a collaboration request | on the **controller** instance (usually production): **App Engine > Collaboration > Collaboration Tasks** > **State**: Closed - Approved / Closed - Rejected / Canceled / Closed - Failed. People already holding `delegated_developer` are approved automatically; the invitee must sign out and in again |
| Edit descriptors | **App Engine > Collaboration > Descriptors** ([[Application Administration and Collaboration Descriptors]]) |
| Catalog templates for forms | a **record producer** template in Service Catalog with the destination table left **empty**, readable by the Creator Studio Users group. Can also limit which catalogs builders may pick |
| Question sets | Service Catalog **variable sets**: reusable, not editable by builders |
| Show the App Engine Studio template | clear property `com.glide.creator_studio.template_deny_list` |
| Skip the "App type" page | create property `apptype.selection.disabled` (true/false) = true, in Global scope |
| Experience switcher access | defaults in Experience Configurations (`sn_udc_experience_configuration`); add rows in Experience Visibility Controls (`sn_udc_experience_visibility_control`): experience, **Available for roles**, **Not available for roles**. Every product must be on Yokohama or later |
| Notification emails | guided setup, or the notification records directly. Shipped: *Request opened*, *Request assigned to me*, *Request assigned to my group*, *Request closed* |
| Give access after deployment | on production: assign `<scope>.agent` to fulfillers. Forms are open to everyone unless the builder set *Available for* / *Not available for* (user criteria) |
| Deploy | not from Creator Studio: App Engine Management Center, or Pipelines and Deployments ([[AEMC Pipelines and Deployments]]) |

### Changing an application's table

Reasons: reuse a table that already has logic, need changes Request Task does not allow, write into a larger existing application. Roles: admin, `sn_creatorstudio.app_configurator` or `sn_creatorstudio.configuration_admin`. Do it in guided setup, or open `sn_creatorstudio_request_app_config.list`, find the application (search by the first word of its name), switch to its scope, set **Request table**.

- The table should extend Request Task and must have a `request_type` field (label *Request type*, reference to Record Producer): without it no playbook can be added or triggered.
- A table in another scope must allow updates from other scopes.
- Forms created against the old table show an error; filtered lists created earlier keep pointing at the old table.

### Custom playbook activities

1. Build the flow, subflow or action in Workflow Studio.
2. Create an **activity definition** for it ([[Playbooks Administration, Roles and Access]]); on its *Automation Plan* tab set each input to **Always Show** (visible to builders) or *Show as additional property* (admins only).
3. **App Engine > Request App Administration > Creator Studio Activities > New**: **Activity**, **Order** (lower appears first), **Short description** (shown in the picker), **Active**.

Hide a shipped activity by clearing **Active** (running processes are unaffected). Examples: approval by a department head instead of the requester's manager; a notification to a chat tool.

## Collaboration

| Capability | Owner | Editor |
|---|---|---|
| Invite collaborators | yes | yes |
| Manage collaborators, edit application settings, delete, **submit for deployment** | yes | no |
| Forms, automation, workspace lists | yes | yes |
| Manage ACLs and roles | yes | yes |
| Allow scripting, source control, upgrade, publish to repository or Store | no | no |

All file-type permissions are on for both by default. **Customize permissions** in *Manage collaborators* picks individual ones. Needs an App Engine Enterprise licence.

## Forms

- A form is a catalog item (record producer); one per kind of request; all forms of an application write to the same table.
- States: **Draft** and **Published**. Editing a published form works on a draft copy; **Mark as ready** replaces the published version; **Undo all changes** returns to it. Only published forms can be used in playbook conditions.
- Published forms cannot be deleted, only hidden (form settings > clear **Make form visible to others**, then redeploy). Deleting a question from a published form leaves it inactive in the catalog.
- Build manually or with AI (*Build with AI* tab: write directions, **Generate form preview**; needs `now.assist.creator`).
- **Preview** shows portal, Now Mobile and Virtual Agent renderings without creating a record. **Try it** (published forms only) submits for real: playbooks run and a record is created to inspect.

### Question types

| Type | Notes |
|---|---|
| Single-line text, Multi-line text | |
| Dropdown, Radio button | choices you list, single answer; optional *None*; radio can default to the first |
| Check box | two side by side form a section that accepts no other type |
| Yes/No, Date, Date and time, Duration | |
| Attachment | a question, distinct from the form-level attachment option; can be shown conditionally |
| Question set | admin-made, not editable; must be added as new, an existing question cannot be converted |
| **Record choices** | pick a record of a **Source table** with filter conditions (a reference). Enables **Add auto-fill** on other questions: choose the dependent question and a field of the source table (dot-walk) to prefill |
| **Field choices** | values of one field of a table |
| **Multi-select** | several records of a table |

Per question: label, help text, *Show question on form* (off = hidden but stored), *Mark as required*, *Mark as read-only*, default value (for reference types search with a leading `*`). Layout elements: one- or two-column section (optional label), divider, heading, rich text.

**Dynamic behavior** (*Behaviors* tab; these are catalog UI policies): conditions on other questions' answers, then one or more of: make visible, mark required, make read-only, display a message (info / warning / error), choose a value.

Form settings: name, short description, image, description; hide *Add to wish list*; hide or require attachments; **Location** (catalogs and categories; Employee Center taxonomy topics); **Access** (*Available for*, *Not available for*). The template cannot be changed afterwards.

## Playbooks

Created per **published** form with **+ Add automation**.

| Setting | Options |
|---|---|
| Trigger (fixed after creation) | Form submitted · Form updated · Form submitted or updated |
| Run (for update triggers; fixed) | Once · For each unique change · Only if not currently running · For every update |
| Conditions (editable later) | on table fields, or on form answers by choosing *Questions* as the field |

| Activity | Settings |
|---|---|
| **Request approval** | approver: Group, Specific person, or Requester's manager; **Anyone approves** or **All approve** (for a group: every member) |
| **Assign to** | group or person |
| **Create task** | priority Critical to Planning (creates a Request Subtask) |
| **Send an email** | To / Cc (users, addresses, or *Requester*), subject, rich body |
| **Update submission** | set Short description, Description, State or Priority on the request (for example close it after a rejection) |
| **Placeholder** | no logic yet: swap later, or build in Workflow Studio |

Each activity: label, description, **When to start** (*When playbook starts* or *After specific activity*), optional extra conditions.

- **Decision** (Diagram view only): branches with conditions plus a mandatory ELSE; process *all true branches* or *only the first true*; start rule, optional delay, restart rule.
- **Parallel path**: add from the connector menu or drag a connector; or set several activities to *When playbook starts*.
- **Board view** to reorder; **Diagram view** to see flow and add decisions.
- Not available here: optional activities, several stages, data pills from earlier activities, notifications. Use **Open in Workflow Studio**; a playbook edited there can no longer be edited in Creator Studio.
- Fix all errors, then **Activate**. Copy with **Duplicate**.

## Fulfilment

- One **Request App Workspace** per instance (**All > App Engine > Request App Workspace**); a category per application. Access needs `<scope>.agent` or admin: the owner alone cannot open it.
- On a record: form answers on **Details**, playbook results on **Automations** (the docs also name a **Catalog tasks** tab guiding the fulfiller through activities).
- Builders add filtered lists (name, conditions, columns, **Activate list**), for example one per form; and arrange the record under **Record details** (advanced form changes need Table Builder). More categories: table `sys_ux_list_category`, admin only.
- **Requests are not closed automatically**: the fulfiller closes the record by hand, which sends *Request closed* to the requester.

## Related

- [[Creator Studio Overview, Setup and Roles]] · [[Build a Request App in Creator Studio]] · [[Playbook Activities, Decisions and Variants]] · [[Delegated Development and Deployment]]
