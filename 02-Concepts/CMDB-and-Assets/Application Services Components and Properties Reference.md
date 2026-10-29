---
type: reference
tags: [reference, cmdb, schema, instance-admin]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Configuration Management > Service instances > Components installed with application services, Manually update an application service with changes from the CMDB, Use application services APIs (read 2026-10-29). https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/components-installed-app-services.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Application Services Components and Properties Reference

**In one line:** the tables, properties and script APIs that come with the **Application Service** plugin (`com.snc.cmdb.it_service`). Concepts: [[Service Instances (Application Services)]].

Properties: **All > Configuration > Application Services > Properties** (role `app_service_admin` to change). Service Mapping adds more properties of its own (not in this chapter).

## Tables

| Table | Label | Holds |
|---|---|---|
| `cmdb_ci_service_auto` | Service Instance | all monitorable services: application services; dynamic CI groups if Service Mapping is active; alert groups if Event Management is active |
| `cmdb_ci_service_discovered` | Mapped Application Service | one container CI per discovered or manual application service |
| `sa_m2m_service_entry_point` | Entry Point | entry points per application service |
| `sa_service_group_member` | Service Group Members | service group membership |
| `sa_service_group_responsibilities` | Business Service Group Responsibilities | roles that may access a service group |
| `sa_baselines` | BaseLines | history timeline baselines |
| `sa_business_service_user_prefs` | Business Service User preferences | per-user map preferences |
| `sa_context_menu` | Menu Action | configurable map context menu options |
| `sa_hash` | Hash | internal counters and hashes |
| `sa_notification` | Discovered Service Notification | internal notifications (mostly Service Mapping) |
| `checkpoint_attribute_description` | Checkpoint Attribute Description | links timeline changes to model checkpoints |
| `cmdb_convert_bulk_services` | Bulk Convert Services | bulk conversions and progress (refreshed every 10 s) |
| `csdm_dashboard_action_report_result`, `csdm_dashboard_type_report_result`, `csdm_dashboard_reports_result` | Application Services Action / Types / Dashboard Results | the service instance dashboard reports |
| `svc_manual_ci_exclusions_inclusions` | Manual CI Inclusions / Exclusions | classes allowed or excluded as members |

## Properties

| Property | Default | Meaning |
|---|---|---|
| `sa.it_service.manual_ci_rel_type` | `5599a965c0a8010e00da3b58b113d70e` (Depends on::Used by) | relationship type sys_id used when CIs are added by hand or via API |
| `sa.history.aggr_interval_coef` | 1 | aggregation of history timeline changes (0 = none) |
| `sa.service_modeling.use` | true | sync Service Mapping operations with Service Modeling |
| `sa.map.LIMIT_MAX_GRAPH_SIZE` | true | limit map size (false may hurt performance) |
| `sa.map.MAX_NODES_FOR_LAYOUT` | 5000 | above this the map is not drawn (error) |
| `sa.map.ALLOW_SPANNING_TREE_VIEW` | true | allow spanning tree view |
| `sa.map.MAX_EDGES_FOR_FULL_LAYOUT` | 1000 | edges before spanning tree view applies |
| `sa.map.MAX_EDGES_FOR_LAYOUT` | 100000 | above this the map is not drawn |
| `sa.map.LIMIT_GRAPH_DEGREE` | 1000 | node degree that switches to compact large-map mode |
| `sa.service_tree.MAX_ITEMS_TO_DISPLAY` | 7000 | Services Tree blocked above this |
| `sa.map.max_connections_in_properties_panel` | 50 | connections shown for a selected line |
| `sa.map.enable_auto_grouping` | true | CI grouping on maps |
| `sa.map.min_nodes_for_auto_grouping` | 10 | minimum CIs for grouping |
| `sncCommonMap.RENDER_FULL_LABELS` | Disabled | full labels: `pdf` (exported PDF only), `all` (map and PDF) |
| `sncCommonMap.NODE_LABEL_WIDTH` | 95 (20 to 1000) | label width in pixels |
| `glide.cmdb.csdm.app_service.max_results` | 100000 (add to `sys_properties`) | cap for the "not in an application service" dashboard reports |
| `sa.service.max_ci_service_population` | 1,000 (add to `sys_properties`) | max CI connections added by update-from-CMDB and manual-service conversion |
| `sa.service.population.stop_expansion_under_ci_classes` | `cmdb_ci_service_discovered` | service classes under which update-from-CMDB does not insert CIs |

## APIs

- REST: **`createOrUpdateService`** (POST; create or update a manual service from CI sys_ids and their hierarchy; services land in `cmdb_ci_service_discovered`; connections default to Depends on::Used by) and **`getContent`** (GET; CIs and relationships of a manual service). Role `app_service_admin` (`app_service_user` for `getContent`).
- JavaScript (server side; the class name and scope are not printed in this chapter, see the *Application Service API* reference): `addCI()`, `addManualConnection()`, `migrateManualToApplicationService()`, `populateApplicationService()`, `removeCI()`, `removeManualConnection()`.
- Before using the API: all CIs must already be in the CMDB, and you need each CI's sys_id and the hierarchy.

## Related

- [[Service Instances (Application Services)]] · [[Integration Options and Interfaces Overview]]
