---
type: concept
tags: [concept, notifications, incident, roles, schema]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > ServiceNow AI Platform Additional Capabilities > Task Communications Management (landing, process, plugins, activate, components installed, Install Collaboration Services for TCM and its components, Working with TCM: define a communication plan, task, channel, contact, recipient list, plan type, task type, contact responsibilities, channel configuration, Slack for a communication task), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/task-communications-management/tcm-landing-page.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Task Communications Management

**In one line:** **Task Communications Management** (TCM, `com.snc.task_communication_management`) is the generic framework behind communication plans: **plan definitions** with conditions attach a **communication plan** (`comm_plan`) and its **communication tasks** (`comm_task`) to any task-extending record, each task telling given contacts something on a channel (email, SMS, conference, Slack, DEX Desktop Assistant) once or on a schedule.

From the Brazil docs; not tested. Its best-known use is [[Incident Communications Management]] (`incident_alert` extends `comm_plan`, `incident_alert_task` extends `comm_task`), which holds the incident-side detail (contact sources, closure cascade, ICM roles). Activated together with ICM (`com.snc.iam`) or Major Incident Management (`com.snc.incident.mim`); brings **Contact Management** `com.snc.contact_management` and **Targeted Communications** `com.sn_publications` (recipient lists). Demo data included.

## How it fits together

Example from the docs: plan definition *Technical Communications* on `incident` with condition Priority High and Major incident state Accepted; task definitions *Initiate Technical Communications* (email, one time) and *Technical Status Update* (email and SMS, recurring); contacts = service owners of the affected CIs. When an incident matches, the plan and tasks attach and run in order.

## Definitions (**Task Communications Management > Plan Definitions**)

| Record | Fields |
|---|---|
| Communication plan definition (`comm_plan_definition`) | Name, Table, Type (plan type), Order, **Condition based** + Condition, Active, Description; related lists task definitions and contact definitions |
| Communication task definition (`comm_task_definition`) | plan, Name, Type (task type), Application, Order (execution order), Active, Description, **Communication frequency** (One time or Recurring), **Duration** (send within, or repeat every, that time) |
| Channel definition (`comm_channel_definition` and children) | related links **Add Channel - Email** (email client template defined on the communication task table; Recipient field To, CC or BCC, default from `sn_comm_management.default_email_recipient_field`), **- SMS** (Notify SMS template, provider selector), **- Conference** (Notify provider selector; exclusive with email and SMS), **- Slack**, **- DEX Desktop Assistant** (notification template) |
| Contact definition (`comm_contact_definition`) | type (user, group, recipient list), Responsibility, the user / group / list |

SMS and conference on incidents need Notify (`com.snc.notify`) and `com.snc.iam.notify_number` ([[Notify Conference Calls and Use from Tasks, Incident Communications and On-Call]]). Slack needs the store app **Collaboration Services for Task Communications Management** (`sn_tcm_collab_hook`; tables `comm_channel_def_slack`, `comm_channel_slack`, `comm_plan_collab_data`) and a configured Slack workspace ([[Collaboration Services (Slack, Teams and Zoom on Tasks)]]); it sends direct messages.

**Administration** menu: **Recipients Lists** (Name, Type, State, Method *Upload File* static from Excel or *Dynamic Condition* by script or condition, e.g. the support group of the incident's service), **Plan Types** and **Task Types** (Name, Global or a Table, Application, Active; used for filtering, reports and SLAs on plans and tasks), **Contact Responsibilities** (Global or Table, Name such as Business Director or Communication Manager, Type), **Channel Configuration** (`comm_channel_config`, read only: Channel, Configuration script include, Active, Classification).

## Tables

Definitions: `comm_plan_type_lookup`, `comm_task_type_lookup`, `comm_plan_definition`, `comm_task_definition`, `comm_channel_definition`, `comm_channel_def_email`, `comm_channel_def_sms` and `comm_channel_def_conference` (only with Notify), `comm_contact_definition`, `comm_channel_config`. Runtime: `comm_plan`, `comm_task`, `comm_channel`, `comm_channel_email`, `comm_channel_sms`, `comm_channel_conference`. `comm_task_handler` maps task types to handlers (e.g. `CommunicationManagementIncidentHandler`; admins cannot delete this table).

## Roles

| Role | Can | Contains |
|---|---|---|
| `sn_comm_management.comm_plan_viewer` | read TCM tables | `notify_view`, `sn_publications_recipients_list_user` |
| `sn_comm_management.comm_plan_admin` | create and edit definitions | `notify_admin` |
| `sn_comm_management.comm_plan_mgr` | create and edit plans and tasks | `sn_comm_management.comm_plan_viewer` |
| `sn_tcm_admin` | all TCM configuration | `comm_plan_admin`, `comm_plan_mgr` |

## Unconfirmed variants

- Plan manager role: `sn_comm_management.comm_plan_mgr` (TCM components page) vs `sn_comm_management.comm_plan_manager` (ICM pages, Australia).
- Contact definition page asks for `sn_comm_management.communication_plan_admin`; elsewhere `sn_comm_management.comm_plan_admin`.
- Menu written *Task Communications Management* and *Task Communication Management*; the Slack page uses **Incident > Communication Plan Definitions**.

## Example

Plan definition *Example Maintenance Notice* on `change_request`, condition Type is Normal and State is Scheduled; task *Example Heads-up* (email, one time, 30 minutes) to recipient list *Example Affected Users* (dynamic condition on the change's service).

## Related

- [[Major Incident Management]] · [[Notify Overview, Twilio and Providers]]
