---
type: reference
tags: [reference, integrations, cmdb, discovery]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > Observability-Datadog (about 370 cleaned lines, read 2026-10-29) - overview, Data mapping, Configure the connector, Target CMDB classes (class list), Properties. https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/sgc-cmdb-integration-datadog.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for Observability - Datadog

**In one line:** Store app (prefix `sn_datadog_integra`) that pulls Datadog hosts, the service catalog and service relationships into the CMDB, and connects Datadog **monitors** to ServiceNow through webhooks so alerts arrive as events.

From the Brazil docs (Yokohama, Zurich, Australia); guided setup only; not tested. General: [[Service Graph Connectors Overview]].

## Guided setup

Requirements as for other connectors (ITOM units, `com.snc.itom.discovery.license` activated, `com.snc.itom.license`, Integration Commons, CMDB CI Class Models, Datastream Action; `sn_observability` installed first only for events). Role `sn_cmdb_int_util.sgc_admin` or `admin`. Do not migrate from an older connector version.

**All > Service Graph Connectors > Observability Datadog > Setup**:
1. **Configure the Credentials**: keep the default connection name; Datadog base URL or IP, **API key** and **Application key**.
2. **Test Connection**.
3. Optional **Create Hosts Filter**: connection property **`hosts_filter`**, host tags as `key:value` pairs, comma-separated (for example `datadog:monitored,env:<environment>`).
4. **Configure the Webhooks and Monitors**: create a **Datadog Webhook** record (name, connection alias), **Synchronize Monitors**, then tick **Webhook Active** on each monitor that should send alerts.
5. Activate the imports under **Observability Datadog > Import Schedules**.

System property `sn_datadog_integra.datadog_enabled` (boolean, default false; meaning not described).

## Data and classes

| Data source | Staging table |
|---|---|
| SGO-Datadog Hosts | `sn_datadog_integra_datadog_hosts` |
| SGO Datadog - Services Catalog | `sn_datadog_integra_datadog_service_catalog` |
| SGO-Datadog application services | `sn_datadog_integra_datadog_application_services` |
| SGO Datadog - Service Relation | `sn_datadog_integra_datadog_service_relation` |

Targets: Server (CPU, disk), Network Adapter, IP Address, Key Value, Cloud Service Account, **Logical Datacenter**, Cloud Database and Cloud Load Balancer (**Hosted on::Hosts** the datacenter). The page does not list which classes the service catalog and relations feed.

## Related

- [[Service Graph Connectors Overview]] · [[Service Graph Connector for Observability - AppDynamics]] · [[Service Graph Connector for Observability - New Relic]]
