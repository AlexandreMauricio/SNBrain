---
type: reference
tags: [reference, integrations, cmdb, assets]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > Microsoft Intune (about 900 cleaned lines, read 2026-10-29) - overview with data mapping, Configure using SGC Central, Configure using guided setup (deprecated from 2.7.0) including advanced data sources and multiple instances, Target CMDB classes (first classes read, rest skimmed). https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/cmdb-integration-intune.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for Microsoft Intune

**In one line:** Store app (staging tables `sn_intune_integrat_*`) that reads Intune-managed computers, mobile devices and discovered apps through Microsoft Graph and loads computers, handheld devices, network adapters, IPs, serial numbers and software into the CMDB.

From the Brazil docs (Graph API v1.0 and beta; Yokohama, Zurich, Australia); not tested. General: [[Service Graph Connectors Overview]]. Similar OAuth setup: [[Service Graph Connector for Microsoft Azure]].

## Microsoft side

App registration with client ID, secret, tenant ID, and **application** Graph permissions **DeviceManagementManagedDevices.Read.All**, **DeviceManagementApps.Read.All**, **User.Read.All**. URLs by cloud: Graph `https://graph.microsoft.com` (US Gov `graph.microsoft.us`, China `microsoftgraph.chinacloudapi.cn`, Germany `graph.cloudapi.de`); token `https://login.microsoftonline.com/<tenantid>/oauth2/v2.0/token` and regional equivalents. MID Server optional (only when no direct connection).

Requirements: ITOM Visibility or Discovery subscription units, `com.snc.itom.license`; auto-installed Integration Commons, CMDB CI Class Models, Datastream Action, IntegrationHub Zip step and JSON Parser step, SGC Central.

## Regular or advanced data sources

| Data source | Type | Loads |
|---|---|---|
| SG-Intune Computer | regular | Computer, **SG-Intune Computer Related** (`sn_intune_integrat_computer_related`), IP, serial number, software |
| SG-Intune Devices | regular | Handheld Computing Device (`cmdb_ci_handheld_computing`), serial, network adapter, **SG-Intune Device Related**, IP, software |
| SG-Intune Software | regular | software (discovered apps) |
| SG-Intune Device Reports | **advanced** | replaces Computer + Devices; only Wi-Fi IPv4 imported |
| SG-Intune Software Reports | **advanced** | replaces Software; includes **publisher** |

Software lands in Software and Software Instance without SAM, or **Software Installation** (`cmdb_sam_sw_install`) with SAM. Software deleted in Intune is deleted from the CMDB.

**Advanced** data sources (KB1641546): faster, fewer API calls, for large estates. Since 2.7.0 not available by default: choose them in SGC Central (`admin` required). They need the paid **IntegrationHub Professional Pack** (`com.glide.hub.integrations.professional`) and `glide.attachment.extensions` empty or including `zip, json`. Report trigger jobs **SG-Intune Trigger Device Reports** and **SG-Intune Trigger Software Reports** ask Intune to build reports; schedule the **SG-Intune Device Reports** import about **3 hours later**, and deactivate the regular scheduled imports.

## Setting up the connection

SGC Central (connector 2.5.0+; guided setup deprecated from **2.7.0**): select data source type → **Create and test connection** (name, connection URL, OAuth client ID, secret, token URL, optional MID Server) → **Configure properties** → (advanced) **Activate report trigger job** (scheduled script: name, active, run, time, run as) → schedule **<connection>-SG-Intune Devices**.

Connection properties (in **Service Graph Connection Properties**, `sn_cmdb_int_util_service_graph_connection_property`):

| Property | Default | Applies to | Meaning |
|---|---|---|---|
| `include_primary_user_details` | true | regular | true = **Assigned to** from the primary user (follows reassignment), false = the enrolling user; true is slower |
| `include_ip_address_details` | true | regular | true = fill **IP Address** (`cmdb_ci_ip_address`); slower |
| `api_version` | v1.0 | regular | Graph API version |
| `software_path` | device | regular | device or app: how apps and devices are matched; null = let the code decide |
| `user_lookup_field` | user_principal_name | both | user_principal_name or email_address, to find the assigned user |
| `device_report_chunks_count` / `software_report_chunks_count` | 1 / 16 | advanced | report chunks; 1, 16 or 256 |
| `export_apis_max_calls_before_wait` / `export_apis_wait_time_in_ms` | 8 / 120000 | advanced | throttling of the export APIs |

Multiple Intune tenants (2.1.1+): the global-scope access and cache-flush steps in [[Service Graph Connectors Overview]], plus for advanced data sources the same for **Scheduled Script Execution** (`sysauto_script`) and a form creating data sources and imports with an **Instance Prefix**, connection alias and run-as user. Unconfirmed variants on the same page: scheduled import table written `scheduled_data_set` and `scheduled_import_set`; scheduled script table written `sys_autoscript` and `sysauto_script`.

## Classes and relationships

Computer `cmdb_ci_computer` (name, serial number, disk space, manufacturer, OS, OS version, model, assigned to, chassis type) and Handheld Computing Device (adds IMEI, MEID, phone number, root access, carrier), each **Owns::Owned by** Network Adapter and IP Address, with references to the connector's related tables and to software installations. Add the **SG-Intune Computer Related** / **SG-Intune Device Related** related lists to the computer form to see Intune details.

## Related

- [[Service Graph Connectors Overview]] · [[Service Graph Connector for Microsoft SCCM]] · [[Software Asset Management Foundation Plugin]]
