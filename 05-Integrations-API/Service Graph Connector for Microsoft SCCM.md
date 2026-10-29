---
type: reference
tags: [reference, integrations, cmdb, assets]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > Microsoft SCCM (about 960 cleaned lines, read 2026-10-29) - overview with data mapping, Configure using SGC Central, Configure using guided setup, Target CMDB classes, Upgrade to the latest version, Enable software editions, Accessing connection details, Configuring air gap connections (high-secure, low-secure, instance, test and full load). https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/cmdb-integration-sccm.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for Microsoft SCCM

**In one line:** Store app (scope prefix `sn_sccm_integrate`) that reads the SCCM / MECM SQL Server database over **JDBC through a MID Server** (or from files, in the air-gap variant) and loads computers, disks, network adapters, IPs, serials, software installs and software usage into the CMDB. Read-only on the SCCM side.

From the Brazil docs (SCCM/MECM 2503, 2509, 2603; Yokohama, Zurich, Australia); not tested. General: [[Service Graph Connectors Overview]]. Software side: [[Software Asset Management Foundation Plugin]].

## Requirements

- A SQL Server login on the SCCM database with **db_datareader** (or, with integrated authentication, the account running the MID Server agent needs db_datareader).
- A **Windows MID Server** (mandatory for integrated authentication, recommended for all JDBC connections); plugin **Integration - JDBC** (`com.snc.integration.jdbc`); auto-installed Integration Commons and CMDB CI Class Models.
- Role: prerequisites `admin`; setup `sn_cmdb_int_util.sgc_admin` or `admin`. With integrated authentication the **run as** user of the scheduled import needs `import_admin`.
- Multi-instance from connector **3.0.4**; air gap from **3.7.0**; SGC Central from **3.5.0**.

## Connection templates (SGC Central > Create connection > Microsoft SCCM)

| Template | Use |
|---|---|
| **SCCM JDBC Connection Credentials** | SQL user name and password; driver `com.microsoft.sqlserver.jdbc.SQLServerDriver` pre-set |
| **SCCM JDBC Conn Cred (Integrated Auth)** | Windows integrated authentication with domain credentials; MID Server mandatory |
| **SCCM Air Gap** | no direct path to SCCM: PowerShell export on a high-secure server, file transfer, MID Server on a low-secure server reads the files |

JDBC fields: connection name, query timeout and connection timeout (seconds, 0 = none), host, database name, override default port (SQL Server default **1433**), instance name, MID Server.

Playbook after the connection: **Configure properties** (optional) → **Customize data source SQL statement** (optional, per data source) → **Configure import schedule**: activate **<connection>-SCCM Computer Identity** (the parent).

## Properties and options

| Setting | Where | Effect |
|---|---|---|
| asset tags (`asset_tag` connection property = true) | connection | map SCCM asset tag into **Asset tag** on Computer |
| `sn_sccm_integrate.sccm_disks_managed` = true | system property, connector scope | avoid duplicate **Disk** (`cmdb_ci_disk`) records when Discovery also runs; existing disks change only after the next SCCM hardware scan |
| `sn_cmdb_int_util.transform_disk_name_to_discovery_format` = true | system property, **Integration Commons** scope | disk names become `Disk #<number>` |
| **Use last run datetime** | each data source | incremental pulls; clear it for a full pull, for the test load of Computer Identity, and **always** on the Removed Software data sources |

Network adapters without IP or MAC are skipped by default: remove the `where` clause from the **SG-SCCM Network** data source SQL to include them.

## Data sources

SG-SCCM Computer Identity (parent; asset tag, assigned user, DNS domain), Computer OU (OU name into **SG-SCCM Computer Related**, `sn_sccm_integrate_sccm_2019_computer_related`), Disk, Network, Operating System, Processor, Software, Removed Software, and the **Asset Intelligence** pair Software AI / Removed Software AI (use the AI pair if SCCM has Asset Intelligence, otherwise the plain pair), plus **SG-SCCM Last Discovered Update**, which runs last and sets **Most recent discovery** on computers from SCCM's last hardware scan. Removed Software supports license reclamation in SAM.

## Classes

Computer `cmdb_ci_computer` (serial, CPU details, asset tag, chassis type, default gateway, DNS domain, most recent discovery, OS fields, RAM, model, assigned to), Disk (**Contains::Contained by**), Network Adapter and IP Address (**Owns::Owned by**), Serial Number `cmdb_serial_number`, key values `cmdb_key_value`, software: Software Installation `cmdb_sam_sw_install` with SAM, or Software `cmdb_ci_spkg` + Software Instance `cmdb_software_instance` without; **Software Usage** written `samp_sw_usage` here, while [[Legacy Software Asset Management Plugin]] lists `cmdb_sam_sw_usage` (unconfirmed which table this connector fills; possibly SAM Professional versus legacy). Software installs carry SCCM group ID and SCCM timestamp.

## Software editions

Needs setup on the SCCM side first (KB0721360). Then activate the **Software Edition** scheduled import and data source and its transform **Update software install with edition**, and test with **Load All Records**.

## Upgrades

Data sources you customised come back as **skipped updates**: review them in the upgrade history (**Skipped Changes to Review**) and merge your SQL changes into the new versions. If SQL or mappings changed, clear **Use last run datetime** on all data sources and do a full pull (2.3 → 2.3.1 changed the software source native key, so at least Computer and Software must be pulled again). Remove the `last_run_datetime` value on the data sources after installing the latest version. When upgrading, deactivate the legacy **SG-SCCM Computer Identity** schedule; records named `SG-SCCM ...` are templates for per-connection copies, so do not use them directly.

## Air gap

1. **High-secure server** (can reach SCCM): download `SgSCCMHighSecureSetup.ps1` and `GetSCCMData.ps1` from the playbook, create an SCCM directory, run the setup script (log directory, host, database name, port, page size, credentials path, data directory names, credential prompt) to produce a JSON config; give the running account write and delete rights.
2. **Low-secure server** (has the MID Server): run `SgSCCMLowSecureSetup.ps1`; read and delete rights on the directory.
3. **Instance**: plugin **IntegrationHub Action Step - PowerShell**; template SCCM Air Gap; connection with MID Server, **Parent Directory**, optional **Archive Data After Retrieval** and archive path.
4. Test: `.\GetSCCMData.ps1 -configFilePath <path>` writes a sample file and a log saying the test load succeeded (a 403 means bad credentials or rights).
5. Full: `.\GetSCCMData.ps1 -completeLoad $true -configFilePath <path>` (old files deleted unless `-clean $false`), copy the directories to the low-secure server, and schedule both the export and the transfer to match the scheduled import. Test the connection from **All > Service Graph Connectors > SCCM > Connections**.

## Related

- [[Service Graph Connectors Overview]] · [[Service Graph Connector for Microsoft Intune]] · [[Integration Commons for CMDB]] · [[Connections, Credentials and Aliases]] · [[Import Sets - Data Sources, Staging Tables and Cleanup]]
