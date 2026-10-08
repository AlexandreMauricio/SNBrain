---
type: reference
tags: [reference, api, integrations, admin, cmdb, encoded-query, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Developing your application > ServiceNow CLI (read 2026-10-08 through the docs site; whole section, 2,579 cleaned lines; the sample JSON responses were skipped): ServiceNow CLI, Install the ServiceNow CLI (Mac, Windows, Linux), Configuring and managing your ServiceNow CLI connection profiles (default profile, named profile, view, remove, refresh), Get help with ServiceNow CLI, Perform record operations (create, delete, get, query, update), Create a custom command in ServiceNow CLI, Manage ServiceNow CLI extensions, ServiceNow CLI available commands, Commands installed with CMDB Application CLI and API. https://www.servicenow.com/docs/r/application-development/servicenow-cli/servicenow-cli.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# ServiceNow CLI

**What it is:** `snc`, a command-line program for a workstation that runs operations on an instance. Every command is a record on the instance mapped to a REST endpoint, so the available commands depend on the instance you connect to, and you can add your own.

From the Brazil docs. Not the same tool as the ServiceNow SDK (`now-sdk`) used by the ServiceNow IDE. Interfaces overview: [[Integration Options and Interfaces Overview]].

## Install

- Workstation: installer bundle from the ServiceNow Store for 64-bit macOS, Windows 10 or later (default `C:\Program Files\ServiceNow CLI`), or Linux (CentOS, Ubuntu); tick *Add to PATH*. Check with `snc version`. Latest version named: 1.1.0.
- Instance: the **CLI Metadata** application (`sn_cli_metadata`) from the Store; needed for record operations and custom commands.
- Roles for record commands: `sn_cli_metadata.cli_user`, `sn_cli_metadata.cli_admin` or admin. Installing and defining commands: admin.

## Profiles

Stored in `~/.snc/config.json` (Windows `%USERPROFILE%\.snc\config.json`): per profile `host`, `loginmethod`, `username`, `output`, `hostversion`, `appversion`. **Secrets are kept in the operating system keychain, not in the file.** Every run is logged under `.snc/.logs`.

| Command | Does |
|---|---|
| `snc configure profile set` | interactive; creates or edits the **default** profile: host (`https://<instance>.service-now.com` or just the name), login method (Basic, OAuth, OAuth + MFA), user name, password, and for OAuth the client id and secret (`<CLIENT_ID>`, `<CLIENT_SECRET>`), for MFA the authentication code; default output format |
| `snc configure profile set --profile <name>` | a named profile; use it with `--profile <name>` on any command |
| `snc configure profile list [--profile <name>]` | show profiles (no secrets) |
| `snc configure profile remove --profile <name>` | remove a named profile; the default one only by editing the file |
| `snc configure profile refresh [--profile <name>]` | reload the command list from the instance; do this after changing commands there |

## Syntax and global arguments

`snc <command-group> [<child group>] <command> [arguments]`, arguments in any order; quote values containing spaces.

| Argument | Effect |
|---|---|
| `--help`, `-h` | name, description, synopsis, commands, groups, arguments, examples |
| `--debug`, `-d` | print log output |
| `--profile`, `-p` | which profile |
| `--output`, `-o` | `json` (default), `yaml`, `text` (tab-separated, for grep / awk / PowerShell), `table`, `none`; overrides the profile |
| `--no-interactive` | never prompt: use defaults or fail |
| `--no-verbose` | no messages; for automated runs |

## Record commands

Run from the workstation against the instance; they act with the profile user's rights (ACLs apply as through the Table API).

| Command | Arguments |
|---|---|
| `snc record create` | `--table`, `--data` (JSON string of field/value pairs); one record per call; returns the record |
| `snc record get` | `--table`, `--sysid` |
| `snc record query` | `--table`, `--query` (encoded query, required), `--fields` (comma list), `--limit`, `--offset`, `--displayvalue` (display values for reference and choice fields) |
| `snc record update` | `--table`, `--sysid`, `--data` |
| `snc record delete` | `--table`, `--sysid` |

```bash
snc record query --table incident --query 'active=true^priority=1' --fields number,short_description --limit 5 --output table
```

```bash
snc record create --table incident --data "{'short_description': 'Example incident', 'impact': '3'}"
```

## Custom commands

Defined on the instance under **Command Line Interface (CLI)**, role admin; each belongs to an application scope.

| Record | Fields |
|---|---|
| **End Points** (`sn_cli_metadata_end_point`) | **Resource Path** (any inbound or scripted REST path, for example `api/now/table/{table}/{sysid}`), **HTTP Method** |
| **Command Groups** | **Name**, **Parent Group**, **Reference Group** (alias of an existing group), descriptions, **Active** |
| **Commands** | **Name**, **Command Group**, **API Endpoint**, or **Reference Command** (alias; no chains, no ancestors, descendants or callbacks); help text and examples; **Success / Failure Expression** evaluated on the response (for example `result.code = 1`); success, progress and failure messages; **Is Callback Command** (hidden from users) and on a primary command the callback settings: **Callback Expression**, **Callback Command**, **Callback Interval** (ms, default 1,000), **Max Retries** (default 10), used to poll a long-running operation |
| *Command Arguments* | **Name**, **Short Name**, **Data Type** (String, Integer, Boolean, File Input, Password), **Default Value**, **Mandatory**, **Prompt**, **Visibility Expression** (ask only depending on an earlier answer), **Order**. File input: up to 10 MB (`glide.rest.scripted.max_inbound_content_length_mb`); YAML is converted to JSON unless **Skip Pre-processing** |
| *API Endpoint Arguments* | map to the REST call: **Name**, **Value** (literal or `{flags.<argument>}`), **Parameter Type** (Body, Header, Path, Query) |
| *Return Values* | **Path Expression** into the response and an **Alias**, to return only some keys |

## Extensions

`snc extension list-available -o table`, then `snc extension add | update | remove --name <extension>`.

**ui-component** extension (custom Next Experience components):

| Command | Arguments |
|---|---|
| `snc ui-component project` | `--name` (unique npm package name), `--description`, `--scope` (up to 18 characters, snake case; default `x_<company code>_<component name>`, company code from `glide.appcreator.company.code`), `--offline` (scaffold without validating the scope) |
| `snc ui-component develop` | local test server: `--entry` (default `example/index.js`), `--open`, `--port` (default 8081), `--host` |
| `snc ui-component deploy` | to the instance as an application: `--open` (UI Builder), `--force` (overwrite existing component records) |

## CMDB application service commands

Added by the Store application *CMDB Application CLI and API* (`app-cmdb-api-cli`); REST equivalent: the SG Services API. Group `snc service-graph app-service <command> --data '<JSON>'` (double quotes around the JSON on Windows). Role `app_service_admin` (`app_service_user` may use `find`, operational services only), plus Service Mapping roles where relevant.

The service is identified by `sys_id`, else `number`, else identification (IRE) fields such as `name`, `environment`, `version`, in that order of precedence.

| Command | Does | Extra properties |
|---|---|---|
| `register` | create the application service with tags and upstream relationships | `tags` (key, value); `relationships` (up to 25): `business_app`, `business_service_offering`, `technical_service_offering`, `parent_app_service` (the page's own example writes `business_application`: check) |
| `find` | details and upstream relationships | |
| `update` | basic fields and tags only | |
| `update-state` | `state`: ACTIVATE (operational_status Operational, life_cycle_stage Operational, status In Use), DEACTIVATE (Non-Operational, Design, Build), RETIRE (Retired, End Of Life, Retired) | |
| `populate` | fill the service by a population method | `population_method.type`: `cmdb_group` (`group_id`), `dynamic_service` (`levels`, default from property `svc.manual.convert.levels.default_value`, else 3), `tag_list` (`tags`), `tag_based_service_family` (`service_candidate`), `service_hierarchy` (`service_relations` parent/child pairs) |
| `convert` | turn a manual or empty service into a calculated one (record moves to `cmdb_ci_service_calculated`) | `levels` |
| `create-relationship`, `delete-relationship` | one `parent` and one `child` (child in Service Instance `cmdb_ci_service_auto`; a dynamic CI group can only be a child) | `parent.class_name`: `cmdb_ci_service_auto` (default), `cmdb_ci_service_discovered`, `cmdb_ci_service_by_tags`, `cmdb_ci_service_calculated`, `service_offering`, `cmdb_ci_business_app` |
| `delete` | delete the service | |

Related: [[Service Builder]], [[Service Offerings, Commitments and Availability]].

## Related

- [[Integration Options and Interfaces Overview]] · [[Application Scope and Namespace Identifiers]] · [[Application Development Tools and Lifecycle]]
