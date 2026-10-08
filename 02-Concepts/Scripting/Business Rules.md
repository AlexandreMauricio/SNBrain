---
type: concept
tags: [concept, scripting, business-rule, glide-api, javascript, automation]
status: documented
source: ServiceNow docs, Australia, Build workflows > Classic Business rules (read 2026-10-08 through the docs site; one page): how business rules work, prevent recursive business rules, business rules in scoped applications, create a business rule, global variables, business rules and client scripts, using NULL, display business rules, Task Active State Management, example scripts (compare dates, parse XML, abort action, operation, OR condition, glide list, lock user accounts, before-query rule). https://www.servicenow.com/docs/r/australia/build-workflows/business-rules-classic/c_BusinessRules.html
sn-release: Australia
verified:
updated: 2026-10-08
---

# Business Rules

**In one line:** a business rule (`sys_script`) is a **server-side** script that runs when a record is displayed, inserted, updated or deleted, or when a table is queried, whatever the entry point (form, list, import, web service).

ServiceNow now calls them *classic*: new automation should be a flow ([[Flows, Subflows and Actions Overview and Architecture]]), but every instance is full of them. Position among the other engines: [[Order of Execution for Rules, Engines and Notifications]].

## When it runs

| **When** | Runs | Typical use |
|---|---|---|
| **before** | after submit, before the database write | set or validate fields on `current`; abort |
| **after** | after the write | update *related* records; queue events |
| **async** | later, from a scheduled job created at submit | slow work that the user should not wait for |
| **display** | after the read, before the form is shown | fill `g_scratchpad` for client scripts |

Combined with the operations **Insert**, **Update**, **Delete**, **Query**.

- **Query** rules are normally *before* rules and run only for the table queried, not for tables reached through reference fields.
- Async rules have no `previous`, so `changes()`, `changesTo()` and `changesFrom()` do not work in the *script*; they do work in the filter condition and the **Condition** field. Property `glide.businessrule.async_condition_check` = true re-checks the condition just before the job runs.
- Several async rules, or quick successive updates, can run out of order and overwrite each other: use *after* rules or events when order matters ([[Events and the Event Queue]]).
- Newly created async rules also run during upgrades.
- Business rules run only for operations made through GlideRecord. `setWorkflow(false)` skips them, and some applications write directly on purpose.
- They do not enforce ACLs unless the script asks for it.

## The form

**System Definition > Business Rules** (tick **Advanced** to see everything).

| Field | Meaning |
|---|---|
| **Name**, **Table**, **Application**, **Active** | a database view can only have Query rules |
| **Accessible from** | only when Table is Global |
| **When**, **Order** | lowest order first; set an order on async rules too (used for the job) |
| **Insert**, **Update**, **Delete**, **Query** | Delete and Query are on the advanced form |
| **Filter Conditions** | condition builder; string comparisons are case-sensitive |
| **Role Conditions** | roles the acting user must hold |
| **Set field values** | field, *To* (a value) / *Same as* (another field) / *To (dynamic)*, value |
| **Add message** | a message shown to the user |
| **Abort action** | cancels the write; then only a message is still possible |
| **Condition** | a JavaScript condition, evaluated together with the filter conditions. Leave empty when the test lives in the script |
| **Script** | runs when the conditions hold |
| **Versions** (related list) | compare and revert |

So setting values, showing a message and aborting need no script.

## Script variables

| Variable | Is |
|---|---|
| `current` | the record as it is now |
| `previous` | the record before the first update or delete of this transaction. Update and delete only; null in async rules |
| `g_scratchpad` | display rules only: values sent to the client with the form |
| `gs` | GlideSystem |

All three record variables are shared by every rule of the transaction. Variables you declare at the top level are global too and leak into the next rule: always wrap code in a function (the template does).

