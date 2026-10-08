---
type: reference
tags: [reference, flows, automation, workflow, ai, forms-lists]
status: documented
source: ServiceNow Australia Build workflows PDF, "Building Playbooks" (pp. 75-138: activity definitions, creating an activity definition and its action, UI layouts, adding activities, AI agent and AI skill activities, automation assets, start with delay, optional activities, decision activities and stages, questionnaire, Go back, parallel branches, dynamic inputs, activity state mapping, playbook variants and evaluation points), read in full 2026-10-08
sn-release: Australia
verified:
updated: 2026-10-08
---

# Playbook Activities, Decisions and Variants

**What it is:** the things that can be placed in a playbook and how each is configured. Basics (stages, start rules, triggers) are in [[Playbooks Overview and Components]].

## Activity definitions

Table Activity Definition (`sys_pd_activity_definition`); **Process Automation > Process Automation Administration > Activity Definitions**, or **Create a new activity** in the activity picker. Roles admin, `playbook.admin`, `pd_content_author`.

| Part | Fields |
|---|---|
| Basics | **Label**, **Table** (records usable as inputs, usually Task or Global; the playbook's own table overrides it at design time), **Application**, **Accessible From** (all scopes or this scope only), **Required Roles** (others see activities using it read-only; only `playbook.admin` can edit this field), **Description** |
| Automation Plan | **Flow or Action**: a *published* subflow or action. Its inputs become variables: set defaults, or leave blank for the playbook author. Per variable visibility: *Always show*, *Show as additional property*, *Show as additional property for Playbook admins only* |
| Activity Experience | **UI Layout**, the **Associated table** / **Associated record** whose data the card shows (usually an output of the subflow or action), then layout-specific fields. Buttons come from the related list *Playbook Experience Action Assignment Map* (an action assignment + the experience it appears in) |
| AI Agents (form-based activities) | **On**; **Child Agents**, **Run as**, **AI agent instructions**, **Autonomous support** with **Supported actions** (Update Record, Create Record, Mark Complete) and autonomous instructions. Modes: *Collaborative* (the agent fills values, a human approves) or *Autonomous* |

Do not use a *triggered flow* as an automation plan (it could also run outside the playbook): use subflows or actions. Preset sensible defaults.

**Automation assets**: tick **Include all automation assets** in the activity picker to drop a flow, subflow or action straight into a playbook. A hidden, non-reusable activity definition is created. Use when no UI and no reuse is needed.

### UI layouts

| Layout | Sections beyond *Associated Record* (associated table and record, experience status table and record) |
|---|---|
| Create Record | Details (tagline, icon, title, description, pending state title and description, record fields, footer); Form (form view, form fields, template fields); Attachments; Features (Show SLA, Show Checklist, Is Automated) |
| Record | the same without template fields |
| Questionnaire | Details, Form, Attachments, Features |
| Instructional | Details (tagline, icon, title, description, footer); Is Automated |
| Knowledge | Knowledge (table, record); title, footer; Is Automated |
| List | Details; List Details (list title, table, list query, UI view, columns, max columns, row count); Is Automated |
| Record generator | creates a record at run time and sends the user to it: template fields, process definition scoped name, associated table, form view. No Associated Record section |
| Guided Decision | decision tree execution, decision tree. Needs App Engine or Customer Service Management |

## Common activities named in the guide

| Activity | Category | Notes |
|---|---|---|
| Create New Record | non-interactive | table and field values; values can be data pills from the parent record |
| Wait For Condition | interactive | pauses until a record meets a condition |
| Instruction | interactive | a message; **Wait for user input** |
| Questionnaire | interactive | below |
| Create Record Form, Record Form (User Form), Knowledge, Send Email | | named as MCP-compatible types |
| Use an AI agent, Use an AI skill | | below |
| Placeholder | | left by AI generation; must be replaced before activation |
| Collect user data | | retired from the picker in 26.1; replaced by Questionnaire |

### Questionnaire

Collects answers for use later in the same playbook; no table or data definition needed. Use a User Form activity instead when a table exists or the data must be reported on. **Questionnaire** tab > **Create questionnaire** > **Add question**: question text, **Required question**, **Type of answer**, **Max answer length**. A required question blocks submitting, not skipping the activity. Access: **Assignment Group / Assigned to this Process Step** (default: those of the trigger record; if both empty anyone can read and edit the answers). Output **Record** (Flow Data): dot-walk *Outputs > Record > Vars*. Editing a questionnaire does not affect executions already running.

### AI agent and AI skill

| Activity | Fields | Needs |
|---|---|---|
| **Use an AI agent** | **AI agent**, **Objective** (text plus data pills), **Run as** (active user, user who triggered the playbook, user who completed a prior activity), **Expected outputs**; optional **Assigned to**, **Assignment group** (who may complete, skip or restart while the agent works), **Conversation label** | AI agents plugin. The user talks to the agent inside the playbook card (**Start Now Assist**), and confirms what it proposes |
| **Use an AI skill** | **AI skill**, then inputs that load from the skill | Call Now Assist Skill Step plugin. One-shot tasks (sentiment, text generation); outputs are data pills and can drive a decision or a variant |

## Start with delay

On stages and common activities (not Placeholder), under *Show additional options*.

| Input | Meaning |
|---|---|
| **Duration Type** | *Explicit* (for example 5 minutes), *Relative* (before or after a date/time pill; past dates do not shorten the wait), *Percentage* (a share, 0-100, of the time until an end date; a past end date gives 0) |
| **Wait for** | up to 999 hours; actual wait can be longer because of queue load |
| **During the following schedule** | a Schedule (`cmn_schedule`) so the end falls in working hours |

## Flow control

| Element | How | Rules |
|---|---|---|
| Optional activity | Board view > toggle **Optional activities** > add to the swimlane. *Global* ones can be inserted anywhere by the agent, stage ones only in that stage | the experience page needs the Playbook Modals component |
| Decision (activity or stage) | Diagram view > **+** > diamond. **Branches** tab: label and condition per branch (only in the side panel); with several branches choose *process all that are true* or *only the first true* (drag to order) | role `playbook.admin`. Stage decisions show the agent only the relevant stages |
| Parallel branch | Diagram view > **+** > parallel icon | every branch runs |
| Go back | **+** > **Add a Go back** inside a decision branch (a decision is inserted if missing). Target: an earlier **Activity**, a **Stage**, or **Start of Playbook** | the decision needs a forward branch and *first true only* evaluation; no un-gated parallel forward branch; the Go back is the last and only one in its branch; the target must come earlier, must not be another Go back, and must have restart configured |
| Dynamic inputs | an action whose script step outputs JSON describing fields, consumed by a subflow or action with a dynamic input, used as the automation plan; set the input to *Always show* | lets a choice (for example a catalog item) decide which further inputs appear |

## Activity state mapping

A card's state normally comes from the flow behind it: Pending, Ready, In Progress, Complete, Skipped, Error, Canceled. An activity definition can instead name an **Experience Status Record** (default: the `sys_flow_data` record; any table works). Mapping rules per Experience Status Table sit on the experience's **Status Mapping** tab, in both directions (*Experience Status to Activity State* for what the card shows; *Activity State to Experience Status* for what is written back on complete or skip). Rules ship for `sys_flow_data` and `task`.

*Can Complete* / *Can Skip* buttons appear only if the status record is defined, the user can write to it and to its status field, a rule set exists for the table, and a mapping exists for Complete or Skipped. Without read access to the status field the flow's own state is shown.

## Variants

Variations of one base playbook, instead of copies or tangled run conditions (for example per region, per card network, per job level). Roles admin or `playbook.admin`.

- Variant panel > **Add a variant**: **Variant name** and **Conditions**. Child variants nest up to 6 levels and inherit the parent's conditions; sibling variants sit at the same level.
- Evaluated top-down at each level; the **first** match runs. Reorder by dragging within a level.
- By default evaluated at the start. A **variant evaluation point** (**+** > variants icon) moves evaluation after a chosen activity, so earlier outputs can decide. No variant-specific activity may sit before the point, and conditions cannot refer to later activities.
- In a variant, inherited activities are greyed; changed ones show an *overridden* marker and can be re-synced. Stage properties cannot be overridden.
- A variant can be marked **Favorite**.

## Related

- [[Playbooks Overview and Components]] · [[Playbooks Administration, Roles and Access]] · [[Playbook Experience Design for Workspace, Portal and Mobile]] · [[Create and Test a Playbook]]
