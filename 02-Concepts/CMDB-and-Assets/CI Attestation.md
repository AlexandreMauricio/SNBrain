---
type: concept
tags: [concept, cmdb, data-integrity, data-management, workspace]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB data management > "CIs attestation" with "Review attestation tasks in a workspace" and "Run an attestation policy on-demand" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/cmdb-data-management-landing.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# CI Attestation

**In one line:** attestation asks the people who own or manage CIs to confirm, in bulk and on a schedule, that the thing each CI represents **actually exists**; rejected CIs can then be retired, archived or deleted.

It is a policy type of [[CMDB Data Manager]] (no subflow: the reviewer closes the task). Create the policy with [[Create a CMDB Data Manager Policy]].

## Reviewing an attestation task

**Workspaces > CMDB Workspace > Tasks > Attestation**. Roles: owners `data_manager_user` (inside `sn_cmdb_user`); admins `data_manager_admin` or `sn_cmdb_admin`. Managers also see the tasks of their direct reports and of members of groups they manage.

1. Open a task (or select several for bulk review). If it is wrongly assigned: **Reassign** > **To me**, **To other user** (owners can pick only within the current assignment group; admins anyone with `data_manager_user`), or **Send for reassignment** (notifies the administrator).
2. **Review CIs to attest**. An unassigned task becomes yours.
3. If the **Smart detection** dialog appears: **Auto-attest** the detected CIs, or **Review**.
4. Work through **Not Yet Reviewed**. Selecting a CI opens its health, key properties and CMDB 360 data. For the selected CIs:

| Action | Result |
|---|---|
| **Attest** | moves to *Attested* |
| **Reject** (with explanation) | moves to *Rejected* |
| **Unattest** | back to *Not Yet Reviewed* |
| **Exclude** (with explanation) | removed from this task and added to the attestation exclusion list, so future policies skip it. Only an admin can undo |
| **Remove duplicates from task** | removed from the task and a **de-duplication task** is created for them ([[Duplicate CI Remediation]]). Only an admin can undo |

5. When *Not Yet Reviewed* is empty, **Submit**.

Only three CI fields are written: **Attestation Status** (Attested, Rejected, Not Yet Reviewed), **Attested By**, **Attested Date**. Admins can **Cancel task** while it is Not started or In progress.

## Smart detection and auto-attestation

CIs seen recently by a discovery source can be attested without a human look.

| Property | Default | Effect |
|---|---|---|
| `sn_cmdb_ws.attestation.smart_detection.disabled` (add to `sys_properties`) | false | true turns smart detection off |
| `sn_cmdb_ws.attestation.smart_detection.discovery_window` | 30 | days: the CI must have been discovered within this window |
| `sn_cmdb_ws.attestation.smart_detection.discovery_source.exclusion` | Manual Entry | comma-separated sources that do not count |

Needs Discovery or Service Graph Connectors feeding the CMDB.

## Run on demand

Data Manager > **Policies** > **Published policies** > the attestation policy > **Run Policy** > **Run**. One policy at a time, and not while it is already running. Does not disturb its schedule. Role `sn_cmdb_admin`.

## Related

- [[CMDB Data Manager Reference - Notifications, Properties, Jobs, Tables and Roles]] · [[CMDB Data Certification]]
