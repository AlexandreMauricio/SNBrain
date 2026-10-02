---
type: concept
tags: [concept, incident, notifications, admin]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Incident Management", topic "Managing major incidents" and its subtopics (pp. 2499-2530), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Major Incident Management

**In one line:** a major incident is an ordinary [[incident]] record flagged through **Major incident state**, owned by a major incident manager, with a workbench, communication plans and a post incident report layered on top.

Plugin Incident Management - Major Incident Management (`com.snc.incident.mim`), activated manually; it brings Incident Communications Management (`com.snc.iam`), Incident Updates and Task-Outage Relationship. Optional: Notify (SMS, conference calls), On-Call Scheduling.

## Major incident state

| Value | Set when |
|---|---|
| Proposed | someone proposes the incident, or a trigger rule does: it is a **candidate** |
| Accepted | a major incident manager promotes it, or creates a major incident directly |
| Rejected | the manager rejects the candidate (incident state unchanged) |
| Canceled | the manager **demotes** an accepted major incident, or the incident is canceled |

The normal incident **State** keeps running in parallel.

## Ways in

| Way | Who |
|---|---|
| **Propose Major Incident** on the incident context menu (asks reason and business impact). Not offered on resolved, closed or canceled incidents | any agent |
| **Incident > Major Incidents > Create Major Incident Candidate** | agent |
| **Major incident trigger rules** | automatic |
| **Promote to Major Incident** (context menu) or **Create Major Incident** | major incident manager |

List action **Link to Major Incident** attaches selected incidents as children. Workbench **Find Similar** suggests children (needs Predictive Intelligence solution `ml_sn_global_similar_incidents_mim`).

### Create new or promote

Property `sn_major_inc_mgmt.com.snc.incident.mim.major_incident_creation`:

- **Create new**: accepting a candidate creates a **new** incident that is the major incident; the candidate becomes its child.
- **Promote**: the candidate itself becomes the major incident.

### Trigger rules

**Major Incidents > Administration > Major Incident Trigger Rules** (`major_incident_trigger_rule`; roles `incident_manager`, admin): **Table**, **Conditions**, **Execution Order**, **Action to take** (*Propose* or *Promote*). Evaluated asynchronously on every insert or update of an active incident that has no parent and is not already proposed or accepted. First matching rule wins. The shipped rules are **inactive**.

## Assignment on proposal and promotion

- Group: from property `sn_major_inc_mgmt.major_incident_management_group`. On proposal it is applied only if **Assignment group** is empty; on **manual promotion** it replaces the existing group (the old group and assignee are notified).
- Person: the on-call user of that group if On-Call Scheduling has a shift; on manual promotion or direct creation, the user who did it.

## Workbench

**View Workbench** on a major incident or candidate. Tabs:

| Tab | Content |
|---|---|
| Summary | impacted services, affected CIs, outages, locations, child incidents, groups and on-call people, tasks, activity |
| Communicate | communication plans and tasks (email, SMS, Slack); **Compose**, **Close Task**, **Snooze** for recurring ones, **Manage Recipients**; ad hoc plans with **Add** |
| Collaborate | conference-call tasks (needs Notify): **Initiate**, **Join Call**, mute, add participants |
| Post Incident Report | only when Resolved or Closed: Overview, Findings, Resolution, Timeline (**Regenerate Timeline**), **View Complete Report** / PDF |

A timer in the header shows the duration since creation until resolution.

## Resolution and closure

- Resolving the major incident resolves its child incidents and notifies their callers ([[Parent and Child Incidents]]).
- **Auto-close never closes an accepted major incident**: a major incident manager closes it manually from Resolved.
- A caller without roles cannot resolve, reopen or close a major incident.
- Follow-up: post incident review, and normally a problem for root cause.

## Roles

| Role | Does |
|---|---|
| `major_incident_manager` (the guide's role table prints `mim_manager`) | accept, reject, demote, close; owns the incident; ad hoc communication |
| `communication_manager` | runs stakeholder communication |
| `incident_manager` | properties, trigger rules, communication plan definitions |
| `sn_mim_admin` | all major incident configuration |

## Related

- [[Incident Management Overview and Lifecycle]] · [[Incident Properties Reference]] · [[Incident Communications Management]] · [[Create a Major Incident Trigger Rule]]
