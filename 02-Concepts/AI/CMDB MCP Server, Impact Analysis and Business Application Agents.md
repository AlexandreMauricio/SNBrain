---
type: reference
tags: [reference, ai, cmdb, integrations, change, release-specific]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > ServiceNow Otto for CMDB > Activate the CMDB MCP Server, CMDB MCP Server, MCP Server tools reference, Analyzing the impact of a change or incident, Analyze change and incident impact, CMDB impact analysis agentic workflow details, Business application candidate agent reference (read in full through the docs site API 2026-10-29). https://www.servicenow.com/docs/r/servicenow-platform/now-assist-for-configuration-management-database-cmdb/na-cmdb-mcp-server-c.html
sn-release: Brazil
verified:
updated: 2026-10-29
---

# CMDB MCP Server, Impact Analysis and Business Application Agents

**In one line:** three CMDB AI pieces from the Otto for CMDB chapter: an MCP server that lets external AI clients search and create CIs, an agentic workflow that estimates the upstream impact of a change or incident, and an agent that proposes business applications for application services.

From the Brazil docs. Main note: [[Otto for CMDB Skills and Agentic Workflows]].

## CMDB MCP Server

Exposes CMDB functions as Model Context Protocol tools so an external AI client can use them without database access. Supported clients named: Claude Desktop and Moveworks.

**Activate:** MCP Platform Manager 1.4 or later (1.3 hides the tools), `com.snc.cmdb.gen.ai` active; for the bundled Service Mapping tools activate `com.sn.itom.sm.gen.ai` **before** installing the server (otherwise reinstall). **All > Admin Center > MCP Server Console** > *CMDB MCP Server* > **Activate**; control access with OAuth credentials through Inbound Integrations ([[OAuth 2.0 Inbound - The Instance as OAuth Provider]]).

| Tool | Input | Returns | Role |
|---|---|---|---|
| CMDB Search (GA) | `utterance` or `cisysid`, optional `groupby` | none; one CI with summary and form/map links; 2 to 10 listed; more grouped (max 20 groups) | `sn_cmdb_user` |
| Get Similar CI Classes (GA) | `class_name` | up to five classes (label and name) | `sn_cmdb_user` |
| Create CI (GA) | `ci_class_name`, `attributes_map` | link to the new CI; errors for missing attributes or an existing match | `sn_cmdb_editor` |
| Get Impacted Items (store release) | `change_request_number` | the impact analysis list below | `itil`, enforced by the impact skill |
| Get CI Topology (store release) | `ci_sys_id` | nodes, edges, root; truncation warning at the node limit | none of its own; follows the caller's CMDB read access |
| Explain CMDB Data Model (store release) | `user_query` | matching fields, tables, contexts, relationships (max 5 per table, 15 total) via the Data Model Navigator agent | `sn_cmdb_user` + `sn_data_model_nav.data_model_navigator_read` |

CMDB and Service Mapping tool roles are checked separately: a CMDB-only caller gets authorisation errors on every Service Mapping tool and vice versa.

## Impact analysis agentic workflow

**Inactive by default**; activate in AI Agent Studio (Agentic Solutions). Role `itil`. Ask in the Otto panel, e.g. "What is the impact of CHG...?".

1. **Resolve input**: from a `change_request` or `incident`; the description comes from the Now Assist task summary (Objective and Risk for changes, Issue for incidents), else `short_description` / `description`. CI = the record's CI, else the single affected CI (none or several = error). Cancelled changes (state 4) and closed incidents (state 8) are rejected; New changes (state 5) skip summarisation.
2. **Fetch topology**: three-phase breadth-first walk of `cmdb_rel_ci` upstream. All relationship types; Service Mapping associations (`svc_ci_assoc`) are not used.
3. **LLM assessment**: per upstream CI `sysId`, `ciName`, `ciClass`, `impactLevel` (high, medium, low, none), `impactType` (availability, performance, data-integrity, functional, security, operational, none), `confidence`, `reason` (including redundancy, e.g. a three-node tier surviving one loss). Input limit 15,000 tokens.

Output also as a topology picture (root purple; red high, orange medium, grey none). One Otto credit per run that reaches the LLM. A CI with no upstream dependencies gives an empty list, not an error. Only topology is considered: no past changes, open incidents or schedules. Vague descriptions give weak results. Use it to find single points of failure and owners to notify; validate against your change process ([[Change Management Overview and Lifecycle]]).

## Business application candidate agent

Proposes a business application (and related application service links) for application services. Properties `sn_sm_gen_ai.business_app_matching.*`:

| Property | Default | Meaning |
|---|---|---|
| `supported_app_service_classes` / `unsupported_app_service_classes` | empty | include / exclude application service subclasses |
| `app_service_skip_criteria`, `business_app_skip_criteria` | `operational_status=2` | encoded queries to skip |
| `sync_interval_in_seconds` | 604800 | data sync re-run |
| `batch_interval_in_seconds` / `retry_interval_in_seconds` | 3600 / 1800 | processing cadence, polling |
| `batch_size` | 1000 (cap 10,000) | services per run |
| `similar_max_entries` / `negative_feedback_max_entries` | 100 / 50 | AI context limits |
| `business_app_confidence_minimum_rating`, `relationship_confidence_minimum_rating` | 3 (1 to 5) | minimum confidence to propose |
| `auto_accept_confidence_minimum_rating` | empty | auto-accept above this (leave empty until trusted) |
| `use_all_user_groups_info` | false | include all user and group fields, not just managed by group |

Limits: 250,000 application services (above that the sync job sets itself *unsupported*); recommendations kept 2 years. Tables: `sn_sm_gen_ai_app_service_processing` (ready > in_progress > processed), `sn_sm_gen_ai_processing_entry`, `sn_sm_gen_ai_business_app_recommendation` (numbers BIZ...). Role `itil` for everything.

## Related

- [[Otto for CMDB Skills and Agentic Workflows]] · [[CI Relationships]] · [[Agentic AI Security and Governance]]
