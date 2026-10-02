---
type: how-to
tags: [how-to, fields, schema, forms-lists]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Field administration", topics "Add and customize a field in a table" and "Delete a field from a table" (pp. 801-805), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Add or delete a field

**Goal:** add a new column to a table from its form, or remove a custom column.
**Prerequisites:** role admin.
**Navigation:** any form of the table, header context menu, Configure > Form Layout

## Steps: add

1. Open a form of the table, right-click the header, **Configure > Form Layout**.
2. In **Create new field**, enter **Name** (the label), **Type** and, where shown, **Field length**.
3. Select **Add**.
4. Position the field in the slushbucket and **Save**.

## Steps: delete

1. On a form, right-click the field label, **Configure Dictionary**.
2. Select **Delete Column** in the header and confirm.

Several at once: **System Definition > Dictionary**, filter (e.g. column name starts with `u_`), tick the rows, **Delete** in the actions list. A dialog lists dependencies.

## Result / how to check it worked

The field is on the form (and a dictionary entry exists), or is gone from the table.

## Example

On Incident, add *Example Vendor Ticket* of type String, length 40. The column is created as `u_example_vendor_ticket`.

## Tables / fields involved

- [[sys_dictionary]]: the new entry
- [[sys_documentation]]: its label

## Gotchas

- Base system fields cannot be deleted; a missing one is recreated on upgrade.
- Deleting a field can delete related records. The guide recommends removing it from forms and lists instead.
- Watch the limits: 10 medium-or-longer String fields per table, 1,000 columns ([[Field Administration]]).
- A field added on a child table lives on that table; a field edited that belongs to the parent changes for all children.
