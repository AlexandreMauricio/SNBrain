---
type: troubleshooting
tags: [troubleshooting, access-control, security, roles, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Access Control Lists (ACLs) (read in full 2026-10-08) - ACL debugging tools, ACL troubleshooting reference, ACL configuration watcher, Show ACL execution plan, Explore Access Control Lists (deny by default, pre and post query checks). https://www.servicenow.com/docs/r/platform-security/access-control/r_ACLTroubleshoot.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# ACL Not Working as Expected

**Symptom:** a user cannot see or edit a record or field they should (or can when they should not); a custom ACL seems ignored; a field shows in a list but not in the form; an error appears when calling a client-callable script include or processor.
**Cause:** almost always one of the rows below: another ACL earlier in the processing order, a table ACL failing before the field ACL is reached, a duplicate ACL, or an ACL that denies everyone because it is empty or names roles that do not exist.
**Fix:**

| Symptom | Likely cause | Do |
|---|---|---|
| Nobody but admins can open a **custom table** | no table ACL of its own, so the `*` table rule applies (admins only under default deny) | create table ACLs for the table ([[Create an ACL]]) |
| A custom ACL has no effect | a more specific ACL is matched first, or the user fails another requirement of the same ACL | debug; check the execution plan |
| A **field** ACL has no effect | the user fails the **table** ACL, or a duplicate field ACL lets them through | debug the field |
| A **table** ACL has no effect | a duplicate, or an ACL higher in the order (table before parent before `*`) | debug the table |
| Field visible in the list, not in the form (or the reverse) | condition or script evaluates differently: before the query only roles are checked, after it conditions and scripts too | make condition and script behave the same in both |
| Error running a processor or client-callable script include | an execute ACL the user does not meet | fix the ACL or the user's roles |
| A user **lost** access they had | the ACL's roles no longer exist on the instance: the ACL now denies everyone | **Access Management > Access Findings** > *Access Checks* lists such ACLs; correct the roles |
| An ACL script on a reference field is ignored | `glide.sys_reference_row_check` is false (default) | set it to true (performance cost) |
| Admin is blocked although **Admin overrides** is ticked | another ACL on the same field has it cleared and `glide.security.admin.override.accessterm` is false | set the property to true |

## How to confirm the cause

1. **System Security > Debugging > Debug Security Rules** (as admin), then impersonate the affected user ([[Impersonation]]). Reading the ACL tables still works while impersonating (`glide.security.access_acl_as_impersonator`).
2. A bug icon appears beside each field that has ACLs: click it for the rules and results.
3. At the bottom of the form or list, one line per evaluated ACL:

| Part | Meaning |
|---|---|
| TIME | time spent |
| PATH | `<type>/<name>/<operation>` |
| CONTEXT | the object evaluated |
| RC | true = passed |
| RULE | pass or fail per criterion: **IAccessHandler** (an internal platform check that can grant or deny before any ACL and cannot be changed), **Roles**, **Condition**, **Script** |

Icons: green tick passed, red cross failed, grey circle not evaluated, blue = result taken from cache. Click an ACL name to open it.

4. On a record-type ACL: **Show ACL Execution Plan** shows what runs for the table and field, with overridden ACLs struck through.
5. For "who can access what" without impersonating: [[Access Analyzer, Access Findings and Access Observer]].

## Related

- [[Access Control Lists (ACLs)]] · [[Create an ACL]] · [[Access Analyzer, Access Findings and Access Observer]] · [[Scripting Governance Tool]] · [[Impersonation]] · [[Role Management]]
