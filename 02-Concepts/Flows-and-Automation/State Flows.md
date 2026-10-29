---
type: concept
tags: [concept, automation, scripting, forms-lists]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage service capabilities > Service Administration > State flows (landing, Installed with state flows, Use state flows, Create a state flow, State flow cleanup, Work notes, Domain separation and State Flows), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/c_StateFlows.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# State Flows

**In one line:** a **State Flow** record (`sf_state_flow`) describes one transition of the **State** field on a task-extending table; from it the platform **generates** business rules, UI actions, client scripts and a dictionary override that limit the state choices, perform the transition, set field behaviour and fire events.

From the Brazil docs; not tested. Needs scripting knowledge; records created by `admin`. Field Service Management uses it for work orders (classes *Work Order Flow* `sf_work_order` and *Work Task Flow* `sf_work_task`, for `wm_order` and `wm_task`). **Domain separation: no support** ([[Domain Separation Support Levels by Application]]).

## The State Flow form (**State Flows > State Flows** > New)

| Field | Meaning |
|---|---|
| Table | only tables extending Task (`task`) |
| Starting state / Ending state | the transition; with only an ending state the record applies whenever that state is reached |
| Client script | limits the State choice list to valid next states and applies field controls |
| Event | registered event fired on the transition |
| Name | label (also used for the generated UI action) |
| Roles | not used for processing |
| Active, Class (State Flow, Work Order Flow, Work Task Flow) | |
| Dictionary override | with **Create Default Value**: makes the Ending state the default State of new records on that (extended) table; once created, the button is hidden on other state flows for the table |
| Work notes, Comment | work notes are written to the task on the transition |
| **Manual** section | Manual condition (condition builder) AND Manual condition string (e.g. for mobile), Manual script; **Create UI Action** makes a button named after the record |
| **Automatic** section | Automatic condition AND Automatic condition string, Automatic script; **Create Business Rule** makes a rule that moves the state when the task is in the starting state and the condition is true |
| **Field Controls** | Mandatory, Read only, Visible, Not mandatory, Not read only, Not visible fields, applied on the transition or when the end state is current |

## What gets generated

| Object | Name | Role |
|---|---|---|
| Business rule | *State Flow Events for <table>* | fires the events (one per table) |
| Business rule | *State Flow Notes for <table>* | enforces mandatory fields, adds work notes |
| Client script (onLoad) | *<table> state flow* | valid states and initial field behaviour |
| Client script (onChange) | *<table> change state flow* | field behaviour when State changes |
| UI action / business rule / dictionary override | from the record | manual / automatic transition, default state |

All run in the global scope (server-side business rules, client-side scripts). Script includes `StateFlow` and `StateFlowAJAX`. State flows use client scripts, so **UI policies, which run later, can override** their field controls ([[UI Policies]]).

Advice from the docs: for field controls, create records with **only an ending state** for every state you care about, so the form behaves the same whether the user arrives at or returns to a state; use start + end only for behaviour specific to that exact move. Work notes: a record with a starting state wins over one with only the same ending state.

## Cleanup and moving between instances

- Generated elements live only as long as their state flows: UI action, business rule and override go with their record; the events rule when no state flow with events remains on the table; the onLoad script when no state flow remains; the onChange script when none with field controls remains; the notes rule when none with field controls or work notes remains.
- Importing state flows by XML can leave start / end states blank or numeric (choice sys_ids differ between instances): run **State Flows > Admin > Rebuild State Flows**, which matches by the numeric State value.

## Example

For `incident`, a state flow *Example Awaiting Info* with only Ending state *On Hold*, Field Controls making Caller mandatory and Problem not visible, and Event `example.incident.on_hold` registered beforehand; **Create Client Script** so On Hold is only offered from valid states.

## Related

- [[Business Rules]] · [[UI Actions]] · [[Events and the Event Queue]] · [[Field Administration]] (dictionary overrides)
