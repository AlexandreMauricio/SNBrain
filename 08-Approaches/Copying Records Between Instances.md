---
type: approach
tags: [approach, import-sets, data-management, update-sets]
status: documented
source: ServiceNow docs, Brazil, Workflow Data Fabric > Imports > Import sets > "Importing from another ServiceNow instance" and children, read 2026-10-16 (https://www.servicenow.com/docs/r/integrate-applications/system-import-sets/c_ImportingFromAnotherSNInstance.html); Australia Platform Administration PDF pp. 661-664 for XML export and import (read 2026-10-01)
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Copying records between instances

**Problem:** move data (not configuration) from one instance to another, for example to seed a test instance or merge a legacy instance.

## Options

### A. XML export and import from lists
- **How:** list **Export > XML** on the source, **Import XML** on the target ([[Export and Import Records as XML]]).
- **Pros:** fastest; keeps every field, sys_ids and system dates.
- **Cons:** no business rules, no transformation; references matched by display value only for users, groups, roles and group roles; admin only; export row limits apply.
- **Status:** documented
- **Best when:** small to medium copies of the same table between instances with matching reference data.

### B. XML import set over HTTPS
- **How:** data source pulling `/<table>.do?XML` from the source, transform map, onBefore scripts to keep sys_ids and reconcile references ([[Import Records from Another Instance with an XML Import Set]]).
- **Pros:** business rules optional, full transformation, reference reconciliation, can be scheduled.
- **Cons:** more setup; scripting.
- **Status:** documented
- **Best when:** repeated or larger copies, or when references must be matched on business keys.

### C. CSV import set over HTTPS
- **How:** data source pulling `/<table>.do?CSV` with a normal transform map and coalesce.
- **Pros:** simple mapping on display values; no sys_id handling.
- **Cons:** display values instead of sys_ids (depends on CSV export settings); new sys_ids on the target.
- **Status:** documented
- **Best when:** the target should own its own sys_ids and coalesce on business keys.

### D. REST, record by record
- **How:** outbound REST from the source or the Table / Import Set API on the target.
- **Pros:** near real time.
- **Cons:** an integration to build and run.
- **Status:** documented (as a recommendation only)
- **Best when:** an action on one record must be mirrored on another instance.

Not an option: setting `update_synch` on dictionary entries to carry data in update sets (blocked; it caused performance problems). Configuration still moves with [[Update Sets]]; whole-instance copies with [[Instance Clone Overview]].

## Comparison

| | A XML list | B XML import set | C CSV import set | D REST |
|---|---|---|---|---|
| Business rules | no | optional | optional | yes |
| Keeps sys_ids | yes | yes (script) | no | depends |
| Transformation | no | yes | yes | yes |
| Scheduling | no | yes | yes | event-driven |

## Decision

Use A for quick one-off copies, B when the copy repeats or references need reconciling, C when the target should keep its own identifiers, D for live mirroring. In every case load referenced tables first.

## Related

- [[Import Sets - Data Sources, Staging Tables and Cleanup]] · [[Exporting Data]]
