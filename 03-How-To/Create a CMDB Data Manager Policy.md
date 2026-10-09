---
type: how-to
tags: [how-to, cmdb, data-management, automation, workspace]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB data management > Administer CMDB Data Manager, topics "Create a CMDB Data Manager policy", "Publish a draft CMDB Data Manager policy", "Run an attestation policy on-demand", "Run a certification policy on-demand" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/cmdb-data-management-landing.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# Create a CMDB Data Manager Policy

**Goal:** define and publish a policy that retires, archives, deletes, attests or certifies a set of CIs on a schedule.
**Where:** **Workspaces > CMDB Workspace > Governance > Data Manager > Policies > Create new policy**.
**Role:** `sn_cmdb_admin`.
**Before you start:** for Retire, Archive, Delete, an **active retirement definition** for every targeted class; for approvals, **Managed By Group** filled on the CIs; any custom subflow already built. Concepts: [[CMDB Data Manager]].

## Steps

1. **General information:** **Name**, **Description**, **Policy type**, work notes. **Continue**.
2. **Data Filter:** **Table**, **Filter conditions**, optional **Related List Condition** > **Apply filters**. The impact analysis shows **Included records** and **Excluded records**; move records between them. It already accounts for exclusion lists and retirement state (a Retire policy skips CIs already retired; Archive and Delete skip CIs not retired). **Continue**.
3. **Assignment:** **Assignment type** and **Task assignment**:

| Assignment type | Tasks go to |
|---|---|
| User Field | the user in a chosen user reference field of the table (Assigned to, Attested by...), one task per user |
| User Group Field | the group in a chosen group field (Support Group, Change Group...), one task per group |
| Specific User | one user with role `data_manager_user` |
| Specific User Group | one group holding `data_manager_user` (directly or through a member) |

   Field types allow dot-walking. For attestation and certification, **If task assignment field is empty** decides between an unassigned task and a fallback assignee.
4. **Options** (only those relevant to the type appear):

| Option | Notes |
|---|---|
| Days to complete | deadline; reminders go out at 50%, 70% and 90% of it |
| Subflow | matches the type, for example *Delete Related Entry Configuration Item* for Delete CMDB Related Entry |
| Needs review | tasks wait for approval; otherwise auto-approved |
| Retention time | archive only: how long archived CIs can still be restored |
| Display fields / Certification fields | certification: fields shown to identify the record / fields to certify. No overlap |
| Allow field updates | certification: reviewers may correct values |
| Allow empty field values | certification: an empty value may be certified |
| Instructions | shown to the assignee |

5. **Schedule:** **Schedule** (a recurrence, or **On demand**), start time, day, **Run after every** N days, **Run policy scheduled job as** (users of group *Data Manager Scheduled Job Users*; default *DataManager Job Runner*).
6. **Review:** **Publish policy**, or **Save & Exit** to keep a draft.

## After publishing

- A daily job evaluates published policies and creates the tasks; subflows run on approval and close the task when done. Attestation tasks are closed by the person submitting them.
- For types such as Delete, the list of target CIs is attached to the task as a CSV.
- Follow up: policy form > **View Open Tasks** (column **Success Percent**); the run's record in `cmdb_data_management_policy_execution` (number prefix `PLCEXEC`) notes CIs that were skipped.
- **Deactivate Policy** pauses a published policy. Drafts are published from **Draft policies** > **Edit Policy** > **Review** > **Publish Policy**.
- Run on demand: for attestation and certification, **Published policies** > the policy > **Run Policy** (one at a time, and not while it is running). For other on-demand policies, the scheduled job named after the policy under **System Definition > Scheduled Jobs** > **Execute Now**.

## Example

Policy `Example - retire unowned test servers`, type **Retire**. Table Server, filter *Used for is Test* and *Managed by group is empty* and *Created before last year*. Assignment **Specific User Group** = `Example CMDB Team`. Options: subflow for retire, **Needs review** on. Schedule monthly on day 1. Publish. Next month's run creates one task for `Example CMDB Team` listing the servers; approving it sets them to the retired state defined for Server. A second policy of type **Archive** with the same filter, retention 120 days, then archives the retired ones.

## Gotchas

- **A filter on life-cycle fields can be silently ineffective** in Archive and Delete policies when the retirement definition uses those fields.
- More than 10,000 target CIs are split over several tasks.
- A policy moved by update set arrives as a draft.
- A CI archived and restored cannot be archived again by Data Manager.

## Related

- [[CI Attestation]] · [[CMDB Data Certification]] · [[Dependent CI Management and Cascade Cleanup]]
