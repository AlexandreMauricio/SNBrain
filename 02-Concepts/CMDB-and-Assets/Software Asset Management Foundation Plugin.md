---
type: concept
tags: [concept, assets, cmdb, discovery]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Asset Management common applications > ITSM Software Asset Management > Software Asset Management Foundation plugin" (pp. 355-396), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Software Asset Management Foundation plugin

**In one line:** the ITSM-level software asset feature for Kingston and later (`com.snc.sams`, activated by ServiceNow on request): discovered installations are grouped into discovery models, normalised by hand, and reconciled weekly against **software entitlements** to give a compliance position per product.

Not the separately licensed SAM Professional (`com.snc.samp`), though it shares its tables. Roles `sam_user`, `sam_admin` (run reconciliation, administration). UI: classic **Software Asset** menu, or the store app **Software Asset Workspace** (`sn_sam_workspace`; switching is one-way).

## Flow

1. **Discover** installs into Software Installation (`cmdb_sam_sw_install`) with ServiceNow Discovery or SCCM. A business rule links each install to a discovery model (`cmdb_sam_sw_discovery_model`) keyed on discovered publisher + product + version, creating one if needed.
2. **Normalise** the discovery model: fill **Publisher**, **Product**, **Version** and select **Normalize** → status *Manually Normalized* (otherwise *New*). Only models with **Product type** = Licensable are reconciled (other values: Child, Driver, Not Licensable, Patch, Unknown).
3. **Software model** (`cmdb_software_product_model`): publisher, product and a **Discovery Mapping** (**Version condition** / **Edition condition** = starts with, is, is anything; platform; language; **Software installation condition**). Several discovery models can map to one software model (versions 10.1 and 10.2 → "starts with 10").
4. **Software entitlement** (`alm_license`): the rights you own.
5. **Reconciliation**: scheduled weekly, or **Software Asset > Reconciliation > Run Reconciliation** for one or all publishers (workspace: also by group and subgroup: Country, Department, Company, Region, Cost Center).

## Entitlement fields

| Field | Notes |
|---|---|
| **Software model**, **Asset tag** | |
| **License type** | *Full* or *Upgrade* (then **Upgraded Entitlements** lists the entitlements the rights come from; those are deactivated). Read-only after submit |
| **License duration** | *Perpetual* or *Subscription* with start and end date; state becomes In Use / Retired / On Order automatically from the dates |
| **Metric group** / **License metric** | Common: Per Device, Per Named Device, Per User, Per Named User; or a custom metric |
| **Agreement type** | Generic, or Enterprise Level Agreement (always Compliant, even with unlicensed installs) |
| **Purchased rights** → **Active rights** | Active rights become 0 when the state is Retired |
| **Allocations available** | active rights − sum of allocation quantities |
| **Cost** | needed for true-up and savings figures |

Related lists: **User Allocations** (`alm_entitlement_user`) or **Device Allocations** (`alm_entitlement_asset`) depending on the metric (total cannot exceed rights), **Downgrades/Upgrades** (other software models the rights also cover, with order and dates), **License Keys** (`samp_sw_license_key`, unique per entitlement), **Contracts**, **Expense Lines**. In the workspace an entitlement starts in *build* and counts only once **published** (*in use*); bulk import by Excel template.

## Software model extras

- **Software Model Lifecycles**: type Internal or Publisher; phase Pre Release, General Availability, Upgrade (internal only), End of Life, End of Support, End of Extended Support; dates and **Risk**.
- **Metric Attributes**: per metric, for example *Maximum installs per right*, *Maximum processors per right*, *Minimum cores per processor*, with a value or unlimited.
- **Suites**: components with **Mandatory** = Optional, Always Mandatory, Mandatory Group, plus **Inference percent**. Components of a detected suite are not counted individually. Known suites are created automatically from the discovery map.
- **Publish to Software Catalog**; **Show Matching Discovery Models**.
- Display name format: publisher + product + version + edition (property `glide.cmdb_model.display_name.shorten`).

## Results

**Reconciliation > Product Results** (`samp_product_result`) → **Software Model Results** → **License Metric Results**:

| Value | Meaning |
|---|---|
| Status | Compliant / Not Compliant |
| Unlicensed installs | installs covered by no entitlement |
| True-up cost | rights needed × average price per right |
| Over-licensed amount | cost of unused rights |
| Rights owned / used / unused | per metric |
| Allocated in use, Not allocated in use, Allocated not in use, Not allocated, Allocations needed | allocation breakdown |

**Remediation Options** are generated: Purchase Rights, Create Allocations, Remove Unallocated Installs, Remove Allocations; status New, In Progress, Complete, Void.

## Administration

- **Custom Software Products**: publisher + product for software missing from the library.
- **Custom License Metrics**: allocation type Device or User, reconciliation order for allocated and unallocated, a calculation script (server-side). Switch: `com.snc.samp.recon.enablecustommetrics` (default Yes). Debug: `com.snc.samp.debug`.
- **Edition override** on a software installation when the edition was not discovered (free text, must be exact; re-links the install to another discovery model).
- Other Discovery patterns: on the pattern, **Pre/Post Processing > Sync Installed Software**, plus a row in Software Installation Name Mapping (`cmdb_sam_sw_name_mapping`: class name, publisher, product). SQL Server, Exchange and Oracle Database are handled already.
- **Migrate Software Installs** copies earlier discovered packages (`cmdb_ci_spkg` / `cmdb_software_instance`) into `cmdb_sam_sw_install`; needed once if Discovery ran before the plugin.

## Migrating from the legacy plugin

Activation renames labels (Software License → **Software Entitlement**, User/Device Entitlement → **User/Device Allocations**, Rights → **Active rights**), moves licence keys to their own table, aggregates duplicate allocations into one record with a quantity, and **disables** software counters, the *SAM License Counters* job, auto-match and the old menu. Customised forms and lists may be skipped: review them in **System Diagnostics > Upgrade History** (**Resolve Conflicts > Revert to Base System**), then set **Product** and discovery mapping on each software model.

## Related

- [[Legacy Software Asset Management Plugin]] · [[Asset Management Common Applications]] · [[Models, Model Categories and the Product Catalog]]
