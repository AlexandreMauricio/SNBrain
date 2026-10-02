---
type: table
tags: [table, incident, task, schema]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Incident Management", topics "Create an incident", "Resolve and close an incident", "Reopening an incident", "View major incident information on the Incident form", "Create a UI action to close multiple incidents" (pp. 2459-2463, 2487-2495, 2517-2518), read 2026-10-02. Column names not printed in the guide are marked ?
sn-release: Australia
verified:
updated: 2026-10-02
---

# incident

**Label:** Incident
**Extends:** [[task]] (inherits number, state, priority, assignment, journals, and so on)
**Extended by:** none in the base system
**Purpose:** one row per incident: an unplanned interruption or degradation that the service desk must restore.

## Own columns (not inherited from task)

| Label | Name | Type | Notes |
|---|---|---|---|
| Caller | `caller_id` | reference `sys_user` | who has the issue. Optional when created from an alert or a change |
| Category | `category` | choice | Inquiry / Help, Software, Hardware, Network, Database |
| Subcategory | `subcategory` | choice | depends on Category |
| Service | `business_service` (on task) | reference `cmdb_ci_service` | |
| Service offering | `service_offering` (on task) | reference `service_offering` | |
| Configuration item | `cmdb_ci` (on task) | reference `cmdb_ci` | the single causing CI; others go in Affected CIs |
| Channel | `contact_type` (on task) | choice | Chat, Email, Phone, Monitoring, Self-service, Virtual agent, Walk-in |
| Origin | `?` | | auto-filled source (for example Alert); not editable |
| Impact / Urgency | `impact` / `urgency` (on task) | choice | 1 High, 2 Medium, 3 Low; determine Priority |
| On hold reason | `hold_reason` `?` | choice | Awaiting Caller, Awaiting Change, Awaiting Problem, Awaiting Vendor |
| Resolution code | `close_code` | choice | see below |
| Resolution notes | `close_notes` (on task) | string | |
| Resolved by | `resolved_by` | reference `sys_user` | |
| Resolved | `resolved_at` | date/time | used by auto-close and SLA reports |
| Parent Incident | `parent_incident` | reference `incident` | child incidents |
| Problem | `problem_id` | reference `problem` | |
| Change Request | `rfc` | reference `change_request` | change that will fix it |
| Caused by Change | `caused_by` | reference `change_request` | change that caused it |
| Reopen count | `reopen_count` | integer | |
| Last reopened by / at | `reopened_by` `?` / `reopened_time` `?` | | filled when a resolved incident is reopened |
| Reassignment count | `reassignment_count` (on task) | integer | |
| Major incident state | `major_incident_state` `?` | choice | Proposed, Accepted, Rejected, Canceled (plugin Major Incident Management) |
| Proposed by / Proposed, Promoted by / Promoted | `?` | | major incident audit fields |
| Business impact, Probable cause | `?` | string | major incident tab |
| Actions taken | `?` | journal | internal journal for major incidents |
| Universal Request | `universal_request` | reference | only with the Universal Request integration |

## State values

| Value | Label |
|---|---|
| 1 | New |
| 2 | In Progress |
| 3 | On Hold |
| 6 | Resolved |
| 7 | Closed |
| 8 | Canceled |

Only **7 = Closed** appears literally in this guide (script `setValue('state', 7)`); the others are the standard values of the core state model and should be confirmed with a `sys_choice` query on an instance. The legacy `incident_state` field is described in [[State Fields and Task State Values]].

## Resolution codes named in the guide

Solved (Work Around), Solved (Permanently), Solved Remotely (Work Around), Solved Remotely (Permanently), Not Solved (Not Reproducible), Not Solved (Too Costly), Closed/Resolved by Caller. With the best-practice plugins: Known error, Duplicate. Stored value equals the label in the guide's script.

## Related tables

- [[incident_task]]: work items under an incident
- `task_ci` (Affected CIs), `task_cmdb_ci_service` (Impacted Services/CIs), `task_service_offering`, `task_cmdb_ci_business_app`
- `incident_alert` / `incident_alert_task`: incident communication plan and tasks
- `task_outage`, `cmdb_ci_outage`: outages
- `kb_template_incident_kcs_article`: knowledge created from incidents
- `major_incident_trigger_rule`

## Used in

- [[Incident Management Overview and Lifecycle]] · [[Major Incident Management]] · [[Incident Properties Reference]]
