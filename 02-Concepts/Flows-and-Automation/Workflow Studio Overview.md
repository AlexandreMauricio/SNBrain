---
type: concept
tags: [concept, flows, workflow, automation, instance-admin]
status: documented
source: ServiceNow Australia Build workflows PDF (210 pp., last updated 2026-09-10), "Build workflows" and "Workflow Studio" (pp. 5-18: product map, classic tools, homepage, operations and integrations pages, choosing between playbooks and flows, process automation roles, configuring and updating Workflow Studio), read in full 2026-10-08
sn-release: Australia
verified:
updated: 2026-10-08
---

# Workflow Studio Overview

**In one line:** Workflow Studio (`sn_workflow_studio`) is the single builder for playbooks, flows, subflows, actions, data stream actions and decision tables, with their execution details and integration connections in the same place.

**Where:** **All > Process Automation > Workflow Studio**. The old menu items (Flow Designer, Process Automation Designer) open the matching list inside it. Each object type opens in its own tab, and several can be edited side by side (for example a flow and the decision table it calls).

## Building blocks

| Object | What it is |
|---|---|
| Flow | automates a repeatable multi-step process: when its trigger conditions are met it runs a sequence of actions, flow logic and subflows |
| Subflow | a reusable sequence called from flows or playbook activities |
| Action | a reusable task made of steps, with inputs and outputs |
| Data stream action | an action that pages through large external data; needs Integration Hub; not used inside flows' siblings (playbooks, decision tables) |
| Decision table | if-then rules that take inputs and return results, keeping decision logic out of code (Decision Builder); can be referenced from flows, subflows, actions and playbooks |
| Playbook | stages of activities on top of flows, subflows and actions, with a user interface for the people doing the work ([[Playbooks Overview and Components]]) |

Classic tools the guide treats as legacy, replaceable by flows or playbooks: classic approvals, classic business rules, classic events ([[Events and the Event Queue]]), classic Workflow (the graphical Workflow Editor). Related products: App Engine Studio, Integration Hub and its spokes, MID Server, RPA Hub, Service Creator, the catalog item designer.

## Pages

| Page | Content |
|---|---|
| Homepage | lists per type, *Pick up where you left off*, *Latest updates*, resources. **Create** is on every page since Xanadu (Playbook, Flow, Subflow, Action, Data Stream, Decision table) |
| Operations | per type (playbooks, flows): dashboards (admin only; for example most executed playbooks, executions by state), monitoring (execution details), setup (settings and properties) |
| Integrations | spokes and connections: add, configure or review a connection from its card |

Settings still live on each application's own properties page.

## Flow or playbook?

| Choose | When |
|---|---|
| Flow | little or no manual user interaction (a flow can wait for a record condition, but offers no UI of its own); high volumes (hundreds to thousands a second; flow reporting is off by default); few subflow calls. Flows use less storage |
| Playbook | several manual interactions (reading an article, a checklist, gathering feedback); low volumes (playbooks generate UI and store more execution detail); a long sequence of subflows that is hard to read as a flow |
| Flow that triggers a playbook | high-volume automation where only some runs need the interactive steps |

## Availability

Workflow Studio, flows, subflows, actions and playbooks are platform features, active by default. Data stream actions need an Integration Hub subscription. Decision Builder installs from the Store. Playbooks can only be triggered from tables your subscriptions cover ([[Playbooks Administration, Roles and Access]]).

**Update** (role admin): a banner announces a new version. **System Applications > All Available Applications > All** > *Workflow Studio* > pick the version > **Update**. This also updates its dependencies (Flow Designer, Playbook, Decision Builder).

## Suggested split of roles

A developer builds flows, actions and activity definitions; a playbook owner assembles them into a playbook; a Playbook Experience administrator decides how it is shown; agents work through it.

## Not in this PDF

The published PDF ends at page 210, inside the Playbooks chapter (the user confirmed this is the full file ServiceNow offers). The rest of the guide was read from the docs site on 2026-10-08:

| Chapter | Notes |
|---|---|
| Playbooks, remaining pages | [[Playbook Patterns and Runtime Use]], [[Playbook Activities Reference]] |
| Agentic Playbooks | [[Agentic Playbooks]] |
| Flows, subflows and actions | [[Flows, Subflows and Actions Overview and Architecture]], [[Building Flows - Properties, Triggers, Stages and Error Handling]], [[Subflows in Workflow Studio]], [[Custom Actions, Dynamic Inputs and Error Evaluation]], [[Saved Triggers and External Event Sources]], [[Flow Authoring Aids - History, Variables, Inline Scripts and AI]], [[Flow Administration, Execution Details and Access]], and the references [[Flow Core Actions Reference]], [[Flow Logic Reference]], [[Flow Trigger Types Reference]], [[Flow Action Steps Reference]], [[Flow Data Types and Transform Functions]], [[Flow System Properties Reference]], [[Flow Spokes Shipped with the Platform]] |
| Decision tables | [[Decision Tables]] |
| Spoke Generator | [[Spoke Generator]] |
| Intelligent approvals, Classic approvals | [[Intelligent Approvals]], [[Classic Approvals]] |
| Classic Business rules | [[Business Rules]] |
| System Events | [[Events and the Event Queue]] |
| Service Creator | [[Service Creator]] |
| Classic Workflow | [[Classic Workflow Overview]], [[Classic Workflow Activities Reference]], [[Classic Workflow Stages, Validation and Update Sets]], [[Classic Workflow Administration and Troubleshooting]] |

## Related

- [[Playbooks Overview and Components]] · [[Playbook Activities, Decisions and Variants]] · [[Playbooks Administration, Roles and Access]] · [[Playbook Experience Design for Workspace, Portal and Mobile]] · [[Scheduled Jobs]] · [[Inbound Email Flow or Inbound Email Action]]
