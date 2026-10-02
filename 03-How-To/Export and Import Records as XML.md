---
type: how-to
tags: [how-to, data-management, update-sets, reference-field]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Exporting data", topic "Exporting and importing data via XML" (pp. 661-664), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Export and import records as XML

**Goal:** copy records exactly from one instance to another, sys_ids included, without building an import set.
**Prerequisites:** role admin on both instances. The table must exist on the target.
**Navigation:** any list, column header context menu

## Steps

1. On the **source** instance, open the list (or record).
2. List: right-click a column header, **Export > XML**, then **Download**. Record: **Additional actions > Export > XML (This Record)**.
3. On the **target** instance, open **any** list (the file names its own destination table).
4. Right-click a column header, **Import XML**.
5. **Choose File**, pick the exported file, **Upload**.

## Result / how to check it worked

The records exist on the target with the same sys_id, created and updated values as on the source.

## Example

Export the rows of a custom lookup table `u_example_lookup` from the development instance and import them into test, alongside the update set that carries the table definition.

## Tables / fields involved

- the exported table
- reference fields to User (`sys_user`), Group (`sys_user_group`), Role (`sys_user_role`) and Group Roles (`sys_group_has_role`): see below

## Gotchas

- **Import XML does not run business rules** and does not update the instance cache. Data goes straight into the table with no chance to transform it.
- **Display value matching**: for the four tables above, if the target already has a record with the same display value, the import points the reference at the target's sys_id instead of the imported one. For other tables the sys_id is kept as is, so references break if the referenced record does not exist on the target.
- Image field data is not preserved.
- If nothing is imported, check under **System Definition > Tables & Columns** that the table exists on the target; move it with an update set if not.
- Meant for small, infrequent batches (lookup data, test records). To validate, transform or reconcile references, use an import set.

## Related

- [[Exporting Data]] · [[Sys ID]]
