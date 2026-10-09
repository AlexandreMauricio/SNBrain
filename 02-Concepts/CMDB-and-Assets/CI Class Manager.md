---
type: reference
tags: [reference, cmdb, schema, admin, roles]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > "CI Class Manager" (https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/ci-class-manager-landing-page.html) and, under "CMDB classifications and class dependency", the topics "View and edit class definitions and metadata" and "Delete CIs" (https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/c_CMDBClassifications.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# CI Class Manager

**What it is:** the single place to browse the CMDB class tree and to view, create and edit class definitions and the per-class settings for identification and reconciliation (IRE), CMDB Health and some Service Mapping definitions.
**Where:** **All > Configuration > CI Class Manager**, then **Hierarchy** to open the CI Classes tree.
**Roles:** `sn_cmdb_admin` has full access; `sn_cmdb_editor` reads only. Details per section below.

It does not work with non-CMDB tables.

## Sections for a selected class

| Section | Shows / lets you do | Read | Write |
|---|---|---|---|
| **Class Info > Basic Info** | display name, table name (not editable), description, icon, Extensible, Principal Class | `sn_cmdb_editor` or `itil` | `sn_cmdb_admin` or `itil_admin`, plus `personalize_dictionary` |
| **Class Info > Attributes** | the columns; edit or add (tab **Added** > *Insert new column*). Set **Identification** true to make a column a CI identifier | `sn_cmdb_editor`, `itil` | `sn_cmdb_admin`, `itil_admin`, `personalize_dictionary` |
| **Identification and Reconciliation** | identification and inclusion rules, reconciliation and data refresh rules | `sn_cmdb_editor` or `itil` | `sn_cmdb_admin` or `itil_admin` |
| **Dependent Relationships** | hosting and containment rules | same | same |
| **Suggested Relationships** | diagram of suggested relationships; add or delete | same | same |
| **All Relationship Rules** | combined diagram of suggested and dependent relationships | `itil`, `itil_admin`, `sn_cmdb_editor`, `sn_cmdb_admin` | |
| **Health** | CMDB Health properties, scorecards, KPI rules at class level | `sn_cmdb_editor` or `itil` | `sn_cmdb_admin` or `itil_admin` |
| **CI List** | the CIs of the class; create and delete | | `itil`, `itil_admin`, `sn_cmdb_editor`, `sn_cmdb_admin` can add CIs |

Column settings in **Attributes** are the same as on the [[Dictionary Entry Form]].

## What can be done from it

- **Class basics:** create a class ([[Create a CI Class]]), view and edit definitions, add a suggested relationship, list the CIs of a class, create or change Dependency Views map icons, delete CIs, set Principal Class ([[CI Classes, Dependency and Principal Class]]).
- **CMDB Health:** compliance audit, certification template, orphan rule, staleness rule, recommended field, mandatory attribute, health inclusion rule.
- **IRE:** identification rule, identification inclusion rule, reconciliation rule, data refresh rule, dependent relationship rule (hosting and containment).
- **Service Mapping:** entry point types, CI types for Service Mapping and Discovery.

## Delete CIs of a class

Role `sn_cmdb_admin` or `itil_admin`.

1. **Hierarchy** > select the class > **CI List**.
2. Tick the CIs (header check box = all visible).
3. **Actions on selected rows > Delete** > confirm.

- Deleting a CI also deletes its dependent relationships; CIs left orphaned are handled by [[Dependent CI Management and Cascade Cleanup]], not deleted on the spot.
- For large, policy-driven deletion use CMDB Data Manager.
- Base system tables cannot be deleted (this deletes records, not classes).

## Related

- [[CMDB Overview and Class Hierarchy]] · [[Reclassify a CI]]
