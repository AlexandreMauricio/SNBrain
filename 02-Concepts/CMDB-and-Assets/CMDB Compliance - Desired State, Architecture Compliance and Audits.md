---
type: concept
tags: [concept, cmdb, data-integrity, roles, reporting]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > "CMDB Compliance" with its topics (Compliance Activation, Installed with Compliance, Overview modules, Architecture Compliance, Desired State and its reporting, Certification audits, results, health windows, Certification filters, follow-on tasks, Certification templates) (https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/c_Compliance.html and the pages under it), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# CMDB Compliance - Desired State, Architecture Compliance and Audits

**In one line:** Compliance audits compare what records **are** with what a template says they **should be** (attribute values, relationships, related records), list every discrepancy and can raise follow-on tasks to fix them. Automatic, unlike [[CMDB Data Certification]], where a person confirms values.

**Where:** application menu **Compliance** (Overview, Filters, Templates, Audits, My Follow On Tasks, and sub-menus Architecture Compliance, Desired State, Scripted Audits); also [[CI Class Manager]] > class > **Health > Compliance**.

## Building blocks

| Piece | Table | What it is |
|---|---|---|
| **Certification filter** | `cert_filter` | which records to audit: a table + condition. Versioned |
| **Certification template** | `cert_template` | the expected state: a filter plus conditions. Versioned |
| Conditions | `cert_cond` (base), `cert_attr_cond`, `cert_ci_rel_cond`, `cert_user_rel_cond`, `cert_group_rel_cond`, `cert_related_list_cond` | attribute, CI relationship, user relationship, group relationship, related list |
| **Audit** | `cert_audit` | template (or script) + schedule + task assignment |
| **Audit result** | `cert_audit_result` | one row per certified record; one row **per failed condition** for a failed record |
| **Follow-on task** | `cert_follow_on_task` | work to fix a discrepancy |

## Audit types

The type is fixed by the menu the template or audit is created from.

| Type | Tables | Conditions available |
|---|---|---|
| **Compliance** | any table | attribute, related list. Attribute certification only. Templates can also feed GRC control test definitions |
| **Architecture Compliance** | `cmdb_ci` and descendants | attribute (CPU count, RAM, disk), related list |
| **Desired State** | `cmdb_ci` and descendants | attribute, **CI relationship** (Runs on, Depends on), **user relationship** (base: *Log reviewed by*), **group relationship** (base: *Backed up by*), related list |
| **Scripted** | the filter's table | a script decides ([[Scripted Compliance Audits]]) |

Desired State examples: a Linux database server with too little RAM; a wrong *Depends on* relationship; a critical service with no manager, support group or approval group; a computer lacking a licence for a product (related list condition on Software Installation).

## Activation and roles

- Plugin **Certification Core** (`com.snc.certification_core`), active by default, with **Desired State Certification** (`com.snc.certification_desired_state`, active). To activate: **Architecture Compliance** (`com.snc.architecture_compliance`) and legacy **Data Certification** (`com.snc.certification_v2`); both bring **Version Management** (`com.snc.version`).

| Role | Contains | Can |
|---|---|---|
| `certification` | | read and update own follow-on tasks; view audits, results, template versions. **Given automatically to everyone with `itil`** |
| `certification_filter_admin` | | create, read, update filters |
| `certification_admin` | both above | everything: filters, templates, audits, reassign tasks |

- `sn_cmdb_admin` also has full access to filters, templates and audits; `sn_cmdb_editor` reads.
- **`certification_admin` has few table rights of its own.** Give it roles for the tables its filters need (Company, Cost Center, Schedule...).
- Two business rules *Add Certification Role To Manager* grant `certification` to the **direct manager** of anyone who has it, so tasks can be escalated. A manager with only that role counts as a requester, not a subscribed fulfiller.

## Filters and templates

