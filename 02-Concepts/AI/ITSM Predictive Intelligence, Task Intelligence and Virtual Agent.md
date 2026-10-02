---
type: concept
tags: [concept, ai, incident]
status: documented
source: ServiceNow Australia IT Service Management PDF, "ITSM MCP Server" (pp. 2588-2604), "ITSM Virtual Agent" and "ITSM Virtual Agent Lite" (pp. 2763-2861), "L1 IT Service Desk AI Specialist" (pp. 2862-2882), "Machine learning solutions for IT Service Management" (pp. 2883-2888), "Task Intelligence for ITSM" (pp. 3761-3787), read 2026-10-02 at overview depth: only the introductions and component lists were read
sn-release: Australia
verified:
updated: 2026-10-02
---

# ITSM Predictive Intelligence, Task Intelligence, Virtual Agent and AI workers

**In one line:** besides the generative skills in [[Otto for ITSM Skills and Agentic Workflows]], ITSM ships machine-learning predictions, a chatbot topic pack, an autonomous L1 "AI specialist" and an MCP server for external AI clients.

## Predictive Intelligence for Incident

Plugins `com.snc.incident.ml` (solution definitions *Similar Open Problems*, *Similar Open Change Requests*, inactive by default) and `com.snc.incident.ml_solution` (separate subscription, requested through Now Support); `com.snc.incident.mim.ml_solution` supplies similar incidents to the major incident workbench. Solutions are trained on the instance's own history and can be called from flows and scripts for categorisation and assignment. Change equivalents: [[Change Risk Calculation and Assessment]], [[Standard Change Catalog]].

## Task Intelligence for ITSM

Plugin `com.snc.itsm_ml_task`; no-code **Admin Console** (`com.sn_ti_admin`; tables `sn_ti_admin_*`). Models: **Incident Categorization** (predicts incident fields), **Similar Incidents**, **Similar open Change Requests for Incidents**, **Similar open Problems for Incidents**. Predictions appear as recommendations in the Service Operations Workspace side panel. Roles `sn_itsm_ml_task.ti_admin` / `ti_analyst` / `ti_user` (and `sn_ti_admin.tia_*`). Supported from Utah patch 5.

## ITSM Virtual Agent

Pre-built conversation topics for common IT requests, in web chat and messaging integrations, with hand-off to a live agent. Some topics need IntegrationHub spokes (Microsoft Teams, Exchange, Azure AD, Zoom...). NLU languages: English, German, French (also Canadian), Korean, Spanish, Brazilian Portuguese, Japanese, Italian, Dutch, Simplified Chinese. Topic messages are translated through `gs.getMessageLang()` and `sys_ui_message`. **ITSM Virtual Agent Lite** is the reduced set.

## L1 IT Service Desk AI Specialist

An "autonomous worker" assigned to a team: it is assigned incidents, investigates with knowledge and history, talks to the requester, resolves, and escalates to a human when confidence is low. Uses *incident service and category prediction* (Category, Subcategory, Service, Service Offering, Configuration Item from the descriptions). Roles: `sn_itsm_common.sn_service_desk_manager` (contains `sn_service_desk_agent`, `sn_aia.worker_manager`) onboards it. Property seen: `sn_itsm_aia.glide.ui.autoresolve.time`. Obtained through the account manager.

## ITSM MCP Server

Application `sn_itsm_mcp_server` (on `sn_mcp_server`): lets a Model Context Protocol client (the guide names Moveworks and Claude) work with the instance in natural language.

| For | Capabilities |
|---|---|
| Agents: incidents | read and update by number, assignees and groups, similar records, knowledge search and linking, Knowledge Graph questions |
| Agents: changes | search and aggregate, create / update / close, suggest model or template, state transitions, risk, approvals, tasks, data-quality evaluation |
| Requesters | create an incident (with knowledge deflection), check status of own incidents and requested items, escalate, comment (`sn_itsm_mcp_server.requester.*`) |
| On-call (inactive by default) | who is on call, own shifts, time off and coverage requests |

Activated by an administrator (`sn_mcp_server.admin`).

## Related

- [[On-Call Scheduling]] · [[Incident Management Overview and Lifecycle]]
