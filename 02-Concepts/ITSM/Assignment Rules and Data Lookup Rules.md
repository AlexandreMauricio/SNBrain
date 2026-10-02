---
type: concept
tags: [concept, task, incident, automation]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration" (pp. 527-533), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Assignment rules and data lookup rules

**In one line:** assignment rules fill **Assigned to** (`assigned_to`) and **Assignment group** (`assignment_group`) on an unassigned task when conditions match; data lookup rules can set any field and can run on form change.

## Assignment rules

An assignment rule runs only when all of this is true:

- The task record was **created or updated** (saved). Unsaved form changes do not trigger it.
- The record is **unassigned**: both `assigned_to` and `assignment_group` are empty. A rule never overwrites an existing assignment, including one from a default value or an earlier rule.
- It is the **first matching rule**: among rules whose table and conditions match, only the one with the lowest **Order** runs. With equal orders, the first match wins.

Module: **All > System Policy > Rules > Assignment**. Role: `assignment_rule_admin` or admin. See [[Create an Assignment Rule]].

Baseline examples: *Networking* (incident, Category is Network, group Network), *Service Desk* (incident, Active is true, group Service Desk), *IT Hardware* (`sc_req_item`, approved, hardware category, group Hardware).

## Data lookup rules

Data lookup and record matching improve on assignment rules:

- They can set **any field**, not only assignment fields.
- They can run **on form change** (so they apply to unsaved changes), on insert, or on update.
- They can **replace existing values**, including defaults.

Assignment lookup rules live at **All > System Policy > Rules > Assignment Lookup Rules**: match on Category, Subcategory, Configuration item and Location, and set Assignment group and Assigned to. At least one matcher and one setter field are required. See [[Create an Assignment Data Lookup Rule]].

Both kinds can exist together. Once an incident is assigned, duplicate rules are ignored unless the data lookup definition is set to replace existing values.

## Assigning from a workflow or flow

For multi-step processes (e.g. a group must approve first), assign from workflow task activities instead. Put a short Timer activity at the start of the workflow, otherwise it runs before the record is inserted.

## Where it sits in the processing order

Both engines run between the low-order and high-order before business rules: [[Order of Execution for Rules, Engines and Notifications]].

## Related

- [[task]] · [[Approaches to Auto-Assigning Tasks]]
