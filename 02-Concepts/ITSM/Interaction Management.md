---
type: concept
tags: [concept, workspace, roles, schema]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage people and work capabilities > Interaction Management (landing, Activating, Configuring: interaction states, context and channel metadata, interaction wrap up, interaction form, wrap up timer, wrap up scheduled job, wrap-up configuration, wrap-up codes, enable codes; Using: create an interaction, associate a record; Reference: components installed), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/interaction-management/interaction-management.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Interaction Management

**In one line:** plugin **Interaction Logging, Routing, and Queueing** (`com.glide.interaction`, also called *Interactions Management*) adds the **Interaction** table (`interaction`), one record per request for help through a channel (chat, phone, walk-up, messaging, Virtual Agent), shared by every product area instead of each building its own queue.

From the Brazil docs; not tested. How agents work interactions in Service Operations Workspace: [[Working Records in Service Operations Workspace]]. Walk-up activates this plugin: [[Walk-up Experience]]. Most interactions are created by the channel applications (chat, AWA, VA), not by hand.

## States

| State | Meaning |
|---|---|
| New | inserted |
| On Hold | waiting for assignment |
| Work In Progress | an agent accepted it |
| Wrap Up | conversation over, agent finishing (only when an active wrap-up configuration matches) |
| Closed Complete | timed out, or agent or consumer closed it |
| Closed Abandoned | consumer disconnected or stopped answering |

Each state can drive routine actions (e.g. on creation set **Opened for** and message the user). Form and list views can be tailored per application, and the table can be extended.

**Context** (initial question, asset, device location; stored by default in `interaction_json_blob`, any table possible) and **channel metadata** (what is needed to talk on the channel; free JSON or a reference) are document ID fields on the interaction.

## Form fields

Number, Type (chat, phone ...), Account, Contact, Consumer, **Opened for**, State, Assigned to, Short description, Work notes; add **Wrap up duration** (seconds in Wrap Up; 0 when the tab was closed) and **System wrap up** (true when the system ended wrap-up) to the form when using wrap-up.

## Wrap up

A period after the conversation for notes and updates; the agent's capacity is **not** freed until Closed Complete. Base system supports chat and messaging. **Interactions > Wrap Up Configuration** (`interaction_wrap_up_configuration`, admin):

| Field | Default | Meaning |
|---|---|---|
| Name, Table (read only), Application | CSM and FSM Configurable Workspace Foundation | |
| Active, Order | true, 100 | lowest order wins among matching configurations |
| Conditions | | e.g. [Type] [is] [Chat] |
| Enforce wrap up duration | false | system ends wrap-up after **Duration in seconds** (default 60) |
| Show duration to agent | false | countdown in the header or side panel (CRM Workspace only): green above 50 %, yellow 50-25 %, orange under 25 %, red at zero then Closed Complete |
| Enable wrap up codes, Allowed wrap up codes, Default wrap up code | | codes from **Interaction > Wrap Up Codes** (Code, Active, Description) offered in the wrap-up dialog |
| Enable AI code, Enable AI notes, Use third party AI, Use AI code as default | | AI interaction wrap up: recommended code and generated notes |

Ending: **End Wrap Up** (to Closed Complete), closing the workspace tab (in Work In Progress this skips wrap-up), or the timer. Fallback: scheduled job **Fallback Timeout for Interactions in Wrap Up** (inactive by default, every 5 minutes) closes records in Wrap Up longer than `com.glide.interaction.max_wrapup_duration` (Max Wrap Up, default 15 minutes; must exceed the enforced duration).

## Manual use

- **Interaction > All** > New (`interaction_agent`): Type, Opened for, Assigned to, State, Short description, Work notes.
- **Interaction > Assigned to me** > open > **Associate Record**: Document table, Record Type (Task or Knowledge), the task or article; stored in `interaction_related_record`; tasks show in **Related Tasks**. You also need access to the associated record.

## Roles and tables

| Role | Can |
|---|---|
| `interaction_admin` | configure interactions (contains `interaction_agent`) |
| `interaction_agent` | create and edit, transfer to agents or queues |

Tables: `interaction`, `interaction_json_blob`, `interaction_related_record`, `interaction_wrap_up_configuration`. Activation (admin): **System Applications > All Available Applications > All**; with domain separation and delegated admin, from the global domain.

## Example

Configuration *Example Chat Wrap Up*: condition [Type] [is] [Chat], Enforce wrap up duration on, 90 seconds, Show duration to agent, codes *Example Resolved* and *Example Escalated* with *Example Resolved* as default.

## Related

- [[Service Operations Workspace for ITSM]] · [[Skills Management]] (skill determination for interaction) · [[Response Templates]]
