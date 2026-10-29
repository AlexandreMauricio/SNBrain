---
type: reference
tags: [reference, cmdb, assets, choice-list]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CSDM > Reference - Document and contract life cycle, Life-cycle of contracts, Tangible/physical life cycle, Life cycle of tangible/physical CIs, Retiring a service instance, Tangible/physical tables, Location life cycle, Life-cycle of locations, Intangible/logical life cycle, Life-cycle of intangible/logical entities, Intangible/logical tables, Product life cycle, Life-cycle of product entities (read in full through the docs site API 2026-10-29). Stage diagrams are images, not read. https://www.servicenow.com/docs/r/servicenow-platform/common-service-data-model-csdm/csdm-lifecycle-df-tangible-physical.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# CSDM Life Cycle Values Reference

**In one line:** the CSDM life cycle **stages** and their **stage statuses** for each of the five entity types, as listed in the Brazil docs. Labels only: the stored values (`value = label`) are not printed and may differ per instance.

How the pairs are used and synchronised: [[CSDM Life Cycle Stages and Synchronization]]. Which pairs a class may use is set in `life_cycle_control` (by entity type, aggregated down the class hierarchy).

## Tangible/physical (hardware CIs and assets)

"Tangible/physical" replaces the older label "Hardware". Statuses marked (CI) are CI-only per the docs.

| Stage | Statuses |
|---|---|
| Ideation | Under Evaluation, Pilot |
| Purchase | On Order, Preallocated |
| Design | Design, Chartered, Build |
| Inventory | Available, Reserved, Preallocated, Pending Repair (CI), Legal Hold (CI), Quarantine (CI) |
| Deploy | In Stock, Reserved, Pending Transfer, In Transit, Test |
| Operational | Pending Fulfillment, In Use, In Maintenance, End of Support, Pending Retirement |
| End of Operation (intermediate) | Pending Evaluation, Pending Return, In Transit, Pending Resale, Pending Certificate, Pending Disposal, Pending Donation, On Hold (suspended, blocked, paused) |
| Defective | In Stock, In Transit |
| Missing | Lost, Stolen |
| End of Life | Pending Disposal, In Transit, Pending Certificate, Disposed, Donated, RMA, Sold, Vendor Credit, Buyout, Lease Return |

Tables with this life cycle (from `cmdb_ci`): Accessory `cmdb_ci_acc`, Communication Device `cmdb_ci_comm`, Computer Peripheral `cmdb_ci_peripheral`, Computer Room AC `cmdb_ci_crac`, Display Hardware `cmdb_ci_display_hardware`, Facility Hardware `cmdb_ci_facility_hardware`, Hardware `cmdb_ci_hardware`, Imaging Hardware `cmdb_ci_imaging_hardware`, IP Device `cmdb_ci_ip_device`, Monitoring Equipment `cmdb_ci_monitoring_hardware`, Network Adaptor `cmdb_ci_network_adaptor`, Printing Hardware `cmdb_ci_printing_hardware`, Rack `cmdb_ci_rack`, Storage Device `cmdb_ci_storage_device`.

**Retiring a service instance** does not retire its hardware: the host may stay idle for reuse, or still serve other service instances (a shared database host). The service instance follows the logical life cycle, its hardware the tangible one.

## Intangible/logical (applications, services, licences, service instances)

| Stage | Statuses |
|---|---|
| Ideation | Under Evaluation, Pilot |
| Purchase | On Order, Preallocated |
| Inventory | Available |
| Design | Design, Chartered, Build |
| Deploy | Test |
| Operational | In Use, End of Support (still in use; not a reason to retire), Pending Retirement |
| End of Operation | On Hold (suspended, blocked, paused) |
| End of Life | Retired, Obsolete |

Business Application defines only Ideation, Design, Operational and End of Life, but shows inherited stages too.

Tables listed with this life cycle (about 75, from `cmdb_ci`) include Business Application, Business Capability, Business Process, Information Object, Service `cmdb_ci_service`, Cluster and cluster parts, Database and Database Catalog, DNS Name, Endpoint, Environment, IP Address and IP Network, load balancer pool/service/VLAN classes, OS-level virtualisation container and image classes, Package `cmdb_ci_os_packages`, Patch `cmdb_ci_patches`, SAN classes, storage controller/export/file share/pool/volume, UPS parts, VPC `cmdb_ci_vpc`, VPN `cmdb_ci_vpn`, WebSphere Cell. **The docs table has many garbled names** (spaces inside names, `Ib` for `lb`, `cmdb_cil_cluster_node`, `cmdb_ci_cloud_keu_pair`, `cmdb_ci_osiv_image`, `cmdb_CIM_profile`); they are not copied here, check `sys_db_object` when one is needed. It also lists "Cloud Mgmt Subnet" as `cmdb_ci_subnet` and "IP Phone" (`cmdb_ci_ip_phone`) among logical tables (unconfirmed).

## Product (product models)

| Stage | Statuses |
|---|---|
| Ideation | Under Evaluation, Pilot |
| Design | Chartered, Design, Planning (planning items from Strategic Portfolio Management) |
| Build & Integrate | Build (commit to packaged deliverable in non-production), In Production (final promotion to live) |
| Operational | Available, Pending Retirement, End of Support |
| End of Life | Retired (no new purchases or deployments), Obsolete |

## Document and contract (contracts, business process documents)

| Stage | Statuses |
|---|---|
| Ideation | Draft, Under Evaluation |
| Operational | In Use, Published, Renewal in Process, Renewed, Pending Retirement |
| End of Life | Expired, Retired |

## Location (`cmn_location`)

| Stage | Statuses |
|---|---|
| Ideation | Chartered, Build |
| Operational | Available, In Use, Pending Retirement |
| End of Life | Sold, Lease Return, Obsolete |

## Related

- [[CSDM Life Cycle Stages and Synchronization]] · [[CSDM Overview and Data Domains]] · [[Models, Model Categories and the Product Catalog]] · [[Contract Management]]
