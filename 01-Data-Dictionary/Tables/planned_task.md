---
type: table
tags: [table, schema, task]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration", topic "Extending the Task table with Planned tasks" (pp. 533-540), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# planned_task

**Label:** Planned Task
**What it stores:** tasks that are part of a planned, multi-stage process (projects, releases), adding duration, effort, cost and hierarchy fields to Task.
**Extends:** [[task]]
**Extended by:** project and release tables (records are created on the child tables through the Planned Task Interceptor)
**Plugin:** Planned Task; cannot be activated alone, it comes with Project Management (PPM Standard)

## Key columns

| Label | Name | Type | Reference / choice | Meaning | Confidence |
|---|---|---|---|---|---|
| Planned start date | `start_date` | glide_date_time | | estimated start | documented |
| Planned end date | `end_date` | glide_date_time | | estimated end; calculated from planned start (or actual start if present) plus planned duration | documented |
| Planned duration | `duration` | glide_duration | | estimated elapsed time from start to end | documented |
| Planned effort | `effort` | glide_duration | | estimated working time | documented |
| Actual start date | `work_start` | glide_date_time | | when work really started | documented |
| Actual end date | `work_end` | glide_date_time | | when work really ended | documented |
| Actual duration | `work_duration` | glide_duration | | elapsed time so far | documented |
| Actual effort | `work_effort` | glide_duration | | time actually worked | documented |
| Remaining duration | `remaining_duration` | glide_duration | | planned minus actual duration | documented |
| Remaining effort | `remaining_effort` | glide_duration | | planned minus actual effort | documented |
| Percent complete | `percent_complete` | decimal | | manual on a child task; rolled up on a parent | documented |
| Estimated cost | `cost` | currency | | estimate | documented |
| Actual cost | `work_cost` | currency | | actual | documented |
| Rollup | `rollup` | boolean | | system-managed: the task has children, so its rolled-up fields are read-only | documented |
| Top task | `top_task` | reference | `planned_task` | the highest ancestor in the hierarchy (blank on the top task itself) | documented |
| Critical path | `critical_path` | boolean | | no description in the guide | documented (name only) |
| Time constraint | `time_constraint` | string | | description of time constraints | documented |
| HTML description | `html_description` | html | | description with markup | documented |

**Duration** is calendar time from start to end; **effort** is hours of work.

## Rollup

- Parent percent complete = sum(child planned duration x child percent complete) / sum(child planned duration).
- Planned and actual dates of children roll up to the parent automatically.
- Rolled up by default: cost, budget, effort, actual date, planned date, duration, percent complete.
- To include or exclude a field: open the **Planned task rollup** table (from **System Definition > Tables**, **Show List**), **New**, set **Child** table, **Field**, **Navigator** (the parent reference column), **Parent** table and the **Rollup** check box.

## Business rules that maintain it

Set actual work start value; Set close data on inactive; Recalculate (schedule fields); Planned task global events; Update parent actual effort / effort / percent complete; Validate duration (not zero or negative); Validate percent complete (0 to 100); Validate work end before work start; Set top task; Set top task on children.

## Other features

- **Baseline**: related link **Create a Baseline** on the top planned task records start and end times at that moment; viewable on a Gantt chart.
- **Task hierarchy**: a UI action (e.g. *Task hierarchy* on projects). To add it to another planned task table, copy one of the existing UI actions under **System UI > UI Actions** and change its table.
- All task dependency types are supported except external dependencies.

## Related

- [[task]] · [[Time Cards and Time Sheets]]
