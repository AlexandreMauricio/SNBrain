---
type: how-to
tags: [how-to, cmdb, schema, admin]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB classifications and class dependency, topic "Create a CI class" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/c_CMDBClassifications.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# Create a CI Class

**Goal:** add a new CMDB class (table) as a child of an existing class, with the rules identification needs.
**Where:** **All > Configuration > CI Class Manager** ([[CI Class Manager]]).
**Roles:** `sn_cmdb_admin` or `admin` for full access; or `sn_cmdb_admin` / `itil_admin` together with `personalize_dictionary` to edit the dictionary.
**Before you start:** the parent class must be **Extensible**, otherwise **Add Child Class** is not offered. How columns are inherited: [[Table Extension and Extension Models]].

## Steps

1. Open CI Class Manager > **Hierarchy** > select the parent class > **Add Child Class**.
2. **Provide Basic Info**, then **Next**:

| Field | Notes |
|---|---|
| Display name | unique label, max 80 characters. Also updates the label record in the language file ([[sys_documentation]]) |
| Table name | generated from the label with the prefix `u_cmdb_ci`. The prefix is fixed; the rest can be edited (lowercase letters, digits, underscore; max 80) |
| Description | what the class is for |
| Icon | |
| Extensible | whether this class can itself be extended |
| Principal Class | include it in the Principal Class filter ([[CI Classes, Dependency and Principal Class]]) |

3. **Add Attributes:** **+** for each new column (same settings as the [[Dictionary Entry Form]]). To use a column for identification, set its **Identification Rule** cell to true. **Next**.
4. **Set Identification Rule:** review the rule and identifier entries derived from the parent. **Replace** to give the class its own.
5. **Dependencies** (shown only when the class has dependent identification rules): **Add dependency**.
6. **Add Reconciliation Rules:** **Add** reconciliation rules and data refresh rules.
7. **Add Suggested Relationships:** review the derived diagram; **New** > pick a **Relationship** and **Target Class** > **Save**. These feed the suggestions in CMDB Query Builder.
8. **Done**.

## Example

Parent **Computer** (`cmdb_ci_computer`). Display name `Example Thin Client`, table name `u_cmdb_ci_example_thin_client`, Extensible off, one added column `Example Dock ID` (string). Keep the derived identification rule (serial number, then name), add no dependencies, **Done**. The class then appears under Computer in the hierarchy.

## Gotchas

- A class with no working identification rule cannot be matched by identification, so loads create duplicates.
- The table name cannot be changed later (Basic Info shows it read-only).
