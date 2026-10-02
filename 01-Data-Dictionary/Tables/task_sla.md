---
type: table
tags: [table, sla, task, schema]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Service Level Management", topics "Task SLA table", "Installed with Service Level Management", script examples in "Add custom business rules to SLA" (pp. 3146, 3171-3173, 3201-3203), read 2026-10-02. Column names not printed in the guide are marked ?
sn-release: Australia
verified:
updated: 2026-10-02
---

# task_sla

**Label:** Task SLA
**Extends:** none stated (not a task)
**Purpose:** one row per SLA definition applied to one task: the running clock.

## Columns

| Label | Name | Type | Notes |
|---|---|---|---|
| Task | `task` | reference [[task]] | confirmed by script (`current.task`) |
| SLA definition | `sla` `?` | reference `contract_sla` | |
| Stage | `stage` `?` | choice | In progress, Paused, Completed, Cancelled (Breached / Achieved only in 2010 compatibility mode) |
| Has breached | `has_breached` `?` | boolean | replaces the legacy task field Made SLA (inverted) |
| Start time | `start_time` `?` | date/time | |
| Stop time | `end_time` `?` | date/time | |
| Breach time | `planned_end_time` | date/time | label Breach time = Planned end time; confirmed by script |
| Original breach time | `original_breach_time` `?` | date/time | as first calculated; add to the form |
| Actual elapsed time / percentage / time left | `duration` `?` / `percentage` `?` / `time_left` `?` | | 24x7, minus pauses |
| Business elapsed time / percentage / time left | `business_duration` `?` / `business_percentage` / `business_time_left` | | inside the schedule; the last two names appear in the property descriptions |
| Pause duration, Business pause duration | `pause_duration` `?`, `business_pause_duration` `?` | | written when a pause ends |
| Schedule, Time zone | `schedule` `?`, `timezone` `?` | | taken from the definition's sources |
| Target | `?` | choice | None, Response, Resolution |

## Related tables

| Table | Label |
|---|---|
| `contract_sla` | SLA Definition |
| `sla_condition_class` | SLA Conditions (condition rules) |
| `sla_repair_log`, `sla_repair_log_entry` | repair logs |
| `sla_breakdown_by_assignment` (extends `sla_breakdown_core`), `sla_breakdown_definition`, `sla_breakdown_definition_field`, `sla_definition_sla_breakdown` | breakdowns |
| `sla_timer_config`, `sla_timer_config_mapping` | timer configuration |
| `service_offering_sla` | Service Offering SLA |
| `ast_service` | Service Contract |

## Notes

- Only itil, `sla_admin`, `sla_manager` and admin can read task SLAs; end users cannot.
- Values are as of the last calculation, not live.

## Used in

- [[SLA Definitions and Task SLAs]] · [[SLA Engine, Repair, Timeline and Breakdowns]] · [[Database Views]]
