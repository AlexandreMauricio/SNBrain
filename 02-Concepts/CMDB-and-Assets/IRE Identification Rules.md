---
type: concept
tags: [concept, cmdb, data-integrity, schema, admin]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB Identification and Reconciliation (IRE) > Configure, topics "Identification rules", "Create a CI identification rule", "Create an identification inclusion rule", "General guidelines for using CMDB Identification" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/c_CMDBIdentifyandReconcile.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# IRE Identification Rules

**In one line:** an identification rule tells [[Identification and Reconciliation Engine (IRE) Overview|IRE]] which attribute combinations make a CI of a class unique. One rule per class: a **CI identifier** (`cmdb_identifier`) with prioritised **identifier entries** (`cmdb_identifier_entry`) and optional **related entries** (`cmdb_related_entry`).

**Where:** **Configuration > CI Class Manager** > class > **Class Info > Identification Rule**. List views under **Configuration > Identification/Reconciliation**.
**Roles:** read `sn_cmdb_editor` or `itil`; write `sn_cmdb_admin` or `itil_admin`.

## Inheritance

- A class without its own rule uses its parent's, **including identifier entries and related entries**.
- Giving the class its own rule (**Replace**) drops everything inherited. Entries needed again must be re-added by hand. Example: Hardware's rule has a related entry for the software instance table; a new rule on Computer loses it unless recreated.
- A rule can be edited only on the class where it is defined, never as inherited.

## Independent and dependent rules

| Type | Identifies by | Notes |
|---|---|---|
| **Independent** | the CI's own attributes | preferred |
| **Dependent** | first the CI it depends on, then this CI within that context, using the relationship (and any qualifier chain) | needs dependent relationship rules for the class ([[CMDB Dependent Relationship Rules - Hosting and Containment]]). Slower and more error-prone. A dependent CI has one parent with dependency |

If the payload's qualifier chain for a matched parent/child pair differs from the database, the database chain is updated to match.

## Identifier entries

| Kind | Chosen as | Matches on |
|---|---|---|
| **Regular** | *Use attributes from main table* | the CI's own (or inherited) attributes |
| **Lookup** | *Use attributes from another table (Lookup table)* | rows of a related table that reference the CI, for example Serial Number (`cmdb_serial_number`) or Network Adapter. Missing lookup rows are inserted |
| **Hybrid** | *Use attributes from main and another table* | both. Example: two cloud VMs share serial numbers; serial number + type from the lookup table plus **Name** from the main table tells them apart |

Fields:

| Field | Notes |
|---|---|
| Active | at least one active entry is needed for the rule to apply |
| Priority | lower number first. Equal priorities are applied in random order. Leave gaps |
| Search On Table | the main table, or the lookup table. **A lookup table must have a reference field to `cmdb_ci`**, otherwise the entry is invalid |
| Criterion Attributes | the set that must match |
| Allow null attribute | try the entry when at least one criterion attribute has a value. Off = all must have values. Always off for hybrid |
| Allow fallback to parent's rules | dependent rules only: use the parent CI's rule when this one finds nothing |
| Advanced options: conditions | filter narrowing the records searched. For regular entries only when property `glide.identification_engine.enable_identifier_optional_condition` is true (default false) |
| Advanced options: **Enforce exact count match** (lookup) | on: **every** lookup item in the payload must match rows referencing the same CI; several matches = oldest CI. Off: one matching lookup item is enough; several matches = the CI with most matching items, then the oldest |

## Related entries

Do **not** identify the CI. They say how to create or update rows in other tables (CMDB or not) that reference the identified CI, sent in the payload's `related` block. Fields: Active, **Related table**, **Referenced field** (always a reference to `cmdb_ci` or a descendant), Priority, Criterion attributes, Allow null attribute, Filter conditions. Inherited by child classes that define none.

## The shipped Hardware rule as an example

Identifier entry on Serial Number (`cmdb_serial_number`) with criterion attributes Serial Number + Serial Number Type. The payload's `lookup` items are searched there. Unless exact count match is on, one match is enough; if all matches point to one CI, that CI is updated. No match: next entry. All entries exhausted: a new CI is inserted. The full entry list is in [[CMDB Modelling Guidelines for Hardware, Virtual Machines and Cloud]].

## Identification inclusion rules

A per-class condition (**Active record condition**) that limits which CIs take part in identification **and** in the CMDB Health duplicate metric, for example only operational CIs. Table `cmdb_ie_active_config`. None exist in the base system.

- CI Class Manager > class > **Identification** > **Inclusion Rule (Advanced)** > **Add**. List: **Identification/Reconciliation > Identification Inclusion Rules**.
- **They affect every script that calls IRE** and can stop Discovery and Service Mapping from identifying some CIs. Create with care.

## Guidelines

1. Prefer independent rules: model the class with attributes that identify it by themselves.
2. If dependent, keep to **one** level of dependency. **Two is the maximum supported.**
3. **Avoid lookup entries** (performance); look first for a way to use an independent rule.
4. Keep the number of identifier entries low, ideally **one**; each extra entry costs performance.
5. Strongest entry gets the highest priority.
6. Put the rule at the class level where it belongs.
7. Do not define a lookup entry on a class that also has its own CI identifier (for example Network Adapter looked up from Hardware and identified by itself): the two rules can disagree and create duplicates.

## Gotchas

- **Reference fields are weak criterion attributes.** An invalid reference (for example Model ID) is replaced with *Unknown*; several CIs then share *Unknown* and become duplicates.
- With exactly two criterion attributes of which one is `sys_class_name`, the other cannot be null even with **Allow null attribute**.
- `sys_class_name` cannot be a criterion attribute of an independent rule; a dependent rule cannot have a lookup entry ([[IRE Error Messages]]).
- Turning on `glide.identification_engine.enable_identifier_optional_condition` activates **all** the conditions already shipped on regular entries. Review column **Optional condition** in `cmdb_identifier_entry.list` first.
- Reclassification is possible only between classes with identical identification rules.

## Related

- [[Create a CI Identification Rule]] · [[CI Class Manager]] · [[Duplicate CI Detection in IRE]]
