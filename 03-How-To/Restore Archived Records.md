---
type: how-to
tags: [how-to, data-management, admin]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Data Management" (pp. 624-625, 634), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Restore archived records

**Goal:** bring archived records, and optionally their related records, back into the primary table.
**Prerequisites:** role admin.
**Navigation:** All > System Data Management > Data Management Console, or All > System Archiving > Archive Log

## Steps (console, one or many records)

1. Open the console, **Tables** tab, and find the table (status **Archive**).
2. Select **View records**.
3. Select the records, then **Actions on selected rows > Restore Selected**, or use the related link **Restore All Records Matching Conditions**.
4. Confirm the **Bulk Restore Request Success** dialog.

## Steps (Core UI, one record)

1. Open **All > System Archiving > Archive Log** (or go through the policy: Archive Rules, the rule, Archive Run, Archive Log).
2. Open the log entry of the record.
3. Select the related link **Restore Record** or **Restore Record and Related Records**.

## Result / how to check it worked

The record is back in the primary table and removed from the archive table. The **Restored** column in the Archive Log related list shows when.

## Example

Restore one archived incident with **Restore Record and Related Records** so that its archived child records come back too.

## Tables / fields involved

- `sys_archive_log`: source of the restore
- `ar_<table>`: row is removed on restore

## Gotchas

- **Never delete archive log entries**: without the log entry the record cannot be restored.
- If the rule has **Auto Rearchive**, the restored record is archived again after the set interval.
