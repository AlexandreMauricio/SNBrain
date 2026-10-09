---
type: concept
tags: [concept, cmdb, data-integrity, discovery, reporting, workspace]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > "CMDB 360" with its topics "CMDB 360 experience in a workspace", "Configure the CMDB 360 dashboard in a workspace", "Exclude classes from CMDB 360", "Components related to CMDB 360" (https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/multisource-cmdb.html and the pages under it), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# CMDB 360

**In one line:** CMDB 360 (formerly Multisource CMDB) keeps **every value every discovery source reported for every CI attribute**, including the values reconciliation rejected, so you can see where a value came from, compare sources, undo a bad source and recompute.

Without it, [[Identification and Reconciliation Engine (IRE) Overview|IRE]] keeps only the winning value and discards the rest.

- Data store: **CMDB 360 Data** (`cmdb_multisource_data`), one record per discovery source and CI.
- Supports non-CMDB tables (off by default).
- Required for **dynamic reconciliation rules** ([[IRE Reconciliation, Data Refresh and Data Source Rules]]).

## Enable

1. Activate plugin **ITOM Discovery License** (`com.snc.itom.discovery.license`).
2. **All > Configuration > CMDB 360 Properties**: `glide.identification_engine.multisource_enabled` = true (**default false**).
3. Optional: exclude classes (below).

## What it is used for

- See, per attribute, the CMDB value and what each source reported: **CMDB 360 Data Preview** related link on a CI form, the CMDB 360 section of [[CI Form in CMDB Workspace]], **Preview Data** on the Reconciliation Rules page of [[CI Class Manager]]. The source whose value is in the CMDB is highlighted green.
- Change reconciliation rules, or drop an unreliable source, and **recompute**: [[Recompute CI Attribute Values with CMDB 360]].
- Validate a new source against trusted ones.
- Query and report: [[Create and Schedule a CMDB 360 Query]].

## Dashboard

**Workspaces > CMDB Workspace** > **CMDB 360** (or Insights > CMDB 360). Role `sn_cmdb_user` or one containing it.

| Tile | Cards |
|---|---|
| **Potential issues** | **CIs not reported by discovery sources**: CIs seen by several sources where at least one has gone silent for more than N days. Example with N = 7: reported today by ServiceNow, 4 days ago by ServiceWatch, 8 days ago by AgentClientCollector, so it is listed. **Data mismatch**: CIs for which sources report different values for chosen attributes |
| **Saved queries** | up to 20 of your queries; create, edit, run |
| **Discovery sources** | number of sources, total CMDB 360 records, reconciled CIs, distribution per source, **Coverage: CIs with a single discovery source**, **Coverage: CIs by number of discovery sources**. Filter: All, CMDB CI, Principal Class |

### Settings (role `cmdb_ms_admin`)

| Setting | Effect |
|---|---|
| Global: **Maximum number of records in a list view** | cap on drill-down lists, default 100,000 (property `sn_cmdb_ws.ms.report_max_limit`) |
| **Number of days since CIs were last discovered by a discovery source** | N above, default 7 (`sn_cmdb_ws.ms.discovery_source_not_reporting_max_days`) |
| Data mismatch | classes to check (child classes included), attributes, **every** attribute or **any** attribute mismatching, and class weights |
| Coverage | classes given priority in the drill-down set, with weights. Unprioritised: random classes |

Weights split the global cap between classes: **automatic** = equal shares (four classes, 25,000 records each of 100,000); **manual** = your percentages.

### Coverage chart performance

- A class with more records in `cmdb_multisource_data` than `sn_cmdb_ws.ms.report_class_ci_count_max_threshold` (default 10 million) gets a row in **CMDB 360 Analytics Skipped Class** (`sn_cmdb_ws_ms_skip_class`) and is skipped from then on. Set **Override class CI records population** to true on that row to include it again.
- `sn_cmdb_ws.ms.calculate_cmdb_only` (default true): Discovery sources tile counts CMDB classes only. With it true, or with non-CMDB capture off, the *All* and *CMDB CI* filters show the same thing.

## Exclude classes

CMDB 360 stores a lot. Excluding classes speeds up the analytics job and queries. Table **CMDB 360 denied classes** (`cmdb_multisource_deny_class.list` > **New** > the class > **Active**). Role `cmdb_ms_admin` (inside CMDB Admin).

- Covers the class **and its descendants**.
- Pre-filled with some classes (`dscy_net_base`, `discovery_net_base`).
- Existing data for the class is removed gradually by record cleaners.
- Untick **Active** or delete the row to include the class again.

## Properties

On **Configuration > CMDB 360 Properties** unless noted. Role `cmdb_ms_admin` to change.

| Property | Default | Effect |
|---|---|---|
| `glide.identification_engine.multisource_enabled` | false | turns CMDB 360 on |
| `glide.identification_engine.multisource_cmdb_ci_enabled` | true | capture for CMDB classes |
| `glide.identification_engine.multisource_non_cmdb_ci_enabled` | false | capture for non-CMDB classes (for example `cmdb_serial_number`, `cmdb_software_instance`) |
| `glide.identification_engine.multisource.query.batch.limit` | 100 | results per page of a query |
| `glide.identification_engine.multisource.query.max.limit` | 10000 | results on **Load All Results** |
| `glide.identification_engine.multisource.recompute.max.ci.limit` | 100000 | CIs per recompute |
| `glide.cmdb.logger.source.cmdb_multisource` (add to `sys_properties`) | | log level (info, warn, error, debug, debugVerbose); entries in `syslog` with source `cmdb_multisource` |
| `sn_cmdb_ws.ms.calculate_cmdb_only` (add) | true | see above |
| `sn_cmdb_ws.ms.report_class_ci_count_max_threshold` (add) | 10 million | see above |

## Tables

| Name | Holds |
|---|---|
| `cmdb_multisource_data` | the data store: raw data from all sources |
| `cmdb_multisource_column_metadata` | attribute to column mapping, for query performance |
| `cmdb_multisource_query`, `cmdb_multisource_query_status` | query definitions and execution state |
| `cmdb_multisource_query_result`, `..._result_ms_record`, `..._result_disco_source` | results by result type: CI records, CMDB 360 records, discovery source records |
| `cmdb_multisource_recomp_task`, `cmdb_multisource_recomp_task_ci` | recompute requests and the CIs involved |
| `cmdb_multisource_deny_class` | excluded classes |
| `sn_cmdb_ws_ms_skip_class` | classes skipped by the coverage charts |

## Roles

This page lists `cmdb_ms_read` (run queries; contains `cmdb_read`), `cmdb_ms_editor` (create and run queries; no recompute) and `cmdb_ms_admin` (also properties). **Discrepancy:** the CMDB Workspace components page names the lowest role `cmdb_ms_user` instead of `cmdb_ms_read`, and this page says the admin role contains `cmdb_ms_write`, a role named nowhere else. Check `sys_user_role` on the instance. See [[CMDB Workspace Reference - Properties, Roles, Jobs and Tables]].

## Related

- [[CMDB Workspace Insights and SGC Central]] · [[Duplicate CI Detection in IRE]]
