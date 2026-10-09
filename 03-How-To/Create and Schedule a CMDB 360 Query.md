---
type: how-to
tags: [how-to, cmdb, reporting, workspace, discovery]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB 360, topics "Create a Get Records query", "Create a Find Gap query", "Create a Compare Attribute Values query", "Schedule a query for a report" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/multisource-cmdb.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# Create and Schedule a CMDB 360 Query

**Goal:** question the [[CMDB 360]] data store: which sources report which CIs, where a source has stopped reporting, where sources disagree. Then run the query on a schedule so a report can use it.
**Where:** **Workspaces > CMDB Workspace > Insights > CMDB 360** > **Saved queries** > **Create Query**.
**Roles:** `sn_cmdb_user` plus `cmdb_ms_admin` or `cmdb_ms_editor`.

## The three query types

| Type | Choose | Answers |
|---|---|---|
| **Get Records** | *I want to get CMDB 360 data* | CIs of chosen classes as reported by chosen sources |
| **Find Gap** | *I want to find gaps in data between discovery sources* | CIs that some sources report and another does not |
| **Compare Attribute Values** | *I want to compare attribute values between discovery sources or against the CMDB* | CIs whose attribute values differ between sources, or between a source and the CMDB |

## Steps

**Get Records**

1. Select CI classes (click a class to add conditions), or **All Classes**. **Continue**.
2. Select discovery sources (empty = all). **Continue**.
3. Results layout: **Show unique CMDB 360 records** (one per CI) or **Show CI records by discovery source** (one per CI and source); **Limit results to** an application service, technical service or CMDB group. **Continue**.
4. Name, description, **Save**.

**Find Gap**

1. Select classes. **Continue**.
2. Select the **non-reporting** sources (several = OR) and one or two **reporting** sources as baseline (empty = all). **Continue**.
3. Results layout as above. Name, **Save**.

**Compare Attribute Values**

1. Select **one** class, with conditions if wanted. **Continue**.
2. **Any attribute doesn't match** or **Every attribute doesn't match**; select the attributes. **Continue**.
3. Select at least two sources, or tick **Compare to CMDB** and select one. Optionally **Limit results to**. **Continue**.
4. Name, **Save**.

## Results

- **Load More Results** shows the next page (100 per page, `glide.identification_engine.multisource.query.batch.limit`); **Load All Results** goes up to 10,000 (`...multisource.query.max.limit`).
- A **CMDB 360 Source** link opens the data preview for that source; a record link opens the CI, where **View CMDB 360 Data** is available.

## Schedule and report

1. Run the query at least once.
2. **Schedule query** (on the Results Layout page; for Compare Attribute Values on the Discovery Sources page), or **Create Schedule** on the results page.
3. **Run frequency** and time (weekly and monthly also need a day). **Save**.
4. **Create Report**: the report is refreshed by each scheduled run and is managed with normal reporting.

## Example

Find Gap query `Example - servers missing from agent`: class **Server**, non-reporting source *AgentClientCollector*, reporting source *ServiceNow*, unique CMDB 360 records, limited to the CMDB group `Example Production Servers`. Scheduled weekly on Monday; the report lists servers Discovery sees but the agent does not.

## Gotchas

- No schedule or report until the query has been run once.
- Raising the two limit properties costs query performance.

## Related

- [[CMDB Groups]] · [[CMDB Workspace Insights and SGC Central]]
