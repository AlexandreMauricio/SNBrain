---
type: how-to
tags: [how-to, platform, schema, forms-lists]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration", topic "Create a many-to-many table relationship" (pp. 473, 521-522), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Create a many-to-many relationship

**Goal:** link two tables so each record of one can relate to many of the other, and the related records show as a related list on both sides.
**Prerequisites:** role admin.
**Navigation:** type `sys_m2m.list` in the navigation filter (Many to Many Definitions, `sys_m2m`)

## Steps

1. Enter `sys_m2m.list` in the navigation filter.
2. Select **New**.
3. Set **From table** (the parent side) and **To table** (the child side). The form fills the other fields with suggested values.
4. Adjust the suggested values if needed and submit.

## Result / how to check it worked

A new link table exists, and each of the two tables can show the other as a related list (add it with **Configure > Related Lists**).

## Example

From table *Example Laptops*, To table *Example Software Titles*: one laptop lists many titles and one title lists many laptops.

## Tables / fields involved

- `sys_m2m` (Many to Many Definitions): the definition
- `sys_collection`: view the many-to-many relationships that ship with the base system (`sys_collection.list`). **View only**; always create through `sys_m2m`

## Gotchas

- Many-to-many table names cannot exceed 30 characters.
- These tables do not count as custom tables ([[Custom Tables and Entitlements]]).

## Related

- [[Tables, Records and Table Relationships]]
