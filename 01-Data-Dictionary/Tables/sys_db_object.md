---
type: table
tags: [table, schema, platform]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration" (pp. 464, 473-478, 516-517), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# sys_db_object

**Label:** Tables
**What it stores:** one record per table in the database. Module: **System Definition > Tables** (also **Tables & Columns**).
**Extends:** not stated in the guide

## Key columns

Column names are not given in the guide; these are the form labels.

| Label | Name | Meaning | Confidence |
|---|---|---|---|
| Label | ? | table label shown on lists and forms (stored in [[sys_documentation]]) | documented |
| Name | ? | table name; `u_` prefix in global, scope namespace in an application, `st_` added for remote tables | documented |
| Extends table | ? | parent table | documented |
| Application | ? | owning application scope (read-only) | documented |
| Remote table | ? | data comes from a script against an external source; cannot extend another table | documented |
| Extensible | ? | other tables may extend this one | documented |
| Extension model | ? | blank (inherit, or table per class) or Table per hierarchy; may need adding to the form | documented |
| Auto-number | ? | adds a numbered field with a number format | documented |
| Live feed | ? | record feeds on the form | documented |
| Accessible from, Can read / create / update / delete, Allow access to this table via web services, Allow configuration | ? | cross-scope application access settings | documented |

## Relations

- Related lists: **Table Columns** (the table's [[sys_dictionary]] entries), **Database Indexes**.
- Related links: **Show Schema Map**, **Show List**, **Show Form**, **Delete All Records**.

## Related

- [[Create a Table]] · [[Table Extension and Extension Models]] · [[Tables, Records and Table Relationships]]
