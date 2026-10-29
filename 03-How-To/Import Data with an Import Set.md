---
type: how-to
tags: [how-to, import-sets]
status: documented
source: ServiceNow docs, Brazil, Workflow Data Fabric > Imports > Import sets, topics "Importing data using import sets", "Create a File type data source", "Create a transform map", "Create a field map", "Run an import", "Review the import set", "Schedule a data import", https://www.servicenow.com/docs/r/integrate-applications/system-import-sets/c_ImportDataUsingImportSets.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Import data with an import set

**Goal:** load records from a spreadsheet or file into a table, updating existing ones instead of duplicating them.
**Prerequisites:** role import_admin (data source) and import_transformer (transform map), or admin; the file; knowing which target field identifies a record uniquely.
**Navigation:** All > System Import Sets > Administration > Data Sources

## Steps

1. **Data Sources > New**: **Name**, **Import set table label** (the table name is generated), **Type** *File*, **Format** (CSV, Excel, XML, JSON), **File retrieval method** *Attachment* (or SFTP / HTTPS with server and path). Submit and attach the file.
2. Related link **Test Load 20 Records**: creates the staging table and shows sample rows. Check the columns (do not add columns by hand).
3. Related list **Transforms > New** (or **System Import Sets > Create Transform Map**): **Name**, **Source table** = the staging table, **Target table**. Decide **Run business rules** (untick for a bulk historical load). Save.
4. **Auto map matching fields**, then **Mapping Assist** for the rest.
5. Open the field map of the unique field and tick **Coalesce** (e.g. email for users). For reference targets set **Referenced value field name** (e.g. `user_name`) and **Choice action** (*ignore* or *reject* to avoid creating unwanted records). Set **Date format** for date fields. Use **Index Coalesce Fields** if the coalesce field is not indexed.
6. Optional transform scripts (onBefore to skip rows, etc.): [[Transform Scripts and Script Variables]].
7. Back on the data source: **Load All Records**, then **Run Transform** (or **Transform** on the map).
8. Review the import set: **Import Set Runs** (inserts, updates, ignored, skipped, errors) and the import log.
9. Optional: schedule it (**Administration > Scheduled Imports > New**, data source, **Run as**, frequency): [[Scheduled and Concurrent Imports]].

## Result / how to check it worked

The target table shows the new and updated records; running the same file again gives updates or skips, not new duplicates.

## Example

| Part | Value |
|---|---|
| File | `example_users.csv` with columns name, email, department, manager_user_id |
| Data source | *Example User Load*, File, CSV, Attachment; staging table `u_example_user_load` |
| Transform map | *Example User Load to User*, target `sys_user`, Run business rules off for the first load |
| Field maps | email to `email` (**Coalesce**), department to `department` (choice action *reject*), manager_user_id to `manager` with **Referenced value field name** `user_name` |
| onBefore | skip rows without email: `if (source.u_email.toString() == '') ignore = true;` |

## Tables / fields involved

- `sys_data_source`, the staging table (extends `sys_import_set_row`), `sys_import_set`, `sys_transform_map`, target table such as [[sys_user]].

## Other ways to do this

[[Easy Import]] for a one-off admin load into one table; the Import Set API or web service import sets for system-to-system feeds ([[Web Service Import Sets and Direct File Posting]]); robust transformers for several target tables ([[Robust Import Set Transformers and ETL Definitions]]).

## Gotchas

- Imports run as System: no writes to encrypted fields.
- Staging rows are deleted after 7 days by **Import Set Deleter**.
- Several coalesce fields must **all** match; values compare case-insensitively by default.
- XLS files must use the 1900 date system; set your user time zone to the data's time zone.
- Troubleshooting: [[Import Set Performance and Errors]].
