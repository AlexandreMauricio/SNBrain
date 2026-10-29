---
type: reference
tags: [reference, integrations, cmdb, assets]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > Tanium Atlas Endpoints (about 740 cleaned lines, read 2026-10-29) - overview, Configure the Tanium environment (service account, persona, API token), Configure using SGC Central, Data mapping, Targeted CMDB classes (skimmed), Supported resource types, Properties. https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/sgc-integration-tanium-endpoints.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for Tanium Atlas Endpoints

**In one line:** Store app (properties prefixed `sn_tanium_endpoint`) for ITAM that imports **user-facing endpoints** (computers and mobile devices) from Tanium with an API token. It does **not** import the Server class: if you need servers, use [[Service Graph Connector for Tanium]].

From the Brazil docs (Yokohama Patch 4, Zurich, Australia; connector 1.0.0 described); not tested. Also see [[Service Graph Connector for Tanium Atlas]].

## Tanium side (Tanium administrator)

1. An identity to bind the token to: a **service account** (recommended; **Administration > Permissions > Users**) or, only if service accounts are not allowed, a **persona** (**Administration > Permissions > Personas**).
2. Roles **Interact Basic User**, **Asset User**, **Gateway User** (they carry the Gateway API and sensor-read permissions); read access to any additional sensors and their content sets; **Computer Group** access, otherwise API calls return nothing.
3. **Administration > Permissions > API Tokens > New API Token**: notes, expiration **over 7 days** (ServiceNow rotates the token automatically every seven days), **Trusted IP Addresses** = the MID Server or instance IPs. Hand the token to the ServiceNow admin.

## Setting up the connection

SGC Central (prerequisites `admin`, setup `sn_cmdb_int_util.sgc_admin` or `admin`) > connector type **Tanium Endpoints**:
1. **Create and test connection**: connection name, host name, token, optional MID Server.
2. Optional **Configure additional sensors**: **Fetch sensors** fills **SG-Tanium-Endpoints Sensors**; set **Ingest** = true and **Type** = **Single line** (one record per device, flat attribute-value pairs) or **Multiline** (an array of records per device). The **normalized sensor name** (spaces removed, special characters replaced by underscores) is the JSON key to use in RTE mappings.
3. **Configure import schedule** (activate); if you added sensors, run the import once and finish the RTE mapping from the import set.
4. **Confirm connection creation**.

## Data sources and classes

| Data source | Staging table | Targets (Tanium sensor) |
|---|---|---|
| SG-Tanium-Endpoints Hardware-Software | `sg_tanium_endpoints_hardware_software` | Computer (computer name, serial, domain, CPU, OS, memory, **Is Virtual**), Disk (Physical disk), File System (Logical Disk), Handheld Computing Device (Mobile Devices), IP Address (Tanium Client IP Address), Key Value (**Custom Tags** only, of Custom / Extended Custom / Enhanced / Meta), Network Adapter (Asset Network Adapter), software (Asset SIU Installed Products for computers, Asset Installed Applications for handhelds) |
| SG-Tanium-Endpoints Usage | `sg_tanium_endpoints_usage` | Software Usage `samp_sw_usage` (Asset SIU Product Usage); needs SAM Professional `com.snc.samp` |
| SG-Tanium-Endpoints Remove Software | `sn_cmdb_int_util_remove_record` | transform-map record removal |

Software: Software + Software Instance without SAM, Software Installation with SAM.

## Properties

Connection: retry count (3), page size per REST call (50); names not printed on the page. System: `sn_tanium_endpoint.buffer_days_from_last_scan_for_hardware` (0) and `sn_tanium_endpoint.exclude_serial_number_for_certain_os` (true; AIX and Solaris). Connections: **All > Service Graph Connectors > Tanium Endpoints > Connections**.

## Related

- [[Service Graph Connector for Tanium]] · [[Service Graph Connector for Tanium Atlas]] · [[Service Graph Connectors Overview]] · [[Integration Commons for CMDB]]
