---
type: concept
tags: [concept, automation, schema, roles]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > ServiceNow AI Platform Additional Capabilities > Classic Orchestration > Orchestration ROI (labor rate cards, automation entries, correlated task rules, time range, installed components, standard and premium reports) and Client Software Distribution (request, installed components, licences and counters, ordering, extend a lease, SCCM configuration, deployment, validation, revocation, dashboard, extension framework, keys and points), read 2026-10-29; report and field tables skimmed. https://www.servicenow.com/docs/r/servicenow-platform/orchestration/c_OrchestrationROI.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Orchestration ROI and Client Software Distribution

**In one line:** two Classic Orchestration add-ons: **Orchestration ROI** estimates and tracks savings from automating manual tasks (labor rate × task volume), and **Client Software Distribution** (CSD) deploys and revokes software ordered from the Service Catalog through a distribution tool such as **SCCM**, with leases and licence checks.

From the Brazil docs; not tested. Both depend on [[Classic Orchestration Overview and Activity Packs]] and use Classic Workflow.

## Orchestration ROI

Plugin `com.snc.runbook_automation.roi` (comes with Orchestration, without demo data; ask support to reinstall with demo data). Brings **Cost Management** `com.snc.cost_management` (labor rate cards). Role `orchestration_manager`. Set up in this order:

1. **Orchestration > ROI > Labor Rate Cards**: hourly rates for the manual work.
2. **Automation entry** (`automation_entry_form`): couples a rate card with the workflow that automates the task; estimated manual duration per task and times per month.
3. **Correlated task rule** (**Orchestration > ROI Task Correlation > Correlated Tasks Rules**, `manual_mapping_conditions`): entry, table and conditions that find the matching manual tasks (e.g. on `incident`, Subcategory is *Employee OnBoarding* and Short description contains *new employee*); matches stored in `manual_mapping_records` to compute real duration and volume.
4. **Time Range for Calculated Averages** (default: the last month) > **Calculate**.

Other tables: `run_rate_predicted_savings` (predicted savings report), `savings_report` and `detailed_savings_report` (automations run, estimated and calculated savings), `roadmap_planning` (hours to build, target automation %, start month).

Reports: **Orchestration > ROI Reports > Dashboard** (standard: summary, estimated and calculated costs) and **Premium Dashboard** (`com.snc.runbook_automation.roi_premium`, needs Performance Analytics Premium, separate subscription, and its scheduled collection job; savings over time by category).

## Client Software Distribution

Plugin `com.snc.orchestration.client_sf_distribution` (by request with an Orchestration subscription). Brings the SCCM activity pack `com.snc.orchestration.sccm_mgnt`, Asset Lease Management `com.snc.orchestration.asset_lease_management` (lease start, stop, extend), the scoped Service Catalog API `com.glideapp.servicecatalog.scoped.api`, and Software Asset Management `com.snc.software_asset_management`. Admin role `sn_client_sf_dist.csd_admin`.

**Set up with SCCM** (**Configuring SCCM**, in order): give an SCCM user the Application Administrator role; update the SCCM cmdlet library; configure a Windows MID Server for SCCM; create Windows credentials; run the retrieval workflow from the **SCCM Server Instance** record (applications, collections, deployments); link each SCCM application to a **software model**; define an **SCCM configuration** (application, install and uninstall collections, Discovery model); create the **catalog item** (options *Skip approval*, *Check license compliance*).

**Ordering and deployment**: workflow *Order Client Software* (manager approval unless skipped; licence check, and a catalog task to buy licences if none is free; available = licence valuation above 0 and type *Not allocated*, from a software counter in Software Asset Management) triggers *Deploy SCCM Application*, which removes the user or device from the uninstall collection if present and adds it to the install collection. Every request needs a lease start date.

**Validation**: Discovery or the SCCM integration plugin fills **Software Installation** (`cmdb_sam_sw_install`); scheduled job *Reconcile Requested Software* moves statuses *Not installed* > *Installed* or *Status check expired*; also *Revoked*.

**Revocation**: *Revoke Client Software* (UI action on the requested software or on *Installed Software Not Entitled*) calls *Revoke SCCM Application*, moving the user or device to the uninstall collection; works without user interaction and even for software installed by other means.

**Leases**: users go to **Service Catalog > My Requested Software** > record > **Extend** (related link) and pick a later end date; may need approval; if not approved before the end date the software is revoked. End-of-lease notification is sent ahead of the end (sent at once if the new end is within that period).

| Property (**Client Software Distribution > Properties**) | Default | Meaning |
|---|---|---|
| `sn_client_sf_dist.softwareInstallExpDays` | 30 days | how long to keep checking for installation |
| `sn_client_sf_dist.softwareInstallIntervalHour` | 1 hour | reconcile job interval |
| `sn_client_sf_dist.discoveryExeDay` | | days between scheduled application Discovery (runs at midnight) |
| `sn_client_sf_dist.lease_execution_interval` | | minutes between *CSD Lease Schedule* runs |
| `sn_client_sf_dist.lease_end_notification` | 5 days (lease page) | days before lease end to notify |

Tables: `sn_client_sf_dist_cat_item` (extends `sc_cat_item`), `sn_client_sf_dist_req_software`, `sn_client_sf_dist_application`, `sn_client_sf_dist_provider`, `sn_client_sf_dist_extension_key`, `sn_client_sf_dist_extension_point`, `sn_client_sf_dist_software_config` (base for provider configurations), `sn_client_sf_dist_cmdb_ci_sccm_server` (extends `cmdb_ci`), `sn_client_sf_dist_sccm_application`, `sn_client_sf_dist_sccm_app_cat_item`, `sn_client_sf_dist_sccm_collection`, `sn_client_sf_dist_sccm_deployment`, `sn_client_sf_dist_sccm_sf_config`. Script includes include `SoftwareCatItemCreator` (used by the **Create Catalog Item** UI action).

**Other providers** (Casper, Altiris, LANDesk; advanced, see the CSD Extension Implementation Guide): **Client Software Distribution > Extensions > Providers**: provider server table (extend `cmdb_ci`), discovery flow, software configuration table (extend `sn_client_sf_dist_software_config`), deployment and revocation flows, and **extension keys** (e.g. `SetDeploymentData`) with **extension points** holding the provider code. A CSD dashboard gives visual reports.

## Unconfirmed variants

- CSD procedure pages ask for role `sn_client_sf_dist` (eight pages), the components page names `sn_client_sf_dist.csd_admin`.

## Example

Catalog item *Example Diagram Tool* for an SCCM application with install collection *Example Install* and uninstall collection *Example Uninstall*, *Check license compliance* on, 90-day lease.

## Related

- [[Classic Workflow Overview]] · [[MID Server Overview and Architecture]]
