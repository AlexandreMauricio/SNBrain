---
type: concept
tags: [concept, scripting, business-rule, automation, notifications, flows, workflow]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration", topic "Precedence between data lookup, assignment, and business rules" (pp. 528-529), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Order of execution for rules, engines and notifications

**In one line:** around every database operation (insert, update, delete) the server runs before-rules, engines, the operation, after-rules, more engines and notifications in a fixed sequence, and business rule **order 1000** is the dividing line.

## The sequence

Client-side code (client scripts, Ajax) always runs first, before the form is submitted to the server.

1. **Before business rules with order below 1000.**
2. **Before engines** (no fixed order among them):
   - Approval engine (task and `sys_approval_approver` tables)
   - Assignment rules engine (task tables)
   - Escalation engine
   - Data policy engine
   - Field normalization engine
   - Role engine (keeps `sys_user_has_role` in sync; for `sys_user`, `sys_user_group`, `sys_user_grmember`, `sys_user_role`)
   - Execution plan engine (task tables)
   - Update version engine (creates a version when `sys_update_xml` is written)
   - Data lookup engine
   - Workflow engine, for **default** workflows
3. **Before business rules with order 1000 or higher.**
4. **The database operation.**
5. **After business rules with order below 1000.**
6. **After engines** (no fixed order among them): label engine, listener engine, table notifications engine, role engine, text indexing engine, update sync engine, workflow engine for **deferred** workflows, trigger engine for all Workflow Studio flows.
7. **Email notifications**, by the weight of the notification record: those sent on insert, update or delete, then event-based ones.
8. **After business rules with order 1000 or higher** (active records only).

**Async business rules** also run after the operation, but in the background: the system creates a scheduled job when the form is submitted (before the database action), and the scheduler runs it later.

**Calculated fields** are populated before any business rule, and again after the before-rules if needed ([[Dictionary Entry Form]]).

## What follows from it

- A before-rule that must see the result of assignment rules or data lookup needs **order 1000 or higher**; one that must run before them needs an order below 1000.
- Flows (trigger engine) start after the record is written and after the low-order after-rules.
- A default workflow that assigns a task runs before the record exists in the database; the guide suggests a short Timer activity at the start so it resumes with the saved record ([[Assignment Rules and Data Lookup Rules]]).

## Related

- [[Assignment Rules and Data Lookup Rules]] · [[task]]
