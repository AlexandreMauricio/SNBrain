---
type: reference
tags: [reference, ai, integrations, api, incident, change]
status: documented
source: ServiceNow Australia IT Service Management PDF, "ITSM MCP Server" (pp. 2588-2605), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# ITSM MCP Server

**What it is:** a Model Context Protocol (MCP) server shipped by ServiceNow (`sn_itsm_mcp_server`) that lets an external AI client (the guide names Moveworks and Claude) read and act on incidents, changes, the caller's own tickets and on-call schedules in the instance, under the connected user's roles.

## Activation

Plugins: ServiceNow Otto for ITSM (`sn_itsm_gen_ai`), Model Context Protocol Server (`sn_mcp_server`), ITSM MCP Server (`sn_itsm_mcp_server`). Role `sn_mcp_server.admin` or admin.

1. **All > MCP Server Console > Configuration > Servers > ITSM MCP Server** (application scope *ITSM MCP Server*).
2. **Auth scope** = `a2aauthscope` (lets the REST A2A protocol reach the AI agent MCP tools).
3. **Activate** (inactive by default). Activation exposes every registered tool to connected clients and creates an OAuth client entry named after the integration (`sn_itsm_mcp_server.itsm_default`).
4. Connect the client with OAuth (authorization code grant): use the generated entry, or your own (`oauth_admin`). Never store the client secret in notes: `<CLIENT_ID>`, `<CLIENT_SECRET>`.

The server authenticates each request against the instance's role-based access; answers contain only what the user may see. Updates go through platform APIs with business rules running. If tools other than those below appear in the definition, resolve the upgrade's skipped records.

## Tools

All names are prefixed `sn_itsm_mcp_server.`.

### Incident (fulfillers)

| Tool | Does | Role |
|---|---|---|
| `incident.get_details` | state, priority, assignment, CI, description, work notes | `sn_incident_read` |
| `incident.search_similar` | semantic search for similar incidents, ranked | `sn_incident_read` |
| `incident.search_similar_kb` | active, published knowledge articles for a `query` or an `incident_number` | `sn_incident_read` |
| `incident.get_kb_details` | one published article by number or sys_id | `sn_incident_read` |
| `lookup_assignment_groups`, `lookup_users` | groups and members; users by name, role, group | `sn_incident_read` |
| `incident.modify` | work notes, comments, assignee, assignment group | `sn_incident_write` |
| `incident.attach_kb` | links an article to an incident | `sn_incident_write` |

itil gets all of them.

### Change (role itil)

| Tool | Operations (required `operation` parameter) |
|---|---|
| `change.lifecycle` | `create` (from model, template or type), `update` (fields, state transition, journal), `calculate_risk` (including the assessment questionnaire), `upsert_task`, `planned_outage` |
| `change.analyze` | `suggest_assignment_groups`, `get_risk_and_impact_data` (risk score and blast radius), `suggest_cis`, `suggest_models_and_templates` |
| `change.query` | `read`, `search`, `similar_change_and_issues` (needs incident read), `aggregate_by`, `get_state_info` (current state, valid next transitions, mandatory fields), `check_schedules_and_conflicts`, `data_quality` |
| `change.relation` | `list_tasks`, `list_affected_cis`, `list_approvals`, `list_incidents`, `list_problems`, `list_outages`, `list_change_policies` |
| `task_approval_decision` | approve or reject the caller's oldest pending approval on a change or requested item |

Custom change fields are exposed by overriding `getCustomFields` in script include `ITSMMCPChangeCustomFields` (extends `ITSMMCPChangeCustomFieldsSNC`; server-side) to return the column names, for example `['u_environment_type']`. Ships empty.

### Requester (any authenticated user, own tickets only)

| Tool | Does |
|---|---|
| `requester.create_incident` | guided: knowledge deflection, catalog item redirection, duplicate detection, then creation; returns an incident or requested item number |
| `requester.check_status` | incident or RITM by number or description ("my VPN ticket") |
| `requester.escalate` | raises **Urgency** one level with a mandatory reason; refused if already High, if Resolved / Closed / Canceled, or if escalated in the last 24 hours |
| `requester.add_comment` | customer-visible comment; not on closed or canceled tickets; no work notes |

### On-call (inactive by default)

Roles itil, `roster_admin`, `rota_admin`, `rota_manager` or `oc_read` (extend with property `com.snc.on_call_rotation.calendar_read_roles`).

| Tool | Does |
|---|---|
| `oncall.on_call_lookup` | `who_is_on_call` by group or shift; `my_next_shift` (one entry per roster the user is on) |
| `oncall.timeoff_request` | two phases: `analyze` (read-only: affected groups, PTO policy, who can cover, conflicting requests) then `create`, only after the user confirms |

### Common

| Tool | Does |
|---|---|
| `itsm_knowledge_graph` | answers structured natural-language questions: incidents and changes not Closed Complete, active catalog and request items |
| `get_session_timezone` | the user's session time zone and current time; to be called before interpreting dates |
| `task_approval_decision` | see above |

## Related

- [[Otto for ITSM Agentic Workflows and AI Agents Reference]] · [[On-Call Scheduling]] · [[Change Management Overview and Lifecycle]]
