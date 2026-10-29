---
type: concept
tags: [concept, integrations, cmdb, workspace, roles, domain-separation]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > SGC Central - Exploring SGC Central, Configuring SGC Central (install, scheduled jobs, explore connectors, update and install connectors, connector settings), Managing connections (initial setup tasks, create, update, view, monitor and analyze, diagnose a processing error, access IntegrationHub ETL), SGC Central reference (components, domain separation); about 780 cleaned lines, read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/sgcc-explore.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# SGC Central Application

**In one line:** Store app `sn_sgc_central` that gives Service Graph Connectors one home in the **Service Graph Workspace** or **CMDB Workspace**: find and install connectors, create connections through per-connector **playbooks**, manage installed and draft connections, and monitor imports. The dashboard cards themselves are described in [[CMDB Workspace Insights and SGC Central]].

From the Brazil docs; not tested. Connector concepts and roles: [[Service Graph Connectors Overview]]. Per-connector playbooks: [[Service Graph Connectors Catalog]].

## Who does what

| Role | In SGC Central |
|---|---|
| `admin` | install and upgrade connectors (including API connectors), playbook prerequisites, background scripts, global table access, settings, IntegrationHub ETL page |
| `sn_cmdb_int_util.sgc_admin` | create, update, delete and view connections; monitor; diagnose errors |
| `cmdb_inst_admin` | IntegrationHub ETL maps, data sources and scheduled imports, connector properties, reading related records such as `em_event` |

## Setting it up

1. **Install** (role `admin`): **System Applications > All Available Applications > All** > `sn_sgc_central`. Needs a CMDB Workspace version matching the release: Yokohama 7.3.0+, Zurich 7.4.1+, Australia 8.0.0+. Brings **Integration Commons for CMDB** and **CMDB Workspace**. If the view does not appear, clear the browser cache.
2. **Scheduled jobs**: **SGC central collection** (daily; fills the dashboard from recent imports; activate it after installing and set its schedule) and **SGC central collection onDemand with lookback** (on demand; collects the last **30 days** of history). An empty dashboard usually means these have not run.
3. **Explore connectors**: **Updates available** (opens Application Manager to update), **Entitlements available** (install from Application Manager), **Available from ServiceNow Store**.
4. **Settings > Browse system properties by connector**: edit a connector's system properties (choosing a connector switches the application scope).

## Connections

- **Create connection** (SGC-admin or admin): choose the connector type and follow its playbook; if a connector has no playbook, its guided setup is used. Choosing a type switches the application scope.
- **Initial setup tasks** (first connection for a connector, role `admin`) appear in the **Prerequisites** stage: grant global **Application Access** on **Data Source** (`sys_data_source`), then run the cache-flush script (here only `sys_data_source` and `sys_db_object`; some connectors add `scheduled_import_set` and `sys_variable_value`, see [[Service Graph Connectors Overview]]).
- **All connections > Installed**: open a connection to edit **Details** (then **Update and test connection**) and see tabs for data sources, import schedules, errors and connector-specific tabs.
- **All connections > Drafts**: **Configure** to continue a half-finished playbook, **Resume setup** for a single-instance connector's first setup.

## Monitoring and diagnosis

Overview page (SGC-admin or admin): connection status, processing status, ongoing executions, ingested and processed data, processing performance, filtered by connector type, connection, data source and date range ([[CMDB Workspace Insights and SGC Central]]). Two details from these pages:
- The **Processing status** card counts only import sets that failed in the last run, while the summary table's Error column also counts **cancelled** import sets, so the numbers can differ.
- **Diagnose error** (one error at a time, from the connection's **Errors** tab via **View details**): Now Assist explains the error and recommends a fix based on a knowledge article found with AI Search, if the **Service Graph Connector diagnosis** skill is enabled ([[Otto for CMDB Skills and Agentic Workflows]]).

The **IntegrationHub ETL** page (role `admin`) counts ETL definitions (total, active, scheduled) and links to [[IntegrationHub ETL]].

## Tables

| Table | Holds |
|---|---|
| `sn_sgc_central_service_graph_connector` | connectors: scope, app ID, provider |
| `sn_sgc_central_st_installed_connection` | installed and draft connections with status, last run, frequency |
| `sn_sgc_central_service_graph_connection_trigger` | trigger that starts the playbook when a connection is created (playbook chosen by the metadata record's scope) |
| `sn_sgc_central_conn_prop_config` | how connection properties appear on the create / edit page (groups, order, mandatory, defaults) |
| `sn_sgc_central_connection_record_tabs` | tabs on the connection page (Details, Data Sources, Scheduled Imports, Errors, connector-specific) |
| `sn_sgc_central_st_integrationhub_etl` | ETL list shown in SGC Central |

**Domain separation: not supported** (contrast with the connectors themselves, Standard\* for multi-instance connectors).

## Related

- [[CMDB Workspace Insights and SGC Central]] · [[Service Graph Connectors Overview]] · [[Service Graph Connectors Catalog]] · [[Integration Commons for CMDB]]
