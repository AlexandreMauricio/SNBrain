---
type: concept
tags: [concept, service-catalog, access-control, users, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog > Configuring > Service Catalog security, topics "Set security for items and categories", "Create a user criteria record in Service Catalog", "Apply user criteria to items and categories", "Extend user criteria", "User criteria migration", "Legacy service catalog access controls", "Service Catalog administration", "Restrict access", "Service catalog categories", "Service Catalog properties", "Service Catalog and CSDM tables", https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/c_ServiceCatalogAccessControls.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# User criteria and catalog access

**In one line:** who can see and order a catalog item or category is decided by **user criteria** records (`user_criteria`) placed in the item's or category's **Available For** and **Not Available For** lists; the older "entitlements" are legacy.

## User criteria record

**Catalog Definition > User Criteria** (roles admin or catalog_admin; managers and editors can only apply existing ones to their items).

| Field | Meaning |
|---|---|
| **Users**, **Groups**, **Roles**, **Companies**, **Locations**, **Departments** | lists to match |
| **Match All** | cleared (default): matching any populated condition is enough; ticked: every populated field must match (beware impossible combinations) |
| **Advanced** + **Script** | extra condition returning true/false; use the predefined `user_id` (the user being evaluated), never `gs.getUser()` or other session APIs; do not name a function `answer`; runs in the criteria's scope; slows evaluation |
| **Active** | on or off |

- Role matches and script results are **cached in the session**: log out and in after a change. Profile changes (location, department) apply at once for standard criteria; scripted criteria need a new session.
- User criteria do not apply to elevated privilege roles.
- **Empty criteria** (no roles, groups, departments, locations, companies or script) match only **authenticated** users. Discrepancy: the Brazil page says this behaviour "applies only to the Australia release"; unclear whether Brazil keeps it.
- Extend matching to another `sys_user` reference (e.g. cost center): add a **List** column to the User Criteria table that references the same table and has a matching name (`u_cost_center` matches `cost_center`).
- Good practice: generic, reusable criteria with explicit names ("Users in Company X AND in Madrid"); build on dev/test and move with update sets.

## Applying them

- On the item or category form: related lists **Available For** and **Not Available For**. Or from the criteria form: lists **Available For Catalog Items**, **Not Available For Catalog Items**, **Available For Categories**, **Not Available For Categories** (configure the form to add them).
- Link tables: `sc_cat_item_user_criteria_mtom`, `sc_cat_item_user_criteria_no_mtom`, `sc_category_user_criteria_mtom`, `sc_category_user_criteria_no_mtom`.
- **Not Available For beats Available For.** With several criteria the user must match at least one Available For and none of the Not Available For.
- Category criteria do **not** flow down to the items in the category: secure items separately.
- Criteria only restrict the catalog view. A user who can reach the table some other way (list, ACL) is not stopped: protect the data with [[Access Control Lists (ACLs)]].
- All item types take criteria (order guides, content items, record producers).
- Categories show only if they have an active item in their hierarchy; admin and catalog_admin see categories only if they have an active item and **Availability** Desktop or Both (`glide.sc.category.canview.override`, default admin and catalog_admin).
- `glide.sc.catalog_item.subscription_enforcement`: `allow_bypass` (default) lets a service offering subscription bypass the item's Available For; `require_criteria` does not.
- Catalog Builder templates and items also accept up to 50 criteria; **Secondary owner** on an item takes criteria too (who may edit the item).

## Legacy entitlements

- Before user criteria: per-item lists (**Available for / Not available for** Company, Department, Group, User, Location), the **Roles** field and an **Entitlement Script** (`answer = true/false`, may use `gs.getUser()`). Checked in the order roles, script, then the lists; all must pass. No restriction = everyone.
- Legacy CMDB-style link tables no longer used for access: `sc_cat_item_user_mtom` / `_no_mtom`, `sc_cat_item_group_mtom`, `sc_cat_item_dept_mtom`, `sc_cat_item_location_mtom`, `sc_cat_item_company_mtom` (each with a `_no_mtom` partner).
- `glide.sc.entitlement.override`: roles (e.g. itil) that bypass entitlements.

### Migration

- `glide.sc.use_user_criteria` (default true; entitlements ignored when true). Upgrades from instances that used entitlements keep it false.
- `glide.sc.user_criteria_migration` = true shows both related-list families side by side while you rebuild entitlements as criteria; then switch `glide.sc.use_user_criteria` on.
- Criteria scripts cannot use `current` (the item or category) as entitlement scripts could.

## Debugging

**Catalog Administration > User Criteria Diagnostics**: pick a user and an item, **Diagnose**; shows every catalog, category and item node with match results per criterion. ACLs are out of scope. Item diagnostic rule `checkUserCriteriaUsage` flags items still on entitlements. See [[Debugging Service Catalog Items]].

## Related

- [[user_criteria]] · [[Create and Apply a User Criteria Record]] · [[Domain Separation in Service Catalog]] (criteria must be visible in the item's domain) · [[Catalogs, Categories and the Catalog Home Page]]
