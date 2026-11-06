---
type: reference
tags: [reference, scripting, glide-api, javascript]
status: documented
source: ServiceNow Brazil docs, API implementation and reference > Server API reference, pages ArrayUtil - Global, JSUtil - Global, GlideStringUtil - Scoped, Global, GlideSecureRandomUtil - Scoped, Global, GlideRecordUtil - Global, GlideScopedEvaluator - Global, GlideURI - Global, GlideExcelParser - Scoped, Global, read 2026-11-06 through the docs site API (map ooCZhg2g6YDYvKp3oBwAxA). Scoped variants of GlideScopedEvaluator and GlideURI not read.
sn-release: Brazil
verified:
verified-by:
updated: 2026-11-06
---

# Server Utility APIs (ArrayUtil, JSUtil, GlideStringUtil, GlideRecordUtil)

**In one line:** ready-made helpers for arrays, null checks, string escaping, random values, GlideRecord copying, evaluating stored scripts, URL parameters and reading Excel files, all on the server.

From the Brazil docs, not tested. **Check the scope column:** several helpers are global only.

| Class | Scope | Use |
|---|---|---|
| `ArrayUtil` (script include) | global | `contains`, `indexOf`, `unique`, `union`, `intersect`, `diff`, `concat`, `ensureArray`, `convertArray` (Java to JavaScript array) |
| `JSUtil` (script include) | **global only** | `nil` (null, undefined or empty string), `notNil`, `has`, `doesNotHave`, `toBoolean`, `getBooleanValue(gr, field)`, `type_of`, `instance_of`, `isJavaObject`, `logObject`, `escapeText`, `escapeAttr` and their unescape methods |
| `GlideStringUtil` | scoped and global | `escapeHTML`, `unEscapeHTML`, `getHTMLValue`, `escapeQueryTermSeparator` (`^` to `^^`), `escapeTicks`, `escapeAllQuotes`, `urlEncode`, `normalizeWhitespace`, `newLinesToBreaks`, `getNumeric`, `isBase64`, `isEligibleSysID`, `dotToUnderBar` |
| `GlideSecureRandomUtil` | scoped and global | `getSecureRandomInt`, `getSecureRandomIntBound(bound)`, `getSecureRandomLong`, `getSecureRandomString(length)` (alphanumeric) |
| `GlideRecordUtil` (script include) | global | `getGR(table, sys_id)` (at the right child class), `getCIGR(sys_id)`, `getFields(gr)`, `getTables(table)` (ancestors), `populateFromGR(map, gr, ignore)`, `mergeToGR(map, gr, ignore)` |
| `GlideScopedEvaluator` | global and scoped | `evaluateScript(gr, scriptField, variables)` runs a script stored in a record's script field, in **the record's scope**; `putVariable`, `getVariable` |
| `GlideURI` | global | `get(name)`, `set(name, value)`, `deleteParameter`, `deleteMatchingParameter`, `getMap()`, `setView(view)` (`sysparm_view`), `getFileFromPath()`, `toString(path)`. Not for scripts run during export or in background jobs |
| `GlideExcelParser` | scoped and global (`sn_impex`) | parses `.xlsx`: `parse(stream)` or `setSource(stream)`, `getColumnHeaders()`, `next()`, `getRow()`, `getSheetNames()`, `setSheetName`, `setSheetNumber`, `setHeaderRowNumber`, `setNullToEmpty`, `getErrorMessage()`, `close()` |

Docs quirks, recorded as written:

- The JSUtil page describes `notNil` with the same words as `nil`. By its name and general knowledge, it is the opposite.
- The GlideURI - Global page also contains a GlideModalV3 `switchView()` entry and a stray `getGlideURI()` heading, which seem misplaced.

## Example

```javascript
// Server side, global; read the first sheet of an Excel attachment on a record
var attachment = new GlideSysAttachment();
var parser = new sn_impex.GlideExcelParser();
parser.parse(attachment.getContentStream('<attachment_sys_id>'));
var headers = parser.getColumnHeaders();
while (parser.next()) {
    var row = parser.getRow();
    if (JSUtil.notNil(row[headers[0]])) gs.info(row[headers[0]]);
}
parser.close();
```

## Related

- [[GlideSysAttachment, GlideFilter and GSLog API Reference]] · [[GlideTableHierarchy and GlideElementDescriptor API Reference]] · [[GlideRecord API Reference]] · [[Team Script Conventions]]
