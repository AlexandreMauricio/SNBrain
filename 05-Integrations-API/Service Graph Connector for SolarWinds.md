---
type: reference
tags: [reference, integrations, cmdb, discovery]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > SolarWinds (about 1,120 cleaned lines, read 2026-10-29) - overview, Configure using SGC Central, Configuring air gap connections (skimmed; same pattern as SCCM), Data mapping, Properties. Guided setup and target class attributes skimmed. https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/cmdb-integration-solarwinds.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for SolarWinds

**In one line:** Store app (prefix `sn_solarwinds_inte`) that imports hardware, virtualisation, cloud and software inventory from **SolarWinds Orion** into the CMDB through a MID Server, with an **air gap** option for isolated networks.

From the Brazil docs (Orion 2019.4 HF6 or 2020.2.1 HF2 minimum; Washington DC, Xanadu, Yokohama); not tested. General: [[Service Graph Connectors Overview]].

## Setting up the connection

SGC Central (connector 2.6.0+; role `admin`) > **SolarWinds**:
1. **Select data source type**: **Standard** (direct access) or **Air gap** (2.5.0+).
2. Air gap only: **Download PowerShell scripts** and run them first (below).
3. **Create and test connection**: standard = name, Orion host, user name, password, **MID Server** and MID application (the form expects one); air gap = name, parent directory on the low-secure server, optional archive after retrieval and archive path, the MID Server on the low-secure server.
4. **Set configuration properties**: **SAM installed** if the SolarWinds **Server & Application Monitor** module exists (not ServiceNow SAM), **NPM installed** if **Network Performance Monitor** exists.
5. Schedule the parent **SG-Solarwinds Hardware** (or **Execute Now**).

**Air gap**: same design as [[Service Graph Connector for Microsoft SCCM]]: `SgSolarWindsHighSecureSetup.ps1` and `GetSolarWindsData.ps1` on a high-secure server that can reach Orion (JSON config, credentials file, data directories), `SgSolarWindsLowSecureSetup.ps1` on the low-secure server with the MID Server, the **IntegrationHub Action Step - PowerShell** plugin in the instance, a test run, then `GetSolarWindsData.ps1 -completeLoad $true` on a schedule plus a scheduled file transfer between the servers.

## Data sources

`SG-SolarWinds <name>` with staging tables `sn_solarwinds_inte_solarwinds_cmdb_<name>`: Hardware (parent), CPU, Disk, Network Adapter, Software, IIS, MS SQL Servers, Cloud, Cloud Volumes (and others not printed in the part read).

## Classes

Computer and servers by OS (Windows, Linux, AIX, Solaris, UNIX, **Hyper-V Server**), Hardware, **Network Gear** (`cmdb_ci_netgear`), VM Instance, Disk, Storage Volume, Network Adapter, IP Address, Serial Number; IIS (**Microsoft IIS Web Server** `cmdb_ci_microsoft_iis_web_server`, **IIS Virtual Directory** `cmdb_ci_iisdirectory`); **MS SQL Server** `cmdb_ci_db_mssql_server` and **MS SQL Database** `cmdb_ci_db_mssql_database`; cloud (Cloud Service Account, Availability Zone, Logical Datacenter, Cloud Network, Cloud Subnet, Image, Hardware Type); software (Software Installation with SAM, Software + Software Instance without); CI Relationship.

## Properties

`sn_solarwinds_inte.page_size` (10000) and `sn_solarwinds_inte.monetize.url` (a link to ServiceNow's ITOM licensing overview PDF).

## Related

- [[Service Graph Connector for Microsoft SCCM]] · [[Service Graph Connectors Overview]] · [[Integration Commons for CMDB]]
