---
type: concept
tags: [concept, cmdb, data-management, data-integrity, automation, workspace]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > "CMDB data management", topics "Working with CMDB Data Manager", "Retirement definitions", "CMDB Data Manager experience in a workspace", "Administer CMDB Data Manager" (get started, retirement definitions, exclusion lists, view policies, analytics), "Review CMDB Data Manager tasks" (https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/cmdb-data-management-landing.html and the pages under it), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# CMDB Data Manager

**In one line:** a policy-driven framework for doing CI life-cycle work in bulk: retire, archive, delete, attest, certify, and clean related tables. A policy selects CIs, creates tasks per owning group, optionally waits for approval, then a subflow does the work.

**Where:** **Workspaces > CMDB Workspace > Governance > Data Manager** (overview, Policies, Excluded records, Subflows, Analytics, Settings). Role `sn_cmdb_admin` (or `data_manager_admin`).

Policies apply to classes that extend [[cmdb_ci]] (certification also covers non-CMDB tables; *Delete CMDB Related Entry* covers tables in `cmdb_related_entry`).

## Terms

| Term | Meaning |
|---|---|
| **Policy** | the plan for one life-cycle event: type, target CIs, assignment, options, schedule |
| **Policy subflow** | the Workflow Studio subflow that does the work (delete, archive, retire are shipped; custom ones can be added under **Subflows**). Runs only after approval if the policy needs it |
| **Policy task** | one task per distinct **Managed By Group** among the target CIs (table `cmdb_data_management_task`). Holds the CI list, the approval and triggers the subflow. **At most 10,000 CIs per task**; more are split into further tasks |
| **Exclusion list** | CIs that policies of a given type never target |

## Policy types

| Type | Effect | Reversible |
|---|---|---|
| **Retire** | sets the CI to its class's retired state; the CI stays in lists and in CMDB Health | yes (edit the CI) |
| **Archive** | moves the CI to an archive table; gone from lists, maps, relation formatters. Deleted from the archive after the retention time | restore during retention |
| **Delete** | removes the CI | **no** |
| **Delete CMDB Related Entry** | deletes orphan or stale rows in related tables such as `cmdb_serial_number` | no |
| **Attestation** | tasks asking owners to confirm the CI really exists ([[CI Attestation]]) | |
| **Certification** | tasks asking reviewers to confirm attribute values ([[CMDB Data Certification]]) | |

Examples from the docs: retire computers without an owner created over a year ago; archive Linux servers in one datacenter not updated for six months; delete containers not discovered in the past week.

## Retirement definitions

What "retired" means for a class: a condition such as *Operational status is Retired*. Table **CMDB Retirement Custom Definitions** (`cmdb_retirement_custom_definitions`).

- **Required**: every class targeted by a Retire, Archive or Delete policy needs an **active** definition, or creating the policy fails.
- Used three ways: a Retire policy **sets** CIs to the definition; it skips CIs that already match; **Archive and Delete only touch CIs that match** (they must already be retired). A filter on Life Cycle Stage in such a policy has no effect if the definition is based on that attribute.
- **Inherited** like identification rules: the most specific definition up the class tree applies.
- The definition for `cmdb_ci` is **active, cannot be deactivated or deleted**, and so applies everywhere unless a class has its own. Other shipped definitions (Hardware, Application, Service...) are **inactive until activated**. Service example: Operational status, Phase and Status all Retired.
- One definition per class. Conditions can use **AND only** (the policy sets these values).
- Manage: Data Manager overview > **Manage retirement definitions** > toggle **Active**, edit, **Add definition** (Table + condition). Delete only when inactive; the class then inherits again.

## Life cycle in practice

1. Work on a non-production instance first.
2. Decide the class and its retirement definition (mind inheritance).
3. A **Retire** policy for the CIs no longer needed.
4. An **Archive** or **Delete** policy for the retired ones.
5. Move the configuration to production (policies travel in update sets and arrive as **drafts**).

Enable dependent CI management so parts of retired, archived or deleted CIs are not left orphaned: [[Dependent CI Management and Cascade Cleanup]].

## Archiving

The Archive type uses platform data archiving ([[System Archive and Archive Rules]]):

- Archive rule **Archive Configuration Items** in `sys_archive`; the hourly **Archive** job does the work.
- CIs are archived in batches of 1000 (`sys_archive_run_chunk`).
- Archive tables are named `ar_` + class, for example `ar_cmdb_ci_computer` (**System Archiving > Archive Tables**). They are created on the first run, which is therefore slower.
- Restore with the platform's restore function during retention. **A CI that was archived and restored cannot be archived again by Data Manager.**

## Approval and assignment

- **Needs review** on the policy: tasks wait for a member of the CIs' **Managed by Group**. Empty group, or a rejected task = an administrator must step in. Without it, tasks approve themselves.
- Fill **Managed by Group** per class in CI Class Manager to keep approvals flowing.
- Reviewers (roles `sn_cmdb_user` and up): **Workspaces > CMDB Workspace > Tasks**: **Approve task** (starts the subflow), **Reject task** with a reason (state Closed Canceled, approval Rejected; only your own tasks), **Reassign** (Assign to me / Request reassignment), **Review records** > **Exclude** (also adds the records to the type's exclusion list for the future). Admins can **Cancel task** while it is Not started.
- Tasks still open and unapproved after 90 days are closed as stale.

## Exclusion lists

Data Manager > **Excluded records**, grouped by policy type. **Exclude Records** > table, filter, select > choose policy types > **Save**. **Remove from list** to target them again. **Certification does not support exclusion lists.**

## Overview and analytics

Overview cards: open, unassigned, pending (for example archive still running), closed incomplete, overdue, aging (no due date and no activity for 30 days), policies failing evaluation, workload by group and by person. Policies page: timeline of upcoming runs, published / draft / deactivated / failing. Analytics: CIs processed per life-cycle type (6 months), average days to close, closed complete versus incomplete (12 months), policy execution time.

## Gotchas

- **Delete is irreversible.**
- With Asset Management active, check the linked asset is Retired (`install_status`) before retiring a CI.
- A CI can be skipped by a run because it is already in another task, or because the policy's **Run as** user cannot access it. The policy execution record's work notes say how many.

## Related

- [[Create a CMDB Data Manager Policy]] · [[CMDB Data Manager Reference - Notifications, Properties, Jobs, Tables and Roles]] · [[Duplicate CI Remediation]] · [[CMDB Workspace]]
