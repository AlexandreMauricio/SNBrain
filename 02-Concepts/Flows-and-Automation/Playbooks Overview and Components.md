---
type: concept
tags: [concept, flows, automation, workflow, ai, domain-separation]
status: documented
source: ServiceNow Australia Build workflows PDF, "Workflow Studio Playbooks" (pp. 18-29: exploring Playbook, builder, components, runtime, HTML sanitization, AI capabilities, domain separation; pp. 56-75: building playbooks, components, triggers, scheduled triggers, stages and activities; pp. 138-142: playbook properties and creation; pp. 158-164: testing, restart, duplication), read in full 2026-10-08
sn-release: Australia
verified:
updated: 2026-10-08
---

# Playbooks Overview and Components

**In one line:** a playbook is a business process modelled as a trigger plus stages of activities, each activity backed by a flow, subflow or action and optionally shown to the person doing the work as a card.

**Where:** **All > Process Automation > Workflow Studio > Playbooks** ([[Workflow Studio Overview]]). Step-by-step: [[Create and Test a Playbook]]. Activity types and branching: [[Playbook Activities, Decisions and Variants]]. Roles and admin: [[Playbooks Administration, Roles and Access]]. Runtime UI: [[Playbook Experience Design for Workspace, Portal and Mobile]].

## Components

| Component | Meaning | Table |
|---|---|---|
| Playbook (process definition) | trigger + stages + activities | `sys_pd_process_definition` |
| Trigger definition | reusable template: record operation, table, conditions | `sys_pd_trigger_definition` |
| Trigger instance | the trigger as configured on one playbook | ? |
| Stage | a logical group of activities with a start rule | ? |
| Activity definition | maps a subflow or action's inputs and outputs (the *automation plan*) and how the card looks (the *activity experience*) | `sys_pd_activity_definition` |
| Activity instance | an activity definition placed in a playbook, with its own input mappings | ? |
| Start rule | when a stage or activity starts, which sets what runs in parallel and what runs in series | |
| Process execution | one run of a playbook | Process Execution (`sys_pd_context`) |
| Activity execution, stage context | one run of an activity / stage | `sys_pd_activity_context`, `sys_pd_lane_context` |

## What happens at run time

1. The trigger conditions are evaluated.
2. An event is processed and the playbook starts in the background.
3. The automation plans of all activities are built into one process plan, which runs.
4. Execution details are stored in `sys_pd_context`.
5. Data is served to the Playbook Experience, if one is configured, so agents can work the cards.

## Builder

Header: status, **Diagram** / **Board** view, undo and redo, error tray, **Optional activities** toggle, **Test**, **Activate**; **More actions**: Properties, Duplicate, Deactivate, Summarize. Decisions can only be *added* in Diagram view; optional activities only in Board view. The side panel configures the selected stage or activity (Details, Automation, UI Layout, runtime permissions, AI agent). A playbook changed after activation is saved but **deactivated** until activated again.

## Playbook properties

| Property | Meaning |
|---|---|
| **Playbook name**, **Application**, **Description** | Global scope lets it run in any scope |
| **Execution type** | *Record driven* (tied to a record, triggered automatically or on demand, data stored on the record) or *Standalone* (single session, no record; started manually or from another playbook) |
| **Parent table** | supplies the trigger record and data pills; required before triggers can be opened and for Knowledge and Email activities |
| **Limit playbook executions for each parent record to** | maximum runs per record |
| **Allow this playbook to be restarted during runtime** | see Restart |
| **Inputs** tab | named inputs, used as `inputs.<name>` anywhere in the playbook |
| **Runtime permissions** tab | users, groups, user criteria and roles |
| **Run my trigger** | *Once* (once in the life of the record), *Only if not currently running*, *For every update* |

A playbook can also be started from script with `triggerPlaybook(String scopedName, GlideRecord parentRecord)` (Playbook Experience API on the developer site; server-side; the guide gives no namespace). A playbook can be activated with no trigger at all for that purpose. Developers can also author playbooks as code with the Fluent DSL in the ServiceNow IDE or SDK.

## Triggers

Up to 10 per playbook, record-based or scheduled, in any mix.

