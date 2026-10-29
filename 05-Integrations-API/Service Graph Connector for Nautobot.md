---
type: reference
tags: [reference, integrations, cmdb, discovery]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > Nautobot (about 200 cleaned lines, read 2026-10-29) - overview with data mapping, Configure using SGC Central, Target CMDB classes, Accessing connection details. https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/sgc-integration-nautobot.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for Nautobot

**In one line:** Store app `sn_nautobot_integ` that imports servers and IPAM data (namespaces, prefixes, IP addresses) from Nautobot, a network source-of-truth tool, into the CMDB.

From the Brazil docs (Zurich Patch 4, Australia, Brazil); SGC Central only; not tested. The overview's use-case sentence says it feeds **API Insights**, which looks copied from the Akamai page and does not fit the classes listed; unconfirmed. General: [[Service Graph Connectors Overview]].

## Setting up

SGC Central > **Nautobot**: **Create and test connection** (fields not listed) → **Set configuration properties** → **Configure import schedule** → **Confirm connection creation**. Connections: **All > Service Graph Connectors > Nautobot > Connections**.

## Data and classes

| Data source | Staging table | Targets |
|---|---|---|
| SG-Nautobot Server | `sn_nautobot_integ_sg_nautobot_server` | Server, Linux Server, Windows Server (CPU count, install status) |
| SG-Nautobot Namespace | `sn_nautobot_integ_sg_nautobot_namespace` | Managed Network `cmdb_ci_managed_network` |
| SG-Nautobot Prefixes | `sn_nautobot_integ_sg_nautobot_prefixes` | Managed IP Network Subnet `cmdb_ci_ip_network_subnet` |
| SG-Nautobot IP Address | `sn_nautobot_integ_sg_nautobot_ip_address` | Allocated IP Address `cmdb_ci_allocated_ip_address` |

## Related

- [[Service Graph Connector for Infoblox]] · [[Service Graph Connector for BlueCat]] · [[Service Graph Connector for NetBrain]]
