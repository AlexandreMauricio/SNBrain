---
type: concept
tags: [concept, cmdb, workspace, roles, admin]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > "CMDB Workspace" > Explore (overview, Home, Governance, Explore and Search, Tasks, Data Owner, Lists views, Configuration identifiers framework) and Configure (set up, important actions, quick links, custom lists, attributes and class list for new CIs) (https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/cmdb-workspace.html and the pages under it), read through the docs site API 2026-10-09; also "Platform Analytics Solution for CMDB (legacy)" (https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/cmdb-content-pack.html), read 2026-10-29
sn-release: Brazil
verified:
updated: 2026-10-29
---

# CMDB Workspace

**In one line:** the configurable workspace for the CMDB (**Workspaces > CMDB Workspace**, scope `sn_cmdb_ws`): search and browse CIs, see health and recent activity, work CMDB tasks, and reach every CMDB tool from one place. Service Graph Workspace has been merged into it.

- Store app, installed automatically with the product on install or upgrade.
- Built on Performance Analytics: most cards drill down to a KPI Details pane with **Show Records**.
- **Does not support domain separation.**
- Can be opened in UI Builder like any configurable workspace ([[UI Builder Overview and Concepts]]).

## Roles

| Role | Name | Access |
|---|---|---|
| CMDB Admin | `sn_cmdb_admin` | everything, including policies in CI Class Manager and Data Manager. Contains `sn_cmdb_editor`, `data_manager_admin`, `canvas_admin`, `cmdb_ms_admin`, `cmdb_dedup_admin` |
| CMDB Editor | `sn_cmdb_editor` | write CIs and Data Manager tasks, not policies. Contains `sn_cmdb_user`, `cmdb_ms_editor` |
| CMDB User | `sn_cmdb_user` | read only. Contained indirectly by `itil`. Contains `canvas_user`, `data_manager_user`, `cmdb_ms_user` |

Many cards need an extra role for the data behind them (`sn_incident_read`, `sn_change_read`, `app_service_user`, `service_viewer`, `dependency_views`, `cmdb_query_builder_read`, `evt_mgmt_user`). Full list of roles, properties, jobs and tables: [[CMDB Workspace Reference - Properties, Roles, Jobs and Tables]].

> Instances upgraded straight from Xanadu or Yokohama to Brazil must run the scheduled job *Remove CMDB Roles from ITIL roles and Add CUD access to sn_cmdb_admin/sn_cmdb_editor roles* for these roles to be set up as described.

## Prerequisites

| Plugin | ID | |
|---|---|---|
| CSDM Activation | `com.snc.cmdb.csdm.activation` | recommended (life cycle status mapping to the legacy status fields) |
| CMDB CSDM Support | `com.snc.cmdb.csdm` | required, active by default |
| CMDB Page Templates | `sn_cmdb_pg_templts` | required, active by default |
| CMDB NLQ Search Connected | `sn-cmdb-nlq-search` | required, active by default |

Features shown in the workspace (CMDB Health, CMDB 360, Data Manager) must be set up themselves before their cards show anything.

Demo data: tick **Load demo data** when installing, then run the scheduled job **[Demo] - CMDB Workspace demo data**. Not for production.

## Views

| View | Who | What |
|---|---|---|
| **Home** (default) | admin, editor, user | CI overview charts (CI Summary by CMDB group, My CIs, Cloud vs Non-cloud), My work (open and overdue Data Manager tasks), CMDB Health KPIs, quick links, Otto for CMDB |
| **SGC Central** (Ingestion icon) | `sgc_admin`, `cmdb_inst_admin`, `admin` | Service Graph Connector monitoring ([[CMDB Workspace Insights and SGC Central]]) |
| **Governance** | `sn_cmdb_admin` | important actions, what's new, recent activity, health, success advisor summaries, management tools |
| **Explore and Search** | admin, editor, user | browse classes; AI search, Intelligent Search or conditional search |
| **Tasks** | `data_manager_user` or any of the three | certification, attestation and life-cycle tasks |
| **Insights** | any of the three (some dashboards need more) | dashboards ([[CMDB Workspace Insights and SGC Central]]) |
| **Data Owner** | admin, editor, user | the CIs I own or manage, their health, tasks and related activity |
| **Lists** | admin, editor, user | CMDB lists and related non-CI tables |

