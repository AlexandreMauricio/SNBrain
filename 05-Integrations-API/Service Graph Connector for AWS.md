---
type: reference
tags: [reference, integrations, cmdb, discovery]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > AWS (about 4,860 cleaned lines, read 2026-10-29) - overview, Configure the AWS environment (resources, scripts, prerequisites, executing scripts), Configure using SGC Central, Additional features, Life cycle management, Record removal, Properties (names scanned). The guided-setup page (classic path), the long data mapping and target class tables, the quick start tests and the discovery comparison tables were skimmed, not transcribed. https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/cmdb-integration-aws-sg.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for AWS

**In one line:** Store app `sn_aws_integ` that reads an AWS organisation through AWS Config (and optionally Systems Manager and EKS bastion hosts) and loads accounts, networks, compute, storage, databases, Kubernetes and software into the CMDB through IRE.

From the Brazil docs (supported on Yokohama, Zurich, Australia per the page); not tested. General: [[Service Graph Connectors Overview]]. Cloud patterns vs connectors: same note.

## What it needs in AWS

| AWS piece | Needed for | Notes |
|---|---|---|
| **AWS Config** + configuration recorder | everything (required) | enable in every account and region (`EnableAWSConfig.yml`) |
| AWS Config **aggregator** | optional, recommended for many accounts/regions | one place for baseline and incremental data; deleted resources still need `config:ListDiscoveredResources` per account and region |
| **Systems Manager** (SSM agent, `AmazonSSMForInstancesRole` instance profile, Inventory per region) | deep discovery (host name, serial, CPU, TCP, processes) and software inventory | |
| **S3 bucket** (private, policy allowing the EC2 instance profile `s3:GetObject`, `PutObject`, `PutObjectAcl`) | deep discovery output of SendCommand | only with deep discovery |
| EKS **bastion EC2** hosts | Kubernetes data via kubectl through SSM | only for EKS |

CloudFormation scripts downloaded from the connector's setup (run as stacks or StackSets from the management account): **basic** — `EnableAWSConfig.yml`, `CreateServiceNowUser.yml` (IAM user, default `NOWSGCUser`), `CreateSnowOrganizationAccountAccessRoleInMemberAccount.yml` (read-only role, default `SnowOrganizationAccountAccessRole`), `SnowDesignatedAccountAccessRoleInManagementAccount.yml` (only when the user lives in a member account), the two Systems Manager automation role scripts; **deep discovery** — `AmazonSSMForInstancesRoleSetup.yml`, `SG-AWS-RunShellScript-Setup.yml` (Linux, incl. Apache, Nginx, Tomcat, MySQL versions), `SG-AWS-RunPowerShellScript-Setup.yml` (Windows); **EKS** — `SG-AWS-RunKubeCtlEKSNamesShellScript.yml`, `SG-AWS-RunKubeCtlShellScript.yml`. Use the same IAM user and role names in every script.

## Setting up the connection

Preferred: **SGC Central** (Service Graph Workspace > Ingestion, or CMDB Workspace > SGC Central) > **Create connection** > AWS (connector 2.7.0+; prerequisites stage `admin`, setup stage `sn_cmdb_int_util.sgc_admin` or `admin`). Classic alternative: **All > Service Graph Connector for AWS > Setup** guided setup (scope picker set to the app).

Playbook steps: download and run basic / deep discovery / EKS scripts → **Create and test connection** (connection name, Access Key ID, Secret Access Key of the IAM user, optional MID Server) → **Set configuration properties**: organisation details; S3 account ID, bucket, region; **AWS regions** (empty = all; narrowing speeds imports; after changing, clear **Last run datetime** on all AWS data sources); **STS assume role name**; SSM SendCommand document names; **Management account ID** or **Standalone account ID** (KB1642159); Config aggregator account/name/region; **key rotation** (rotate keys, date, period in days, status, error email recipients and groups); **Is gov cloud**; EKS document names → **Configure EKS EC2 resources** (resource id, region, account, connection alias) → **Run diagnostic tests** (options to skip SSM, deep discovery or EKS tests; shows API access and IAM permission results) → **Configure import schedule** on the parent **SG-AWS-Organization** scheduled import → confirm.

## Data sources and classes (life cycle managed unless noted)

