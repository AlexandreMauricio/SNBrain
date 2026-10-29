---
type: reference
tags: [reference, integrations, cmdb, discovery]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > Observability-Dynatrace (about 1,770 cleaned lines, read 2026-10-29) - overview and upgrade note, Configure using SGC Central, Configure using guided setup (including multiple instances and Grail), Data mapping (data source names), Target CMDB classes (skimmed), Set up push notifications, Properties. https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/cmdb-integration-dynatrace.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for Observability - Dynatrace

**In one line:** Store app `sn_dynatrace_integ` that pulls hosts, processes, process groups, services, applications, Kubernetes, Docker and AWS / Azure cloud entities from **Dynatrace Classic** (v1/v2 APIs) into the CMDB, and sets up Dynatrace **problem notifications** that arrive as events.

From the Brazil docs (minimum Dynatrace SaaS 1.284; Yokohama, Zurich, Australia); not tested. General: [[Service Graph Connectors Overview]].

**Which Dynatrace connector?**
- This one: Dynatrace **Managed** (self-hosted) or **legacy SaaS**.
- [[Service Graph Connector for Observability - Dynatrace SaaS]]: the **third-generation** Dynatrace SaaS platform.
- Dynatrace also publishes its own "Service Graph Connector for Dynatrace", which is a different product.

**Before upgrading to 1.10.0+**: disable the reconciliation rules on tables extending **Application** (`cmdb_ci_appl`) (KB1649455).

## Setting up (SGC Central, connector 1.11.0+)

Prerequisites stage (role `admin`):
1. Optional: install **Observability Commons for CMDB** (`sn_observability`) for events.
2. Global Application Access (create, update, delete) on **Data Source** (`sys_data_source`), **Scheduled Data Import** (`scheduled_import_set`) and **Value** (`sys_variable_value`), then the cache-flush background script from [[Service Graph Connectors Overview]] extended with `sys_variable_value`.
3. With events: **Enable script access for event management**: copy the script include **EvtMgmtImpactManagerMediator** into global scope (**Insert and Stay**) with **Accessible from** = All application scopes, so the connector can call `SNC.ImpactManager`.

Setup stage (`sn_cmdb_int_util.sgc_admin` or `admin`):
4. **Create and test connection**: name, Dynatrace host name, **API key prefixed with `api-token `** (token scope at least **Read entities**, `entities.read`).
5. Optional **Set configuration properties**: management zone IDs or names, service types, tags, **Save REST response as attachment**.
6. Optional **Configure observability** → **Create problem notification**: creates "ServiceNow default Problem notification" and an alerting profile in Dynatrace.
7. Schedule **SGO-Dynatrace Hosts - <connection>**.

Guided setup (**All > Service Graph Connectors > Dynatrace Observability > Setup**, being deprecated) does the same and adds: multiple Dynatrace environments (**Add Connection** in Workflow Studio, then **Test Load 20 Records**), **Grail**-enabled tenants (an extra OAuth 2.0 client-credentials connection linked to the Service Graph connection record; property `grailEnabled` = true), and a one-off script to upgrade source native keys for multi-instance:

```javascript
// Scripts - Background, global scope; one-off, prefixes existing SGO-Dynatrace source native keys
// with the connection alias sys_id printed in the docs (check it matches your default connection)
var gr = new GlideRecord("sys_object_source");
gr.addQuery("name", "SGO-Dynatrace");
var grOR = gr.addQuery("id", "STARTSWITH", "HOST-");
grOR.addOrCondition("id", "STARTSWITH", "PROCESS_GROUP_INSTANCE-");
grOR.addOrCondition("id", "STARTSWITH", "PROCESS_GROUP-");
grOR.addOrCondition("id", "STARTSWITH", "SERVICE-");
grOR.addOrCondition("id", "STARTSWITH", "APPLICATION-");
gr.query();
while (gr.next()) {
    gr.setValue("id", "f379137e075820107add6a77c4a93538|||" + gr.getValue("id"));
    gr.update();
}
```

## Events

Problem notifications need a token that also has ReadConfig, WriteConfig, LogExport, metrics.read, settings.read and settings.write, logs.read. The notification is a webhook to `https://<instance>.service-now.com/api/sn_em_connector/em/inbound_event?source=SGO-Dynatrace` (the docs print the URL with `https://` twice). Manual alternative: in Dynatrace **Settings > Integration > Problem notifications**, a custom JSON payload with placeholders such as `{ProblemID}`, `{ProblemTitle}`, `{ProblemSeverity}`, `{ProblemImpact}`, `{ProblemURL}`, `{ProblemDetailsJSONv2}`.

## Data

Data sources are named `SGO-Dynatrace <entity>` with staging tables `sn_dynatrace_integ_sg(o)_dynatrace_*`: Hosts V2, Processes V2, Process Groups V2, Services V2, Applications (V2), Application Relationships, Custom Applications V2, Docker Container, Kubernetes cluster, namespace, node, pod, service; AWS (EC2, ELB, application/network LB, auto scaling group, Lambda, RDS, DynamoDB, S3, availability zone, datacenters, service account); Azure (VM, scale set VMs, function app, load balancer, Cosmos DB, SQL server, storage accounts, region, subscriptions). Several exist in V1 and V2 versions. Service types map to **Calculated Application Service** (`cmdb_ci_service_calculated`) except `DATABASE_SERVICE`, which maps to **Database Instance** (`cmdb_ci_db_instance`).

## Properties

| Property | Kind | Default | Meaning |
|---|---|---|---|
| `managementZoneIds`, `managementZoneNames`, `tags` | connection | | limit what is fetched |
| `serviceTypes` | connection | | BACKGROUND_ACTIVITY, CICS_SERVICE, CUSTOM_SERVICE, DATABASE_SERVICE, ENTERPRISE_SERVICE_BUS_SERVICE, EXTERNAL, IBM_INTEGRATION_BUS_SERVICE, IMS_SERVICE, MESSAGING_SERVICE, QUEUE_LISTENER_SERVICE, RMI_SERVICE, RPC_SERVICE, WEB_REQUEST_SERVICE, WEB_SERVICE |
| `grailEnabled`, OAuth Connection | connection | | Grail tenant and its linked OAuth alias |
| `saveRESTResponseAsAttachment` | connection | false | large payloads through the *SGO-Dynatrace Fetch Entities For Larger Payload* flow, saved as .json attachments |
| `flowDesignerTimeout` | connection | 600000 ms | flow, subflow, action timeout |
| `sn_dynatrace_integ.append_environment_id_to_service_name` | system | false | add the environment ID to service names |
| `sn_dynatrace_integ.createUnmatchedApplicationCIs` | system | true | unclassified processes become Application CIs |
| `sn_dynatrace_integ.populate_applications` | system | false | create Application CIs from processes (read only by **scheduled** imports) |
| `sn_dynatrace_integ.default_from_value_days` | system | 300 | days a CI may be inactive before it is ignored |
| `sn_dynatrace_integ.page_size` | system | 50 | REST page size |
| `sn_dynatrace_integ.critical_cluster_threshold` | system | 75 | % of cluster nodes in a state before it propagates to the parent in the service map (needs `sn_observability`) |
| `sn_dynatrace_integ.events_for_unmatched_ci.enabled` | system | false | ingest events without a matching CI (needs `sn_observability`) |

## Related

- [[Service Graph Connector for Observability - Dynatrace SaaS]] · [[Service Graph Connector for Observability - AppDynamics]] · [[IRE Reconciliation, Data Refresh and Data Source Rules]]
