---
type: concept
tags: [concept, flows, automation, domain-separation, ai]
status: documented
source: ServiceNow docs, Australia, Build workflows > Workflow Studio > Flows, subflows, and actions (read 2026-10-08 through the docs site): landing page, Getting started, Build your first flow, Build a flow from a template, Use the help panel, Exploring flows, Architecture Overview, Data pills, Domain separation and Workflow Studio, Generate group approvals for domain separated requests, Exploring actions, Conversational actions (and available / compatibility check), Exploring subflows, Conversational subflows (and available / compatibility check), Flow diagramming view, Flow debugger, Saved flow triggers. Start page https://www.servicenow.com/docs/r/australia/build-workflows/workflow-studio/workflow-studio-flows-subflows-and-actions-landing.html
sn-release: Australia
verified:
updated: 2026-10-08
---

# Flows, Subflows and Actions Overview and Architecture

**In one line:** a flow is a trigger plus a sequence of actions, flow logic and subflows; the platform queues it as an event, compiles it into a process plan, runs it in the background and records the outcome in a flow context.

Built in [[Workflow Studio Overview]]. Administration, execution details, roles and APIs: [[Flow Administration, Execution Details and Access]]. For processes with manual steps see [[Playbooks Overview and Components]].

## Pieces

| Piece | Meaning |
|---|---|
| Trigger | when the flow runs and what data it starts with: record-based (created, updated, deleted), schedule-based, or application-based (Service Catalog, inbound email, SLA task, MetricBase, Kafka message, REST API) |
| Action | a reusable operation with **inputs**, **steps** and **outputs** (for example Create Record, Update Record, Look Up Records, Ask For Approval, Send Email, Log). Core actions ship with the instance; spokes add more |
| Step | one operation inside an action (for example the Create Record step, a Script step, a REST step) |
| Flow logic | If / Else If / Else, For Each, Do the following until, Do the following in parallel, Try, Make a decision, Wait for a duration of time, Set Flow Variables, Call a Workflow, Dynamic Flows, Get Flow Outputs, End Flow, Exit Loop, Skip Iteration |
| Subflow | like a flow but with inputs and outputs instead of a trigger; called from a flow, another subflow, a playbook or a script. Outputs are set with *Assign subflow outputs* |
| Spoke | a scoped application of actions and subflows for one product or integration (the ITSM spoke has incident and problem actions) |
| Data pill | a variable in the Data panel holding trigger data or an action's output; dragged into inputs; named with the sequence number of the action that produced it |
| Error handler | an optional section that runs actions when the flow fails |

The designer has four areas: Trigger, Actions, Error handler, Data panel. Each component shows a plain-language description of what it uses, for example "Incident Created where (Short description starts with ...)". The action picker lists recent and popular actions, installed spokes, core actions and Global-scope actions.

## How a flow is processed

1. Trigger conditions are met (after the database operation; synchronous business rules and workflows normally run first: [[Order of Execution for Rules, Engines and Notifications]]) or an API calls the flow → an entry in the event queue ([[Events and the Event Queue]]).
2. The scheduler picks the event up. Expect a delay between trigger and start.
3. A **process plan** is built: the published actions and subflows, their inputs and steps. It is compiled just in time and cached, so a published action moved in by update set is picked up at the next run without editing the flows that use it.
4. The plan runs as the user and in the application scope set in the flow properties.
5. The outcome is stored in a flow context record: state, duration, logs, values.

Do not change the inputs or outputs of a subflow or action used by active flows: the next run can fail. Runs already in progress keep their compiled copy.

| Context state | Meaning |
|---|---|
| Complete | finished |
| In Progress | running; a transaction quota rule stops flows after one hour by default |
| Waiting | serialised until a task, approval or record condition moves on |
| Canceled | cancelled by a user |
| Error | stopped: a missing input, a quota rule, a failed action |

## Life cycle

| Object | Status |
|---|---|
| Flow / subflow **Status** | *Modified* (unsaved), *Draft* (saved, no process plan), *Published* (has a process plan) |
| Flow / subflow **Active** | true once a flow is activated or a subflow published. Deactivating stops new runs; running ones finish |
| Action | *Draft* or *Published* (field **Draft state** on Action Types `sys_hub_action_type_definition`; not shown in the designer). Draft actions are usable only with **Show draft actions**, and a flow containing them cannot be activated. Turning that option off before publishing removes the draft actions from the flow |

