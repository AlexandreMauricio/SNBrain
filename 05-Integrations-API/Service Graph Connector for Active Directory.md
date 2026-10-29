---
type: reference
tags: [reference, integrations, cmdb, assets]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > Active Directory (about 370 cleaned lines, read 2026-10-29) - overview with data mapping, Configure connections (guided setup), Target CMDB classes. https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/sgc-ad-integration.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for Active Directory

**In one line:** Store app (scope `sn_sec_sgc_ad`) that reads **computer objects** from Microsoft Active Directory over LDAP and loads them, with their operating system as software, into the CMDB. It is not the user and group import: that is [[LDAP Integration]].

From the Brazil docs; the version table lists ServiceNow **Utah, Vancouver, Washington** and leaves the AD version blank, so this page looks dated. Only a guided setup is documented. Not tested. General: [[Service Graph Connectors Overview]].

## Requirements

ITOM Visibility or Discovery subscription units; activate `com.snc.itom.discovery.license`; `com.snc.itom.license`; auto-installed Integration Commons, CMDB CI Class Models, Datastream Action; **Observability Commons for CMDB** (`sn_observability`) only for event ingestion. Role `admin`.

## Guided setup

**All > Service Graph Connectors > Active Directory > Setup** > **Best Experience**:
1. **Configure Inactive threshold** (optional): system property **`sn_sec_sgc_ad.inactive_threshold`**, default **90** days. Computers whose activity matches the threshold are excluded from the import (exact rule cut off in the source: presumably computers not logged on for that many days).
2. **Update LDAP OU Definition** access: in global scope, allow the connector to use the **LDAP OU Definition** table (Application Access).
3. **Configure LDAP Server Details**: the shipped server record (for example **SGC-AD-computer**, with a computer OU): login distinguished name, password, starting search directory (e.g. `DC=<domain>`), LDAP server URL (`ldap://<host>:389/`), MID Server when the directory is not reachable from the instance.
4. **Test Connection** on the LDAP server record.
5. Optional **Add Multiple Instances**: Application Access on `sys_data_source` and `scheduled_import_set`, **Add Another LDAP Server** (type Active Directory, server name, URL, start directory, then login DN and password), test.
6. **Set up scheduled import jobs**: activate the scheduled data import. Defaults to keep: **Concurrent import** on, **Partition Method** Custom size, **Partition size** 15,000, pre- and post-import scripts on, **Use connection** off for the first run; Run = Once is handy for a first test, then **Execute now**.

Rule 6 reminder: the login password is a real secret; never write it into notes.

## Data and classes

| Data source | Staging table |
|---|---|
| SGC Active Directory Import | `sn_sec_sgc_ad_active_directory_import` |
| SGC Active Directory Computer | `sn_sec_sgc_ad_active_directory_computer` |

Targets: Computer `cmdb_ci_computer` (object ID, FQDN, checked out / check in, first discovered, OS, OS version) and software (Software, Software Instance, or Software Installation with SAM). The computer staging table keeps the raw AD attributes (account expires, bad password count and time, common and distinguished name, last logon, logon count, member of, object GUID, password last set, sAMAccountName, service principal names, user account control, USN changed and created, when changed, and similar). Some attribute names appear twice in two spellings (`Ms-DS-Supported encryption types` and `msds_support_ncryptiontypes`, `Service binding information` and `service_binding_information`): labels versus column names, unconfirmed.

## Related

- [[LDAP Integration]] · [[Set Up an LDAP Integration]] · [[Scheduled and Concurrent Imports]] · [[Service Graph Connectors Overview]]
