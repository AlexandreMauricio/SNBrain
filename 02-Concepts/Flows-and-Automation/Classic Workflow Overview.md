---
type: concept
tags: [concept, workflow, automation, scripting, roles, domain-separation, javascript]
status: documented
source: ServiceNow docs, Australia, Build workflows > Classic Workflow (read 2026-10-08 through the docs site): Classic Workflow, Getting started with workflows, Workflow editor (palette, title bar, keyboard navigation, welcome page and canvas keyboard commands), Workflow management, Create a workflow (properties, from a table, for a catalog item, for an SLA definition, ending workflows with multiple branches), Work on workflows, Workflows used as subflows (pass a variable, prepare a subflow), Using variables in a workflow, Workflow catalog variables, Workflow concepts (versions, scope, domain separation, data separation, engine operation order, tables), Workflow roles. https://www.servicenow.com/docs/r/australia/build-workflows/legacy-workflow/c_WorkflowOverview.html
sn-release: Australia
verified:
updated: 2026-10-08
---

# Classic Workflow Overview

**In one line:** the legacy graphical Workflow Editor: a workflow is a flowchart of *activities* joined by *transitions*, attached to a table, and each run is a *workflow context*.

**Status:** legacy. Since Zurich new instances no longer receive the workflows ServiceNow used to ship (their logic is now flows); upgraded instances keep theirs. Workflows can still be created everywhere, but only Workflow Studio gets new features ([[Flows, Subflows and Actions Overview and Architecture]]). The editor works properly only in Core UI, not Next Experience.

Activities: [[Classic Workflow Activities Reference]]. Stages, validation, update sets: [[Classic Workflow Stages, Validation and Update Sets]]. Operations: [[Classic Workflow Administration and Troubleshooting]].

## Parts

| Part | Is |
|---|---|
| Properties | name, table, start condition and the rest (below) |
| Activities | the operations: create a task, ask for approval, run a script, wait |
| Exit conditions | on each activity, evaluated when it finishes (for example Approved / Rejected) |
| Transitions | the line from an exit condition to the next activity. Several lines from one condition run concurrently |
| Context (`wf_context`) | one run, with its history |
| Version (`wf_workflow_version`) | one design state: published, or checked out by one user |

A run follows every transition whose condition matches and is complete when it reaches **End**, even if other branches are still running (they are cancelled). To make branches wait for each other, bring them into a **Join** before End.

## How a workflow starts and who it runs as

- Start: a record inserted in its table that matches its condition; a reference from a record (a catalog item's **Workflow**, an SLA definition's **Workflow**); a schedule; a script.
- Run as: the session that caused the step. A record operation runs it as that user; a schedule or an expiring timer runs it as System; a script call as the caller. After a wait, the workflow continues as whoever ended the wait (the approver, the person closing the task).

```javascript
// Server-side (business rule, script include, UI action), global scope: start a workflow with inputs
var wf = new Workflow();
var wfId = wf.getWorkflowFromName('Example Workflow');
wf.startFlow(wfId, current, current.operation(), { u_example_input: 'value' });
```

The docs' own example passes `null` as the record and the workflow name as third argument; the form above follows the Workflow script include API (general knowledge).

## Editor

