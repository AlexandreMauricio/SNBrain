---
type: concept
tags: [concept, platform, scripting, javascript, glide-api, schema, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Developing your application > Building pro-code applications (read 2026-10-08 through the docs site): Building pro-code applications, Building applications in source code, ServiceNow Fluent, JavaScript modules and third-party libraries, Third-party library support in Brazil, User interface development with React, Custom application configuration in source code. https://www.servicenow.com/docs/r/application-development/building-applications-source-code.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Source-Code Development - Fluent, JavaScript Modules and React

**In one line:** an application can be written as files instead of forms: metadata declared in **ServiceNow Fluent** (`.now.ts`), server logic in **JavaScript modules**, UI optionally in **React**, built into ordinary metadata on the instance, with changes flowing both ways.

From the Brazil docs. The two environments: the ServiceNow IDE (in the browser, inside ServiceNow Studio) and the ServiceNow SDK (local, VS Code): [[ServiceNow IDE and ServiceNow SDK]]. Folder layout and build / sync commands in Studio: [[ServiceNow Studio Source Control, Fluent Apps and Deployment]].

## IDE or SDK

| | ServiceNow IDE | ServiceNow SDK |
|---|---|---|
| Where | on the instance (VS Code for the Web) | local VS Code Desktop; works offline |
| Collaboration | others' changes visible live; Git | download from / install to the instance with the CLI; Git |
| Git | common operations; one checked-out branch per repository per instance (or sandbox) | full |
| Fluent language server | included | extension from the marketplace |
| Code autocomplete (Otto for Code) | yes | no |
| Build Agent | chat panel | "skills" from SDK 4.6.0 |
| Converting existing applications | yes | yes |

## ServiceNow Fluent

A declarative language based on TypeScript for the records under Application File (`sys_metadata`): one API per record type (tables, roles, ACLs, business rules, client scripts, ATF tests, UI pages ...) and a generic **Record** API for types without their own. API reference: https://servicenow.github.io/sdk/. A few types (`sys_metadata_link`, `sys_ux_lib_asset`) cannot be expressed and stay XML.

Shape of a file (runs nowhere by itself: it is compiled at build into records; the scripts it references run where their record type runs, in the application's scope):

```ts
import '@servicenow/sdk/global'
import { BusinessRule, ClientScript, StringColumn, Table } from '@servicenow/sdk/core'
import { logChange } from '../server/script.js'   // a JavaScript module

export const x_acme_example_item = Table({
  name: 'x_acme_example_item',
  schema: {
    state: StringColumn({ label: 'State', choices: { ready: { label: 'Ready' }, done: { label: 'Done' } } }),
    task:  StringColumn({ label: 'Task', maxLength: 120 }),
  },
})

ClientScript({                       // client side, onLoad
  $id: Now.ID['cs0'], name: 'example_onload', table: 'x_acme_example_item',
  type: 'onLoad', uiType: 'all', script: Now.include('../client/client-script.js'),
})

BusinessRule({                       // server side, after update
  $id: Now.ID['br0'], name: 'LogStateChange', table: 'x_acme_example_item',
  when: 'after', action: ['update'], order: 100, active: true, script: logChange,
})
```

- `$id: Now.ID['...']` is the stable key that maps the object to its record.
- `Now.include(path)` pulls a script file's text in.
- Comment directives: `@fluent-ignore` (silence diagnostics on the next line), `@fluent-disable-sync` (never overwrite the next object from instance changes), `@fluent-disable-sync-for-file` (first line: same for the whole file).

## JavaScript modules

A module is a `.js` or `.ts` file under `src/server` whose exports are reused inside the application; on the instance modules are rows in EcmaScript Module (`sys_module`).

```js
// src/server/script.js  (server side, scoped application)
import { gs, GlideRecord } from '@servicenow/glide'
export function logChange(current, previous) {
  gs.addInfoMessage(`state: ${previous.getValue('state')} -> ${current.getValue('state')}`)
}
```

| Rule | Detail |
|---|---|
| Glide APIs are not global in a module | import them: `import { gs } from '@servicenow/glide'`; namespaced ones from their namespace (`@servicenow/glide/sn_ws_int` for `RESTAPIRequest`) |
| Script includes | `import { global } from '@servicenow/glide/global'` or `import { X } from '@servicenow/glide/<scope>'` |
| From a classic script (business rule, script include) | `const { feature } = require('path/to/module')`; `import` / `export` only work inside modules |
| TypeScript to TypeScript | include the `.ts` extension in the import |
| Short import names | `imports` map in `package.json` (`"#calc": "calculus"`) |
| Scope | a module is usable only in its own application scope |
| Editing | only in the IDE or with the SDK |
| Not available | Node.js APIs (built-ins are polyfilled at build), browser globals, CommonJS packages without `exports`, application customizations; only the ECMAScript features the platform's engine supports |

**npm libraries**: declare in `package.json` `dependencies`. A library that needs platform APIs must be listed under `trustedModules` in `now.config.json` (only for packages you trust fully). Tested for Brazil:

| Result | Libraries |
|---|---|
| Work | @langchain/textsplitters, acorn, bn.js, camelcase, chance, clone, date-fns, dayjs, debug, diff, docxtemplater, extend, fast-csv, html-parser-lite, iconv-lite, inherits, ini, js-yaml, lodash, lru-cache, marked, mime, mime-types, moment, moment-timezone, ms, openai, path-to-regexp, pdf-lib, pizzip, ramda, reflect-metadata, saxes, semver, strip-ansi, tslib, underscore, uuid, validator, xtend |
| Partly | @aws-sdk/client-s3, effect, jszip, minimatch, underscore.string, util |
| Do not work | @faker-js/faker, ajv, archiver, axios, deep-equal, eml-parser, exceljs, jws, qs, unzipper |

## React UI (experimental)

1. Create the application from a React template.
2. Put `index.html` (containing `<sdk:now-ux-globals>` and a `<script src="./main.jsx" type="module">`), scripts and styles in `src/client`.
3. Declare a UI page (`sys_ui_page`) in Fluent: `UiPage({ $id, endpoint: '<scope>_example.do', html: importedIndexHtml, direct: true })`.
4. Build: Rollup bundles `src/client` into `dist/static`.
5. Install: assets land in `sys_ux_lib_asset`, `db_image`, `sys_ux_theme_asset`; the page opens at `https://<instance>.service-now.com/<scope>_example.do`.

Limits: edit the HTML only in source (instance edits do not sync back); no audio, video or WASM; attachment size limit `com.glide.attachment.max_size`; no `rel="preload"`, no relative stylesheet links or CSS imports, no CSS modules; hash routing only; no server-side rendering. Some Next Experience components are usable through the React Wrapper Component Library npm package.

## `now.config.json`

| Parameter | Purpose (default) |
|---|---|
| `scope`, `scopeId`, `name` | the application |
| `fluentDir` (`src/fluent`), `generatedDir` (`generated`), `serverModulesDir` (`src/server`), `clientDir` (`src/client`), `metadataDir` (`metadata`) | source layout |
| `appOutputDir` (`dist/app`), `staticContentDir` (`dist/static`), `packOutputDir` (`target`) | build output |
| `dependencies` | items of other scopes the application uses: `{ "<scope>": { "tables": [...], "roles": [...] } }` |
| `excludeFilePatterns`, `ignoreTransformTableList` | what not to transform or download |
| `serverModulesIncludePatterns` / `ExcludePatterns` | which files become modules (tests and `.d.ts` excluded) |
| `modulePaths` **or** `tsconfigPath` | custom transpile mapping, or a tsconfig (never both) |
| `staticContentPaths` | client source to output mapping |
| `linter.module.enabled` (true) | check modules against the platform's JavaScript engine |
| `taxonomy` (`mapping`, `fallbackFolderName` = `other`) | folders for generated Fluent by table, e.g. `sys_script` to `server-development/business-rule` |
| `tableOutputFormat` (`bootstrap` or `component`) | how table XML is emitted |
| `defaultLanguage` (`en`) | language for field labels |
| `trustedModules` | npm packages allowed platform APIs (`External source` = false in `sys_module`) |
| `applicationRuntimePolicy` (`none`, `tracking`, `enforcing`) | runtime access tracking ([[Application Access Settings and Cross-Scope Privileges]]) |
| `networkPolicies` | network access policy records (`sys_arp_network_policy`): `policyType` (`csp_script_src`, `csp_connect_src`, `now_inbound_scoped`, `now_inbound_global`, `now_outbound`), `status` (requested / allowed / denied), host, scheme, path, resource |
| `wildcardPolicy` | exemption policy (`sys_arp_segment_policy`) per pillar: network, scripting, application resource limits, record |
| `performancePolicy` | quota template (`sys_app_resource_limit_template`): percentages for API transactions, event handlers, interactive transactions, scheduled jobs; `mode` disabled / enforced / logOnly |

## Related

- [[ServiceNow IDE and ServiceNow SDK]] · [[ServiceNow SDK CLI Reference]] · [[ServiceNow Fluent API Reference]] · [[ServiceNow Studio Source Control, Fluent Apps and Deployment]] · [[Build Agent]] · [[Business Rules]] · [[Metadata File Types and Primary Tables]]
