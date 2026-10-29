---
type: reference
tags: [reference, integrations, cmdb, api]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > API Service Graph Connectors - Apigee Edge, Apigee X, AWS API Gateway (with partition and page size), Azure API Management, Boomi Cloud API Management, Kong Gateway, Kong Konnect, MuleSoft (overviews, Configure using SGC Central, target tables skimmed for class names; about 3,400 cleaned lines, read 2026-10-29). https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/api-sgc-apigee-edge.html and sibling pages
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# API Service Graph Connectors

**In one line:** Store apps that import API gateway and API management data (gateways, managed APIs, frontends and backends, deployments, product bundles, consumers and subscriptions) into a common CMDB API data model shown in [[API Insights]]. All are configured through **SGC Central** in the CMDB Workspace.

From the Brazil docs (each supports Yokohama, Zurich, Australia; Kong Konnect lists only Yokohama and Zurich); not tested. Shared framework: [[Service Graph Connectors Overview]]. A security-oriented API source: [[Service Graph Connector for Akamai API Security]].

## Common data model

Data sources run in a fixed order (gateway or organisation first, then managed APIs, frontends and backends, consumers, products, subscriptions, access) into:

| Class | Table |
|---|---|
| Gateway (per product) | e.g. `cmdb_ci_apigee_api_gateway`, `cmdb_ci_aws_api_gateway`, `cmdb_ci_azure_api_mgmt`, `cmdb_ci_boomi_api_gateway`, `cmdb_ci_kong_gateway`, `cmdb_ci_anypoint_api_gateway`; generic **API Gateway** `cmdb_ci_api_gateway` |
| Managed API | `cmdb_ci_managed_api` |
| API | `cmdb_ci_api` |
| API Frontend / API Backend | `cmdb_ci_api_frontend` / `cmdb_ci_api_backend` |
| API Product Bundle | `cmdb_ci_api_product_bundle` |
| API Consumer Subscription | `cmdb_ci_api_consumer_subscription` |
| API Deployment, API Consumer, API Consumer Access (not CIs) | `api_deployment`, `api_consumer`, `api_consumer_access` |
| plus DNS Alias, Key Value (tags) | `cmdb_ci_dns_alias`, `cmdb_key_value` |

**Deletion:** soft only, and only for CI classes. CIs not found in the last scheduled run become **Non-Operational**; Managed APIs additionally get **Life cycle stage** = End of Life and **Life cycle stage status** = Retired ([[CSDM Life Cycle Values Reference]]).

Roles: prerequisites `admin`, setup `sn_cmdb_int_util.sgc_admin` or `admin`. Connections: **All > Service Graph Connectors > <connector> > Connections** (or a default draft connection in SGC Central).

## Per connector

| Connector | Authentication | Notable settings |
|---|---|---|
| **Apigee Edge** | OAuth 2.0 **password grant**: token URL plus Apigee user name and password (entered in a dialog; creates a second "... Basic Connection" record used internally); MID Server optional (auto-select, specific server or cluster) | organisation names (empty = all accessible), app types to import (Company, Developer, Both), include environments |
| **Apigee X** | Google service account + **JKS** X.509 certificate (as for [[Service Graph Connector for GCP]], KB setup article); service account email, keystore, password | include environments, collect usage data; also brings Cloud Organization, Google folder and project classes. Talk to Now Support before upgrading production to **2.3.0** (source native keys change) |
| **AWS API Gateway** | IAM user **access key + secret key**, AWS Signature with **STS** assume role | STS assume role name, AWS regions, optional **Config aggregator** (name, region; page size max 100 then), collection period in days, **Is gov cloud**; connection properties `PartitionSize` (managed APIs per parallel job; empty = computed by Integration Commons) and `PageSize` |
| **Azure API Management** | Azure app (client ID, secret, tenant ID); token URL by cloud (global, US Gov, China, Germany as in [[Service Graph Connector for Microsoft Azure]]) | subscription IDs (empty with discovery scope Subscription = all in the tenant) |
| **Boomi Cloud API Management** | OAuth client ID and secret | |
| **Kong Gateway** | **Kong RBAC** token or **Kong Basic Authentication**; Admin API URL and port | exclude workspaces; extra class **Kong Workspace** (`kong_workspace`) |
| **Kong Konnect** | **Personal access token** | gateway group IDs (control plane groups; when set, gateway IDs are ignored), gateway IDs, regions, collect usage data, page size (100), partition size |
| **MuleSoft** (Anypoint Platform) | **Connected App** client ID and secret, token URL, organisation (tenant) ID | environments to include (only API proxies there) |

## Related

- [[API Insights]] · [[Service Graph Connectors Overview]] · [[Service Graph Connector for Akamai API Security]] · [[Integration Commons for CMDB]]
