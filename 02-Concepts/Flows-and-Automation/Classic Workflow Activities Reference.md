---
type: reference
tags: [reference, workflow, automation, scripting, service-catalog, sla, javascript]
status: documented
source: ServiceNow docs, Australia, Build workflows > Classic Workflow > Workflow activities (read 2026-10-08 through the docs site): Workflow activities, Workflow activities reference, Approval and rollback activities (Approval Action, Approval Coordinator, Approval - Group, Approval - User, Generate, Manual Approvals, Rollback To), Condition activities (If, Switch, Wait for condition, Wait for WF Event), Notification activities (Create Event, Notification), Timer activities (SLA Percentage Timer, Timer), Task activities (Add Worknote, Attachment Note, Catalog Task, Create Task), Utility activities (Branch, Join, Lock, Log Message, Log Trace Message, REST Message, Return Value, Run Script, Set Values, SOAP Message, Turnstile, Unlock), Parallel Flow Launcher (WorkflowCoordinator object, completed subflow values, example), View activity descriptions, Add an activity, Manage transitions, Manage activity conditions, Edit the activity properties form, Using approval activities and rolling back workflows, Using variables in Notify activities, Use multiple timer activities, Publish a custom activity, Activity pinning. https://www.servicenow.com/docs/r/australia/build-workflows/workflow-activities/wf-activity-overview.html
sn-release: Australia
verified:
updated: 2026-10-08
---

# Classic Workflow Activities Reference

**What it is:** the core activities of the legacy Workflow Editor, with their variables, results and exit conditions. Concepts: [[Classic Workflow Overview]]. Flow equivalents: [[Flow Core Actions Reference]], [[Flow Logic Reference]].

## How an activity works

- Dropped from the palette onto a transition line; its properties form opens. An activity whose definition names a table appears only when the workflow's table is that table or extends it.
- **Result** (`activity.result`) decides which **condition** (exit) is taken. Extra exits: right-click > **Add Condition** with a JavaScript test such as `activity.result == 'rejected'`; variables `current`, `activity` (the `wf_executing` record), `activity.result`, `activity.vars`. **Reorder Conditions** changes their order. Custom activities do not support added conditions.
- States: Executing, Waiting, Finished, Cancelled, Error.
- Every condition needs a transition, and every transition a target: validate before publishing.
- **Copy Activity** (right-click) duplicates with its settings, without transitions.
- Scripts inside activities run server-side in the workflow's scope and set the variable `answer` where a value is expected.

## Approvals and rollback

Only on tables extending Task (except *Approval - User* and *Approval Action*, usable anywhere), and only when the table's approval engine is **off** (**System Properties > Approval Engines**); otherwise greyed out ([[Classic Approvals]]). They run as the user whose decision ends the wait.