```javascript
// Business rule script: server-side, before insert/update on a custom table, global scope
(function executeRule(current, previous /*null when async*/) {
    if (current.u_start.nil() || current.u_end.nil())
        return;
    var start = current.u_start.getGlideObject().getNumericValue();
    var end = current.u_end.getGlideObject().getNumericValue();
    if (start > end) {
        gs.addInfoMessage('Start must be before end');
        current.u_start.setError('Start must be before end');
        current.setAbortAction(true);
    }
})(current, previous);
```

The docs give this pattern for global scope and warn it may need changes in a scoped application.

## Rules of thumb

- **Never `current.update()`** in a business rule: it re-triggers the insert and update rules (the system detects and stops the recursion, and logs it). A *before* rule's changes to `current` are saved automatically; an *after* rule should touch other records. `setWorkflow(false)` plus `update()` is a last resort.
- `current.setAbortAction(true)` stops only the database action: the rest of the script and later rules still run. `isActionAborted()` tells them. It is ignored when the rule is in a different scope from the record's table.
- `current.operation()` returns `insert`, `update` or `delete` for rules covering several operations.
- Guard against a null `current` or `previous` before using them.
- `NULL` in capitals is reserved and means "clear this field"; do not use it as data (imports turn it into empty; in a reference field it is just the text NULL).
- For task tables, react to `current.active.changesTo(false)` rather than writing your own "state means closed" logic: rule *Task Active State Management* (order 50, on state change) already sets **Active** (`active`) from the table's `close_states` attribute ([[State Fields and Task State Values]]).

## Display rules and g_scratchpad

Cheaper than a client-to-server call when the value is known before the form loads. Changes made to `current` in a display rule are not saved; they only change what the form shows.

```javascript
// Display business rule (server-side)
g_scratchpad.created_by = current.sys_created_by;
```

```javascript
// Client script (browser), same form
if (g_scratchpad.created_by == 'example.user') {
    // adjust the form
}
```

## Before-query rules

Add conditions to every query on the table: row-level restriction without ACLs. The shipped *incident query* rule shows callers only their own incidents:

```javascript
// Business rule "incident query": server-side, before query on incident, global scope
if (!gs.hasRole('itil') && gs.isInteractive()) {
    var u = gs.getUserID();
    current.addQuery('caller_id', u).addOrCondition('opened_by', u).addOrCondition('watch_list', 'CONTAINS', u);
}
```

ACLs can restrict the same thing; a query rule hides the rows without the "rows removed by security" message (general knowledge, not from this page).

## Scripting snippets from the docs

| Need | Pattern |
|---|---|
| OR in a query | `var qc = gr.addQuery('priority', '1'); qc.addOrCondition('priority', '2');` Two such variables give (A or B) and (C or D) |
| glide list (for example **Watch list** `watch_list`) | `current.watch_list.toString().split(',')` gives sys_ids; `getDisplayValue()` gives names. On an empty list `indexOf()` returns undefined: call `toString()` first or test `nil()` |
| XML in a field | `gs.getXMLText(current.payload, '//name')` |

## Scope

- A rule belongs to an application scope. On a table of **another** scope only two kinds are allowed: *async* (insert, update, delete; set field values and script) and *before* (insert, update, delete; set field values only, no script, no abort). Never Query.
- Scoped rules use the scoped APIs and can call script includes of their own scope or those open to all scopes (prefix the scope).
- **Global business rules** (Table = Global) load on every page and are callable from other scripts; **Accessible from** limits callers. They ignore domain separation. Use a script include instead.

## Business rule and client script together

Client scripts and UI policies act only on forms, so list editing, imports and web services bypass them. Anything that must hold for the data needs a business rule (or an ACL); the client script only adds the immediate feedback. Examples from the docs: an email address built by a client script is not built for imported users until a business rule does it; a field hidden by UI policy is still editable in a list until an ACL blocks it. See [[UI Policies]].

## Related

- [[Order of Execution for Rules, Engines and Notifications]] · [[Events and the Event Queue]] · [[UI Policies]] · [[Flows, Subflows and Actions Overview and Architecture]]
