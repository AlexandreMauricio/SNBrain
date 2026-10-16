---
type: concept
tags: [concept, import-sets, scripting, javascript]
status: documented
source: ServiceNow docs, Brazil, Workflow Data Fabric > Imports > Import sets > Transform maps, topics "Transformation script variables", "Map with explicit transform map scripts", "Map with transformation event scripts", plus "Field map script variables", "Updating records using coalesce", "Add onBefore scripts to the transform map", "Scheduled data import scripting options", https://www.servicenow.com/docs/r/integrate-applications/system-import-sets/r_MapWithTransformationEventScripts.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Transform scripts and script variables

**In one line:** server-side scripts on a transform map either do the mapping themselves (the map's **Script** field) or react to transform **events** (related list **Transform Scripts**, field **When**): onStart, onBefore, onAfter, onComplete, onForeignInsert, onChoiceCreate, onReject.

All run on the server, in the transform map's scope (examples here are global).

## Variables

| Variable | Type | Meaning |
|---|---|---|
| `source` | GlideRecord | the staging row (in onStart: the first row, still empty because no row has been read; onComplete: the last row) |
| `target` | GlideRecord | the target record being written |
| `map` | GlideTransformMap | read-only: `name`, `sys_id`, `source_table`, `target_table`, `order` |
| `import_set` | GlideRecord | the import set (onStart, onBefore, onAfter, onComplete) |
| `log` | object | `log.info()`, `log.warn()`, `log.error()` into the import log (info lines need `glide.importlog.log_to_table` = true) |
| `action` | string | `insert` or `update` |
| `ignore` | boolean | onStart: stop the whole transform; onBefore: skip this row (onAfter still runs); onForeignInsert / onChoiceCreate: do not create that record or choice |
| `error` | boolean | onStart/onBefore/onAfter: halt the transform with an error; onForeignInsert/onChoiceCreate: reject the row; onComplete: mark the set as error |
| `error_message`, `status_message` | string | returned in the SOAP or REST response (web service imports) |
| `name`, `value` | string | onForeignInsert / onChoiceCreate: target field name and the display value about to be created |
| `response` | object | web service import sets: extra response elements (`response.transaction_id = 'abc';`) |
| `answer` | | field map source scripts: the value to set |

## When each runs

| Event | When | Typical use |
|---|---|---|
| **onStart** | before any row | log, check prerequisites, `ignore = true` to abort |
| **onBefore** | before each row is transformed | skip rows (`ignore`), set references directly, `target.setNewGuidValue(source.u_sys_id)` to keep sys_ids |
| map **Script** (explicit) | after field values are copied, before the write | derive values, set `target.sys_class_name` to land in a child class |
| **onAfter** | after the row is saved | related records, attachments, orders |
| **onForeignInsert** | before a referenced record is auto-created | block or log foreign inserts |
| **onChoiceCreate** | before a new choice value is created | block unknown choices |
| **onReject** | when a foreign record or choice is rejected and the row is dropped | log, raise an event |
| **onComplete** | after all rows | events, totals; good place for heavy logic instead of per-row business rules |

## Examples (adapted from the docs)

```javascript
// onBefore: skip rows without a company (transform script, global)
(function runTransformScript(source, map, log, target) {
    if (source.u_company.toString() == '') {
        ignore = true;
        log.info('No company, row ignored: ' + source.u_name);
    }
})(source, map, log, target);
```

```javascript
// Explicit map script: route servers to child classes by OS
var os = source.u_operating_system.toString();
if (/linux/i.test(os)) target.sys_class_name = 'cmdb_ci_linux_server';
if (/win/i.test(os))   target.sys_class_name = 'cmdb_ci_win_server';
```

```javascript
// Explicit map script: split a full name into first, middle and last
var parts = source.u_name.toString().split(' ');
if (parts.length == 1) target.last_name = parts[0];
else {
    target.first_name = parts.shift();
    target.last_name = parts.pop();
    if (parts.length) target.middle_name = parts.join(' ');
}
```

```javascript
// onComplete: raise a custom event for a notification or script action
gs.eventQueue('x_example.import_completed', import_set, map.name, '');
```

Other patterns in the docs: create a missing software package (`cmdb_ci_spkg`) and point `target.software` at it; order a catalog item with the legacy `Cart` API from onAfter; `new GlideEvent(...)` records (older style than `gs.eventQueue`). Use `toString()` on source fields before JavaScript string functions. Never use the string `NULL` as data (it clears fields).

## Scheduled import pre and post scripts

On the scheduled import: `cancel = true` (pre-script) stops it; `import_set` (`number`, `sys_id`, `state`, `table_name`); `data_source` (can be changed, e.g. `data_source.import_set_table_name = '...'; data_source.update();`). See [[Scheduled and Concurrent Imports]].

## Performance

Each GlideRecord query in a transform script runs once per row: prefer built-in features (coalesce options, choice actions) and keep scripts light ([[Import Set Performance and Errors]]).

## Related

- [[Transform Maps, Field Maps and Coalesce]] · [[GlideRecord Queries, GlideRecordSecure and Server Utilities]] · [[LDAP Integration]] (LDAP transform script examples)
