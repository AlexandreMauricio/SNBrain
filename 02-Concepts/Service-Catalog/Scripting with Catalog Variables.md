---
type: concept
tags: [concept, service-catalog, scripting, glide-api, business-rule]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog > Configuring > Service Catalog scoping, topic "Referencing Service Catalog variables in server-side scripts", https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/c_ScriptableServiceCatalogVariables.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Scripting with catalog variables (server-side)

**In one line:** on a RITM, catalog task or produced record, `current.variables.<name>` reads and writes answers; `variables.getElements()` lists them as GlideElementVariable objects, with an extra API for multi-row variable sets.

Runs server-side, in global or scoped applications (the page says both work), for example in business rules, flow script steps, fix scripts or Scripts - Background.

## Reading and writing

```javascript
// Read (any server script with current = sc_req_item, sc_task or a produced record)
gs.info(current.variables.original_number);
gs.info(current.variables.caller_ref.getDisplayValue()); // reference variable: display value

// Variable inside a set: both forms work
current.variables.asset_tag;
current.variables.example_set.asset_tag;

// Write: only in a BEFORE business rule (after rules do not save variable changes)
current.variables.name = 'Auto-generated: ' + current.variables.asset_tag;
```

- The variable must have a **Name**. Duplicated names overwrite each other silently.
- Date/Time variables are stored in GMT like any date field.
- Variable set roles override the roles of the variables inside.

## Listing variables of a record

```javascript
// Scripts - Background, read only
var ritm = new GlideRecord('sc_req_item');
if (ritm.get('<RITM sys_id>')) {
    var vars = ritm.variables.getElements();      // getElements(true) also returns MRVS
    for (var i = 0; i < vars.length; i++) {
        var q = vars[i].getQuestion();
        gs.info(q.getLabel() + ': ' + q.getValue());
    }
}
```

- `ritm.variables.getVariableValue()`: name/value pairs.
- `getElements()` skips formatting types (label, break, container end/split...).
- GlideElementVariable methods: `isMultiRow()`, `getQuestion()` (variables only), `getLabel()` (set title for an MRVS), `canRead()`, `canWrite()`, `getDecryptedValue()` (masked variables), `getRows()` and `getRowCount()` (MRVS only).

## Multi-row variable sets

| Operation | Code |
|---|---|
| whole MRVS as a JSON array string | `gr.variables.table_var` |
| replace all rows | `gr.variables.table_var = <JSON or array of ordered key/value pairs>` |
| one column | `gr.variables.table_var.var1` |
| row count | `gr.variables.table_var.getRowCount()` |
| one row | `var row = gr.variables.table_var.getRow(i);` |
| cell read / write | `row.var1`, `row.var1 = value`, `row.setCellValue('var1', value)` |
| add / delete row | `var row = gr.variables.table_var.addRow();`, `row.deleteRow();` |
| cells of a row | `row.getCells()` then `cell.getLabel()`, `cell.getCellDisplayValue()` |

## Example from the page, generalised

Create a computer CI from variables when a "create item" check box is ticked (server-side business rule on `sc_req_item`; writes to the CMDB, so test on a PDI first):

```javascript
if (current.variables.create_item == 'true') {
    var ci = new GlideRecord('cmdb_ci_computer');
    ci.initialize();
    ci.asset_tag = current.variables.asset_tag;
    ci.serial_number = current.variables.serial_number;
    ci.name = current.variables.name;
    ci.manufacturer = current.variables.company;
    ci.insert();
}
```

## Related

- [[Catalog Variables and Variable Types]] · [[Variable Sets and Multi-Row Variable Sets]] · [[Business Rules]] · [[Record Producers]] (the `producer` object at submit time)