- **Versions:** saving a change to name, table or conditions creates a new active version and deactivates the previous one. Changing **Description** or **Active** does not. All versions share the record number; the default list shows active versions only. **Revert** on an old version copies it as the new active version. **Delete inactive versions** removes unused ones.
- A filter in use by a template or scripted audit cannot be deleted; a template in use by an audit cannot be deleted. Deleting the latest active version reactivates the previous one.
- **Copy:** context menu **Insert** on a filter; **Clone** on a template. New number, version 1.
- Template conditions are **all ANDed**. Save each condition with the green check mark before anything else: **updating the form does not save an open condition**. Deleting a condition marks it inactive (grey X reactivates).
- Attribute conditions support dot-walking (**Show Related Fields**) and a *between* operator.
- Related list conditions: tick **All** to require the condition of every related record. With no related records, *All* ticked passes and unticked fails.
- Relationship builders show suggested relationships unless **Show all relationships** is ticked.
- Selecting a filter on an incompatible table warns that existing conditions cannot apply.

## Audits

Key fields (full walk-through in [[Create and Run a Compliance Audit]]):

- **Create tasks** (off by default) and **Assignment type**: User Field, Specific User, Group Field, Specific Group, with **Assign to empty** = Do Not Create Task, Create Unassigned Task, or Create Assigned Task. A specific user must hold `certification`.
- **Run:** Daily, Weekly, Monthly, Periodically, Once, On Demand. Day 29 to 31 falls back to the last day of shorter months.
- **Preview Audit Results** tests the template without writing results or tasks, and does not change **Last run date**.
- An audit with results cannot be deleted; a result with a follow-on task cannot be deleted.
- `glide.allow.new.cert_follow_on_task` (default **true**): a new follow-on task for the same failure at every run. False = reuse the same task. Not for scripted audits.

### Results

| Field | Meaning |
|---|---|
| Document | the audited record |
| State | **Certified** (one row), **Failed** (one row per failed condition), **Pending** (data certification awaiting input) |
| Column name, Desired value, Discrepancy value | what was checked, what was expected, what was found (failed rows only) |
| Follow on task, Audit | links |
| Threshold | *In Limit* or *Exceeded* |
| Stability | *Stable* or *Unstable* |

Seen in: **Audit Results** lists per audit type, the audit's related list, and the **Compliance** view of a CI form (Passed Audit Results, Failed Audit Results, Follow On Tasks; base CI classes only).

### Health window, threshold and stability

On the audit: **Health window** + **Health window unit** (default 7 Days), **Threshold count** (default 5), **Stability count** (default 1).

- The window is **trailing**: each run looks back that long from now. Windows are judged independently, so a CI can be *Exceeded* in one run and *In Limit* in a later one.
- **Threshold:** more failures of a field within the window than the count = *Exceeded*.
- **Stability:** more switches between Certified and Failed within the window than the count = *Unstable*.

## Follow-on tasks

- Mine: **Compliance > My Follow On Tasks**. Open the failed results from the task, fix the CI, update **State** with work notes. A `certification` user sees only their own tasks but can reassign them.
- All (admin): **Follow On Tasks** under each audit type. **Audit** and **Configuration item** are read-only; the short description comes from the audit's **Task description**.

## Overview pages and reports

- **Compliance > Overview**, and **Overview** under Architecture Compliance and Desired State: upcoming audits, outstanding tasks, discrepancies, hierarchical task roll-up, 30/60/90 day task aging. `certification` views; `certification_admin` customises; `admin` edits.
- Reports (**Reports > View / Run**, search *Desired State*): Desired State Discrepancies, Result with Stability Unstable, Result with Threshold Exceeded, Upcoming Desired State Audits, 30/60/90 Day Task Aging, Hierarchical Task Roll Up, Outstanding Desired State Tasks.

## Out of place in this chapter

The docs page "Compliance filter" here describes **software licence** compliance (entitled company, location, department; levels In compliance, Nearly out of compliance at over 95% used, Out of compliance, Reconciliation required, Unused, Non applicable for cluster-related infrastructure licences). That belongs to software asset management: [[Legacy Software Asset Management Plugin]].

## Related

- [[CMDB Data Manager]] · [[CI Relationships]]
