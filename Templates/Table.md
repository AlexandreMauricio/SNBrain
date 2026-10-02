---
type: table
tags: [schema]
status: unverified
source: <sys_dictionary result / script output / docs URL / own experience>
sn-release:
verified:
updated: <YYYY-MM-DD>
---

# table_name

**Label:** <UI label, e.g. Incident>
**What it stores:** <one sentence, plain language. Which module or application uses it>
**Extends:** [[parent_table]] (inherited columns are documented there)
**Extended by:** <child tables, or none>
**Scope:** global / <application scope>

## Key columns

Only columns defined on this table, plus any dictionary overrides of inherited ones.

| Label | Name | Type | Reference / choice | Meaning | Confidence |
|---|---|---|---|---|---|
| Number | `number` | string | | | verified / documented / unverified |

## Relations

- `<column>` -> [[other_table]]: <what the reference means>
- Related lists / tables pointing here: [[child_table]].`<column>`

## Choice values

<Only when a column stores coded values. List value = label, and say which instance and release they came from.>

## Useful queries

```text
<encoded query>
```

```javascript
// what this returns
var gr = new GlideRecord('table_name');
gr.addEncodedQuery('<encoded query>');
gr.setLimit(10);
gr.query();
```

## Gotchas

- <inherited fields that behave differently, state models, columns that look meaningful but aren't, etc.>

## Related

- [[Some Concept]] · [[Some How-To]]
