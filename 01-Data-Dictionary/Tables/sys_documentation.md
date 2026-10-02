---
type: table
tags: [table, schema, platform, glossary]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration" (pp. 465, 478-479), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# sys_documentation

**Label:** Field Labels (the Language File)
**What it stores:** the label and hint of every table and column, per language. Module: **System Definition > Language File**.

## Key columns

| Label | Name | Meaning | Confidence |
|---|---|---|---|
| Table | ? | table the label is for | documented |
| Element | ? | the column. **Empty = the label of the table itself** | documented |
| Label | ? | text shown on forms and list headers | documented |

## How it is maintained

- Updating **Label** on a table record or **Column label** on a dictionary entry also updates this table for the current language.
- To relabel directly: filter this table by the table name, open the row and edit it. Filter **Element is empty** to find the table's own label.
- Right-click a field label on a form to reach its label record.

## Related

- [[sys_dictionary]] · [[sys_db_object]] · [[Tables, Records and Table Relationships]]