| Activity | Does | Key variables | Results / exits |
|---|---|---|---|
| **Approval - User** | one approval per user | **Users**, **Groups** (members get individual approvals); **Wait for**: Anyone to approve / Everyone to approve / First response from anyone / Condition based on script; **When anyone rejects**: Reject the approval / Wait for other responses; **Approval Column** (default `approval`), journal column; schedule (due date); **Additional approvers script** | approved, rejected, deleted, cancelled; exits Approved, Rejected (and Error, Skipped) |
| **Approval - Group** | a group approval (`sysapproval_group`) plus one per member | **Groups**; **Wait for**: An approval from each group / from any group / from everyone from all groups / First response from each group / First response from any group / Condition based on script; **When anyone rejects**; schedule; **Additional groups script** | the same |
| **Approval Coordinator** | one outcome from several child approval activities (user, group, manual) | **Wait for**: any child approved / all children approved / first approval or rejection / script; **When a rejection occurs** | approved, rejected, deleted, cancelled. On completion remaining child approvals become No Longer Required; the same user is asked only once |
| **Manual Approvals** | waits for approvals added by hand (in Not requested state); creates none | **Wait for** any / all / first response; **When anyone rejects** | approved at once when there are none |
| **Approval Action** | sets the task's approval | **Action**: Mark task approved / rejected / requested / Disregard pending approvals | marking approved also sets pending approvals to No Longer Required (Set Values does not) |
| **Generate** | creates in advance the tasks (Pending) and approvals (Not Requested) of the activities after it, with expected start and due dates from their durations | **Generate approvals**, **Generate tasks** | conditions flagged **Skip during generate** are not followed (default: Rejected, If's No, Turnstile's Continue, Join's Incomplete). Can be run again to refresh |
| **Rollback To** | jumps back along its transition and resets what lies between | none | approvals back to Not Yet Requested; the target task to Open, tasks in between to Pending. Emails or external actions are not undone. Based on the drawn sequence, not the execution order |

No user or group selected = the activity approves automatically. A script error in an approval activity ends it as **Skipped**, which then follows the Approved path unless the exit is guarded ([[Classic Workflow Administration and Troubleshooting]]).

Approval script (server-side, in the activity): `counts.total`, `.approved`, `.rejected`, `.requested`, `.not_requested`, `.not_required`; for groups also `groups[id]` with the same counters.

```javascript
// Approval script of an Approval - User activity: approve on a simple majority
if (counts.approved / counts.total > 0.5)
    answer = 'approved';
else if (counts.rejected / counts.total >= 0.5)
    answer = 'rejected';
```

## Conditions and waiting

| Activity | Does | Notes |
|---|---|---|
| **If** | **Condition** and / or **Advanced** script (`answer = 'yes'`) | both must hold for Yes; exits Yes, No |
| **Switch** | one exit per value of a **Field** of the table or a catalog **Variable** | like a switch statement; conditions of type Standard, Else, Error |
| **Wait for condition** | pauses until the current record matches **Condition** (and **Condition script** sets `answer = true`) | re-evaluated on each update of the record. Optional **Enable Timeout** + **Duration**. Meant for changes made from outside; to wait on a value the workflow itself just set, put a one-second Timer first |
| **Wait for WF Event** | pauses until a workflow event of the given name fires in this context | fired with `workflow.fireEvent('name')` from another branch or a script. Flow replacement: *Wait For Message* |

## Timers

Run as System (the scheduler resumes the workflow).

| Activity | Variables |
|---|---|
| **Timer** | **Timer based on**: a user-specified duration / a relative duration / a date-time or duration field / script (`answer` = seconds). **Wait**: the full duration, a % of it, some time before, some time after. **Schedule based on**: the workflow's schedule, a specific schedule, a schedule field (a 2-hour wait started at 16:00 on an 8-17 schedule ends at 9:00 next day). **Time zone based on**: none (GMT), specific, field |
| **SLA Percentage Timer** | **Percentage** of the task SLA's duration. Only in workflows on Task SLA (`task_sla`). Paused and resumed with the SLA |

Results: Complete, Cancelled. Each timer keeps its own scratchpad values (end time, real start time, retroactive seconds left), so several timers can coexist in one workflow.

## Tasks

Run as the user who completes the task.

| Activity | Does | Key variables | Results |
|---|---|---|---|
| **Create Task** | a record in any Task table | **Task type**, **Priority**, **Wait for completion**; **Task values from** Fields (fulfillment group, assigned to, short description, instructions) / Template / Values; **Advanced** script on `task` (for example `task.short_description = current.short_description;`); schedule for the due date | closed complete, closed incomplete, closed skipped, deleted, cancelled |
| **Catalog Task** | a catalog task; only on Requested Item (`sc_req_item`) | the same, plus **Variables on Task Form** (catalog variables to show) | the same |
| **Add Worknote** | adds a work note; only on Incident | **Work Note** | |
| **Attachment Note** | attaches a generated .txt file and notes it | **Field** (work notes or comments), **Attachment Name**, **Attachment Data** | |

## Notifications

| Activity | Does |
|---|---|
| **Notification** | sends an email: **To**, **To (groups)**, **To (script)** (`answer` = sys_ids), **Subject**, **Message** with field values inserted |
| **Create Event** | queues a registered event: **Event name**, **Parameter 1**, **Parameter 2** (strings in quotes). Processed within about a minute ([[Events and the Event Queue]]) |

The Notify (telephony) activities (Call, Say, Input, Play, Record, Send SMS, conference and queue) accept `${variable}` from the scratchpad, up to 20 per activity; Input exposes `${digit}`.

## Utilities

| Activity | Does | Notes |
|---|---|---|
| **Run Script** | runs a script in the workflow's scope | changes to `current` are saved by the engine |
| **Set Values** | sets fields on the current record when the workflow next pauses or ends | the last Set Values before the pause wins for a field. Setting Approval here does not cancel pending approvals: use Approval Action |
| **Branch** | one *Always* exit with several transitions, all taken at once | same as drawing several lines from one condition |
| **Join** | waits for all incoming paths | exits **Complete** and **Incomplete** (a predecessor finished on a path that bypassed the Join). Without a Join, what follows runs once per path |
| **Turnstile** | counts passes | **Allowed iterations**; exits Continue, Cancel. Loop guard, usually with Rollback To |
| **Lock** / **Unlock** | mutual exclusion between contexts of the same workflow | **Key**, **Max. duration**, **Max. attempts**, **Delay between attempts**; results Success / Failure (state Timeout). Put a one-second Timer before Lock, and nothing that waits (approvals, tasks, timers, MID activities) between Lock and Unlock |
| **Log Message**, **Log Trace Message** | write to the workflow log | trace adds activity name, event and table |
| **Return Value** | from a subflow, writes a value to the parent's scratchpad | the parent's subflow activity maps it (*Map return value to variable*) |
| **Parallel Flow Launcher** | starts several subflows at once and waits for all | **Workflow**, **Inputs** (array of name/value sets, one subflow per set), **Count**, **Max flows**, **Max simultaneous**; scripts *Flow complete* (`flow.output`, `.index`, `.contextId`, `.inputs`, `.status`) and *Finished script* (`coordinator.getNumFlows()`, `.getFlow(i)`). Advanced: a `WorkflowCoordinator` object to launch different subflows. Waits forever if one never ends; batch large numbers |
| **REST Message**, **SOAP Message** (legacy) | call an outbound REST or SOAP message, optionally through a MID Server; sensor script reads `activity.output` | **deprecated in Australia**: gone from the palette for new workflows, still run in existing ones (re-activate the activity definition to edit) |

## Custom activities and pinning

With Orchestration, users with `activity_creator` build custom activities; a saved one is visible only to its author until **Publish**; editing needs **Checkout**; an admin can **Force Checkout** a version locked by someone absent. **Pinning** keeps a workflow on the current version of a Store-delivered custom activity when a new one is downloaded (per activity, or for the whole workflow in its properties). Activity descriptions and the layout of an activity's form: **Workflow > Administration > Activity Definitions** (**Edit Variables Layout**).

## Related

- [[Classic Workflow Overview]] · [[Classic Workflow Stages, Validation and Update Sets]] · [[Classic Workflow Administration and Troubleshooting]] · [[Classic Approvals]]
