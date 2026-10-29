---
type: concept
tags: [concept, service-catalog, request, flows, workflow]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog > Configuring > Service Catalog request fulfillment, topics "Service Catalog request fulfillment", "Service catalog workflows", "Create a catalog workflow", "Add an activity to a catalog workflow", "Publish a catalog workflow", "Execution Plans", "Create an execution plan", "Execution plan tasks", "Creating execution plan tasks", "Service catalog execution plans", "Using Service Catalog execution plans scripts", "State closure in the request fulfillment execution plan", "View request notifications", "Pass variables between tasks", plus Catalog Builder topics "Configure a step-based service fulfillment flow", "Create a service fulfillment step type", "Define a service fulfillment step", https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/request-fulfillment.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Catalog fulfilment: flows, workflows and execution plans

**In one line:** each catalog item names **one** process engine (a Workflow Studio flow, a legacy workflow, or an execution plan) that runs per RITM to get approvals and create catalog tasks; Catalog Builder adds "service fulfillment steps" on top of a flow.

## Preparing fulfilment

1. Groups that do the work: any group, or **Catalog Policy > Fulfillment Groups** (type `catalog`, roles `catalog` and `itil`).
2. A process: flow, workflow or execution plan.
3. Put it on the item (**Process Engine** tab: **Flow**, **Workflow** or **Execution plan**, only one).

## Flows (current)

A flow with a **Service Catalog** trigger runs for each RITM. Flow actions such as **Get Catalog Variables** and **Create Catalog Task** read variables (including MRVS rows with For Each). See [[Flow Trigger Types Reference]] and [[Flow Core Actions Reference]].

## Legacy workflows

- Base workflows: **Service Catalog Request** (simple) and **Service Catalog Item Request** (more complex). Edited in the Workflow Editor; support domain separation.
- Workflow on **Requested Item** (`sc_req_item`): one per ordered item, assigned on the item. Workflow on **Request** (`sc_request`): runs for every request whatever was ordered; needs conditions; not set on the item.
- Catalog tasks that need variables must be created by the **parent** workflow, not a subflow.
- **Expected time** becomes the item's **Delivery Time**; with a **Schedule** the hours are converted to working days (2 days = 48 h; at 8 h per day = 6 days; plus a weekend = 8 days).
- Deleting an item or the workflow context while running sets the stage to *Catalog item removed* / *Workflow context removed*.
- With domain separation, point items at the domain-specific copy of a workflow explicitly.
- Roles: workflow_creator, workflow_admin (publish also workflow_publisher). Worked example in the docs: manager approval, Set Values on reject and approve, catalog tasks to Procurement and Hardware, a task assigned to `current.requested_for` through the **Advanced** script `task.assigned_to = current.requested_for;`, a notification and a log message.
- Background: [[Classic Workflow Overview]] · [[Classic Approvals]].

## Execution plans (oldest, linear)

- **Catalog Administration > Execution Plans** (`sc_cat_item_delivery_plan`). One plan can serve many items (e.g. every PC model). The docs recommend workflows (and now flows) instead; plans fit processes built by script or import.
- **Execution plan tasks** (templates, table `sc_cat_item_delivery_task` from general knowledge, unconfirmed) become catalog tasks when the item is ordered: **Fulfillment group**, **Assigned to**, **Order** (same order = start together; leave gaps 100, 200...), **Delivery time**, **Condition** and optional **Condition script** (both must be true; false = task created as *Closed Skipped*), **Short description**, **Instructions**. **SLA** field superseded by SLM.
- Variables reach a task through the task's **Available Variables** related list (Plan view), or by making the variable **Global**.
- **Approval tasks** (`sc_cat_item_dt_approval`): **Upon reject** = *Cancel all future Tasks* (default, also cancels the RITM) or *Go to a previous Task* (rolls back intermediate tasks; the approval record itself is not rolled back). Approvers: **Approved By** list or an **Approval Script** returning a user (e.g. `current.request_item.request.requested_for.manager`).
- Delivery estimate: sum of task times as elapsed time, or working time with **On Calendar** (a 24 h task on a 9-5 calendar = 3 working days). Display: `glide.sc.round.delivery.times`.
- Skipped last task closes the RITM as complete.
- **Execution plan script** (configure the item form to add the field, often **Delivery Plan Script**): server-side, `current` is the RITM, returns the sys_id of the plan to use, for example a remote-worker plan by the requester's location. Catalog tasks, approvals, delivery time and due date do not exist yet when it runs. (The docs' sample returns undefined variables; treat it as pseudo-code.)

### State closure with execution plans

| Children | Parent closes as |
|---|---|
| all tasks Closed Complete | RITM Closed Complete |
| at least one Closed Incomplete | RITM Closed Incomplete |
| all Closed Skipped | RITM Closed Skipped |

Same rule from RITMs to the request.

## Service fulfillment steps (Catalog Builder)

- Business owners define steps in Catalog Builder's **Fulfillment** step if the item uses a flow registered in **Catalog Administration > Service Fulfillment Steps Registry**. Base flow: **Step-based request fulfillment**, which calls subflow **Service Fulfillment Steps base flow** (input `task` = RITM, output `state` = completed / failed).
- Base step types: **Task** (description, assignment group, assigned to, priority), **Custom approval** (users, groups, all or anyone approves), **Manager approval**. Each step: **Sequence** (with or after previous step), **Condition** on the item's questions. Steps can be grouped into stages to run in parallel; **Estimated time to deliver** (days) sets the due date.
- New step type: a data table extending Service Fulfillment Step (`sc_service_fulfillment_step`, with domain master attribute `service_fulfillment_stage`) when extra input is needed; a record producer (keep the variable set *Service Fulfillment Steps - Properties*, **Save Options** = *Save in Destination*, **Allow edit**); a subflow copied from **Template: Service Fulfillment Steps** (inputs `requested_item`, `service_fulfillment_step_data`, `service_fulfillment_step`; set step data state to canceled, failed or completed); and a **Service Fulfillment Step Configuration** record (order, hide, producer, subflow, **Dynamic title** like `Approval from ${approval_title}`).

## Notifications

Request notifications: **System Notification > Email > Notifications** filtered on tables `sc_request` and `sc_req_item`. The Employee Experience Foundation plugin (`com.snc.sn_ex_emp_fd`) supplies a branded layout. Now Mobile push notifications cover request completed, not processed, rejected, approval assigned and agent comments.

## Related

- [[Catalog Fulfilment Process - Flow, Workflow, Execution Plan or Steps]] (approach) · [[Request Management Data Model and Process]] · [[Order Guides]] (sequenced fulfilment with Playbooks)
