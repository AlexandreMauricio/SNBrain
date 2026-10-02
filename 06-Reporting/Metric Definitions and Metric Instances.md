---
type: concept
tags: [concept, reporting, task, scripting]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Metrics" (pp. 2746-2749), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Metric definitions and metric instances

**In one line:** a metric definition watches one field of a table and records, as the data changes, how long each value lasted (or a scripted value), in `metric_instance`; this captures history that a plain report on the table cannot.

## Why

"How many incidents were created today" is a report on the table. "How long was each incident assigned to each group" needs the history of changes: that is a metric.

## Pieces

| Piece | Table | Holds |
|---|---|---|
| Metric definition | `metric_definition` | **Name**, **Table**, **Field**, **Type**, **Timeline**, **Active**, **Script** |
| Metric instance | `metric_instance` | **Definition**, **ID** (the record measured), **Value** (the field value measured, e.g. the assignee), **Duration**, start/end, `calculation_complete` |

Types:

- **Field value duration**: time from when the field gets a value until it changes. One instance per value. Optional script can set `answer = false` to stop (the baseline incident metrics stop when **Active** becomes false) and can close other open durations with `mi.endDuration()`.
- **Script calculation**: the script computes anything and inserts the `metric_instance` row itself.

## Rules

- Plugin Metric Definition (`com.glide.metrics`). Role `metric_admin`. Module **Metrics > Definitions**. Not the same thing as Assessment metrics.
- **No back-fill**: a definition only measures changes after it was created.
- Works on **audited** fields only; unaudited fields give unreliable values. Fields starting with `sys_` do not work (except `sys_domain`).
- Baseline only fires on [[task]] tables, through the *metric events* business rule. For `cmdb_ci` tables, copy that business rule to the CI table.
- One table per definition.

## Example

Definition *Assigned to Duration*: table Incident, field **Assigned to** (`assigned_to`), type Field value duration. Each reassignment closes one instance and opens another; **Value** holds the assignee's name.

## Reporting on it

Join `metric_instance` to the measured table with a database view (the base system ships `incident_metric`), then report on the view. See [[Database Views]].

## Related

- [[Create a Database View]] · [[task]]
