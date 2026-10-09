---
type: reference
tags: [reference, cmdb, data-management, notifications, roles, instance-admin]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB data management, topics "Notifications" and "Components related to CMDB Data Manager" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/cmdb-data-management-landing.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# CMDB Data Manager Reference - Notifications, Properties, Jobs, Tables and Roles

**What it is:** the lookup lists for [[CMDB Data Manager]].
**Where:** properties show on Data Manager > **Settings** (role `data_manager_admin`).

## Notifications

All by email, from events. Most need no configuration.

| Subject | Sent when | To |
|---|---|---|
| FAILED: A CMDB Data Manager policy has failed to run | policy evaluation errors | `data_manager_admin` holders and the policy's **Run as** user |
| FAILED: A CMDB Data Manager task has failed | the task's subflow fails | same |
| ACTION REQUIRED: A CMDB Data Manager task needs review | a task is open with no reminder inside the frequency window | approvers with a Requested approval (`sysapproval_approver`) |
| cmdb_data_management_task {number} Approval Request | task ready for approval (policy has **Needs review**) | approval group members |
| Due date is approaching for {number} | assigned task with a due date, at 50%, 70%, 90% of the time | `assigned_to` |
| Due date breached for {number} | due date passed | `assigned_to` and their manager |
| CMDB Attestation task {number} completed | an attestation task is submitted | `data_manager_admin` holders |
| CMDB Data Manager task {number} rejected | a task is rejected in review | the configured group, else `data_manager_admin` holders |
| ...has been assigned to you / to a group you belong to | tasks created with an assignee | assignee, or group members |
| An unassigned CMDB Data Manager task {number} has been created | tasks created without an assignee | members of group *Data Manager Admin* (shipped empty: add people to it) |

## Properties

| Property | Default | Effect |
|---|---|---|
| `glide.cmdb.data.manager.delete.batch.size` | 1000 | CIs per delete or archive batch |
| `glide.cmdb.data.manager.subflow.timeout` | 600,000 ms (10 min) | a subflow running longer is cancelled |
| `glide.cmdb.data_manager.default_archive_time` | 120 | days archived CIs stay restorable before permanent deletion |
| `cmdb.data.manager.stale.task.life.in.days` | 90 | days after which an open or unapproved task is stale and closed |
| `cmdb.data.manager.stale.tasks.notifications.frequency` | 7 | days between "needs review" reminders |
| `sn_cmdb_ws.cmdb.dm.policy_types.due_date_notification` | `attestation,certification` | policy types that get due-date reminders |
| `sn_cmdb_ws.glide.cmdb.data.manager.aging.policy.task.timeframe` | 30 | days without activity before a task counts as aging |
| `sn_cmdb_ws.glide.cmdb.data_manager.rejected.task.notifications.group` | empty | group (sys_id) notified of rejected tasks |
| Scheduled job users (setting) | group *Data Manager Scheduled Job Users*, user *DataManager Job Runner* | who policy jobs can run as |

The task review page of the docs names the rejected-task property `glide.cmdb.data_manager.rejected.task.notification_group`; the components page gives the `sn_cmdb_ws.` name above. Check `sys_properties`.

## Scheduled jobs

| Job | Does |
|---|---|
| CMDB Data Manager Retire Policy Processor | published Retire policies; only CIs not yet retired |
| CMDB Data Manager Archive/Delete Policy Processor | Archive policies first, then Delete if no errors; only CIs already retired |
| CMDB Data Manager Delete Related Entry Policy Processor | Delete CMDB Related Entry policies |
| CMDB Data Manager - Stale Task Cleaner | daily; sets stale tasks to Closed Cancelled |

## Tables

| Name | Label | Holds |
|---|---|---|
| `cmdb_data_management_policy` | CMDB Data Management Policy | policies |
| `cmdb_data_management_policy_execution` | ...Policy Executions | one record per run, number prefix `PLCEXEC`; work notes give skipped CIs. Certification runs feed the Data Certification Dashboard |
| `cmdb_data_management_policy_runtime_attributes` | ...Policy Runtime Attributes | current status and summary |
| `cmdb_data_management_task` | ...Task Control | policy tasks |
| `cmdb_data_management_task_to_ci`, `cmdb_data_management_task_to_document` | | task to CI, task to related item |
| `sn_cmdb_ws_attestation_task_to_ci` | | attestation task to CI |
| `cmdb_ci_state_management_task_to_ci` | | task to CI for the Dependent CI Deletion policy type |
| `cmdb_policy_ci_exclusion_list` | Excluded CIs | exclusion lists |
| `cmdb_policy_type`, `cmdb_policy_type_categories` | | policy types and their Workflow Studio categories |
| `cmdb_policy_scheduled_job` | | scheduled job per policy |
| `cmdb_retirement_custom_definitions` | CMDB Retirement Custom Definitions | retirement definitions |
| `cmdb_dependent_ci_ledger`, `cmdb_ci_end_of_life_ledger`, `cmdb_dependent_ci_class_exclusion`, `cmdb_dependent_ci_extra_rels_config` | | [[Dependent CI Management and Cascade Cleanup]] |
| `cmdb_data_manager_policy_and_attributes` | | policies with attributes (named on the CMDB Workspace feature adoption page) |

## Roles

| Role | Name | Can | Contains |
|---|---|---|---|
| CMDB Data Manager administrator | `data_manager_admin` | everything: policies, previews, approvals, exclusion lists, subflow categories | `task_editor`, `data_manager_user`, `cmdb_query_builder_read` |
| CMDB Data Manager user | `data_manager_user` | read policies, calculate previews, view and update / approve / reject own tasks | |

`sn_cmdb_admin` contains `data_manager_admin`; `sn_cmdb_user` contains `data_manager_user` ([[CMDB Workspace Reference - Properties, Roles, Jobs and Tables]]).

## Record retention

- Certification records are kept apart so they can live longer for audits: the cleanup rule on `cmdb_data_management_policy_execution` (in [[sys_auto_flush]]) skips certification runs.
- Archive rules: **Archive CMDB Data Management Tasks** (all but certification); **Archive Certification Instances** (certification executions **2 years** after creation, destroyed **7 years** after archiving); **Archive Certification tasks**. Related rows in `sn_cmdb_ws_dm_certification_task_to_document` are archived with them. See [[System Archive and Archive Rules]].

## Related

- [[Create a CMDB Data Manager Policy]]
