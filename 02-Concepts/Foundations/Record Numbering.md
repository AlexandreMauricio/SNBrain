---
type: concept
tags: [concept, fields, task, platform, business-rule]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Field administration", topic "Record numbering" (pp. 813-818), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Record numbering

**In one line:** tables such as Incident, Problem, Change Request and Knowledge get automatic numbers (`INC0001001`) from a per-table number format in Number (`sys_number`) and a counter in Counter (`sys_number_counter`).

## How it works

- **All > System Definition > Number Maintenance**: one number format per table.

| Field | Meaning |
|---|---|
| **Table** | the numbered table |
| **Prefix** | e.g. `INC`, `CHG` |
| **Number** | base number, default 1000. Raising it above the current counter moves the next number up; the counter never goes back down to a lower base |
| **Number of digits** | minimum digits after the prefix, default 7, padded with zeros. Numbers grow past it when needed |

- **Show Counter** related link shows the current counter.
- If the table has no numbered field, saving the format creates **Number** (`u_number`) with default value `javascript:getNextObjNumberPadded();`.
- The number is produced by the field's default value script:
  - `getNextObjNumberPadded()`: **renumbers existing records** when Number of digits changes.
  - `getNextObjNumber()`: does not.
- Resetting numbering only affects new records.
- Number records may not travel automatically when an application is moved between instances.

## Gaps and duplicates

- By default a number is taken when a new record form is **opened**, so abandoned forms leave gaps. `glide.itil.assign.number.on.insert` = true (**System Properties > System**, *Assign a task number only upon insert*) takes it on save. An aborted insert still consumes a number.
- **Uniqueness is not enforced by default.** Options: a before-insert business rule that checks for the number and takes the next one, or a unique index on the table (which blocks the insert with an error instead).

Guide's business rule pattern (before, insert only):

```javascript
var curNum = current.number + '';
if (curNum) {
    var recordClass = current.getRecordClassName();
    var gr = new GlideRecord(recordClass);
    gr.addQuery('number', curNum);
    gr.setLimit(1);
    gr.query();
    if (gr.getRowCount() > 0) {
        current.number = getNextObjNumberPadded();
    }
}
```

## Left padding

- Task tables: set the Number field's default to `javascript:getNextObjNumberPadded();`, then set **Number of digits** in Number Maintenance. Applied to existing and new records.
- Custom tables or tables not extending task: first copy the business rule *Pad Numbers* and the script include *NumberManager* (as `UNumberManager`, using `u_number`), as described in the guide.

## Where it lives in the data

- `sys_number`: the format per table
- `sys_number_counter`: the next number
- [[task]]: **Number** (`number`), the display value of task tables

## Gotchas

- **Changing Number of digits can rewrite the numbers of all existing records** on the table. Be careful on production.

## Related

- [[Field Administration]] · [[Create a Table]] (Auto-number option)
