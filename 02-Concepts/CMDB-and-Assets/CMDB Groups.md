---
type: concept
tags: [concept, cmdb, encoded-query, admin]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > "CMDB groups" (https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/cmdb-groups.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# CMDB Groups

**In one line:** a CMDB group (`cmdb_group`) is a named collection of CIs, filled by hand, by saved queries or by encoded queries, so that something can act on all of them at once: health monitoring, life cycle actions, an application service, a chart in CMDB Workspace.

**Where:** **All > Configuration > CMDB Groups**.

## Group types

| Type | Used for | Can be filled by |
|---|---|---|
| **Default** | general purpose | manual CIs, saved CMDB queries, encoded queries |
| **Health** | CMDB Health monitors the members and aggregates their health for the group (for example the CIs of one location) | **encoded queries only**; dynamic filters not supported even though the condition builder accepts them |
| **CMDB Workspace** | a custom class group: a bar in the CI Summary chart and, without the Service Graph Workspace - Content app, the navigation of Explore ([[CMDB Workspace]]) | encoded queries only |

Other uses: the **Dynamic CI Group** method of populating an application service takes its members from a CMDB group; CI Lifecycle Management APIs can fetch a group's CIs through the group's scriptable API and apply an action to all.

## Create and fill

Roles: view `sn_cmdb_editor` or `itil`; use in CMDB queries also `cmdb_query_builder`; add CIs by hand `asset` or `sn_cmdb_editor`.

1. **CMDB Groups** > **New** > unique **Group Name**, **Group type** > **Submit**.
2. Fill it with one or more of:
   - **CMDB Group Contains Saved Queries** > **Add Query** > pick a saved Query Builder query. CIs of every class in the query become members.
   - **CMDB Group Contains Configuration Items** > **Edit Manual CI** > filter, select CIs, **+**, **Save**.
   - **CMDB Group Contains Encoded Queries** > **New**: **Class**, **Condition**, and **CI Overview Condition** (used for the CMDB Workspace CI overview chart only when `sn_cmdb_ws.ci_overview.enable_simple_condition` is true; not used by Show All CI).
3. **Show All CI** lists the members (CMDB tables only), with **Operational Status** and the CI Lifecycle Management **Actions** that apply (from **CMDB CI Actions**, `statemgmt_cmdb_actions`). Query-based groups are evaluated live, so a slow query can time out here.

## Limits

- `glide.cmdb.group.max_ci_limit`: maximum CIs per group, **10,000** by default. At the limit nothing more can be added until the property is raised.

## Tables

| Name | Purpose |
|---|---|
| `cmdb_group` | the groups |
| `cmdb_group_contains_encoded_query` | encoded queries of a group (with column **Simple Condition** for the CI overview) |

## Related

- [[CMDB Workspace Reference - Properties, Roles, Jobs and Tables]] · [[CMDB Overview and Class Hierarchy]]
