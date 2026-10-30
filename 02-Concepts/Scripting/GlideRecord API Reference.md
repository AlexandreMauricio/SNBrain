---
type: reference
tags: [reference, scripting, glide-api, javascript, encoded-query]
status: documented
source: ServiceNow Brazil docs, API reference > Server API reference > GlideRecord - Global and GlideRecord - Scoped (method lists and their notes), read 2026-10-30. Parameter tables and per-method examples not copied. https://www.servicenow.com/docs/r/api-reference/server-api-reference/c_GlideRecordAPI.html Team notes shared by the user's manager, 2026-10-30, file GlideRecord.md (unverified, sections marked).
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# GlideRecord API Reference

**In one line:** the method list for **GlideRecord**, server side, global and scoped. For how to query, see [[GlideRecord Queries, GlideRecordSecure and Server Utilities]].

From the Brazil docs; not tested.

## Rules that matter

- **An invalid query part is dropped** and the rest runs, so `deleteMultiple()` or `updateMultiple()` on a bad query can destroy data. Test first; `glide.invalid_query.returns_no_rows` helps but not with every operator.
- **Avoid dot-walking for values:** it returns an object. Use `getValue()`, `getDisplayValue()`, or `toString()` when dot-walking, as `current.caller_id.manager.toString()`.
- Use `setValue()` rather than direct assignment before `update()` or `updateMultiple()`.
- **Counting only:** use [[GlideAggregate and GlideQuery API Reference|GlideAggregate]], not `getRowCount()`.
- `deleteMultiple()` and `updateMultiple()`: not with `chooseWindow()`; `deleteMultiple()` not on tables with currency fields, and no dot-walking.
- `chooseWindow()` triggers COUNT(*). `setNoCount()` stops it.
- `setWorkflow(false)` and `setUseEngines(false)` have wide effects; `setWorkflow()` is ignored by some later calls (see the page). `autoSysFields(false)` leaves system fields stale.
- `canRead()` is not a reliable table-level check.
- `addValue()` is atomic in the database, but the new value is not read back.

## Methods

| Purpose | Methods |
|---|---|
| Filter | `addQuery`, `addEncodedQuery`, `addActiveQuery`, `addInactiveQuery`, `addNullQuery`, `addNotNullQuery`, `addJoinQuery`, `addDomainQuery`, `addFunction`, `addExtraField` |
| Query access (with [[GlideRecord Queries, GlideRecordSecure and Server Utilities|GlideRecordSecure]]) | `addUserQuery`, `addUserEncodedQuery`, `addUserOrderBy`, `addUserOrderByDesc`; `addSystemQuery`, `addSystemEncodedQuery`, `addSystemOrderBy`, `addSystemOrderByDesc` |
| Order and limit | `orderBy`, `orderByDesc`, `setLimit`, `chooseWindow`, `setNoCount`, `setCategory`, `disableSysIdInOptimization` |
| Run and move | `query`, `_query`, `queryNoDomain`, `next`, `_next`, `hasNext`, `get`, `find`, `saveLocation`, `restoreLocation`, `setLocation`, `getLocation`, `getRowNumber` |
| Read | `getValue`, `getDisplayValue`, `getElement`, `getUniqueValue`, `getRowCount`, `getEncodedQuery`, `getLink`, `getFields`, `getED`, `getAttribute`, `getLabel`, `getPlural`, `getClassDisplayValue`, `getTableName`, `getRecordClassName`, `getRelatedLists`, `getRelatedTables`, `getEscapedDisplayValue` |
| Write | `initialize`, `newRecord`, `setValue`, `setDisplayValue`, `insert`, `update`, `deleteRecord`, `updateMultiple`, `deleteMultiple`, `insertWithReferences`, `updateWithReferences`, `addValue`, `applyTemplate`, `applyEncodedQuery`, `setNewGuid` |
| Control | `setWorkflow`, `setUseEngines`, `autoSysFields`, `setForceUpdate`, `setAbortAction`, `setQueryReferences` |
| Check | `canCreate`, `canRead`, `canWrite`, `canDelete`, `changes`, `operation`, `isNewRecord`, `isValid`, `isValidField`, `isValidRecord`, `instanceOf`, `hasAttachments` |
| Dynamic attributes | `getDynamicAttribute`, `getDynamicAttributeValue`, `getDynamicAttributeDisplayValue`, `setDynamicAttributeValue`, `setDynamicAttributeDisplayValue`, `setDynamicAttributeValues`; roles `dynamic_schema_writer` and a reader role |

## Scoped differences

By comparing the two pages' method lists; a missing method may just be undocumented, so test.

- **Not on the scoped page:** `addDomainQuery`, `addExtraField`, `addInactiveQuery`, `addJoinQuery`, `addValue`, `applyEncodedQuery`, `applyTemplate`, `autoSysFields`, `changes`, `find`, `getFields`, `getLocation`, `getPlural`, `getRelatedLists`, `getRelatedTables`, `getRowNumber`, `hasAttachments`, `insertWithReferences`, `instanceOf`, `queryNoDomain`, `saveLocation`, `restoreLocation`, `setDisplayValue`, `setForceUpdate`, `setLocation`, `setNewGuid`, `setQueryReferences`, `setUseEngines`, and the dynamic attribute methods.
- **Only on the scoped page:** `getElements`, `getLastErrorMessage`, `isActionAborted`, `isEncodedQueryValid`, `isValidEncodedQuery`, `isView`, `setNewGuidValue`.

## Query tips (team notes)

Unverified team notes, not tested. Server side. `GlideFilter` and the `ref_` syntax appear in no official page read so far.

**Field of a child table from a parent query:** `ref_<child table>.<field>`.

```javascript
var taskGR = new GlideRecord('task');
taskGR.addQuery('ref_incident.<incident field>', '<value>');
```

**Does a record match an encoded query?**

```javascript
GlideFilter.checkRecord(incidentGR, 'active=true');
```

**Exactly one result:** avoid `getRowCount()`, which the notes call unoptimised on large results, and which agrees with the rule above.

```javascript
if (gr.next() && !gr.hasNext()) {
    // exactly one record
}
```

## Example

```javascript
// Server side, global: background script, read only
var gr = new GlideRecord('incident');
gr.addActiveQuery();
gr.addQuery('priority', 1);
gr.orderByDesc('sys_created_on');
gr.setLimit(10);
gr.query();
while (gr.next()) {
    gs.info(gr.getValue('number') + ' ' + gr.getDisplayValue('assigned_to'));
}
```

## Related

- [[GlideAggregate and GlideQuery API Reference]] · [[GlideElement and GlideUser API Reference]] · [[GlideSystem API Reference]] · [[Business Rules]]
