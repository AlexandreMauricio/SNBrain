---
type: reference
tags: [reference, scripting, glide-api, javascript]
status: documented
source: ServiceNow Brazil docs, API implementation and reference > Server API reference, pages GlideSysAttachment - Global, GlideFilter - Scoped, Global, GSLog - Scoped, Global, read 2026-11-06 through the docs site API (map ooCZhg2g6YDYvKp3oBwAxA). GlideSysAttachment - Scoped not read.
sn-release: Brazil
verified:
verified-by:
updated: 2026-11-06
---

# GlideSysAttachment, GlideFilter and GSLog API Reference

**In one line:** three server utilities: handle attachments, test whether a record matches an encoded query without querying, and log at levels.

From the Brazil docs, not tested. All run on the server. Scope is given per class below.

## GlideSysAttachment (global)

| Method | Does |
|---|---|
| `copy(sourceTable, sourceID, targetTable, targetID)` | copies every attachment, with its attributes; returns a String listing the new `sys_attachment` sys_ids, comma separated in the docs' output |
| `getAttachments(table, sys_id)` | GlideRecord of the attachment metadata |
| `getContentStream(sysID)` | the bytes as a GlideScriptableInputStream, not a string |
| `write(record, fileName, contentType, content)`, `writeContentStream(...)` | attach new content to a record |
| `deleteAttachment(attachmentID)` | deletes one |
| `addAttribute`, `addMultipleAttributes`, `fetchAttribute`, `fetchAllAttributes`, `updateAttribute`, `updateAllAttributes`, `deleteAttribute`, `deleteAllAttributes` | attachment attributes, listed in **Attachment Attributes** (`sys_attachment_list`) |

Methods touching encryption contexts are global only. Tables: [[Attachments]].

## GlideFilter (scoped and global)

- `GlideFilter.checkRecord(gr, filter, match)`: does the record meet the encoded query? `match` true (the default) needs every condition, false needs any one.
- `new GlideFilter(filter, title)` then `filter.match(gr, match)`: the same, reusable inside a loop.
- `setCaseSensitive(false)` turns off case sensitivity, but **not** for `checkRecord`, whose values stay case-sensitive.
- `setEnforceSecurity(true)` evaluates the filter string sandboxed.

**Trap:** GlideFilter is **case-sensitive by default**, while GlideRecord queries are not. A filter of `first_name=abel` will not match *Abel*. Add `ISNOTEMPTY` to a condition to exclude empty values.

## GSLog (scoped and global)

A script include. Each logger is tied to a system property that sets the minimum level, and to a caller name that appears in the message.

```javascript
var log = new GSLog('<property name>', 'ExampleCaller');
log.logInfo('Example message');            // *** Script [ExampleCaller]: Example message
if (log.debugOn()) log.logDebug('detail');
```

- Methods: `log(level, msg)`, `logDebug`, `logInfo`, `logNotice`, `logWarning`, `logErr`, `logCrit`, `logAlert`, `logEmerg`, `debugOn()`, `getLevel()`, `setLevel()`.
- Output goes to **System Logs > System Log**. The default level is **notice**.

**Unconfirmed variants for the levels:** the page's introduction lists debug, info, notice, warning, err and crit, as do the team notes. The method list adds **alert** and **emerg**.

## Example

```javascript
// Server side, global; copy attachments only for active incidents
var inc = new GlideRecord('incident');
if (inc.get('<incident_sys_id>') && GlideFilter.checkRecord(inc, 'active=true')) {
    var copied = new GlideSysAttachment().copy('incident', inc.getUniqueValue(), 'problem', inc.getValue('problem_id'));
    new GSLog('<property name>', 'ExampleCaller').logInfo('Copied: ' + copied);
}
```

## Related

- [[Attachments]] · [[GlideRecord API Reference]] · [[Debugging Scripts]] · [[Force Records into an Update Set]]
