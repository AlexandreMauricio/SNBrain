---
type: reference
tags: [reference, workflow, automation, update-sets, service-catalog, forms-lists]
status: documented
source: ServiceNow docs, Australia, Build workflows > Classic Workflow (read 2026-10-08 through the docs site): Workflow stages (use, add and translate, stage sets, create a stage field, select a stage field, display approvers, icons and tooltips, stage renderers, fields with deleted records), Workflow validation, Workflow validator and each validator page (ValidateTransitionOut, ValidateTransitionIn, ValidateDanglingTransition, ValidateSubflows, ValidateScriptForCurrentDotUpdate, ValidateLowestCommonTable, ValidateTableChange, ValidateParentFlow, ValidateSingleEnd, ValidateUpdateSetDependencies, ValidateUpdateSetParentDependencies, ValidateInputVarUpdateSetDependencies, ValidateWorkflowEndStages, ValidateWorkflowStageColumn, ValidateWorkflowStateValues), Workflow movement with update sets, Input variable movement (two input variables, removal, avoiding duplicate workflows). https://www.servicenow.com/docs/r/australia/build-workflows/legacy-workflow/c_WorkflowStages.html
sn-release: Australia
verified:
updated: 2026-10-08
---

# Classic Workflow Stages, Validation and Update Sets

**What it is:** three design-time topics of the legacy Workflow Editor: showing progress with stages, the validator that runs before publishing, and how workflows travel in update sets. Context: [[Classic Workflow Overview]].

## Stages

A workflow can write its progress into a **stage field** of the record. Each activity may name a **Stage**; when the activity starts, the engine sets that stage on the record.

- On Requested Item (`sc_req_item`) the stage field is always **Stage** (`stage`) and cannot be changed. On other tables choose it in **Properties > Stages > Stage field**.
- A field of type **Workflow** shows the stages as icons in lists (pending, in progress, approval pending or rejected, complete, cancelled / late, skipped) and as a value on forms.
- State shown per stage follows the activities: an active activity = *In progress*; pending and completed likewise; a cancelled activity shows *Request Cancelled*.
- One stage can serve several activities (Order equipment, Receive equipment, Add to CMDB all = *Order*).
- Available stage values combine: the field's choices, default stages for the table, the workflow's own stages (`wf_stage`, **Edit Stages**), and values already in records.

### Stage sets

**Workflow > Stage Sets**: a named list of stages (name, value, order). **Workflow > Default Stages (by table)** assigns a set to a table so new workflows on it start with those stages. In **Edit Stages**: **Import from Stage Set**, **Export to Stage Set**; in the properties' Stages tab: **Import Stages from Choice List**. Stages with the same value appear once.

### Making a stage field

1. Add a field of type **Workflow** to the table; in its dictionary entry set a choice list (*Dropdown with --None--*).
2. Create one choice per stage: choice **Value** = stage **Value**, no spaces (underscores). Upgrades lower-case stage values and replace special characters with underscores.
3. Keep the field read-only: changing it by hand, by business rule or by script breaks the display.
4. Add it to the list layout to see the icons, and select it as the workflow's stage field.

Translate stage names in **Edit Stages** (or `wf_stage`) while using the target language; never change the **Value**. Form display uses the choice labels, so translate those too.

### Renderers (Properties > Stages > Stage rendering)

| Renderer | Shows | Use |
|---|---|---|
| **Workflow-driven** (default) | stages along the expected path, including subflows; paths not taken drop out | almost always |
| **Main flow** | only the parent workflow's stages | hide subflow detail |
| **Linear** | all stages of parent and subflows in the user-specified order, whatever path runs | loops and rework that should not show. Parent and subflows must use the same record, the same stage field and the same stages (share a stage set) and all be set to Linear |
| **Progress bar** | one bar, equal share per stage | many stages; needs *User Specified* stage order |
| **Legacy**, **Requested item** | pre-Dublin behaviour (the second for `sc_req_item`) | only to preserve old behaviour; can report wrong data |

