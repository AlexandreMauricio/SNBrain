---
type: how-to
tags: [how-to, cmdb, assets, data-integrity]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CSDM > Activate the CSDM plugin, Enabling life-cycle synchronization from legacy to asset (Map legacy status values to CSDM life-cycle values; Migrate legacy asset and CI settings to CSDM life-cycle values), Life cycle mapping form (read 2026-10-29). https://www.servicenow.com/docs/r/servicenow-platform/common-service-data-model-csdm/csdm-life-cycle-standard-values.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Enable CSDM Life Cycle Synchronization

**Goal:** map legacy asset and CI status values to CSDM life-cycle pairs, run the one-time alignment, and switch on ongoing asset/CI/IBI synchronisation.
**Prerequisites:** `itil_admin` or `asset_admin` for mapping and sync; `itil` and `itil_admin` (as the docs print it) for the CSDM Activation plugin; a recent backup or clone to rehearse on.
**Navigation:** **All > CSDM > Life Cycle Mapping** (`life_cycle_mapping.list`).

Background and the four phases: [[CSDM Life Cycle Stages and Synchronization]].

## Steps

1. Open **CSDM > Life Cycle Mapping** and review the prepopulated rules. For each legacy value your instance uses (including custom states and substates), make sure a rule exists, is **Active**, and has a **Life cycle control**.
2. To add a rule: **New**, fill **Mapping for table**, **Priority**, **Legacy field name** (and subfield), **Legacy field value** (and subfield value), **Life cycle control**, **Life cycle stage**, **Life cycle stage status** > **Submit**.
3. Select **Enable life cycle sync**. This sets `csdm.lifecycle.sync.between.ci.and.asset.activated` to true and runs the discrepancy check.
4. Work through the discrepancy report: each item opens the mapping that needs fixing (missing rules, inactive rules, the inactive rules the check created for custom values). Fix them and select **Refresh** until the report is clean.
5. The bulk alignment job then runs once (mapping edits are blocked while it runs).
6. Activate the **CSDM Activation** plugin (`com.snc.cmdb.csdm.activation`) if it is not active yet. The docs give two orders: "map before activating" on the plugin page, "activate after migration" on the migration page; both end with mapping done first.
7. From here, manage CI life cycles in bulk with [[CMDB Data Manager]] policies.

## Result / how to check it worked

- Every `cmdb_ci` and asset record has a stage and stage status (from its asset when there is one, from the CI rules otherwise); values that matched no rule show **TBD**.
- CSDM Data Foundations dashboard, **Crawl** tab: *CIs with Mismatched Operational Status and Life Cycle Stage* lists remaining mismatches ([[CMDB and CSDM Data Foundations Dashboards]]).

## Example

On a test instance, the hardware CI status *Pending Install* has no rule. Create: Mapping for table `cmdb_ci_hardware`, Legacy field name **Install Status**, Legacy field value *Pending Install*, Life cycle stage **Deploy**, stage status **Test**, Priority 100, Active. Then **Enable life cycle sync**, confirm the report no longer lists that value, and check a sample CI such as *EXAMPLE-SRV-01* after alignment.

## Tables / fields involved

- `life_cycle_mapping` (rules), `life_cycle_control` (valid combinations), `alm_hardware_state_mapping` and `alm_asset_ci_state_mapping` (legacy asset ↔ CI rules), `alm_asset`, [[cmdb_ci]], `sn_install_base_item`.

## Gotchas

- Legacy values stay on the records; after alignment CI legacy values are no longer synced to the CI pair and may drift.
- Inheritance: a rule on a parent table applies to children unless a child has its own rule.
- Rehearse on a sub-production instance; this is a one-time bulk change with no undo described in the docs.
