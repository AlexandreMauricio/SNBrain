---
type: concept
tags: [concept, data-management, platform, instance-admin]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Roll back and delete recovery" (pp. 687-693), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Rollback and delete recovery

**In one line:** the platform records **rollback contexts** for deletes, patch upgrades, plugin activations and background scripts, so they can be undone for a limited number of days.

## Database support

| Database | Roll back | Delete recovery |
|---|---|---|
| MySQL | yes | yes |
| MariaDB | yes | yes |
| Oracle | yes | no |
| SQL Server | no | no |

Plugins needed: **Restore Deleted Records** (`com.snc.undelete`) and **Delete Recovery** (`com.glide.delete_recovery`).

## The modules

| Module | Covers | Window |
|---|---|---|
| **System Definition > Deleted Records** | deleted records on **audited tables** | cascaded deletes within 7 days; after that only the record and references on tables that audit deletions |
| **Rollback & Recovery > Delete Recovery** | **any** deleted record, with all related changes | 7 days |
| **Rollback & Recovery > Script Execution History** | scripts run in **Scripts - Background** with **Record for Rollback?** ticked | 7 days of history |
| **Rollback & Recovery > Rollback Contexts** | patch upgrades, plugin activations, and the rest | 10 days by default |

## When a rollback context is created

- `GlideRecord.delete()` or `deleteMultiple()` deletes records.
- A patch upgrade.
- Activation of a plugin that supports rollback contexts.
- A Scripts - Background run with **Record for Rollback?** ticked (it tracks every INSERT, UPDATE and DELETE).

Not created if the operation drops or renames tables or columns, truncates a table, re-parents or promotes a column, changes a column type or narrows a column. Dropping an index is fine.

A rollback does not touch records changed by other activity in the meantime.

## Retention

Contexts are stored in Rollback Context (`sys_rollback_context`) and removed by the daily job **Clean Expired Rollback Contexts**. Properties (add to `sys_properties`; match the name to the context's **Type**):

| Property | Default days |
|---|---|
| `glide.rollback.expiration_days_app_install` | 15 |
| `glide.rollback.expiration_days_plugin` | 15 |
| `glide.rollback.expiration_days_batch_app_install` | 10 |
| `glide.rollback.expiration_days_delete` | 10 |
| `glide.rollback.expiration_days_scripts_bg` | 10 |
| `glide.rollback.expiration_days_flow` | 10 |
| `glide.rollback.expiration_days_inst_preview` (CMDB Integration Studio) | 10 |
| `glide.rollback.expiration_days_redact` (data anonymisation) | 10 |
| `glide.rollback.expiration_clean_demo_data` | 10 |
| `glide.rollback.expiration_days_other` | 10 |

## Rolling back upgrades and plugins: constraints

- Only between **patches of the same release family**, and only to the **previous** version (patch 3 to patch 1 takes two rollbacks).
- One active instance at a time; multiple nodes not supported.
- Meant for pre-production. **A rollback deletes data and can erase the evidence needed to debug the upgrade problem**: the guide says to check with Support first.
- After rollback, `glide.war.no_upgrade` is set so the upgrade does not rerun, and the context state becomes Expired.

## What is not tracked for undelete

- Tables with the dictionary attribute `no_audit_delete=true`.
- Many `sys_` tables, unless auditing is enabled for them.
- References are restored only if the reference field is on an audited table. Image-type references are not restored.

## Related

- [[Restore a Deleted Record]] · [[Roll Back a Patch, Plugin Activation or Background Script]] · [[Update Jobs, Delete Jobs and One-Time Delete Rules]]
