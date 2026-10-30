---
type: concept
tags: [concept, reporting, schema, roles, service-catalog, encoded-query]
status: documented
source: ServiceNow Brazil docs, Platform Analytics guide > Platform Analytics experience > Data visualizations (Explore, Create and types overview, single score as the pattern, calendar, list, indicator scorecard, forecasting, Share edit delete, Configure, Reference), read 2026-10-30. The per-type option and worked example pages (boxplot, bubble, dial, gauge, geomap, heatmap, bar, pie, Pareto, pivot) were listed but not read one by one, nor the end of Colors. https://www.servicenow.com/docs/r/now-intelligence/analytics-center-data-visualizations.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Platform Analytics Data Visualizations

**In one line:** a **data visualization** (`par_visualization`) shows table, indicator or other data as a chart, score or list; it replaces both Core UI reports and PA widgets, which cannot be placed on Platform Analytics dashboards. Library: **All > Platform Analytics > Library > Data Visualizations**.

From the Brazil docs; not tested. Built on Highcharts 12.3.0 in Brazil. Saved from the **Visualization Designer** into the library, or created locally inside an inline dashboard. Core UI reports can still be created from the library on upgraded instances when `com.snc.par.coreui.report_create.enabled` is true, but not on instances net new on Xanadu or later.

From a Core UI list, right-click a column header > **Pie Chart** or **Bar Chart** opens a Platform Analytics visualization on new or fully migrated instances, otherwise a Core UI report.

## Types

| Group | Types | Use |
|---|---|---|
| Score | Single score, Dial, Gauge | one value; dial and gauge against a range, gauge with coloured ranges |
| Time series | Line (default choice), Spline, Scatter, Column, Step, Area | change over time |
| Bars | Horizontal (nominal data), Vertical (ordinal), Pareto | compare across a dimension |
| Parts of a whole | Pie (5 to 7 segments), Donut (up to 5), Semi-donut (up to 4) | segments total 100 %, no two within 10 % |
| Multidimensional | Pivot table, Heatmap, Bubble | several variables |
| Other | Calendar report, List, Indicator Scorecard, Box plot, Geomap | |

Every type shares **Header and border**, data source, **Presentation** (display and colours), **Data update** and **Chart interaction** sections.

Specifics worth remembering:

- **Calendar**: reads from a table (default `task`; **Opened** to **Closed**); shows at most 30 days back from the first visible day, property `glide.report.calendar.max_days_back`; no scheduled export. Migrated ones require both date fields.
- **List**: replaced simple lists in Zurich. **Save before changing columns**, or the default columns are removed. No auto refresh. Runtime options: personalize, group, filter columns, inline edit (not journal fields). Column filters last only for the session; source filters persist for everyone.
- **Indicator Scorecard**: List or Pivot; source by condition, manual selection or indicator group; default metrics last score, change, target, trend; only **Go to data view**.
- **Forecast** on time series: **Show forecast**, not for table sources; overrides the indicator's forecast for this visualization. Methods Auto (default), Linear, Seasonal, Seasonal Trend, STL, Random Forest, Autoregressive. Non-indicator sources need a PA subscription. With too few data points, nothing and no message appears.

## Data sources

| Source | Availability | Notes |
|---|---|---|
| Table | base | predefined conditions from **Report Sources** (`sys_report_source`), custom conditions, questions, catalog variables |
| Indicator | base | breakdowns and elements; benchmark indicators not supported; regular and Data snapshot indicators cannot be mixed |
| Usage Insights | Store application | roles `admin`, `analytics_admin`, `analytics_viewer`; date range mandatory; not on calendar, heatmap, simple list, indicator scorecard; pivot is listed both ways. Application named both *Usage Insights in PAR Integration* and *User Experience PAR Integration*: unconfirmed variants |
| MetricBase | separate subscription | time series; **Go to data view** needs `sn_sow_metric_exp` |
| Workflow Data Fabric | Zero Copy Connector Hub tables | no real-time update on score types |
| Health Log Analytics | | only in UI Builder |

**Multiple sources** must be the same type, and only some visualization types support them: time series are supported, scores are not; the rest of that table lost its values when read, so treat as unconfirmed. Changing to a type without support keeps only the first source, permanently.

**Restrict by role:** one record per source in **Visualization Data Sources Visibility** (`sys_viz_data_source_role`, sources in `sys_viz_data_source`). Existing visualizations stay visible, but their creators lose edit without a listed role. For indicators also `par_vis_config.data_source.can_select_indicator`.

## Filtering table data

Condition builder on the source, **Save as predefined condition** for reuse, plus **Related list conditions** (one related table; counts such as greater than or equal, None, Between).

**Dynamic JavaScript filter:** in a condition value, `javascript:<statement>;` or, for longer logic, `javascript:new <ScriptInclude>().<function>();`. Global scope behaviour is not stated; the script include must be **client callable**, return the right type, and for *is one of* return a comma-delimited list or an array. List fields are not supported, and allowed operators depend on field type. Roles: `itil`, `report_user`, `report_group`, `report_global`, `report_admin`, `admin`.

