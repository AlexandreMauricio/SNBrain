---
type: concept
tags: [concept, flows, automation, roles, domain-separation, scripting]
status: documented
source: ServiceNow docs, Australia, Build workflows > Workflow Studio > Decision tables (read 2026-10-08 through the docs site; whole chapter): Workflow Studio decision tables, Exploring decision tables, Decision tables workflow, Decision Builder user interface, Filter decision tables, Configure decision tables, Create decision tables in Workflow Studio, Duplicate a decision table, Edit decision tables using draft authoring, Modify decision table structure, Modify decision table rules, Use decision tables, Manage decision tables in Excel, View related objects, Test a decision table, Create decision table code snippets, Modify decision tables in the classic UI, Delete a decision table, Filter conditions, Use enhanced reference record, Set rows active or inactive, Decision Builder system properties, Domain separation and Decision Builder. https://www.servicenow.com/docs/r/australia/build-workflows/workflow-studio/decision-designer-overview.html
sn-release: Australia
verified:
updated: 2026-10-08
---

# Decision Tables

**In one line:** a decision table (`sys_decision`) holds if-then rules as rows: **inputs** are tested by **condition columns**, and the first (or every) matching row returns its **result columns**. The logic lives outside the flow or script that asks.

Built in Workflow Studio (the former Decision Builder, part of Workflow Studio since Washington DC); once Workflow Studio decision tables are installed, tables made in the classic UI can only be edited there. Procedure: [[Create a Decision Table in Workflow Studio]].

## When to use one

- Nested if/else or switch logic, in a flow or a script.
- Rules that change often, or that a business expert rather than a developer should maintain.
- The same logic needed in several flows, playbooks or scripts.

## Structure

| Part | Notes |
|---|---|
| Properties | **Decision table name**, **Description**, **Application**, **Accessible from** (this scope or all), **Enable draft authoring** |
| **Inputs** | label, type, **Mandatory**. Types: Choice, Currency, Date, Date/Time, Decimal, Due Date, Integer, Long, Reference, String, String (Full UTF-8), True/False. More than 30 slows the editor. A Choice input can reuse a choice list only from a table in the table's own scope |
| **Condition columns** | each linked to one input, with a **Default operator** (not for True/False). A Reference input can feed several columns: **Data to evaluate** = the reference record itself or a field of the referenced table |
| **Result columns** | the same types plus Duration. Several result columns = several results per row |
| Rows (decision rules) | one operator + value per condition cell, one value per result cell. Evaluated in **Rank** order |
| **Default result** row | appears once a result column exists; returned when no row matches. Empty = nothing returned |

- **Add reference filter** on a Reference input or result limits the records offered in the cells.
- Currency and True/False result cells always return something (0.00, false) when left empty; and as soon as any column has a default result, they get one too. Currency results are converted to the session currency on save in multi-currency instances.
- **Decision rule view** (row menu > *Open in Decision rule view*) allows conditions that do not fit one-cell-per-column (OR, two tests on one input). Such *advanced rows* are read-only in Excel; prefer splitting into simple rows.
- Rows can be set **inactive** (grey band): skipped at run time without being deleted.
- Changing an input's type is possible only while no condition column uses it; switching away from Choice clears the column's values; changing a result's reference table clears its values; deleting an input deletes its columns and can break callers.

## Roles

| Role | Can |
|---|---|
| admin, `decision_table_admin` | everything: inputs, columns, rows. Delegated developers get this inside their application |
| `decision_rule_author` | add, reorder, delete rows; edit condition and result values |
| `decision_result_editor` | edit result values of existing rows only |
| `decision_table_reader` | read, test, export to Excel |

## Draft and publish

- With **draft authoring** (default on new tables) a published table is changed through **Create Draft** > edit > **Save** > **Publish**. Callers keep using the published version meanwhile; a **View** toggle switches between the two.
- Publishing replaces the published version **irretrievably**: old versions are not kept.
- Without draft authoring every saved change is live at once. Turning it on for an existing table (properties, with no unsaved changes) puts the table in published state.
- **Test** (saved tables): draft or published version, first match or all matches, input values; shows the matching rows.
- **Duplicate Decision Table**: new name, scope, draft or published version, and optionally the rows (only up to 300 rows).
- **See Related Objects**: the flows, subflows and playbooks that use it (those you may not see are counted as hidden).
- Deleting a table needs admin.

## Using a table

| From | How |
|---|---|
| Flow or subflow | **Make a decision** flow logic ([[Flow Logic Reference]]); since Xanadu the table's structure can be created from inside the flow |
| Playbook | activity *Make a Decision - First Match* ([[Playbook Activities, Decisions and Variants]]) |
| Script | `DecisionTableAPI`: `getDecision()` returns the first match, `getDecisions()` all. **Create Code Snippet** (table menu, published or saved table) generates both calls ready to paste |

```javascript
// Server-side script (business rule, script include or Scripts - Background), global or scoped.
// Shape of a generated snippet; take the real sys_id and input names from Create Code Snippet.
var dt = new sn_dt.DecisionTableAPI();
var inputs = { u_category: 'network' };
var response = dt.getDecision('<decision_table_sys_id>', inputs);
var group = response.result_elements.u_assignment_group;
```

The docs page names the class and the two methods only; the namespace and the response shape above are general knowledge, to be confirmed against a generated snippet.

## Excel round trip

For large tables: **Export** (saved table) gives an .xlsx with the rows and an instructions sheet; edit; **Import**.

- Change rows only: operators and values in condition cells, values in result cells. Never headers or columns. Anything right of the result columns is ignored; anything after five empty rows is ignored.
- Edit the exported file itself (renaming is fine; pasting into a new workbook is not).
- Import validates everything first: on failure download `Error.xlsx`, fix, import that file.
- **History** sidebar lists exports and imports with user, time and the file.
- Not possible when the table has no condition column, has unsaved changes, has unsupported field types or an inactive input; and not on instances whose language is not English.
- Properties: `com.glide.decision_table.excel_hide_references` (false; true leaves reference dropdowns out of the file), `glide.ui.export.choice_list_max_characters` (80; add it to change).

## Editor behaviour

- 20 rows per page; save before changing page, reordering or filtering. A row added at the end of a page moves to the next page on save.
- Reorder by dragging or by typing a new **Rank** (press Enter).
- Column filters work on saved tables, match cell values (not operators), default operator *is*, and do not handle dynamic (relative) operators.
- An info icon on a reference value opens the referenced record in place.

## Tables from the classic UI

On first open, condition columns are created for every field the old conditions tested. Rules that use OR, test the same input or reference twice, use unsupported types or inactive inputs are shown as one merged condition expression (edited in the condition builder) and count as unsupported until simplified. Unsupported inputs and columns allow only label changes.

## Limits and domains

| Property | Default | Limits |
|---|---|---|
| `com.glide.decision_table.max_inputs` | empty = none | inputs per table |
| `com.glide.decision_table.max_questions` | empty = none | rows (decision questions) per table |

Domain separation (standard support): a table belongs to its creator's domain; a parent domain sees child tables but must switch domain to edit them.

## Related

- [[Create a Decision Table in Workflow Studio]] · [[Flow Logic Reference]] · [[Workflow Studio Overview]] · [[Business Rules]]
