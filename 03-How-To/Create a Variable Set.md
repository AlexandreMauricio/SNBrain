---
type: how-to
tags: [how-to, service-catalog]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog > Reference, topics "Create a variable set and add it to an item", "Variable set layout", https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/t_CreateAVariableSet.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Create a variable set and add it to items

**Goal:** define a group of questions once and reuse it on several catalog items or order guides.
**Prerequisites:** role catalog_admin or admin to create; catalog_editor or catalog_manager may only attach.
**Navigation:** All > Service Catalog > Catalog Variables > Variable Sets

## Steps

1. **New**, choose **Single-Row Variable Set** (one set of answers) or **Multi-Row Variable Set** (grid).
2. Fill **Title**, **Internal name** (used by `g_form` and server scripts), **Order**, **Layout**, **Display title**; for a multi-row set optionally `max_rows=<n>` in **Variable Set attributes**.
3. Save, then create the variables in the **Variables** related list (an MRVS shows them as columns in this order).
4. Optional: catalog client scripts, catalog UI policies (Applies to *A Variable Set*) and **Catalog Data Lookup Definitions** for the set.
5. On each catalog item or order guide: **Variable Sets** related list > **Edit** > add the set > **Save**.
6. Optional per item order: open the item-to-set record from the related list and set **Order**.
7. **Try It** on an item.

## Result / how to check it worked

The set's questions appear on every item that uses it; editing the set changes all of them.

## Example

| Part | Value |
|---|---|
| Set | Single-row, title *Example Delivery Details*, internal name `example_delivery` |
| Variables | `delivery_location` (reference to Location), `delivery_date` (date) |
| Used by | *Example Monitor*, *Example Laptop* |

Server-side read: `current.variables.example_delivery.delivery_location` or `current.variables.delivery_location`.

## Tables / fields involved

- [[item_option_new]] (variables, with a reference to their set), variable set and item-to-set link tables (names not given by the docs).

## Gotchas

- No two sets with the same internal name on one item; no variable named like a set.
- Scripts must use the **internal name**, not the title.
- MRVS limits (no containers or macros inside, no Global, not on catalog tasks, own scripts only): see [[Variable Sets and Multi-Row Variable Sets]].
- Background: [[Catalog Variables and Variable Types]].
