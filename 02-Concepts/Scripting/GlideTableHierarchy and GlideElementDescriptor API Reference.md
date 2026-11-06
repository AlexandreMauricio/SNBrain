---
type: reference
tags: [reference, scripting, glide-api, schema]
status: documented
source: ServiceNow Brazil docs, API implementation and reference > Server API reference, pages GlideTableHierarchy - Scoped and GlideElementDescriptor - Scoped, Global, read 2026-11-06 through the docs site API (map ooCZhg2g6YDYvKp3oBwAxA).
sn-release: Brazil
verified:
verified-by:
updated: 2026-11-06
---

# GlideTableHierarchy and GlideElementDescriptor API Reference

**In one line:** ask a script which tables a table extends or is extended by, and what a field is (type, label, length, mandatory, encrypted), without querying the dictionary tables directly.

From the Brazil docs, not tested. Server side. Extension itself: [[Tables, Records and Table Relationships]].

## GlideTableHierarchy (scoped)

`new GlideTableHierarchy('<table>')`, then:

| Method | Returns |
|---|---|
| `getName()`, `getBase()`, `getRoot()` | the table, its parent, the top of the hierarchy |
| `getTables()`, `getHierarchy()` | arrays of the table names in the hierarchy |
| `getTableExtensions()`, `getAllExtensions()` | the tables that extend it; the docs word the two descriptions alike, so which includes the table itself is unconfirmed |
| `hasExtensions()`, `isBaseClass()`, `isSoloClass()` | booleans |

## GlideElementDescriptor (scoped and global)

No constructor. Get it with `gr.getED()` or `gr.<field>.getED()`.

| Method | Returns |
|---|---|
| `getName()`, `getLabel()`, `getPlural()` | name and labels |
| `getInternalType()`, `getLength()` | dictionary type and maximum length |
| `isMandatory()`, `isVirtual()`, `isAutoOrSysID()`, `isChoiceTable()` | booleans |
| `isEncrypted()` (column level encryption), `isEdgeEncrypted()`, `getEncryptionType()`, `getAttachmentEncryptionType()`, `hasAttachmentsEncrypted()` | encryption |

Dictionary attributes are read with `getED().getBooleanAttribute('<attribute>')`, which the team's UI action in [[Force Records into an Update Set]] uses. That method is not on this page, so its documentation is unconfirmed.

## Example

```javascript
// Server side, scoped or global; list the fields of Example Table and where the table sits
var hierarchy = new GlideTableHierarchy('x_example_table');
gs.info('Extends: ' + hierarchy.getBase() + ', root: ' + hierarchy.getRoot());

var gr = new GlideRecord('x_example_table');
gr.initialize();
var fields = gr.getFields();
for (var i = 0; i < fields.size(); i++) {
    var ed = fields.get(i).getED();
    gs.info(ed.getName() + ' | ' + ed.getLabel() + ' | ' + ed.getInternalType() + ' | mandatory ' + ed.isMandatory());
}
```

`x_example_table` is invented. `getFields()` is listed in [[GlideRecord API Reference]] (global).

## Related

- [[Tables, Records and Table Relationships]] · [[GlideRecord API Reference]] · [[Server Utility APIs (ArrayUtil, JSUtil, GlideStringUtil, GlideRecordUtil)]]
