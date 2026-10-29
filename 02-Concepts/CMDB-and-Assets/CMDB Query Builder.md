---
type: concept
tags: [concept, cmdb, reporting, admin]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB Query Builder (29 topics, 1,229 cleaned lines, read in full through the docs site API 2026-10-29) - landing, Explore, Execution modes, Configure (settings, relationships, batch size, execution mode), Navigate, Build CMDB query, Build Service Mapping query, partial query, delete, basic and dynamic reports, search, schedule, export and import (XML and update set), Reference (domain separation, properties, five example queries). https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/querying-cmdb.html
sn-release: Brazil
verified:
updated: 2026-10-29
---

# CMDB Query Builder

**In one line:** a drag-and-drop canvas (**All > Configuration > CMDB Query Builder**) for queries that span several CI classes, their relationships and references, and non-CMDB tables such as Incident or Asset; saved queries feed reports, scheduled emails and [[CMDB Groups]].

From the Brazil docs. Steps: [[Build a CMDB Query in Query Builder]]. Natural-language front end: [[Intelligent Search for CMDB]] (search box above the canvas; off with `glide.cmdb.query.nlq.activated` = false).

## Query types

| Type | Matches | Line on the canvas |
|---|---|---|
| **CMDB Query** | CI classes joined by direct relationships (first level, or up to second level), references, or "no relationship"; optional non-CMDB tables that reference `cmdb_ci` | solid |
| **Service Mapping Query** | a *pattern* of classes; returns the Service Mapping services containing it. Relationships also match indirectly through classes not on the canvas. **Services Including This Pattern** off = services *without* it | dashed |
| **Combination** | a saved Service Mapping query dragged into a CMDB query (*Saved Service Queries*): CMDB results limited to CIs in those services, or *Does Not Belong To Service* for the opposite | |

- The **starting node** is the first class dropped on the canvas and cannot be changed. In a complex query only the starting node may be attached to an AND/OR operator. A non-CMDB table cannot be the starting node.
- An **Application Service** node with **Convert attached nodes to pattern** matches CIs any number of levels inside the service (dashed line); without it, only direct relationships.
- Connection notation: red asterisk = something missing (e.g. relationship type); *Levels:n Types:n* or a reference name on the line.
- Relationship results show only parent, child and type: no other `cmdb_rel_ci` columns. With *Up to 2nd level* the type is not shown.

## Results

- 100 rows at first; **Load More Results** (V1 engine only) and **Load All Results** up to `glide.cmdb.query.max_results_limit` (10,000). Export takes only the rows loaded.
- `glide.security.use_csrf_token` must be true for all results to appear.
- Wait for a running query to finish or time out before running another.
- **Settings** icon (`sn_cmdb_admin`): *Display Relationships in Results*, *Display Suggested Connections* (side lists filtered to what can connect to the selected node), *Display Results in New Tab*.
- **Partial query**: switch the navigation selection tool to section mode, draw a box round some nodes, **Run**, pick a starting node.

## Engine modes V1 and V2

V2 (default) is faster and handles larger results. Some structures always fall back to V1:
- filters with related list conditions;
- a node with *No relationships* whose target node filters on configuration item conditions (e.g. server NOT connected to a router WHERE router is active);
- Service Mapping queries with related edges or *Find Related / Unrelated CIs*, and combination queries with *Does Not Belong to Service*.

Queries with **OR** produce differently shaped results: V2 merges related rows into one result, V1 keeps separate rows. Keep V1 if existing reports rely on the old shape.

Decision order: the query's **Query Execution Mode** in Saved Queries (`qb_saved_query`) (V1, V2 or None) > `glide.cmdb.query.or_execution_mode` (for queries with OR) > `glide.cmdb.query.execution_mode` (empty = V2) > the V2 support check. The mode actually used is shown in Query Status (`qb_query_status`).

## Batch size

Each run is processed in batches of 100. Override globally with `glide.cmdb.query.batch_size` (add it to `sys_properties`), or per query with **Execution Batch Size** in `qb_saved_query` (highest priority). Applies to UI runs, the scriptable API, scheduled jobs and CMDB groups. The docs suggest asking Support to size it. **Unconfirmed variant:** the same page also writes the property as `glide.cmdb.query.batch.size`; which name the instance reads is not tested.

## Properties

| Property | Default | Meaning |
|---|---|---|
| `glide.cmdb.query.max_results_limit` | 10000 | rows for Load All and for scheduled results |
| `glide.cmdb.query.batch_time_limit_in_sec` | 300 | time limit per batch |
| `glide.cmdb.query.query_time_limit_in_sec` | 1800 | time limit for the whole query |
| `glide.cmdb.query.non_cmdb.black_listed_tables` | empty | non-CMDB tables to hide; comma-separated names, `*abc` hides every table containing *abc* |
| `glide.cmdb.query.batch_size` | 100 (add the property) | global batch size |
| `glide.cmdb.query.execution_mode` | V2 | default engine |
| `glide.cmdb.query.or_execution_mode` | V2 | engine for queries with OR; wins over the previous |
| `glide.cmdb.query.nlq.activated` | true | Intelligent Search in the builder |

The first four are under **Configuration > CMDB Properties > Query Builder Properties**. Roles `sn_cmdb_admin` or `admin`.

## Reports, schedules, moving queries

- **Basic report**: from a column menu in the results, Bar Chart or Pie Chart; static, limited to the rows loaded. Needs Core UI (`com.glide.ui.ui16`) and `report_user`.
- **Dynamic report**: **Create Report** is enabled only for a saved query **with a schedule** whose full result set is loaded. Creates a *report source* (name = query name, cannot be renamed) refreshed at every run; usable in Platform Analytics dashboards. Changing the query definition breaks the link: create a new report. Find it via *Query Information* or **Reports > Administration > Report Sources**.
- **Schedule** (*Create Schedule*): Users, Groups, Email addresses, Zip output, Active, Run, Time, Conditional with a Condition script, Omit if no records, Subject, Introductory message, Type (file format; add to the form layout). Rows attached up to the max results limit. Recipients need an email address and notifications enabled.
- **Export / import**: *Export query* icon > Download gives XML; *Import query* on another instance. A combination query carries its Service Mapping query along. Alternative: `qb_saved_query` list > *Export query* as an update set, then import as a retrieved update set ([[Update Sets]]). The domain of the query must exist in both instances.
- Tags on a query help **Search Saved Queries** (by name, type, tags, creator, updater). The query URL can be shared. Delete from the card view (X).

## Roles

`cmdb_query_builder_read`: view and run saved queries. `cmdb_query_builder`: create, change, run, schedule, export; may change or delete other users' queries. `sn_cmdb_user` for *Open in Workspace* from a result CI.

## Domain separation

Supported and on by default. Saved queries (`qb_saved_query`) are domain separated. Results behave like list views: relationships (`cmdb_rel_ci`, not domain separated) show regardless of domain, CIs only when visible in the current domain.

## Related

- [[Build a CMDB Query in Query Builder]] · [[CMDB Groups]] · [[Intelligent Search for CMDB]] · [[CI Relationships]] · [[CMDB Workspace]]
