---
type: reference
tags: [reference, cmdb, workspace, roles, instance-admin, automation]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB Workspace > Reference, topics "Components installed with CMDB Workspace" and "CMDB Workspace scheduled jobs" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/cmdb-workspace.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# CMDB Workspace Reference - Properties, Roles, Jobs and Tables

**What it is:** what the CMDB Workspace app (`sn_cmdb_ws`) and the Configuration Management (CMDB) plugin (`com.snc.cmdb`) install for [[CMDB Workspace]]. The app also adds the CMDB group type *CMDB Workspace*.

## Properties

Most are not present until added to `sys_properties`.

| Property | Default | Effect |
|---|---|---|
| `sn_cmdb_ws.explore_ci.record.enabled` | true | use [[CI Form in CMDB Workspace]] when opening a CI; false = basic view (for example while custom configuration is migrated) |
| `sn_cmdb_ws.ci_overview.managed_by_me.enabled` | true | show the My CIs chart (for `sn_cmdb_editor`) |
| `sn_cmdb_ws.total_cis.enabled` | true | show the Total CIs section |
| `sn_cmdb_ws.ci_overview.enable_simple_condition` | false | simpler CI overview queries for very large CMDBs |
| `sn_cmdb_ws.list.record_count_limit` | 100,000 | cap on the result count in conditional search; higher costs performance |
| `sn_cmdb_ws.unifiedmap.map_search_filter.default_levels` | 3 | initial levels up and down from the home node in Unified Map (`sn_cmdb_admin`, affects all users) |
| `sn_cmdb_ws.unifiedmap.map_search_filter.max_levels` | 25 | maximum levels in Unified Map |
| `sn_cmdb_ws.ms.discovery_source_not_reporting_max_days` | 7 | CMDB 360: days after which a CI counts as no longer reported by a source. Set in CMDB 360 > **Settings** |
| `sn_cmdb_ws.ms.report_max_limit` | 100,000 | CMDB 360: maximum records in chart drill-downs. Set in CMDB 360 > **Settings** |
| `sn_cmdb_ws.insight.category.disable_after_failure` | 3 | consecutive failed days before a cloud / non-cloud job is disabled |

## Roles

| Role | Name | Contains | Notes |
|---|---|---|---|
| CMDB Admin | `sn_cmdb_admin` | `data_manager_admin`, `canvas_admin`, `sn_cmdb_editor`, `cmdb_ms_admin`, `cmdb_dedup_admin` | full access including `cmdb_ci` and default config identifier records |
| CMDB Editor | `sn_cmdb_editor` | `sn_cmdb_user`, `cmdb_ms_editor` | writes CIs and Data Manager tasks, not policies |
| CMDB User | `sn_cmdb_user` | `canvas_user`, `data_manager_user`, `cmdb_ms_user` | read only; contained indirectly by `itil` |
| Multisource CMDB Admin | `cmdb_ms_admin` | `cmdb_ms_editor` | CMDB 360 data, dashboard configuration, queries |
| Multisource CMDB Editor | `cmdb_ms_editor` | `cmdb_ms_user` | create and edit CMDB 360 queries |
| Multisource CMDB User | `cmdb_ms_user` | `cmdb_read` | read CMDB 360 |
| Workspace Config Admin | `sn_cmdb_ws.config_admin` | `sn_cmdb_ws.config_editor` | config identifiers and child tables (non-default records) |
| Workspace Config Editor | `sn_cmdb_ws.config_editor` | | child config tables such as `sn_cmdb_ws_config_property` |
| | `cmdb_manual_ci_ire_access` | | manual CI creation through IRE; in `sn_cmdb_editor` by default |

## Scheduled jobs

| Job | Does |
|---|---|
| CMDB Workspace Collection - CI Overview, New CIs, New hardware, New application, New application services, Total / Updated application services, Updated CIs, Orphan CIs, Application service outages, Data Manager Policies, Data Manager Tasks | collect the counts behind Home and Governance cards |
| CMDB Workspace Collection - CMDBPerformance.Integrations.Processing Rate / .Rows | Service Graph connector rate and row counts |
| CMDB Workspace Collection On Demand with Lookback | 30 days of history for some indicators; runs on install or upgrade only |
| CMDB Workspace - Populate aggregates Daily | fills `sn_cmdb_ws_base_aggregate_data`, then calls *CMDB Workspace Aggregates Daily Collection* (a Performance Analytics job) |
| CMDB Workspace - Populate aggregates Monthly | IRE-by-source data, then calls *Aggregates Monthly Collection* |
| Multisource Dashboard Collection, Multisource Dashboard Analytics Population | CMDB 360 dashboard statistics, daily |
| insight - cloud non-cloud aggregate; Insight - Cloud / Non-cloud (Applications, DB Instances, Kubernetes Cluster, Servers, Storage Volume, VM Instances), Insight - Cloud Object Storage, Insight - Cloud Service Account | [[Cloud vs Non-cloud Resources Chart in CMDB Workspace]] |
| PopulateDuplicate Task Group Daily | groups de-duplication tasks with a root cause summary, for Otto for CMDB |
| [Demo] jobs | only when demo data was loaded |

