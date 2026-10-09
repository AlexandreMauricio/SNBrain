---
type: how-to
tags: [how-to, cmdb, data-integrity, admin]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB Compliance, topics "Create a filter", "Create or edit a certification template", "Create a compliance audit", "Schedule and run an audit", "Results preview", "View an audit result", "Access follow-on tasks" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/c_Compliance.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# Create and Run a Compliance Audit

**Goal:** check automatically that a set of CIs has the attributes and relationships it should, and get tasks for the ones that do not.
**Where:** **All > Compliance** (the sub-menu fixes the audit type: Desired State, Architecture Compliance, or the top-level Filters / Templates / Audits for type Compliance), or **CI Class Manager** > class > **Health > Compliance**.
**Roles:** `certification_admin` or `sn_cmdb_admin`.

Concepts: [[CMDB Compliance - Desired State, Architecture Compliance and Audits]].

## Steps

1. **Filter.** **Compliance > Filters** > **New**: **Name**, **Table**, **Filter condition** (the builder shows how many records match) > **Submit**. This is version 1.
2. **Template.** **Compliance > Desired State > Templates** > **New**: **Name**, **Filter**, description. Then add conditions, saving each with the green check mark:
   - **Certification Attribute Conditions** (all types)
   - **Certification CI Relationship Conditions**, **User Relationship**, **Group Relationship** (Desired State only)
   - **Certification Related List Conditions** (all types)
   - **Submit**.
3. **Audit.** **Compliance > Desired State > Audits** > **New**:

| Field | Value |
|---|---|
| Name, Short description | |
| Template | the template (only active versions of the matching type are offered) |
| Create tasks | tick to get follow-on tasks |
| Assignment type | User Field, Specific User, Group Field or Specific Group, plus **Assign to empty** for the field types |
| Task description | becomes the short description of every follow-on task |
| Run, Day, Time | the schedule, or **On Demand** |
| Health window, unit, Threshold count, Stability count | defaults 7 Days, 5, 1 |

   Save (context menu **Save**) so the related lists appear.
4. **Preview Audit Results** (related link): a summary of what the audit would find, without writing anything.
5. **Run Audit**, or wait for the schedule. **Audit Results** and **Follow On Tasks** fill in on the audit.
6. Assignees work their tasks under **Compliance > My Follow On Tasks**.

## Example

- Filter `Example - production Linux servers`: table Linux Server, condition *Used for is Production*.
- Template `Example - Linux baseline` (Desired State): attribute conditions *RAM (MB) greater than or is 8192* and *Support group is not empty*; related list condition on Software Installation *Display name is Example Backup Agent*.
- Audit `Example - weekly Linux baseline`: Create tasks on, Assignment type **Group Field** = Support group, Assign to empty = **Create Unassigned Task**, Run Weekly on Monday 06:00.

A server with 4096 MB and no backup agent gets two Failed results (one per failed condition), with follow-on work assigned to its support group (whether that is one task or one per result is not stated in the docs).

## Gotchas

- **An unsaved condition row is lost on Submit or Update.** Click the green check mark first.
- All conditions are ANDed; there is no OR.
- Changing a filter's or template's name, table or conditions makes a **new version**; audits keep pointing at the version they were given until changed.
- With the default `glide.allow.new.cert_follow_on_task` = true, **every run creates a new task for the same unresolved failure**.
- Audits with results, and results with tasks, cannot be deleted.
- Architecture Compliance and Desired State accept only filters on `cmdb_ci` tables.

## Related

- [[Scripted Compliance Audits]] · [[CI Class Manager]]