### Home

- **CI Summary:** all CIs in up to 20 CMDB groups. Add a group of your own: a CMDB group with **Group type** *CMDB Workspace*, populated by encoded queries; it appears after the job *CMDB Workspace - Group and Encoded Query Counts* next runs. Drill from a class to **Create CI** ([[Create a CI Manually in CMDB Workspace]]).
- On very large CMDBs (a billion CIs) the chart queries can run too long: `sn_cmdb_ws.ci_overview.enable_simple_condition` = true (default false) switches to simpler queries that use only the CSDM status attribute `life_cycle_stage`, not the legacy `operational_status` / status fields. **Fewer results where CSDM has not been adopted.** The simple query is visible in column **Simple Condition** of `cmdb_group_contains_encoded_query`.
- **My CIs:** CIs whose **Managed By Group** is one of your groups, by class category. Property `sn_cmdb_ws.ci_overview.managed_by_me.enabled`.
- **Cloud vs Non-cloud resources:** [[Cloud vs Non-cloud Resources Chart in CMDB Workspace]].
- **Quick links:** Dependency Views, Query Builder, Data Manager, CI Class List, Unified Map, CMDB Health Dashboard, Relationship Health Dashboard, Create CI, Data Certification Dashboard, CMDB Coverage Dashboard. Add your own with **+** (URL must start with `http:` or `https:`); stored in **Quick Links** (`sn_cmdb_ws_quick_links`) and **visible only to the user who added it**.

### Governance

- **Important actions:** cards for health tasks (duplicate, orphan, stale CIs, de-duplication tasks) and Data Manager tasks (reassignment requests, unassigned overdue). A card shows only if at least one record matches its filter. Configured in **CMDB WS Imp Action Card Config** (`sn_cmdb_ws_imp_action_card_config`, open with `sn_cmdb_ws_imp_action_card_config.list`, role `sn_cmdb_admin`): editable **Active**, **Order**, **Filter condition**, **List columns**, **List groupby**; not editable **Persona**, **Type**, **Table**. Rows cannot be added or deleted. Admin and editor cards overlap but admin filters also include unassigned tasks.
- **What's new:** counts of new CIs (`cmdb_ci`), applications (`cmdb_ci_appl`), hardware (`cmdb_ci_hardware`) and service instances (`cmdb_ci_service_auto`), last 24 hours by default.
- **CMDB success advisor:** summaries generated by Otto for CMDB per product area (Data Foundations, HAM, SAM).
- **Management tools**, grouped Manage (CI Class Manager, Data Manager, CMDB Groups, Dynamic CI Groups, de-duplication templates and dashboard, Coverage), Optimize (success advisor, Health, Data Foundations dashboards with plugin `com.snc.cmdb.getwell`, de-duplication tasks, remediation rules), Visualize (Dependency Views, Query Builder, Unified Map), Create (Create CI, Create Service Instance with `service_admin`). Links appear only when the app, plugin and role requirements are met.

### Explore and Search

- **Explore by contexts** (classes grouped in a hierarchy of categories) needs the Store app *Service Graph Workspace - Content* (which brings *Data Model Navigator*). Without it only **Explore by classes** is offered, organised by CMDB groups of type *CMDB Workspace*.
- **AI search** (natural language through Otto): roles `sn_cmdb_user` and `now_assist_panel_user`, Otto for CMDB 3.0 or later, skill *Search result classifier* active. Otherwise the search falls back to **Intelligent Search** (NLQ).
- Intelligent Search shows 100 results, **Load More Results** for the next 100, **Load All Results** up to `glide.cmdb.query.max_results_limit` (default 10,000). A query over more than one table offers **View in Query Builder**. Ambiguous table or relationship names open **Refine your query**.
- **Use conditional search instead** gives a plain condition builder for one class. `sn_cmdb_ws.list.record_count_limit` (default 100,000) caps the result count ("100,000 +").

