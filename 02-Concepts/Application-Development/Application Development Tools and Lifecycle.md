---
type: concept
tags: [concept, platform, admin, ai, reporting, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > AI Workflow Factory Prime and Learning about developing on the ServiceNow AI Platform (read 2026-10-08 through the docs site): AI Workflow Factory Prime, Learning about developing, Find ServiceNow developer products quickly (the pro-code and low-code finder pages, Reporting on data from pro-code / low-code apps, What ServiceNow product solves your problem), Programming basics, Early Availability guide, Low-code versus pro-code development, Modifying versus building an application, Understand the ServiceNow UI experiences, Support for developers, Licensing. https://www.servicenow.com/docs/r/application-development/build-applications.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Application Development Tools and Lifecycle

**In one line:** the map of what ServiceNow offers for building an application, by how much code you want to write and by stage of the lifecycle.

This note comes from the **Brazil** docs; the rest of the vault is mostly Australia. Detail notes: [[Application Scope and Namespace Identifiers]], [[Application Access Settings and Cross-Scope Privileges]], [[Application Administration and Collaboration Descriptors]], [[Personal Developer Instances]].

## Which builder

| Tool | For | What it is |
|---|---|---|
| **Creator Studio** | people who do not code | guided, no-code builder for request-and-fulfil applications: a form that submits to a catalog item and starts a playbook |
| **App Engine Studio** (AES) | low-code | wizard-driven builder of scoped applications |
| **ServiceNow Studio** | citizen and platform developers ("mid-code") | one environment with all builders, navigation of application files, tracking and packaging |
| **Build Agent** | any level | builds a full scoped or global application from natural-language prompts, inside ServiceNow Studio or the ServiceNow IDE |
| ServiceNow IDE, ServiceNow SDK, VS Code extensions, ServiceNow CLI, REST and script APIs | pro-code | source-code development |
| Mobile App Builder, Mobile Card Builder | mobile | |

Builders used inside any of them: UI Builder, Table Builder, Workspace Builder (AES only), Workflow Studio flows, playbooks and decision tables ([[Workflow Studio Overview]]), business rules ([[Business Rules]]).

- *No-code* needs no development experience (risk: unsanctioned "shadow IT" apps); *low-code* is visual with the option to script; *pro-code* has no tool limits and needs programming skill.
- Ask first whether an existing application can be extended. Building new is worth it when the old one no longer fits the business, costs more to maintain than to replace, or cannot take the features wanted without disrupting its users.

## AI Workflow Factory Prime (entitlement bundle)

App Engine Management Center, App Engine Studio, ATF Test Generator and Cloud Runner, Autonomous Engineer, Creator Studio, Developer Sandboxes, ServiceNow Otto for App Engine, ServiceNow Otto for Creator, ServiceNow Studio for App Engine, Table Builder for App Engine, Task Mining, Workspace Builder. Access depends on entitlement.

## By stage

| Stage | Products named by the guide |
|---|---|
| Plan | delegated development, source control link, Common Service Data Model |
| Build | the builders above |
| Automate | Automation Discovery, Workflow Studio, decision tables, playbooks, business rules, Integration Hub |
| Secure | AES personas and roles, roles, ACLs, UI policies, users and groups, Edge Encryption |
| Test | Automated Test Framework, Test Management, Script Debugger, Script Tracer, session log, impersonation, CLI |
| Deploy | App Engine Management Center (requests, deployments, collaborators); application repository |
| Maintain | update sets, Service Mapping, Instance Data Replication, MetricBase |

The guide's own lifecycle: define the problem (output wanted, input data and its tables) > plan (a flowchart; get permissions) > code > test (wrong, oversized and missing data too) > deploy (done by administrators, not developers) > maintain > document (for the next developer and for users).

## Reporting on an application's data

Two generations coexist: **Core UI** (the Reporting application on table data, Performance Analytics widgets, responsive dashboards) and **Platform Analytics** (data visualisations on any source, dashboards and filters, built on the Next Experience framework). The docs say "report" for the first and "visualization" for the second.

- Filter large tables (a date range); grouping on a field with many values is slow; a *Long running transaction timer* message means add filters.
- Regular exports: schedule them.
- Dashboards in Platform Analytics can be made (1) entirely in the Platform Analytics experience, no developer needed; (2) as visualisation components on a UI Builder page; (3) in Platform Analytics then embedded in a UI Builder page through the Dashboard page template; (4) as a *technical dashboard* built in UI Builder but listed and shared like any dashboard.

## UI experiences a developer meets

| Experience | Character |
|---|---|
| Next Experience (Unified Navigation) | one shell: application pill, menus, search, Favorites, History, Workspaces; custom menus |
| Configurable Workspace | multi-record agent layout |
| Classic environment | lists and forms; full application creation |
| Core UI | default on new instances; the classic UI with the updated look |

## Licensing, early access, help

- An application needs an entitlement; with a *subscription* the application follows family upgrades automatically. Subscription types decide user allocation and custom application and table entitlements ([[Subscription Management]], [[Custom Tables and Entitlements]]).
- **Early Availability** (Developer Program): the next release about a month before general availability, with PDIs, learning plans and API documentation. Scoped server APIs are the ones to build on; legacy (global) APIs are documented for existing global work.
- Help: ServiceNow Community, the Developer Site (training, API and CLI docs, PDIs), training and certification, the developer video channel.

## Related

- [[Application Scope and Namespace Identifiers]] · [[Personal Developer Instances]] · [[ServiceNow AI Platform Overview]] · [[Workflow Studio Overview]]
