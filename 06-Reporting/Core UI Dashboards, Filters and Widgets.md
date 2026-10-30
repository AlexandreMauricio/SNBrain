---
type: concept
tags: [concept, reporting, access-control, roles, release-specific]
status: documented
source: ServiceNow Brazil docs, Platform Analytics guide > Core UI: Responsive dashboards (landing, Exploring, Create and use, empty dashboards, Share, Administering, permissions, Restrict to roles), Interactive Filters (overview, types), Performance Analytics widgets (overview), Analytics Hub (overview, list), Interactive Analysis (overview, Launch), Platform Analytics solutions (overview, available list start, Solution Library and data collection lines), read 2026-10-30. Editing, layout, breakdown, update set and accessibility pages, per-widget and per-filter steps, cascading filter setup, and the full solutions list listed, not read in detail. https://www.servicenow.com/docs/r/now-intelligence/performance-analytics/dashboards-landing-page.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Core UI Dashboards, Filters and Widgets

**In one line:** the classic analytics front end: **responsive dashboards** (`pa_dashboards`) holding reports, **Performance Analytics widgets** and **interactive filters**. All are in **maintenance mode, security fixes only**, and replaced by [[Platform Analytics Dashboards]] and [[Platform Analytics Filters]].

From the Brazil docs; not tested. Older instances keep them until migrated: see [[Migrating Core UI Reporting to Platform Analytics]].

| Piece | Net new status | Replaced by |
|---|---|---|
| Responsive dashboards | cannot create on net new Xanadu or later | Platform Analytics dashboards |
| Interactive filters | cannot create on net new Yokohama or later; **from Australia only `report_admin` creates and edits** | Filters in Platform Analytics |
| PA widgets | not on Platform Analytics dashboards or UI Builder, except compatibility mode | [[Platform Analytics Data Visualizations]] |
| Analytics Hub | only KPI Details after migrating | [[KPI Details and KPI Signals]] |
| Interactive Analysis | **not supported in Platform Analytics** | none stated |

Responsive dashboards cannot show data visualizations.

## Responsive dashboards

- Edits are global, because dashboards are shared.
- **Share panel** gives view or view and edit.
- **Empty page and empty selector:** the title holds a tab, newline or special ASCII character; fix it at `pa_dashboards_list.do`.
- **Performance Analytics > System > Dashboard Administration** lists all, for `dashboard_admin`.

| Who | View | Create | Edit | Delete |
|---|---|---|---|---|
| no role | shared only | no | no | no |
| any role | own, shared | yes | own, or shared with edit; no PA widget changes | own |
| `pa_power_user`, `pa_admin` | as above | yes | as above, plus PA widgets; manage sharing on what they edit | own |
| `dashboard_admin`, `admin` | all | yes | all, change owner | all |

- **Widget ACLs apply, except on PA widgets:** anyone who can view the dashboard sees all its PA widgets. A blocked widget shows an empty placeholder. Aggregate charts show all records; list rows and drilldowns follow ACLs. Real-time scores differ by viewer.
- **Quebec** onward, widgets follow indicator and breakdown ACLs, which reads against the point above: unconfirmed.
- Explicit Roles: `snc_external` users cannot view dashboards by default.
- **Restrict to roles** is not recommended; it is not sharing, and migrated dashboards get `pa_viewer` and `pa_contributor` filled in.

Properties: `glide.cms.share_dashboards.role` (a misspelled single role stops everyone sharing), `glide.cms.dashboards.sharing_with_secure_search`, `glide.cms.dashboards.sharing.search.maxRecords` (create it).

## Interactive filters

Filter reports on a dashboard without changing them; choices persist per user. Types: choice list, reference, date, Boolean, group, empty or non-empty, cascading, and scripted custom filters. **PA widgets ignore them** (use breakdown controls); MetricBase reports are not supported.

Create role stated as `hp_publisher_admin` and `report_admin`. `hp_publisher_admin` contains `analytics_filter_admin`.

## PA widgets

Tie an indicator to a visualization. `pa_power_user` or `pa_admin` create them, though one line says `pa_admin` is required: unconfirmed.

| Type | Shows |
|---|---|
| Time Series | scores over time |
| Breakdown | scores by element |
| Score | latest, speedometer, real-time |
| List | several indicators |
| Pivot | one indicator, two breakdowns, heatmap |
| Text analytics | word cloud |
| Workbench | related indicators of a process |

Values round: 10,000 up uses K, a million up M, a billion up G, so averages may be off slightly.

## Analytics Hub and Interactive Analysis

**Analytics Hub** (**Performance Analytics > Analytics Hub**): indicator list and detail view with trends, predictions and breakdowns. Replaced scorecards.

**Interactive Analysis:** right-click a reference, choice, date/time, integer or Boolean column header > **Launch Interactive Analysis**. No role beyond list access. Visible columns decide the Group by, Stack by and filter options; filters persist per view and user.

## Platform Analytics solutions

Prepackaged dashboards and indicators per product, free, but they may need the matching PA entitlement and underlying licences; mostly Core UI, being replaced. Install through **PA Solution Library > Solutions**, review sources and scripts against your tables, run the **Historic Data Collection** job, then schedule. Examples: `com.snc.pa.cmdb`, `com.snc.pa.knowledge_v2`, `com.snc.pa.chat`, `com.snc.pa.change`, `com.snc.pa.customer_service_advanced`. See [[Performance Analytics Data Collection]].

## Example

On an older instance, share *Example Dashboard* with *Example Group* as view only, then right-click **Priority** on an incident list and launch Interactive Analysis.

## Related

- [[Core UI Reporting]] · [[Performance Analytics Concepts and Roles]] · [[ITSM Success Dashboard]]
