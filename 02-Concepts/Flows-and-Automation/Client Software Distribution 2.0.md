---
type: concept
tags: [concept, automation, integrations, service-catalog, assets, roles, ai, release-specific]
status: documented
source: ServiceNow Brazil docs, Workflow Data Fabric > Integration Hub > Build integrations > Integration Hub solutions > Client Software Distribution 2.0 application (overview, components installed), read 2026-10-30. Provider setup pages for Microsoft Endpoint Configuration Manager, Jamf and Intune, ordering, revocation and the integration guide listed, not read. https://www.servicenow.com/docs/r/integrate-applications/integration-hub/csd-app-2.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Client Software Distribution 2.0

**In one line:** a Store application that deploys and revokes software from Service Catalog requests through third-party management systems, using spoke flows, with leases and optional Software Asset Management licensing.

From the Brazil docs; not tested. Separate from [[Orchestration ROI and Client Software Distribution|the older CSD]]. Version 1.7.4 on the page.

## CSD and CSD 2.0

| | CSD | CSD 2.0 |
|---|---|---|
| Providers | SCCM | Microsoft Endpoint Configuration Manager, Jamf, Microsoft Intune |
| New provider | extension point scripts | subflows in Workflow Studio |
| Licensing | tied to SAM data | SAM tables or its own tables |
| Discovery | PowerShell cmdlets | REST, with pagination |
| Revocation | catalog requests; uninstall through SCCM from reclamation candidates | same, through all three providers |

To use SAM: **Client Software Distribution 2.0 > Properties** (`sn_csd.useSAMPlugin`).

## Components

Roles are written with a space: `sn_csd.CSD Admin`, `sn_csd.CSD User` (orders catalog items).

Tables: `sn_csd_provider`, `sn_csd_cat_item_fulfilment_config`, `sn_csd_software_config`, `sn_csd_application`, `sn_csd_software_product_model`, `sn_csd_req_software`, `sn_csd_license`, `sn_csd_entitlement`, `sn_csd_entitlement_user`, `sn_csd_entitlement_asset`, `sn_csd_lease_manager`, `sn_csd_lease_schedule`, `sn_csd_lease_execution`.

Properties named: `sn_csd.softwareInstallExpDay`, `sn_csd.softwareInstallIntervalHour`, `sn_csd.discoveryExeDay`, `sn_csd.lease_execution_interval`, `sn_csd.lease_end_notification`.

## AI agents

With **Now Assist for Integration Hub** (see [[Integration Hub Spokes Catalog]]): catalog item creation for Intune and Jamf only, and Configuration Manager agents for collections and application targets. Users need the CSD Admin role.

## Example

Admin defines configuration *Example Editor Install* for Intune, creates its software model and catalog item, and sets a lease. A user orders it, the spoke flow deploys it, and it is revoked when the lease ends.

## Related

- [[Orchestration ROI and Client Software Distribution]] · [[Integration Hub Overview and Subscription]] · [[Integration Hub Spokes Catalog]]
