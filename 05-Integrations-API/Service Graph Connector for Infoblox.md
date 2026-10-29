---
type: reference
tags: [reference, integrations, cmdb, discovery]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > Infoblox (about 640 cleaned lines, read 2026-10-29) - overview and upgrade notes, Configure using SGC Central, Configure using guided setup, Data mapping, Target CMDB classes (skimmed), Accessing connection details, Handling parallel data loading, Create table cleanup jobs, Life cycle management, Properties. https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/sgc-cmdb-integration-infoblox.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for Infoblox

**In one line:** Store app `sn_infoblox_integ` that imports **IP address management (IPAM)** data from Infoblox (network views, IP pools, IPv4 and IPv6 networks and subnets, allocated IPs, DNS aliases) into the CMDB and can raise IPAM tasks when networks appear or disappear.

From the Brazil docs (Infoblox WAPI v2.11.2; Yokohama, Zurich, Australia); not tested. Other IPAM sources: [[Service Graph Connector for BlueCat]], [[Service Graph Connector for Nautobot]]. General: [[Service Graph Connectors Overview]].

## Setting up the connection

SGC Central (connector 1.2.0+; prerequisites `admin`, setup `sn_cmdb_int_util.sgc_admin` or `admin`) > **Infoblox** > **Configure connection**. **Single connection** in SGC Central: the default **SG_Infoblox_Connection**.
1. **Configure and test connection**: name, Infoblox base URL, user name, password, MID Server only when there is no direct path.
2. Optional **Set configuration properties**: **Network view** (comma-separated; empty or `Default` = all views) and **API version** (the WAPI version).
3. Optional **Configure task preferences**: **Create task on network insertion**, **Create task on network deletion**, **Task user group** (by default an IP address management group; set per connection alias on **SG Infoblox Connection**).
4. Schedule the parent **SG-Infoblox IP Pool**.

The classic guided setup (being deprecated) holds the same settings as **Attributes** on the HTTP connection (`api_version`, `network_view`) and supports more Infoblox instances through the usual global access and cache-flush steps ([[Service Graph Connectors Overview]]) plus **Add Another Basic Auth Connection**. Do not migrate data from an older connector: uninstall it.

## Data sources (run in this order)

| Data source | Staging table | Targets |
|---|---|---|
| SG-Infoblox IP Pool (network containers) | `sn_infoblox_integ_sg_infoblox_ip_pool` | **Managed IP Pool** `cmdb_ci_ip_pool` |
| SG-Infoblox Network | **Detailed Subnetwork** `sn_infoblox_integ_sg_infoblox_detailed_subnetwork` | **Managed IP Network Subnet** `cmdb_ci_ip_network_subnet`, **Managed Network** `cmdb_ci_managed_network` |
| SG-Infoblox IP Address | `sn_infoblox_integ_sg_infoblox_ip_address` | **Allocated IP Address** `cmdb_ci_allocated_ip_address`, subnet, managed network |
| SG-Infoblox DNS Alias (CNAME records) | `sn_infoblox_integ_sg_infoblox_dns_alias` | **DNS Alias** `cmdb_ci_dns_alias` |

Which subnets get their IP addresses imported is decided per row by the **Get Ip Address** field on the Detailed Subnetwork table; set a global default with `sn_infoblox_integ.default_get_ip_address` (1.5.0+, default false) or include/exclude networks by regex.

## Properties

| Property | Kind | Default | Meaning |
|---|---|---|---|
| `api_version` | connection | | WAPI version |
| `network_view` | connection | empty | network views to import; empty = all |
| `sn_infoblox_integ.default_get_ip_address` | system | false | default for Get Ip Address |
| `sn_infoblox_integ.included_network_regex` / `excluded_network_regex` | system | empty | networks to include or exclude |
| `sn_infoblox_integ.parallel_loading_partition_size` | system | | max networks per partition (max **150**), 1.3.0+, for SG-Infoblox Network (partitioned by network view) and IP Address (by number of networks) |

## Version 1.5.0: soft deletion and cleanup

From **1.5.0**, CIs not seen in the latest pull get **operational status = retired** (Managed Network, IP Pool, Subnet, Detailed Network, Allocated IP Address). Source native keys now include the managed network, so **run a full load after upgrading**: every CI from 1.4.0 or earlier then becomes retired (KB2779014). To purge them, create **table cleanup jobs** ([[Table Cleaner]]):
- In scope **CMDB CI Class Models** (owner of the IPAM tables), one job per table (`cmdb_ci_managed_network`, `cmdb_ci_ip_pool`, `cmdb_ci_ip_network_subnet`, `cmdb_ci_allocated_ip_address`), **Age in seconds** 86400 (recommended; 0 = immediate), filter **Discovery source is SG-Infoblox AND Operational status is retired**.
- In the connector scope, one job on `sn_infoblox_integ_sg_infoblox_detailed_subnetwork` with **Operational status is retired**.
- Wrong filters can delete live CIs or other sources' CIs. Jobs run in the next maintenance window.

## Related

- [[Service Graph Connector for BlueCat]] · [[Service Graph Connector for Nautobot]] · [[Table Cleaner]] · [[Integration Commons for CMDB]]
