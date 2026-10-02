---
type: concept
tags: [concept, data-management, platform, access-control, reference-field]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Data Management" (pp. 594-596, 610-617, 626-634, 642-644, 648-651), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# System Archive and archive rules

**In one line:** an archive rule moves records that match its conditions from a primary table into a flat `ar_` table on the same instance, optionally with related records, and a destroy rule deletes them after a retention period.

## What archiving does and does not do

- Improves query and report performance on the primary table and keeps data for audit or history.
- **Does not reduce primary storage** and does not move data to another tier (that is [[Live Archive with RaptorDB Professional]]).
- Available on all instances.

## What happens when a rule is activated

- An archive table is created with the prefix `ar_` (Incident becomes `ar_incident`).
- A hierarchy is **flattened**: one archive table, no base and extended tables.
- **Reference values become strings** holding the display value at the time of archiving. Later renames or deletions of the referenced record do not change archived rows.
- An XML copy of each archived record goes to `sys_archive_log`, the same table for every rule. It is the only place that keeps the sys_id together with the display value: `<assigned_to display_value="Example User">5137...</assigned_to>`.
- A module **Archive <table label>** appears under **System Archiving > Archive Tables**, with a list and form from the default views (dot-walked fields are left out of the form).

## Archive rule fields

| Field | Notes |
|---|---|
| **Name** | display value of the rule |
| **Table** | cannot be changed later. Not allowed: tables in another scope, tables with `update_synch`, and peripheral tables (`sys_audit`, `sys_audit_delete`, `sys_audit_relation`, `sys_attachment`, `sys_journal_field`) |
| **Conditions** | which records to archive. Test them in a list first |
| **Retain references** | keep the sys_id in reference fields instead of a string. **Read-only once saved.** Enabling it reprocesses existing archive rows; progress in `sys_archive_ref_migration` |
| **Auto Rearchive** / **Duration** | a restored record goes back to the archive after this time |
| **Active** | plus the policy must be active |

Related link **Recalculate Archive Estimate** fills **Record estimate** (primary records only). **Run Archive Now** needs an active policy.

Condition tip from the guide: `[Closed] [relative] [before] [2] [Years] [ago]` archives what closed more than two years before today, while `[Closed] [on] [Last 2 years]` is a calendar window.

Several rules can exist per table; overlapping ones (older than six months, older than three months) conflict because either may run.

## Related records

On the rule, **Archive Related Records** (Core UI) or the **Manage related records** step (console):

| Action | Effect on records that reference the archived record |
|---|---|
| **Archive** | archived too |
| **Clear** | the reference is emptied (a many-to-many link is deleted) |
| **Delete** / Cleanup | deleted |

- **Reference** lists reference fields and document ID fields (marked `*`) that point at the archived table, e.g. *Problem in Incident* for a rule on Problem.
- **Reference table rule**: the archive rule to apply to those related records. **Since Washington DC, cascading only happens for related tables whose rule is named here**; before, an existing rule cascaded automatically.

## Destroy rule

- **Create Destroy Rule** on the archive rule: **Active**, **Destroy Related Records**, **Archive Duration** (default one year in the console wizard).
- **An empty or zero duration destroys archived records immediately.**
- Journal, attachment and audit rows of the record are always deleted with it.
- Progress is in the archive destroy log.

## Access, queries and language

- Archive tables use the ACLs of the original table by default. With `glide.security.enable_archive_table_acls` = true, ACLs defined on the archive table take over (and mask the originals); with none defined, the originals still apply. Only **read** is evaluated; other operations are blocked. The property is absent on upgraded instances (add it), true on new ones.
- Archive tables are indexed only on display value, creation date and sys_id. Search by number or creation date; avoid ad hoc filters such as "all priority 1".
- Display strings use the language of the SYSTEM user, or the system default language.

## Operations

- Schedule: the scheduled job **Archive** runs every 60 minutes (**System Scheduler > Scheduled Jobs**).
- Stop: clear **Active**, or cancel with `GlideArchiver().cancel()` in **Scripts - Background**. Deleting a rule needs Support.
- Restore: [[Restore Archived Records]].
- CMDB CIs are archived with the CMDB Data Manager, and email with the Email retention plugin, not with your own rules.

## Limits and properties

- Archive table limits: static row size 65,535 bytes, row size 8,126 bytes, 1,000 columns on Oracle and 1,011 otherwise. An "archive table could not be created" error may mean too many or too wide custom columns.
- Producer/consumer model over `sys_archive_run_chunk`:

| Property | Default | Meaning |
|---|---|---|
| `glide.db.archive.chunk_size` | 1000 | sys_ids per chunk |
| `glide.db.archive.max.rule.records` | 10000 | records batched per consumer, per rule |
| `glide.db.archive.max.batches` | 10 | chunks a consumer handles before handing over |
| `glide.db.archiving.max_consumer_workers` | 4 | concurrent consumers, cluster-wide |
| `glide.db.archive.chunk.max.process.time` | 600000 ms | after this a running chunk is marked error |
| `glide.db.archive.debug` | false | verbose logging |

## Related

- [[Create an Archive Rule]] · [[Data Management Overview]] · [[Table Cleaner]]
