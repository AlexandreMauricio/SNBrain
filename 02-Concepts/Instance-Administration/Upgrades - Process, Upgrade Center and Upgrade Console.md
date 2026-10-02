---
type: concept
tags: [concept, instance-admin, update-sets, release-specific]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Using ServiceNow AI Platform upgrade tools": "Upgrade Center" and "Upgrade Console" (pp. 2839-3006), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Upgrades: process, Upgrade Center and Upgrade Console

**In one line:** an upgrade replaces base records with the new release's versions but **skips anything you customised**; the work of an upgrade is previewing, deciding what to do with those skipped records on the first sub-production instance, testing, and carrying the decisions forward.

## The recommended sequence

1. Clone production over a test instance and a non-production (dev) instance.
2. Upgrade the non-production instance.
3. On it, process the **skipped records** list. Your decisions are captured in **update sets**.
4. Test, and compare with pre-upgrade benchmarks.
5. Upgrade the test instance, **import those update sets**, test again.
6. Upgrade production, import the update sets, test.

You reconcile skips **once**; later instances only receive the update sets.

## Two front doors, same tools

| | Upgrade Center | Upgrade Console |
|---|---|---|
| Where | **All > Upgrade Center** | **Admin > Upgrade Console** or **All > Admin Center > Upgrade Console** (store app from Australia) |
| Role | admin | `upgrade_admin` |
| Extra | | **Guided upgrade** tab (once an upgrade is started), **bulk application updates**, tiles for ATF, cloning, Now Support |

Modules in both: **Upgrade Preview**, **Upgrade Monitor**, **Upgrade History**, **Upgrade Plan**, **Skipped Record Rules Editor**.

## Upgrade Preview

Pick a target version and **Go**. Without upgrading, it predicts:

- total record changes and **predicted skipped records** (to review / reviewed / resolved by rules), by priority and by product;
- application installs and upgrades (from/to version);
- **schema changes** (new tables, columns, indexes);
- ATF pass rate of the last 30 days; links to fixes, personalised release notes, known errors.

You can already review predicted skips and **revert** some customisations before upgrading, so they are not skipped. **Refresh preview** regenerates and replaces earlier "reviewed and retained" marks. Only versions the instance is entitled to appear.

## Upgrade Monitor

- No upgrade running: shows the schedule; **Schedule upgrade** / **Reschedule upgrade** send you to the Now Support upgrade wizard; **Check for upgrade** looks for one available now.
- Running: admins logging in land on **Upgrade Progress** (stages Upgrading Platform, Updating Schema, Loading Plugins, Completing; node status).
- Done: **Upgrade Summary Report**: duration, skipped records by priority/product/code changed, application upgrade status, schema changes to **clone-excluded tables** (empty in sub-production, so production takes longer), top 10 fix scripts, schema changes and plugins by duration.
- A warning appears if the upgrade jobs *Check distribution for possible upgrade* or *Check database for possible upgrade* were modified; the fix button reverts them.

Duration depends on record counts, number of customisations, nodes, size of tables needing schema changes, and fix scripts. Sub-production is faster than production when tables were excluded from the clone.

## Upgrade History

**Upgrade History** > an upgrade (table `sys_upgrade_history`, details in `sys_upgrade_history_log`): From/To version, start/finish, **Changes skipped**, **Changes applied**, **Changes processed**, **Copies to review**. Related lists: Skipped Changes to Review, Skipped Changes Reviewed, Customization Unchanged, Changes Applied, Copies to Review, Claim Outcomes to Review, Upgrade Details. Related link **Skipped Record VTB** shows skips as a task board (Not Reviewed, Reviewed, Merged, Retained, Reverted).

The upgrade log is extracted to `database-upgrade_<timestamp>.log` and attached, zipped, to the history record (`glide.db.upgrade.log.save_to_db.enabled`, true).

## Skipped records

See [[Skipped Records in Upgrades]] and [[Process the Skipped Records List after an Upgrade]].

## Upgrade Plan

Automates app/plugin installs (and optionally skip resolutions) across instances.

- One **builder** instance (usually dev, already upgraded) builds and publishes the plan to the app repository; **consumer** instances retrieve and install it **before** their upgrade. Property `glide.upgrade.plan.instance_type`.
- By default (since Yokohama) only app installations are included; `glide.upgrade.plan.include.skips` = true adds customisations and skip resolutions (all skips, you cannot pick).
- One plan per upgrade; plan version must exactly match the instance version including patch and hotfix. Cannot be uninstalled on a consumer (only the whole upgrade rolled back). Only items **Ready** and **Active** are installed. No maint-only plugins.
- **Skipped record rules and upgrade plans cannot be used together.**

## Guided upgrade (Upgrade Console)

- **Pre-upgrade** (sub-production): release notes, request a clone, choose or create an upgrade plan (several plans can be merged; highest item version wins), automated tasks (generate preview, create upgrade update sets; optional ATF test generation and store-app upgrades), pre-testing (pick test suites), preview application upgrades (**Check app compatibility** is required), review predicted skipped records and rules.
- **Instance upgrade**: schedule through Now Support; optional **pre-staged schema alters** about a week ahead (`glide.staged_upgrade.enabled`, false by default).
- **Post-upgrade**: review skipped records, store application upgrades, post-testing (selected ATF suites run automatically), prepare the update set and plan for the next environment. Production adds **validate your upgrade** (UAT).
- **End session** on a started guided upgrade rolls back its progress data.

## Applications

- **Bulk application updates**: **Admin > Upgrade Console > Update apps > Update now**: select apps and versions, check compatibility, optional ATF, then **Update Now** or **Schedule Update**. About 5 minutes for 4-5 apps; much longer for hundreds. Use Application Manager for a single app or a new install.
- **Auto-upgrade** of ServiceNow-managed applications: instances poll every 2 hours and schedule within 24 hours of publication, outside blackout windows and platform upgrade windows. Properties `sn_app_auto_upgr.enabled`, `sn_appclient.scheduled_jobs_config`, `sn_app_auto_upgr.platform_upgrade_lookahead_hours`. Task states Assigned, In Progress, Success, Failed.

## Upgrade risk

Forms of base records flagged **high** or **medium risk** (likely to change in future releases; table `sys_metadata_volatility`) show a warning before you customise them. **High Risk Customizations** lists where your customisations overlap them. Advice: do not customise those unless necessary; revert if you did.

## Related

- [[Instance Clone Overview]] · [[Instance Scan]]
