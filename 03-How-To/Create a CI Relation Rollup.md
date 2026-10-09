---
type: how-to
tags: [how-to, cmdb, business-rule, automation]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CI relationships in the CMDB, topic "Create a CI relation rollup" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/c_CIRelationships.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# Create a CI Relation Rollup

**Goal:** keep a field on a parent CI equal to the count, sum, maximum, minimum or mean of a field on the CIs related to it by one relationship type.
**Where:** **All > Configuration > Relationships > CI Relation Rollups**.
**Role:** `ecmdb_admin`.

Typical uses: total power drawn by everything in a rack shown on the rack; a notification when a threshold is passed, or when 9 of 10 rack slots are filled.

## Steps

1. **CI Relation Rollups** > **New**.

| Field | Notes |
|---|---|
| CI Relationship Type | for example `Members::Member of` |
| Type | COUNT, MAX, MEAN, MIN or SUM |
| Parent field | the field that receives the result |
| Child field | the field read from each child |
| Rollup class | the classes the rollup applies to (for example racks only) |

2. Make the business rule run. Rollups are calculated by the business rule **cmdb synch event** on `cmdb_ci` (server side). It is active, but does not fire until changed: open it under **Business Rules** and tick **Update**, **Delete** and **Query**.
3. Optional, to recalculate when a relationship itself changes: activate the business rule **cmdb_rel_ci synch event** (tick **Active**).

## Example

Relationship type `Contains::Contained by`, Type SUM, Parent field `Example power total`, Child field `Example power draw`, Rollup class Rack. After step 2, changing the power value on a server contained by `Example Rack 01` updates the total on the rack.

## Gotchas

- Nothing happens until the business rule in step 2 is edited.
- Field names in the example are placeholders; the docs do not name the fields.

## Related

- [[CI Relationships]] · [[cmdb_rel_ci]] · [[Business Rules]]
