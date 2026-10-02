---
type: table
tags: [table, schema, task]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration", topics "Working with the Task table" and "Task table structure" (pp. 522-527), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# task

**Label:** Task (the guide also writes "Tasks")
**What it stores:** the base class for work records. It supplies the common fields and the task-driving features (approvals, assignment, SLAs, inactivity monitors, flows) to every table that extends it.
**Extends:** nothing (base class)
**Extended by:** `incident`, `problem`, `change_request`, [[planned_task]], `sc_req_item` and many more
**Extension model:** table per hierarchy: one physical `task` table holds every child record, told apart by `sys_class_name` ([[Table Extension and Extension Models]])

Tasks are not created on `task` itself (it carries the `extensions_only` attribute). Selecting **New** on `task.list` opens the **Task Interceptor**, which asks which child table to use.

## Key columns

| Label | Name | Type | Reference / choice | Meaning | Confidence |
|---|---|---|---|---|---|
| Number | `number` | string | | identifying number, generated on creation. **Display value** of every task table | documented |
| Short description | `short_description` | string | | human-readable title | documented |
| Description | `description` | string | | multi-line description of the work | documented |
| State | `state` | integer | choice | Pending, Open, Work in Progress, Closed Complete, Closed Incomplete, Closed Skipped. Applications override it with their own states (numeric values not given in the guide) | documented |
| Active | `active` | boolean | | whether work is still going on. Set only by application business rules (e.g. `incident autoclose` closes resolved incidents not updated for a day) | documented |
| Priority | `priority` | integer | choice | by default calculated from Impact and Urgency by the `calculatePriority` business rule. Lists colour-code it | documented |
| Escalation | `escalation` | integer | choice | Normal, Moderate, High, Overdue. Populated from SLAs. Lists colour-code it | documented |
| Assigned to | `assigned_to` | reference | `sys_user` | user who does the work. Default reference qualifier shows only users with the `itil` role; some child tables override it | documented |
| Assignment group | `assignment_group` | reference | group | named in the assignment rules topic; type not listed in the guide's field table | documented (name only) |
| Opened | `opened_at` | glide_date_time | | when a person first opened the record | documented |
| Created | `sys_created_on` | glide_date_time | | when the record was created | documented |
| Additional comments | `comments` | journal_input | | comments any user can add; shown in the activity stream | documented |
| Work notes | `work_notes` | journal_input | | notes only ITIL users can add and see | documented |
| Approval history | `approval_history` | journal | | history of approvals | documented |
| Watch list | `watch_list` | glide_list | `sys_user` | users notified on update. By default only Incident, Change and Service Catalog send these notifications | documented |
| Work notes list | `work_notes_list` | glide_list | `sys_user` | users notified when work notes are added. By default only Change, Problem and Service Catalog | documented |
| Time worked | `time_worked` | timer | | timer of how long the form has been open | documented |
| Task type | `sys_class_name` | sys_class_name | | the child class of the record | documented |
| Sys ID | `sys_id` | GUID | | unique record identifier | documented |

Other date fields mentioned by the reminder topic: **Due date**, **Follow up**, **Actual start** (`work_start`).

## Relations

- `assigned_to` -> `sys_user`
- [[reminder]].`Task` -> `task`: reminders for an active task
- Child tables share the physical table; their own columns are stored through storage aliases ([[sys_storage_alias]])

## Features every task table gets

- **Approvals**: manual or from approval rules (also usable on non-task tables).
- **Assignment**: [[Assignment Rules and Data Lookup Rules]].
- **Service levels**: SLAs track how long a task has been open.
- **Inactivity monitors**: notify when a task has not been touched for a set time.
- **Flows** (Workflow Studio): an automated process applied to tasks that match conditions.
- **Journal fields**: `comments` and `work_notes` feed the activity formatter. Journal fields are shown whether or not the table is audited.

## Gotchas

- **Changes to `task` apply to every child table.** Adding a field is low impact (hide it where unneeded); deleting one used across tables loses data. Use [[Dictionary Overrides]] for per-table differences.
- New choice values on a `task` choice list must be unique across the hierarchy.
- Fields created directly on `task` are never glommed with other columns.

## Related

- [[Table Extension and Extension Models]] · [[Order of Execution for Rules, Engines and Notifications]] · [[planned_task]]
