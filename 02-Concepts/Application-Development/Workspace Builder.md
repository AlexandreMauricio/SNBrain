---
type: concept
tags: [concept, platform, workspace, forms-lists, reporting, roles, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Developing your application > Builder library > Workspace Builder (read 2026-10-08 through the docs site; whole section, 924 cleaned lines): Workspace Builder, Exploring Workspace Builder, Accessing Workspace Builder, Sample workspaces you can build, Parts of a workspace, Layout, Configuring, Installing, Using Workspace Builder, Add a workspace, Configure workspace settings, Customize a workspace home page, Add a record page, Create lists for a workspace, Enable analytics, Edit a workspace, Reference - Components for home pages. https://www.servicenow.com/docs/r/application-development/workspace-builder/workspace-builder-landing.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Workspace Builder

**In one line:** a no-code editor, opened from ServiceNow Studio or App Engine Studio, that creates a configurable workspace (home dashboard, list pages, record pages, search, analytics) from a few questions and lets you adjust those parts; anything beyond that is done in UI Builder.

From the Brazil docs. The source-code route to the same thing is the Fluent `Workspace` object: [[Fluent API - Service Catalog, SLA, Service Portal and Workspace]]. How an ITSM workspace built this way is configured in use: [[Service Operations Workspace Configuration and Customization Reference]].

## Facts

- Plugin `com.devsnc_sn_workspace_builder` (scope `sn_ws_builder`), from the Store; a dependency of the App Engine Studio workspace template. Needs an **App Engine Enterprise** licence.
- Roles to build: `admin` or the Guided Application Creator role in ServiceNow Studio; `sn_app_eng_studio.user` or delegated developer in App Engine Studio.
- Open: Studio > search the workspace, or File categories > User Interface > **Workspace**; App Engine Studio > the application > the workspace's menu > **Edit**.
- **A workspace must have a home page and lists to be editable here**; if either was removed, or for a workspace made from an *application* template, use UI Builder. Changes made in UI Builder (custom components, custom side-panel tabs) may not show in Workspace Builder.

| Version limit (as the pages state them) | Consequence |
|---|---|
| workspace created before Tokyo | home page only previewable here; edit in UI Builder |
| built before AES Workspace UI Template 22.0.3 | record pages edited in UI Builder |
| the landing page says "workspaces built starting with Brazil" | (?) conflicts with the two limits above; the pages were written at different times |

## Layout of the builder

Left: navigation (**Home**, **List**, **Analytics**), with a header switch between *Navigation configuration* and *Record pages*. Middle: preview canvas (for the home page, an inline editor). Right: configuration of the selection. **Workspace settings** and **Preview** (new browser tab) in the header.

## Create a workspace

Studio: create > File > User interface > **Workspace** > **Begin**. App Engine Studio: the application > Experience > **Add** > **Workspace** > **Begin**.

| Field | Meaning |
|---|---|
| **Name** | shown to users; defaults to the application name |
| **Description** | |
| **URL** | path of the workspace; defaults from the name |
| **Roles** | at least one; a custom role must exist first |
| **Primary Table**, **Secondary Tables** | the tables worked in; only tables that have a default view. A record page is generated for each |

If the workspace has no access control, the first edit asks for roles (*Add user roles to continue*).

## Settings (Workspace settings)

| Tab | Field | Meaning |
|---|---|---|
| General | **Name**, **URL**, **Description** | |
| General | **User access** | users and groups allowed; empty = unrestricted. Add one role at a time |
| General | **Search configuration** | which search profile the workspace uses; an AI Search profile (if AI Search is on) adds multi-value facets, parent documents with attachments, dark mode |
| General | **Workspace theme** | from UX Themes (`sys_ux_theme`); only when Polaris is not enabled |
| Record navigation | **Navigation type** | tabbed for workspaces made here, **fixed after creation**; breadcrumb navigation requires creating the workspace in UI Builder |
| Record navigation | **Table**, **Label** | which record types the *new record* menu offers, and their labels; each table once |

## Home page

A Platform Analytics dashboard. **It cannot be hidden or removed.** Other pages should be changed through a variant or copy, otherwise upgrades stop updating them.

- **Add new element**: Data visualization (new or from the library), Filter (acts on visualizations sharing the data source), Heading, Image (by URL), List - Simple, Rich text. Anything else: UI Builder.
- Per element: drag, resize, configure (settings icon), **Duplicate**, **Add to library**, **Delete** (no confirmation).
- Dashboard menu: **Add a tab**, **Duplicate**, **Share** (users, groups, roles; can view, edit, share; copy link with or without filters), **Printer friendly**, **Add to bookmarks**, **Delete** (keep at least one). **Open in UI Builder** for more.
- A workspace holding a *technical dashboard* is edited in UI Builder.

## Lists

Navigation > **List**: activate lists if needed (select a list > **Activate list**). Structure: **list category** (**Name**, **Description**) containing **filtered lists** (**Name**, **Table**), each with **Manage columns** (dot-walking allowed) and **Apply conditions** (condition builder, saved filter, sort). A workspace on a non-core table needs its categories created by hand. Removing the list page means the workspace can only be edited in UI Builder.

## Record pages

One per table; the table cannot be changed afterwards. The default pages are read-only: change them through a page variant.

| Part | Where |
|---|---|
| New page | header > Record pages > **+ Create new** > **Name**, **Table** (a custom table needs at least one field of its own) |
| Form | Record details > **Edit form** opens [[Table Builder]]; reload the page afterwards |
| Activity stream | toggle in Form details |
| Related information (tabs) | **+ Add tabs** or **Manage related information**: choose and order related lists; the related table must already exist |
| Playbook | **Add a playbook** > **Tab name**, **Playbook experience** (only playbooks for that table; needs the Playbook Experience plugin; not for template-built applications) |
| Contextual side panel | toggles for Attachment and templates (on by default), Agent assist, and the **Ribbon** with Active SLA, CMDB Timeline, Customer 360 (needs extra settings); saved automatically; not for template-built applications |
| Delete | Settings > **Delete record page** |

## Analytics

Navigation > **Analytics** > **Activate Analytics Center**. The Analytics Overview offers Analytics Q&A (needs Natural Language Query), an indicator scorecard and tiles for the dashboards the user may see. Further changes: **Open in UI Builder**. If the page or route does not exist, the tab simply does not appear.

## Related

- [[UI Builder Overview and Concepts]] · [[Table Builder]] · [[App Engine Studio Building Reference]] · [[ServiceNow Studio Overview, Access and Navigation]] · [[Playbook Experience Design for Workspace, Portal and Mobile]] · [[Builder Tools Overview and Custom UI Components]]
