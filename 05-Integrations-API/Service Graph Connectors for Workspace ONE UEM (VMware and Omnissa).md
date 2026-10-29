---
type: reference
tags: [reference, integrations, cmdb, assets]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > VMware Workspace ONE UEM (overview, Configure, Targeted CMDB classes, about 560 cleaned lines) and Omnissa Workspace ONE UEM (overview, Configure using SGC Central, Data mapping, Targeted CMDB classes, Properties, Accessing connection details, about 250 lines), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/cmdb-integration-workspace-one.html and https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/sgc-integration-omnissa-works.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connectors for Workspace ONE UEM (VMware and Omnissa)

**In one line:** Two Store apps import devices and apps from Workspace ONE Unified Endpoint Management into the CMDB: the older **VMware Workspace ONE UEM** connector (scope prefix `sn_vmwoneuem_integ`, guided setup) and the newer **Omnissa Workspace ONE UEM** connector (prefix `sn_omnwoneuem_inte`, SGC Central only). Omnissa is the company that took over Workspace ONE from VMware.

From the Brazil docs; not tested. The docs do not say whether the Omnissa connector replaces the VMware one or how to migrate (open question). General: [[Service Graph Connectors Overview]]. Similar sources: [[Service Graph Connector for Microsoft Intune]], [[Service Graph Connector for Jamf]].

## VMware Workspace ONE UEM connector

Supported: Workspace ONE UEM 2506 (25.6.961.16), ADM API v2; ServiceNow Yokohama, Zurich, Australia. Use cases: hardware and app inventory for Android, Apple and Windows devices, BYOD or corporate compliance tracking, ownership.

**Requirements:** ITOM Visibility or Discovery subscription units; activate `com.snc.itom.discovery.license`; `com.snc.itom.license`; auto-installed Integration Commons, CMDB CI Class Models, Datastream Action. Role `sn_cmdb_int_util.sgc_admin` or `admin`.

**Guided setup** (**All > Service Graph Connectors > Workspace ONE UEM > Setup**):
1. Connection property **`auth_type`** = `basic` or `oauth`.
2. Basic: credentials (UEM user name and password) **plus an API key** (UEM API key or tenant code). OAuth: client ID and secret (token URL from the UEM admin).
3. **Configure HTTP connection**: the UEM host name.
4. **Test Connection**, then activate **SG-Workspace ONE UEM Devices and Apps** (inactive by default; Run = Periodically).
5. More UEM instances: global application access on `scheduled_import_set` and `sys_data_source`, the cache-flush background script ([[Service Graph Connectors Overview]]), **Add Connection** with URL `https://<host-name>/API` (basic: then set the API key record for that alias; OAuth: **Create and Get OAuth Token**), test, activate the schedule.

**Optional settings:**
- **CMDB Duplicate Row Rule** for the import: activate it (value true) and list fields that change on every import in **Ignore Fields**.
- Software import is **off** by default: set connection property `turn_off_software_import` = false.
- `managed_apps_only`: by default apps with **IsManaged** false are skipped; set false to import them.
- `import_apps_with_status`: comma-separated app status values, default **2, 3, 5** (1 Pending Install, 2 Installed, 3 Pending Removal, 4 Removed, 5 Unknown).

**Data:** one staging table `sn_vmwoneuem_integ_devices_and_apps` → Computer, Handheld Computing Device, Media Player (`cmdb_ci_media_player`), Network Adapter, Printer, Serial Number, software (Software Installation if `com.snc.sams` is installed, otherwise Software + Software Instance). Owner, ownership type and compliance state go to **SG-Workspace ONE UEM Device Related** (`sn_vmwoneuem_integ_device_related`, e.g. `compliance_state`, `device_ownership`); switch the CI form to the **SG-Workspace ONE UEM** view to see them.

## Omnissa Workspace ONE UEM connector

Supported: **Zurich Patch 4, Australia, Brazil**. SGC Central > connector type **Omnissa**: **Create and test connection** (fields not listed) → **Set configuration properties** → **Configure import schedule** → **Confirm connection creation**. Connections: **All > Service Graph Connectors > Omnissa > Connections**.

| Data source | Staging table | Targets |
|---|---|---|
| SG-Omnissa WS1 Device | `sn_omnwoneuem_inte_sg_omnissa_ws1_device` | Handheld Computing Device, Computer, Media Player, Printer, Hardware (`cmdb_ci_hardware`), Network Adapter |
| SG-Omnissa WS1 Apps | `sn_omnwoneuem_inte_sg_omnissa_ws1_apps` | Software, Hardware |
| SG-Omnissa WS1 Usage | `sn_omnwoneuem_inte_sg_omnissa_ws1_usage` | (target printed as the data source name) |
| SG-Omnissa WS1 Remove Software | `sn_cmdb_int_util_remove_record` | Software removal |

Attributes: model, OS version, serial number, MAC, **Assigned to**, phone number (handhelds). Hardware **Owns::Owned by** Network Adapter. Connection properties: `hostname` (host URL used to create, run, track and download **reports**, so this connector seems report-based), `managed_apps_only` (default false, same meaning as above).

## Related

- [[Service Graph Connectors Overview]] · [[Service Graph Connector for Microsoft Intune]] · [[Service Graph Connector for Jamf]] · [[Integration Commons for CMDB]]
