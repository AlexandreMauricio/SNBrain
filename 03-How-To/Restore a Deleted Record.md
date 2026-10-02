---
type: how-to
tags: [how-to, data-management, admin]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Roll back and delete recovery" (pp. 689-691), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Restore a deleted record

**Goal:** bring back a record that was deleted, with or without the records deleted along with it.
**Prerequisites:** role admin. Within seven days for full recovery.
**Navigation:** All > System Definition > Deleted Records, or All > Rollback & Recovery > Delete Recovery

## Steps: Deleted Records (audited tables)

1. Open **All > System Definition > Deleted Records** and open the deleted record. One record at a time.
2. Choose:
   - **Undelete With Related**: the record plus all cascaded deletes and other database actions caused by the delete (shown when a rollback context exists).
   - **Recover entire operation**: if this record went as part of a bigger delete, everything from that parent delete.
   - **Undelete Record**: only this record.
3. Read the instructions page and select **Restore deleted record**.

## Steps: Delete Recovery (any table)

1. Open **All > Rollback & Recovery > Delete Recovery** and select the entry.
2. Related link **Rollback...**.
3. Type `yes` in **Rollback entire operation** and select **OK**.

## Result / how to check it worked

A progress page counts restored references, then a **Restore Summary** lists the changes with a link to the restored record.

## Example

A test incident deleted yesterday with its child tasks: open it in Deleted Records and use **Undelete With Related** so the tasks return too.

## Tables / fields involved

- `sys_audit_delete`: deletions of audited tables
- `sys_rollback_context`: what makes the "with related" options possible

## Gotchas

- **Undelete Record performs an insert, so business rules can fire** and cause extra inserts and updates elsewhere.
- Tables with `no_audit_delete=true` and many `sys_` tables are not tracked.
- After seven days, cascaded deletes can no longer be recovered.
- Background: [[Rollback and Delete Recovery]].
