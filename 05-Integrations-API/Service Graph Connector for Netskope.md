---
type: reference
tags: [reference, integrations, cmdb, security]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > Netskope (overview and Configure, about 90 cleaned lines, read 2026-10-29). No target-class page in this guide. https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/sgc-netskope-integration.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for Netskope

**In one line:** Store app that imports **Netskope Client** inventory (hardware and software of the devices running the client) into the CMDB through the Netskope **Get Client Data v1** API with an API key.

From the Brazil docs (Netskope client version 112; ServiceNow Washington, Xanadu, Yokohama); not tested. The guide has no class or data-mapping page for this connector, and the overview's monitoring sentence names *SentinelOne* (apparently copied from that page). Same setup shape as [[Service Graph Connector for SentinelOne]]. General: [[Service Graph Connectors Overview]].

## Requirements

ITOM Visibility or Discovery subscription units; Integration Commons, CMDB CI Class Models, **Discovery Core** (`com.snc.discovery.core`), `com.snc.itom.discovery.license` (activate), `com.snc.itom.license`, **Guided Setup** (`com.sn.ads.setup`), Data Stream (`com.glide.hub.action_type.datastream`), ITOM Patterns. Roles: Netskope **Viewer** for the key; ServiceNow `admin`.

## Guided setup

**Service Graph Connectors > Netskope > Setup** > **Best Experience**:
1. **Configure Netskope Authentication Credentials**: the Netskope **API Key**.
2. **Configure Netskope HTTP Connection**: the Netskope base URL.
3. **Test Connection**: status code 200.
4. Optional more tenants: allow data source and scheduled import creation (global Application Access), run the cache-flush background script ([[Service Graph Connectors Overview]]), add the connection, test it.
5. Scheduled data import for data source **SG-Netskope-Client**: Active, **Concurrent Import** on, Partition Method **Custom Size**, Partition Size **1000**, pre/post-import scripts left as they are, then **Execute Now**.

## Related

- [[Service Graph Connector for SentinelOne]] · [[Scheduled and Concurrent Imports]] · [[Service Graph Connectors Overview]]
