---
type: concept
tags: [concept, assets, cmdb, discovery, release-specific]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Asset Management common applications > ITSM Software Asset Management > Legacy Software Asset Management plugin" (pp. 293-355), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Legacy Software Asset Management plugin

**In one line:** the ITSM-level software asset feature (`com.snc.software_asset_management`) reconciles discovered installations against licence rights with **software counters**. It exists only on instances that activated it on Jakarta or earlier; newer instances use [[Software Asset Management Foundation Plugin]] or the separately licensed SAM Professional.

Menu **Software Asset**. Role `sam` (contains `inventory_user`, `contract_manager`, `category_manager`, `financial_mgmt_user`).

## Data model

| Table | Label | Notes |
|---|---|---|
| `cmdb_software_product_model` | Software Model | what you licence; **License type**, version fields, suite parents/components, upgrade/downgrade |
| `cmdb_sam_sw_discovery_model` | Software Discovery Model | one row per distinct discovered title/version; created only by discovery; links to a software model |
| `cmdb_sam_sw_install` | Software Installation | discovery model × hardware CI; replaces the older `cmdb_software_instance` (re-point transform maps) |
| `cmdb_sam_sw_usage` | Software Usage | who used what from where; **not** filled by ServiceNow Discovery (third-party tool, for example SCCM) |
| `alm_license` | Software License | an asset with **Rights**, **License metric**, conditions |
| `alm_entitlement` (`alm_entitlement_asset`, `alm_entitlement_user`) | License Entitlement | who or which CI holds a right |
| `sam_sw_counter` | Software Counter | the reconciliation definition |
| `sam_sw_counter_result` → `sam_sw_counter_summary` → `sam_sw_counter_detail` | results by grouping → by type → per install/usage/entitlement |
| `sam_sw_counter_history`, `sam_sw_counter_violation` | history copies; non-count violations |
| `sam_sw_license_calculation` | License Calculation | license types |
| `cmdb_m2m_suite_model`, `cmdb_m2m_downgrade_model` | suites; upgrades and downgrades |
| `cmdb_processor_definition`, `sam_processor_mapping` / `sam_ibm_pvu_mapping` | IBM PVU support |

## Discovery model matching

A new discovery model is matched to a software model on Display Name + Publisher + Version, then Display Name + Version, then Display Name alone; version falls back to the major version (8.0.4 → 8.0). **Match model** re-runs it; **Create Software Model** / **Create Software Model and Counter** make new ones. Records start unapproved: review and tick **Approved**; **Low confidence** needs **Confirm Mapping**. The primary key of an install is its serial number, else publisher + name + product ID + version + revision.

## Licence calculation types

| Category | Types |
|---|---|
| By CPU | By CPU cores, By number of CPUs |
| By points | Per installation - IBM PVU (needs the IBM PVU process pack) |
| CAL | CAL (Device), CAL (User): counted from usage |
| By user | Number of installs per user (each install uses rights, up to **Installs per license**), Per named user (one right however many installs), No license needed (User) |
| By utilization | Usage (CPU), Usage (User) |
| By workstation | Per workstation, No license needed (Workstation) |
| Oracle (process pack) | Oracle Named User, Named User Plus, Processor |
| Custom | script with variables `found`, `workstation`, `user`, `counter_id`, `query_table`, `valuation`; helpers in `SAMUtil` (`getWorkstationInstallsOrUsages`, `getUserInstallsOrUsages`, `createCounterViolation`). Server-side |

## Software counters

**Software Asset > Reconciliation > Software Counters**: **Software model**, optional **Contract** (enterprise or subscription), **Grouping** (Location, Company, Department, Cost Center, Entitlement (CPU), Entitlement (User), none), **Enforce to** (*License* or *Strict*: the user or machine must also match the grouping), **License type**, **Installs per license**, conditions, and the speed options **Verify entitlements** and **Generate details**.

- **Count Licenses** runs one counter; job **SAM License Counters** runs all daily at 02:00 and picks up installs not scanned for 7 days. Results are cached; **Rebuild SAM Cache** (context menu) forces a recount.
- Result types: Entitled in use, Entitled not in use, Not entitled, Not allocated.
- **Immediate compliance** = extra rights needed now; **Planned compliance** takes unused entitlements into account.
- List colours: green compliant, orange within 5 %, red not compliant. **Software Asset > System > Check License Compliance** runs everything.
- Valuation 1 = a right is consumed; 0 = covered by a suite or by a multi-install right.

## Licences

- **Software Asset > Software Licenses**: **Model**, **Rights**, **License metric**, state and substate, **Allocated conditions** / **Assigned to condition**.
- Entitlements: **Add Entitlement**, or the related lists **Asset Entitlements** and **User Entitlements**; you cannot entitle more than the rights owned.
- Enterprise licence: a contract of **License type** Enterprise with the licence in **Assets Covered**: everyone is entitled and **Rights** shows 0. Subscription: **Agreement type** Subscription.
- **Merge with similar licenses**: irreversible; licences must match on model, conditions, company, location, department, cost centre, state, upgrades and covered assets; rights and costs are summed, entitlements moved; merged originals are no longer counted.

## Suites, upgrades and downgrades

- Suite: a software model with **Suite Components**. **Inference percent** = share of components that must be installed to infer the suite; **Inference mandatory** on a component makes it required. Result stored on the install as **Inferred suite**.
- Downgrade child: an older version counted against the parent's rights (limited to the parent's available rights); upgrade parent the reverse. Set on the model (all licences) or on one licence, with start and end dates. The child should have no counter of its own unless it has its own licence.

## IBM PVU and Oracle process packs

`com.snc.sam.ibmpvu.pp` and `com.snc.sam.oracle.pp`: no longer available on request. PVU: processor definitions are derived from the CI's **CPU type** (else CPU name), **CPU count**, **CPU core count**; rights used = cores × PVUs per core from the mapping (the most expensive mapping when no exact match). **Refresh Processor Definitions** once after activation.

## Property

`sam.install_deletion_deadline` (7 days): delete an install not rediscovered with its CI; keep it above the discovery interval.

## Related

- [[Asset Management Common Applications]] · [[Models, Model Categories and the Product Catalog]]
