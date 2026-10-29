---
type: reference
tags: [reference, integrations, cmdb, discovery]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > OpenTelemetry (about 780 cleaned lines, read 2026-10-29) - overview with data mapping, Configure (main steps), Target CMDB classes (skipped), Properties (names), Linking inferred services. https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/sgc-cmdb-integration-opentelemetry.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for OpenTelemetry

**In one line:** Store app (scope `sn_sg_lightstep`) that imports topology built from OpenTelemetry traces in **ServiceNow Cloud Observability** (formerly **Lightstep**): application services, Kubernetes objects, containers, images and the service dependency map, plus events. **Being prepared for deprecation from Australia**: hidden and not installed on new instances, still supported (KB0867184).

From the Brazil docs (ServiceNow Utah, Vancouver, Washington DC); guided setup only; not tested. General: [[Service Graph Connectors Overview]].

## Guided setup

**All > Service Graph Connectors > OpenTelemetry > Setup** (role `admin`; usual ITOM requirements, `sn_observability` installed first for events; do not migrate from an old connector version):
1. **Use OpenTelemetry**: prepare Cloud Observability per KB1527588; note projects, organisation and API key.
2. **Set up your organization**: the Cloud Observability organisation name (connection property).
3. **Set up the API key** (API Key Credentials) → **Test the connection** → **Get Projects** (fills the **Project properties** list).
4. Advanced (optional): **lookback time** in hours (default 12; should match the schedule frequency: each run reads from now minus lookback to now), **excluded projects**, project diagnostics, service map and stale-CI settings.

## Data

Each data source has a full and a **Delta** scheduled job:

| Data source | Staging table | Targets |
|---|---|---|
| OpenTelemetry Resources | `sn_sg_lightstep_resources` | Calculated Application Service, Kubernetes cluster, deployment, node, pod, StatefulSet, ReplicaSet, DaemonSet, job, cronjob, namespace; Server; Key Value |
| OpenTelemetry Pods | `sn_sg_lightstep_pods` | Kubernetes cluster and pod |
| OpenTelemetry Containers | `sn_sg_lightstep_containers` | Docker Container |
| OpenTelemetry Container Images | `sn_sg_lightstep_container_images` | Docker Image |
| OpenTelemetry Services | `sn_sg_lightstep_kubernetes_services` | Kubernetes Service |
| OpenTelemetry Dependency Map | `sn_sg_lightstep_dependency_map` (+ inferred services in `sn_sg_lightstep_inferred_service`) | Calculated Application Service and relationships |

**Inferred services** (remote services seen only from the caller's spans) cannot be identified automatically. A `cmdb_inst_admin` links each one to a CI under **All > Service Graph Connectors > OpenTelemetry > Inferred services** (set **Inferred service CI**); a rule then builds the relationships and service map entries. Inferred services not seen in the last scan are deactivated and their relationships deleted.

## Properties (system)

`sn_sg_lightstep.classes_to_inactivate_stale_records` (classes whose stale CIs are inactivated), `sn_sg_lightstep.events_for_unmatched_ci.enabled` (false), `sn_sg_lightstep.resource_api_num_rows` (2500), `sn_sg_lightstep.service_map_classes_to_exclude`, `sn_sg_lightstep.service_map_max_levels` (5), `sn_sg_lightstep.service_map_relationship_types_to_exclude`; plus lookback hours (12).

## Related

- [[Service Graph Connectors Overview]] · [[Service Instances (Application Services)]] · [[Service Graph Connector for Observability - Dynatrace]]
