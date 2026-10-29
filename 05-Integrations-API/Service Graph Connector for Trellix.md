---
type: reference
tags: [reference, integrations, cmdb, security]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > Trellix (about 460 cleaned lines, read 2026-10-29) - overview with data mapping and system property, Configure using SGC Central, Configure using guided setup, Target CMDB classes (class list). https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/sgc-integration-trellix.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for Trellix

**In one line:** Store app `sn_trellix_integ` that imports devices managed by Trellix (servers with their file systems, storage disks, network adapters, IPs and software) into the CMDB for security incident response and endpoint management.

From the Brazil docs (Washington DC, Xanadu, Yokohama); not tested. General: [[Service Graph Connectors Overview]].

## Setting up the connection

SGC Central (role `admin`) > **Create connection** > **Trellix**:
1. **Create and test connection**: connection name, connection URL, Trellix user name and password, **Use MID server** for an on-premises Trellix (the MID Server must already exist).
2. **Configure import schedule**: activate **SG-Trellix-Devices** (or **Execute Now**).

Classic guided setup (**All > Service Graph Connectors > Trellix > Setup** > Quick Start, being deprecated): **Basic Auth Credentials** (order 100 by default), **HTTP(s) Connection** (keep the default name **SGTrellix**; base URL like `https://<host>:<port>`; MID Server and MID application for on-premises; connection timeout in seconds; one active connection per alias), **Test Connection**, schedule.

## Data and classes

One data source, **SG-Trellix-Devices** → staging **SGC Trellix Device Import** (`sn_trellix_integ_sgc_trellix_device_import`) → **Server** `cmdb_ci_server`, File System, **Storage Disk** (`cmdb_ci_storage_disk`), Network Adapter, IP Address, software (Software Installation with SAM; Software + Software Instance without).

System property `sn_trellix_integ.getdevices_count` (integer, default 100): page size when fetching devices.

## Related

- [[Service Graph Connectors Overview]] · [[Service Graph Connector for Microsoft Defender for Endpoint]] · [[Service Graph Connector for SentinelOne]]
