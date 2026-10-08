---
type: concept
tags: [concept, platform, roles, access-control, admin, update-sets, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Developing your application > ServiceNow Studio (read 2026-10-08 through the docs site): ServiceNow Studio, Exploring ServiceNow Studio, ServiceNow Studio and Build Agent tutorial, Access ServiceNow Studio, Quick start (for IDE developers, Build Agent, personalizing the homepage, search, Navigator panel, collections, bookmarks, scopes, app info, navigate to a table, focus the Navigator, create an update set), User interface, ServiceNow Studio for AES developers, Builders, Integrated development tools, ServiceNow Studio and legacy products, Configuring, Domain separation, Installing (instance strategy, components installed), Managing access (roles and access in app development tools, personas and roles, elevate your role), Managing access to the experience switcher, Collaborating on apps (view, add, modify, remove), Settings, Link an app to source control, Import an app from source control, Using ServiceNow Studio, Build Agent in ServiceNow Studio, Applications (create an application, create an app file, App details page, modify settings, bookmarks, preview, code search, delete). NOT re-read: Use App Engine instead of customizations and Customization vs configuration with ServiceNow Studio, the same text already captured from the Creator Studio section. https://www.servicenow.com/docs/r/application-development/servicenow-studio-classic/servicenow-studio-landing.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# ServiceNow Studio Overview, Access and Navigation

**In one line:** ServiceNow Studio is the platform developer's single workbench: find and edit any application or metadata record in any scope you may edit (global included), open each in its builder, track changes in update sets, and deploy, with Build Agent on the home page.

From the Brazil docs. Source control, source code (Fluent), deployment and reference lists: [[ServiceNow Studio Source Control, Fluent Apps and Deployment]]. It replaces the legacy Studio and Guided Application Creator (both deprecated since November 2024, still supported for now); their applications open unchanged. Open at **All > App Engine > ServiceNow Studio**.

## Facts

- Present on every instance (plugin `sn_sns`; depends on `sn_udc`, `sn_studio_commons`, `sn_app_obj_wizards`, `sn_deploy_pipeline`); nothing to configure. No domain separation support.
- With an **App Engine Enterprise** licence it also offers: table from spreadsheet, UI and workspace templates, App Engine Studio catalog templates, Workspace Builder, and deployment of scoped and global applications through the App Engine pipeline.
- The legacy flag **Can Edit Application in Studio** on an application record does not apply here.
- Install on production too before cloning it over development.
- Since version 29.2.11 the ServiceNow IDE lives inside it (the **Explorer** tab).

## Who gets in

| Role | Can |
|---|---|
| `admin` | everything: create applications, Fluent applications in source code, global (unscoped) records, update sets, delegate |
| `delegated_developer` | applications created by them, shared with them, or in scopes they may edit; create files, update sets, submit for deployment. Cannot create applications |
| `sn_g_app_creator.app_creator` (Guided Application Creator role), `sn_g_app_creator.global` | create applications (the Global one also global applications); becomes delegated developer of what they create |
| `sn_udc.admin` | granular admin: Studio properties and settings, experience switcher roles |
| `sn_prfrd_tables.admin` | configure preferred tables for Table Builder |
| metadata-specific admin roles (for example business rule admin, script include admin) | that record type only |

There are no Studio-specific user roles. To touch roles and ACLs: user profile icon > **Elevate role** > `security_admin`.

### Which tool a role opens

| Experience | Available for | Never for |
|---|---|---|
| ServiceNow IDE | `admin` | Creator Studio roles |
| ServiceNow Studio | `delegated_developer`, `admin`, `sn_g_app_creator.app_creator` | Creator Studio roles |
| Creator Studio | `delegated_developer`, `admin`, `sn_creatorstudio.user`, `sn_creatorstudio.restricted_user` | |

A Creator Studio role locks its holder out of the other two whatever else they hold. Defaults live in `sn_udc_experience_configuration`; exceptions are added in `sn_udc_experience_visibility_control` ([[Creator Studio Administration, Building and Reference]]). **Since version 30.1.1 the experience switcher is no longer in ServiceNow Studio.**

## Screen

| Activity bar item | For |
|---|---|
| **Home** | Build Agent chat panel, recent apps and files |
| **Explorer** | applications in source code (Fluent) |
| **Conversations**, **Plans** | Build Agent conversations and the plans it made |
| **Search** | any file, app, table or tool in any scope (Ctrl + / or Cmd + /); toggle **Activate code search** |
| **Create** | app or file |
| **Apps** | filter All / Custom (default) / Store / Creator Studio / Fluent |
| **File Categories** | all metadata by category and type |
| **Collections** | your folders of apps, files and lists; *Bookmarks* is one of them (Studio-only, unrelated to platform favorites) |
| **Recent**, **Deployment**, **Changes** | recent files; deployment requests, update sets, applications; source control changes |
| **User profile** | elevate role, command palette (Ctrl/Cmd-Shift-P), keyboard shortcuts, preferences |

- Preferences: Build Agent on or off (off = the older Otto app generation), light or dark, and activity bar mode **Vibe** (Apps and Changes only), **Pro** (all) or custom.
- Each file opens in its own tab showing name, type, scope. **Scope follows the active tab automatically**; the status bar shows scope and update set, where you can switch or create one (**New** > name > **Save** > **Apply**) and **View update set**. Some builders (Table Builder) take over scope control and say so.
- Right-click a tab > **Show in Navigator** points the Navigator at that file's application.
- New users see no Search or Create > App/File until they have created a first scoped application and refreshed.

### Search shortcuts

| Type in Search | Opens |
|---|---|
| `<table>.list` | list |
| `<table>.do` or `<table>.form` | new form |
| `<table>.config` | configuration page |
| `<table>.filter` | empty list ready for a filter (large tables) |

Lower case opens in the content pane, UPPER case in a new tab. The table name of each metadata type is shown under it in the Navigator.

**Code search**: a snippet across all applications or one, optionally limited to a table; results grouped by script type with line numbers. Handy for finding where an error message comes from.

## Applications and files

- **Create > App**: *On your own* (name, description, logo, **Scope**: scoped or global; roles, admin and user offered, at least one), *With ServiceNow Otto* (opens Build Agent), or *With Creator Studio*. An **App Gallery** of finished examples is reference only: there are no templates here.
- **Create > File**: pick the **Application** (or Global), then the file type by category, search or recents; the form depends on the type. Refresh the Navigator to see it.
- **App details** page: header with metadata and badges (*Creator Studio*, *AI*, *Fluent*) saying where the application came from, **+ Create**, files by category (Data, User Interface, Automation, Security featured), and a menu: link to source control, **Invite**, **Settings** (the application record), publish, refresh, **Delete** (type Delete; permanent).
- **Preview**: files that have a UI open in preview; they can be changed by talking to Build Agent.
- Files open in their builder: most in a Studio tab, Mobile App Builder in a browser tab. Builders cannot be opened on their own.

### Builders reachable

| Area | Tools |
|---|---|
| AI | AI Agent Studio, AI Skill Kit, Build Agent |
| Automation | decision tables, flows / subflows / actions, playbooks (Workflow Studio) |
| Data | Table Builder, Form Builder |
| Integration | Integration Hub Imports |
| Mobile | Mobile App Builder |
| UI | Catalog Builder, Service Catalog, Service Portal, Survey Designer, UI Builder, Workspace Builder |
| Other | Script Debugger (role `script_debugger`) |

## Coming from App Engine Studio

Same: creating applications, Git integration, collaboration. Different: applications are found under **Apps** filtered to Custom; files of many more types, creatable from the home page; scope switches by itself; no templates ([[App Engine Studio Overview, Setup and Roles]]).

## Collaboration

Needs the collaboration application and, for full use, App Engine Enterprise; without it existing delegated permissions are honoured but cannot be managed here. **App details > more options > Invite** opens *Collaborate with others*: list, invite a user or group with a descriptor (an Editor can only grant Editor), change, **Customize permissions**, **Remove**. Someone new to the platform needs admin approval; otherwise auto-approved. Rules and permissions: [[Application Administration and Collaboration Descriptors]], [[Delegated Development and Deployment]].

## Build Agent here

Opens with each session (or the Otto icon / *Open Build Agent* in the status bar). Create or update apps and files, summarise an app, review the change log, roll back to a checkpoint or the whole conversation; deploy as any other application. Detail: [[Build Agent]].

## Related

- [[ServiceNow Studio Source Control, Fluent Apps and Deployment]] · [[Build Agent]] · [[Application Development Tools and Lifecycle]] · [[Application Scope and Namespace Identifiers]]