**Dot-walking**: table sources only, in metrics, group by, columns and conditions; recommended limit three levels; needs `glide.ui.list.allow_extended_fields`.

**Questions** (task-family tables, or `sc_cat_item_producer`): use in filters and group by. Record producer variables work as filter questions but cannot be grouped.

**Catalog variables**: source must be `sc_req_item` or `sc_task`. Roles other than `viz_admin` need adding to ACLs on `sc_item_option`, `sc_item_option_mtom` and `item_option_new`. As main group by they act as an inner join, as secondary an outer join. Box and Trendbox cannot group by them; Single Score, Calendar and Geomap have no group by; Pivot only as columns or rows. Oracle CLOB fields cannot return them.

**Function fields** work here but are configured only in the Core UI Report Designer, by `function_field_admin` (nobody has it on upgrade).

**System tables** such as `syslog`, `syslog_transaction`, `sys_attachment`, `sys_email` are excluded unless added to `glide.ui.permitted_tables`, and then admin only. `sys_audit` is allowed by default, but such unindexed scans on huge tables can slow or stop the instance.

## Chart interactions

| Action | Where | Limits |
|---|---|---|
| **Go to data view** | default for most | table: list (Core UI if `com.glide.par.pae.drilldown_to_core_ui` is true, otherwise Platform Analytics); indicator: KPI Details; Usage Insights: overview; MetricBase: Metrics Explorer |
| **Go to URL** | | not Geomap or Indicator Scorecard |
| **Apply as filter** | inline dashboard editor only | bars, pie, donut; table and indicator; not when group by is a duration |
| **Drill down to chart** | Visualization Designer only | table sources; not from Calendar, Scorecard, List, Geomap; the last level is a Core UI list |

None of these is available in UI Builder: technical dashboards use custom events. Viewers need rights to the data they drill to.

## Value formatting and colour

**Format values** in Metric: duration units, decimals 0 to 4 (not on currency), rounding Up, Down, Ceiling, Floor, Half up, Half down, Half even, thousands separator, abbreviation (not on currency).

Colours default to the UX theme (`sys_ux_theme`, `sys_ux_theme_properties`). Per visualization: single colour, colour per metric, rules on single score, dial and pivot. Target colours from `pa_target_color_schemes`.

## Roles

| Role | Can |
|---|---|
| any role | create on a dashboard they can edit; bookmark and export what is shared |
| `viz_creator`, `itil`, `report_user` | create in the Designer; edit own or shared; share to users and groups |
| `viz_admin`, `platform_analytics_admin` | edit, delete, share (also to roles), export, schedule any |
| `report_admin`, `admin` | as `viz_admin`, plus Core UI reports |
| `par_scheduler` | schedule what they can access; needs another role too |
| `sn_par_sche_export.par_scheduler_admin` | schedule any, delete scheduled exports (contained in `viz_admin`) |

Certify: `admin`, `viz_admin`. `report_view` ACLs still apply however a visualization is reached, and any role can list visualizations at table level. Editing rights from sharing apply in the Designer, not to the copy on a dashboard. Delete is irreversible and does not check dashboard use.

**Export formats** are in [[Platform Analytics Dashboards]]. Page format and orientation: Letter, A4, A3; not for lists.

## Properties

| Property | Meaning | Default |
|---|---|---|
| `par_viz.table_data.max_data_points` | data points, table sources | 10000 |
| `par_viz.table_data.max_groups` | maximum group count honoured, table sources | 50 |
| `par_vis_config.live_refresh_rate_min_value` | minimum live refresh, seconds | 30 |
| `sn_analytics_list.pagination_max_value` | records per page in Lists; above 100 risks memory | 100 |
| `uxa.query_builder.max_num_of_user_filter` | saved Usage Insights filters | 500 |

## Domain separation

Global visualizations reach all child domains; sibling domains stay separate; a copy keeps its design, but data follows the viewer's domain. **Unconfirmed variants on one page:** created in a parent domain, visible to child domains (TOP example) or only inside that parent (*Joe's Company* example).

## Tables

`analytics_visualization` (parent of `sys_report*` and `par_visualization*`), `par_component` (visualizations and filters, extends `sys_metadata`), `par_visualization` (extends `par_component`), `par_component_permission`, `par_visualization_permission`, `par_metadata`, `par_export_visualization`, `report_stats` (usage of migrated items).

## Example

Vertical bar *Example Incidents and Problems by Group* on `incident` and `problem`, both *Active is true*, group by **Assignment group**, side by side, with **Drill down to chart** to single score *Example Open Count*.

```
javascript:new ExampleFilterUtils().getGroupIds("Example Group");
```

## Related

- [[Platform Analytics Dashboards]] · [[Platform Analytics Experience Overview]] · [[Metric Definitions and Metric Instances]] · [[Database Views]]
