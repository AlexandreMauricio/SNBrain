---
type: reference
tags: [reference, roles, access-control, incident, problem, change, request]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Components installed with ITSM Roles" in the Incident, Problem, Change and Request Management chapters, "Installed with Business Stakeholder", "ITSM Enhanced Security Features" (pp. 557-560, 773, 3023-3027, 3122-3125), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# ITSM granular roles

**What it is:** the ITSM Roles plugin (`com.snc.itsm.roles`) adds read/write roles per process so that access need not be all-or-nothing through itil. Active on new instances since New York; upgraded instances must request it.

## Roles

| Role | Access | Contains |
|---|---|---|
| `sn_incident_read` | read all incidents and the major incident workbench | dependency_views, agent_workspace_user, view_changer, cmdb_read, cmdb_query_builder_read |
| `sn_incident_write` | write incidents | sn_incident_read, template_editor |
| `sn_problem_read` | read problems | |
| `sn_problem_write` | write problems | sn_problem_read, template_editor |
| `sn_change_read` | read all changes and the CAB workbench | sn_cmdb_user, dependency_views, view_changer, cmdb_read, app_service_user, cmdb_query_builder_read |
| `sn_change_write` | write changes | sn_change_read, template_editor, cmdb_query_builder |
| `sn_change_admin` | change configuration without global admin | sn_change_write, sn_change_cab.cab_manager, change_manager |
| `sn_request_read` | read requests and requested items **only when the user is an approver**; do not assign without `business_stakeholder` | |
| `sn_request_write` | write requests and requested items | task_editor, dependency_views, agent_workspace_user, view_changer, cmdb_read, cmdb_query_builder_read, sn_request_read |
| `sn_request_comment_write` | comment on requested items (also needs table write access) | |
| `sn_service_desk_agent` | tier 1 agent across the four processes | sn_incident_write, sn_problem_write, sn_change_write, sn_request_write, tracked_file_reader (plus knowledge_user, now_assist_panel_user with ITSM Gen AI) |
| `business_stakeholder` (plugin `com.snc.business_stakeholder`) | view and approve across ITSM | PA viewer, approver_user, cmdb_read, request and incident comment write |

Sub-plugins: `com.snc.itsm.roles.incident_management`, `.problem_management`, `.change_management`, `com.snc.service_management.roles.request_management`.

## Enhanced security

Plugin `com.snc.itsm.enhanced_security` (installed on new instances): deny-unless ACLs that block unauthenticated (public) access to the ITSM task tables.

## Related

- [[Base System Roles]] · [[Incident Management Overview and Lifecycle]] · [[Problem Management Overview and Lifecycle]] · [[Change Management Overview and Lifecycle]] · [[Request Management Data Model and Process]]
