---
type: concept
tags: [concept, data-management, platform, business-rule]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Data Management" (pp. 599, 617-620, 634-637, 650-651), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Table cleaner

**In one line:** table cleanup rules delete records automatically once a date field is older than a set age and optional conditions match; they live in Auto Flush (`sys_auto_flush`) and run from an hourly job.

## How it works

- Rule = table + **Matchfield** (a date/time field, default `sys_created_on`) + **Age in seconds** + **Conditions**. Example from the guide: closed incidents not updated for 30 days = match field `sys_updated_on`, age 2,592,000, condition State is Closed.
- Options: **Clean journals** (`sys_journal_field`), **Clean audit** (`sys_audit`, `sys_audit_relation`; the `sys_audit_delete` rows the cleaner itself writes are kept), **Cascade delete** (also delete records that refer to the deleted ones). Attachments are always deleted.
- Many base-system rules exist: see `sys_auto_flush.list`.
- The rule and its data management policy must both be active ([[Data Management Overview]]).

## Limits

- **Business rules, workflows and flows do not fire** on these deletes: the cleaner deletes with workflow off.
- At most **20 minutes per table per run** (`glide.db.tablecleaner.chunk_delete_max_time_spent`, default 1200 seconds).
- **Slow rules**: if a rule's query takes over 30 seconds, the whole job stops and that rule is skipped for two days (`glide.db.tablecleaner.days_before_slow_rule_reattempt`, default 2). Cause is usually no index on the match field or condition fields.
- Not supported on tables with **table rotation**. Since Xanadu patch 5, supported on extension and shard tables through `sys_auto_flush` rules (not through the `GlideTableCleaner` scriptable).
- A table can opt out with the **Disable Table Cleaner** dictionary attribute; some internal tables have it by default.
- Dictionary attributes `nibble_size` (default 250), `nibble_sleep` and `no_optimize` tune batch size, pauses and compaction ([[Dictionary Attributes Reference]]).

## Resource usage

The job runs asynchronously: producer threads build chunks, consumer threads delete them. Job record **DMTableCleaner** in `sys_dm_job`; runs in `sys_dm_run` (check **Chunks Errored**); chunks in `sys_dm_chunk` (**Message**, **State**). Changing thread counts needs Support.

## Where it lives in the data

- [[sys_auto_flush]]: the rules

## Related

- [[Create a Table Cleanup Rule]] · [[Approaches to Deleting Many Records]] · [[System Archive and Archive Rules]]
