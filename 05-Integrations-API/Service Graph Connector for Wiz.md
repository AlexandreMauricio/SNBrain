---
type: reference
tags: [reference, integrations, cmdb, security]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > Wiz (about 2,270 cleaned lines, read 2026-10-29) - overview with data source mapping, Set up the Wiz environment, Configure using SGC Central, Properties, Supported Wiz types (skimmed), Target tables (class names only). Guided setup deprecated from 1.4.0, not read in detail. https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/sgc-cmdb-integration-wiz.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for Wiz

**In one line:** Store app `sn_wiz_integ` that reads the multi-cloud inventory Wiz already holds (AWS, Azure, GCP, OCI, Alibaba, vSphere resources and Kubernetes) through the Wiz REST API and loads it into CMDB cloud classes, tagging each CI with its Wiz project.

From the Brazil docs (tested by ServiceNow on Yokohama, Zurich, Australia); not tested here. General: [[Service Graph Connectors Overview]].

## Wiz side

As a Wiz user with **Write** on service accounts: copy the **API Endpoint URL** from the user profile; **Settings > Service Accounts > Add Service Account**, optionally limit to projects, API scopes **read:resources** and **read:projects**; copy client ID and secret. Token URL is always `https://auth.app.wiz.io/oauth/token`.

## Setting up the connection

SGC Central (connector 1.3.0+; guided setup **deprecated from 1.4.0**; prerequisites `admin`, setup `cmdb_inst_admin` or `admin` — note: other connectors name `sn_cmdb_int_util.sgc_admin` here). **Single instance only**: edit the default connection **SG-Wiz**.
1. **Create and test connection**: name, **Connection URL** `https://api.<region>.app.wiz.io` (region e.g. us1, us2, eu1, eu2), client ID, client secret, token URL (pre-filled).
2. Optional **Set configuration properties**: **Projects** (IDs to import) or **Exclude projects** (used only when Projects is empty).
3. Schedule **SG-Wiz-Organization**.
4. Optional **Enable full data retrieval**: schedule the script *Reset Last Run Datetime for SG-Wiz*, which clears **Last Run Date Time** so the next run is a full pull (otherwise runs are incremental).

## Connection and system properties

| Property | Meaning |
|---|---|
| Projects / Exclude Projects | as above |
| **Server Bypass** | true = link VM data to existing Server records instead of creating new Server and VM records |
| **Fetch Scaleset VMs** | true = import scale set VMs |
| `sn_wiz_integ.list_resources_action.page_size` | REST page size (100) |

## Data sources and classes

Data sources `SG-Wiz-<type>` with staging tables `sn_wiz_integ_sg_wiz_<type>`: Organization (cloud org, Google folder), Subscription (service account, Google project, vCenter datacenter), Datacenter (AWS, Azure, Google, OCI, logical datacenters), Resource Group, Network Interface, Virtual Network, Firewall (security group), Volume (and disk type), Virtual Machine (VM instance, hardware type, cloud hardware type, Linux/Windows/other server), Virtual Machine Image (skipped when no subscription ID or subscription details), Load Balancer, Database (cloud database, DB cluster, DynamoDB), Bucket, Serverless (function), Network Address (public IP), Storage Account, API Gateway (cloud gateway), Snapshot, Kubernetes cluster, namespace, node, deployment, service, pod, ReplicaSet, container (Docker container), Compute Instance Group (scale set), Gateway (internet gateway). Labels and tags go to `cmdb_key_value`; Wiz project data to **SG-Wiz Extension Attributes** (`sn_wiz_integ_extension_attributes`). Deleted resources are marked retired or absent.

## Related

- [[Service Graph Connectors Overview]] · [[Service Graph Connector for AWS]] · [[Service Graph Connector for Microsoft Azure]] · [[Service Graph Connector for GCP]]
