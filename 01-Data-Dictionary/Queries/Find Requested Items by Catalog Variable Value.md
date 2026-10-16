---
type: query
tags: [query, service-catalog, glide-api, encoded-query]
status: documented
source: ServiceNow docs, Brazil, API implementation and reference > Scripting > "Querying tables in script", section "Querying Service Catalog Tables", https://www.servicenow.com/docs/r/api-reference/scripts/c_UsingGlideRecordToQueryTables.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Find requested items by catalog variable value

**Purpose:** list the RITMs whose catalog variable has a given value (variables are not columns of `sc_req_item`, so a normal filter cannot do it).
**Kind:** GlideRecord (and the equivalent encoded query)
**Where to run:** Scripts - Background, a fix script, or any server script; the encoded query also works as a list filter on **Variable Ownership** (`sc_item_option_mtom.list`)
**Read-only:** yes
**Scope:** global (the docs example); should also work scoped with `gs.info`

```javascript
// Scripts - Background, read only
var own = new GlideRecord('sc_item_option_mtom');
own.addQuery('sc_item_option.item_option_new.name', 'example_variable'); // variable Name
own.addQuery('sc_item_option.value', 'example_value');                   // stored value (sys_id for references)
own.query();
while (own.next()) {
    gs.info(own.request_item.number);
}
```

```text
sc_item_option.item_option_new.name=example_variable^sc_item_option.value=example_value
```

## Notes

- `sc_item_option_mtom` links an answer (`sc_item_option`) to its RITM (`request_item`); `sc_item_option.item_option_new` is the variable definition ([[item_option_new]]), `sc_item_option.value` the answer. Column names from the docs example.
- Values are stored as text: choice variables store the choice **value**, references the sys_id, check boxes `true` / `false`.
- Record producer answers are in `question_answer` instead, and MRVS rows in `sc_multi_row_question_answer`; this query does not see them.
- On one RITM it is simpler to read `ritm.variables.<name>` ([[Scripting with Catalog Variables]]).
- Large instances: the dot-walked conditions join three tables; add a date or catalog item condition on `request_item` to keep it fast.

## Tables touched

- `sc_item_option_mtom`, `sc_item_option`, [[item_option_new]], `sc_req_item`
