---
type: reference
tags: [reference, integrations, cmdb, discovery]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > BlueCat (about 230 cleaned lines, read 2026-10-29) - overview, Configure using SGC Central, Data mapping, Targeted CMDB classes, Properties. https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/sgc-integration-bluecat.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for BlueCat

**In one line:** Store app `sn_bluecat_integ` that imports IPAM data from BlueCat (configurations, networks and blocks, allocated IP addresses, IPv4 and IPv6) into the same CMDB IPAM classes Infoblox uses.

From the Brazil docs (Zurich Patch 4, Australia, Brazil); SGC Central only; not tested. Compare [[Service Graph Connector for Infoblox]]. General: [[Service Graph Connectors Overview]].

## Setting up

SGC Central > **BlueCat**: **Create and test connection** (fields not listed) → **Set configuration properties** → **Configure import schedule** → **Confirm connection creation**.

## Data and classes

| Staging table | Target |
|---|---|
| `sn_bluecat_integ_sg_bluecat_configuration` | **Managed Network** `cmdb_ci_managed_network` (correlation ID, short description) |
| `sn_bluecat_integ_sg_bluecat_blocks` and `sn_bluecat_integ_sg_bluecat_networks` | **Managed IP Network Subnet** `cmdb_ci_ip_network_subnet` (IP version, managed network, parent pool) |
| `sn_bluecat_integ_sg_bluecat_allocated_ip_address` (data source **SG-BlueCat-Allocated IP Address**) | **Allocated IP Address** `cmdb_ci_allocated_ip_address` (is DHCP, is DNS, is reserved, is broadcast) |

## Properties

| Property | Kind | Default | Meaning |
|---|---|---|---|
| IPv4 network type / IPv6 network type | connection | true / true | import IPv4 / IPv6 IPAM data |
| Chunk size for IP address retrieval | connection | 2 | networks per chunk for IP import; invalid values are auto-adjusted |
| `sn_bluecat_integ.included_network_regex` / `excluded_network_regex` | system | | networks to include or exclude |
| `sn_bluecat_integ.task_create_on_network_insert` | system | false | create a task when a network is inserted |

## Related

- [[Service Graph Connector for Infoblox]] · [[Service Graph Connector for Nautobot]] · [[Service Graph Connectors Overview]]
