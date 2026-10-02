---
type: reference
tags: [reference, notifications, email, incident, change, problem, request]
status: documented
source: ServiceNow Australia Platform Administration PDF, "System notifications", topic "Baseline email notifications" (pp. 2517-2529), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Baseline email notifications and events

The base system ships these notifications (not an exhaustive list; applications add their own). Each is triggered by an **event**, usually fired by a business rule named in the last column. Navigation: **System Notification > Email > Notifications**. Concepts: [[Email Notifications]], [[Events and the Event Queue]].

## Incident

| Notification | Event | Fired by |
|---|---|---|
| Incident Opened (for the caller, opened by someone else) | `incident.inserted` | incident events |
| Incident Opened & Unassigned (ITIL template) | `incident.inserted` | incident events |
| Incident Commented (ESS template, to the opener) | `incident.commented` | incident events |
| Incident Commented (ITIL template, to the assignee) | `incident.commented` | incident events |
| Email assigned to (assigned to you) | `incident.assigned` | incident events |
| Email assigned To Group | `incident.assigned.to.group` | incident events |
| Incident Resolved (feedback requested) | `incident.updated` | incident events |
| Incident Closed | `incident.updated` | incident events |

## Change, change task, problem, problem task

| Notification | Event |
|---|---|
| Change approved / rejected | `change.approved` / `change.rejected` |
| Change assigned to me / to my group | `change.assigned` / `change.assigned.to.group` |
| Change commented (to assignee or unassigned) | `change.commented` |
| Change worknoted (to assignee or unassigned) | `change.worknoted` |
| Notify Change Calendar / Remove (meeting invitation) | `change.calendar.notify` / `change.calendar.notify.remove` |
| Change Task assigned to me / my group | `change_task.assigned` / `change_task.assigned.to.group` |
| Change Task worknoted | `change_task.worknoted` |
| Problem worknoted (to assignee or unassigned) | `problem.worknoted` |
| Problem Task assigned to me / my group | `problem_task.assigned` / `problem_task.assigned.to.group` |
| Problem Task worknoted | `problem_task.worknoted` |
| Task approved | `task.approved` |
| Unscheduled Change (a CI changed with no active change) | `cmdb.unscheduled.change` |

"Unassigned" variants go to the assignment group; "to assignee" variants to the assigned person.

## Approvals and catalog

| Notification | Event |
|---|---|
| Approval Request (reply links to approve or reject) | `approval.inserted` |
| Approval Rejected / Rejected by Other | `approval.rejected` / `approval.rejected.by.other` |
| Catalog Approval Request | `request.approval.inserted` |
| Catalog Approval Rejected / cancelled | `request.approval.rejected` / `request.approval.cancelled` |
| Request Approved / Assigned / Completed | `sc_request.approved` / `sc_request.assigned` / `sc_request.updated` |
| Request Opened on Behalf | `sc_request.requested_for` |
| Request Item Assigned / Delivery | `sc_req_item.assigned` / `sc_req_item.delivery` |
| Email assigned to / to group (sc_task) | `sc_task.assigned.to.user` / `sc_task.assigned.to.group` |

The `sc_task.assigned.to.user` notification is from the legacy delivery plans; with a workflow it needs `work_start` set by a Set Values activity.

## Knowledge, reminders, system

| Notification | Event |
|---|---|
| Knowledge Closed Created / Duplicate / Invalid | `kb.submission.closed_created` / `closed_duplicate` / `closed_invalid` |
| Appointment Invite / Update (meeting invitation) | `itil_appointment.inserted` / `itil_appointment.updated` |
| Reminder Insert / delete (calendar) / Reminder Insert Email | `reminder.notify` / `reminder.notify.delete` / `reminder.notify.email` |
| Certificate Expiring / Expired | `certificate.expiring` / `certificate.expired` |
| Reset Password | `reset.password` |
| Scheduled Import Completed | `scheduled_import_set.completed` |
| System Upgraded | `system.upgraded` |
| Text Index Completed | `text_index.complete` |
| Change Notification (label) | `label.notify` |

Some events are fired by platform code rather than a business rule and are not configurable.

## Related

- [[Email Notifications]] · [[Create an Email Notification]]
