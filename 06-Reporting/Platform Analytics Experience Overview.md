---
type: concept
tags: [concept, reporting, workspace, release-specific]
status: documented
source: ServiceNow Brazil docs, Platform Analytics guide > Platform Analytics experience (landing page), Analytics Overview, read 2026-10-30. https://www.servicenow.com/docs/r/now-intelligence/par-workspace.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Platform Analytics Experience Overview

**In one line:** the **Platform Analytics experience** (**All > Platform Analytics**) is the single interface for dashboards, data visualizations, filters and KPIs, replacing the separate Core UI tools for reports and Performance Analytics widgets.

From the Brazil docs; not tested. Core UI reports and dashboards are still visible from the Core UI tools: `report_admin` creates and edits Core UI reports, `dashboard_admin` Core UI dashboards.

**Unconfirmed variant:** one page says the experience is on by default on upgrade to **Brazil**, another on upgrade to **Australia**.

## Parts

| Part | What it holds |
|---|---|
| **Analytics Overview** | role-specific quick view: bookmarked, created by me, certified; **Create** button (Dashboard, Data Visualization, Filter, Scheduled Export, Indicator); search; Analytics Q&A (natural-language questions answered with a visualization) |
| **Library** | **Dashboards**, **Data Visualizations**, **Filters**, **Indicators**, **Scheduled Exports**, with a link to Usage Insights |
| **KPI Details** | trends, forecasts, records behind a KPI score; breakdowns and time aggregations |
| **KPI Signals** | notifies when a KPI score changes significantly |

Search uses AI Search if enabled, otherwise Zing. **Create Indicator** needs the plugin `com.snc.pa.premium`. An Analytics Overview with library tabs can be added to your own configurable workspace.

## Who sees what on the overview

Access to artifact types depends on role; recorded role names: `platform_analytics_admin`, `pa_admin`, `dashboard_admin`, `viz_admin`, `par_scheduler`, `report_admin`. Users outside the analytics admin roles get only Dashboards, Data Visualizations and Indicators in the left pane.

The table column alignment was lost when the page was read, so which role reaches which artifact is not recorded here.

- Score cards for data collection (jobs with errors, with warnings, running over 1 hour): `pa_admin`, `pa_data_collector`, `pa_power_user`; `platform_analytics_admin` sees all; `viz_admin` and report admins see none.
- Dashboard usage and load time cards (under or over 5 seconds): `dashboard_admin` and `platform_analytics_admin`, and only when Usage Insights (`glide.analytics.enabled`) has data.

**Unconfirmed variants of spelling on these pages:** `pa-admin` and `pa_admin`; `reports_admin` and `report_admin`.

## Example

A *Test User* with `viz_admin` opens **All > Platform Analytics > Analytics Overview**, finds *Example Open Incidents by Priority* under **Certified**, and bookmarks it.

## Related

- [[Platform Analytics Dashboards]] · [[Migrating Core UI Reporting to Platform Analytics]] · [[Proactive Analytics Insights on Dashboards]]
- [[ITSM Platform Analytics Dashboards and KPIs]] · [[Application Development Tools and Lifecycle]]
