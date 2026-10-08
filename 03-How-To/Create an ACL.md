---
type: how-to
tags: [how-to, access-control, security, roles, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Access Control Lists (ACLs) (read in full 2026-10-08) - Configure an ACL, Create a datatype ACL, Show ACL execution plan, Use the ACL configuration watcher, Secure records in an embedded list. https://www.servicenow.com/docs/r/platform-security/access-control/t_CreateAnACLRule.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Create an ACL

**Goal:** restrict or grant one operation on a table or field (or another object) to the right users.
**Prerequisites:** role `admin` plus elevation to `security_admin`; the application picker set to the scope of the object.
**Navigation:** All > System Security > Access Control (ACL)

How ACLs are matched and evaluated: [[Access Control Lists (ACLs)]].

## Steps

1. Elevate: user menu > **Elevate role** > `security_admin`.
2. **System Security > Access Control (ACL) > New**.
3. **Type** (usually *record*; it cannot be changed later) and **Operation** (one per ACL: make one ACL each for read, write, create, delete).
4. **Decision Type**: *Allow If* to grant, *Deny Unless* to block everyone who does not meet the requirements.
5. **Name**: the table, and a field or *None* for the whole row. For a name the dropdown does not offer (a wildcard, a datatype ACL `*.[<type>]`), switch the field to manual entry.
6. Optional **Applies To**: a filter limiting which records the ACL covers.
7. Requirements (all must be met): **Requires role** (any one of the listed roles), **Security Attribute Condition**, **Data Condition**.
8. For logic a condition cannot express: tick **Advanced** and write a **Script** that sets `answer`.
9. Decide **Admin overrides** (clear it if admins too must meet the condition or script).
10. Save. The **Security Rules** window (the *configuration watcher*) shows the ACLs related to this one: green = added, blue = modified, red = removed, *Masked* = no longer effective because of your change, *Unmasked* = newly effective. Nothing is saved until you confirm.

Script (ACL script: server side, in the ACL's scope; not allowed when the table belongs to another scope):

```js
// illustrative only (not from the docs, untested)
// read ACL on an example table: the caller or anyone in the assignment group
answer = current.getValue('caller_id') == gs.getUserID() ||
         gs.getUser().isMemberOf(current.getValue('assignment_group'));
```

## Result / how to check it worked

- On a *record* ACL, related link **Show ACL Execution Plan**: tabs per operation, row-level and field-level ACLs; **Show all** adds overridden ones (struck through) and wildcards; **Show Effective** hides inherited and wildcard ones.
- **System Security > Debugging > Debug Security Rules**, then impersonate a user who should and one who should not have access ([[ACL Not Working as Expected]]).

## Example

Only members of *Example Group* holding role `x_example_reader` may read records of the custom table *Example Record* (`x_example_record`), and only *Test User*'s manager role may see the **Cost** (`cost`) field:

| ACL | Operation | Requirements |
|---|---|---|
| `x_example_record` (field *None*) | read | role `x_example_reader` |
| `x_example_record.cost` | read | role `x_example_manager` |
| `x_example_record.cost` | query_range | role `x_example_manager` (so others cannot sort or filter by cost to infer it) |

Without the first ACL, the table would fall under the `*` wildcard rules and be visible to admins only.

## Tables / fields involved

- Access Control (`sys_security_acl`): **Type**, **Operation**, **Name**, **Applies To**, **Requires role** (stored in `sys_security_acl_role`), **Data Condition**, **Script**, **Admin overrides**, **Active**. Column names are not given in the pages read (?).

## Other ways to do this

- Hiding or locking a field in the form only: UI policy or client script ([[UI Policies]]); these are not security. Enforcing mandatory or read-only on every path: [[Data Policies]].
- Restricting which rows are returned without ACLs: a before-query business rule ([[Business Rules]]) or security data filters.

## Gotchas

- An ACL with no requirement at all, or whose roles do not exist on the instance, **denies everyone**.
- A field ACL does not help if the user fails the table ACL.
- Two ACLs for the same object and operation: passing either is enough (Allow If); for Deny Unless all must pass.
- A create ACL with a data condition on a field value usually fails: the new record's fields are still empty.
- ACLs are captured in update sets; the roles they need must exist on the target.
- `current` inside a related list points at the parent record.
