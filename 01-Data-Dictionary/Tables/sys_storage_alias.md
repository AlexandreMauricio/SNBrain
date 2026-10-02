---
type: table
tags: [table, schema, platform, task]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration", topic "Storage aliases" (pp. 469-472), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# sys_storage_alias

**Label:** Storage Column Aliases
**What it stores:** for every field on the instance, which physical database column actually holds its data. It is what makes flattened hierarchies such as Task work.

## Key columns

| Label | Name | Meaning | Confidence |
|---|---|---|---|
| Element Name | ? | the field as users and scripts see it | documented |
| Storage Alias | ? | the physical column, e.g. `a_ref_2` | documented |
| Storage Table Name | ? | the physical table: always `task` for table-per-hierarchy classes, the table's own name for table per class | documented |
| Table | ? | the logical class the element belongs to (holds the class discriminator) | documented |

## Example from the guide

`cab_delegate` on Change Request is stored in `a_ref_2` on `task`. At database level that is:

```sql
SELECT a_ref_2 FROM task WHERE sys_class_name='change_request' AND a_ref_2 IS NOT NULL
```

This is the physical SQL the platform runs, not something you run from the instance.

## Gotchas

- Readable by administrators, but **not editable from the UI**.
- The alias column can be larger than the logical field's max length.
- Alias naming depends on the field type (`a_ref_` holds reference values in the example).

## Related

- [[Table Extension and Extension Models]] · [[task]]
