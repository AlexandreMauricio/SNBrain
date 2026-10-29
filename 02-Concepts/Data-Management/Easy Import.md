---
type: concept
tags: [concept, import-sets, data-management, forms-lists]
status: documented
source: ServiceNow docs, Brazil, Workflow Data Fabric > Imports > Easy import, topics "Easy import", "Download an import template", "Add a record in the template", "Update a record in the template", "Import a record from the template", "Show reference fields as lists in Excel templates", "Easy import template validation", "Easy import properties", https://www.servicenow.com/docs/r/integrate-applications/easy-import/c_EasyImport.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Easy import

**In one line:** from any list an admin downloads an Excel template (insert or update), fills it, and imports it back into the same table, without building a data source or transform map.

## Steps

1. On the list (filtered as needed): right-click a column header (List v2) or the list title menu (List v3) > **Import**.
2. Choose **Insert** (new records) or **Update** (one row per record in the current filter, with a `sys_id` column). Optional: clear **Include all fields in the template?** to keep only the list's columns. **Export template format** XLSX (XLS only when `glide.legacy.excel.export` is true). **Create Excel template**.
3. Fill or edit rows on the **first sheet only** (the template has a *Directions* tab). Paste with *Paste Special > Values* to keep the validation rules.
4. Back on the same list: **Import**, choose Insert or Update, pick the file, **Upload and Preview Import Data**, then **Complete Import** (or **Ignore Errors and Complete Import** to skip bad cells).

## Rules

- Admin only; tables in the current scope or granting write access to other scopes.
- **Created by** / **Updated by** always become the importing admin.
- Insert: a blank cell gives a blank value (fields that cannot be blank fail validation). Update: blank never overwrites a value; a value overwrites a blank.
- References: type the **display value** (e.g. user name), not a sys_id. Dictionary attribute `easy_import_ref_as_choice=true` turns a reference into an Excel drop-down (up to 250 options; per field `easy_import_ref_query_limit=<n>` wins over property `glide.easy_import.reference_query_limit`).
- Validation: in Excel (cells highlighted: choice values, integers, references from small static tables, true/false) and on the server (header with valid names, at least one row, `sys_id` column present only in update templates; errors pause the import).
- Properties: `glide.import_template.row_limit` (10,000), `glide.easy_import.run_business_rules` (true; false = like `setWorkflow(false)`), `glide.import_template.field_types_to_ignore` (journal, glide_list, image, workflow, conditions and others).

## When to use

Small, one-off loads by an admin into one table. For repeatable loads, scheduling, transformation or other sources, use an import set ([[Import Data with an Import Set]]).

## Related

- [[Import Sets - Data Sources, Staging Tables and Cleanup]] · [[Export and Import Records as XML]] · [[Dictionary Attributes Reference]]
