---
type: table
tags: [table, problem, task, schema]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Problem Management", topics "Problem Task form", "Map problem task states", "Create a problem task" (pp. 3015-3016, 3052-3054, 3081-3083), read 2026-10-02. Column names not printed in the guide are marked ?
sn-release: Australia
verified:
updated: 2026-10-02
---

# problem_task

**Label:** Problem Task
**Extends:** [[task]]
**Purpose:** a unit of work under a problem, numbered PTASK, used by the problem coordinator to get help from subject matter experts.

## Own columns

| Label | Name | Type | Notes |
|---|---|---|---|
| Source problem | `problem` | reference [[problem]] | |
| Type | `problem_task_type` `?` | choice | Root Cause Analysis, General (read-only after creation) |
| Problem task model | `prb_task_model` | reference `prb_task_model` | set through the interceptor URL |
| Close code | `close_code` `?` | choice | Complete, Canceled |
| Canceled reason | `?` | | asked on Cancel |
| Cause code | `?` | choice | Environmental disaster, Hardware issue, People/Process/Documentation... |
| Workaround, Proposed fix notes | `?` | | Root Cause Analysis tasks only |
| Close notes | `close_notes` (on task) | | General tasks only |
| Completed by / Completed | `?` | | |

## State values

| Value | Label |
|---|---|
| 151 ✔ | New |
| 152 `?` | Assess |
| 154 ✔ | Work in Progress |
| 157 ✔ | Closed |

✔ = value printed in the migration mapping table. Legacy: -5 Pending, 1 Open, 2 Work in Progress, 3 Closed Complete, 4 Closed Incomplete, 7 Closed Skipped.

## Behaviour

- Actions: **Assess**, **Start Work**, **Re-assess**, **Cancel**, **Complete**.
- Open tasks are canceled when the problem closes (`problem.closed.cancel_open_tasks`).
- The coordinator is notified when all tasks are completed or canceled; findings are copied to the problem by hand.

## Used in

- [[Problem Management Overview and Lifecycle]]
