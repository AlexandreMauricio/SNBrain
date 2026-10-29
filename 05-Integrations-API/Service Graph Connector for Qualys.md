---
type: reference
tags: [reference, integrations, cmdb, security]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > Qualys (about 1,230 cleaned lines, read 2026-10-29) - overview with CI mapping rules, Configure connections, SGC for Qualys APIs (attribute comparison skimmed), Targeted CMDB classes (class list only). https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/sgc-qualys-integration.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for Qualys

**In one line:** Store app (scope `sn_sec_sgc_qualys`) that imports the hardware and software inventory Qualys holds (servers, cloud VMs on AWS and Azure, network interfaces, file systems, open ports, services, tags) into the CMDB, complementing Qualys asset discovery.

From the Brazil docs (ServiceNow **Utah, Vancouver, Washington**: page looks dated); guided setup only; not tested. General: [[Service Graph Connectors Overview]].

## Two Qualys APIs

| API | Licence | Notes |
|---|---|---|
| **Global Asset API v2** | Qualys **CSAM** (Cybersecurity Asset Management) required | default; includes **Hardware Category** and **OS Category**; preferred when feeding Security Posture Control |
| **Asset Management and Tagging API v2** | no CSAM needed | off by default; use only without CSAM access; no hardware or OS category |

Chosen per connection with property **`use_asset_management_and_tagging_api`** (true = Asset Management and Tagging API). Both bring AWS and Azure cloud details; the docs compare their attribute lists field by field.

## Class mapping rules

The target class is decided before transformation by rule tables, and the class is written into the import set row:
- **Hardware CI Mapping Rule**: hardware category 1 + category 2 → class.
- **Computer CI Mapping Rule**: OS name, OS category, OS category 2, OS publisher, OS product name → class.
- **Asset Management CI Mapping Rule** (for the tagging API): operating system and whether volume or processor info is present → class.

To let Qualys update attributes already owned by another source, add **reconciliation rules** ([[IRE Reconciliation, Data Refresh and Data Source Rules]]).

## Guided setup

**All > Service Graph Connectors > Qualys > Setup** > **Best Experience** (role `admin`; requirements as for other connectors plus `sn_observability` only for events):
1. **Configure Qualys authentication credentials**: Qualys user name and password (Basic Auth Credentials, Active).
2. **Configure Qualys HTTP Connection**: host without `https` (for example `qualysapi.qualys.com`); optional MID Server.
3. Set `use_asset_management_and_tagging_api`, then **Test Connection** (200 or 201).
4. Optional more Qualys accounts: Application Access on data source and scheduled import tables, **Add Connection** on **SG-Qualys Connections**, MID Server on the new HTTP connection, test.
5. Scheduled data import: Run = Once for a first test, **Use connection** off for the first run, **Concurrent Import** on, then **Execute Now**.

## Classes

Server `cmdb_ci_server`, Virtual Machine Instance, File System, Cloud Mgmt Network Interface `cmdb_ci_nic`, Cloud Network, Cloud Subnet, Availability Zone, AWS Datacenter, Azure Datacenter, Cloud Service Account, Image `cmdb_ci_os_template`, Hardware Type `cmdb_ci_compute_template`, software (Software, Software Instance, Software Installation). Extra detail tables: **SGC Qualys Asset Details**, **Asset Software Details**, **Asset Network Interface Details** (`sn_sec_sgc_qualys_asset_nic_details`), **Asset Processor Details**, **Asset Open Port Details**, **Asset Service Details**, **Asset Tag**, **Asset Cloud Tag** (all `sn_sec_sgc_qualys_asset_*`).

## Related

- [[Service Graph Connectors Overview]] · [[Service Graph Connector for Rapid7]] · [[Identification and Reconciliation Engine (IRE) Overview]]
