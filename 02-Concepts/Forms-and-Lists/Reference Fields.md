---
type: concept
tags: [concept, reference-field, fields, forms-lists]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Field administration", topic "Reference field type" (pp. 972-994), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Reference fields

**In one line:** a reference field stores the **sys_id** of one record of another table and shows that record's **display value**; it also lets forms and scripts dot-walk into the referenced record.

## Display value

The database holds the sys_id (e.g. `task.assigned_to` = a user's sys_id); the UI shows the display value (the user's **Name**) in lists, forms, reports, auto-complete and slushbuckets.

Which field is the display value, in order:

1. A field with **Display** = true on the lowest child table.
2. A field with Display = true on the parent table.
3. A field named `name`, `u_name` or `x_name`.
4. A field named `number`, `u_number` or `x_number`.
5. The field named in the property `glide.record.display_value_default`.
6. **Created on** of the referenced record.

- Only one display field per table: setting Display on one clears it on the others. Child tables inherit the parent's unless they set their own.
- Choose a field that is required and unique. Translate its values, or untranslated options are missing from type-ahead.

## Options on the dictionary entry

| Option | Notes |
|---|---|
| **Reference qualifier** | restricts which records can be chosen: [[Reference Qualifiers]] |
| **Reference cascade rule** | what happens to referencing records when the referenced one is deleted: **Clear** / None-selected (default, empties the field), **Delete** / Cascade (deletes the referencing records: use with caution), **Restrict** (blocks the delete), **None** (leaves them untouched). The guide's list also shows *Delete no workflow*. No effect for many-to-many relationships |
| **Reference key** | store another field's value instead of the sys_id (e.g. `email` for a reference to `sys_user`). Pick a required, unique field. A choice-style reference with a reference key does not work |
| **Dynamic creation** + script | typing a value with no match creates the record: `current.name = value; current.insert();`. `parent` gives access to the record being edited |
| **Choice** | show the reference as a dropdown: set Choice to a dropdown option and add `ref_auto_completer=AJAXReferenceChoice`. Falls back to a lookup above `glide.ui.max_ref_dropdown` records (default 25; per field: attribute `max_ref_dropdown`) |

## Decorations (icons beside the field)

| Icon | Shows when | Notes |
|---|---|---|
| Reference lookup (magnifier) | field is editable | opens the list of the referenced table. Attribute `tree_picker` shows a tree for hierarchical tables |
| Reference icon (i) | field has a value | read-only preview with **Open Record**. The preview uses the table's `sys_popup` view (configure at `<table>.do?sysparm_view=sys_popup`), else the default view; top section only |
| Related incidents | attribute `ref_contributions=user_show_incidents` | |
| Show workflow | attribute `ref_contributions=show_workflow` | |

When a client script, UI policy or ACL makes the field read-only, pop-ups and click-through are hidden unless `glide.ui.reference.readonly.clickthrough` is true (per field: attribute `readonly_clickthrough=true`).

## Auto-complete

- Works only if the user can read the referenced table.
- Attributes `ref_auto_completer`, `ref_ac_columns`, `ref_ac_columns_search`, `ref_ac_order_by`, `ref_ac_display_value` ([[Dictionary Attributes Reference]]). Set them on the **table's Collection entry** to affect every reference to that table; a field-level attribute of the same name wins.
  - Example on `sys_user`: `ref_auto_completer=AJAXTableCompleter,ref_ac_columns=department,ref_ac_order_by=department`
- **Starts with** is the default search. `glide.ui.ref_ac.startswith` = true forces it for everyone. With it false, the user preference `<referenced table>.autocomplete.contains` = true gives a contains search.
- `*text` in the field is a wildcard search; `**` lists available records.
- **Recent selections**: up to 15 per user per field, in `sys_ui_recent_selection`. `glide.xmlhttp.max_choices` controls how many show (0 disables). Not for catalog variables, Service Portal or mobile.

## Adding one

Add a field of type Reference and name the table ([[Add or Delete a Field]]). To show a field *of* the referenced record on the form, dot-walk in the form layout: it appears as `Caller.Email`.

A reference points to one table only; for any table use a Document ID field ([[Field Types Reference]]).

## Related

- [[Reference Qualifiers]] · [[Tables, Records and Table Relationships]] · [[Dictionary Entry Form]]
