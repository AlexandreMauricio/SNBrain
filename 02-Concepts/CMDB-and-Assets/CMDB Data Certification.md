---
type: concept
tags: [concept, cmdb, data-integrity, data-management, workspace, domain-separation]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB data management > "Data Certification" with its topics (experience in a workspace, retention, convert legacy schedules, dashboard, review tasks, failed tasks, reset, run on demand) (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/cmdb-data-management-landing.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# CMDB Data Certification

**In one line:** certification asks reviewers, on a schedule, to confirm that **specific field values are correct** on specific records, for audit or regulatory reasons. In Brazil it is the *Certification* policy type of [[CMDB Data Manager]], and works on CMDB **and non-CMDB** tables.

Attestation asks "does this CI exist?"; certification asks "are these values right?" ([[CI Attestation]]).

- Example: certify Operating System and CPU count on all Windows servers in one city, assigned automatically to the right team.
- Usable on domain-separated instances.
- No exclusion lists for this policy type.
- The workspace version has no merging of certification tasks and no escalation (features of the legacy application).

## Policy settings specific to certification

Set in [[Create a CMDB Data Manager Policy]]: **Certification fields** (to verify), **Display fields** (only to identify the record), **Allow field updates**, **Allow empty field values**, **Days to complete**, **Instructions**, and the fallback when the assignment field is empty.

## Dashboard

**Workspaces > CMDB Workspace > Tasks > Certification**. `data_manager_user` sees tasks assigned to them, their groups and the people or groups they manage; `data_manager_admin` sees all.

| Tab | Shows |
|---|---|
| **Certification tasks** | every task with progress, percent complete and state (Not Started, Past Due...) |
| **Certification instances** | one card per policy run (a *certification instance* = the tasks of one policy execution, number `PLCEXEC...`): total, complete, open, unassigned tasks; **Certification records** filtered by Certified or Failed |
| **Workload and Aging tasks** | work by group and by person; past-due tasks by age (61 to 90 days, over 90) |

## Reviewing a task

Roles `sn_cmdb_user`, `sn_cmdb_editor` or `sn_cmdb_admin`.

1. Open the task. Wrong assignee: **Reassign** (group, user, reason), **Assign to me**, or **Request reassignment**. Several tasks can be reassigned at once.
2. Tab **Review not completed**: select records > **Certify** or **Fail** for a bulk verdict (applies only to fields not yet reviewed).
3. Or **Review records** for detail: columns with a check mark are certification fields; then per field **Certify selected fields**, **Fail selected fields**, or **Edit fields** > **Update** and certify.
4. Records move to **Review completed**. **Submit** becomes available when every record is reviewed.

- If the policy disallows empty values, a record with an empty field can only be failed until the field is filled.
- If the policy disallows updates, wrong values can only be failed.
- **Reset** (role `data_manager_user`; at least one field already reviewed) sets every result back to not reviewed and removes comments. **Field values already changed stay changed.**
- Admins can **Cancel task** while Not started or In progress.
- **Failed fields** (role `sn_cmdb_admin`): the same page lists, per task, the records and fields that failed; **Certification Document Id** links to the record, **Element** names the field.

## Converting legacy certification schedules

Schedules of the old Core UI Data Certification application (`cert_schedule`) can become **draft** certification policies. Role `data_manager_admin` or `sn_cmdb_admin`.

1. Data Manager overview > **Import** on the banner (shown only if there are schedules to import) > **Import into draft policies**.
2. Read the import summary; `cert_schedule.list` columns **Migration Status** and **Migration exception** explain skipped or failed ones.
3. **View draft policies** > review > publish.

- Converted schedules are **deactivated**. Legacy tasks are left as they are.
- Not migrated: **Assign to empty** and **Last run date**. Dot-walked assignment fields are kept.

## Retention

Certification executions are archived 2 years after creation and destroyed 7 years after archiving; they are exempt from the routine cleanup that applies to other policy types. Details in [[CMDB Data Manager Reference - Notifications, Properties, Jobs, Tables and Roles]].

## Run on demand

Data Manager > **Policies** > **Published policies** > the policy > **Run Policy** > **Run** (role `sn_cmdb_admin`; one at a time, not while running).

## Related

- [[CMDB Workspace]]
