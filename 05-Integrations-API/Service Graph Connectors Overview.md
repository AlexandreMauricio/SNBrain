---
type: concept
tags: [concept, integrations, cmdb, roles, domain-separation]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Getting started with Service Graph Connectors, Service Graph Connectors (list), Domain separation, Cloud discovery solutions comparison (coverage tables are images, not read), Support Tools application (install, resolving issues) (read 2026-10-29). https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/cmdb-sgc-intro.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connectors Overview

**In one line:** Service Graph Connectors (SGC) are Store apps that pull data from a third-party product (cloud, endpoint management, monitoring, security, network, OT) into CMDB and some non-CMDB tables, using IntegrationHub ETL maps, Integration Commons transforms and IRE, so the data lands in the CSDM-correct classes without duplicates.

From the Brazil docs; not tested. Shared framework: [[Integration Commons for CMDB]]. Maps: [[IntegrationHub ETL]]. Monitoring: SGC Central in [[CMDB Workspace Insights and SGC Central]] and the CMDB Integrations Dashboard. Per-connector notes: [[Service Graph Connectors Catalog]].

## Kinds

- **Service Graph Connectors**: third-party data sources.
- **API Service Graph Connectors**: API gateways and API management tools, feeding [[API Insights]].
- **Partner-built connectors**: listed on the Store.

Pipeline: identify (class, attributes, source) → standardise → reconcile (IRE rules) → load.

## Roles

| Role | Can |
|---|---|
| `admin` | install and upgrade connectors, create connections and properties, run background scripts, grant access to global tables |
| `sn_cmdb_int_util.sgc_admin` (SGC-admin) | create, update, delete connections; guided setup; read/write connector properties; everything below |
| `cmdb_inst_admin` | IntegrationHub ETL; read connector modules; properties; custom tables; scheduled imports and data sources; related records owned by other apps (e.g. `em_event`) |
| `sn_cmdb_int_util.sgc_viewer` (SGC-viewer) | view modules, CCF, connections in CMDB Workspace, properties, scheduled import runs and logs, data sources, custom tables |

## Connectors listed in the Brazil docs

Public cloud: AWS, GCP, Microsoft Azure, Wiz. Endpoint / asset management: Google Chromebooks (Google Console), Jamf, Microsoft Intune, Microsoft SCCM, Tanium (and Tanium Atlas, Tanium Atlas Endpoints), VMware / Omnissa Workspace ONE UEM. Monitoring and observability: AppDynamics, Datadog, Dynatrace, Dynatrace SaaS, OpenTelemetry, New Relic, SolarWinds, Splunk. Security: Microsoft Defender for Endpoint, Microsoft Active Directory, Netskope, Qualys, Rapid7, SentinelOne, Akamai API Security. Network and other: BlueCat, Confluent, ExtraHop, Infoblox, Nautobot, NetBrain, Trellix. OT (listed, documented elsewhere): Claroty CTD, Microsoft Defender for IoT (on-premises and Azure), Operational Technology Excel import. API: Apigee Edge, Apigee X, AWS API Gateway, Azure API Management, Boomi Cloud API Management, Kong Gateway, Kong Konnect, MuleSoft. The Store list is the authoritative one.

## Patterns or connectors for cloud

Discovery and Service Mapping **patterns** give deeper, continuously updated, business-aware data (relationships, service mapping, certificates, firewalls). Cloud **connectors** give fast point-in-time ingestion from the provider's APIs. The same resource can land in **different classes** depending on the method (e.g. patterns bring all zones, connectors only zones tied to an instance), so pick one method per provider (the docs' example: connectors for GCP, patterns for AWS and Azure). The per-provider coverage tables are images and were not read.

## Domain separation

Support level **Standard\*** (with exceptions), only for **multi-instance** connectors. Install **Domain Support - Domain Extensions Installer** (`com.glide.domain.msp_extensions.installer`) first. Not domain separated: tables without `sys_domain`, import set tables, transform histories, **Key Value** (`cmdb_key_value`), **Software Instance** (`cmdb_software_instance`). Before San Diego IRE used strict (non-hierarchical) domain separation. See [[Domain Separation Support Levels by Application]].

## Setting up connections: SGC Central or guided setup

Most connectors document both. **SGC Central** (Service Graph Workspace > Ingestion, or CMDB Workspace > SGC Central > **Create connection**) runs a playbook: prerequisites (role `admin`), then setup (`sn_cmdb_int_util.sgc_admin` or `admin`): create and test connection, connector properties, schedule the parent scheduled import, confirm. The classic **guided setup** (**All > Service Graph Connectors > <connector> > Setup**, scope picker set to the connector) is being deprecated per connector.

**Adding a second instance of the source in the classic guided setup** (pattern seen in the GCP connector; other connectors may differ):
1. Global scope: on the **Data Source** (`sys_data_source`) and **Scheduled Data Import** (`scheduled_import_set`) table records, tick **Can create**, **Can update**, **Can delete** in **Application Access**.
2. Background script in global scope to clear table caches:

```javascript
// Scripts - Background, global scope; flushes cached table definitions so the connector can create data sources
GlideTableManager.invalidateTable("sys_data_source");
GlideCacheManager.flushTable("sys_data_source");
GlideTableManager.invalidateTable("scheduled_import_set");
GlideCacheManager.flushTable("scheduled_import_set");
GlideTableManager.invalidateTable("sys_db_object");
GlideCacheManager.flushTable("sys_db_object");
```

3. Back in the connector scope: create the credentials (certificate or OAuth), **Add Connection** in Workflow Studio / Flow Designer, **Test Connection**, schedule the imports, then **Advanced Setup > Sync New Data source** so new data sources get credentials.

## Troubleshooting

- **Service Graph Connector Support Tools** (`sn_sgc_support`, install as `admin` from **System Applications > All Available Applications > All**; brings Integration Commons and Glide Virtual Agent Lite `com.glide.cs.chatbot.lite`). **All > Service Graph Connectors > Troubleshooting** starts a virtual agent chat: **Debug a specific Service Graph Connector** (connection: properties, run the Workflow Studio action, HTTP logs; data: IRE / reconciliation / business rule / mapping customisations, reprocess an import row; performance: execution history; mapping: ETL map review) or **General analysis**.
- Otto for CMDB *SGC diagnosis* skill ([[Otto for CMDB Skills and Agentic Workflows]]).
- SGC Central's connection view and the CMDB Workspace performance insights ([[CMDB Workspace Insights and SGC Central]]).

## Related

- [[Service Graph Connectors Catalog]] · [[Populating the CMDB]] · [[Identification and Reconciliation Engine (IRE) Overview]] · [[IRE Reconciliation, Data Refresh and Data Source Rules]]