Organisation `cmdb_ci_cloud_org`, organisational unit `cmdb_ci_aws_org_unit`, service account `cmdb_ci_cloud_service_account`, tags → `cmdb_key_value` (no life cycle), datacenter `cmdb_ci_aws_datacenter` (no), availability zone `cmdb_ci_availability_zone` (no), subnet `cmdb_ci_cloud_subnet`, network interface `cmdb_ci_nic`, security group `cmdb_ci_compute_security_group`, storage volume and snapshot `cmdb_ci_storage_volume`, `cmdb_ci_storage_vol_snapshot`, images `cmdb_ci_os_template`, hardware type `cmdb_ci_compute_template`, EC2 → `cmdb_ci_vm_instance`, `cmdb_ci_server`, block and VNIC endpoints, storage mapping, IP address; load balancers `cmdb_ci_cloud_load_balancer`, RDS `cmdb_ci_cloud_database`, S3 `cmdb_ci_cloud_object_storage`, DynamoDB `cmdb_ci_dynamodb_table`, Redshift `cmdb_ci_aws_redshift`, generic resources `cmdb_ci_cmp_resource`, EKS → Kubernetes cluster, namespace, node, service, pod, volume, deployment, DaemonSet, ReplicaSet, Docker container; SSM inventory → server, applications, running processes, TCP connections. Data source names follow `SG-AWS-<resource>` (e.g. `SG-AWS-EC2`, `SG-AWS-VPC`, `SG-AWS-SendCommand`, `SG-AWS-SSM-GetS3Object`, `SG-AWS-Software-Inventory`).

Unconfirmed variant: the life cycle table lists **SG-AWS-VPC → Network Adapter** (`cmdb_ci_network_adapter`); a VPC would normally be a cloud network class. Check the actual map before relying on it.

## Deletion and life cycle

Resources deleted in AWS are **retired** (install status), not deleted. Default detection uses `sys_object_source` and `ListDiscoveredResources` in batches of 20 (slow). **Optimized deletion** (`sn_aws_integ.enableOptimizedDeletion` = true) compares full pulls using **SG-AWS Extension Attributes** (`sn_aws_extension_attributes`), for every table except hardware type, availability zone, AWS datacenter, running process, TCP connections and application. Deleted EKS pods, services, volumes and so on are set to Retired.

## Tuning and fixes

| Setting | Effect |
|---|---|
| `sn_aws_integ.save_payload_as_attachment` (on by default) | stores each REST response as a temporary attachment to avoid the 1,024 MB direct-response limit |
| script include `SgAwsApplicationProperties`: `isConfigDbLoadEnabled`, `isConfigTagsDbLoadEnabled` → true | load AWS Config data and tags in smaller database batches to avoid memory errors (needs the aggregator) |
| connection property `aws_account_partition_size` | partition size for parallel loading of image, tags, SendCommand, GetS3Object data sources (otherwise computed by Integration Commons) |
| **Enable parallel loading** check box on a data source | turn parallel loading off per data source |
| parallel deletion | on for the main data sources since Washington DC Patch 5 once the parallel job plugin is active; after upgrading to 2.9.1 before that, run the *SGC - Parallel Loading Fix* script |
| `sn_aws_integ.is_software_inventory_enabled` | skip SSM GetInventory calls when using `SG-AWS-Software-Inventory`; **not supported from connector 2.10.0** |
| `sn_cmdb_ci_class.use_single_cloud_os_image` | 2.10.0+: images go to independent Cloud Image `cmdb_ci_cloud_os_image` instead of dependent `cmdb_ci_os_template` (which created duplicates) |
| `sn_aws_integ.load_all_images` | on for the first pull (BYOL: Oracle DB images get key value BYOL), then turned off automatically |

Other property families (about 40, mostly integers defaulting to 100): batch sizes per resource type for `BatchGetResourceConfig` and aggregate variants, throttling min/max wait, retry counts, EKS chunk size and document processing time, TCP status filters for Linux and Windows, `use_aggregator_configured_accounts`, `create_server_record_even_if_SSM_disabled`.

## Other features

Event-based discovery can update connector CIs; shared VPC and subnets across accounts are related; upgrades: remove customisations of the app from `sys_update_xml`, upgrade dependencies, then clear **Use last run datetime** on all data sources for a full import and rerun the AWS scripts.

## Related

- [[Service Graph Connectors Overview]] · [[Integration Commons for CMDB]] · [[CMDB Modelling Guidelines for Hardware, Virtual Machines and Cloud]] · [[Connections, Credentials and Aliases]]
