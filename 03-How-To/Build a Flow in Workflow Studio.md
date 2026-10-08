---
type: how-to
tags: [how-to, flows, automation, service-catalog]
status: documented
source: ServiceNow docs, Australia, Build workflows > Workflow Studio > Flows, subflows, and actions (read 2026-10-08 through the docs site): Getting started with flows, Build your first flow in Workflow Studio, Create a flow in Workflow Studio, Create a flow with a Service Catalog trigger, Test a flow, Activate a flow. https://www.servicenow.com/docs/r/australia/build-workflows/workflow-studio/build-your-first-flow.html
sn-release: Australia
verified:
updated: 2026-10-08
---

# Build a Flow in Workflow Studio

**Goal:** create, test and activate a flow. Concepts: [[Flows, Subflows and Actions Overview and Architecture]], [[Building Flows - Properties, Triggers, Stages and Error Handling]]. Not tested on an instance.

**Needs:** role `flow_designer` (or admin, or delegated developer); a non-production instance; any business rule or workflow doing the same job deactivated first.

## Steps

1. **All > Process Automation > Workflow Studio** > **New > Flow** > tab **Build from scratch**.
2. Fill **Flow name**, **Description**, **Application**; under additional properties check **Run as** and, if needed, **Run with roles**. **Submit**.
3. **Add a trigger**: pick the type, the table and the conditions (or a saved trigger). **Done**.
4. **Add an Action, Flow Logic, or Subflow**:
   - *Flow Logic > If*: build the condition from a pill (pill picker or drag from the Data panel).
   - Inside it, *Action* > for example *Ask For Approval* or *Update Record*; fill the inputs with pills from the trigger or from earlier steps.
   - Add *Else* / *Else If* for the other paths.
5. Changes save as you go (each **Done**).
6. **Test**: choose a record that should take the path you want to check > **Run Test** > open the execution details and read each step's state and runtime values. Repeat for the other paths.
7. **Activate**.
8. For a catalog item: open the item and put the flow in its **Flow** field; clear **Workflow** and **Execution Plan**.

Later: **Executions** in the header lists each run with state and duration.

## Example

Flow *Example Approval for Requested Items*, trigger **Service Catalog**.

1. *If* **Trigger > Requested Item Record > Price** is greater than 1000.
2. → *Ask For Approval* on the requested item (**Approval Field** = Approval, **Journal Field** = Approval history), rule *Approve when Anyone approves* from **Requested Item Record > Opened by > Manager**.
3. *Else* → *Update Record* on the requested item: **Approval** = Approved, **State** = Closed Complete, **Close notes** = a fixed text.

Test once with a requested item priced above the limit (the run waits on the approval) and once below (the run completes at step 3).

## Related

- [[Building Flows - Properties, Triggers, Stages and Error Handling]] · [[Subflows in Workflow Studio]] · [[Create and Test a Playbook]]
