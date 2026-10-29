---
type: approach
tags: [approach, service-catalog, request, flows, workflow]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog, topics "Service Catalog request fulfillment", "Execution Plans", "Service catalog workflows", "Configure a step-based service fulfillment flow", "Define a service fulfillment step", "Catalog Item form", https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/request-fulfillment.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Catalog fulfilment process: flow, workflow, execution plan or service fulfillment steps

**Problem:** decide how a catalog item gets approved and fulfilled after it is ordered. An item takes exactly one process engine.

## Options

### A. Workflow Studio flow (Service Catalog trigger)
- **How:** set the item's **Flow**; flow uses Get Catalog Variables, Ask for Approval, Create Catalog Task. See [[Catalog Fulfilment - Flows, Workflows and Execution Plans]].
- **Pros:** current tool, no code needed, handles MRVS rows, reusable subflows, works with Catalog Builder and AI authoring.
- **Cons:** each item's flow is still built by an admin or developer unless steps (D) are used.
- **Status:** documented
- **Best when:** default choice for new items.

### B. Legacy workflow (on `sc_req_item`)
- **How:** Workflow Editor, then the item's **Workflow** field.
- **Pros:** branching, approvals, rollback; existing processes keep working; base workflows ship with the platform.
- **Cons:** legacy editor; catalog tasks needing variables must come from the parent workflow; domain copies must be assigned explicitly.
- **Status:** documented
- **Best when:** the instance already runs catalog workflows and migration is not planned yet.

### C. Execution plan
- **How:** **Catalog Administration > Execution Plans**, task templates with groups, order, conditions; item's **Execution plan**.
- **Pros:** one plan serves many items; simple linear tasks; can be built by script or import; approval rollback to an earlier task.
- **Cons:** linear only, no graphical editor; the docs recommend workflows (and now flows) instead; Catalog Builder cannot change the engine of an item that has one, and AI cannot add a flow to it.
- **Status:** documented
- **Best when:** maintaining old items, or bulk-generated simple processes.

### D. Service fulfillment steps (Catalog Builder)
- **How:** item uses a registered step-based flow (base: *Step-based request fulfillment*); the business owner adds Task, Custom approval and Manager approval steps in the builder's Fulfillment step.
- **Pros:** business owners define fulfilment themselves; conditions on the item's questions; parallel groups; custom step types possible.
- **Cons:** limited to the step types provided; custom types need a table, record producer, subflow and configuration record.
- **Status:** documented
- **Best when:** delegated catalog ownership with simple task-and-approval fulfilment.

## Comparison

| | Flow | Workflow | Execution plan | Steps |
|---|---|---|---|---|
| Editor | Workflow Studio | Workflow Editor | form records | Catalog Builder |
| Branching | yes | yes | conditions per task only | conditions and parallel groups |
| Owner | admin / developer | admin | admin | business owner |
| Status in docs | current | legacy | discouraged | current |

## Decision

Use a flow (A) for new items, steps (D) on top of a flow when owners build items in Catalog Builder, keep (B) and (C) only for existing items.

## Related

- [[Approaches to Auto-Assigning Tasks]] · [[Workflow Studio Overview]] · [[Classic Workflow Overview]]
