---
type: reference
tags: [reference, platform, update-sets, integrations, ai, javascript, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Developing your application > ServiceNow Studio (read 2026-10-08 through the docs site): Source control integration, Metadata source control (operations, edit repository configuration, pull, commit, stash, manage stashes, resolve conflicts, tags and branches, default branch, commit history, move application files), Fluent source control (instance requirements, basic authentication, OAuth 2.0 application registry and credentials, MID Server, clone, initialize, Git commands), Building apps in source code (application structure, create an app in source code, convert an application to Fluent, build and install, synchronizing), AI tools and files, App summary generation (exploring, install, enable the App Summary AI agent, summarize, reference), Change your development experience, Viewing app origination information, Debug a script, Metadata record categories, App deployment (update sets: create, mark complete; Application Repository; pipelines), Reference: properties, supported preview file types, collaboration permissions, Custom Application record form. With ServiceNow Studio Overview, Access and Navigation and Metadata File Types and Primary Tables this covers the whole section (4,839 cleaned lines). https://www.servicenow.com/docs/r/application-development/servicenow-studio-classic/source-control-integration.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# ServiceNow Studio Source Control, Fluent Apps and Deployment

**What it is:** the two kinds of Git integration in ServiceNow Studio, how applications are written as source code (ServiceNow Fluent) and kept in step with the instance, the deployment routes, and the Studio properties and application record fields.

From the Brazil docs. The workbench itself: [[ServiceNow Studio Overview, Access and Navigation]].

## Two source control integrations

| | Metadata source control | Fluent source control |
|---|---|---|
| For | ordinary applications (XML metadata) | applications created in source code or converted to Fluent |
| Where | **App details > Source control** menu | **Explorer** and **Changes** tabs, command palette (`Git: ...`) |
| Credentials | a credential record, **one set shared by all developers on the instance** | per **user**: `Git: Set IDE Git credentials` (basic with a personal access token, or OAuth), valid for a whole Git domain if ticked |
| Who | linking by admin; tags and branches also by the app creator role | admins only |
| Operations | import, pull (apply remote changes), commit, stash, switch / create branch, tag, history | checkout, clone, commit, create branch, discard, fetch, pull, push, stage, stash (pop, drop, list, apply, clear), update remote origin |

Both: non-production instances only; one repository per application; a MID Server can reach a repository behind a firewall; production gets applications through the application repository or update sets.

### Metadata source control

Identical in behaviour to App Engine Studio's: link fields, shared credentials, commit options (`glide.sourcecontrol.default_commit_mode`), discard affecting everyone, `sn_source_control.properties` and `checksum.txt`, default branch property. See [[App Engine Studio Overview, Setup and Roles]] and [[App Engine Studio Building Reference]]. Studio-specific: creating a branch switches the application, uncommitted changes included, to it; history is under **Source control > View history** (message, user, SHA-1, date, files).

### Fluent source control

Instance requirements when attachment settings were tightened: `glide.attachment.extensions`, if set, must include `txt,gitdata`; with `glide.security.attachment_type.use_blacklist` on, the blocked extensions and types must not include them or `text/plain`, `application/octet-stream`. Custom extensions: `sn_glider.git.attachment.extension.text` / `.binary`.

**OAuth** (admin): create an OAuth application at the Git provider with callback `https://<instance>.service-now.com/oauth_redirect.do`; then **System OAuth > Application Registry > New > Connect to a third-party OAuth provider**:

| Field | Value |
|---|---|
| **Client ID**, **Client Secret** | `<CLIENT_ID>`, `<CLIENT_SECRET>` from the provider |
| **OAuth API Script** | `OauthAPIScriptForGitHub`, `...ForGitLab`, `...ForBitbucket`, `...ForAzureRepos` (others: write one whose name starts with "Oauth") |
| **Default Grant type** | Authorization code |
| **Authorization URL** / **Token URL** | the provider's endpoints (GitHub: `https://github.com/login/oauth/authorize` and `/access_token`) |
| **Send Credentials** | *As Basic Authorization header* (GitHub, GitLab, Bitbucket); *In Request Body* (Azure Repos) |

Azure Repos first needs the **Client Secret** column of `oauth_entity` lengthened to 2048. Users then pick the OAuth profile in `Git: Set IDE Git credentials` and authorise on first use.

**MID Server**: in scope *ServiceNow IDE*, **MID Server > Applications > New** with a MID Server that has the REST capability and **Application** = ServiceNow IDE; its user needs `sn_glider.ide_git_user` or admin.

**Clone**: Explorer > command palette > `Git: Clone` > URL > **Build and Install**. The repository must hold applications with `now.config.json` and `package.json`; Git server 2.3.2 or later; only the default branch arrives (`Git: Fetch` for others). **Initialize**: Apps tab > application > *Add app to explorer* > `Git: Initialize Repository` > branch name > stage, commit, **Push** > remote URL. One repository per application per instance; one checked-out branch at a time.

Conflicts appear under *Merge conflicts* in the Changes tab (accept current, incoming, both, or edit). File history: Explorer > file > *Timeline*.

## Applications in source code (Fluent)

ServiceNow Fluent is the language (TypeScript-based, `.now.ts` files) in which application metadata is declared. In Studio the **Explorer** tab is one permanent workspace (the standalone IDE has several per user). **Only admins can work on Fluent applications: do not convert one that delegated developers still maintain.**

| Path | Holds |
|---|---|
| `src/fluent` | Fluent code; `generated` = metadata converted to Fluent |
| `src/server` | JavaScript or TypeScript modules (TypeScript is transpiled) |
| `src/client` | UI files |
| `metadata` | metadata still as XML; do not edit by hand |
| `dist` (`app`, `static`), `target` | build output; installable zip |
| `node_modules`, `package.json`, `package-lock.json` | npm dependencies. The path to `package.json` is stored in **Package JSON** on the `sys_app` record |
| `now.config.json` | application configuration; must be at the root |
| `.eslintrc`, `.gitignore`, `.vscode` | tooling |

| Task | How |
|---|---|
| **Create** (admin) | Explorer > *Create an app* > Scoped or Global > name, description, scope (`x_<prefix>_...`, up to 18 characters, unique), npm package name > template: basic boilerplate, AIUX extension starter, JavaScript or TypeScript basic, JavaScript or TypeScript full-stack React. The public npm registry must be reachable from the browser |
| **Convert** | App details > *Convert app to ServiceNow Fluent* > **Convert** adds the structure only. Optionally right-click `metadata` > **Convert Directory to Fluent** (a few types, such as `sys_metadata_link` and `sys_ux_lib_asset`, stay XML) |
| **Build and Install** (status bar) | compiles Fluent to metadata on the instance; modules go to EcmaScript Module (`sys_module`). The open file decides which application. Failures: output and problems panels |
| **Sync Changes** (status bar) | the reverse: metadata changed elsewhere on the instance is downloaded and turned into source. Required before installing when changes are detected. First sync: stage your changes and initialise a repository beforehand. Later syncs take only what changed; `Fluent: Force Sync of Fluent App with all metadata` takes everything |
| `Fluent: Reinstall Fluent App` | uninstall and reinstall from the package; **metadata on the instance not yet synced is lost** |

This two-way sync is what lets code-first and click-first developers share an application. A *Fluent* badge on App details also means: **deploy from the ServiceNow IDE, not from Studio**.

## AI in Studio

- AI file types (need the AI products installed): **Agentic Workflow** (`sn_aia_usecase`), **AI Agent** (`sn_aia_agent`), both edited in AI Agent Studio, and **Skill** (`sn_nowassist_skill_config`). After editing, reload App details.
- **App summary**: App details > **Summarize** > rate, copy, regenerate, or **Use as app description** (helps spot duplicate applications). Needs `sn_app_summary.app_summary_user` plus admin or delegated developer with write on the application record. It now runs as the **App Summary AI Agent**, which is **off after installation** (it costs usage): enable in AI Agent Studio > AI Agents > the agent > *Select channels and status* > **Active**. Times out after two minutes by default. Disable entirely with property `sn_sns.is_app_summarization_disabled` = true (create it). The install page still mentions the older skill pair (app summary and table summary) and the role `now.assist.creator`.

## Deployment

**Publish** in an application creates a deployment request, listed under **Deployment > Deployment requests**; **New** there creates one and attaches update sets.

| Route | Notes |
|---|---|
| Update sets | status bar picker or Deployment tab. Delegated developers: create, switch, publish (seeing the update set list needs `com.snc.dd.manage_update_set_enabled`). Admins: everything, including promote through ReleaseOps. Mark **Complete** only when ready, and never set it back to In progress: make a new one |
| Application repository | App details > **Publish** > **New version**, **Release notes**. Each organisation sees only its own applications |
| Pipelines | built on the CI/CD spoke: publish to the repository, install on targets, run ATF and instance scans; requests handled in App Engine Management Center ([[AEMC Pipelines and Deployments]]). Premium for scoped apps |
| ReleaseOps | update sets through assessment and release playbooks |

## Properties

| Property | Effect |
|---|---|
| `sn_devstudio.servicenow_studio_banner.enable` | banner pointing to ServiceNow Studio from App Engine Studio or legacy Studio (default true). The AES pages name `sn_app_eng_studio.show_servicenow_studio_banner` for the same purpose |
| `sn_udc.smaller_app_files_count_threshold` | below this file count the navigator loads the whole application at once: 2300 for admins, 1150 for delegated developers |
| `glide.ui.open_in_studio_button.enabled` | create and set false to stop right-click **Configure** redirecting to Studio |
| `sn_glider.enable_ide` | false turns off the IDE and, since 29.2.11, **ServiceNow Studio as well** |
| `sn_glider.fluent_convert_enabled` | allow converting applications to Fluent (default true) |
| `sn_glider.default_to_bundled_sdk`, `sn_glider.pinnedSdkVersion` | which SDK version new or converted applications use (default latest) |
| `com.snc.dd.*` | visibility of deployment permissions: [[Delegated Development and Deployment]] |

Preview supports UI pages (`sys_ui_page`) only. Collaboration permission defaults (Owner / Editor) are the same table as for Creator Studio: [[Creator Studio Administration, Building and Reference]].

## Custom Application record (`sys_app`) fields

| Field | Meaning |
|---|---|
| **Name**, **Version** | label (renaming changes nothing derived from it); version compared by the repository and the Store |
| **Scope** | read-only; change only by recreating |
| **Application administration** | protect the application's roles ([[Application Administration and Collaboration Descriptors]]) |
| **JavaScript Mode** | ECMAScript 2021 (ES12), ES5 Standards Mode, or Compatibility Mode |
| **Runtime Access Tracking** | None / Tracking / Enforcing for cross-scope script access ([[Application Access Settings and Cross-Scope Privileges]]) |
| **Restrict Table Choices** | design choices limited to the application's own tables |
| **Licensable**, **Subscription requirement**, **Subscription model** | subscription tracking; the last two only for partners selling on the Store |
| **Menu**, **User role** | application menu and the role that sees it |
| **Guided Setup** | started on install or upgrade |
| Related lists | Application Files, Dependencies, Cross scope privileges, Design Access |

## Related

- [[ServiceNow Studio Overview, Access and Navigation]] · [[Metadata File Types and Primary Tables]] · [[Build Agent Usage, Checkpoints and Reference]] · [[Application Scope and Namespace Identifiers]] · [[ReleaseOps]] · [[Update Sets]] · [[Application Repository, Publishing and Administering Apps]]
