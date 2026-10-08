---
type: concept
tags: [concept, flows, automation, service-catalog, sla, email, roles]
status: documented
source: ServiceNow docs, Australia, Build workflows > Workflow Studio > Flows, subflows, and actions > Build flows (read 2026-10-08 through the docs site): Building flows, Create a flow (and with inbound email, multiple inbound email triggers, Kafka message, MetricBase, Proactive Analytics, Service Catalog, SLA Task, external trigger, roles), Create flow Service Catalog variables, Create a decision table in a flow, Copy a flow, Duplicate an action or subflow, Test a flow, Activate a flow, Change default title, Edit a flow, Delete a flow, View activated flows for a table, Default read-only flows, Flow and subflow stages (configure, show subflow stages), Flow error handler (add, custom action to throw an error), Flow roles. Section start https://www.servicenow.com/docs/r/australia/build-workflows/workflow-studio/flows.html
sn-release: Australia
verified:
updated: 2026-10-08
---

# Building Flows - Properties, Triggers, Stages and Error Handling

**In one line:** what you set when building a flow: who it runs as, what starts it, how it reports progress to the requester, and what it does when something fails.

Architecture and limits: [[Flows, Subflows and Actions Overview and Architecture]]. Procedure: [[Build a Flow in Workflow Studio]]. Subflows: [[Subflows in Workflow Studio]].

## Flow properties

