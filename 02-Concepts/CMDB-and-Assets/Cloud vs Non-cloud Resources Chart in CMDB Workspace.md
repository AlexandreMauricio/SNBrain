---
type: concept
tags: [concept, cmdb, workspace, reporting, automation]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB Workspace, topics "Cloud vs Non-cloud resources chart", "Configure datacenters for Cloud vs Non-cloud resources", "Configure classes for Cloud vs Non-cloud resources", "Resume a disabled Cloud vs Non-cloud resources scheduled job", "Criteria in Cloud vs Non-cloud resources" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/cmdb-workspace.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# Cloud vs Non-cloud Resources Chart in CMDB Workspace

**In one line:** charts on the Home and Insights views of [[CMDB Workspace]] counting CIs and application services hosted on a cloud provider against those that are not, per key class.

## Needed for the chart to show data

- Table **Cloud Service Account** (`cmdb_ci_cloud_service_account`) exists.
- **Logical Datacenter** (`cmdb_ci_logical_datacenter`) holds at least one cloud datacenter.
- **Datacenter Types** (`sn_cmdb_ws_datacenter_type`) has at least one datacenter class classified as cloud. Pre-filled with common ones (for example Azure Datacenter, `cmdb_ci_azure_datacenter`). **Only providers with a row here are counted.**

## The charts

- **CI classes bar chart:** one bar per pair of class and type (Applications / Cloud). Each bar has its own scheduled job, run every 24 hours and staggered. Selecting a bar opens *Cloud vs Non-cloud CIs* and *CI Classes by Cloud Providers*; **Latest updates** shows each job's status and, for admins, lets jobs be activated or deactivated.
- **Application Services pie chart:** from `svc_ci_assoc`: **Cloud** (all member CIs cloud), **Non-cloud** (none), **Hybrid** (mixed), **Unknown** (some members not classified). Can lag behind the class chart.

## How a CI is classified

A CI counts as non-cloud when it is tied to no datacenter, or to a datacenter class typed non-cloud. Cloud paths per class (relationship in brackets):

| Class | Cloud when |
|---|---|
| Virtual Machine Instance (`cmdb_ci_vm_instance`) | VM (Hosted on) cloud datacenter (Hosted on) cloud service account |
| Server ([[cmdb_ci_server]]) | server (Virtualized by) VM instance, then as above. No VM instance relationship = non-cloud |
| Application (`cmdb_ci_appl`) | application (Runs on) server, then as server; or application (Hosted on) cloud datacenter |
| Database Instance (`cmdb_ci_db_instance`) | (Runs on) server, then as server; or directly to a cloud logical datacenter |
| Kubernetes Cluster (`cmdb_ci_kubernetes_cluster`) | (Hosted on) cloud logical datacenter. No datacenter relationship = non-cloud |
| Storage Volume (`cmdb_ci_storage_volume`) | (Hosted on) cloud logical datacenter. No datacenter relationship = non-cloud |
| Cloud Object Storage (`cmdb_ci_cloud_object_storage`) | always cloud (needs the [[CMDB CI Class Models App]]) |
| Cloud Service Account | always cloud; `datacenter_type` holds the datacenter class |

Totals for applications and database instances are cloud + non-cloud, which can be less than the table's row count (badly formed records fall out).

## Configure

Role `sn_cmdb_admin` for both.

- **Datacenters:** `sn_cmdb_ws_datacenter_type.list` > **New**: **Datacenter class** (a child of Logical Datacenter), **Type** (cloud or not), **Cloud Provider** (your label).
- **Classes shown:** `sn_cmdb_ws_insight_query_category.list` (**CMDB Insight Query Categories**): set **Active** per class/type pair. Independent of the state of the pair's scheduled job.

## Job limits

- Hard limits per job: **2 hours** and **500,000 records**; beyond either the job is stopped and shown as failed.
- A job that fails **3 days running** is disabled. Change the number with property `sn_cmdb_ws.insight.category.disable_after_failure` (add it to `sys_properties`).
- Resume a disabled job (role `cmdb_query_builder`, contained in the three CMDB Workspace roles): `sysauto_query_builder.list` (**Scheduled Email of Query Builders**) > set **Active** true.
- Job names: *Insight - Cloud Servers*, *Insight - Non-cloud Servers* and so on per class; *insight - cloud non-cloud aggregate* runs every 30 minutes.

## Related

- [[CMDB Modelling Guidelines for Hardware, Virtual Machines and Cloud]] · [[CMDB Workspace Reference - Properties, Roles, Jobs and Tables]]
