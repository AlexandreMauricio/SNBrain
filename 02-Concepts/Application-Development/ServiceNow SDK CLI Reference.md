---
type: reference
tags: [reference, platform, api, javascript, encoded-query, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Developing your application > Building pro-code applications > ServiceNow SDK > Reference > ServiceNow SDK CLI (read 2026-10-08 through the docs site; whole page). The page itself says the newest command documentation is on GitHub. https://www.servicenow.com/docs/r/application-development/servicenow-sdk/servicenow-sdk-cli-commands.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# ServiceNow SDK CLI Reference

**What it is:** the commands of `now-sdk`, the command line of the ServiceNow SDK. It runs on a workstation, inside an application directory, and talks to a non-production instance (Washington DC or later) as an admin user.

From the Brazil docs. Context and workflow: [[ServiceNow IDE and ServiceNow SDK]]. Invoke as `now-sdk <command>` (global install) or `npx @servicenow/sdk <command>` (installed in the application). A different tool from `snc`: [[ServiceNow CLI]].

Global options: `--version` / `-v`, `--help` / `-h` (also per command), `--debug` / `-d`.

## Commands

| Command | Does | Changes the instance? |
|---|---|---|
| `auth` | store, list, delete, choose credentials | no |
| `init` | create an application, or convert one | no |
| `build` | compile source into build artifacts | no |
| `install` | package and install on the instance | **yes** |
| `dependencies` | download type definitions | no |
| `transform` | instance metadata (XML) into Fluent source | no |
| `move` | global-scope metadata into a local global application | no (local) |
| `download` | all metadata XML of the application, for comparison | no |
| `clean` | delete build output | no |
| `pack` | zip the build output | no |
| `explain` | show Fluent API documentation | no |
| `query` | read-only Table API query | no |

### auth

| Form | Parameters |
|---|---|
| `auth --add <instance url>` | `--type` `basic` or `oauth` (default `oauth`); `--alias <alias>` (usable with `init`, `transform`, `dependencies`, `install`) |
| `auth --delete <alias>` | `all` deletes every credential |
| `auth --list` | passwords and codes are not shown |
| `auth --use <alias>` | set the default |

Credentials live in the operating system keychain or credential manager.

### init

`init [--from <sys_id or path>] [--appName] [--packageName] [--scopeName] [--auth] [--template]`. Without parameters it prompts. Run `npm install` afterwards.

| Template | Gives |
|---|---|
| `base` | minimal structure |
| `javascript.basic`, `typescript.basic` | Fluent plus JavaScript or TypeScript modules (TypeScript in `src/server` is transpiled) |
| `javascript.react`, `typescript.react` | the same plus React UI |
| `partial.javascript.react`, `partial.typescript.react` | add the React files to an existing application |

### build

`build <source> [--frozenKeys] [--errorOnConflict] [--skipClean]`; `source` = directory holding `package.json` (default: current).

| Parameter | Default | Effect |
|---|---|---|
| `--frozenKeys` | false | for CI: fail instead of updating `keys.ts` (generated in `src/fluent/generated`) when Fluent code changed |
| `--errorOnConflict` | false | sys_id conflicts between Fluent and XML become errors, not warnings |
| `--skipClean` | false | keep the output directory (faster incremental builds) |

npm dependencies are converted to XML that installs with the application.

### install

`install [--source] [--reinstall] [--auth] [--open-browser] [--info] [--demoData] [--skip-flow-activation]`. Needs a previous `build`.

| Parameter | Default | Effect |
|---|---|---|
| `--reinstall`, `-r` | false | uninstall then install; **instance metadata missing from the local package is removed**; old module versions leave `sys_module` |
| `--auth`, `-a` | default alias | credentials |
| `--open-browser`, `-b` | false | open the application record afterwards |
| `--info`, `-i` | false | report on the last installation; installs nothing |
| `--demoData` | true | include demo data |
| `--skip-flow-activation` | false | do not publish flows on install (activating needs IDE 4.1.1 or later on the instance) |

**CI/CD without prompts** (environment variables of the pipeline; values come from the pipeline's secret store, never from files in the repository):

| Variable | Value |
|---|---|
| `SN_SDK_NODE_ENV` | `SN_SDK_CI_INSTALL` |
| `SN_SDK_INSTANCE_URL` | `https://<instance>.service-now.com` |
| `SN_SDK_AUTH_TYPE` | `basic` (default) or `oauth_client_credentials` |
| `SN_SDK_CLIENT_ID`, `SN_SDK_CLIENT_SECRET` | `<CLIENT_ID>`, `<CLIENT_SECRET>` |
| `SN_SDK_USER`, `SN_SDK_USER_PWD` | for basic authentication |

### dependencies

`dependencies [--directory] [--auth] [--type-defs-only] [--fluent-only] [--add <table> <sys_ids or names>] [--scope <name>]`

| Parameter | Effect |
|---|---|
| none | both kinds |
| `--type-defs-only` | script types only (`@types/servicenow`) |
| `--fluent-only` | items listed in `now.config.json` only (`@types/servicenow/fluent`) |
| `--add` with `--scope` | write dependencies into `now.config.json`: `--add tables incident problem`, `--add roles admin itil`, `--add sys_security_acl "*"`, or a table name followed by sys_ids |

### transform

`transform [--from <path>] [--directory] [--auth] [--format] [--table]`

- No parameters: new instance metadata becomes source in `src/fluent/generated`, and changes to metadata already in source are merged into `src/fluent`.
- `--from <dir or file>`: convert local XML (what existed at `init`) into Fluent.
- `--format` / `-f` (default true): format the generated code.
- `--table sys_script,sys_security_acl`: only these tables (child tables included).
- The convert page also shows `--preview true` (display without saving), which this reference table does not list.

### move, download, clean, pack

| Command | Notes |
|---|---|
| `move --ids <sys_id,sys_id> [--source] [--auth]` | pulls global-scope metadata into a local **global** application as Fluent; that application must already be installed on the instance |
| `download <directory> [--source] [--incremental]` | all metadata XML into a directory other than `metadata`; `--incremental` = only changes recorded in Customer Updates (`sys_update_xml`). Module changes are not included |
| `clean <source>` | remove build artifacts |
| `pack <source> [--skip-package-inventory]` | installable zip; `package_inventory.csv` speeds upgrades |

### explain

`explain <topic> [--list] [--format pretty|raw] [--peek]`: documentation for a Fluent API, guide or skill (`table-api`, `table-guide`, `uipage-api`). `--list` filters the topic list by keyword, `--peek` gives a one-line description, `raw` prints Markdown.

### query

`query <table> --query <encoded query> [...]`: read-only Table API query, meant for looking up sys_ids, schemas, existing records and choice values while writing Fluent (and for feeding an AI agent).

| Parameter | Default | Table API parameter |
|---|---|---|
| `--query`, `-q` | required | `sysparm_query` |
| `--limit` | 100 | `sysparm_limit` |
| `--offset` | 0 | `sysparm_offset` (use `nextOffset` from JSON output) |
| `--fields`, `-f` | all | `sysparm_fields` |
| `--display-value` | false | `sysparm_display_value` (`true`, `false`, `all`) |
| `--exclude-reference-link` | true | `sysparm_exclude_reference_link` |
| `--no-count` | false | `sysparm_no_count` |
| `--view` | | `sysparm_view` |
| `--query-category` | | `sysparm_query_category` |
| `--query-no-domain` | false | `sysparm_query_no_domain` |
| `--timeout` | 30000 ms | per page |
| `--output`, `-o` | | `json` = envelope with `ok`, `hasMore`, `nextOffset`, `records`; log output suppressed |

```bash
now-sdk query sys_choice --query 'name=incident^element=state' --fields 'value,label' --auth dev1 --output json
```

## Related

- [[ServiceNow IDE and ServiceNow SDK]] · [[Source-Code Development - Fluent, JavaScript Modules and React]] · [[ServiceNow Fluent API Reference]] · [[ServiceNow CLI]]
