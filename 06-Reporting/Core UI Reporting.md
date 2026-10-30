---
type: concept
tags: [concept, reporting, access-control, roles, schema, release-specific]
status: documented
source: ServiceNow Brazil docs, Platform Analytics guide > Reporting, dashboards, and Performance Analytics in the Core UI > Reporting (Exploring, Create, Distribute, Report types overview, multiple datasets, scoped reports, Administering: roles, ACLs, permission issues, statistics, sources; Reference: roles, properties), read 2026-10-30. Per-report-type pages, Jelly embedding, Map administration, ACL Assessment, scheduled email steps, and the later sections (responsive dashboards, interactive filters, PA widgets, Analytics Hub, Interactive Analysis, solutions) listed, not read in detail. https://www.servicenow.com/docs/r/now-intelligence/reporting/reporting-landing-page.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Core UI Reporting

**In one line:** classic **Reporting** builds reports (`sys_report`) in the **Report Designer**, on the current state of any non-system table. In Brazil it is the legacy path: net new and migrated instances use [[Platform Analytics Data Visualizations]] instead.

From the Brazil docs; not tested. **Instances net new on Xanadu or later cannot create Core UI reports.** Others can, through **Library > Data Visualizations > Create data visualization > Core UI**, when `com.snc.par.coreui.report_create.enabled` is true (default given as true on the properties page).

**Reports versus Performance Analytics:** reports show now; indicators show trends, targets, thresholds and forecasts. See [[Performance Analytics Concepts and Roles]].

## Report types

Bar (vertical, horizontal), Pareto; Pie, Donut; time series (Area, Spline, Column, Line, Step line, Trend); multidimensional (Pivot, Multilevel pivot, Heatmap, Bubble); scores (Single score, Dial, Speedometer); statistical (Box, Trendbox, Control, Histogram); other (Calendar, Map, List, Funnel, Pyramid).

**Multiple datasets:** bar, horizontal bar, column, line, step line, area, spline. Same type as the parent, same **Group by**, and same **Per** on time series. The legend always shows. Needs `glide.ui.doctype`. No multiple Group by. Limit stated as *up to five tables* and as *5 additional datasets*: unconfirmed variants.

**Analytics Q&A** generates a report from a question: needs Natural Language Query, `com.snc.par.nlq.report_designer.enabled`, and English, French, Canadian French, Spanish, German or Japanese.

**Report sources** (**Reports > Administration > Report Sources**, `sys_report_source`; called **Data Sources** in the Designer): reusable table plus conditions, also the *Predefined conditions* in data visualizations. Changes propagate to every report. A source used by active reports cannot be deleted. Reports with OR conditions match both sets. A related list condition on the source makes a report's own related list conditions ignored or error: both are stated, so avoid mixing.

**Report ranges** split continuous time into intervals (`sys_report_range`).

**Scoped reports:** from another scope you only get Insert, Insert and Stay, Schedule, Add to Dashboard, Export to PDF, Report History. Switch scope to update.

## Access

| Level | Controlled by |
|---|---|
| Who sees the report | sharing: creator only (default), users, groups, roles, everyone |
| Who can create on a table | ACL operation `report_on` (`security_admin`) |
| Who can view results | ACL operation `report_view`, table or field |
| Rows in lists and drilldowns | normal read ACLs |
| Rows in charts | **Before Query business rules** on the source |

- `report_on` only hides the table when creating; users can still view and run reports. A write ACL on `sys_report` controls saving: without it **Save** is disabled, use **Insert** for a copy.
- `report_view` supports **required roles only**, not scripts or conditions; it cannot stop list access (use read ACLs), and also applies to data visualizations. Denied viewers see *Access to this content denied based on report_view field ACLs*. Fields in conditions and dot-walks are checked too.
- With no `report_view` ACL, `glide.report.report_view.read_acl` applies the roles of the table read ACL: `enforce` (default), `log`, `ignore`. Not recommended to change. Only roles count, not scripts or conditions.
- Aggregate reports do not need target table ACLs to view the chart, but hidden records stay out of drilldowns.
- Table ACLs do **not** pass to database views; they need their own (`report_on` and read).
- A global report saved as personal or group is **copied**; a personal one saved as group or global changes its security state.

