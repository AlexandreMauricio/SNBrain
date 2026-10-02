---
type: how-to
tags: [how-to, incident, notifications, flows]
status: documented
source: ServiceNow Australia IT Service Management PDF, "On-Call Scheduling", topics "Designing an escalation process", "Create an escalation trigger rule", "On-Call Scheduling subflows" (pp. 2947-2952, 2974-2977), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Create an on-call escalation trigger rule

**Goal:** when a task meeting a condition is assigned to a group, contact that group's on-call person and assign the task to whoever accepts.
**Prerequisites:** role `rota_admin` or admin (`rota_manager` for own groups, workflow only). The group has a published on-call shift.
**Navigation:** All > On-Call Scheduling > Administration > Trigger Rules

## Steps

1. Select **New**. **Name**, **Table**, **Execution order**, **Active**.
2. **When to activate**: **Run Trigger** = *Run once*, or *Every time trigger field changes* with **Trigger fields**; **Match conditions** All/Any; **Conditions**.
3. **What action to take**: optional **Group** (makes the rule group-level); **Trigger action** = Subflow; **Trigger subflow** = *On-Call: Assign By Acknowledgement*.
4. Submit.

## Result / how to check it worked

Create a matching task assigned to the group: the on-call primary gets a notification on their preferred channel; accepting it sets **Assigned to**. The tracking icon beside **Assignment group** shows the path (needs `com.snc.on_call_rotation.log_escalations`).

## Example

| Field | Value |
|---|---|
| Name | Example P1 network escalation |
| Table | Incident |
| Run Trigger | Every time trigger field changes; fields Assignment group, Priority |
| Conditions | Priority is 1 - Critical AND Assignment group is Example Network Team |
| Trigger subflow | On-Call: Assign By Acknowledgement |

## Tables / fields involved

- `trigger_rule`, `cmn_rota`, `cmn_rota_roster`, `on_call_escalation` and children, [[incident]]

## Gotchas

- Rules are evaluated like assignment rules, in **Execution order**.
- Reassigning the task to a group with no matching rule cancels the running escalation.
- SMS and voice need Notify; a user with no SMS device is simply not contacted when SMS is forced.
- Tables that do not extend task must first be added in **Trigger Rule Table Configuration**.
- Background: [[On-Call Scheduling]].
