---
type: concept
tags: [concept, change]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Change Management", topics "Change Advisory Board (CAB) workbench", "Working with the CAB Workbench" and subtopics (pp. 554, 695-715), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# CAB workbench

**In one line:** a CAB definition is a recurring meeting series with a board and an agenda filter; it generates CAB meetings whose agenda items are change requests, run and decided from the workbench.

## Records

| Record | Table | Key fields |
|---|---|---|
| CAB definition | `cab_definition` (extends `cmn_schedule`) | **CAB Manager**, **Delegates**, **Board Members / Groups**, **Rolling Meeting Window** (days ahead to generate), **Automatically Add Change Requests** + **Change Request Addition Conditions** (filter and sort), **Time per Agenda Item**, **Complete Pre-approved Changes**, **Auto Add Agenda Decisions**, **Notification lead time**; related lists **Schedule Entries**, **Related Schedules** (for example holidays to skip) |
| CAB meeting | `cab_meeting` | **State** (Pending, In progress, Complete, Canceled; set by the workbench), start/end, **Change Requests starting after / on or before**, **Meeting Notes** |
| Agenda item | `cab_agenda_item` | **Task** (change request, or standard change proposal since Australia), **Order**, **Decision**, **Allotted Time**, **Elapsed Time** |
| Attendee | `cab_attendee` | |

Menu: **Change > Change Advisory Board** (My CAB Definitions, My / All CAB Meetings, CAB Workbench). Role `sn_change_cab.cab_manager`; itil and `sn_change_read` can view and attend.

## Flow

1. Create the definition, add a schedule entry (for example weekly), save.
2. Related link **Refresh CAB Meetings** generates meetings and their agendas.
3. On a meeting: **Refresh Agenda Items**, **Send meeting request to attendees**, **Share notes**.
4. In the workbench the manager uses **Start meeting**, **Next**, **Pause**, **Promote**, **Demote**, **Restore**, **End meeting**; approvers get **Approve** / **Reject** on the current item; attendees can ask **Notify me** before their item.

Adding an agenda item sets **CAB date** on the change. Decisions are appended to the meeting notes as `(CAB Automation) - <number> - <decision> - <manager> - <time>`.

Property `sn_change_cab.com.snc.change_management.cab.use_sow_meeting`: open meetings in Service Operations Workspace (true on new instances; needs `sn_sow.sow_user`).

## Related

- [[Change Management Overview and Lifecycle]] · [[Change Approval Policies]] · [[Schedules and Schedule Entries]]
