---
type: table
tags: [table, schema, task, notifications]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration", topic "Reminder table" (pp. 526-527), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# reminder

**Label:** Reminder
**What it stores:** automatically sent reminders for a task, relative to one of the task's date fields. Works for any table that extends [[task]]. Open with `reminder.do`.

## Key columns

Column names are not given in the guide.

| Label | Name | Meaning | Confidence |
|---|---|---|---|
| Task | ? | the parent task (must be active) | documented |
| User | ? | the user the reminder is for | documented |
| Remind me | ? | how long before: 15 minutes, 30 minutes, 1 hour, 2 hours (more can be added). Stored in minutes | documented |
| Before | ? | which date field on the task: **Due date** or **Follow up**. The task must have a value in it | documented |
| Using | ? | Send an Email, or Outlook Calendar | documented |
| Subject | ? | up to 100 characters | documented |
| Notes | ? | up to 8,000 characters | documented |

## Gotchas

- Only administrators can create or edit reminders by default. For others, add create and read ACLs on the table.
- **Activity due** and **SLA due** appear in **Before** but are legacy and unusable.
- To use another date field: save with Due date or Follow up, then edit **Before** from a list view and type the field name (e.g. `work_start` for Actual start). The form then cannot be edited further unless Before is set back.
- Show reminders on a task form with **Configure > Related Lists**, add **Reminders->Task**.

## Related

- [[task]]
