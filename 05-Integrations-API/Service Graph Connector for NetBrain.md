---
type: reference
tags: [reference, integrations, cmdb, discovery]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > NetBrain (about 170 cleaned lines, read 2026-10-29) - overview, Configure using SGC Central, Data mapping, Targeted CMDB classes, Properties. https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/sgc-integration-netbrain.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for NetBrain

**In one line:** Store app `sn_netbrain_integ` that imports network devices, switches and network adapters discovered by NetBrain (including which ESX servers connect to which switches) into the CMDB.

From the Brazil docs (Zurich, Australia, Brazil); SGC Central only; not tested. General: [[Service Graph Connectors Overview]].

## Setting up

SGC Central > **NetBrain**: **Create and test connection** (fields not listed) → **Set configuration properties** → **Configure import schedule** → **Confirm connection creation**.

## Data and classes

| Data source | Staging table | Targets |
|---|---|---|
| SG-NetBrain One IP | (not printed) | Device (`cmdb_ci_hardware`), Switch (`cmdb_ci_netgear`), Network Adapter (MAC, discovery source) |
| SG-NetBrain ESX Server-Switch | `sn_netbrain_integ_adt_staging` | Device, **IP Switch** (`cmdb_ci_ip_switch`) |

"ADT" appears to be NetBrain's data table feature (meaning unconfirmed).

## Connection properties

| Property | Default | Meaning |
|---|---|---|
| ADT Page size | 1000 | ADT records per request |
| ADT Endpoint | T10000M | ADT endpoint identifier |
| Page size | 50000 | records per request |

## Related

- [[Service Graph Connector for Nautobot]] · [[Service Graph Connector for ExtraHop]] · [[Service Graph Connectors Overview]]
