---
type: how-to
tags: [how-to, forms-lists, task]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Form administration", topic "Process flow formatter" (pp. 769-770), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Create a process flow formatter

**Goal:** show the stages of a process as a bar at the top of a form, with the current stage highlighted.
**Prerequisites:** role admin. The Process Flow Formatter plugin active.
**Navigation:** All > System UI > Process Flow

## Steps

1. Open **All > System UI > Process Flow** and select **New**.
2. Set **Table**, **Name**, **Label** (the text shown), **Order** (lowest on the left) and **Active**.
3. In **Condition**, define when this stage is the current one. Any field in the condition builder can be used.
4. Submit, and repeat for each stage.
5. Add the process flow formatter to the form through the form layout.

## Result / how to check it worked

Open a record: the stage whose condition matches is highlighted and the earlier stages show a check mark.

## Example

On a custom task table: *Draft* (order 100, **State is Draft**), *In review* (200, **State is Review**), *Done* (300, **State is Closed**).

## Tables / fields involved

- `sys_process_flow` (Flow Formatter): one record per stage

## Gotchas

- An inactive stage does not appear in the bar.
- Stages show only if the formatter has been added to the form.
- Background: [[Formatters]].
