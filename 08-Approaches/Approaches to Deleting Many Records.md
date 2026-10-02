---
type: approach
tags: [approach, data-management, admin]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration" (pp. 480-482) and "Data Management" (pp. 617-624, 639-642), read 2026-10-01. Comparison built from the guide's statements; none tested
sn-release: Australia
verified:
updated: 2026-10-01
---

# Deleting many records: ways to do it

**Problem:** remove a large number of records from a table safely.

## Options

### A. Delete job or one-time delete rule
- **How:** see [[Bulk Update or Delete Records with a Job]]
- **Pros:** conditions, preview, cascade preview, scheduling, **rollback** (one-time delete rules: up to fourteen days). Can run business rules and engines.
- **Cons:** deleting a whole table this way locks it.
- **Status:** documented
- **Best when:** a selected set of records, once.

### B. Table cleanup rule
- **How:** see [[Create a Table Cleanup Rule]]
- **Pros:** automatic and recurring; batches itself; the guide's choice for emptying or thinning large tables.
- **Cons:** no business rules, workflows or flows fire; no rollback mentioned; needs an indexed match field; 20 minutes per table per hourly run.
- **Status:** documented
- **Best when:** ongoing retention by age.

### C. Delete all records (table form)
- **How:** see [[Delete a Custom Table or All Records in a Table]]
- **Pros:** one click; runs delete business rules and cascade rules.
- **Cons:** everything goes, including records of child tables; not available for some system tables.
- **Status:** documented
- **Best when:** emptying a table on a sub-production instance, or before deleting a custom table.

### D. Select and delete from a list
- **How:** select all rows on a page, **Actions on selected rows > Delete**, repeat.
- **Pros:** no setup.
- **Cons:** page by page.
- **Status:** documented
- **Best when:** a few hundred records.

### E. Script
- **How:** GlideRecord delete in a background or fix script, with `setLimit()` to keep batches small and `setWorkflow(false)` to skip business rules.
- **Pros:** full control.
- **Cons:** no preview or rollback unless you build them; easy to get wrong.
- **Status:** documented (the two methods are mentioned, no full script given)
- **Best when:** logic the tools cannot express.

### F. Archive instead of delete
- **How:** see [[Create an Archive Rule]]
- **Best when:** the data must stay available for audit.

## Recommendation

Use **A** for a one-off selection because of preview and rollback, **B** for recurring retention, and **C** only where losing the whole table's data is intended. Reach for **E** last.
