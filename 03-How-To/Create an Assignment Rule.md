---
type: how-to
tags: [how-to, task, incident, automation]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration", topic "Create an assignment rule" (pp. 530-532), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Create an assignment rule

**Goal:** assign unassigned task records to a user or group automatically when they match conditions.
**Prerequisites:** role `assignment_rule_admin` or admin.
**Navigation:** All > System Policy > Rules > Assignment

## Steps

1. Open **All > System Policy > Rules > Assignment** and select **New**.
2. Set **Name** and **Active**.
3. **Applies to**: choose the **Table** and build the **Conditions**. **Match conditions** can be Any or All.
4. **Assign to**: set **User** and/or **Group**.
5. Or use **Script**: it must evaluate to the sys_id of a user or group. `current.variable_pool` is available.
6. Set **Execution Order** if several rules could match (lowest wins; only one rule runs).
7. Submit.

## Result / how to check it worked

Create a record that matches and has no assignee or group, save it, and check **Assigned to** and **Assignment group**.

## Example

Rule *Example Network Routing* on Incident (`incident`), condition **Category is Network**, **Group** = *Example Network Team*. A new network incident saved without an assignment group lands with that team.

## Tables / fields involved

- [[task]]: **Assigned to** (`assigned_to`), **Assignment group** (`assignment_group`)

## Other ways to do this

[[Approaches to Auto-Assigning Tasks]]

## Gotchas

- Runs only on save, only when both assignment fields are empty, and never overwrites ([[Assignment Rules and Data Lookup Rules]]).
- The table list only shows tables and database views in the rule's scope.
- For a **custom table extending task**, the rule works only after the instance cache is cleared (`cache.do`). Cache flushes degrade performance: not during business hours.
- In a script, return the type the field expects; a mismatch gives unexpected results.
