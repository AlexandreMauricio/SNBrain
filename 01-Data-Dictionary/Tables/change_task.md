---
type: table
tags: [table, change, task, schema]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Change Management", topics "Create a change task", "Place a change request on hold", "Copy a change request" (pp. 668-670, 680-681), read 2026-10-02. Column names not printed in the guide are marked ?
sn-release: Australia
verified:
updated: 2026-10-02
---

# change_task

**Label:** Change Task
**Extends:** [[task]]
**Purpose:** a piece of work under a change request (plan, implement, test, review).

## Own columns

| Label | Name | Type | Notes |
|---|---|---|---|
| Change | `change_request` `?` | reference [[change_request]] | change the value to move a task to another change |
| Type | `change_task_type` `?` | choice | Planning, Implementation, Testing, Review |
| Planned start / end date | `planned_start_date` `?` / `planned_end_date` `?` | date/time | Implementation tasks must fall inside the change's planned dates |
| On hold / On hold reason | `on_hold` / `on_hold_reason` | | follows the change request |
| Close code / Close notes | `close_code` / `close_notes` | | required before Closed |
| Created from | `created_from` | choice | `manual` (default) or `workflow`; only manual tasks are copied by **Copy Change** |

## States

Pending, Open, In progress, Closed, Canceled. A closed task cannot be reopened.

## Behaviour

- Moving the change to **Implement** creates two tasks: *Implement* and *Post-implementation testing*.
- Moving to **Review** cancels open flow-created tasks; manually created tasks must be closed by hand before the change can close.
- Cancelling the change cancels all active tasks.
- Putting the change on hold puts all active tasks on hold with the same reason; taking it off hold releases them, except tasks that were put on hold manually.
- Approved unauthorized change: a task *Post Implementation Review* is created for the Change Management group.

## Used in

- [[Change Management Overview and Lifecycle]]
