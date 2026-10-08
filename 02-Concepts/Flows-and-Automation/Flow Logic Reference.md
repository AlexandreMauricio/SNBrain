---
type: reference
tags: [reference, flows, automation, workflow]
status: documented
source: ServiceNow docs, Australia, Build workflows > Workflow Studio > Flows, subflows, and actions > Reference > Workflow Studio flow logic (read 2026-10-08 through the docs site): Workflow Studio flow logic and each page - Append to Flow Variables, Assign subflow outputs, Call a workflow, Do the following until, Do the following in parallel, Dynamic flows, End Flow, Exit Loop, For Each, Get Flow Outputs, Go back to, If, Make a decision, Set Flow Variables, Skip Iteration, Try, Wait for a duration. https://www.servicenow.com/docs/r/australia/build-workflows/workflow-studio/flow-logic.html
sn-release: Australia
verified:
updated: 2026-10-08
---

# Flow Logic Reference

**What it is:** the control blocks of a flow or subflow: branching, loops, parallel paths, waits, error catching, variables and calls. Actions: [[Flow Core Actions Reference]].

**Rule that applies to every branch and loop:** a pill value set *inside* a branch (Then, answer branch, For Each, Do Until) is null when read from outside it. Carry values out with a flow variable.

## Overview

| Flow logic | Does | Inputs | Outputs |
|---|---|---|---|
| **If** / **Else If** / **Else** | run the Then branch when the conditions hold | Condition label, Condition | none |
| **Make a decision** | branch on a decision table's answers | see below | see below |
| **For Each** | run once per record of a list | Items (Records pill or sys_id list) | the current record |
| **Do the following until** | repeat until a condition is true | Condition label, Conditions | none |
| **Exit Loop** | break out of the loop | none | none |
| **Skip Iteration** | continue with the next item | none | none |
| **Go back to** | jump to an earlier step | Go back to step | none |
| **Do the following in parallel** | separate paths, all must finish | none (add paths with +) | none of its own |
| **Try** / **Catch** | keep going when something inside fails | none | none of its own |
| **Wait for a duration** | timer | see below | Duration (ms), Date/time |
| **End Flow** | stop here | none | none |
| **Set Flow Variables** | assign flow variables | Name, Data (text, pill or script) | none |
| **Append to Flow Variables** | add objects to an Array.Object flow variable | Name, Data | none |
| **Assign Subflow Outputs** | set the subflow's outputs | Name, Data | none |
| **Dynamic Flow** | call a flow or subflow chosen at run time | Flow Template, Flow, Wait for completion, the template's inputs | Context |
| **Get Flow Outputs** | read a dynamic flow's outputs | Flow Template, Context | Response (JSON), Error Message |
| **Call a Workflow** | run a legacy workflow | Select a Workflow, Wait?, Current, the workflow's inputs | State, Context, Result, Return value |

## Branching

**If**: nest further Ifs inside Then. Keep OR conditions on one field in one condition set and AND conditions in another; mixing them can make a condition that is never true. Several Ifs that differ only by condition and do the same thing are better as one *Make a decision*.

**Make a decision**

| Input | Meaning |
|---|---|
| **Decision Label** | replaces the default step title |
| **Decision Table** | a Decision Table (`sys_decision`) record; can be created from here |
| **Execution** | *First decision that matches* or *Run all decisions that match* |
| **Use Branches** | one branch block per possible answer (like an If per answer). Clearing it deletes the branch blocks for good |
| **Include Otherwise** | an Else branch for "no answer". Never runs when the table has a default answer |
| one input per Decision Input (`sys_decision_input`) | values or pills |

