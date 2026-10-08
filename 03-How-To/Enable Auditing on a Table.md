---
type: how-to
tags: [how-to, data-management, data-integrity, schema, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Platform Security > Auditing (chapter read in full 2026-10-08) - Configuring auditing for a table, Enable inclusion list auditing for a table, Include a table field in auditing, Exclude a field from being audited, Enable auditing for a system table, Configure auditing using Audit Management Console, History List. https://www.servicenow.com/docs/r/platform-security/t_EnableAuditingForATable.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Enable Auditing on a Table

**Goal:** record who changed which field, from what to what, on a table that is not audited yet.
**Prerequisites:** role `admin`. Know whether you want most fields (exclude a few) or only a few fields (include them).
**Navigation:** All > System Definition > Dictionary (or All > Audit Management Console)

Background: [[Auditing and Record History]].

## Steps

1. **Dictionary**: filter **Table** = your table, **Column name** empty, **Type** = Collection. Open that row.
2. Tick **Audit** > **Update**. From now on updates and deletions of every field are audited.
3. To skip some fields: open each field's dictionary record (or show the **Attributes** column in the list) and add attribute `no_audit`.
4. Or, to audit only a few fields: on the collection row add attribute `audit_type=whitelist`, then on each field to keep add `audit=true`.
5. For a `sys_` table, also add its name to **System Properties > UI Properties** > *List of system tables ... that will have the delete audited* (`glide.ui.audit_deleted_tables`), comma separated without spaces, if deletions should be audited.

The same through the **Audit Management Console**: select the table > **Audit** toggle > **Edit Audit Status** to tick or untick columns > **Save**.

## Result / how to check it worked

Change a field on a record, then open the form context menu > **History > List**: the change is listed. Or filter `sys_audit.list` on **Table name** and **Document key** = the record's sys_id.

## Example

Custom table *Example Requests* (`u_example_request`), where only **State** (`u_state`) and **Assigned to** (`u_assigned_to`) matter. Collection row: **Audit** ticked, attribute `audit_type=whitelist`. Field rows `u_state` and `u_assigned_to`: attribute `audit=true`. *Test User* moves a request to *In Progress*: `sys_audit` gets one row with field `u_state`, the old and the new value. Editing the description produces no row.

## Tables / fields involved

- Dictionary (`sys_dictionary`): **Audit** (`audit`), **Attributes** (`attributes`)
- Audit (`sys_audit`): **Table name** (`tablename`), **Field name** (`fieldname`), **Document key** (`documentkey`), **Old value** (`oldvalue`), **New value** (`newvalue`), **User** (`user`). Column names from general knowledge, not from the pages read (?)
- `sys_history_set`, `sys_history_line`: the history shown on the form

## Gotchas

- Auditing is **not inherited**: enable it on each child table whose records must be audited.
- Inserts are not audited unless `glide.sys.audit_inserts` is true; imports through import sets and update sets are not audited at all.
- Encrypted fields are never audited.
- Auditing a busy table costs performance and storage: prefer the inclusion list there.
- Non-admins see **History > List** only with a role in `glide.history.role` and read access to `sys_history_set`.
- Dictionary changes are configuration: capture them in an update set and move them like any other change ([[Update Sets]]).
