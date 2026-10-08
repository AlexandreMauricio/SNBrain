---
type: concept
tags: [concept, data-management, data-integrity, security, cmdb, admin, roles, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Platform Security > Auditing (whole chapter, 25 topics, 791 cleaned lines, read in full 2026-10-08 through the docs site) - Exploring Auditing, Configuring auditing for a table (inclusion and exclusion listing, impersonation tracking, system tables), Audit Management Console and retention, Viewing Sys Audit and Audit Relationship Change tables, History sets, differences between audit and history sets, access to history, number of entries, History List, Calendar and Timeline (related records, export, compare), tracking reference field changes, inserts and CI relationships, granular admin roles. https://www.servicenow.com/docs/r/platform-security/c_AuditedTables.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Auditing and Record History

**In one line:** when a table is audited, every field change is written to the Audit table (`sys_audit`): record, field, old value, new value, who, when; the **History** a user opens on a record is a short-lived working copy built from those rows.

From the Brazil docs. Steps: [[Enable Auditing on a Table]]. The logs, which are something else: [[System Logs, Log Files and Protected Tables]]. Recovering deleted records: [[Restore a Deleted Record]]. Dictionary attributes: [[Dictionary Attributes Reference]].

## What is audited

- Only tables with **Audit** ticked on the table's dictionary record (the *collection* row). Incident, change, problem and others are audited by default.
- **Not inherited**: auditing `cmdb_ci` audits records whose class is exactly that table; auditing `cmdb_ci_computer` audits computers, including their inherited fields.
- All fields of an audited table, unless narrowed (below). **Encrypted fields are never audited.**
- **Inserts are not audited** by default (they would be over 80% of the table): `glide.sys.audit_inserts` = true changes that.
- Deletions: audited from forms, lists, scripts and jobs, unless the table has attribute `no_audit_delete` or is listed in `glide.db.audit.ignore.delete` (a default list of technical tables; **adding the property replaces the built-in list**, so copy the defaults first). Tables starting `sys_` only if named in `glide.ui.audit_deleted_tables` (**System Properties > UI Properties**).

Not audited even on an audited table:

- changes made by upgrades, update set commits, XML imports and **import sets**;
- fields with attribute `no_audit`;
- system fields (`sys_...`) except `sys_class_name` and `sys_domain_id`;
- touches by inactivity monitors; some updates triggered by UI pages; manual Performance Analytics score changes.

So a record can show 132 updates and seven audited ones.

## Narrowing the fields

| Approach | How |
|---|---|
| Exclusion list (audit most fields) | attribute `no_audit` on each field to skip. Skipping journal fields breaks the activity formatter |
| Inclusion list (audit a few fields) | attribute `audit_type=whitelist` on the table's collection row, then `audit=true` on each field to keep |

High-volume tables (workflow contexts, Event Management alerts) should only ever be audited by inclusion list; `em_alert` cannot be audited as a whole.

**Audit Management Console** (**All > Audit Management Console**, `admin`): tabs for tables with audit enabled, disabled, or all; per table an **Audit** toggle, **Edit Audit Status** to choose columns, and a **Retention** tab.

## Retention

Audit rows are meant to be kept indefinitely. Since the console, a per-table policy can purge them (role `security_admin`): **Automatically Purge Audit Records** + **Duration**; **Generate Estimate** shows roughly how many rows would go (needs `com.glide.stats.table_stats.data_source` = `information_schema` and `com.glide.stats.storage_disk_usage.information_schema` = true). **Purged audit data cannot be restored.**

## The tables

| Table | Holds |
|---|---|
| Audit (`sys_audit`) | **Table name**, **Field name**, **Document key** (sys_id of the record), **User**, **Old value**, **New value** (references as sys_ids, dates in UTC), update count, reason, checkpoint id |
| Audit Relationship Change (`sys_audit_relation`) | changes of relationships between audited records and their sources, including deletions |
| Audit Delete (`sys_audit_delete`) | snapshots of deleted audited records |
| History Set (`sys_history_set`) | one per record whose history was built: **ID**, **Table**, **Load Time** |
| History (`sys_history_line`) | the lines: **Label**, **Old**, **New**, **Type** (field, email, relationship), **Update Number** (-1 = creation or deletion), **Update Time**, **User Name** |
| `sys_journal_field` | journal entries (comments, work notes) |

- Business rules and workflows do not run on inserts into `sys_audit`.
- **History sets are disposable**: built when a record is created or its history is opened; sets untouched for 30 days are removed by the table cleaner, and the lines rotate through four weekly tables (at most 21 days). They are rebuilt from `sys_audit` on demand. **Do not report on history sets.**
- Since Brazil audit rows are written **in the same transaction** as the change, so a cancelled transaction no longer loses them. Property `glide.db.audit.lazy` (now false by default) restores the old background behaviour if it exists and is true: delete it.
- `glide.audit.track_impersonation` = true records the real user as well as the impersonated one ([[Impersonation]]).

## Viewing history

Form context menu **History**:

| View | Shows |
|---|---|
| **List** | one row per change; needs auditing on the table, a role listed in `glide.history.role` (default `itil`), and read access to `sys_history_set` (admin by default: add an ACL for others) |
| **Calendar** | days with changes, coloured per user; highlight one field's changes |
| **Timeline** (configuration items) | bubbles for change sets, baselines and proposed changes; zoom, property filter, summary and detail snapshots, related records' timeline, export of a snapshot (XML, PDF), compare two points in time. A relationship change counts as valid only if made through change management or proposed changes |

- `glide.history.max_entries` (250): entries shown. Fields a user cannot read are left out of their view.
- CI relationship changes appear in the history of both CIs; switch off by not auditing `cmdb_rel_ci`, `cmdb_rel_user_type` (as printed), `cmdb_rel_group`.
- A reference field stores a sys_id, so renaming the referenced record (a user changing name) rewrites history's display: to preserve the old name, create a new user record and deactivate the old one, or keep the old name in custom fields.

## Roles

| Role | Access |
|---|---|
| `audit_viewer` | read `sys_audit`, `sys_journal_field`, `sys_history_set` |
| `audit_admin` | write and delete on `sys_audit` (avoid manual edits; use jobs for bulk deletion) |

## Related

- [[Enable Auditing on a Table]] · [[System Logs, Log Files and Protected Tables]] · [[Dictionary Attributes Reference]] · [[Table Cleaner]] · [[Restore a Deleted Record]] · [[Impersonation]] · [[Log Export Service (LES)]] · [[Journal Fields]]
