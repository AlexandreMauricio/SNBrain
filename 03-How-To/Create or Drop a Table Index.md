---
type: how-to
tags: [how-to, platform, schema, admin]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration", topics "Create a table index" and "Drop a custom index" (pp. 473, 519-521), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Create or drop a table index

**Goal:** speed up queries on specific columns with a database index, or remove a custom index.
**Prerequisites:** role admin. Index design needs database knowledge; the guide advises consulting a DBA.
**Navigation:** All > System Definition > Tables (Database Indexes related list), or Tables & Columns (Index creator)

## Steps: create

1. Open the table under **All > System Definition > Tables** and go to the **Database Indexes** related list, then **New**. (Or **Tables & Columns**, select the table, **Index creator**.)
2. Select the fields for the index. **The order of the fields matters.**
3. Tick **Unique Index** if values must be unique.
4. Choose the index type: **btree** (default) or **Columnstore** (compressed column-oriented storage for large datasets; RaptorDB Professional only).
5. Select **Create Index**.

## Steps: drop

1. Open the table record, **Database Indexes** related list.
2. Open the custom index and select **Drop**.

## Result / how to check it worked

The index is listed (or no longer listed) in the table's Database Indexes related list.

## Example

On `u_example_laptops`, create a btree index on *Asset tag* then *Assigned to*, in that order, during off-peak hours.

## Tables / fields involved

- [[sys_db_object]]: Database Indexes related list

## Gotchas

- Indexing a large table (around 1 TB) can hit performance: do it off-peak, and not while heavy jobs such as Discovery run on that table.
- The **Table Name** field on the creator is informational; changing it has no effect.
