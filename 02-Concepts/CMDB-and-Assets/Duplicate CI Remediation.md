---
type: concept
tags: [concept, cmdb, data-integrity, data-management, workspace]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB data management > "Duplicate CIs remediation" with its topics (CI de-duplication experience in a workspace, templates, review and remediate manually, manually create a task, related table workflows, default related items, properties, components) (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/cmdb-data-management-landing.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# Duplicate CI Remediation

**In one line:** remediation takes a **de-duplication task** (a set of CIs judged to be the same thing), keeps one as the **main CI**, optionally merges attributes, relationships and related records from the others into it, and then deletes or marks the rest.

Tasks are raised by identification ([[Duplicate CI Detection in IRE]]), by an attestation reviewer, or by script. Table **Remediate Duplicate Task** (`reconcile_duplicate_task`); its CIs are in **Duplicate Audit Result** (`duplicate_audit_result`).

## Two ways to remediate

| Way | Where | For |
|---|---|---|
| **Templates, in bulk** | **CMDB Workspace > Governance > Management tools > De-duplication Dashboard / De-duplication Template Library** | many similar tasks, consistently |
| **Duplicate CI Remediator**, one task | **Configuration > Identification/Reconciliation > De-duplication Tasks** > task > **Remediate** | a single task, step by step |

Roles: view `sn_cmdb_editor` or `itil`; remediate `cmdb_dedup_admin` (inside `sn_cmdb_admin`) or `itil_admin`. Steps: [[Remediate a De-duplication Task]].

With Otto for CMDB, the remediator offers an AI option (skill *De-duplication task resolution assistant*) that fills in the choices for review, and a *Manage duplicate CIs* skill guides the template route.

## Main CI and `duplicate_of`

- Before remediation the CIs of a set are duplicates of each other. After it, the main CI has an empty **`duplicate_of`** and every other CI points to it.
- On instances upgraded from before New York, old duplicates have `duplicate_of` = *Unknown*.
- **IRE fills `duplicate_of` itself; avoid editing it.** If edited (form or script) the system enforces:
  - a CI cannot be a duplicate of itself, nor of a CI in another domain;
  - no chains: setting CI1 as duplicate of CI2 (itself a duplicate of CI3) stores CI3. Fails if CI2's main CI is *Unknown*;
  - making a main CI a duplicate of another CI moves all its duplicates to the new main CI; making it a duplicate of one of its own duplicates swaps the roles.
- **A main CI cannot be deleted** while other CIs reference it in `duplicate_of`.

## What gets merged

- **Attributes:** per attribute, keep the main CI's value or take another. Not offered: system fields, discovery fields (`discovery_source`, `last_discovered`, `first_discovered`), read-only fields such as the asset.
- **Relationships:** all or none (or by condition in a template). Dropped rather than merged: relationships with empty type, parent or child; ones that would become cyclic or duplicate.
- **Related items** (records in other tables that reference the CI): by default those in the **default related items list** (**Identification/Reconciliation > Duplicate CI Remediator Default Related Items**; role `sn_cmdb_admin` or `itil_admin`). Only tables whose reference field points at `cmdb_ci` itself can be on the default list; tables referencing a child class can still be picked per task.
- **Asset tables are never merged.** Excluded by `glide.duplicate_ci_remediator.related_items_blacklist`.
- Afterwards the duplicates are **deleted**, or kept with **attributes set to custom values** (recommended: for example Operational Status = Retired). Kept duplicates carry `duplicate_of` and are not put in new tasks; if identification is not set to skip duplicates, add an inclusion rule that leaves them out.

## Related tables that resist the update

Business rules on a related table can block re-pointing a record to the main CI. **De-duplication Related Table Configurations** (`reconcile_duplicate_related_table_config.list`, role `cmdb_dedup_admin`) lists tables for which remediation may **Disable workflow** (skip all business rules and automation) and **Proceed with errors**, optionally only for records matching a condition. Effective while `glide.duplicate_ci_remediator.merge_related_items_enhanced` is true (default).

- Shipped rows: Change (`change_request`, condition *state is not New*) and Task CI (`task_ci`).
- Without this mechanism: a CI on a change request in state New is replaced by the main CI; on a change in any other state it is **removed** when the duplicate is deleted (business rule *Read only CI when not New*). Incidents and problem tasks get the main CI. On an inactive change the Configuration item field is cleared.
- The remediator warns when a selected table has such a row. Check that skipping its business rules is intended.

## Special cases

| Case | Behaviour |
|---|---|
| More duplicates than `glide.duplicate_ci_remediator.max.cis` (default 1000; hard ceiling 5000) | only the recommended main CIs (oldest created, newest updated, most recently discovered) and **Use Main CI**; no attribute or relationship reconciliation; default related items only |
| Duplicate serial numbers (lookup table task) | relationships are not merged |
| Task will not load (very many related items) | add `glide.duplicate_ci_remediator.enable_restricted_mode` = true to get the **Restricted Mode** option (KB1542272) |
| No identification rule for the class, so no task is generated | create the task by script with the `CMDBDuplicateTaskUtils` API. CMDB CIs only; a CI can be in only one task |

## Templates

A de-duplication template holds, for one class: which tasks it takes (all tasks of the class, optionally child classes, narrowed by a condition or a script returning task sys_ids), how the main CI is chosen, how attributes, relationships and related items merge, and what happens to the duplicates. Templates live in **libraries**.

- States: **draft** (editable) > **published** (runnable, not editable or retirable) > unpublish to edit > **retire** (only when unpublished).
- A published template can have a **schedule** (More options > **Create schedule**; activate, deactivate, edit).
- Dashboard: template cards with **Assign tasks** and **Run template**, **Run all**, tabs **Ready / Running / Completed**, and an insights pane (tasks processed in the past week, tasks completed with errors, tasks matching no template).

## Properties

**Configuration > CMDB Properties > Duplicate CI Remediator Properties** unless marked (add).

| Property | Default | Effect |
|---|---|---|
| `glide.duplicate_ci_remediator.dry_run` | false | **true = nothing is updated**; the task's work notes describe what would happen |
| `glide.duplicate_ci_remediator.max.cis` | 1000 | threshold for limited remediation |
| `glide.duplicate_ci_remediator.max.field_length` | 4000 | attributes with a larger `max_length` are left out of the wizard. Affects performance |
| `glide.duplicate_ci_remediator.related_items_blacklist` | `cert_task.cmdb_ci,cert_audit_result.configuration_item,discovery_log.cmdb_ci,alm_hardware.ci,alm_asset.ci,fm_expense_line.ci` | `table.reference_column` pairs never merged |
| `glide.duplicate_ci_remediator.merge_related_items_enhanced` (add) | true | honour the related table configurations |
| `glide.duplicate_ci_remediator.enable_restricted_mode` (add) | false | offer Restricted Mode |

## Tables and jobs

| Table | Holds |
|---|---|
| `reconcile_duplicate_task`, `duplicate_audit_result` | tasks and their CIs |
| `cmdb_duplicate_ci_remediation` | each remediator run: input, choices per tab, status, results |
| `reconcile_duplicate_task_data` | task metadata for dashboard analytics |
| `reconcile_duplicate_related_table_config` | related tables with workflows turned off |
| `sn_cmdb_ws_reconcile_duplicate_template_library`, `sn_cmdb_ws_reconcile_duplicate_template_suggested_task` | libraries; task-to-template mapping |

| Job | Runs | Does |
|---|---|---|
| De-duplication: Populate Duplicate Task Data | daily | copies identification metadata of tasks for analytics |
| De-duplication: Populate Template Task Run Records | every minute | assigns matching and manually added tasks to templates |
| De-Duplication: Template Scheduler | every minute | feeds queued tasks to the execution engine. **Tasks stay "ready" if this job is not running** |
| De-duplication: Populate Template Suggested and Orphan Tasks | hourly | counts of matching and unmatched tasks for the dashboard |

## Related

- [[IRE Identification Rules]] · [[CMDB Data Manager]] · [[CMDB Workspace]]
