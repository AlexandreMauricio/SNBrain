---
type: concept
tags: [concept, cmdb, assets, data-integrity, choice-list]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CSDM (read in full 2026-10-29) - Foundation domain (life-cycle values), Activate the CSDM plugin, Synchronize existing data, Support for synchronization, Legacy status values auto-updated, Enabling life-cycle synchronization from legacy to asset (with Map legacy status values and Migrate legacy asset and CI settings), Synchronizing life-cycle values for Asset, CI and IBI, Asset status values aligned, Life cycle mapping form, Life-cycle terms, Mapping data to CMDB tables. https://www.servicenow.com/docs/r/servicenow-platform/common-service-data-model-csdm/csdm-life-cycle-standard-values.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# CSDM Life Cycle Stages and Synchronization

**In one line:** CSDM replaces the many legacy status fields (install status, operational status, hardware status and substatus, asset state and substate, model and contract status) with one **life-cycle value pair** — **Life cycle stage** + **Life cycle stage status** — mapped from the legacy values by rules in `life_cycle_mapping` and then kept in step across asset, CI and install base item.

From the Brazil docs; not tested. The stage and status values per entity type are in [[CSDM Life Cycle Values Reference]]. Overview: [[CSDM Overview and Data Domains]].

## Terms

| Term | Meaning |
|---|---|
| Life-cycle value pair | stage (broad phase: Ideation, Operational, End of Life...) + stage status (e.g. In Use, In Maintenance, End of Support) |
| Legacy values | install status, operational status, hardware status, hardware substatus on CIs; state and substate on assets |
| CI / asset / IBI | record in `cmdb_ci` / `alm_asset` / Install Base Item `sn_install_base_item` (anything sold or provided as a service to a customer) |
| Product instance | the asset + CI + IBI of one real item (or asset+CI, asset+IBI); tied together through the **model category** |
| Life cycle control | `life_cycle_control`: the valid stage/status combinations per class and per entity type (tangible/physical, logical, document and contract, location, product) |
| Life cycle mapping | `life_cycle_mapping`: one rule per legacy value (per table) → life-cycle pair; prepopulated with common mappings |

Field names on the CI are not printed in this chapter; [[CI Lifecycle Management (Legacy)]] mentions the jobs *Update life cycle from legacy* and *Update legacy from CSDM*; names of the stage fields unconfirmed (`life_cycle_stage` appears as a list name: type `life_cycle_stage.list` to see mapped pairs).

## Inheritance differs from choice lists

`life_cycle_control` **aggregates** definitions down the class hierarchy: a child class shows its own stages plus every parent's. So a Business Application, which defines only Ideation, Design, Operational and End of Life, also offers Deploy and Inventory inherited from `cmdb_ci`. The docs call this expected; there is no way to suppress parent stages. Contrast `sys_choice`, where the most specific table wins ([[Choice Lists]]).

## Plugins and properties

| Item | Meaning |
|---|---|
| `com.snc.cmdb.csdm.activation` (CSDM Activation) | activate **after** mapping existing life cycle data; roles given as `itil` and `itil_admin` |
| `csdm.lifecycle.migration.activated` | system property; true = life cycle migration active. One page calls it "the CSDM (csdm.lifecycle.migration.activated) plugin" (unconfirmed variant: property or plugin) |
| `csdm.lifecycle.sync.between.ci.and.asset.activated` | false (default) = asset and CI sync through legacy status/substatus; true = sync the CSDM pairs directly. Set to true by **Enable life cycle sync** |

Order variants: the plugin page says map data **before** activating `com.snc.cmdb.csdm.activation`; the migration page lists activating it as **what to do next** after migration. Both readings kept.

Legacy values auto-mapped when the plugin is activated (legacy values are **not deleted**; mappings inherit from parent to child tables): product model status, asset state, asset substate, contract status, CI install status, CI operational status, CI hardware status and substatus (tangible CIs).

## The synchronisation process

Started by **Enable life cycle sync** on the **CSDM > Life Cycle Mapping** list (roles `itil_admin` or `asset_admin`).

1. **Discrepancy check**: checks asset mapping rules, CI mapping rules and the legacy asset-to-CI rules (`alm_hardware_state_mapping`, `alm_asset_ci_state_mapping`); reports unmapped legacy values, values only in inactive rules, and **custom legacy values**, for which it creates *inactive* mapping records to complete. Fix, **Refresh**, repeat until clean.
2. **Bulk alignment** (one-time scheduled job; mapping edits blocked meanwhile): assets without a pair get one from the asset rules; CIs whose pair differs from their asset's take the asset's; CIs with no asset get theirs from the CI rules. IBI records are not changed (already synced).
3. **Switch of sync rules**: asset ↔ CI pairs synced both ways; CI legacy values ↔ CI pair sync **turned off** (so CI legacy values may drift; a CSDM dashboard report lists the divergence); asset legacy ↔ CI legacy sync continues; asset legacy ↔ asset pair continues.
4. **Ongoing**: business rules keep asset, CI and IBI pairs aligned.

## Who syncs with whom

- **Asset ↔ IBI**: always through the life-cycle pair, when the model category is a product instance.
- **Asset ↔ CI**, property **false**: through legacy status/substatus. Docs examples: asset State *In use* → asset pair Operational/In use → IBI pair; CI status and substatus become Installed / In use. IBI pair Defective/In Stock → asset → CI. CI Retired/Donated → asset → IBI pair End of Life/Retired.
- **Asset ↔ CI**, property **true**: asset legacy change → asset pair from the mapping → asset legacy copied to CI legacy → asset pair copied to CI. CI pair change → copied to asset → asset legacy set from the mapping → copied to CI legacy. IBI ↔ asset still through the pair.

Example given: the defective pair is written once as Defective/In Stock and once as "In Stock and Defective" (order of stage and status unclear in the docs).

## Life cycle mapping form

| Field | Meaning |
|---|---|
| Mapping for table | table (and its descendants unless they have their own rule) |
| Priority | when several legacy values on one record match rules, the lowest number wins; not used for reverse sync (at most one reverse choice per pair and class) |
| Active | inactive rules fall back to lower priority, else the pair becomes **TBD** |
| Legacy field name / subfield name | e.g. hardware status / substatus |
| Legacy field value / subfield value | the legacy values being mapped |
| Life cycle control | the valid class + stage + status combination (authoritative) |
| Table | table the control belongs to |
| Life cycle stage / stage status | the target pair; no matching rule = **TBD** |

Docs example: Install Status *Pending Install* on hardware CIs → Deploy / Test. Activation needs every mapping active and with a life cycle control, custom values completed.

## Asset status alignment (docs summary table)

| Asset / hardware asset status | CSDM phase |
|---|---|
| Ordered | Plan / Design |
| In Stock → In Use | Build / Deploy |
| In Use / In Maintenance | Consume / Operate |
| Pending Disposal / Disposed | Retire |

This table uses phase names (Plan, Build, Consume, Retire) that are not the stage names of the life cycle definitions (Purchase, Inventory, Deploy, Operational, End of Life): unconfirmed how they relate.

## Who benefits

Event Management and Operational Intelligence (is a CI in maintenance?), Cloud Cost Management, Audit Management and conformance tasks, CMDB Data Manager policies ([[CMDB Data Manager]]).

## Related

- [[CSDM Life Cycle Values Reference]] · [[Enable CSDM Life Cycle Synchronization]] · [[CI Lifecycle Management (Legacy)]] · [[Asset Management Common Applications]] · [[CMDB and CSDM Data Foundations Dashboards]]
