---
type: reference
tags: [reference, integrations, cmdb, security]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > SentinelOne (about 550 cleaned lines, read 2026-10-29) - overview, Configure connections, Targeted CMDB classes (class list and properties). https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/sgc-sentinelone-integration.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for SentinelOne

**In one line:** Store app `sn_sec_sgc_sntlone` that imports SentinelOne **agents** (the endpoints, servers and cloud VMs they run on) into the CMDB through the **Get Agents v2.1** API with an API key.

From the Brazil docs (ServiceNow Xanadu, Washington, Vancouver); guided setup only; not tested. Setup is the same shape as [[Service Graph Connector for Netskope]]. General: [[Service Graph Connectors Overview]].

## Guided setup

Requirements: ITOM units; Integration Commons, CMDB CI Class Models, Discovery Core, `com.snc.itom.discovery.license` (activate), `com.snc.itom.license`, Guided Setup `com.sn.ads.setup`, Data Stream, ITOM Patterns. Roles: SentinelOne **viewer**, ServiceNow `admin`.

**Service Graph Connectors > SentinelOne > Setup** > **Best Experience**: **Configure SentinelOne Authentication Credentials** (API key) → **Configure SentinelOne HTTP Connection** (base URL) → **Test Connection** (200) → optional more consoles (Application Access, cache-flush script from [[Service Graph Connectors Overview]], new connection, test) → scheduled data import (Active, concurrent import, partition method and size, then run).

## Classes

Computer, Server `cmdb_ci_server`, Virtual Machine Instance, Network Adapter, IP Address, Key Value, and cloud context: AWS, Azure and **GCP Datacenter** (`cmdb_ci_google_datacenter`), Availability Zone, Cloud Network, Cloud Subnet, Cloud Service Account, Image (`cmdb_ci_os_template`), Hardware Type (`cmdb_ci_compute_template`). Detail tables: **SentinelOne Additional Attributes** (`sn_sec_sgc_sntlone_additonal_attributes`, spelled *additonal* in the docs; AD computer and last-user groups and DNs, AD mail, agent decommissioned, agent operational state, last active date, missing permissions) and **SentinelOne Asset Tags** (`sn_sec_sgc_sntlone_asset_tags`).

System property `sn_sec_sgc_sntlone.api_page_size` (type string, default 1000): records per page.

## Related

- [[Service Graph Connector for Netskope]] · [[Service Graph Connector for Microsoft Defender for Endpoint]] · [[Service Graph Connectors Overview]]
