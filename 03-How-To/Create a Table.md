---
type: how-to
tags: [how-to, platform, schema, admin]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration", topic "Create a table" (pp. 473-479), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Create a table

**Goal:** add a custom table, with its columns, module, numbering and access settings.
**Prerequisites:** role admin. Check your custom table entitlements first ([[Custom Tables and Entitlements]]).
**Navigation:** All > System Definition > Tables

## Steps

1. Open **All > System Definition > Tables** and select **New**.
2. Fill the header:
   - **Label**: unique label shown on lists and forms.
   - **Name**: generated from the label with a fixed prefix (`u_` in global, the scope namespace in an application). The rest is editable; lowercase letters, digits and underscores only.
   - **Extends table**: the parent, if any. It must be extensible. **Extension can only be set now, not later.**
   - **Remote table**: only for tables fed by a script from an external source (disables Extends).
   - **Create module** and **Add module to menu**: adds a list module to an existing or new application menu. Only available at creation.
3. In **Columns**, add rows: **Column label**, **Type** (mandatory), **Reference** (for reference fields), **Max length** (strings: under 255 is single-line, 255 or more multi-line), **Default value**, **Display** (the field shown where this table is referenced).
4. In **Controls**: **Extensible**, **Live feed**, **Auto-number** (with the number format), **Create access controls** and **User role** (creates basic security rules for a new or existing role).
5. In **Application Access**: **Accessible from** (all scopes or this scope only), **Can read / create / update / delete** for scripts in other scopes (read must be on for the others), **Allow access to this table via web services**, **Allow configuration** (other scopes may build business rules, client scripts and UI actions on it).
6. **Submit**.

## Result / how to check it worked

The table appears in the Tables list, with the system fields added automatically ([[System Fields on Every Table]]) and, if chosen, a module in the navigator.

## Example

A table labelled *Example Laptops* in the global scope gets the name `u_example_laptops`. Add a string column *Asset tag* (name `u_asset_tag`), tick **Display** on it, tick **Auto-number** with a prefix, tick **Create access controls** with a new role, and tick **Create module** under a new menu *Example Hardware*.

## Tables / fields involved

- [[sys_db_object]]: the table record
- [[sys_dictionary]]: one Collection entry plus one per column
- [[sys_documentation]]: the labels

## Gotchas

- Typing a table name that does not exist in a column's **Reference** creates that table on save.
- Only change a column's type between types of the same basic kind (e.g. Choice and String), or data can be lost.
- Do not extend Choice (`sys_choice`).
- To change labels later, edit the rows in Field Labels (`sys_documentation`).
- The guide recommends building tables with the application-building tools rather than one by one.
