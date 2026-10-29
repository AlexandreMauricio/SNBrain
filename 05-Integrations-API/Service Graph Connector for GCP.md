---
type: reference
tags: [reference, integrations, cmdb, discovery]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > GCP (about 3,550 cleaned lines, read 2026-10-29) - overview, Configure using SGC Central, Configure using guided setup, Handling import failures, Deep discovery, Life cycle management, Record removal, Properties (names scanned). Data mapping, target class and discovery comparison tables skimmed for class names only. https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/sgc-cmdb-integration-gcp.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for GCP

**In one line:** Store app `sn_gcp_integ` that reads a Google Cloud organisation or set of projects through the GCP REST APIs (no MID Server, no agents) with a service account and a Java KeyStore certificate, and optionally runs OS Config patch jobs for deep discovery of VMs.

From the Brazil docs (tested by ServiceNow on Yokohama, Zurich, Australia); not tested here. General: [[Service Graph Connectors Overview]].

## Requirements

ITOM Visibility or ITOM Discovery subscription units; plugins `com.snc.itom.discovery.license` (activate) and `com.snc.itom.license`; auto-installed Integration Commons for CMDB, CMDB CI Class Models, Datastream Action (`com.glide.hub.action_type.datastream`); **Observability Commons for CMDB** (`sn_observability`) only for event ingestion, installed **before** the connector. Do not migrate data from an old connector version: uninstall and run the new one. Role `sn_cmdb_int_util.sgc_admin` or `admin`.

## Setting up the connection

SGC Central (connector 1.8.0+) > **Create connection** > GCP:
1. **Review setup instructions** (KB1220598): create the GCP service account and a JKS keystore; note the keystore password.
2. **Create X.509 certificate** (type Java Key Store; upload `keystore.p12`; optional expiry notifications; **Validate Stores/Certificates**).
3. Optional **Download GCP deep discovery scripts** (Linux shell, Windows PowerShell; KB2213095).
4. **Create and test connection**: Connection Name, **Service Account Email**, **Keystore**, **Keystore Password**, **Organization Id**, **Discovery Scope** = Organization or Projects.
5. Optional deep discovery connection properties; schedule the parent **SG-GCP Organization** import.

Classic guided setup (**All > Service Graph Connectors > GCP > Setup**, planned for deprecation) edits the **SG-GCP Default Connection** in Flow Designer and uses **Edit and Get OAuth Token**. Adding more GCP organisations there needs the multi-instance steps described in [[Service Graph Connectors Overview]]. After upgrades, **Advanced Setup > Sync New Data source** > **Synchronize Datasources**.

## Deep discovery

Uses **OS Config patch jobs** per project. Upload the scripts to a Cloud Storage bucket, then set connection properties: Scripts Bucket Name, Outputs Bucket Name, Outputs Storage Path, Shell and PowerShell script object paths and **generation numbers**. Scheduled imports **SG-GCP Execute Patch Job** (two pending rows per project, Linux and Windows) and **SG-GCP Get Patch Job** (reads and deletes output; ADM fills server, processes, TCP, CPU) — [[Integration Commons for CMDB]] ADM adapter. Applications classified: Apache, MongoDB, SQL Server, MySQL, Nginx, Oracle listener and instance, PostgreSQL, Tomcat.

## Classes

Organisation `cmdb_ci_cloud_org`, folder `cmdb_ci_gcp_folder`, project `cmdb_ci_gcp_project`, service account, network `cmdb_ci_network` with ACLs and rules, subnet, availability zone, Google datacenter `cmdb_ci_google_datacenter`, VM instance, server, hardware type, images, NIC, IP, storage volume and snapshot, security group, load balancer with pool, member, health service and service, cloud database, cloud function `cmdb_ci_cloud_function`, object storage, Kubernetes cluster, node pool, node, pod, namespace, deployment, ReplicaSet, service, volume, cluster role and binding, Docker container and image, generic resources `cmdb_ci_cmp_resource`, software (`cmdb_ci_spkg`, `cmdb_software_instance`, `cmdb_sam_sw_install`), tags `cmdb_key_value`. BYOL/BYOS images get key values `Windows_OS_License_Type_automatic` / `Linux_OS_License_Type_automatic`.

## Deletion

- **Soft deletion** (connector 1.11.0+): Integration Commons record removal retires install and operational status of CIs not seen recently, using `sys_object_source` and connection properties **Use Record Removal** (true after the first post-upgrade run) and **lookback_time_in_days** (null on the first run, then 15: CIs not discovered for 15 days are retired). Source native keys now include the connection alias ID. Applies to folders, projects, networks, subnets, volumes, snapshots, security groups, VMs, load balancer parts, databases, functions, object storage and all Kubernetes data sources. **SG-GCP Generic Resource** uses the post-script method (1.10.0+).
- **Hard deletion**: **SG-GCP Software Inventory**.

## Tuning

- `sn_gcp_integ.save_rest_response_as_attachment` (on): avoid the 1,024 MB REST response limit.
- Batch size per data source (default 100): properties to **create** as integers, e.g. VM instance, network, subnet, Kubernetes parts, load balancer parts, software inventory. Unconfirmed variant: the import-failure page prints most names without the prefix (`sg_gcp_vm_instance_batch_size`), the properties page with it (`sn_gcp_integ.sg_gcp_vm_instance_batch_size`).
- Others: page sizes for listing folders, projects, resources, annotations; `sn_gcp_integ.add_inherited_tags`; `sn_gcp_integ.sg_gcp_generic_resource_type_dynamic_create`; `sn_gcp_integ.software_chunk_size`; retry count.

## Related

- [[Service Graph Connectors Overview]] · [[Service Graph Connector for AWS]] · [[Integration Commons for CMDB]]
