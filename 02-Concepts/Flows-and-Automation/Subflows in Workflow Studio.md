---
type: concept
tags: [concept, flows, automation, ai]
status: documented
source: ServiceNow docs, Australia, Build workflows > Workflow Studio > Flows, subflows, and actions > Build subflows (read 2026-10-08 through the docs site): Building subflows, Create a subflow (and with Now Assist), Create conversational subflow skill, Configure subflow conversational settings, Configure LLM for descriptions, Copy a subflow, Create a decision table in a subflow, Convert items to subflow, Create a template value input, Get started with Dynamic Flow and Get Flow Outputs, Publish a subflow, Summarize a subflow, Subflow history, Test a subflow, Test conversational subflow. Section start https://www.servicenow.com/docs/r/australia/build-workflows/workflow-studio/subflows.html
sn-release: Australia
verified:
updated: 2026-10-08
---

# Subflows in Workflow Studio

**In one line:** a subflow is a flow without a trigger: it declares inputs and outputs, runs when a flow, another subflow, a playbook or a script calls it, and is the unit of reuse in Workflow Studio.

Context: [[Flows, Subflows and Actions Overview and Architecture]]. Everything about flow design applies ([[Building Flows - Properties, Triggers, Stages and Error Handling]]).

## When to use one

- The logic is needed in several flows, or with different inputs each time.
- A flow passes 25 actions.
- Something must be started only by a call (from a flow or a script), not by a trigger.
- A flow's error handler needs more than 10 steps, or reusable corrective steps.

## Parts

| Part | Notes |
|---|---|
| Properties | **Subflow name**, **Description**, **Application** (fixed), **Domain**, **Accessible From** (all scopes or this scope), **Category** (custom categories since Xanadu), **Protection**, **Subflow annotation** (help text under the title), **Run as**, **Run with roles**, **Flow priority default** |
| Inputs | name, type, **Mandatory**, advanced options (hint, default, choices). Keep to 20 or fewer |
| Outputs | name and type; values set with **Assign Subflow Outputs** flow logic, typically once per branch. Without conditions the last assignment wins |
| Body | actions, flow logic, other subflows; with *Show triggered flows* an activated flow can be called too (its trigger is ignored) |

Input and output names cannot be `sys_id`, `sys_created_by`, `sys_created_on`, `sys_updated_on`, `sys_updated_by` or `sys_mod_count`.

**Template value input**: an input of type *Template Value.&lt;table&gt;* dropped into the **Fields** of a Create or Update Record step lets each caller choose which fields to set. Static values set beside it in the subflow win, which is a way to enforce a policy.

## Life cycle

- **Test** needs at least one action; you type the input values (remembered for the next test); optional background run.
- **Publish** makes it callable. Later edits stay in draft until published again; every parent flow then picks up the new version automatically. Do not change inputs or outputs under active callers.
- **See related flows** before changing it ([[Flow Administration, Execution Details and Access]]).
- **Copy subflow** (new name, optional scope). History, summary and conversational settings work as for flows ([[Flow Authoring Aids - History, Variables, Inline Scripts and AI]]).
- **Convert to subflow**: in a flow, **Select multiple** > tick consecutive items > *Convert to subflow* > name. The items are replaced by a call and pill references are rewired; the subflow is created published in the same scope. Set Flow Variables blocks cannot be converted. Cannot be undone with Undo.

## Running several

- **Parallel subflows**: start each without waiting, then wait until all are in a terminal state. Worth it only when the outputs depend on each other; otherwise trigger separate flows.
- **Dynamic Flow** flow logic: choose the subflow at run time by name. A *template* subflow fixes the inputs and outputs every candidate shares; the **Flow** input is built from text and pills (for example a fixed prefix plus a field value); **Wait for completion**. **Get Flow Outputs** then reads the outputs through the Dynamic Flow's **Context** pill. Each dynamic call runs in its own flow context.

## Conversational skills

A published subflow can be offered in AI assistant conversations: side panel **Conversational settings > Create a new skill** (roles admin or `flow_designer`, plus `now.assist.creator`; several skills per subflow).

| Setting | Meaning |
|---|---|
| **Is conversational**, **Subflow skill name**, **Subflow skill description** | the description is what the assistant matches utterances against |
| **Generate skill metadata** | AI-written descriptions for empty fields only |
| **Assistants where subflow is discoverable**, **Roles which can access this** | the role must also be allowed in the subflow itself |
| Per input / output | show or hide; description (required for mandatory ones); **Default value** (hidden + default = passed silently); **Override with reference** (pick from a table's field instead of typing) |
| Advanced | include in discovery, in the topic list, promote, **Use autonomous mode** (no confirmation before record operations), **Enable follow up**, show errors, channels |

Test with **Test > Trigger via a conversation**. The model that writes descriptions is chosen in `sys_one_extend_capability` (application *Conversational subflows and actions*).

## Related

- [[Building Flows - Properties, Triggers, Stages and Error Handling]] · [[Flows, Subflows and Actions Overview and Architecture]] · [[Playbook Activities, Decisions and Variants]]
