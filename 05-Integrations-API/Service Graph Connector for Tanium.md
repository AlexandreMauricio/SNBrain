---
type: reference
tags: [reference, integrations, cmdb, assets]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > Tanium (about 640 cleaned lines, read 2026-10-29) - overview with data mapping, Configure using SGC Central, Configure using guided setup (including multiple instances), Targeted CMDB classes (class list), Accessing connection details. https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/cmdb-integration-tanium.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for Tanium

**In one line:** Store app `sn_tanium_integ` that reads hardware, software, running applications and software usage from a **custom view in Tanium Asset** and loads computers and servers into the CMDB. It is the Tanium connector to use when you need **Server** data; see [[Service Graph Connector for Tanium Atlas Endpoints]] for the newer endpoint-only connector and [[Service Graph Connector for Tanium Atlas]].

From the Brazil docs (Tanium 1.9+ for hardware and software, 1.17+ for usage; ServiceNow Washington DC, Xanadu, Yokohama); not tested. General: [[Service Graph Connectors Overview]].

## Authentication

**Basic** (user name and password) or **token** (Tanium API token). **Tanium Platform 7.6.2+ accepts tokens only**: after upgrading the connector, switch existing connections to token; with several instances, deactivate the old basic-auth scheduled jobs and create new token connections. With tokens, the scheduled import's **Run as** user needs the **`connection_admin`** role. MID Server optional.

## Tanium side: the custom view

The integration reads a Tanium Asset view. In Tanium: **Modules > Asset > Views**, create the reserved **ServiceNow** view (**Create View > Create ServiceNow view**) if missing, copy it, and in the copy add all fields of the **SIU Product Usage** bucket, add Asset to **Last Seen** and Network Adapter to **Model**. Select that view in ServiceNow (**Select view** / **Set View**). The setup's ADM instructions are to be ignored: application dependency mapping is not supported.

## Setting up the connection

SGC Central (connector 1.7.0+; prerequisites `admin`, setup `sn_cmdb_int_util.sgc_admin` or `admin`): **Create custom view** (prerequisite, tick the confirmation) → **Select alias template** (Basic authentication / Token-based authentication) → **Configure and test connection** (name, host name, user and password or token, optional MID Server) → **Select view** → schedule the parents **<connection> - SG-Tanium Usage** and **<connection> - SG-Tanium Hardware and Software**.

Classic guided setup (**All > Service Graph Connectors > Tanium > Setup**, being deprecated): set the authentication-type system property to `basic` or `token`, edit the matching default connection in the `sn_tanium_integ` scope, test, set the view, activate the scheduled imports. Do not migrate data from an older connector version: uninstall it first. More Tanium instances: the global access and cache-flush steps in [[Service Graph Connectors Overview]] (this page writes the scheduled import table both `scheduled_data_set` and `scheduled_import_set`: unconfirmed variant), **Add Another Basic / Token Auth Connection**, connection properties (retry count, application page size, asset page size, view identifier stored on **SG Tanium Connection**), test, **Set view** per connection alias.

## Data sources

| Data source | Staging table | Targets |
|---|---|---|
| SG-Tanium Hardware and Software | `sn_tanium_integ_sg_tanium_import` | Computer, File System, Disk, IP Address, Network Adapter, Serial Number; software (Software + Software Instance without SAM, Software Installation with SAM) |
| SG-Tanium Applications | `sn_tanium_integ_sg_tanium_applications` | Application (`cmdb_ci_appl`), running process, TCP |
| SG-Tanium Usage | `sn_tanium_integ_sg_tanium_usage_import` | **Software Usage** (`samp_sw_usage`); only with **SAM Professional** (`com.snc.samp`) |
| SG-Tanium Remove Software | **Integration Commons Remove Record** (`sn_cmdb_int_util_remove_record`) | removes software not updated, transform-map method ([[Integration Commons for CMDB]]) |

From 1.8.0, system property `buffer_days_from_last_scan_for_hardware` (non-zero = days of buffer, 0 = off) removes software only when the hardware it sits on was scanned after the software's last scan, plus the buffer.

The connector does **not** create Virtual Machine Instance (`cmdb_ci_vm_instance`) CIs; it looks them up by object ID to relate to existing ones (sentence cut off in the source).

## Related

- [[Service Graph Connector for Tanium Atlas]] · [[Service Graph Connector for Tanium Atlas Endpoints]] · [[Software Asset Management Foundation Plugin]]
