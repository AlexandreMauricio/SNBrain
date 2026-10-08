---
type: how-to
tags: [how-to, flows, automation, workflow]
status: documented
source: ServiceNow Australia Build workflows PDF, "Create a sample playbook" (pp. 57-63), "Add and configure a trigger / stage / activity in a playbook" (pp. 66-75, 91-94), "Create a playbook" (pp. 140-142), "Test a playbook" (pp. 158-160), read in full 2026-10-08
sn-release: Australia
verified:
updated: 2026-10-08
---

# Create and Test a Playbook

**Goal:** build a record-driven playbook in Workflow Studio, test it against a record, and activate it. Concepts: [[Playbooks Overview and Components]]. Not tested on an instance.

**Needs:** role admin, `playbook.admin` or `pd_author` (`playbook.write` with content filtering); a trigger table your subscription covers ([[Playbooks Administration, Roles and Access]]); a non-production instance for testing.

## Steps

1. **All > Process Automation > Workflow Studio > Playbooks** > **New > Playbook**. Enter **Playbook name**, **Application**, **Description** > **Build playbook**. The builder opens in Diagram view.
2. Select the **Start** node > **Details**: **Execution type** = Record driven, **Parent table** > **Save and close**.
3. Open the **Triggers** panel > **Add trigger > Record based** > *When record is created* (or updated, or both). Add conditions; tick **Run this trigger on extended tables** or **Trigger on unique values** if needed > **Save and close**.
4. Add stages: **+** > **Add a stage** (Board view: **+ Add stage**). Give each a **Label** and a **Start Rule** (*When playbook starts* or *After specific stages*).
5. Add activities to each stage: **+** > **Add an activity** > pick from *Common Activities* (or select the application first for its own activities).
   - **Details**: **Label**, **Start Rule** (*When stage starts* or *After specific activities*).
   - **Automation**: fill the inputs, typing values or using the data pill picker (*Context > Parent Record*, or the outputs of an earlier activity).
   - **UI Layout**: what the card shows.
6. Optional: decisions, parallel branches, optional activities, variants ([[Playbook Activities, Decisions and Variants]]); restart rules.
7. **Test**: choose an existing record (trigger conditions are ignored) > **Run Test**. Open *Process execution details* for states and logs, and *Playbook preview* to see the cards. Fix errors shown in the error tray.
8. **Activate**. Any later edit deactivates the playbook until you activate it again.
9. Decide where people see it: [[Playbook Experience Design for Workspace, Portal and Mobile]].

## Example

Playbook *Example Priority Follow-up* on the Interaction (`interaction`) table.

- Trigger: *When record is created*, condition on a field of the person the interaction was opened for.
- Stage 1 *Classify*: activity **Create New Record** on Incident (`incident`), with **Assigned to** and **Short description** taken by data pill from the parent interaction and **Caller** from its **Opened for**.
- Stage 2 *Communicate*: **Wait For Condition** on the incident created in stage 1 (pill from that activity's output) until it is updated by its assignee; then **Instruction** with a message telling the agent to notify the requester, **Wait for user input** = Yes.
- Stage 3 *Resolve*: **Wait For Condition** until the incident **State** is Resolved; then **Instruction** asking the agent to send the resolution notes.

Test with an interaction opened for *Test User*; the execution should create one incident and stop at the first wait.

## Related

- [[Playbooks Overview and Components]] · [[Workflow Studio Overview]]
