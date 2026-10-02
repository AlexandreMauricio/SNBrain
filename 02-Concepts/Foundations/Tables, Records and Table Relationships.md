---
type: concept
tags: [concept, platform, schema, reference-field]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration" (pp. 460-466, 472-473), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Tables, records and table relationships

**In one line:** everything on an instance is stored in tables; a record is a row, a field is a column, and tables relate to each other by extension, references, many-to-many tables and database views.

## How it works

- A **table** is a collection of records. Each record is a row and each field on it is a column. Records can be viewed as a list or a form.
- Base tables ship for the ITSM processes (Incident, Problem, CMDB and so on). Administrators can add **custom tables** ([[Custom Tables and Entitlements]]).
- Three "data dictionary" tables describe the schema itself:

| Label | Name | What it holds | Module |
|---|---|---|---|
| Tables | [[sys_db_object]] | one record per table | **System Definition > Tables** |
| Dictionary Entries (the System Dictionary) | [[sys_dictionary]] | one record per table (Type = Collection) and one per column: type, length, default, dependency, attributes | **System Definition > Dictionary** |
| Field Labels (the Language File) | [[sys_documentation]] | label and hint of every table and column | **System Definition > Language File** |

- From a table record you can edit columns, set the auto-number format, make the table extensible, create modules, open the schema map (**Show Schema Map**), open the dictionary (**Show Dictionary Record** in the header context menu), jump to the list or form, or delete all records.
- Changing the system dictionary is high impact: changes apply to all extended tables unless a [[Dictionary Overrides|dictionary override]] exists, are hard to reverse, and changes to `sys_` tables can break things such as update sets. Prefer the Tables module or form configuration over editing the dictionary directly.

## The four kinds of relationship

| Kind | What it is | Example |
|---|---|---|
| **Extension** | a child class has all the fields of its parent class plus its own | Incident (`incident`) extends Task (`task`). See [[Table Extension and Extension Models]] |
| **One-to-many: reference field** | a field holds one record of another table | **Caller** on Incident points to User (`sys_user`) |
| **One-to-many: glide list** | a field holds several records of another table | **Watch list** (`watch_list`) on Incident points to users |
| **One-to-many: document ID** | a field can point to a record on any table (rare) | **Document** on Translated Text (`sys_translated_text`) |
| **Many-to-many** | a link table makes related records visible from both sides in a related list | [[Create a Many-to-Many Relationship]] |
| **Database view** | two tables joined virtually, for reporting | [[Database Views]] |

## Viewing relationships

- **Schema map**: [[Generate a Schema Map]].
- System dictionary filtered by table, and the Tables module.

## Related

- [[Table Extension and Extension Models]] · [[Dictionary Entry Form]] · [[Dictionary Attributes Reference]] · [[System Fields on Every Table]] · [[task]]
