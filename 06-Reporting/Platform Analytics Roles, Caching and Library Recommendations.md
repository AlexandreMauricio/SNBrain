---
type: reference
tags: [reference, reporting, roles, schema]
status: documented
source: ServiceNow Brazil docs, Platform Analytics guide > Platform Analytics experience > Reference (Data caching, roles, tables, UI artifacts, properties), Library recommendations, Creating Platform Analytics pages (overview and Add a dashboard to a page; UI Builder property, event, URL delegation and data broker pages not read), read 2026-10-30. https://www.servicenow.com/docs/r/now-intelligence/platform-analytics-exp-reference.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Platform Analytics Roles, Caching and Library Recommendations

Shared reference for the Platform Analytics experience. From the Brazil docs; not tested.

## Roles

No role here is assigned to a group by default, none needs a paid allocation (most PA functions need a subscription), and none is elevated. All are base system except `analytics_admin` (Usage Insights) and `sn_process_optimization_analyst` (Process Mining).

| Role | Purpose | Contains or contained by |
|---|---|---|
| `platform_analytics_admin` | administration across the experience; equivalent to `admin` for security | contains `analytics_admin`, `analytics_categories_admin`, `analytics_filter_admin`, `dashboard_admin` and more |
| `analytics_admin` | Usage Insights administration | contains other Usage Insights roles |
| `analytics_categories_admin` | dashboard categories | |
| `analytics_filter_admin` | edit or delete any filter, add to the library | |
| `dashboard_admin` | any dashboard, Platform Analytics or responsive | contained by `platform_analytics_admin` |
| `pa_admin` | Performance Analytics administration; equivalent to `admin` for security | contains the other PA roles |
| `pa_kpi_signal_admin` | activate KPI Signals | none, but `pa_admin` has the same rights |
| `par_scheduler` | schedule email of what they can view or edit | |
| `sn_par_sche_export.par_scheduler_admin` | as `par_scheduler`, full CRUD on `par_export` | |
| `viz_creator` | Designer: create, edit, export, share to groups and users | contained by `viz_admin` (implicit), `itil`, `report_user` |
| `viz_admin` | all actions on any visualization, share to roles, schedule all | contains `viz_creator`; contained by `pa_power_user` (as read; table alignment lost) |
| `report_admin` | as `viz_admin`, plus Core UI reports including Service Portal | |
| `now_assist_explorer_user` | AI Data Explorer explorations | |
| `sn_process_optimization_analyst` | Process Mining map on dashboards | |

**Unconfirmed variant:** one cell spells `platform_analytics_admim`.

**Filters:** add to a dashboard: any role with edit rights (`dashboard_admin` for any). Edit a library filter or use the designer: `analytics_filter_admin` or higher.

Least privilege example from the docs: to create and export library visualizations, grant `viz_creator`, not `viz_admin`.

## Data caching

Table and indicator data only. Needs `glide.analytics.cache.enabled` = true. Per dashboard in the inline editor, per visualization or local data instance in UI Builder (`useDataCache`).

| Property | Meaning | Default |
|---|---|---|
| `glide.analytics.cache.enable_dashboard_default` | new inline dashboards start cached | off (implied) |
| `glide.analytics.cache.dashboard_default_value` | default expiry: 1, 2, 4, 8, 12 or 24 hours | 24 hours |
| `glide.analytics.cache.prefetch.min_age_in_seconds` | minimum cache expiry to be prefetched; raise, do not lower | 8 hours |
| `glide.analytics.cache.prefetch.max_refresh_counter` | prefetches without a hit before stopping; lower, do not raise | 10 implied by the text |

**Prefetch** keeps entries alive: a job every 15 minutes finds entries expiring in the next 30 minutes and refreshes them, on by default, so the first agent of the day does not wait. See also [[Platform Analytics Dashboards]].

## Core UI artifact creation

`com.snc.par.coreui.dashboard_create.enabled` and `com.snc.par.coreui.report_create.enabled`: any internal role can create that Core UI artifact from the library. If absent or false, only a user with the matching admin role can (text cut when read). They exist only on upgraded instances and have no effect on instances net new on Xanadu or later.

## Admin menu

**All > Platform Analytics Administration**: **Core UI Artifacts** (Dashboards `pa_dashboards`, Widgets `pa_widgets`, Reports `sys_report`, Interactive Filters `sys_ui_hp_publisher`, each with a Migrate action) and **Next Experience Artifacts** (Dashboards `par_dashboard` with **Rollback**, Data Visualizations `par_visualization`, Filters `par_component_filter`).

## Library recommendations

Store application **Analytics Library Recommendations** (`app-analytics-recommendations`). A panel of tiles on each library page, for admins, that filters the list. Job *Analytics library management job*, weekly by default; deactivate it to switch the feature off.

| Library | Visible to | Tiles |
|---|---|---|
| Dashboards | `dashboard_admin` and higher | unused, empty, no active owner |
| Data visualizations | `viz_admin` and higher, including `pa_admin` | not on any dashboard, no active owner |
| Indicators | `pa_admin` and higher | inactive jobs, empty sources, or no recent views |

Property `sn_analytics_rcmnd.recommendation_metrics_time_period`: days defining recent usage (create it). `com.glide.par.v_table_join.enabled` true limits recommendations to Next Experience items. Tables `analytics_library_scan_item`, `analytics_library_scan_execution`.

## Pages in your own workspace

Either a prebuilt workspace from **App Engine Studio**, or page templates in UI Builder. A Dashboard component cannot be added alone: create the page from the **Dashboards** template. First add the workspace to the dashboard's **Dashboard Visibility**, then set **Default dashboard** (or bind it), optionally **Tab SysId**, and **Use as embedded** to isolate it from page URL parameters. Custom redirection, URL parameter delegation, global filters and the data broker are UI Builder configuration, not summarised.

## Example

For *Example Group*, an analyst gets `viz_creator` and `par_scheduler`, a manager gets `dashboard_admin`, and `glide.analytics.cache.enabled` stays true with new dashboards cached for 8 hours through `glide.analytics.cache.dashboard_default_value`.

## Related

- [[Platform Analytics Experience Overview]] · [[KPI Details and KPI Signals]] · [[Platform Analytics Filters]]