### Tasks

Overview cards: overdue, in progress, not started, completed (all closed states), excluded records. Tabs **Certification**, **Attestation**, **Lifecycle** list rows of **CMDB Data Management Task** (`cmdb_data_management_task`) by `policy.cmdb_policy_type` (life-cycle = Retire, Archive, Delete, Delete related entry). You see tasks assigned to you or your groups; managers also see their direct reports' and group members' tasks; CMDB Admins also see unassigned ones.

### Data Owner

Filters: **CIs I own** (`owned_by` is me), **CIs I manage** (`managed_by` or a managing group I belong to), then by class. Cards: data sources, ingestion issues, new and updated CIs in 24 hours; health (completeness, correctness, compliance); related incidents, changes and problems; actions and recommended tools. Which related items appear is configured in **Explore CI Related Item Configurations** (`sn_cmdb_ws_explore_ci_related_item_config`, role `sn_cmdb_ws.config_editor`).

### Lists

Default lists come from `sys_ux_list_menu_config` for the workspace: CMDB Groups (`cmdb_group`), CI Identifier (`cmdb_identifier`), Relationships ([[cmdb_rel_ci]]), Tags (`cmdb_key_value`), Switch Forwarding Rules (`dscy_swtch_fwd_rule`), Switch Partitions (`dscy_swtch_partition`), Switch Ports (`cmdb_switch_port`), Switchports (`dscy_switchport`), TCP Connections (`cmdb_tcp`). Editors and admins can add records. **My lists > Create new list** (role `sn_cmdb_user`): start from an existing list or pick a source table, columns and filters.

## Viewing a CI

- Default (`sn_cmdb_ws.explore_ci.record.enabled` = true): [[CI Form in CMDB Workspace]].
- If false: the older **CI details pane** with a 14-day timeline, CI health, attribute groups (configured by the form view *CMDB - Workspace* of the class), activity, infrastructure and service relationships. The timeline fails to load beyond 200 history entries, 100 incidents, 50 requests or 200 events (a link opens the classic timeline). **Save** and **Delete** are for CMDB Admin only.

## Configuration identifiers framework

Lets one CMDB Workspace feature behave differently per workspace, mainly when it is embedded in another workspace.

- **Config identifiers** (`sn_cmdb_ws_config_identifier`): parent record for a set of settings. The base **Default** identifier (Default = Yes, cannot be changed) is workspace-agnostic and is the fallback when a workspace has no entry of its own.
- Roles: `sn_cmdb_ws.config_editor` (child config tables such as `sn_cmdb_ws_config_property`), `sn_cmdb_ws.config_admin` (identifiers too), `sn_cmdb_admin` (the default identifier and its records).
- Used by Unified Map (node limits, levels, endpoint de-duplication, attributes panel, class profiles, life cycle stage filter) and by Create CI:

| Table | Label | Purpose | Fields |
|---|---|---|---|
| `sn_cmdb_ws_ci_additional_attributes` | CI additional attributes config | extra, non-mandatory attributes asked for when creating a CI | Config identifier, CI class, Active, Additional attributes, Apply to hierarchy, Feature (*Create CI*) |
| `sn_cmdb_ws_ci_class_config` | CI class config | which classes are offered for a new CI | Config identifier, CI class, Active, Feature, Apply to hierarchy, Operation (include or exclude) |

Both need role `sn_cmdb_ws.config_editor` and by default hold one entry covering the whole hierarchy.

- The older **Platform Analytics Solution for Configuration Management (CMDB)** (preconfigured PA dashboards) is legacy, replaced by this workspace (Brazil docs).

## Related

- [[CMDB Overview and Class Hierarchy]] · [[CI Class Manager]] · [[CI Relationships]]
