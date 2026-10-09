---
type: concept
tags: [concept, cmdb, data-integrity]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB Identification and Reconciliation (IRE), topic "Detecting duplicate CIs" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/c_CMDBIdentifyandReconcile.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# Duplicate CI Detection in IRE

**In one line:** when identification finds more than one CI matching a payload item, [[Identification and Reconciliation Engine (IRE) Overview|IRE]] groups them into a **de-duplication task** (`reconcile_duplicate_task`) and, by default, carries on by updating the oldest one.

Many duplicates usually mean weak identification rules ([[IRE Identification Rules]]).

## What happens on a match with several CIs

| `glide.identification_engine.skip_duplicates` | Duplicates found | Result |
|---|---|---|
| true (default) | fewer than `glide.identification_engine.skip_duplicates.threshold` (default 5) | the **oldest** CI is the match and is updated; it becomes the **main CI**. The others get **`duplicate_of`** = main CI |
| true | more than the threshold | treated as false |
| false | any | matching fails with an error; nothing is updated |

- **A de-duplication task is created in every case.**
- CIs marked `duplicate_of` are **left out of later matching**.
- If IRE later updates any other attribute of a marked CI, it is no longer a duplicate and `duplicate_of` is cleared.
- `glide.duplicate_ci_remediator.max.cis` governs handling of very large duplicate sets (remediation side).
- Before any rule runs, IRE checks the payload itself: two items identical on a class identifier and the **payload is rejected**.

## Duplicates in lookup and related tables

Duplicate rows in a lookup table (Serial Number, `cmdb_serial_number`) or a related table (software instance) get **no task by default**. To have tasks, add a row per table to **CMDB Deduplication Task Lookup or Related item allowed classes** (`cmdb_duplicate_lookup_related_allowed_class.list`, empty in the base system):

| Field | Notes |
|---|---|
| Lookup or related item class | the lookup or related table |
| Identifier table | the class whose identification rule uses it (for example Hardware) |
| Active | |

Roles: write `sn_cmdb_admin`, `cmdb_dedup_admin` or `itil_admin`; read also `sn_cmdb_editor`, `itil`. The [[CMDB CI Class Models App]] can ship rows for its classes.

## One lookup value pointing at several CIs

Example: the same serial number on rows that reference two different CIs. IRE picks the row with the **older** CI. Whether a task is raised for the two CIs depends on `glide.identification_engine.lookup_match.create_duplicate_task_ci.enabled` (add to `sys_properties`):

- **false (default):** no task. Right when the situation is legitimate (identical serials on different kinds of hardware).
- **true:** a task for the CIs.

The docs' two worked cases, payload with serials ABC123 and DEF456 for a new Linux server:

| Lookup table content | Exact count match | Outcome |
|---|---|---|
| Both serials on CI1 **and** on CI2, with duplicate rows | on or off | CI1 (oldest) updated. Tasks for the duplicate serial rows. Task for CI1 + CI2 only if the property is true |
| ABC123 only on CI1, DEF456 only on CI2 | **on** | no match at all (neither CI has both), so a new CI; no tasks |
| same | **off** | CI1 updated. Task for CI1 + CI2 only if the property is true |

(The docs prose also says no CI task is created when exact count match is off or more than one CI matches; that contradicts the second table, which is reproduced here. Test before relying on either.)

## Related

- Resolving the tasks: [[Duplicate CI Remediation]] and [[Remediate a De-duplication Task]].
- [[IRE Properties and Tables Reference]] · [[IRE Error Messages]]