**Workflow > Workflow Editor**. Welcome page (Published / Checked Out / Help), then a canvas per open workflow and a palette: **Workflows** (usable as subflows), **Core** (activities valid for this workflow's table), and with Orchestration **Packs**, **Custom**, **Data**.

Title bar menu: New Workflow, Open Existing, **Copy**, **Publish**, **Checkout**, Delete (not when contexts exist), **Set Inactive**, Expand / Collapse Transitions, Start Workflow (only for Global-table workflows; others are tested by inserting a matching record), **Validate Workflow**, **Show Contexts**, **Properties**, **Edit Inputs**, **Edit Stages**. Keyboard: Tab between elements and activities, Enter to edit, arrows to move a selected activity (Shift for one pixel).

## Checkout and publish

- Editing needs **Checkout**: a personal version only that user sees and runs. Everyone else keeps running the published version. **Publish** replaces it for all.
- Contexts already running keep the version they started with.
- A workflow can run only if the user has it checked out, or a published active version exists. A subflow with neither blocks its parent (a critical entry is written to the context log).
- Workflows of a read-only application cannot be checked out.
- Names are not unique (sys_id is): keep them unique anyway.

## Properties

| Section | Fields |
|---|---|
| General | **Name**, **Table** (Global = any table; only tables of the workflow's scope are listed), **Description**; read-only Checked out, Checked out by, Published |
| Conditions | **If condition matches**: *None* (start only by script), *Run the workflow* (default), *Run if no other workflows matched* (only when no other workflow runs on that record); **Condition**; **Order** (lowest first). Hidden for tables that start workflows by reference, such as Requested Item (`sc_req_item`) |
| Inputs | variables accepted when used as a subflow or started by script |
| Activities | **Activity pinning** (Set by activity / Pin all / Unpin all); **Max activity count** (default 100; the workflow is cancelled when reached, a guard against loops) |
| Application | scope (read-only) and **Accessible from** |
| Schedule | **Delivery based on** a user-specified duration (**Expected time**) or a relative duration with **Schedule** and **Timezone** |
| Stages | **Stage** field, **Stage rendering**, **Stage order** |
| Estimated Runtime | **Requires ERT**, **Estimated Run Time**, **Outlier Percentage Threshold for ERT** (20) |

Other entry points: a table's list header > **Configure > Workflows**; a catalog item's **Process Engine** tab > **Workflow** > New (table fixed to `sc_req_item`); an SLA definition's **Workflow** field.

## Variables

| Kind | Declared | Read / written |
|---|---|---|
| Activity variables | on the activity definition (`wf_activity_definition`) | `activity.vars.<name>` |
| Workflow inputs | **Edit Inputs** (stored in Variables `var_dictionary`) | `workflow.inputs.<column name>`. Not available for workflows on `sc_req_item` |
| Scratchpad | nowhere: created on first use | `workflow.scratchpad.<name>`; shared by all activities of the context; history in `wf_history_scratchpad` |
| `current` | the triggering record | `current.<field>`. Changes are saved by the engine: **never `current.update()`** |
| Catalog variables | on the catalog item, or global (no item) | `current.variables.<name>`; chosen per Catalog Task activity to show on the task |

In activity fields, `${field}` and `${workflow.scratchpad.name}` substitute values.

## Subflows

Drag a workflow from the **Workflows** tab onto another: the parent waits for it to complete.

- The subflow declares **inputs**; the parent fills them on the subflow activity with values or `${...}` variables.
- **Return Value** activity in the subflow (on every ending path) hands a value back to the parent's scratchpad.
- The subflow must be active and published (or checked out by the same user); otherwise the parent hangs. Validation catches it.
- A subflow containing **Create Task** that runs twice in one parent reopens the first task instead of creating a second: use separate subflows or create the task in a Run Script.

## Scope and domains

- A workflow takes the scope the author was in; it cannot be changed, only copied into another scope (and only if **Accessible from** is *All application scopes*). Scripts in its activities run in that scope.
- A privately scoped workflow calling global resources (tasks, approvals, events, timers, script includes) fails or hangs: check accessibility before deploying.
- Domain separation: workflows are *process* (a child domain checking out a parent's workflow creates its own overriding copy); contexts are *data* (visible in their domain and its parents). A resumed workflow uses the credentials of the user who resumed it but stays in the original user's domain.

## Roles

| Role | Can |
|---|---|
| `snc_required_script_writer_permission` | required with any of the below to use the editor and script |
| `workflow_admin` | check out, create, edit, publish, delete. **Equivalent to admin**: script activities bypass ACLs (not scope) |
| `workflow_creator` | the same without publish. Also admin-equivalent |
| `workflow_publisher` | force checkout, validate, publish, delete |
| `activity_creator` | custom (Orchestration) activities |
| `web_service_admin` | REST and SOAP in the activity designer |

## Engine order and tables

The workflow engine runs **default** workflows among the *before* engines and **deferred** ones (property *Run after bus. rules run*) after the write: [[Order of Execution for Rules, Engines and Notifications]]. Up to 300 published versions are cached (`glide.workflow.model.cache.max`; restart needed).

| Table | Holds |
|---|---|
| `wf_workflow`, `wf_workflow_version` | workflows and their versions |
| `wf_activity`, `wf_condition`, `wf_transition` | the design |
| `wf_activity_definition`, `wf_element_activity` | activity types; custom activity definitions |
| `wf_context`, `wf_executing`, `wf_history`, `wf_transition_history`, `wf_log` | runs: context, executing activities, history, log |
| `wf_workflow_binding` | which workflow ran for which record; stops a re-run after a context is deleted |
| `wf_workflow_execution` | stand-in "current" records for Global workflows |
| `wf_command` | queued events of parallel threads |
| `wf_workflow_schedule` | scheduled workflows |
| `wf_stage`, `stage_set`, `stage_set_entry`, `stage_set_table` | stages |
| `wf_estimated_runtime_config`, `wf_workflow_timing` | run time metrics |

## Related

- [[Classic Workflow Activities Reference]] · [[Classic Workflow Stages, Validation and Update Sets]] · [[Classic Workflow Administration and Troubleshooting]] · [[Flow Logic Reference]] · [[Classic Approvals]]
