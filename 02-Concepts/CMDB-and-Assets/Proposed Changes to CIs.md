---
type: concept
tags: [concept, cmdb, change, data-integrity, scripting, javascript]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > Managing proposed changes (one topic, read in full through the docs site API 2026-10-29; the page URL redirects to the capabilities landing page in the browser). https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/c_ProposedChanges.html. Scripts below are the docs samples rewritten with placeholder values; not run
sn-release: Brazil
verified:
updated: 2026-10-29
---

# Proposed Changes to CIs

**In one line:** a proposed change records field values and relationship additions or removals for a configuration item (CI) against a change request, without touching the CI, so they can be applied in one action once the change is approved.

From the Brazil docs. Steps: [[Propose, Verify and Apply a CI Change]]. The same feature in the workspace: [[Working Records in Service Operations Workspace]] (*Propose single change*). The CI timeline shows proposed changes too: [[Auditing and Record History]].

## What it does

- Prepared on a change request (or, per the docs, any task-related record) from the **Affected CIs** related list (`task_ci`, see [[change_request]]).
- What can be proposed: a new value for **any field on the CI form**, and **adding or removing a CI relationship** ([[CI Relationships]]). Changing a relationship means proposing its removal and a new one. Not valid for user and group relationships.
- **A proposed change cannot be deleted** (as the docs state it; how to drop one that is no longer wanted is not described: ?).
- The CI keeps its current data until **Apply Proposed Changes** on the change request is clicked; that applies all of that change request's proposals at once. If the change is never approved, nothing has to be reversed.
- When to apply is left to your process: the button is not tied to approval or state by the docs.
- Seeing proposals on the CI form needs the field **CMDB Scheduled Changes** added to the form layout (not shown by default); it then shows a *Scheduled changes* area, which reads "No scheduled changes found" after applying.

Roles: `sn_cmdb_editor` or `itil` to propose and apply; `personalize_form` to add the field to the form.

Trap: the proposed change form also has **Update** and **Delete** buttons, which change or delete the CI **immediately**, bypassing the proposal. Use **Save Proposed Change**.

## Proposed change verification rules

**All > Configuration > Change Verification > Proposed Change Verification Rules** (roles `asset`, `sn_cmdb_editor` or `itil`).

| Field | Meaning |
|---|---|
| **Rule name** | name |
| **Table name** | CI class the rule applies to |
| **Filter condition** | which CIs of that class |
| **Active** | on or off |
| **Rule script** | server-side script returning true (pass) or false (fail); `current.getValue('<field>')` returns the **proposed** value |

**Verify Proposed Changes** on the change request runs every active rule whose filter matches an affected CI and shows passed or failed at the top of the form. Details: related link **Proposed Change Verification Log** (the last two days). Verifying is optional and **a failure does not block applying** — it is advisory only.

```javascript
// Rule script (server side): fails unless the proposed OS is Example OS and there are at least 2 CPUs
validateRule()
{
    var os = current.getValue('os');
    var cpu = current.getValue('cpu_count');
    if (os != 'Example OS' || cpu < 2)
        return false;
    return true;
}
```

(The docs sample is written in this unusual `validateRule() { ... }` form; whether a normal `function` declaration works the same is unconfirmed.)

## Planned change validation scripts

A different thing: these judge **changes that already happened** to a CI, as shown in the CI timeline and change history, flagging each as planned (valid) or not.

**All > Configuration > Change Verification > Planned Change Validation Script** (roles `sn_cmdb_admin`, `sn_cmdb_editor`, `admin` or `itil`). Fields: **Active**, **Applies to** (class), **Script**. Several scripts may exist per class, but only one is active per class.

How a change is judged:
1. If the CI's class or a parent class (searched up the hierarchy) has an active script, its boolean result decides. A non-boolean result counts as false.
2. Otherwise the default check: the change is planned if it happened between **Work start** and **Work end** of the change request linked to the CI. The docs admit this is unreliable: a manual edit within that window also counts as planned.

Script inputs: `current` (GlideRecord), `updatedOn` (GlideDateTime), `updatedBy` (String, who or what made the change), `fieldsChanged` (String, comma-separated field names; the docs' template calls it `changedFields`, a naming discrepancy on the page).

```javascript
// Planned change validation script (server side): planned only if an admin made the change
isValidChange();
function isValidChange() {
    return isUserAdmin(updatedBy);
}
function isUserAdmin(userName) {
    var user = new GlideRecord('sys_user');
    user.addQuery('name', userName);   // docs sample matches on name; user_name may be what updatedBy holds (?)
    user.query();
    if (!user.next())
        return false;
    var hasRole = new GlideRecord('sys_user_has_role');
    hasRole.addActiveQuery();
    hasRole.addQuery('user', user.getUniqueValue());
    hasRole.query();
    while (hasRole.next()) {
        var role = hasRole.role.name.toString();
        if (role == 'sn_cmdb_admin' || role == 'admin')
            return true;
    }
    return false;
}
```

Table names for the rules, logs and scripts are not given on the page (?).

## Related

- [[Propose, Verify and Apply a CI Change]] · [[change_request]] · [[CI Relationships]] · [[Auditing and Record History]] · [[Change Management Overview and Lifecycle]] · [[Working Records in Service Operations Workspace]]
