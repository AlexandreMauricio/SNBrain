---
type: reference
tags: [reference, ai, cmdb, assets, roles, release-specific]
status: documented
source: ServiceNow Brazil docs, Enable AI Experiences > AI agents and agentic workflows > AI agents library > CMDB AI agents (11 topics), IT Operations Management AI agents (20), Asset Management AI agents (7), read 2026-11-06 through the docs site API (map UBGwc5glUUjVANqQeiJeZA). Hardware and Software Asset Management, AIOps and Leap sections not read.
sn-release: Brazil
verified:
verified-by:
observed-in:
updated: 2026-11-06
---

# AI Agents Library - CMDB, ITOM and Asset Agents

**In one line:** the shipped AI agents that search, create and govern CIs, investigate monitoring alerts across observability tools, and repair or source assets.

From the Brazil docs, not tested. Background: [[AI Agent Studio, Agentic Workflows and AI Control Tower]], [[AI Agents Library - Platform and Creator Agents]]. A dash (–) means the role was not captured from the page.

## CMDB

| Agent | Does | Allowed role | Used in |
|---|---|---|---|
| CMDB search | builds and runs CI queries, joins across tables, returns links or a summary | `sn_cmdb_user` | Search on CMDB |
| CMDB data model navigator | answers questions about classes, tables, fields and relationships | `sn_cmdb_user`, `sn_data_model_nav.data_model_navigator_read` | CMDB Data Model Navigator Assistant |
| CI form contextual help | explains CI attributes, classes and workspace views | `sn_cmdb_user` | Show contextual CI form help |
| Configuration item summarization | summarises a CI by sys_id with the CI summarization skill | `sn_cmdb_user` | – |
| CMDB CI creator | creates a CI | `sn_cmdb_editor` | Create configuration item |
| Data certification and attestation manager, data ownership manager, health metrics manager, life cycle manager, principal class manager | act on those governance settings of CI classes | `sn_cmdb_admin` | CMDB Data Governance |

Concepts: [[CMDB Health]], [[CMDB Workspace]], [[CI Classes, Dependency and Principal Class]].

## IT Operations Management

**Alert investigation:** one agent per observability tool, all used in the *Analyze alert impact* agentic workflow, with **SRE investigate** coordinating them and correlating their findings:

| Tool | Agent |
|---|---|
| AWS CloudWatch | CloudWatch API agent; CloudWatch MCP server agent |
| Microsoft Azure | Azure Monitor MCP agent (KQL on Log Analytics) |
| Google Cloud | Gemini Cloud Assist A2A investigation agent |
| Datadog, Dynatrace, New Relic, Splunk, ThousandEyes | an MCP server agent each (Dynatrace's needs `evt_mgmt_operator`; Splunk's does not cover Splunk Observability Cloud) |
| Prometheus, LogicMonitor | an API agent each |
| Kentik, SolarWinds | analysis agents (Kentik: `evt_mgmt_operator`; SolarWinds: SWQL queries) |
| network issues in general | Network SME agent |

The MCP agents rely on the MCP Client ([[AI Platform Map, Roles and Product Tiers]]).

**Service mapping and CSDM:**

| Agent | Does | Allowed role | Data access role |
|---|---|---|---|
| Analyze potential impact | finds servers and services a change affects and writes the result to work notes | `sn_change_write` | `service_mapping_ai_user`, `cmdb_read`, `itom_admin` ... |
| Service map | runs on a schedule and builds service maps from ML-based and tag-based candidates | `snc_internal` | as above |
| CSDM business application to infrastructure (an *AI specialist*) | matches each business application to a discovered service and creates the *Uses::Used by* relationship in `cmdb_rel_ci` | `snc_internal` | as above |
| Pattern Diagnostic | finds CIs with missing attributes and reads discovery logs to diagnose the pattern | – | – |

Products: [[Discovery Overview]], [[Service Mapping Overview]], [[Event Management Overview]].

## Asset Management

| Agent | Does | Allowed role | Used in |
|---|---|---|---|
| Asset next best action | checks the task and routes it to the right repair agent | `inventory_user` | Help repair hardware or enterprise assets |
| Evaluate asset, Repair asset | troubleshoot and repair defective assets, using web search | `inventory_user` (data adds `sn_eam.asset_technician`) | same |
| Asset sourcing | plans and runs sourcing by consumption, transfer or purchase | `procurement_user` | Help manage enterprise asset requests |
| Purchase order creation, Transfer order creation | create the order | `procurement_user` (data adds `itil`, `sn_request_write`) | Help manage hardware or enterprise asset requests |

## Example

With the CMDB AI agents active, *Test User* holding `sn_cmdb_user` asks the Otto panel for Linux servers in *Example Location* with no owner. The CMDB search agent builds the query and returns a list link. The same user cannot run the governance agents, which need `sn_cmdb_admin`.

## Related

- [[AI Agents Library - Platform and Creator Agents]] · [[Otto for ITSM Agentic Workflows and AI Agents Reference]] · [[CMDB Workspace]] · [[Role Masking for AI Agents]]
