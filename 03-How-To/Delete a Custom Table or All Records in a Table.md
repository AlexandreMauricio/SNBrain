---
type: how-to
tags: [how-to, platform, schema, admin]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration", topics "Deleting custom tables", "Delete a custom table", "Delete all records from a table" (pp. 479-482), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Delete a custom table or all records in a table

**Goal:** remove a custom table that is no longer needed, or empty a table while keeping it.
**Prerequisites:** role admin. For a table in a scoped application, select that application in the scope picker (or configure cross-scope access).
**Navigation:** All > System Definition > Tables (or Tables & Columns)

## Steps: delete all records

1. Open the table from **System Definition > Tables & Columns** (or its record under **Tables**).
2. Select **Delete all records**.
3. Type `delete` in the confirmation box and select **OK**.

Alternative from a list: show the maximum rows per page, select all rows, **Actions on selected rows > Delete**, and repeat per page.

## Steps: delete a custom table

1. Open the table under **All > System Definition > Tables**.
2. Select **Delete All Records** first, so delete business rules and reference cascade rules run properly.
3. Select **Delete** (only shown for tables starting with `u_` or `x_`).
4. Type `delete` and select **OK**.

## Result / how to check it worked

- Delete all records: the table is empty but still exists, and references to it (business rules, reference fields) are kept.
- Delete table: the table and everything that references it are gone: choice list items, forms, sections, lists and related lists, reports and Performance Analytics widgets, reference fields pointing to it, access controls.

## Example

On a sub-production instance, empty `u_example_laptops` with **Delete all records**, confirm the list is empty, then select **Delete** to remove the table itself.

## Tables / fields involved

- [[sys_db_object]]: the table record being deleted

## Gotchas

- **Deleting all records also deletes the records of tables that extend it.**
- Base system tables cannot be deleted; if one is, an upgrade recreates it.
- A table with child tables cannot be deleted.
- Some system tables cannot be emptied this way (e.g. User, `sys_user`) and are not listed.
- For large deletes by script, limit the batch with `setLimit()` to avoid locking the table, and consider `setWorkflow(false)` so business rules do not fire for every row.
