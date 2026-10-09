---
type: how-to
tags: [how-to, cmdb, data-integrity, discovery]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB 360, topic "Recompute CI attribute values" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/multisource-cmdb.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# Recompute CI Attribute Values with CMDB 360

**Goal:** rewrite existing CI attribute values from the stored per-source data, either because reconciliation rules changed or because one discovery source turned out to be wrong and must be backed out.
**Where:** **All > Configuration > CI Class Manager** > class > **Class Info > Reconciliation Rules** > **Recompute**.
**Roles:** `sn_cmdb_admin` or `itil_admin`.
**Before you start:** [[CMDB 360]] enabled. To apply new rules, change the rules first ([[IRE Reconciliation, Data Refresh and Data Source Rules]]).

## Steps

1. **Recompute Type:**
   - *Replace values from the specified discovery source with value from the discovery source next in priority*: recompute while excluding one **Discovery Source**. Its records are also removed from the CMDB 360 data store.
   - *Apply updated reconciliation rules*: recompute under the rules now in effect.
2. **Recompute Scope**, each wider than the last: only CIs of this class; this and derived classes; this and derived classes plus selected related items.
3. **Delete action** for CIs whose **only** source is the excluded one: **Delete record**, or **Set record attributes to custom value** (for example Operational status = Retired, to take the CI out of use without deleting it).
4. **Next** > on **Review** check the counts of affected CIs > **Recompute**.
5. Follow progress through the link in the status message, or `cmdb_multisource_recomp_task.list`.

## Example

Source `ExampleScanner` has been writing wrong operating system values on Linux servers. On class **Linux Server**: type *Replace values from the specified discovery source*, source `ExampleScanner`, scope *only CIs of this class*, delete action *Set record attributes to custom value* (Operational status = Retired). Review shows the number of CIs changed and the number retired; **Recompute**. Afterwards the OS values come from the next source in priority.

## Gotchas

- **Excluding a source this way only fixes existing data.** If reconciliation rules still authorise that source, its next payloads populate the CMDB again. Change the rules too.
- At most `glide.identification_engine.multisource.recompute.max.ci.limit` CIs per operation (default 100,000).
- One recompute task runs at a time; others queue.
- CIs reported by several sources **under different class names** are skipped.
- **Not supported for non-CMDB tables.**
- Stop a run: set the task's **Status** to *Closed Incomplete* and **Update**. Set it back to *Work in progress* to resume where it stopped.

## Related

- [[CI Class Manager]]