| Property | Meaning |
|---|---|
| **Flow name** | spaces become underscores in the internal name |
| **Application** | scope; fixed after creation; decides what data the flow can reach |
| **Domain** | on domain-separated instances |
| **Protection** | None or Read-only (only in a scope you own) |
| **Run as** | *User who initiates session* (default: actions limited by that user's ACLs, respects their date formats, can use their personal OAuth token) or *System User*. Not inherited by subflows. Inbound email flows always run as the sender (Guest when unknown) |
| **Run with roles** | only with *User who initiates session*: roles the flow gets **instead of** the user's roles while it runs |
| **Flow Priority Default** | Low, Medium, High ([[Flow Administration, Execution Details and Access]]) |

### Flow roles

- Any role you hold in that scope can be given, except `admin`, `security_admin` and application admin roles; those *high-security roles* can only be added by an application administrator through **+ Add high-security roles**.
- A user needs the flow's roles to edit it (otherwise read-only). Copying a flow drops its roles.
- A role missing on the instance shows as a sys_id and blocks saving until removed or created.
- Subflows have their own roles; nothing is inherited either way.
- A role does not guarantee access: ACLs may ask for more ([[Flow Administration, Execution Details and Access]]).
- Flow roles override roles an AI agent would inherit from its user.
- With the Explicit Roles plugin add `snc_internal`. Typical use: an inbound email flow run by Guest gets `itil` so it can read incidents.

## Triggers

| Trigger | Notes |
|---|---|
| Record: Created, Updated, Created or Updated | table + conditions; **Run Trigger** Once or Always on update triggers |
| Scheduled | date-based |
| **Service Catalog** | runs for requests of a catalog item whose **Flow** field names this flow; the requested item is the trigger record. Clear the item's **Workflow** and **Execution Plan** fields. Catalog variables cannot be used in the trigger condition: read them in the flow with *Get Catalog Variables*. A flow referencing inactive or missing variables cannot be activated. Catalog items are Global records, not carried in the flow's update set |
| **Inbound Email** | **Email conditions** on Email (`sys_email`), for example Receive type is Reply; **Reply Record Type** = table of the target record. Set **Run as** to the initiating user. By default one email is processed by one flow only; property `glide.hub.flow.inbound_email_trigger.show_advanced` = true adds **Order** and **Stop processing** to chain several ([[Inbound Email Flow or Inbound Email Action]]) |
| **SLA Task** | runs when a task matches an SLA definition whose **Flow** field names this flow; use *SLA Percentage Timer* actions inside ([[SLA Definitions and Task SLAs]]) |
| Kafka Message | Stream Connect subscription and plugin; topic alias, serialization, start position, messages per run; concurrency and relative weight on the flow's settings record (Kafka view) |
| MetricBase | separate subscription; a MetricBase trigger record plus conditions |
| Proactive Analytics | Performance Analytics subscription; target missed, threshold breached, signal generated and their predictive variants |
| External trigger | Integration Hub; a trigger definition from a third-party spoke |

**Flow catalog variables** (More Actions > **Manage flow catalog variables**, on a Service Catalog flow): variables that exist only for this flow, shown as `Flow:<name>` in *Create Catalog Task* and *Get Catalog Variables*. The form is the normal catalog variable form.

## Editing

- Since Washington DC a flow opens **read-only**: **Edit Flow** takes the edit lock (a message names whoever holds it). The lock ends on closing the tab, **Make flow read only**, or 30 minutes idle.
- Since Zurich there is no Save button: changes save on **Done**, on adding, moving or deleting a step, on undo / redo, on activate. **Force save** is under More actions. Undo keeps the last 20 changes of the session, except those that created records. (Instances upgraded from Washington DC may have property `sn_flow_designer.save_as_you_go_enabled` set to false.)
- An asterisk marks a step missing mandatory inputs. Changing the trigger can delete configurations that referenced it.
- **Copy flow** (new name, optional other scope): not for protected flows. **Duplicate** copies one action or subflow call in place, with its inputs.
- **Change default title**: `*bold*`, `_italic_`, `~underline~`, `~~strike~~`, `#title#`, plus pills.
- **Delete**: only in the flow's own scope, not if protected.
- Flows on a table: list of the table > column menu > **Configure > Flow Designer Flows**.
- A flow imported by update set may show missing actions when a spoke is not installed.

## Test and activate

**Test** ignores the trigger. For record triggers choose or create a record; for update triggers you can declare which fields changed (previous and current value). **Run test in background** is optional. Then open the execution details. **Activate** needs write access; it is greyed out for flows in a scope you cannot write, protected flows, or missing developer permission.

## Stages

Stages tell an end user where a request stands. A *stage field* (type Workflow) on the trigger table shows them; Requested Item (`sc_req_item`) has one (**Stage**).

- More Actions > **Flow stages**: import a stage set, or **Add new stage** (**Name**, **Value**, **Duration** estimate, **Always Show**). Order them top to bottom as they should display. Then **Add a Stage** at the start of an action, logic block or inside an If. Not inside a For Each.
- States: Pending, In progress, Skipped, Complete, Cancelled, Error. Each stage can relabel its states (default or approval state sets).
- **Set "Error" State** only inside a conditional block within a stage. It does not stop the flow: add End Flow or remediation yourself.
- One stage field per table (only the first in the dictionary is used). The field shows the stages of the *last* flow that ran on the record, so give flows on the same table distinct conditions, and do not update the stage field from outside.
- Scheduled flows have no record, so their stages are never seen.
- **Show Subflow Stages** on a subflow call folds its stages into the parent's display.
- Properties: `com.glide.hub.flow_engine.stage_display.show_approvers` (true), `...show_approvers_limit` (5; above 10 breaks list rendering).

## Error handler

Turn on **ERROR HANDLER**: a section of up to 10 items that runs when the flow hits an error.

| Data | Content |
|---|---|
| **Error Status > Code** | 1 = error, 0 = success by default; custom actions can return their own |
| **Error Status > Message** | the error text |

| Resulting state (execution details) | When |
|---|---|
| Completed (error caught) | the handler ran, even if empty |
| Completed (error skipped) | a custom action continued past a failed step |
| Error | handler off, or the handler itself failed |

The context record shows plain Complete for the first two. A handler cannot resume or retry the failed step: use **Try** flow logic for that. Allowed logic in the handler: If, Wait for a duration, End Flow, Dynamic Flow, Set Flow Variables. Put clean-up in a subflow to get past 10 items; an empty handler on a subflow stops its errors cascading to the parent.

To test, a script step that throws works (action script step, server-side, in the action's scope):

```javascript
(function execute(inputs, outputs) {
    if (inputs.code == 1) {
        throw 'Example error message';
    }
})(inputs, outputs);
```

## Design guidelines

- Short, modular flows; over an hour of run time means too long. Aim for 25 actions, move the rest to subflows.
- Deactivate the business rules or workflows a flow replaces.
- Need variable input rather than a trigger? Use a subflow.
- No `gs.sleep()`: use a scheduled trigger, *Wait for a duration* or *Wait for condition*.
- For Each / Do Until: at most 1000 iterations (`sn_flow_designer.max_iterations`); cap Look Up Records at 1000; batch larger jobs. Declare loop counters with `var` in scripts.
- Parallel branches must not depend on each other.
- Use a large payload right after fetching it rather than after a wait.
- Switch between instance and MID Server steps as little as possible.
- Include `sys_complex_object` records in update sets. Never deploy a flow to an instance on an older release.
- Keep reporting off in production; with reporting on, `com.snc.process_flow.reporting.iteration.lastn` = 1 limits loop memory.
- Flows print across pages from the browser.

## Related

- [[Flows, Subflows and Actions Overview and Architecture]] · [[Flow Authoring Aids - History, Variables, Inline Scripts and AI]] · [[Subflows in Workflow Studio]] · [[Request Management Data Model and Process]]
