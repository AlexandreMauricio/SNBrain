---
type: concept
tags: [concept, incident, notifications]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Incident Communications Management" (pp. 2395-2419), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Incident Communications Management

**In one line:** communication plans attached to an incident that say who is told what, when and by which channel; each plan (`incident_alert`, numbered ICP) holds communication tasks (`incident_alert_task`, numbered ICT) sent by email, SMS, conference call or Slack.

Plugin `com.snc.iam` (activated with [[Major Incident Management]]). SMS and conference calls need Notify (`com.snc.notify`).

## Building blocks

| Piece | What it defines |
|---|---|
| Communication plan definition | which plans attach to which incidents (table must be Incident `incident`), stakeholders and content |
| Communication task definition | one task in the plan: channel and frequency (once or recurring) |
| Communication channel definition | email, SMS, conference, Slack |
| Contact responsibility | a named role in the plan (Duty Manager, Incident Manager, Duty Director by default; also Business Director, Communication Manager, Service Owner, Technical Support...), of type user, group or recipient list |
| Contact definition | rule that resolves a responsibility to a real user or group: **Source** = None (added by hand, with a **Quantity** limit), Form Field (Assigned to, Opened by, Resolved by, Closed by, Assignment group) or Default Override (ordered conditions giving a user or group) |

Group contacts can include the on-call people (primary and secondary by default; property `com.snc.iam.on_call_escalation_level`).

## Records

**Incident Communication Plan** (`incident_alert`, extends `comm_plan`): **Source incident**, **Type** (Ad hoc, End User, Stakeholder, Technical), **Communication plan definition**, **State** (Open, Closed, Canceled), **Assignment group**, **Assigned to**, **Order**.

**Incident Communication Task** (`incident_alert_task`, extends `comm_task`): **State** (Pending, Open, In Progress, Complete, Skipped), **Communication frequency**, **Due in**, **Last communication sent**, **Order**.

Other table: `impacted_ci`.

## Working a plan

- Ad hoc plan: **Incident Communications Management > Create New**, or **New** in the incident's **Incident Communication Plans** related list (the incident becomes the source and fills **Background**).
- On a task: related links **Send Updates** (compose email or SMS; the **From** numbers come from the provider selector `notify_group_selector`), **Initiate / Join / End Conference Call** (property `com.snc.iam.notify_number`; call details are written to work notes).
- Users subscribe through notification preferences, category *Incident Communication Plan* (New IA Raised, IA Actions Taken, IA Resolved Or Closed, IA Cancelled). See [[Notification Preferences and Channels]].

## Closure cascade

| Property (both false by default) | Effect |
|---|---|
| `com.snc.incident.incident_alert.closure` | incident closed → open plans Closed; incident canceled → plans Canceled (business rule *Cascade Closure of ICPs* on incident) |
| `com.snc.iam.incident_alert_task.closure` | plan closed or canceled → tasks never sent become **Skipped**, tasks sent at least once become **Complete** |

The older state model (New, Work in Progress, Resolved, Closed, Canceled) applies only to instances from before London.

## Roles

| Role | Can |
|---|---|
| `ia_admin` | create, edit, cancel plans and tasks, manage contacts (contains `contact_admin`, `sn_comm_management.comm_plan_manager`, `notify_view`) |
| `sn_iam_admin` | all configuration |
| `contact_user` / `contact_admin` / `sn_contact_admin` | view / edit contact definitions and responsibilities |
| `sn_tcm_admin` | Task Communications Management configuration |

Domain separation: Standard.

## Gotchas

- If you use communication plans on an instance upgraded to London or later, deactivate the flow *Major Incident Response and Resolution*.

## Related

- [[Major Incident Management]] · [[Incident Properties Reference]] · [[incident]]
