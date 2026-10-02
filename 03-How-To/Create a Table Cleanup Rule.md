---
type: how-to
tags: [how-to, data-management, admin]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Data Management" (pp. 618-620, 635-636), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Create a table cleanup rule

**Goal:** delete records of a table automatically once they reach a given age.
**Prerequisites:** role admin.
**Navigation:** All > System Data Management > Data Management Console, or Data Management Policies

## Steps (console wizard)

1. In the console, select the table, then **Create rule**, type **Cleanup**, name and description.
2. **Define conditions**: pick the **Date field**, enter the waiting time (years, days, hours), and add conditions.
3. **Clean up associated records**: **Attachments** (always on), **Journals**, **Audits**, and optionally **Cascade delete**.
4. **Rule summary**: review, tick **Activate the rule upon creation**.

## Steps (Core UI form)

1. Console **New cleanup rule**, or in the table's policy select **New** under **Table Cleanup Rules**.
2. Fill the Auto Flush form: **Tablename**, **Matchfield**, **Age in seconds**, **Conditions**, **Clean journals**, **Clean audit**, **Cascade delete**, **Active**. Submit.

## Result / how to check it worked

The hourly table cleaner job deletes matching records. Watch **Records in backlog** and the execution history for the rule in the console.

## Example

Rule on a custom table `u_example_log`: match field `sys_created_on`, age 7,776,000 seconds (90 days), condition **Active is false**, **Clean journals** and **Clean audit** ticked.

## Tables / fields involved

- [[sys_auto_flush]]: the rule

## Other ways to do this

[[Approaches to Deleting Many Records]]

## Gotchas

- The policy and the rule must both be active.
- Deletes do not trigger business rules, workflows or flows.
- Index the match field: a query over 30 seconds stops the whole job and benches the rule for two days.
- Not for tables with table rotation. More in [[Table Cleaner]].
