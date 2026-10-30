---
type: concept
tags: [concept, reporting, schema, domain-separation]
status: documented
source: ServiceNow Brazil docs, Platform Analytics guide > Platform Analytics experience > Filters (all pages), read 2026-10-30. https://www.servicenow.com/docs/r/now-intelligence/interactive-filters-workspace.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Platform Analytics Filters

**In one line:** dashboard filters narrow the lists and data visualizations on a tab or a whole dashboard, by value, true or false, date or domain; a **filter group** applies several with one action. Library: **All > Platform Analytics > Library > Filters**.

From the Brazil docs; not tested.

## Creating and placing

| Where | Role |
|---|---|
| Inline dashboard: **Add new element > Filter** > New or Saved | `dashboard_admin`, the owner, or shared edit rights |
| **Filter Designer** (**Library > Filters > New**), saved for reuse | `analytics_filter_admin`, `admin` |
| Technical dashboard: filter component in UI Builder, with event handlers | `ui_builder_admin` |

Library filters are **not** accessible in the technical editor or other UI Builder pages.

On a tab it affects that tab; above the tabs or with no tabs, the whole dashboard. Usage Insights filters always act globally on the dashboard.

Values persist per viewer on inline dashboards. Editing a filter's configuration resets it to defaults for everyone. PowerPoint export always applies filter values; PDF lets you choose. A **URL** with filter values overrides configured values and user preferences.

## Types

- **Single select** (default) and **Multiple select**. Source: a table and field (reference, string or choice fields only), an indicator breakdown, or Usage Insights. MetricBase and Workflow Data Fabric tables appear under Tables (for MetricBase select no field). Picking a reference field resets the source to the referenced table. Initial load default 500 elements.
- **True/False**: custom labels; true/false fields or a two-value bucket breakdown (`pa_buckets`; the system cannot check it is really Boolean). Empty values mean true plus false can total less than all records.
- **Date**: Score, Time series, Bar and Pie/Donut; applies automatically to indicators and MetricBase KPIs on the tab, table date fields must be added. For indicators **Apply date range** must be on (implicit on time series). Calendar, relative ranges or both; fiscal ranges; optional time selection.
- **Domain**: see below.

Elements include Pill, Checkboxes and Typeahead. A filter applies only to visualizations sharing its table or breakdown. With a multiple select on a breakdown, a visualization with no breakdown shows an aggregate of the elements; one with that breakdown shows each element separately.

Indicator breakdown limits: the breakdown must be used by an indicator; scripted breakdowns are not supported; two breakdown levels at a time, counting filters and the visualization's own.

**A visualization as a filter:** Chart interaction **Apply as filter**, inline dashboards, bars, pie or donut, table or indicator, group by not a duration.

## Cascades

**Other filters to follow** is set on a dashboard only, not in the designer, needs the Pill element and Table or Indicator Breakdown filters, and the followed filter must filter data on the same table as the follower's source.

- **Direct**: *Manager* filter (source `sys_user`) with data to filter both `incident.assignment_group.manager` and `sys_user_group.manager`; *Group* filter follows it.
- **Many-to-many**: needs a connecting table from `sys_m2m` or `sys_collection`, for example `sys_user_grmember`. Listed under **Filters with table connection**. Custom tables need a many-to-many definition first.
- **Mutual**: both must use the same connection type, and many-to-many must share one connecting table.
- **Hierarchical**: table source, no field, **Is in hierarchy**, a hierarchy from `sys_record_hierarchy` (not GRC or other tables), a starting value.

## Filter groups

Any type except Domain, inline dashboards only. One apply makes one database call, so it can be faster than separate filters. Settings: label, horizontal or vertical layout, **Show group apply** (off = each change applies at once), clear, reset.

## URL parameters

Filter values go in the path after the dashboard sys_id as `/unifiedFiltersParam/<key>:<values>;<key>:<values>`, with the key being **Filter Custom Id** (Advanced options) or else the filter id; values comma separated and URI encoded.

```
/now/platform-analytics-workspace/dashboards/params/edit/true/sys-id/<dashboard_sys_id>/unifiedFiltersParam/example-category:database,hardware;active:true
```

**Copy link with filter** in Share builds it. URLs over 2000 characters are shortened through TinyURL, which is worth weighing if filter values are sensitive (inference). Clearing filters resets the dashboard, but the URL still shows the old values.

## Domain filters

Separate component. Needs `com.glide.domain.msp_extensions.installer` and `com.snc.pa.domain_support`; `ui_builder_admin` or `admin`. Tab filters beat top-level ones. Choose **Performance Analytics domain configuration** or **standard domain list**, and **Include global domain data**.

| Display | Global included | Indicator data | Table data, database views |
|---|---|---|---|
| Domain list | yes | selected domain only | selected, global, and child or parent domains |
| Domain list | no | selected domain only | selected and children |
| Domain configuration | yes | selected only if a job collected for it; aggregates from all domains of the configuration, no children or global | selected, children and global; aggregates add global too |
| Domain configuration | no | as above | selected and children, no global |

## Editing

Saved filters: needs `viz_admin` or higher on a dashboard, or `analytics_filter_admin` from the library; otherwise **Unlink from library**. Saving a shared filter asks: this dashboard only, or the library (all dashboards). **Open record** shows the JSON (`admin`).

**Error** *This option is not available for the specified filter source*: a migrated breakdown filter with no indicator. Open `pa_breakdowns.list`, the breakdown, **Indicators** tab, and add indicators.

## Tables

`par_component` (visualizations and filters), `par_component_filter` (library filters, extends `par_component`), `par_component_filter_permission`, `par_dashboard_filter` (filters per dashboard).

## Example

Dashboard *Example Service Desk Overview*: multiple select *Example Group* on `sys_user_group`, single select *Example Member* following it through `sys_user_grmember` with data to filter `incident.assigned_to`, and date filter *Last 30 days*, all in a filter group with **Show group apply** on.

## Related

- [[Platform Analytics Dashboards]] · [[Platform Analytics Data Visualizations]] · [[Migrating Core UI Reporting to Platform Analytics]]