**Stage order**: *Computed* (from the execution order) or *User Specified* (the stages' **Order**).

Approver names inside stage fields: properties `glide.workflow.renderer.workflowdriven.show_approver` (true), `...linear.show_approver` (false), `...mainflow.show_approver` (false), `glide.workflow.renderer.show_approver_limit` (5); give each approval activity a stage. The tooltip's approver name is a Service Catalog property. If a subflow has stages, the parent must have them too. When the context of a requested item is deleted its stages can no longer be drawn (a message shows instead).

## Validation

Runs automatically on publish and on the first run on a node; by hand with the **Validate** icon or **Workflow Versions > Validate Workflow**. The report lists each check with level and message; the overall level is the worst one.

| Level | Publish? |
|---|---|
| Info | yes |
| Warning | yes (a dialog asks to validate first) |
| Critical | no, and the workflow will not run: a critical entry goes to the context log instead |

| Validator | Level | Finds |
|---|---|---|
| ValidateDanglingTransition | **Critical** | a transition whose target is null: invisible on the canvas, hangs the run. Fix: on the workflow version add the *Workflow Activity* related list, open the activity named, delete the transition with an empty **To** |
| ValidateSubflows | **Critical** | a subflow that is inactive, deleted, or not published for this user (for example checked out by someone else with no published version; or missing after an incomplete update set) |
| ValidateTransitionOut | Warning | a condition with no outgoing transition (may be intended) |
| ValidateTransitionIn | Warning | an activity nothing leads to (often a line that passes behind it) |
| ValidateSingleEnd | Warning | more than one End. Harmless when the paths are mutually exclusive; otherwise the first End reached cancels the rest: use a Join and one End |
| ValidateScriptForCurrentDotUpdate | Warning | `current.update()` in an activity script: slow at best, recursive at worst. The engine saves `current` |
| ValidateTableChange | Warning | activities not valid for the workflow's table |
| ValidateLowestCommonTable | Info | the lowest table the activities require |
| ValidateParentFlow | Warning | this workflow is used as a subflow by N others: changing inputs, return value or table affects them |
| ValidateUpdateSetDependencies | Warning | a subflow is being changed in another in-progress update set |
| ValidateUpdateSetParentDependencies | Warning | a parent is being changed in another in-progress update set |
| ValidateInputVarUpdateSetDependencies | Warning | input variables were deleted in a different update set |
| ValidateWorkflowEndStages | Warning | with stages, End lacks a stage named Complete or Completed |
| ValidateWorkflowStageColumn | Warning | stage column missing, not of type Workflow, or unused |
| ValidateWorkflowStateValues | Warning | stages with empty or duplicate names or values |

Critical errors are also highlighted in red on the canvas when the workflow loads.

## Update sets

A workflow is spread over many tables, so it is captured differently from ordinary records (no update set concept note in the vault yet):

- Nothing is recorded while it is checked out. **Publishing** writes the *whole* workflow (activities, transitions, conditions, input variables) as one entry of type Workflow in the publisher's current update set. Only the latest version is kept.
- **Subflows are not included**: they travel only if they are published into the same update set. A parent arriving without its subflow fails run-time validation on the target.
- **Input variables** are also written individually, immediately, when created, changed or **deleted**, to whatever update set is current at that moment. A deletion can therefore reach production before, or without, the workflow version that stopped using the variable.
- On commit the incoming version becomes the published one and every other version is unpublished. So the *last committed* update set wins, not the newest version: committing an older set later silently regresses the workflow.

Practice:

- Do all work on one workflow (variables included) in one update set, and publish there.
- To pull a workflow into a set, check it out and publish it again with that set current; or move its customer update record to the other set.
- Move parents and subflows together, or merge their sets.
- Commit update sets in the order they were built.
- Read the validation warnings before publishing.

To check what a workflow entry carries: open the update set > the workflow's customer update > XML payload > search for `var_dictionary`.

## Related

- [[Classic Workflow Overview]] · [[Classic Workflow Activities Reference]] · [[Classic Workflow Administration and Troubleshooting]]
