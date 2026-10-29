---
type: reference
tags: [reference, integrations, cmdb, assets]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > Jamf (about 790 cleaned lines, read 2026-10-29) - overview with data mapping, Configure using SGC Central, Configure using guided setup (including multiple instances), Target CMDB classes (class and relationship lists), Accessing connection details, Configuring data synchronization, Properties. https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/cmdb-integration-jamf.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for Jamf

**In one line:** Store app (scope prefix `sn_jamf_integrate`) that reads macOS computers, iPhones and iPads, their disks, network data, apps and software usage from Jamf Pro through the Jamf Classic or Jamf Pro API, and loads them into the CMDB.

From the Brazil docs; not tested. Note the supported ServiceNow releases on this page are **Xanadu, Yokohama, Zurich** (other connector pages in the same guide list Yokohama, Zurich, Australia). General: [[Service Graph Connectors Overview]].

## Authentication (`auth_type`)

| Value | Jamf version | Credentials |
|---|---|---|
| `basic` | below 10.35 (Jamf no longer supports it) | user name and password |
| `bearer` (**default**) | 10.35+ | user name and password exchanged for a bearer token |
| `oauth` | 10.49+ | client ID and secret from Jamf Pro **API Roles and Clients**; set the token lifetime above 60 seconds (3600 suggested) |

The Jamf account or client needs read privileges on computers, mobile devices and related objects. A MID Server is optional.

## Setting up the connection

SGC Central (connector 2.13.0+; prerequisites `admin`, setup `sn_cmdb_int_util.sgc_admin` or `admin`):
1. **Select alias template**: **SG-Jamf OAuth Connection** (OAuth / client credentials) or **SG-Jamf Basic Connection** (basic or bearer).
2. **Configure and test connection**: name, connection URL (OAuth, pre-filled) or **Connection Host** (basic, host or IP without `https://`), credentials, optional MID Server.
3. Optional **Set configuration properties**: **Import managed application records only**, **Use JAMF Pro API**.
4. **Configure import schedule**: activate each job shown.

Classic guided setup (**All > Service Graph Connectors > Jamf > Setup**): first set global system property `com.glide.transform.json.max-partial-length` to **65536** (create it if missing), then basic/bearer credentials plus an HTTP connection (leave **Base path** empty to use the Jamf Pro API), or edit the default **SG-Jamf OAuth Connection**; check `auth_type`; **Test Load 20 Records** (HTTP 200 = fine; do not **Load All Records** during setup). More Jamf instances: the global application-access steps on `sys_data_source` and `scheduled_import_set` described in [[Service Graph Connectors Overview]], set `sn_jamf_integrate.auth_type`, **Add Connection** in Workflow Studio (`https://` only in the OAuth connection URL), then per connection set **Use JAMF Pro API** and **Jamf Pro 10.35 or higher**. By default **SG-Jamf Mobile Devices** is active and runs **SG-Jamf Computers** as its parent.

## Connection properties

| Property | Default | Meaning |
|---|---|---|
| `auth_type` | bearer | basic, bearer or oauth |
| `import_managed_apps_only` | false | true = only managed application records |
| `use_jamf_pro_api` | true | computers through the Jamf Pro API (paginated, faster) instead of Classic |
| `use_jamf_mobile_pro_api` | null | mobile devices through the Jamf Pro API (Jamf 11.4+) instead of Classic |
| `is_delta_enabled_for_computers` | false | delta pulls for SG-Jamf Computers; needs `use_jamf_pro_api` = true |
| `is_delta_enabled_for_mobiles` | false | delta pulls for SG-Jamf Mobile Devices; needs `use_jamf_mobile_pro_api` = true |

Delta sync exists from connector 2.14. For a full import set both delta properties to false, then back to true; leaving them false means a slow full pull every time.

## Data sources

| Data source | Staging table | Notes |
|---|---|---|
| SG-Jamf Computers | `sn_jamf_integrate_sg_jamf_computers` | |
| SG-Jamf Mobile Devices | `sn_jamf_integrate_sg_jamf_mobile_devices` | |
| SG-Jamf Lookup Mac Software Bundle Ids | an Integration Commons table (`sn_cmdb_int_util_mac_softwar...`, name cut off in the source) | run **before** Computers and Mobile Devices |
| SG-Jamf Remove Computers Software / Remove Mobile Software | own staging tables | delete software removed at the source (license reclamation) |
| SG-Jamf Software Usage | `sn_jamf_integrate_jamf_software_usage` | feeds **Software Usage** (`samp_sw_usage`) for reclamation rules |

## Classes

Computer `cmdb_ci_computer` (MAC, serial, CPU, DNS domain, FQDN, most recent discovery, OS, RAM, model, assigned to from top user), Handheld Computing Device `cmdb_ci_handheld_computing`, Disk (**Contains::Contained by**), Network Adapter and IP Address (**Owns::Owned by**), Printer `cmdb_ci_printer`, Serial Number, key values, **SG-Jamf Extension Attributes** (written `sn_jamf_integrate_extension_attributes` in the class list and `sn_jamf_integrate_extension_attribute` in the overview: unconfirmed variant), software (`cmdb_sam_sw_install` with SAM; `cmdb_ci_spkg` + `cmdb_software_instance` without). The class page relates Software Installation to **Server** (`cmdb_ci_server`) rather than Computer: unconfirmed. With several Jamf instances, use **Extension Attributes** and **Most recent discovery** to tell which instance a CI came from.

## Related

- [[Service Graph Connectors Overview]] · [[Service Graph Connector for Microsoft Intune]] · [[Software Asset Management Foundation Plugin]]
