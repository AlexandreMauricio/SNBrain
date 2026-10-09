---
type: troubleshooting
tags: [troubleshooting, cmdb, data-integrity, integrations, import-sets]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB Identification and Reconciliation (IRE) > Reference, topic "IRE error messages" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/c_CMDBIdentifyandReconcile.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# IRE Error Messages

**Symptom:** a CI load through Discovery, a Service Graph Connector, an import set with `CMDBTransformUtil` or a direct API call fails or skips items, and the IRE output payload or log carries one of the error codes below.
**Cause:** the payload, the identification rule of the class, or the dependent relationship rules do not fit each other.
**Fix:** find the code in the table.

## Rule problems

| Code | Message (shortened) | Fix |
|---|---|---|
| IDENTIFICATION_RULE_MISSING | Identity Rule Missing for table [x] | give the class (or a parent) an **active** identification rule ([[IRE Identification Rules]]) |
| NO_CLASS_NAME_FOR_INDEPENDENT_CI | Cannot have 'sys_class_name' as a key field in an Independent Identity Rule | remove the class attribute from the CI identifier |
| IDENTIFICATION_RULE_FOR_LOOKUP_MISSING | Identity Rule for table [x] missing Lookup Rule for class [y] | the payload has a `lookup` item for a table with no lookup identifier entry: add one with **Search on table** = y (KB0786444) |
| IDENTIFICATION_RULE_FOR_RELATED_ITEM_MISSING | ...missing Related Rule for class [y] | add a related entry with **Related table** = y |
| NO_LOOKUP_RULES_FOR_DEPENDENT_CI | Cannot have Lookup Rule for a Dependent Identity Rule | remove the lookup entry from the dependent rule |
| METADATA_RULE_MISSING | No containment or hosting rules defined for dependent class [x] | add them ([[CMDB Dependent Relationship Rules - Hosting and Containment]]) |
| DUPLICATE_RELATIONSHIP_TYPES | Duplicate relationship type records exists with name [x] in table [cmdb_rel_type] | delete the duplicate relationship type |

## Payload problems

| Code | Message (shortened) | Fix |
|---|---|---|
| MISSING_MATCHING_ATTRIBUTES | missing minimum set of input values for criterion attributes | supply the criterion attributes of at least one identifier entry of the class |
| REQUIRED_ATTRIBUTE_EMPTY | Missing mandatory field [x] in table [y] | supply the value |
| MISSING_DEPENDENCY | no relations defined for dependent class [x] that matches any containment/hosting rules | add the relation to the CI it depends on, matching a hosting or containment rule |
| MULTIPLE_DEPENDENCIES | Found multiple dependent relation items / Multiple paths leading to the same destination | keep one dependency; remove duplicate relationship or qualifier chains |
| DUPLICATE_PAYLOAD_RECORDS | Found duplicate items in the payload (index 0 and 1) | two items share criterion values: remove one |
| DUPLICATE_RELATED_PAYLOAD, DUPLICATE_LOOKUP_PAYLOAD | Found duplicate Related / Lookup items | remove one |
| INVALID_INPUT_DATA | invalid sys_id (no such record, or it is a duplicate with `duplicate_of` set) | remove or correct the sys_id |
| INVALID_INPUT_DATA | no data source / invalid data source | pass a valid choice of **Discovery source** (`discovery_source`) on `cmdb_ci` |
| INVALID_INPUT_DATA | No such relationship with name [x] in [cmdb_rel_type] | fix the name, add the type, or restore a shipped type that was renamed or deleted |
| INVALID_INPUT_DATA | invalid parent / child record index | fix the indexes in `relations` |
| QUALIFICATION_LOOP | Qualification chain has loop | remove the loop |
| TYPE_CONFLICT_IN_QUALIFICATION | qualification chain has multiple possible paths | leave one path between the two items |
| ABANDONED | Abandoning processing payload item 'x', since it depends on payload item 'y' that has errors | fix y first |
| ABANDONED | Can't find matched record with sys_id; API called recursively; error parsing input json | check the record exists; do not call the IRE API from logic that IRE triggers; fix the JSON |

## Data and runtime problems

| Code | Message (shortened) | Fix |
|---|---|---|
| MULTIPLE_DUPLICATE_RECORDS | Found duplicate records in table [x] using fields [y] | resolve the duplicates: see the de-duplication tasks ([[Duplicate CI Detection in IRE]]) |
| MULTI_MATCH | Duplicate dependent records with the same relationship to one CI; multiple relations between payload items; duplicate records in a lookup table | de-duplication tasks, then delete duplicates; remove duplicate relationship or qualifier chains |
| RECLASSIFICATION_NOT_ALLOWED | CI Reclassification not allowed from class [x] to [y] | review the reclassification task ([[CI Reclassification During IRE Processing]]) |
| INSERT_NOT_ALLOWED_FOR_SOURCE | Insert into [x] is blocked for data source [y] by IRE data source rule | change the data source rule, or wait for a permitted source to create the CI ([[IRE Reconciliation, Data Refresh and Data Source Rules]]) |
| LOCK_TIMEOUT | Failed to acquire synchronization lock | add property `glide.identification_engine.mutex_expiration_time` with a value above the default 15 minutes |

## How to confirm the cause

- **Configuration > Identification/Reconciliation > Identification Logs**: filter by source and time, open a run to see **Input**, **Logs**, **Output**.
- Re-run the payload in [[Simulate an IRE Payload with Identification Simulation]] (nothing is committed).
- Raise the log level temporarily with `glide.cmdb.logger.source.identification_engine` ([[IRE Properties and Tables Reference]]).
- IRE rejects a payload outright, before any rule, if two of its items are duplicates on a class identifier.
- "FAILED TRYING TO EXECUTE ON CONNECTION ... Duplicate entry" in node logs on insert is covered by a separate support article (the docs name it without a number).

## Related

- [[Identification and Reconciliation Engine (IRE) Overview]]
