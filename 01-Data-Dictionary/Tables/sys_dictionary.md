---
type: table
tags: [table, schema, platform]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration" (pp. 464-465, 467-469, 482-489), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# sys_dictionary

**Label:** Dictionary Entries (the System Dictionary)
**What it stores:** one row per table (**Type = Collection**) and one row per column of every table: data type, length, default value, dependency, reference, choice behaviour and attributes. Module: **System Definition > Dictionary**.

## Key columns

The guide documents the form by label, not by column name: see [[Dictionary Entry Form]] for every field. Names below are only those the guide states.

| Label | Name | Meaning | Confidence |
|---|---|---|---|
| Table | ? | table the entry belongs to | documented |
| Column name | ? | the field name (empty on the Collection row) | documented |
| Type | ? | field type, or Collection | documented |
| Class | `sys_class_name` (on the parent class entry) | which child class a record belongs to | documented |

## How many entries a table has

Depends on the extension model ([[Table Extension and Extension Models]]):

- Table per class and table per hierarchy: the parent has entries for the collection and every field; each child only has entries for fields it adds. Example: Task has 66, Incident only 22.
- Table per partition: every child class has its own full set (Hardware has 73, some duplicating the parent). Changes to a parent entry are replicated to the child entries.

## Gotchas

- Changes cascade to all extended tables unless a [[Dictionary Overrides|dictionary override]] exists.
- Editing entries of `sys_` tables can cause system-wide problems.
- A field created here is added at the end of the first section of the default form view.

## Related

- [[sys_db_object]] · [[sys_documentation]] · [[Dictionary Attributes Reference]]