| Type | Options |
|---|---|
| Record based: *When record is created*, *updated*, *created or updated* | a different table than the parent table; **Run this trigger on extended tables**; **Trigger on unique values** (fires once per distinct change of a non-system field, so State going back to an earlier value does not fire again); conditions. Or **Choose existing playbook trigger** |
| Scheduled | **Time zone**, **Start date and time**, **Repeat** (Daily, Weekly with weekdays, Monthly or Yearly on a fixed day or relative weekday, Time interval `hh:mm:ss`, Does not repeat), optional end; conditions, a record limit up to 1000 and a sort field |

- Record triggers fire only for **interactive** operations by users, not for non-interactive sessions, and ignore records arriving by update set or XML import.
- Give each playbook on the same table a distinct condition: with identical filters the order is undefined.
- Playbook triggers do not replace flow triggers: both run. Deactivate business rules, flows or workflows a playbook replaces.
- *Trigger on unique change* can recurse when a non-interactive run updates its own trigger record.
- Reactivating an edited playbook can make it run again for an already fulfilled trigger; unique values prevents that.
- Trigger table and type cannot be changed after the playbook is created.

Custom trigger templates: **Process Automation > Process Automation Administration > Trigger Definitions > New** (**Label**, **Trigger Type**, **Table**, **Condition**, **Run On Extended**); roles admin, `playbook.admin` or `pd_trigger_author`.

## Stages and activities

| Setting | Stage | Activity |
|---|---|---|
| **Label** | shown at run time; keep short (truncated) | same |
| **Description** | builder only | builder only |
| **Start Rule** | *When playbook starts* or *After specific stages* | *When stage starts* or *After specific activities* |
| **Run condition** | runs only if met; can use data from earlier activities | same |
| **Display order** | order among items running at the same time | same |
| **Start with delay** | wait before running | same |
| **Restart rules** | Skip on restart, Run always, Skip on first run | same |
| **Runtime permissions** | who may add optional activities or restart | |

Activity inputs (Automation tab) take fixed values or data pills from the trigger, the parent record, playbook inputs or the outputs of earlier activities (when the start rule is *After specific activities*). Dot-walking works through Reference fields, not Document ID or Sys ID. Model stages on the record's existing state model where there is one.

## Test, restart, duplicate

- **Test** (roles admin, `playbook.admin`, `pd_operator`; preview needs Playbook Experience `sn_playbook_exp`): pick any existing record; trigger conditions are ignored; **Run Test**, then *Process execution details* and *Playbook preview*. Tests create and change real records, so use a non-production instance.
- **Restart**: on for new playbooks; for older ones tick the property. **Once enabled it cannot be disabled.** A playbook can be restarted only while In Progress; a stage or activity only when Complete or in Error. Stage rules do not cascade to activities. Do not make the last activity *Skip on first run* without a parallel path, and do not put all *Skip on first run* activities in one stage (it stays hidden on the first run).
- **Duplicate** (admin, `playbook.admin`): tick one playbook in the list > **Duplicate**: copies trigger, stages, activities and experience settings; the table cannot be changed.

## Security and domains

- Strings are sanitised against an allow-list of HTML elements and attributes (common text, table, list, media and layout tags with `class` and a few attributes each); anything else is stripped. The list cannot be changed.
- Domain separation: **Basic** level. A playbook runs in the domain of the record or user that triggered it; the flows it calls run in that domain and honour flow process overrides (playbooks themselves have none). Playbooks, trigger definitions and activity definitions are not domain-separated: visible to anyone with the roles.

## AI

| Capability | Needs |
|---|---|
| Generate a playbook from text, an image or a knowledge article; recommendations for placeholder activities; summaries | ServiceNow Otto for Creator skills ([[Playbooks Administration, Roles and Access]]) |
| Agentic playbooks; an AI agent or an AI skill as an activity | AI agents ([[Playbook Activities, Decisions and Variants]]) |

## Related

- [[Workflow Studio Overview]] · [[Playbook Activities, Decisions and Variants]] · [[Playbooks Administration, Roles and Access]] · [[Playbook Experience Design for Workspace, Portal and Mobile]] · [[Investigation Framework, CI Actions and Remedial Actions]]
