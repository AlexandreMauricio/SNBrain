---
type: how-to
tags: [how-to, cmdb, import-sets, data-integrity, scripting, javascript]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB Identification and Reconciliation (IRE), topic "Apply IRE to Import Sets" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/c_CMDBIdentifyandReconcile.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# Apply IRE to an Import Set

**Goal:** load CIs through an import set without creating duplicates, by sending each row through identification and reconciliation ([[Identification and Reconciliation Engine (IRE) Overview|IRE]]) instead of letting the transform map insert it.
**Where:** the **onBefore** transform script of the import set's transform map.
**Runs:** server side, transform script, global scope (API `CMDBTransformUtil`).

## Steps

1. Build the import set and transform map as usual (target table = the CI class; field maps).
2. Add an **onBefore** transform script:

```javascript
(function runTransformScript(source, map, log, target) {
    // send the current row through identification and reconciliation
    var cmdbUtil = new CMDBTransformUtil();
    cmdbUtil.setDataSource('ImportSet');
    cmdbUtil.identifyAndReconcile(source, map, log);
    ignore = true;   // stop the transform map from inserting the row a second time

    if (cmdbUtil.hasError()) {
        log.error(cmdbUtil.getError());
    } else {
        log.info('IE Output Payload: ' + cmdbUtil.getOutputPayload());
        log.info('Imported CI: ' + cmdbUtil.getOutputRecordSysId());
    }
})(source, map, log, target);
```

3. Run the import. For each row IRE decides: no match = insert in the target table; match = update the existing CI.

`CMDBTransformUtil` reads the field maps, including reference target fields and source scripts, and passes the values to IRE with the data source given (`ImportSet` by default).

## Rows going to different classes

1. Add a column to the source data with the target class per row, for example header `MyTable`, values such as `cmdb_ci_computer` or `cmdb_ci_server`.
2. After **Auto Map Matching Fields**, add a field map: **Source field** = that column, **Target field** = **Class**.

The **Target table** of the transform map is then ignored.

## Example

Source file with columns `name`, `serial_number`, `MyTable`. Transform map targeting Computer, field maps for name and serial number, `MyTable` mapped to **Class**, and the script above. A row `example-host-01, EX-0001, cmdb_ci_linux_server` creates a Linux server the first time and updates the same CI on the next import, because the Hardware rule matches on the serial number.

## Gotchas

- **`ignore = true` is essential.** Without it the row is inserted again by the transform map after IRE handled it.
- **One transform map per import set.**
- Mandatory fields are not checked by `CMDBTransformUtil`: the import fails on an empty mandatory field whatever *Enforce mandatory fields* says.
- **Does not work for dependent CIs** (classes with a dependent identification rule).
- `'ImportSet'` must be a valid **Discovery source** choice, and reconciliation rules treat it like any other source ([[IRE Reconciliation, Data Refresh and Data Source Rules]]).

## Related

- [[IRE Error Messages]] · [[IRE Identification Rules]]
