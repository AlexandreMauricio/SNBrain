---
type: reference
tags: [reference, integrations, cmdb, discovery]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > Microsoft Azure (about 2,820 cleaned lines, read 2026-10-29) - overview, Configure using SGC Central, Additional features (multiple connections, partition size, data synchronization, VM insights), Record removal, Properties (scanned). Guided setup, data mapping, target classes, supported resource types and the discovery comparison skimmed for class names. https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/cmdb-integration-azure.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for Microsoft Azure

**In one line:** Store app (properties prefixed `sn_sg_azure_integ`) that pulls Azure subscriptions, networks, VMs, storage, databases, functions, AKS and generic resources via the Azure Management APIs (full pull) and Azure Resource Graph (delta), with an optional second **software** connection to a Log Analytics workspace for TCP, processes and software.

From the Brazil docs (supported on Yokohama, Zurich, Australia); not tested. General: [[Service Graph Connectors Overview]].

## Azure prerequisites

- An Azure app registration: **client ID**, **client secret**, tenant ID (OAuth client credentials, [[OAuth 2.0 Outbound - The Instance as OAuth Client]]).
- Hardware: Microsoft Graph **User.Read** permission and the **Reader** role on each subscription.
- Software: Log Analytics API **Data.Read**, a Log Analytics workspace, and **VM insights** enabled for the VMs (data collection rule including processes and dependencies) so the **VMConnection** and **VMProcess** tables fill (data sources **SG-Azure TCP** and **SG-Azure VM Config Data**).

## Setting up the connection

SGC Central (connector 1.9.0+; prerequisites `admin`, setup `sn_cmdb_int_util.sgc_admin` or `admin`) > **Create connection** > Microsoft Azure:
1. **Review setup instructions**.
2. **Select services**: **Hardware only** (default) or **Hardware and software** (software needs a hardware connection).
3. **Create and test hardware connection**: name, connection URL (pre-filled), OAuth client ID and secret, **OAuth token URL** by cloud: global `https://login.microsoftonline.com/<tenantid>/oauth2/v2.0/token`, US Government `login.microsoftonline.us`, China `login.partner.microsoftonline.cn`, Germany `login.microsoftonline.de`.
4. Schedule **<connection>-SG-Azure Subscriptions**.
5. If software: **Create and test software connection** (URL `https://api.loganalytics.io/v1/workspaces/<workspace_id>`, same OAuth details) and schedule **<connection>-SG-Azure TCP** plus any other inactive parent imports.

**Multiple connections**: hardware and software connections are strictly **one-to-one**, so N workspaces need N software and N hardware connections, told apart by connection alias. Classic path: guided setup > Workflow Studio **Add connection**.

## Delta synchronization

`sn_sg_azure_integ.is_delta_sync_enabled` (default true) imports only changes since **Last Success Import Time** (hardware) or **Last Run Datetime** (software), updated only after a successful run. Set to **false** to force a full import (the SGC Central page also says to set it to false after the initial import: unconfirmed which is intended). Grace time, page size, preceding period and API call duration are tunable by properties. After upgrading the connector, run a full load.

## Deletion

Full loads use Integration Commons record removal on `sys_object_source` (install status set to retired); delta loads follow Azure's own change feed. From 1.14.0 life cycle covers subscriptions, resource groups, availability zones, networks, NICs, public IPs, security groups, load balancers, VMs, scale sets, storage accounts and volumes, SQL, functions, AKS clusters, generic resources; the first full load after upgrading to 1.14.0 retires everything not found.

## Parallel loading

Connection property **azure_full_pull_partition_size** = number of subscriptions per parallel job in a full pull (null = computed by Integration Commons). Supported data sources: VMs, network, storage volume (1.11.0+); functions, generic resources, run command, hardware template update, HW consolidation, AKS, load balancers, NICs, public IPs, scale set VMs (1.13.0+). With parallel loading on, **Test Load 20 Records** and **Load All Records** no longer work: use **Execute Now** on the scheduled import.

## Classes

Service account (subscription) `cmdb_ci_cloud_service_account`, resource group `cmdb_ci_resource_group`, Azure datacenter `cmdb_ci_azure_datacenter`, availability zone, network, subnet, NIC, IP, public IP `cmdb_ci_cloud_public_ipaddress`, LB IP, load balancer, security group, VM instance, scale set `cmdb_ci_instance_scale_set`, hardware type, images, servers (Windows, Linux), storage account `cmdb_ci_cloud_storage_account`, volumes, cloud database, function, web server `cmdb_ci_cloud_webserver`, AKS cluster, generic resources, applications, software (`cmdb_ci_spkg`, `cmdb_software_instance`, `cmdb_sam_sw_install`), serial numbers, tags `cmdb_key_value`.

## Other properties seen

`sn_sg_azure_integ.network_page_limit` (100), `sn_sg_azure_integ.insert_short_lived_vms` (true), `sg_azure_generic_resource_type_dynamic_create` (false; true creates generic resource types dynamically), `sn_cmdb_ci_class.use_single_cloud_os_image` (false; true uses Cloud Image `cmdb_ci_cloud_os_image`), plus batch, page and retry counts (defaults 3 to 5,000). Event-based discovery can update the connector's CIs.

## Related

- [[Service Graph Connectors Overview]] · [[Service Graph Connector for AWS]] · [[Service Graph Connector for GCP]] · [[Integration Commons for CMDB]]
