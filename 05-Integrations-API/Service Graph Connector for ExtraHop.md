---
type: reference
tags: [reference, integrations, cmdb, discovery]
status: outdated
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > ExtraHop (overview and Configure, about 360 cleaned lines, read 2026-10-29; configure steps skimmed). https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/cmdb-integration-extrahop.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for ExtraHop

**In one line:** The ServiceNow-hosted connector that pulled ExtraHop network-traffic data (devices and who talks to whom) into the CMDB. **Deprecated**: no longer supported or available for new activation; ExtraHop now hosts its own connector (KB0867184). Marked `outdated` for that reason.

From the Brazil docs (ExtraHop v7.9; ServiceNow Tokyo to Washington DC); not tested. General: [[Service Graph Connectors Overview]].

## What it did (for existing installations)

- Needs an ExtraHop **Discover** appliance (firmware 7.2+) with an API key for an unlimited-privilege user, and a Linux or Windows MID Server unless the appliance is public.
- Setup is older style: **All > Service Graph Connector ExtraHop > Setup** configures a **REST message** (base URL; API key in the **Authorization** header of the HTTP request) and tests the **Computer** and **Network Activity** HTTP methods (HTTP 200), then scheduled jobs.
- Staging: **ExtraHop Computer** (`sn_extrahop_integr_computer`), **ExtraHop Network Activity** (`sn_extrahop_integr_activity`). Targets: Hardware, IP Address, Network Adapter, and **CI Relationship** (`cmdb_rel_ci`) records built from observed traffic flows.

## Related

- [[Service Graph Connectors Overview]] · [[Service Graph Connector for NetBrain]] · [[Integration Options and Interfaces Overview]]
