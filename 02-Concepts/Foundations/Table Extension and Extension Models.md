---
type: concept
tags: [concept, platform, schema, task, cmdb]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration" (pp. 466-472, 514-517), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Table extension and extension models

**In one line:** a child table (child class) inherits every field of its parent class; how the hierarchy is physically stored depends on the extension model (table per class, per hierarchy, or per partition).

## Extension basics

- A table that extends another is a **child class**; the extended table is the **parent class**. A parent that extends nothing is a **base class**. A table can be both parent and child.
- A table can only be extended **when it is created**, and only if the parent is marked **Extensible**.
- Extending links the new table to the parent, creates the system fields on it ([[System Fields on Every Table]]), and creates one or more database tables depending on the model.
- Base examples: Task (`task`) is extended by Incident (`incident`), Problem (`problem`) and Change Request (`change_request`); Configuration Item (`cmdb_ci`) by Application (`cmdb_ci_appl`), Computer (`cmdb_ci_computer`), Database (`cmdb_ci_database`).
- The **Class** field (`sys_class_name`) on a record says which child class it belongs to.

## The three extension models

| | Table per class | Table per hierarchy | Table per partition |
|---|---|---|---|
| Flattened? | no | yes | yes |
| Physical tables | one per class | one, named after the parent | one logical table plus storage tables (partitions) added as limits are reached, e.g. `cmdb$par1` |
| Child fields | derived from the parent | derived from the parent | each child class has its own full list of dictionary entries |
| Record replication | the parent replicates every child record (same sys_id in both) | none needed, the parent table holds all records | none needed |
| Class columns | | `sys_class_name` | `sys_class_name` and `sys_class_path` |
| Used for | the default for new tables and most system tables (e.g. Asset `alm_asset` and its children) | the **Task** hierarchy on MySQL | the **Base Configuration Item** (`cmdb`) hierarchy on MySQL |

- Table per class queries must join tables, so queries from the top of a hierarchy are slowest. Flattened models avoid joins by filtering on the class name (or class path).
- On Oracle, table per hierarchy and table per partition need Technical Support.
- The model does not change how tables look or behave in the instance, including database views. Administrators can see the model but cannot flatten more hierarchies.

## Checking a table's model

**All > System Definition > Tables**, open the table, read **Extension model** (configure the form to add the field if it is missing).

- **None** means table per class, *unless* the table extends something: a child inherits its parent's model. Incident shows a blank value but physically lives on Task.
- **Table per hierarchy**: one physical table for the whole hierarchy.
- A new table extending Task directly uses table per class once Task exceeds 1 million rows.

## Storage aliases (how flattened columns are stored)

Every field has a row in Storage Column Aliases ([[sys_storage_alias]]) mapping the logical field to a physical column.

- **Element Name**: the field as users and scripts see it. **Storage Alias**: the real physical column. **Storage Table Name**: the physical table (always `task` for table per hierarchy). **Table**: the logical class (the class discriminator).
- **Glomming**: sibling classes can share one physical column. Example from the guide: `cab_delegate` on Change Request is stored in `a_ref_2` on `task`, and ten fields in different classes share that alias.
- Rules: two fields of the same class cannot share a column; a parent field and a child field cannot share one; only siblings can; fields created directly on `task` are never glommed.
- Administrators can read the alias table but cannot change it from the UI.

## Related

- [[Tables, Records and Table Relationships]] · [[task]] · [[Dictionary Overrides]] · [[sys_db_object]]
