---
type: concept
tags: [concept, change, release-specific]
status: documented
source: ServiceNow Brazil ITSM docs, Change Management > Change lockdown (overview, Create, Manage, Set the lockdown preview maximum, States, Lockdown conflict detection, Limit conflict detection to a change model state), read 2026-10-29. https://www.servicenow.com/docs/r/it-service-management/change-management/change-lockdown.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Change Lockdown

**In one line:** a **change lockdown** (base system, **Change > Administration > Change Lockdown**) is an approved freeze period that puts matching in-flight change requests **on hold** during a critical business, IT or financial event, and flags new or rescheduled changes inside it as conflicts.

From the Brazil docs; not in the Australia PDF; not tested. Complements blackout schedules ([[Change Conflict Detection and Maintenance Schedules]]): a blackout only reports conflicts, a lockdown also holds the changes.

## Record

Name, Description, Time zone (default *Floating*), **Filter by CI** (shows the **CI Condition** tab: method such as CI Class, **Applies to** table, default `cmdb_ci`, and Condition; unticked = all changes matching the change condition), **Change Request Condition** (which changes to hold), approval **group** and **user**, State (read only). It needs at least one **schedule entry** (All day, Repeat on, End date time, Float day, Float week) before it does anything.

## Life cycle

| State | Changes held | Actions |
|---|---|---|
| Draft | no | Preview (after a schedule entry exists), Update, Request Approval, Delete |
| Awaiting Approval | no | Preview, Revert to Draft, Cancel Lockdown, Delete |
| Enforced | yes: listed in **Schedule Lockdown Changes** with **On hold** true | Cancel Lockdown (releases them; a change on hold for another reason stays on hold) |
| Closed / cancelled | released | none; cannot be reverted or reused, create a new one |

**Preview** lists matched changes (number, short description, model, type, state, planned dates); the count shown is capped by `com.snc.change_management.lockdown.preview.max_changes` (`sn_change_admin`; the cap only limits the dialog, not what is held). Rejection returns it to Draft.

## Conflict detection

- New conflict type **Inside Change Lockdown**; property `change.conflict.lockdown` (shipped true) turns lockdown checking on.
- A change created or rescheduled inside an enforced period gets Conflict status *Conflict*, **On hold** true and an **On hold reason** naming the lockdown; moving it out of the period clears them on the next run.
- Runs when state, CI or planned dates change; with the model state attribute **Allow Conflict Detection** on one state, it runs only in that state.
- The scheduling assistant skips enforced lockdown periods.

## Example

Lockdown *Example Year-End Freeze*, change condition *Type is Normal*, Filter by CI on class *Example Payment Servers*, schedule entry 20 to 31 December, approval group *Example CAB*.

## Related

- [[Change Models and Change Templates]] · [[Change Management Overview and Lifecycle]]
