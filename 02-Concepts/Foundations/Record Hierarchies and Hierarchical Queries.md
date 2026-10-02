---
type: concept
tags: [concept, platform, encoded-query, users, reference-field]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration", topic "Building hierarchical queries" (pp. 587-590), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Record hierarchies and hierarchical queries

**In one line:** a record hierarchy turns a self-referencing field (parent, manager) into a searchable tree, so one condition, **is in hierarchy**, finds a node and everything beneath it.

## How it works

- A record hierarchy is defined on one table and one reference field that points back to the same table. Definitions live in Record Hierarchies (`sys_record_hierarchy`); view them at **All > System Definition > Record hierarchy**.
- The platform generates a **hierarchical path** for every record and keeps it current as records are added, changed or removed.

| Shipped hierarchy | Table | Based on field | Path stored in |
|---|---|---|---|
| Department Hierarchy | Department (`cmn_department`) | Parent | Parent HP1 |
| Location Hierarchy | Location (`cmn_location`) | Parent | Parent HP1 |
| Manager Hierarchy | User (`sys_user`) | Manager | Manager HP1 |

- Other tables with self-referencing fields get no path until a hierarchy is defined for them.

## Using it in the condition builder

Pattern: `[field] [is in hierarchy] [hierarchy] starting at [record] which is [Included | Excluded]`.

- **Included** returns the starting record and everything below it; **Excluded** only what is below.
- **is in hierarchy (dynamic)** starts from a dynamic value such as **Me** or **My Location**.

| Want | Condition |
|---|---|
| assets of a department and its sub-departments | Department is in hierarchy Department Hierarchy starting at *Example Department*, Included |
| incidents from a region, its cities and addresses | Location is in hierarchy Location Hierarchy starting at *Example Region*, Included |
| the same but not the region record itself | ... Excluded |
| incidents assigned to a manager's whole organisation | Assigned to is in hierarchy Manager Hierarchy starting at *Example Manager*, Included |
| incidents assigned to me and my reports, at any depth | Assigned to is in hierarchy (dynamic) Manager Hierarchy starting at Me, Included |
| everyone under me | on `sys_user`: Manager is in hierarchy (dynamic) Manager Hierarchy starting at Me, Included |

It works on any table with a reference field pointing to the hierarchy's table.

## Building your own

1. Pick a table with parent-child records (e.g. Asset, `alm_asset`) and the self-referencing field (e.g. Parent), or create and populate one.
2. **All > System Definition > Record Hierarchy**, **New**: fill **Label**, **Name** (internal name), **Table** and **Reference Field** (the self-reference), then **Submit**. This creates the row in `sys_record_hierarchy`; paths are generated automatically. Role: admin.
3. Use the new hierarchy in the condition builder.

## Related

- [[Tables, Records and Table Relationships]]