| Output | When |
|---|---|
| Answer table | always |
| Answer record | first match |
| Answer records, **Count**, **Ordered IDs** (sys_ids in the table's Order) | all matches; Ordered IDs only without branches, for use in For Each |

The decision's pills can be used inside answer branches only when branches are on, and elsewhere in the flow only when they are off. At most 100 branches (`sn_flow_designer.max_decision_branches`).

## Loops

**For Each**
- Sort the list first (Order by on Look Up Records): the loop keeps list order.
- At most 1000 items; split bigger lists across flows. Avoid nested loops over many records: the one-hour flow transaction quota ends them.
- No stages inside.
- Execution details keep only the first and last iteration unless an execution setting says *Report all iterations* ([[Flow Administration, Execution Details and Access]]).

**Do the following until**: the body runs at least once, even when the condition is already true. Count iterations with a flow variable for custom exits.

**Exit Loop** (break) and **Skip Iteration** (continue): only inside the Then branch of an If / Else If / Else that sits in a For Each or Do Until. Steps after a skip show *Not Run* for that item.

**Go back to** (flows created in Washington DC or later)
- Placed only in a Then branch, a decision answer branch or a Catch branch; never in the error handler.
- Target: a step before it, not in another branch, not in its own branch, not inside a non-branching block unless that block also contains the Go back to, and never into *Do the following in parallel*.
- Targeting a step outside the enclosing loop leaves that loop and resets its counter.
- Counts against `sn_flow_designer.max_iterations` (1000). Give it an exit: a flow variable counter plus an If that ends the flow.
- Only the first Go back to whose conditions are met is used. It cannot be moved, only deleted and re-added, so add it last.
- Typical use: after a rejected approval, wait for a correction and ask again.

## Parallel paths

Paths share one flow context and therefore **one thread**: "parallel" means a waiting path does not block the others, not simultaneous execution. The block completes when every path has finished; outputs of a path become visible to the rest of the flow only then.

- No data dependencies between paths (one creates, another updates the same record): order is not guaranteed.
- Pills cannot be dragged between paths.
- No approval on the same record in two paths.
- For true separate contexts use *Dynamic Flow*, or separate flows.

## Try and Catch

Steps in **Try** run normally. When one fails, it gets status *Completed (error caught)* and the **Catch** section runs; the flow then continues. Use the failed item's status in Catch conditions. Example pattern: try SMS, on failure try a chat message, on failure send email. Flow-wide handling: the error handler in [[Building Flows - Properties, Triggers, Stages and Error Handling]]; per-action handling: [[Custom Actions, Dynamic Inputs and Error Evaluation]].

## Wait for a duration

| Input | Meaning |
|---|---|
| **Duration Type** | *Explicit* (5 minutes), *Relative* (an amount before or after a date/time pill), *Percentage* (0-100% of the time between now and an end date) |
| **Wait for** | up to 999 hours, typed or a Duration pill |
| **Wait for Percentage** | with Percentage type; a past end date means no wait |
| **During the following schedule** | count only time inside a schedule; started outside it, the timer begins at the schedule's next opening |

Relative durations: a past date is ignored (duration 0 or past date with no schedule ends immediately); a future date is waited for first, then the schedule, then the duration. Actual wake-up can be later than requested because of queue load. The run time shown in execution details excludes the wait itself.

## Ending and outputs

- **End Flow** stops every branch, including parallel paths and timers; state Completed. Nothing can follow it in its branch.
- A subflow ended this way returns outputs only if **Assign Subflow Outputs** ran before; parents must cope with empty outputs.
- Assign subflow outputs once per branch, **not inside loops** (only the last value survives; use flow variables in the loop and assign after it).
- Set Flow Variables and Assign Subflow Outputs run top to bottom; a value that references another must come after it; an empty Data clears the value.

## Dynamic Flow and Get Flow Outputs

- **Flow Template**: a published flow or subflow whose inputs (same **Label** and **Name**) every candidate shares. Copy the template to make the candidates and name them by a convention the flow can compose.
- **Flow**: display name (not internal name) or sys_id, built from text plus pills. `scope-name.flow-name` reaches another scope; default is the parent's scope. Not found = the step is skipped and an error is logged.
- Mismatched inputs raise an error.
- Outputs arrive as a **Context** record pill; **Get Flow Outputs** turns it into **Response** (JSON). Pick the Context of the right call when there are several.

See [[Subflows in Workflow Studio]].

## Call a Workflow

Runs a published, active legacy workflow ([[Classic Workflow Overview]]).

- Remove the workflow's own start conditions so it only runs from the flow.
- Workflows on Requested Item cannot be selected: build a Service Catalog flow instead.
- **Wait?** on: the flow resumes when the workflow completes and can read State (Complete, Canceled, Invalid when the context was deleted), Result and Return value. Off: only values produced before the step finished.
- If the workflow is cancelled or its context deleted, the flow stops waiting and continues.

## Related

- [[Flow Core Actions Reference]] · [[Decision Tables]] · [[Flow Authoring Aids - History, Variables, Inline Scripts and AI]] · [[Flow System Properties Reference]]
