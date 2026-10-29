---
type: concept
tags: [concept, integrations, cmdb, import-sets]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Configuration Management > Integrating third-party data into CMDB (landing page) and Integration Commons for CMDB (10 topics, about 1,800 cleaned lines, read in full through the docs site API 2026-10-29) - overview, CMDB Integrations Dashboard, operation types, template scripts, ADM adapter, connection details, data deletion, partition size, quick start tests. https://www.servicenow.com/docs/r/servicenow-platform/cmdb-integration-commons/integration-commons-for-cmdb.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Integration Commons for CMDB

**In one line:** a Store app (scope `sn_cmdb_int_util`, plugin `com.snc.cmdb.integration_util`) that every Service Graph Connector depends on: it supplies the shared RTE transforms and cleansing script includes, the CMDB Integrations Dashboard, the common connection framework, record-deletion logic and partition sizing for parallel loads.

From the Brazil docs; not tested. Installed automatically with any Store Service Graph Connector. Depends on CMDB and CSDM Data Foundations Dashboards v2.3.5 or later ([[CMDB and CSDM Data Foundations Dashboards]]). Transforms list: [[RTE Operations and Integration Commons Transforms Reference]].

## Ways to bring third-party data into the CMDB

| Method | What it is |
|---|---|
| Integration Commons for CMDB | the shared framework (this note) |
| IntegrationHub ETL | wizard producing ETL transform maps for your own integrations ([[Robust Import Set Transformers and ETL Definitions]], [[Populating the CMDB]]) |
| Service Graph Connectors | ready-made Store connectors for third-party sources |
| API Service Graph Connectors | connectors for API gateways (feeding [[API Insights]]) |
| SGC Central | CMDB Workspace view to create, edit, monitor and debug connector connections ([[CMDB Workspace Insights and SGC Central]]) |
| Now Assist for SGC | generative AI help for connector issues |

All of them write through IRE ([[Identification and Reconciliation Engine (IRE) Overview]]).

## CMDB Integrations Dashboard

**All > Self-Service > Dashboards** (or **Platform Analytics > Library > Dashboards**) > *CMDB Integrations Dashboard*; no role required per the docs; Next Experience since Xanadu. Covers all Service Graph Connectors and custom IntegrationHub ETL integrations.
- **CMDB Execution Status** tab: integrations, processed rows, runs in progress, daily statistics, classes updated.
- **CMDB Integration Errors** tab: import and integration errors, erroneous records.
- Filters: **Import Date**, **CMDB Applications** (e.g. SCCM or a custom integration), **CMDB Import** (one run).

## Common connection framework (CCF)

**All > Service Graph Connectors > Connections** lists the connections of every connector using CCF (alias, properties, data sources, scheduled imports), each with a **Test Connection** related link. Tables: `sn_cmdb_int_util_service_graph_connection`, `..._connection_property`, `..._connection_data_source` (m2m to data sources), `..._connection_scheduled_data_import` (m2m to scheduled imports), `..._connection_test_script`.

## Removing CIs deleted at the source

Both methods look in **Source** (`sys_object_source`) for CIs of the source feed that the last run did not update.

| Method | How | Used by |
|---|---|---|
| **Post-script** | the `RecordRemoval` script removes them one by one: hard delete, soft delete, or **optimized soft delete** through IRE (extension attributes table, reconciliation rules; batch of 100, change with integer property `sn_cmdb_int_util.ire_payload_items_size` created in the app scope) | most connectors |
| **Transform map** | rows go to staging table **Integration Commons Remove Record** (`sn_cmdb_int_util_remove_record`); the *Remove Record Transform Map* on-start script deletes them, several import sets in parallel | faster; e.g. the *SG-Tanium Remove Software* data source |

## Parallel loading partition size

For connectors that support it: **partition size = total rows / (10 % × active primary nodes)**; **parallel jobs = total rows / partition size**. Docs example: 1,000 rows, 4 nodes → "1000 / 0.4 = 25", 40 jobs. **The arithmetic does not match the formula** (1,000 / 0.4 = 2,500, which would give 0.4 jobs); the example's 25 and 40 fit "10 jobs per node" instead. Unconfirmed which is meant.

## ADM adapter

Server-side script include `ADMHelper` (scope `sn_cmdb_int_util`, run as `admin`) calls `ApplicationDependencyMapping` from Discovery and Service Mapping Patterns (`sn_itom_pattern`). Inputs: running processes (required; keys `pid`, `ppid`, `command`, `name`, `parameters`), computer sys_id (required), TCP connections (optional; `pid`, `local_ip`, `local_port`, `ip`, `port`, `state`, `type`), ADM properties (optional). Writes **TCP Connections** (`cmdb_tcp`), **Running Process** (`cmdb_running_process`) and **Application** (`cmdb_ci_appl`, classified processes into child classes; unclassified ones depend on a system property not named here), matching against network adapters and IP addresses.

## Quick start tests

ATF suite **CMDB INT: CMDB Integrations Validation** (since Paris): set the test session application (else every installed integration is tested), test against source analysis (`sn_cmdb_int_util_cmdb_integration_source_analysis`), and validate application feed, discovery source, entity mappings, fields, lookups, mandatory operations, operations, references, related entries, relationships. Run after upgrades or new integrations, on non-production only ([[ATF Quick Start Tests by Application]]).

## Related

- [[RTE Operations and Integration Commons Transforms Reference]] · [[Populating the CMDB]] · [[Import Sets - Data Sources, Staging Tables and Cleanup]] · [[Scheduled and Concurrent Imports]]
