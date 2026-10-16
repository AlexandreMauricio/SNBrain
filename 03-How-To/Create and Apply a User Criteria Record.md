---
type: how-to
tags: [how-to, service-catalog, access-control]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog > Service Catalog security, topics "Create a user criteria record in Service Catalog", "Apply user criteria to items and categories", "Debug user criteria of a catalog item", https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/t_CreateAUserCriteriaRecord.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Create and apply a user criteria record

**Goal:** show a catalog item or category only to a defined set of users (or hide it from some).
**Prerequisites:** role admin or catalog_admin (catalog managers and editors can only apply existing criteria to their items).
**Navigation:** All > Service Catalog > Catalog Definition > User Criteria

## Steps

1. **New**. **Name** it after what it matches (e.g. "Users in Example Company AND in Example City").
2. Fill any of **Users**, **Groups**, **Roles**, **Companies**, **Locations**, **Departments**.
3. **Match All**: tick if every filled condition must match; leave clear if any one is enough.
4. Only if needed: **Advanced** and a **Script** returning true or false, using `user_id` (never `gs.getUser()`).
5. **Active**, **Submit**.
6. Open the catalog item (or category): related list **Available For** (or **Not Available For**) > **Edit** > add the criteria > **Save**.
7. Repeat on the items inside a category if they must be restricted too.
8. Check with **Catalog Administration > User Criteria Diagnostics** for a user who should and one who should not see it.

## Result / how to check it worked

Users outside the criteria no longer see the item in browse or search; diagnostics show **User Match** only for the intended users. Users with changed roles or scripted criteria may need to log in again.

## Example

| Part | Value |
|---|---|
| Criteria | *Example Sales EMEA*: Departments = Example Sales, Locations = Example Lisbon, Example Madrid, Match All ticked |
| Applied to | item *Example Sales Laptop*: Available For = *Example Sales EMEA*; Not Available For = *Example Contractors* |

## Tables / fields involved

- [[user_criteria]]; links `sc_cat_item_user_criteria_mtom` / `_no_mtom`, `sc_category_user_criteria_mtom` / `_no_mtom`.

## Gotchas

- Not Available For wins over Available For.
- Category criteria do not protect the items inside.
- Criteria only filter the catalog; protect data with ACLs.
- With `glide.sc.use_user_criteria` false (upgraded instance on entitlements) criteria are ignored: [[User Criteria and Catalog Access]].
- Move criteria between instances with update sets after testing.
