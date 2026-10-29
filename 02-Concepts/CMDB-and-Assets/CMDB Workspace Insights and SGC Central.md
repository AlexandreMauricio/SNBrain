---
type: concept
tags: [concept, cmdb, workspace, reporting, import-sets, integrations]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB Workspace > Explore, topics "SGC view", "Insights view" and its dashboards (CMDB Health, CMDB Data Foundation, CSDM Data Foundation, CMDB success advisor, Feature adoption, Performance insights, Service instances, CMDB 360), and the three "Edit ... from CMDB performance insights" topics (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/cmdb-workspace.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-29
---

# CMDB Workspace Insights and SGC Central

**In one line:** the two monitoring areas of [[CMDB Workspace]]: **Insights** (dashboards for health, adoption and performance of the CMDB) and **SGC Central** (state of Service Graph Connector connections and imports).

## Insights view

**Workspaces > CMDB Workspace** > Insights icon. Only dashboards you have access to are listed.

| Dashboard | Roles |
|---|---|
| CMDB Health | any role containing `sn_cmdb_user` |
| CMDB Data Foundation | `sn_cmdb_admin`, `asset` or `itil_admin` |
| CSDM Data Foundation | `sn_cmdb_admin`, `app_service_admin`, `app_service_user`, `asset`, `cmdb_read`, `itil_admin`, `portfolio_admin`, `service_viewer`, `technology_service_owner` |
| CMDB success advisor (Data Foundations, HAM) | `sn_cmdb_admin`; each appears only once its setup is complete |
| Feature adoption | any role containing `sn_cmdb_user` |
| Performance insights | `sn_cmdb_admin` |
| Cloud vs Non-cloud | see [[Cloud vs Non-cloud Resources Chart in CMDB Workspace]] |
| Service instances | any role containing `sn_cmdb_user`; counts rows of Service Instance (`cmdb_ci_service_auto`), 7-day trend |
| CMDB 360 | `sn_cmdb_editor` or `sn_cmdb_admin` |

### Feature adoption

Three dials, each with a tab of feature cards. Most card data is collected every 24 hours (the "by source" card monthly), from Performance Analytics indicators over **Base Aggregate Data** (`sn_cmdb_ws_base_aggregate_data`). Cards offer Learn more, View demo, Get started or Install app depending on state.

| Category | Low (red) | Moderate (amber) | High (green) | Based on |
|---|---|---|---|---|
| Data ingestion | under 80% | 80 to 90% | over 90% | share of CIs processed by IRE (checked in **Source**, `sys_object_source`) |
| Data governance | under 33% | 33 to 66% | over 66% | share of features used |
| Search and analytics | under 33% | 33 to 66% | over 66% | share of features used |

How each card decides "in use":

- **Service Graph Connectors:** plugin `com.snc.itom.license` active and at least one connector installed.
- **IntegrationHub ETL:** rows in `cmdb_inst_application_feed` (demo maps not counted).
- **CIs processed by IRE by source:** six months. Counted as ServiceNow Discovery: `ServiceNow`, `ServiceWatch`, `ACC-Visibility`, `AgentClientCollector`, `CredentiallessDiscovery`.
- **Data Manager / attestation:** user-created policies in `cmdb_data_manager_policy_and_attributes`, or CIs processed by them in the last 90 days (`cmdb_data_management_policy_execution`).
- **Data synchronization:** at least one class with `managed_by_group` set for the whole class.
- **Principal classes:** at least one class in the Principal Class filter ([[CI Classes, Dependency and Principal Class]]).
- **Query Builder:** rows in Saved Queries (`qb_saved_query`) with Source QB, or queries run in the last 90 days.
- **Intelligent Search:** rows in NLQ Query Logs (`nlq_query_log`) with source `CMDB_WS` in the last 90 days.
- **CMDB 360** cards: only when CMDB 360 is enabled (plugin `com.snc.itom.discovery.license` and property `glide.identification_engine.multisource_enabled`); queries counted from `cmdb_multisource_query`.
- **CMDB Health Dashboard:** at least one health dashboard job enabled.

### Performance insights

**View performance insights** on the tile. A recommendations panel (light bulb) links to the relevant tool or property; an admin can hide or reorder recommendations through **Active** and **Order** in `sn_cmdb_ws_imp_action_card_config`.

Tab **Payloads & CIs**:

| Tile | Shows |
|---|---|
| Partial payloads | payloads IRE could not process because the source gave too little to identify the CI; total and by discovery source, drill down to the payload and its error. Many partial payloads degrade performance |
| Related records | rows of related tables whose **Referenced field** is empty, total and by table (tables listed in `cmdb_related_entry`) |
| Duplicate and stale CIs | counts by class. Stale = not updated within the Effective Duration of the class's health staleness rule |
| Relationship records missing parent or child | invalid `cmdb_rel_ci` rows, with trend |

Tab **Service Graph connectors** (needs at least one connector and role `cmdb_inst_admin`):

- Data sources (`sys_data_source`) with **Use Batch Import** off.
- Scheduled data imports (`scheduled_import_set`) with **Concurrent Import** off, or not using the **Custom size** partition method.
- Connectors whose processing rate or import row count over the last 30 days falls outside the prediction band (outliers).

Fixes available from the lists (all need `sn_cmdb_admin`):

| Fix | Extra role | Steps |
|---|---|---|
| Fill a missing reference in a related table | access to that table | Related records tile > slice > tick the record > **Edit** > set the CI reference > **Update** |
| Edit a data source | `import_admin` | *Sources with batch processing turned off* > tick > **Edit** > **Update** |
| Edit a scheduled data import | `import_scheduler` or `import_admin` | *Sources with concurrent import turned off* or *non-custom size partition* > tick > **Edit** > **Update** |

You may have to switch application scope to the scope of the data source or import to edit it.

## SGC Central view

Ingestion icon. Role `sgc_admin`, `cmdb_inst_admin` or `admin` (the SGC Central pages read 2026-10-29 name only SGC-admin and admin for the Overview page: unconfirmed). Filters: connector type, connection, data source, date range. Installing SGC Central, its collection jobs, playbooks, connection management and error diagnosis: [[SGC Central Application]].

| Section | Cards |
|---|---|
| Connections overview | **Connection status** (success, error, unknown, with last error); **Processing status** (connections whose last import run fully succeeded; activated schedules, processed, success, error); **Ongoing executions** |
| Ingested and processed data | import sets (success, partial, error), imported rows, CIs added and updated, partial or incomplete CIs |
| Data processing performance | daily trend of CIs added, updated and errors; top 10 connections by processing time and by errors (data source, connection, credential) |

Source tables (scope `sn_cmdb_int_util`):

| Table | Holds |
|---|---|
| `sn_cmdb_int_util_cmdb_integration_execution` | executions: rows ingested, processing time |
| `sn_cmdb_int_util_cmdb_integration_execution_import_set` | import sets per execution, with rows and errors |
| `sn_cmdb_int_util_cmdb_integration_execution_audit` | records inserted and updated |
| `sn_cmdb_int_util_cmdb_integration_execution_error` | errors, categorised as credentials, data source or connection |

Indicator definitions (previous day): fully successful import set = errors 0; fully failed = errors not 0 and rows = errors; partly successful = errors not 0 and rows not equal to errors; processing rate = rows processed / hours.

## Related

- [[CMDB Workspace Reference - Properties, Roles, Jobs and Tables]] · [[CMDB Workspace]]
