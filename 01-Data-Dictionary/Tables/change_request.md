---
type: table
tags: [table, change, task, schema]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Change Management", topics "Create a change request", "Legacy State model and transitions", "Update change request states", "Change Management properties" (pp. 561-563, 652-653, 659-666, 738-741), read 2026-10-02. Column names not printed in the guide are marked ?
sn-release: Australia
verified:
updated: 2026-10-02
---

# change_request

**Label:** Change Request
**Extends:** [[task]]
**Purpose:** one row per change: a controlled addition, modification or removal of a CI or service.

## Own columns

| Label | Name | Type | Notes |
|---|---|---|---|
| Requested by | `requested_by` `?` | reference `sys_user` | gets the state-change notification |
| Category | `category` | choice | Hardware, Network, Software... |
| Model | `chg_model` `?` | reference change model | |
| Type | `type` | choice | `normal`, `standard`, `emergency` (values lowercase per the guide's example `type=expedited`); read-only, shows *Model* if the model has no type. ACL `change_request.type` allows editing only in New with no approvals |
| Risk | `risk` | choice | High, Moderate, Low; default None |
| Impact | `impact` (on task) | choice | |
| Conflict status | `conflict_status` `?` | choice | Conflict, No Conflict, Not Run |
| Conflict last run | `conflict_last_run` `?` | date/time | |
| Planned start date / Planned end date | `start_date` `?` / `end_date` `?` | date/time | required for conflict detection |
| Actual start / end | `work_start` `?` / `work_end` `?` (on task) | date/time | filled during Implement |
| Justification, Implementation plan, Risk and impact analysis, Backout plan, Test plan | `justification` `?`, `implementation_plan` `?`, `risk_impact_analysis` `?`, `backout_plan`, `test_plan` (`change_plan` also in the copy list) | string | Planning tab |
| CAB required, CAB date, CAB delegate, CAB recommendation | `cab_required` `?`, `cab_date` `?`, `cab_delegate` `?`, `cab_recommendation` `?` | | CAB date is set from the meeting start time |
| Unauthorized | `unauthorized` `?` | boolean | emergency changes only |
| On hold / On hold reason | `on_hold` / `on_hold_reason` | boolean / string | |
| Close code | `close_code` | choice | `successful`, `successful_issues`, `unsuccessful` |
| Close notes | `close_notes` (on task) | | |
| Outside maintenance schedule | `outside_maintenance_schedule` `?` | boolean | informational, set by the system |
| Exclude from conflict detection | `?` | boolean | add to the form to use |
| Mass update CI class | `?` | boolean | plugin Mass Update CI |
| Risk and compliance category / attributes | `?` / `risk_and_compliance_attributes` | dynamic category / JSON | [[Dynamic Schema]] namespace `change_request/risk_and_compliance_attributes` |

Columns confirmed by the copy property default: `category, cmdb_ci, priority, risk, impact, type, assignment_group, assigned_to, short_description, description, change_plan, backout_plan, test_plan`.

## State values

| Value | Label | Can cancel |
|---|---|---|
| -5 | New | yes |
| -4 | Assess | yes |
| -3 | Authorize | yes |
| -2 | Scheduled | yes |
| -1 | Implement | yes |
| 0 | Review | no |
| 3 | Closed | no |
| 4 | Canceled | |

Pre-Geneva labels for the same values: -5 Pending, 1 Open, 2 Work in Progress, 3 Closed Complete, 4 Closed Incomplete, 7 Closed Skipped.

## Related tables

- [[change_task]] (`change_task.change_request`)
- `task_ci` (Affected CIs), `task_cmdb_ci_service` (Impacted Services/CIs), `task_service_offering`
- `conflict` (detected conflicts), `cmn_schedule_blackout`, `cmn_schedule_maintenance`
- `incident.rfc` (Incidents Fixed by Change), `incident.caused_by` (Incidents Caused by Change), `problem` via `change_request.parent`
- `sysapproval_approver` (approvals), `cab_agenda_item`
- `risk_conditions`, `change_risk_asmt`
- `std_change_proposal` `?`, `std_change_template_candidate`

## Used in

- [[Change Management Overview and Lifecycle]] and the notes linked from it
