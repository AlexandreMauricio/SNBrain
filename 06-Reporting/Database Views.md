---
type: concept
tags: [concept, reporting, schema, access-control]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration", topic "Working with database views for reporting" (pp. 573-574, 580, 584-587), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Database views

**In one line:** a database view joins two or more tables into a read-only pseudo-table, mainly so one report can use fields from all of them.

## How it works

- Defined under **All > System Definition > Database Views** (table `sys_db_view`). Each joined table is a **View Table** row with a **Variable prefix**, an **Order** and a **Where clause**. See [[Create a Database View]].
- Anyone who can create a report can use a view as the source; views are listed with the tables.
- Output is **read-only**: data cannot be edited through a view.
- A view is **not a custom table**: no licensing impact.

## Access control

1. If ACLs exist on the view itself, they are evaluated and win.
2. If none exist, ACLs of the underlying tables apply (including the parent tables of those tables).

- Field-level ACLs are evaluated if they exist; none need creating on the view.
- Property `glide.security.expander.view.legacy`: `false` by default (behaviour above). When `true`, read ACLs must exist on the view and the underlying table ACLs are ignored. On upgraded instances the property has to be added.

## Limits

- Not possible on tables that take part in table rotation.
- Not included in FTP exports. Cannot be a data preserver in clone requests.
- Performance worsens with more tables and more rows; base the where clauses on **indexed fields**.
- In a script, a GlideRecord query on a view returns at most `glide.db.max_view_records` rows (default 10000; add the property to change it). Lists and reports use all rows.
- Avoid MySQL reserved words in names.
- A Table Name field on a table extending `sys_metadata` can only point to a view in the same scope.

## Views shipped with the base system

From the plugins Database Views and Database Views for Service Management. Three families, each named after the task table:

| Pattern | Joins | Tables covered |
|---|---|---|
| `<table>_metric` | the table to metric definition and metric instance | change_request, change_task, incident, problem, pm_project, pm_project_task, release_feature, release_project, release_task, sc_request, sc_req_item, sc_task |
| `<table>_sla` | the table to `task_sla` | change_request, change_task, incident, problem, pm_project, pm_project_task, release_task, sc_request, sc_req_item, sc_task |
| `<table>_time_worked` | the table to task time worked | change_task, incident, pm_project_task |

Examples: `incident_metric` (label Incident Metric), `incident_sla` (Incident SLA), `sc_req_item_sla` (Catalog Request Item SLA). These cover most metric reporting, so check them before building a new view.

## Related

- [[Create a Database View]] · [[Function Fields]] · [[Tables, Records and Table Relationships]]
