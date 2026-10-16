---
type: concept
tags: [concept, service-catalog]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog > Reference, topics "Service catalog variable sets", "Create a variable set and add it to an item", "Variable set layout", https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/c_ServiceCatalogVariableSets.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Variable sets and multi-row variable sets

**In one line:** a variable set is a reusable group of variables (with its own catalog client scripts, UI policies and data lookups) attached to many items or order guides; a multi-row variable set (MRVS) asks the same questions as rows of a grid.

## Basics

- **Catalog Variables > Variable Sets > New**, choose **Single-Row** or **Multi-Row**. Fields: **Title**, **Internal name** (what `g_form` and server scripts use), **Order**, **Type**, **Display title**, **Layout**, **Variable Set attributes** (MRVS: `max_rows=<n>`), **Description**.
- Attach with the **Variable Sets** related list on the item or guide. Catalog managers and editors can attach sets to their items but only admins and catalog admins create sets.
- Change the set once, every item using it changes.
- Within one item: no two sets with the same internal name, and no variable named like a set's title or internal name.
- Roles: a set has read, write and create roles too. They are checked first; if the set blocks access the variable's own roles are ignored.
- Variables in a set follow the normal task-visibility rules (global or attached).

## Layout and order

- Layouts: **1 Column Wide** (default), **2 Columns Wide, alternating sides**, **2 Columns Wide, one side, then the other**. Containers can be added inside a set for more control.
- The set sorts as one unit by its own order among the item's variables; its variables keep their internal order inside it.
- Per-item order: open the item-to-set link record (reference icon in the related list) and set **Order**; it overrides the set's order for that item. A blank per-item order counts as 0 once another set on the item has one.

## Multi-row variable sets

- Grid of rows; each row a set of answers (for example several servers with their configuration). Up to **50 rows** in the UI, `max_rows` can lower it.
- Not allowed inside: Container Start/Split/End, Macro, Macro with label, UI Page; also Attachment, Requested For, Rich Text Label are unsupported (see the type pages). Variables with read roles are not allowed.
- **Unique** on a variable rejects duplicate values across rows; **Hide on grid** keeps a variable off the grid but on the row form.
- Map to field does not work; list collectors must use the glide list interface; cascading in order guides does not apply inside; an MRVS inside a container is not displayed.
- Scripts and policies: only those defined **on the MRVS** affect its variables, and they cannot affect variables outside it. No onSubmit client scripts. Visibility applies on the row form, not the grid. Dependent reference qualifiers cannot cross the MRVS boundary; in a qualifier the "current row" is the one being edited. Access other rows from a client script through `g_service_catalog` (Client API).
- No variable in an MRVS can be **Global**, so MRVS data is not on catalog tasks. Use flows (**Get Catalog Variables**, **Create Catalog Task**, For Each over rows) or workflows to work with the rows.
- Pricing follows row changes (Order Item widget only when `glide.sc.use_cart_layouts` is true).
- Not usable in item UI policy conditions, in reports, or in ATF beyond visible/mandatory/read-only checks. Not shown in Now Mobile RITM views; shown in the variable summarizer only in Service Portal. Cloned requests copy the MRVS data.

## Related

- [[Catalog Variables and Variable Types]] · [[Scripting with Catalog Variables]] (server API for rows) · [[Create a Variable Set]] · [[Order Guides]]
