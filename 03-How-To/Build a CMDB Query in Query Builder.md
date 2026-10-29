---
type: how-to
tags: [how-to, cmdb, reporting]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB Query Builder > Build a CMDB query, Build a Service Mapping query, Configure the relationships to query on, and the five example queries (read in full through the docs site API 2026-10-29). https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/use-cmdb-query-builder.html
sn-release: Brazil
verified:
updated: 2026-10-29
---

# Build a CMDB Query in Query Builder

**Goal:** find CIs by how they are connected (for example servers related to databases, or application services with open incidents) and save the query for reports, schedules or CMDB groups.
**Prerequisites:** role `cmdb_query_builder` (`cmdb_query_builder_read` can only view and run saved queries).
**Navigation:** All > Configuration > CMDB Query Builder

Background: [[CMDB Query Builder]].

## Steps

1. **Create new**: enter a **Name**, choose **CMDB Query** (or **Service Mapping Query**), **Create**. To start from an existing one, use the *Duplicate Query* icon on its card.
2. From **CMDB Classes**, drag the first class onto the canvas: it becomes the starting node. Drag the other classes; add tables such as Incident from **Non-CMDB Tables**.
3. Connect two nodes: click the small square on the right of the first, then the one on the left of the second.
4. In **Connection Properties** (click the line if needed):
   - **Relationship Direction**: choose the **Parent** node.
   - **Relationship Levels**: *First level relationships* or *Up to 2nd level relationships*.
   - **Relationship Types and Related Items**: *Add Relationship Types* (specific or all), *Add a Related Item* (a reference field), or *No Relationships*.
   - For a non-CMDB table: **Use CI reference column** (e.g. *Configuration item*).
   - Service Mapping queries: *Find Related CIs* or *Find Unrelated CIs*.
5. Filters: point at a node > *Apply filters*, add attribute or related list conditions. **Applied Filters** shows them all.
6. AND/OR: connect one node to two others and click the **And** box to switch to **Or**.
7. Result columns: **Properties** > select the node > **Add Columns**.
8. Optional: tags (*Add Tags*), then **Save**.
9. **Run**. Use **Load All Results** for more than 100 rows.

## Result / how to check it worked

The results pane lists one row per match with each node's name and the relationship type; the query appears as a card under **Saved Queries**, and *Query Information* shows its type, groups and schedules.

## Example

Query *Example servers with a database*: drag **Server**, then **Database** to its right, connect them, *Add Relationship Types* > all. **Save**, **Run**: each row shows a server, a database and the relationship. Select the *Server 1* node, **Add Columns** > *Manufacturer*, **Run**, **Save**.

Variant with a non-CMDB table: **Application Service** plus **Incidents** and **Change Requests**, each connected with *Use CI reference column* = *Configuration item* and *Apply ... reference filter to all nodes in the pattern*, the operator switched to **Or**: application services that have an incident or a change on themselves or on any CI inside them.

## Tables / fields involved

- Saved Queries (`qb_saved_query`: Query Execution Mode, Execution Batch Size), Query Status (`qb_query_status`), CI Relationship (`cmdb_rel_ci`)

## Gotchas

- Only the starting node may hang off an AND/OR operator; otherwise the query fails and asks for another starting node.
- New relationship types can take up to 30 minutes to appear in the list.
- *Up to 2nd level* hides the relationship type in the results.
- Export only writes the rows currently loaded.
