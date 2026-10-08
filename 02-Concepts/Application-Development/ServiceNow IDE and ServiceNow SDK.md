---
type: concept
tags: [concept, platform, javascript, scripting, integrations, roles, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Developing your application > Building pro-code applications (read 2026-10-08 through the docs site). ServiceNow IDE - landing, Exploring, User interface, Getting started tutorial (parts 1 to 6), Configure (SDK version per application, npm registry), Add applications (workspace, create, convert, clone), Integrating source control (basic authentication, OAuth 2.0, MID Server, initialize a repository, using source control), Developing applications (synchronizing, define metadata with Fluent, JavaScript modules, third-party libraries, private npm registry, create an application file, build and install), Reference (commands, properties, roles). ServiceNow SDK - landing, Exploring, Configuring (install, upgrade, Fluent Language server), Authenticating (basic, OAuth 2.0), Adding applications (create, convert), Developing (define metadata, JavaScript modules, TypeScript in modules, third-party libraries, downloading dependencies, build and install). The SDK command reference is in ServiceNow SDK CLI Reference. https://www.servicenow.com/docs/r/application-development/servicenow-ide-family-release/integrating-source-control-servicenow-ide.html and https://www.servicenow.com/docs/r/application-development/servicenow-sdk/servicenow-sdk-landing.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# ServiceNow IDE and ServiceNow SDK

**In one line:** the two places where an application is developed as source code: the **ServiceNow IDE** (VS Code for the Web, running on the instance) and the **ServiceNow SDK** (an npm package with the `now-sdk` command line, used from VS Code Desktop on a workstation). Both are for admins and for non-production instances.

From the Brazil docs. The language and file layout: [[Source-Code Development - Fluent, JavaScript Modules and React]]. The same IDE embedded in ServiceNow Studio (Explorer tab): [[ServiceNow Studio Source Control, Fluent Apps and Deployment]]. Commands of the SDK: [[ServiceNow SDK CLI Reference]]. Not the same as `snc`: [[ServiceNow CLI]].

## ServiceNow IDE

- Application **ServiceNow IDE** (`sn_glider`), active by default on Brazil; updated through **Admin > Application Manager**. Open at **All > App Development > ServiceNow IDE**.
- It is VS Code for the Web, so these are **not available**: integrated terminal, debugger, marketplace extensions, unit testing, remote development.
- The SDK is what builds applications inside the IDE (it is the packaging service).

| View | For |
|---|---|
| File Explorer (Outline, Timeline) | files of the applications in the workspace; file history under Timeline |
| Search | text; Ctrl/Cmd-P for a file |
| Source Control | Git changes, commits, merge conflicts |
| File Categories (or Apps) | metadata by category; **Create New File** opens the ordinary platform form inside the editor |
| Now SDK | **Sync Changes**, **Build and Install** |
| Command palette | Ctrl-Shift-P (Windows), Cmd-Shift-P (Mac) |

### Workspaces and applications

A workspace belongs to one user and holds one or more applications; a user can have several.

| Task | Command or action |
|---|---|
| Create / browse / rename / delete a workspace | `Workspaces: Create a Workspace`, `Browse Workspaces`, `Rename a Workspace`, `Delete a Workspace`; `Workspaces: Welcome` = home page |
| Add an existing application | `Workspaces: Add Application to Workspace` |
| Create an application | `Fluent: Create Fluent App`: Scoped or Global, name, description, scope (`x_<prefix>_...`, 18 characters at most), npm package name, template |
| Convert an existing one | `Fluent: Convert an app to Fluent`, then right-click `metadata` > **Convert Directory to Fluent** |
| Clone | `Git: Clone` (the repository needs `now.config.json` and `package.json`; Git server 2.3.2 or later; only the default branch, then `Git: Fetch`) |
| Add Fluent scaffolding to an existing application | `Fluent: Apply Template for an existing Fluent App` |

### Sync, build, install

| Command | Does |
|---|---|
| `Fluent: Sync Fluent App with changed metadata` (**Sync Changes**) | downloads metadata changed elsewhere on the instance since the last sync and turns it into source |
| `Fluent: Force Sync of Fluent App with all metadata` | the same for all metadata; **may overwrite source changes not yet built and installed**: stage first |
| `Fluent: Build and Install` (status bar) | compiles source to metadata and installs it; modules go to EcmaScript Module (`sys_module`). The file open in the editor decides which application |
| `Fluent: Build with Now SDK` | build the installable package only |
| `Fluent: Install Fluent App in Instance` | install without rebuilding |
| `Fluent: Force Install Fluent App in Instance` | install an existing build artifact; may overwrite recent changes |
| `Fluent: Reinstall Fluent App` | uninstall and reinstall so the instance matches the package; **metadata on the instance not yet synced is removed**; also clears old module versions from `sys_module` |
| `Fluent: Download script dependencies` | type definitions for Glide APIs and script includes into `@types/servicenow` |
| `Fluent: Restart Fluent Server` | restart the language server |
| `Package Manager: Install Dependencies` | install the npm packages from `package.json` into `node_modules` |

Where synced content lands:

| Case | Destination |
|---|---|
| New metadata not defined in source | `src/fluent/generated` |
| Changes to metadata defined in source | `src/fluent` and `src/fluent/generated` |
| Changes to XML metadata not converted | `metadata` |

- When metadata changed, the IDE prompts to sync, and **syncing is required before installing**. Dismissing the prompt silences it for the session; installing or refreshing the browser prompts again.
- Before the first sync: initialise a repository and stage your changes.
- IDE 3.1.4 and earlier needed the role `sn_glider.ide_fluent_admin` for convert and reinstall.

### Git in the IDE

Credentials are **per user**, set with `Git: Set IDE Git credentials` (form *New Git credential*: **Git repository URL**, **Git username**, and either **Personal access token** for *Basic auth* or **Select an OAuth profile** for *OAuth*). They apply to every repository in that Git domain; adding different ones for the same domain deactivates the earlier ones. Manage with `Git: Manage Git credentials`. The OAuth registry, the MID Server application and the attachment-extension requirements are described in [[ServiceNow Studio Source Control, Fluent Apps and Deployment]] (same text in both sections).

Initialise: Source Control view > **Initialize Repository** (`Git: Initialize Repository`) > application > branch name (default `main`) > stage all > commit message > **Push** > remote URL. One repository per application per instance; one checked-out branch per repository per instance (or developer sandbox).

Commands (Source Control view or palette): `Git: Checkout to...`, `Git: Clone`, `Git: Commit`, `Git: Create branch...`, `Git: Discard Changes`, `Git: Fetch`, `Git: Pull`, `Git: Push`, `Git: Stage Changes`, `Git: Stash` (with `Pop`, `Drop`, `List`, `Apply`, `Clear`), `Git: Update remote origin`. Conflicting files are listed under *Merge conflicts* (accept current, incoming, both, or edit by hand). Selecting a commit opens a diff editor.

### npm in the IDE

- Default registry `https://registry.npmjs.org`; any registry must answer with the `Access-Control-Allow-Origin` header because the browser fetches the packages.
- Private registry: `Preferences: Open User Settings (JSON)` and set `package-manager.defaultRegistry` or `package-manager.scopedRegistries` (`scope`, `registry`), plus one of `package-manager.basicAuth` (`registry`, `user`, `pass`), `package-manager.legacyAuth` (`registry`, `token` = Base64 of the basic credentials) or `package-manager.tokenAuth` (`registry`, bearer `token`). These are user settings of the IDE; keep real values out of notes and repositories.
- SDK version of one application: set `@servicenow/sdk` and `@servicenow/eslint-plugin-sdk-app-plugin` in `devDependencies` of its `package.json`.

### Properties (`sys_properties`; add them if absent)

| Property | Default | Effect |
|---|---|---|
| `sn_glider.enable_ide` | true | false turns the IDE off for the instance |
| `sn_glider.fluent_convert_enabled` | true | allow converting applications not created in source |
| `sn_glider.default_to_bundled_sdk` | false | true = use the SDK version shipped with the IDE instead of the latest |
| `sn_glider.pinnedSdkVersion` | latest | fixed SDK version for new or converted applications |
| `sn_glider.git.attachment.extension.text` | `txt` | extension of text attachments used for Git data; must also be in `glide.attachment.extensions` |
| `sn_glider.git.attachment.extension.binary` | `gitdata` | the same for binary attachments |

The page's generated summary writes these names without underscores (`snglider.enableide`); the table with underscores is the correct form.

### Roles

| Role | Purpose |
|---|---|
| `sn_glider.admin` (ServiceNow IDE Administrator) | create and develop in the IDE; contains `sn_glider.create_app_admin`, `sn_glider.read_admin`, `sn_glider.write_admin`. In no group by default |
| `credential_admin` | also needed for Git operations |
| `sn_udc.admin` / `sn_udc.basic_read` | modify / read application files in the File Categories view |
| `sn_glider.ide_git_user` (ServiceNow IDE MID Server User) | for the MID Server user when Git goes through a MID Server (or admin) |

Holders of `sn_creatorstudio.restricted_user` cannot open the IDE whatever else they hold. **Discrepancy:** every task page says "Role required: admin" while this page defines a granular `sn_glider.admin`; which tasks the granular role alone covers is not stated (?).

## ServiceNow SDK

- npm package `@servicenow/sdk` from the public registry; works with instances from Washington DC on. Needs Node.js 20.18.0 and npm 8.19.3 or later. The user must hold admin on the instance.
- Per application: `npx @servicenow/sdk <command>`. Global: `npm install --global @servicenow/sdk`, then `now-sdk <command>`; upgrade with `npm update -g @servicenow/sdk`; check with `now-sdk -v`.
- VS Code extension **ServiceNow Fluent Language** gives completion and validation for `.now.ts` and `now.config.json`.
- Advantage over the IDE: offline work and everything VS Code Desktop offers. Other developers should **clone the Git repository**, not download and transform the application from the instance again.

### Workflow (workstation terminal, against a non-production instance)

| Step | Command |
|---|---|
| Authenticate | `npx @servicenow/sdk auth --add https://<instance>.service-now.com` > `basic` or `oauth` > alias (> user name and password for basic). Stored in the operating system keychain and made the default |
| Create | `npx @servicenow/sdk init` > template, application name, npm package name, global or scoped (global only from Australia on), scope name |
| Convert | `npx @servicenow/sdk init --from <sys_id of the application or local path>`; metadata arrives as XML in `metadata`; nothing changes on the instance until install |
| Install packages | `npm install` |
| XML to Fluent (optional) | `now-sdk transform --from metadata/update --auth <alias>`; output in `src/fluent/generated`; `--preview true` only shows the result |
| Type definitions | `now-sdk dependencies --auth <alias>` |
| Pull instance changes | `now-sdk transform --auth <alias>` (module changes are not included) |
| Build | `now-sdk build` (output in `dist/app`, XML under `dist/app/update`) |
| Install | `now-sdk install --auth <alias>` |

- OAuth needs ServiceNow IDE 1.1 or later on the instance (Brazil ships 1.1.4): the browser opens, **Accept**, copy the code shown and paste it in the terminal.
- **If the same metadata exists locally as XML and as Fluent, the XML wins on install.**
- `install --reinstall true` removes instance metadata that is not in the local package, including other developers' work: transform first.
- After installing a converted application, **Package JSON** on the application record (`sys_app`) holds the path to `package.json`.
- Global applications: use npm as the package manager.

### TypeScript in modules

Since SDK 3.0 modules may be TypeScript with default compiler options. For an older application: add `typescript` (4.8.4 or later) to `devDependencies`, put a `tsconfig.json` in `src/server` (module and target `es2022`, `moduleResolution` `bundler`, `allowImportingTsExtensions`, `noEmit`; include `./**/*.ts` and `../../@types/**/*.modules.d.ts`, exclude `**/*.now.ts`) and point `tsconfigPath` in `now.config.json` to it. For a custom transpile step use `modulePaths` instead.

APIs without downloaded types can be stubbed by hand in a `.ts` file; the stub is not packaged:

```ts
// type stub only, for editor support (server-side API, used from a module in a scoped application)
declare module '@servicenow/glide/sn_app_api' {
  class AppStoreAPI { static canUpgradeAnyStoreApp(): boolean }
}
```

A module can reach only global scriptable objects and those of its own scope.

### Dependencies for editor support

| Kind | How | Result |
|---|---|---|
| Fluent (items of other scopes) | list them in `dependencies` of `now.config.json` (`"<scope>": { "tables": ["incident"], "roles": ["admin"], "<table>": ["<sys_id>"] or "*" }`; only tables and roles by name), then `now-sdk dependencies --fluent-only` | `.d.now.ts` files in `@types/servicenow/fluent`; not compiled |
| Scripts | `now-sdk dependencies --type-defs-only` | Glide API types plus the script includes your scripts use, in `@types/servicenow` |

Using a downloaded dependency in Fluent needs `"imports": { "#now:*": "./@types/servicenow/fluent/*/index.js" }` in `package.json`, then:

```ts
import { role as globalRole } from '#now:global/security'
Acl({ $id: Now.ID['example_acl'], type: 'record', table: 'incident', operation: 'read', roles: [globalRole.admin] })
```

For script type-ahead create in `src/fluent` a `tsconfig.server.json` (includes `./**/*.server.js` and `../../@types/servicenow/*.server.d.ts`), a `tsconfig.client.json` (`./**/*.client.js`, `*.client.d.ts`, libs DOM and ES6) and a `tsconfig.json` referencing both; then name scripts `*.server.js` or `*.client.js`.

## Example

Create and install a small application from a workstation (invented names):

```bash
npx @servicenow/sdk auth --add https://<instance>.service-now.com --type oauth --alias dev1
```

```bash
npx @servicenow/sdk init --appName "Example App" --packageName example-app --scopeName x_acme_example --template typescript.basic --auth dev1
```

```bash
npm install
```

```bash
npx @servicenow/sdk build
```

```bash
npx @servicenow/sdk install --auth dev1
```

## Related

- [[Source-Code Development - Fluent, JavaScript Modules and React]] · [[ServiceNow SDK CLI Reference]] · [[ServiceNow Fluent API Reference]] · [[ServiceNow Studio Source Control, Fluent Apps and Deployment]] · [[Application Scope and Namespace Identifiers]] · [[Build Agent]]
