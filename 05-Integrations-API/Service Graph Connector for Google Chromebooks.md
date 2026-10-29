---
type: reference
tags: [reference, integrations, cmdb, assets]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > Google Chromebooks (about 360 cleaned lines, read 2026-10-29) - overview with data mapping, Configure connections (guided setup, multiple instances), Target CMDB classes. https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/sgc-cmdb-google-console.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for Google Chromebooks

**In one line:** Store app (also called the connector for **Google Console**; staging table prefix `sn_googleconsole_i_`) that imports ChromeOS devices managed in the Google Admin console into the CMDB as computers, with network adapters, IPs and software.

From the Brazil docs; not tested. The page's version table lists Google Console *last tested July 2024* and ServiceNow **Xanadu, Washington DC, Vancouver, Utah** (older than the other connectors in this guide). Only a **guided setup** is documented, no SGC Central playbook. General: [[Service Graph Connectors Overview]]. The certificate pattern matches [[Service Graph Connector for GCP]].

## Setting up the connection

Requirements: ITOM Visibility or Discovery subscription units, `com.snc.itom.license`; auto-installed Integration Commons and CMDB CI Class Models. Role `admin`. Scope picker set to the connector.

**All > Service Graph Connectors > Google Console > Setup** > **Quick Start**:
1. **Google Console Setup Instructions**: KB1516892 (Google service account and a JKS keystore; note the keystore password).
2. **Create X.509 certificate**: type **Java Key Store**, keystore password, attach `keystore.p12`, **Validate Stores/Certificates**.
3. **Configure the Connection**: edit the default **SG-GoogleConsole** connection (keep that alias name): service account email, keystore password, the JKS certificate → **Edit and Get OAuth Token**.
4. **Add configuration properties**: **Customer ID** limits the pull to one Google customer.
5. **Test Connection** (status Success).
6. Schedule **SG-GoogleConsole-ChromeDevices** (Active, Run = Periodically) and **Complete** the setup.

More Google tenants: global application access on `sys_data_source` and `scheduled_import_set` (see [[Service Graph Connectors Overview]]), a new X.509 certificate, **Add Connection** → **Create and Get OAuth Token**, properties, test, and activate the scheduled import created for that connection.

## Data and classes

One data source, **SG-GoogleConsole-ChromeDevices** → staging **`sn_googleconsole_i_sg_googleconsole_chromedevices`** → Computer `cmdb_ci_computer` (install status, model number, model, serial number, OS, operational status, OS version, assigned to), IP Address (from `lastKnownNetwork.ipAddress`) and Network Adapter (MAC), each **Owns::Owned by** the computer, and software: Software + Software Instance without SAM / SAM Foundation, Software Installation with either. Devices deleted in Google are marked as no longer present (wording cut off in the source; probably retired).

## Related

- [[Service Graph Connectors Overview]] · [[Service Graph Connector for GCP]] · [[Service Graph Connector for Jamf]]
