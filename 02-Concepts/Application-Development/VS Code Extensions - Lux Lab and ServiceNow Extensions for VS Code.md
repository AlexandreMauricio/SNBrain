---
type: reference
tags: [reference, platform, javascript, scripting, update-sets, portal, ai, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Developing your application > Building pro-code applications (read 2026-10-08 through the docs site). ServiceNow Lux Lab for VS Code extension - landing, Exploring, Configuring (install, connect to an instance), Using (create a new experience, create a page, extend an existing experience, create a page in an extension, extend an existing page, override an existing page, preview a page, add a page to the navigation, deploy changes). ServiceNow Extensions for Visual Studio Code - landing, Functions, Install, Activate, Set up a workspace, Create a project, Import an application, Synchronization (current file, current project), Clear instance credentials, Reset a project, Add custom file types, Create a file, Search files, Run background scripts, IntelliSense, Telemetry. https://www.servicenow.com/docs/r/application-development/servicenow-ai-experience-lab-for-vs-code-landing.html and https://www.servicenow.com/docs/r/application-development/vs-code.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# VS Code Extensions - Lux Lab and ServiceNow Extensions for VS Code

**What it is:** two unrelated Visual Studio Code extensions published by ServiceNow, besides the ServiceNow Fluent Language extension used with the SDK: **Lux Lab** scaffolds and deploys UI experiences (pages and widgets), and **ServiceNow Extensions for VS Code** is the older tool that downloads an application's script files, lets you edit them locally and syncs them back.

From the Brazil docs. For source-code (Fluent) applications use the SDK instead: [[ServiceNow IDE and ServiceNow SDK]].

| | Lux Lab | ServiceNow Extensions for VS Code | SDK + Fluent Language extension |
|---|---|---|---|
| Works on | experiences, pages, widgets | script fields of an existing application | the whole application as source |
| Commands prefix | `Lux:` | `Now:` | `now-sdk` in the terminal |
| Instance changes go to | deployed application scope | the selected update set | the installed application |
| Needs | VS Code 1.97, Node.js 24, pnpm 10, SDK 4.12.1, instance on Australia Patch 5 or Zurich Patch 12 or later | VS Code 1.38.0 or later | Node.js 20.18.0, npm 8.19.3 |

## ServiceNow Lux Lab for VS Code

The docs URLs still say "ai-experience-lab", and the deploy panel is titled *AI Experience Lab: Script Runner*: an earlier name of the same extension. Pages are also called AIUX pages. No instance role is stated for any task ("Role required: none"); what the connecting user needs on the instance is not said (?).

| Part | Purpose |
|---|---|
| Home screen | **+ New project**, **Add a new instance** |
| Explorer | the experience's files, including relevant ones from the instance |
| Script Runner panel | **Build**, **Deploy** without the terminal |
| Preview | render a page inside VS Code, on several device sizes |

**Connect**: *Add a new instance* > authentication type (Basic or OAuth, matching the instance) > `https://<instance>.service-now.com` > user name and password (OAuth continues in the browser) > an alias.

| Task | Steps |
|---|---|
| New experience | **+ New project** > instance > local folder > experience name > folder name > **Standalone App** > application scope name. A sample page and widget are scaffolded |
| Extend an existing experience | the same but choose **Extend Existing App** and pick the experience (it must already be deployed on the connected instance). Pages live under `/src/extensions/<scope>/<experience>` |
| Create a page | a folder and file under `/pages` by hand; or command palette > `Lux: Create page` > name > URL route; or ask an AI coding tool in its panel |
| Page in an extension | `Lux: Create Page` > *AIUX: New Page* > display name (**must be unique**: an equal name overrides the existing page) > URL route |
| Extend a page | `Lux: Create Page` > **Extend Existing Page** > pick the page (a circle-slash icon marks pages already extended) |
| Override a page | `Lux: Create Page` > new page whose display name **and** URL route exactly match the page to replace; takes effect after deploying |
| Preview | Explorer > `/pages` > right-click the page's `page.js` > **Lux: Launch Preview**. Some pages can only be checked after deploying |
| Navigation | in `application.js` at the experience root (not under `src/extensions/`), with the nav helper from `@servicenow/aiux/aiux-components-nav`: `addNavItem(item)` for the first-level sidebar, `setL3Nav(path, tabs)` to replace tabs, `appendL3Nav(path, tabs)` to add tabs; an item is `{ icon, title, action: { type: 'navigate', path: '/home' }, l2Nav?, l3Nav? }`. Then **Build** |
| Deploy | Script Runner > **Deploy**; a notification confirms |

## ServiceNow Extensions for VS Code

Edits are local until synchronised; sync is two-way and handles changed, new and deleted files. Credentials are kept in the operating system's credential vault, not in VS Code settings.

Setup order: install from the marketplace (search *ServiceNow Extensions for VS Code*) > `Developer: Reload Window` > `Now: Activate Now Extension` > `Now: Setup Now Workspace` (a new or existing folder) > `Now: Create Now Project` > instance URL > authentication (Basic: user name and password; OAuth: also `<CLIENT_ID>` and `<CLIENT_SECRET>` of an OAuth application) > project type > **Import Existing** > pick the application > confirm the file types.

- The create-project page says the authenticating account **must not contain the admin role**, while setting up the workspace, syncing a file, custom file types and background scripts say "Role required: admin". Unresolved contradiction in the docs.
- An application appears in the list only once its *Manage Developers* settings were applied (delegated development: [[Delegated Development and Deployment]]).
- Project types *Packages* and *Plugins* are enabled under **Preferences > Settings > Extensions > Now > Project Settings**.

| Command (`Now:`) | Does |
|---|---|
| `Setup Now Workspace` | choose the project folder |
| `Activate Now Extension` | first step after installing |
| `Create Now Project` | connect and import an application |
| `Sync Current Project` / `Sync Current File` | two-way sync; files are syntax-checked first (problems tab) |
| `Select Application` | switch application (also in the status bar) |
| `Select Update Set` | choose the update set that receives your synced changes; default update set if you never choose; the choice lasts until the project or VS Code closes |
| `Configure File Types` | which metadata types are synchronised |
| `Add Custom File Types` | add a table of your own (extending Application File) with script or string columns; stored in `app.config.json` under `CustomFileTypes`: table name, `superCoverName` (always `Miscellaneous`), `coverName`, and `tags` mapping each column to `js`, `html`, `css` or `json` |
| `Create New File` | file group > file type > name; created on the instance at the next sync |
| `Global Search` | find and download any script file of the instance into the project's `scratch` folder; more than 10,000 results by raising *Fetch Records Max Limit* in settings |
| `Clear Credentials` | forget the stored credentials (asked again next time) |
| `Reset Project` | discard all local changes and return to the server state; only for a corrupted project or sync trouble |

**Conflicts** (same file changed on both sides) open a *Conflicting Files* list: **Open Diff**, **Overwrite Server**, **Overwrite Local**, **Mark Resolved** (your merged version is sent at the next sync).

**Background scripts**: select script text > right-click > **Run Background Script - Current** or **- Global** (the scope it runs in). It runs on the server of the connected instance, like Scripts - Background; role admin. It changes whatever the script changes.

**IntelliSense**: completion for client and server Glide APIs, standard JavaScript, Jelly tags, plus snippets, including the instance's own syntax editor macros. ESLint with the instance's rules is supported.

**Telemetry**: anonymous usage data is sent by default; turn off with the user setting `now.telemetry.enableTelemetry` = false (or VS Code's global `telemetry.enableTelemetry`).

## Related

- [[ServiceNow IDE and ServiceNow SDK]] · [[Source-Code Development - Fluent, JavaScript Modules and React]] · [[Application Development Tools and Lifecycle]]