Indicators stored by *Aggregates Daily Collection*: CI relationship missing parent or child, related records missing references, duplicate records, stale records, usage of data attestation, Data Manager, Intelligent Search and Query Builder, total CIs, total partial payloads.

## Tables

| Name | Label | Holds |
|---|---|---|
| `sn_cmdb_ws_imp_action_card_config` | Important Actions Configuration | important action cards and performance recommendations |
| `sn_cmdb_ws_quick_links` | Quick Links | Home quick links |
| `sn_cmdb_ws_group_metadata`, `sn_cmdb_ws_group_query_metadata` | CMDB Group (Query) Metadata | CI counts per group and per encoded query |
| `sn_cmdb_ws_nlq_sample_search`, `sn_cmdb_ws_nlq_sample_search_table`, `sn_cmdb_ws_nlq_excluded_table` | NLQ ... | Intelligent Search sample searches, and tables excluded for ambiguous names |
| `sn_cmdb_ws_base_aggregate_data` | Base Aggregate Data | counts for cards; a new row per refresh, cards read rows with State = ready. Read only |
| `sn_cmdb_ws_datacenter_type`, `sn_cmdb_ws_insight_query_category`, `sn_cmdb_ws_product_insight_data`, `sn_cmdb_ws_app_svc_insight_data` | | cloud / non-cloud configuration and data (`sn_cmdb_ws_insight_data` is the legacy data table before app version 3.4) |
| `sn_cmdb_ws_service_graph_connector`, `sn_cmdb_ws_integration_aggregate_data`, `sn_cmdb_ws_partial_payload_item` | | connector catalogue, outlier data, partial payloads for performance insights. Read only |
| `sn_cmdb_ws_rating_config`, `sn_cmdb_ws_feature_category`, `sn_cmdb_ws_feature_category_runtime_attribute` | | feature adoption thresholds and card metadata. Read only |
| `sn_cmdb_ws_ms_cis_by_number_of_sources`, `sn_cmdb_ws_ms_cis_with_single_source`, `sn_cmdb_ws_ms_class_metadata`, `sn_cmdb_ws_ms_data_mismatch`, `sn_cmdb_ws_ms_data_mismatch_config`, `sn_cmdb_ws_ms_discovery_sources_not_reporting`, `sn_cmdb_ws_ms_settings_weight_type` | | CMDB 360 dashboard data and settings |
| `sn_cmdb_ws_config_identifier`, `sn_cmdb_ws_config_property`, `sn_cmdb_ws_ci_additional_attributes`, `sn_cmdb_ws_ci_class_config` | | configuration identifiers framework |
| `sn_cmdb_ws_node_map_table_attributes`, `sn_cmdb_ws_node_map_related_item`, `sn_cmdb_ws_node_map_reference`, `sn_cmdb_ws_node_map_profiles`, `sn_cmdb_ws_class_icon` | | Unified Map: attributes panel, related items, reference connections, class profiles, icons |
| `sn_cmdb_ws_explore_ci_related_item_config` | Explore CI Related Item Configurations | related item charts on CI Form and Data Owner view |
| `sn_cmdb_ws_dm_certification_task_to_document`, `sn_cmdb_ws_dm_certification_attribute_status`, `sn_cmdb_ws_dm_task_execution_context` | | Data Manager certification task details |
| `sn_cmdb_ws_reconcile_duplicate_task_group`, `sn_cmdb_ws_reconcile_duplicate_task_group_m2m` | Remediate Duplicate Task Groups, Group Task Mapping | grouped de-duplication tasks (write `sn_cmdb_admin`; read `sn_cmdb_user` or `dedup_admin`) |

## Related

- [[CMDB Workspace Insights and SGC Central]]
