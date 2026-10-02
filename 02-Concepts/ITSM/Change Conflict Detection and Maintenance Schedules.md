---
type: concept
tags: [concept, change, cmdb, sla]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Change Management", topics "Conflict detection" and subtopics, "Configuring maintenance schedules - Best practices" (pp. 625-639, 736-737), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Change conflict detection and maintenance schedules

**In one line:** conflict detection compares a change's CI and planned dates against other changes, blackout windows and maintenance windows, and writes the findings to the **Conflicts** tab.

Plugin Change Management - Collision Detector (`com.snc.change.collision`).

## What is a conflict

| Type | Meaning |
|---|---|
| CI Already Scheduled (also Parent / Child) | another active change on the CI, or on a CI related to it, overlaps |
| Not in Maintenance Window (also Parent / Child) | the planned dates fall outside the CI's maintenance window |
| Blackout | the planned dates fall in a blackout window |
| Assigned to already scheduled | the assignee has another change at that time (`change.conflict.assigned_to`) |

Needs **Configuration item** (or Affected CIs in advanced mode), **Planned start date**, **Planned end date**. Inactive changes are not considered. Result fields: **Conflict status** (Conflict, No Conflict, Not Run), **Conflict last run**; rows in table `conflict`.

## Running it

- Manually: **Conflicts** tab > **Check Conflicts** (role itil / `sn_change_write`). Cancelling the progress window clears the results.
- Automatically on save when CI, planned dates or state change (`change.conflict.refresh.conflicts`).
- Scheduled jobs (option *Enable the scheduled change conflict checker*): *Change Conflict Detection < 1 Week Away* daily, *< 1 Month Away* every 2 days, *>= 1 Month Away* weekly.
- Engine: `change.conflict.useprogressworker` false (default) = flow *Change - Conflict Detection* and table `chg_mgt_worker`; true = progress workers.
- **Exclude from conflict detection** (add the field to the form) removes a change from both sides of the check.

## Schedules

| Kind | Table | Menu |
|---|---|---|
| Blackout (no changes) | `cmn_schedule_blackout` | **Change > Schedules > Blackout Schedules** |
| Maintenance (changes allowed) | `cmn_schedule_maintenance` | **Change > Schedules > Maintenance Schedules** |

Both extend `cmn_schedule_condition`, which extends `cmn_schedule` ([[Schedules and Schedule Entries]]). Fields: **Name**, **Time zone** (*Floating* = the user's), **Source** (*Service* = an application service, *Change Request* = changes matching a condition, *CI Class* = a class and its children through **Applies to** + **Condition**), then schedule entries and optional child schedules. Role `itil_admin`.

Alternative for a few CIs: an ordinary schedule with **Type** = maintenance referenced in the CI's **Maintenance schedule** field (`change.conflict.ci_maint_sched`). Use the conditional schedules for rules covering many CIs; every extra conditional schedule slows detection.

Parents and children of the CI are checked through CMDB relationships, so a blackout on a service also catches changes on the CIs under it. The informational check box **Outside maintenance schedule** looks only at the primary and affected CIs.

## Properties (Change > Administration > Conflict Properties)

| Property | Checks / effect |
|---|---|
| `change.conflict.role` | roles allowed to use the feature |
| `change.conflict.mode` | *Basic* (primary CI only) or *Advanced* (primary and affected CIs; off after upgrade) |
| `change.conflict.currentci` | CI already scheduled |
| `change.conflict.blackout`, `.relatedparentblackout`, `.relatedchildblackout` | blackout on CI, parent, children |
| `change.conflict.currentwindow`, `.relatedparentwindow`, `.relatedchildwindow` | maintenance window on CI, parent, children |
| `change.conflict.ci_maint_sched` | the CI's own Maintenance schedule field |
| `change.conflict.relatedservices` | application services containing the CI |
| `change.conflict.assigned_to` | assignee double-booked |
| `change.conflict.populateimpactedcis`, `.identifymostcritical` | add conflicting services to Impacted Services |
| `change.conflict.next_available.schedule_window` (90 days), `.choice_limit` (100) | Scheduling Assistant search |
| `change.conflict.show_conflict_message` | User Preference / Always / Never |
| `change.conflict.allow_contiguous_changes`, `.consolidated_conflicts` | back-to-back changes; grouping of results |
| `change.conflict.max_count` | max conflict rows per type (minimum 1000; create if missing) |
| `change.conflict.log` | log level (default Notice) |

## Resolving

**Conflict Calendar** button (plugin `com.snc.change_request_calendar`) shows the change against other changes and windows; **Scheduling Assistant** proposes free slots within the next 90 days and **Select Available Time** rewrites the planned dates.

## Related

- [[Change Management Overview and Lifecycle]] · [[Create a Blackout or Maintenance Schedule]] · [[Change Schedules Timeline]]
