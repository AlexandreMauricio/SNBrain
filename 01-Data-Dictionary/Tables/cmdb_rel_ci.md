---
type: table
tags: [table, cmdb, schema, reference-field]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > "CI relationships in the CMDB" and its topics (https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/c_CIRelationships.html), read through the docs site API 2026-10-09. The pages describe the parts of a relationship but print no column names; names are marked ?
sn-release: Brazil
verified:
updated: 2026-10-09
---

# cmdb_rel_ci

**Label:** CI Relationship
**Extends:** not stated
**Purpose:** one row per relationship between two CIs. Concepts in [[CI Relationships]].

## Columns

| Label | Name | Type | Notes |
|---|---|---|---|
| Parent | `?` | reference to a CI ([[cmdb_ci]]) | the CI named first in the type (the one that *Runs on*, *Contains*, *Manages*) |
| Child | `?` | reference to a CI | |
| Type | `?` | reference to CI Relationship Type (`cmdb_rel_type`) | types are named `Parent descriptor::Child descriptor`, for example `Runs on::Runs` |

## Notes

- **Not domain separated.** The form formatter still hides a relationship unless both CIs are visible in the user's domain.
- A relationship with a relation qualifier is stored as two rows (parent to qualifier, qualifier to child).
- Rows of dependent relationships identify dependent CIs: do not delete them directly.
- Archiving or deleting a CI archives or deletes its rows here ([[Dependent CI Management and Cascade Cleanup]]).
- Access: ACLs on this table plus the `edit_ci_relations` operation ACL on `*`.

## Related tables

| Table | Label | Relation |
|---|---|---|
| `cmdb_rel_type` | CI Relationship Type | the type; not domain separated |
| `cmdb_rel_type_suggest` | Suggested Relationship | types suggested per class |
| `sys_rel_source` | Relationship Sources | discovery source and last scan per non-dependent relationship; filled only when `glide.identification_engine.populate_sys_rel_source` is on |
| `cmdb_rel_team` | (Teams related list) | groups per service CI by group type ([[CI Classes, Dependency and Principal Class]]) |
