---
type: reference
tags: [reference, schema, platform]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration", topic "Global default fields" (p. 479), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# System fields on every table

The platform adds these fields to every table when it is created. They cannot be deleted or modified.

| Label | Name | Type | Meaning |
|---|---|---|---|
| Sys ID | `sys_id` | Sys ID (GUID) | unique identifier of the record |
| Created | `sys_created_on` | Date/Time | when the record was created |
| Created by | `sys_created_by` | String | user who created it (a string, not a reference) |
| Updated | `sys_updated_on` | Date/Time | date and time of the latest update |
| Updated by | `sys_updated_by` | String | user who last updated it (a string, not a reference) |
| Updates | `sys_mod_count` | Integer | number of updates since creation |
| Class | `sys_class_name` | System Class Name | on extensible tables, which child table the record belongs to |

## Notes

- Tables with the `no_update` attribute do not get `sys_mod_count`, `sys_updated_by` and `sys_updated_on` ([[Dictionary Attributes Reference]]).
- A table that extends another also shows the parent's fields in its column list; editing those affects every child of the parent.

## Related

- [[Tables, Records and Table Relationships]] · [[Create a Table]]