**System tables** need `glide.ui.permitted_tables`, see [[Platform Analytics Data Visualizations]].

**Brazil change:** on upgrade, **all public Core UI reports are unpublished**. `report_admin` can review `sys_report_public` and property `glide.report.published_reports.enable` (name cut on the page; check it). To limit a report to logged-in users, share with Everyone without publishing.

## Troubleshooting

| Symptom | Cause |
|---|---|
| Nobody else sees it | not shared |
| Fewer rows for one user in a list | read ACLs on each row; a message counts removed rows |
| Different totals in a chart | Before Query business rules |
| Public link stopped | unpublished on upgrade to Brazil |

Add a `read` ACL on `sys_report_source` to hide a data source from users.

## Roles

| Role | Can | Contains |
|---|---|---|
| none | view reports shared with them | |
| `report_user`, `itil` | create, view shared; not share, edit or delete those | `viz_creator` |
| `report_scheduler` | email every report they can see; needs another role that lets them create, edit or share | `report_user` |
| `report_group` | manage and share reports of their groups | `report_user` |
| `report_global` | manage or share reports shared with everyone | `report_user` |
| `report_admin` | everything, plus **Reports > Administration** | `report_scheduler`, `report_global`, `report_group`, `analytics_filter_admin`, `gauge_maker`, `viz_admin` |
| `report_description_admin` | table and field descriptions | |

`report_user` is needed to see the Reports module. `report_publisher` and `report_alias_admin` exist but support deactivated functions.

## Statistics

**Reports > Administration > Report Statistics** (`admin`, `report_admin`): runs, last run, average and recent run time; recent count from `glide.report.recent_executions_number`. Sort **Recent run time** to find slow reports. The Reports Usage dashboard in the Admin Console needs `admin` or `pa_admin`.

## Properties

Main page: **Platform Analytics Administration > Properties > Reporting Properties**.

| Property | Meaning | Default |
|---|---|---|
| `glide.report.report_view.read_acl` | fallback read check | `enforce` |
| `glide.report.calendar.max_days_back` | calendar range | 30 |
| `glide.report.calendar.default_event_duration` | event with no end | 01:00:00 |
| `glide.report.calendar.max_events_displayed_per_cell` | per cell | 3 |
| `glide.chart.histogram.bins` | 1 to 20 | 10 |
| `glide.ui.chart.pie.labels.max_items` | labelled slices | 8 |
| `glide.chart.data.label.truncate_to` | label length | 13 |
| `glide.chart.label.legend.truncate_to`, `.large` | legend length | 14, 20 |
| `glide.ui.chart.bar.horiz.max_col_slant_labels` | before slanting | 5 |
| `glide.ui.filter.first_day_of_week` | 1 Sunday, 2 Monday; add it | 2 |
| `glide.report.metric_max_data_points` | MetricBase | 2000 |
| `glide.report.metric_max_series` | MetricBase, maximum 100 | |
| `glide.ui.report.map.default_map` | Map reports | world |
| `glide.homepage_interactivity.ui_ctrls_max_display_options` | interactive filter choices | 25 |
| `glide.report.add_to_list_supported` | enables the `add_to_list` ACL for list report columns | |

## Example

Report *Example Open by Group* on report source *Example Open Incidents*, bar, group by **Assignment group**, shared with *Example Group*; a `report_view` field ACL on *Example Salary* restricts that field to `report_admin`.

## Related

- [[Migrating Core UI Reporting to Platform Analytics]] · [[Database Views]] · [[Timeline Pages and Schedule Pages]] · [[Platform Analytics Data Visualizations]]
