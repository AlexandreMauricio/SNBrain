---
type: concept
tags: [concept, platform, service-catalog, roles, admin, request, task, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Developing your application (chapter page, App Engine products and offerings) > Creator Studio (read 2026-10-08 through the docs site): Creator Studio, Exploring Creator Studio, Example apps, Use App Engine instead of customization, Customization vs. configuration, Creating your first app, Quick start (parts 1 to 6), Get help, Choosing your development experience, Dark mode, Service desks and Creator Studio, Migrating from Service Creator, App compatibility, Apps and tables, Publishing / activation / deployment workflow, Configuring Creator Studio, Installing from the Store, Development instance strategy, Components installed, Configure using Guided Setup (admin group, collaboration descriptors, full and restricted access users, notification emails, playbook activities, app table), Pipelines and Deployments, Roles and personas, Domain separation, Configuring form generation, Install Otto for Creator for form generation. https://www.servicenow.com/docs/r/application-development/creator-studio/creator-studio-landing.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Creator Studio Overview, Setup and Roles

**In one line:** Creator Studio is the no-code builder for **request-fulfilment ("Service Desk") applications**: a form people submit, a playbook that automates approval and tasks, and a workspace list where fulfillers handle the requests.

From the Brazil docs. Building and administering in detail: [[Creator Studio Administration, Building and Reference]]. It replaces Service Creator ([[Service Creator]], retired in Australia). Where it sits among the tools: [[Application Development Tools and Lifecycle]].

## What an application consists of

| Part | Is |
|---|---|
| **Form** | a record producer shown as a catalog item; its questions are the information the fulfiller needs |
| **Automation** | playbooks triggered when the form is submitted or updated (approval, assignment, task, email) |
| **Workspace** | list configurations and record layout in the *Request App Workspace* where fulfillers work |
| **Table** | created automatically, named `<scope>_request` (for example `x_snc_02_03_request`); extends **Request Task** (`sn_creatorstudio_task`), which extends Task (`task`). One row per request |

Vocabulary: *requester* submits, *fulfiller* works on (and possibly approves) the request, *record* is the row created by a submission. Typical uses: equipment or collateral requests, travel or purchase approval, borrowing assets, recognition awards, one-off funding requests.

Lifecycle, in order:

1. Create the application (or ask an admin to).
2. Add a form from a catalog template; customise questions.
3. **Mark as ready** = publish the form (appears in the catalog of the development instance).
4. Add a playbook on the published form; **Activate** it.
5. Adjust the workspace lists and record layout; **Try it** to test.
6. **Submit for review**: choose which forms are *Visible to others* and which playbooks *Run on production*, set version (x.y.z) and release notes.
7. An admin deploys to production ([[AEMC Pipelines and Deployments]]). Playbooks not activated are deployed inactive. Changes are made on the development instance and redeployed.

Compatibility: a Creator Studio application can be opened in ServiceNow Studio, Workflow Studio or Catalog Builder to add more; applications created elsewhere cannot be opened in Creator Studio. Complexity added elsewhere is shown in reduced form with a pointer to the other tool.

## Customise, configure, or build new

The docs' position, used as the argument for App Engine tools:

| Term | Means | Consequence |
|---|---|---|
| **Configuration** | changing behaviour with platform tools and properties **without** altering baseline code or flows (fields, layouts, ACLs, catalog, properties; added code that does not modify baseline) | supported; but any code you add is yours |
| **Customization** | changing baseline code or flows | you maintain it; support will not debug it; each change is a `sys_update_xml` record (Customer Updates) and the record is **skipped at upgrade**, to be reviewed by hand (keep, revert, merge) |
| **Personalization** | a user changing their own view (dark mode, list columns) | no effect on support or upgrades |

Rule: configure first; customise only when it extends the application's own purpose (IT features in ITSM, not a travel workflow inside ITSM); otherwise build a new scoped application. If customising: add before editing, do not copy objects, do not reuse baseline names, keep forms short, export originals first, document the reason, write ATF tests, scan regularly ([[Instance Scan]]), prefer scoped applications. Upgrade handling: [[Upgrades - Process, Upgrade Center and Upgrade Console]].

## Installing and instance strategy

- Needs an **App Engine Enterprise** licence; at least Xanadu patch 3. Plugins: Creator Studio (`sn_creatorstudio`) and Creator Studio - Global (`com.glide.creator_studio.global`). Preinstalled on PDIs.
- Install on **every** instance involved, production included (Request Task must exist there).
- Build on a non-production instance configured like production, then deploy. During development the application is a `sys_app` record; once deployed it is a `sys_store_app` record on production.
- Development and production must have the **same Service Catalog and categories**, or forms will not show correctly.
- Decide who may build: everyone, a group, or by request with approval.
- Virtual Agent previews of forms need the Virtual Agent plugins.
- Domain separation: not supported.

### Guided setup (admin)

**All > App Engine > Guided Setup - Shared**:

| Task | Does |
|---|---|
| Admin group | members of *App Engine Admins* approve creation and collaboration requests |
| Collaboration descriptors | what Owner and Editor may do ([[Application Administration and Collaboration Descriptors]]) |
| Full access users | group **Creator Studio Users**: create applications freely |
| Restricted access users | group **Creator Studio Restricted Users**: must ask an admin to create one |
| Notification emails | edit the request notifications (for example *Request opened*): when, who, what; may need scope *Creator Studio Configurations* |
| Playbook activities | order, add or hide activities offered in the activity picker (the activity must exist already); users refresh the browser |
| App table | change the table an application stores requests in |

AI form generation: install Otto for Creator, check **AI Admin Hub > Features > Creator** > *Service Catalog* card that catalog item generation is active (and the app generation skill), give users `now.assist.creator` ([[Otto for Creator and Otto for App Engine]]).

## Roles and groups

| Role | Allows |
|---|---|
| `sn_creatorstudio.user` | create applications; becomes owner with delegated development on each (gets `delegated_developer`). Contains `catalog_builder_editor`, `sn_g_app_creator.app_creator`, `app_template_runner`, collaboration request read/write, `sn_udc.basic_read`, `sn_creatorstudio.basic_read` |
| `sn_creatorstudio.restricted_user` | no creation; may request an application and work on those assigned (delegated development per application). Contains `sn_creatorstudio.app_requestor` and the same supporting roles except the app creator role |
| `app_engine_admin` (in the App Engine Admins group) | approves creation and collaboration requests, deploys; contains Creator Studio admin write |
| `sn_creatorstudio.admin`, `sn_creatorstudio.admin_write` | admin write access to Creator Studio |
| `sn_creatorstudio.configuration_admin` | granular admin containing the next three |
| `sn_creatorstudio.task_admin` | create / write / delete on `sn_creatorstudio_task`; may change **Request type** (`request_type`, the form a record belongs to) and the `parent` of subtasks |
| `sn_creatorstudio.app_configurator` | change an application's table |
| `sn_creatorstudio.reports_viewer` | run reports on the tables |
| `sn_creatorstudio.basic_fulfiller` | Request App Workspace and some fields of the request table |
| `now.assist.creator` | AI form generation |

- A builder cannot test as a fulfiller on the development instance's Request App Workspace: fulfilling needs the application's own agent role (for example `x_<vendor>_<app>.agent`), which only an admin can give. Use the previews in Creator Studio.
- **Experience switcher** (Creator Studio / ServiceNow Studio / ServiceNow IDE): shown only to someone with access to at least one other environment. Anyone holding a Creator Studio role is kept out of ServiceNow Studio and the IDE whatever else they hold; admins and delegated developers see all. Applications made in Creator Studio are available in ServiceNow Studio, not the reverse.
- If production runs a release without Creator Studio's collaboration support, collaboration requests fail (production is the controller): give the user groups `catalog_builder_editor`.

## Installed tables and properties

| Table | Holds |
|---|---|
| Request Task (`sn_creatorstudio_task`) | default parent of every application's request table; extends `task` |
| Request Subtask (`sn_creatorstudio_child_task`) | tasks created by a playbook's *Create task* activity; extends `task` |
| New Application Task (`sn_creatorstudio_new_application_task`), New Application Admin Task (`sn_creatorstudio_new_application_admin_task`) | the request to have an application created, and the admin's task; extend `task` |
| Request App Config (`sn_creatorstudio_request_app_config`) | one record per application, naming its table; extends Application File |
| Creator Studio Activities (`sn_creatorstudio_activity`) | standard and custom playbook activities offered |

| Property | Effect |
|---|---|
| `com.glide.creator_studio.template_deny_list` | sys_ids of App Engine Studio templates hidden at application creation (default hides one) |
| `sn_creatorstudio.history_record_limit` | how much "recently accessed" history the home page reads (default 1000; -1 = no limit; lower it if the page is slow) |

## Related

- [[Creator Studio Administration, Building and Reference]] · [[Service Creator]] · [[Delegated Development and Deployment]] · [[App Engine Management Center]] · [[Personal Developer Instances]]
