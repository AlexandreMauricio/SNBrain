---
type: concept
tags: [concept, change, forms-lists]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Change Management", topics "Change schedules" and subtopics, "Installed with Change Management - Change Schedule" (pp. 565-571, 609-618), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Change schedules timeline

**In one line:** a change schedule is a saved Gantt view of change requests (plus related tasks, blackout and maintenance windows) defined by a filter and a start and end date field.

Plugin `com.snc.change_management.soc`. Menu **Change > Schedules > Change Schedules** (landing page with **Pinned**, **Your**, **All Schedules**).

## Definition (`chg_soc_definition`)

| Field | Purpose |
|---|---|
| **Start date field**, **End date field** | which change fields draw the span (must differ) |
| **Condition** | which changes, and their order |
| **Left / Right column fields** | content of the pop-up when a span is selected |
| **Show blackout / maintenance window** + colours | only for the change's primary CI |
| **Share with**, **Owner**, **Group Owner** | unshared schedules are visible to owner, owner group and admins |
| Related Definitions (`chg_soc_definition_child`) | child records to draw under each change, for example change tasks: **Table name**, **Reference field**, date fields, condition |
| Style Rules | span colour by condition |

Style rules exist at three levels: default (`chg_soc_style_rule`, **Change > Schedule > Default Style Rules**), per definition (take precedence), and ad hoc from the timeline. Defaults: Risk High red, Moderate orange, Low green; blackout grey, maintenance light blue.

An itil user can create, copy and view; only the owner (or `sn_chg_soc.change_soc_admin`) edits or deletes.

## Limits

`sn_chg_soc.change_soc_initial_limit` (40), `sn_chg_soc.change_soc_scroll_load_limit` (20), `sn_chg_soc.change_soc_total_limit` (1000), `sn_chg_soc.schedule_window_days` (30).

## Related

- [[Change Conflict Detection and Maintenance Schedules]]
