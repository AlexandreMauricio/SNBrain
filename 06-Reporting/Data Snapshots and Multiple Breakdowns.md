---
type: concept
tags: [concept, reporting, schema, release-specific]
status: documented
source: ServiceNow Brazil docs, Platform Analytics guide > Performance Analytics > Data snapshots and multiple breakdowns (overview, Activate), read 2026-10-30. Limitations, sources, calculated fields, jobs and tables, logs pages listed, not read in detail. https://www.servicenow.com/docs/r/now-intelligence/performance-analytics/multi-level-breakdowns.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Data Snapshots and Multiple Breakdowns

**In one line:** **Data snapshots** replaces classic breakdown matrices with change data capture and run-time scoring, so an indicator can take **more than two breakdown levels**.

From the Brazil docs; not tested. Classic PA stops at two because the calculations grow geometrically.

## Requirements

- **RaptorDB Professional**; plugin **Data Snapshots** (`com.snc.pa.mlb`) then installs automatically.
- A PA subscription on production.
- **Not domain separated.** Activating domain separation, or deactivating the plugin, turns the feature off.
- Test in development first; it may use more storage, as jobs copy subsets of source tables.

## Which indicators

Automated without scripted aggregates; formula with only such contributors, also nested. Otherwise a warning on the record explains why. Unsupported indicators keep two levels, so on one dashboard a filter set can apply fully to one visualization and partly to another.

Only data visualizations and KPI Details show more than two levels. **Data collected before activation** allows only two; a third breakdown leaves that date range empty.

## Activate

**Platform Analytics > Library > Indicators > Check instance eligibility** > add columns **Data snapshots status** and **Fact table row count** > select > **Enable Data Snapshots**. A warning appears if rows exceed the licence or storage limit. Classic jobs keep running in parallel, giving a smooth rollback. Then check the **Data snapshots source**, its calendar and frequency.

Roles for one indicator: if a source exists, `pa_data_collector`, `pa_power_user` or higher; if one must be generated, `pa_data_collector` or higher.

No KPI Signals, target responsibility or Benchmark use; PAFormulaUtils is not supported, and classic and Data snapshots indicators cannot be mixed in a formula or a visualization.

## Example

On a RaptorDB Professional test instance, enable *Example Open Count*, wait for scores, then in KPI Details filter by *Priority*, *Category* and *State* together for dates after activation.

## Related

- [[Performance Analytics Concepts and Roles]] · [[KPI Details and KPI Signals]] · [[Platform Analytics Filters]]
