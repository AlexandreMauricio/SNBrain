---
type: table
tags: [table, schema, service-catalog, access-control]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog > Service Catalog security, topics "Create a user criteria record in Service Catalog", "Extend user criteria", "User criteria migration", https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/t_CreateAUserCriteriaRecord.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# user_criteria

**Label:** User Criteria
**What it stores:** reusable "who" definitions (users, groups, roles, companies, locations, departments, script) used to make catalog items and categories available or not; also used by knowledge bases, Catalog Builder templates and other apps.
**Extends:** ? (not stated)
**Extended by:** ? (not stated)
**Scope:** global

## Key columns

| Label | Name | Type | Reference / choice | Meaning | Confidence |
|---|---|---|---|---|---|
| Name, Users, Groups, Roles, Companies, Locations, Departments, Match All, Advanced, Script, Active | ? | lists are List type | `sys_user`, `sys_user_group`, roles, companies, locations, departments | see [[User Criteria and Catalog Access]] | labels documented, names unconfirmed |
| Cost center (example extension) | `u_cost_center` | List | Cost Center | custom column: a List referencing the same table as the `sys_user` field with a matching name | documented (example) |

## Relations

- `sc_cat_item_user_criteria_mtom` (Catalog Item Available for), `sc_cat_item_user_criteria_no_mtom` (Not Available for).
- `sc_category_user_criteria_mtom`, `sc_category_user_criteria_no_mtom` for categories.

## Gotchas

- Script field: use `user_id`, not session APIs; results are cached per session.
- Must be visible in the catalog item's domain when domain separation is on.

## Related

- [[Create and Apply a User Criteria Record]] · [[sys_user]] · [[Access Control Lists (ACLs)]]
