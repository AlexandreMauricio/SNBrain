---
type: how-to
tags: [how-to, change, sla]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Change Management", topics "Create blackout and maintenance schedules in Change Management", "Assign a maintenance schedule to configuration items" (pp. 630-633), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Create a blackout or maintenance schedule

**Goal:** have conflict detection warn when a change is planned inside a freeze period, or outside the allowed maintenance window.
**Prerequisites:** role `itil_admin` or admin. Plugin Change Management - Collision Detector.
**Navigation:** All > Change > Schedules > Blackout Schedules (or Maintenance Schedules)

## Steps

1. Select **New**. Fill **Name**, **Time zone**.
2. **Source**: *CI Class* (then **Applies to** = the class, optional **Condition**), *Service*, or *Change Request* (condition on changes).
3. Save from the context menu.
4. In **Schedule Entries** select **New**: name, **When** (start and end), **Repeats** if recurring. Submit.
5. Optional: add a **child schedule** to narrow the window for a subset.

## Result / how to check it worked

Create a change on a matching CI with planned dates inside the blackout (or outside the maintenance window), open the **Conflicts** tab and select **Check Conflicts**: a row of type *Blackout* (or *Not in Maintenance Window*) appears and **Conflict status** is Conflict.

## Example

| Field | Value |
|---|---|
| Name | Example year-end freeze |
| Source | CI Class |
| Applies to | Server |
| Schedule entry | 20 December 00:00 to 5 January 23:59, repeats yearly |

## Tables / fields involved

- `cmn_schedule_blackout`, `cmn_schedule_maintenance`, `cmn_schedule_span` (entries), `conflict`, [[change_request]]

## Gotchas

- A business service must be converted to an **application service** to be used as the source.
- Related (dot-walked) fields in the condition are not evaluated.
- The matching property must be on (`change.conflict.blackout`, `change.conflict.currentwindow`).
- For one or two CIs, skip this and reference an ordinary schedule of type maintenance in the CI's **Maintenance schedule** field.
- Deleting the schedule deletes its entries and child schedules.
- Background: [[Change Conflict Detection and Maintenance Schedules]].
