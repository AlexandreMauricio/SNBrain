---
type: concept
tags: [concept, data-management, platform, admin]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Data Management" (pp. 620-624, 637-642), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Update jobs, delete jobs and one-time delete rules

**In one line:** these let an admin change or delete many records without a script, with a preview of what will be touched and a rollback afterwards.

## The three tools

| Tool | Where | Does |
|---|---|---|
| **Update job** | **System Data Management > Update Jobs**, or list header context menu **Data Management > Update All with preview** | sets one or more fields on every matching record |
| **Delete job** | **System Data Management > Delete Jobs**, or **Data Management > Delete All with preview** | deletes matching records |
| **One-time delete rule** | Data Management Console, **Create rule**, type **One-time delete** | same as a delete job, built in the console wizard, runs once now or at a set time |

Recurring deletion is the job of [[Table Cleaner]] rules, not these.

## Shared behaviour

- Pick the table, add conditions, **Preview** the matching records.
- Run now (**Execute Now**) or set **Run at** and **Update** to schedule. Prefer non-business hours.
- **Rollback** related link on an executed job restores the previous state.
- Limiting the number of records helps avoid locking the table.

## Delete specifics

- Deleting cascades: records in tables that extend or reference the source go too, **up to three levels** (incidents, problems referencing them, defects referencing those problems, test records referencing the defects).
- **Preview Cascade** shows counts per table; counts for other tables are close estimates. Attachments (`sys_attachment`, `sys_attachment_docs`) may not show in the preview but are deleted.
- One-time delete rules create a rollback context by default; **you have up to fourteen days to roll back**. Option **Run business rules and engines**. The summary page needs an acknowledgment.
- Deleting *all* records of a table locks it for inserts and updates: use a cleanup rule instead.

## Update specifics

- On MariaDB, an UPDATE that touches most rows can take gap locks and escalate to a full table lock until it finishes (inserts are not affected).

## Related

- [[Bulk Update or Delete Records with a Job]] · [[Approaches to Deleting Many Records]] · [[Data Management Overview]]