Editing an active flow or published action creates a draft; the active version keeps running until re-activated or re-published.

## Limits and safeguards

| Topic | Rule |
|---|---|
| Size | 50 actions per flow by default (property `sn_flow_designer.max_actions`) |
| **Run Trigger** (Updated, Created or Updated) | *Once* per record, or *Always* (every update, unless a run is already active for that record) |
| Direct recursion | ignored: a flow whose own action re-triggers it, or that calls itself |
| Indirect recursion | stopped after 3 runs by default (property `com.glide.hub.flow_engine.indirect_recursion_limit`, minimum 1) |
| Testing | **Test** bypasses the trigger; a record-based flow needs a record chosen. Build and test on a non-production instance |

## Data pills

- A pill's value is set when the action, logic or subflow that produces it finishes, and it reflects later changes: after an Update Record on the trigger record, the trigger pill shows the new value. (Before Washington DC all pills were populated as soon as data existed.) To keep an original value, copy it into a flow variable first.
- Strings are sanitised against a fixed allow-list of HTML elements and attributes (the same list playbooks use).

## Diagram view and debugger

- **Flow diagramming view** (Store app, installed with Workflow Studio): nodes with paths, **+** on a path to insert, search, zoom, download as PNG, options to show details and annotations. Disabled when the flow contains unsupported logic or triggers (supported triggers: record, date, inbound email, Kafka message, MetricBase, REST API asynchronous, Service Catalog, SLA task).
- **Flow debugger**: open the flow > **Test > Debug**. Set breakpoints; resume, step over, step into a subflow (opens its own tab), step out, skip all breakpoints; inspect configuration and runtime values at each step.

## Saved triggers

A reusable, published trigger definition (role `trigger_designer`; record-based only since Yokohama): table, conditions, and whether authors may see or add conditions. Advanced options:

| Option | Choices |
|---|---|
| Session | only non-interactive, only interactive, or both |
| User | any user, not these users, or only these users |
| Table | current table only, or current and extended tables |
| Where to run | *background* (default, asynchronous) or *foreground* (synchronous in the user's session: immediate, but can block the session; avoid with script actions) |

Changes to a saved trigger reach every flow using it, except options an author overrode in their flow.

## Domain separation

Support level **Standard**.

| Rule | Detail |
|---|---|
| Ownership | content belongs to the domain of its creator (or the domain picked in the domain picker) |
| Run domain | API call: the caller's domain; inbound email: the sender's; record trigger: the record's; scheduled: the flow's; Service Catalog: the requested item's |
| Visibility | only content reachable from the current domain runs; a child domain can trigger a parent's flows, not a sibling's. Record actions read from the current domain and its children |
| No overrides | a flow in one domain cannot stop another's; every visible flow whose conditions are met runs |
| Practice | the provider's admin in the top domain owns and names flows uniquely per domain; a flow may only contain artifacts from its own or parent domains; edit content while in the domain it belongs to |

Group approvals: by default approvals are created for all group members who can access the request, even across domain visibility. Property `com.glide.hub.flow.approval.group_member.use_query_no_domain` = false restricts them to members visible from the request's domain.

## Conversational subflows and actions

A published subflow or action can be exposed as a skill in an AI assistant conversation. Needs the subflows-and-actions skill turned on, inputs of supported types only (strings, numbers, booleans, dates, choices, references, document ids, HTML, email, table name, string arrays) with hint text, and a role for the users. **Conversational compatible** tab > **Run compatibility check** (new items, or *Complete scan*; roles admin, `flow_designer` or `action_designer`, plus `now.assist.creator`). Conversational settings: on / off, assistants that may discover it, required roles, discoverable, shown in topics, keep conversation context, include error messages.

Shipped: actions Add Comments and Work Notes (ITSM spoke), Create Checklist from Template, Create Outage, Create Problem Record from Incident (role `itil`), Send Notification, and some Active Directory and Google Meet spoke actions (admin); subflows Send Email and Send SMS (`sn_conv_fa.csa_email_write`).

## Related

- [[Flow Administration, Execution Details and Access]] · [[Workflow Studio Overview]] · [[Build a Flow in Workflow Studio]] · [[Inbound Email Flow or Inbound Email Action]] · [[Scheduled Jobs]]
