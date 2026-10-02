---
type: how-to
tags: [how-to, data-management, instance-admin, admin]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Roll back and delete recovery" (pp. 687-691), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Roll back a patch, plugin activation or background script

**Goal:** undo a patch upgrade, a plugin activation, or the database changes of a script run in Scripts - Background.
**Prerequisites:** role admin. Plugins Restore Deleted Records and Delete Recovery active. Inside the retention window (10 days by default, 15 for plugins and app installs). For a script: **Record for Rollback?** was ticked when it ran.
**Navigation:** All > Rollback & Recovery > Rollback Contexts / Script Execution History

## Steps: patch upgrade or plugin activation

1. Open **All > Rollback & Recovery > Rollback Contexts**.
2. Open the context to roll back.
3. Select the related link **Rollback** and confirm.
4. When the progress indicator finishes, log out and log in again.
5. Check the context state is **Rolled back**. If not, contact Support.

## Steps: background script

1. Open **All > Rollback & Recovery > Script Execution History** (or the link shown in Scripts - Background after running).
2. Open the execution.
3. Select the related link **Rollback Script Execution**.

## Result / how to check it worked

The instance reports the earlier patch version (`glide.war`), or the records the script inserted, updated or deleted are back to their previous state.

## Example

On a sub-production instance, a fix script run from Scripts - Background with **Record for Rollback?** ticked updated the wrong records. Open its entry in Script Execution History and roll it back.

## Tables / fields involved

- `sys_rollback_context`

## Gotchas

- Patches only within the same release family, one step back at a time.
- Rolling back deletes data and can remove the evidence of what went wrong: check with Support before rolling back an upgrade.
- Schema changes (dropped or renamed tables or columns, type changes, truncation) prevent a context from being created at all.
- Background and retention properties: [[Rollback and Delete Recovery]].
