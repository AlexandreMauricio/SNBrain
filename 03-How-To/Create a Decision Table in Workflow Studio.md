---
type: how-to
tags: [how-to, flows, automation]
status: documented
source: ServiceNow docs, Australia, Build workflows > Workflow Studio > Decision tables (read 2026-10-08 through the docs site): Create decision tables in Workflow Studio, Test a decision table in Workflow Studio, Define default result values, Create decision table code snippets, and the Make a decision flow logic page. https://www.servicenow.com/docs/r/australia/build-workflows/workflow-studio/create-decision-table-in-decision-designer.html
sn-release: Australia
verified:
updated: 2026-10-08
---

# Create a Decision Table in Workflow Studio

**Goal:** replace a chain of If blocks (or an if/else script) with a table of rules. Concept: [[Decision Tables]]. Not tested on an instance.

**Needs:** role admin or `decision_table_admin` (or delegated developer in the application).

## Steps

1. **All > Process Automation > Workflow Studio** > **New > Decision table**.
2. Fill **Decision table name**, **Description**, **Application**, **Accessible from**; leave **Enable draft authoring** on. **Build decision table**.
3. **Add an input**: **Label**, **Type** (for Reference also the table), **Mandatory**.
4. **Add condition column** on that input: label, **Data to evaluate** (for a reference: the record or one of its fields), **Default operator**. **Done**.
5. **Add result column**: label, **Result type** (for Reference the table, optionally **Add reference filter**). **Done**.
6. Fill the first row: click each condition cell (operator + value) and each result cell.
7. **Add new decision row** for each further rule. Order matters when only the first match is used: drag rows or change **Rank**.
8. Fill the **Default result** row if "no match" should still return something.
9. **Save** > **Test**: choose first match or all matches, type input values, check which rows answer.
10. **Publish**.
11. Use it: in a flow add **Make a decision**, pick the table, fill its inputs with pills, and either build the answer branches (**Use Branches**) or use the answer record pill in the next action. In a script, table menu > **Create Code Snippet**.

To change it later: **Create Draft** > edit > **Save** > **Test** (draft) > **Publish**.

## Example

Table *Example Assignment Group by Category*.

| Part | Setting |
|---|---|
| Input | *Category*, type String |
| Condition column | *Category is*, default operator *is* |
| Result column | *Assignment group*, type Reference to Group (`sys_user_group`) |
| Rows | network > Example Network Group; hardware > Example Hardware Group |
| Default result | Example Service Desk |

Flow: trigger *incident created* > **Make a decision** (table above, input = trigger incident's Category, first match, no branches) > **Update Record** on the incident with **Assignment group** = the decision's answer. Test with an incident in each category and one in an unlisted category (expect the default).

## Related

- [[Decision Tables]] · [[Flow Logic Reference]] · [[Build a Flow in Workflow Studio]]
