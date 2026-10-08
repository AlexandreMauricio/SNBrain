---
type: reference
tags: [reference, workflow, automation, admin, instance-admin, scripting, javascript]
status: documented
source: ServiceNow docs, Australia, Build workflows > Classic Workflow (read 2026-10-08 through the docs site): Workflow events (events in the base system, Glide events relative to workflows, event-specific functions, event-specific activities), Workflow administration, Administering workflow contexts, Cancel a workflow, Scheduling a workflow, Workflow timelines, Workflow error handling (error tracking features, create an error condition exit, reconfigure an approval condition), Workflow run time metrics, Workflow pause utility (request, pause and resume individual / all or multiple workflows, monitor pause requests), Encrypted workflow scratchpad, Troubleshoot workflows, Use the Workflow Operations Dashboard, Workflow performance timing, Correct a skipped workflow approval activity. https://www.servicenow.com/docs/r/australia/build-workflows/legacy-workflow/c_WorkflowAdministration.html
sn-release: Australia
verified:
updated: 2026-10-08
---

# Classic Workflow Administration and Troubleshooting

**What it is:** looking at running legacy workflows, cancelling, scheduling and pausing them, handling script errors, and the engine's internal events. Context: [[Classic Workflow Overview]].

## Contexts

A run is a Workflow Context (`wf_context`): **Workflow > Live Workflows > Active Contexts / All Contexts / History**, or the **Workflow Context** related link on the record.

| Related link | Shows |
|---|---|
| **Show Workflow** | the diagram with the path taken (blue) and not taken (grey), activities coloured by state. Hovering an activity gives state, result, fault description, execution time and execution order |
| **Show Timeline** | activities as bars over time; range selectors and a slider to zoom; subflows in another colour; double-click a bar for its history record. Also from selected rows of *Workflow Activity History*, even across contexts. History only, not live |

Related lists: executing activities, activity history, transition history (with a *Rolled back* column), log.

## Cancel

- Context > **Cancel**: injects a cancel command; activities get their `onCancel`. If it does not react, **Force cancel** interrupts the thread: last resort, it can leave related work unresolved.
- By script (server-side): `new Workflow().cancelContext(contextGR);`
- **On-cancel script** on the workflow version (add the field to the form; version must be checked out): runs asynchronously in **global** scope when the context becomes Cancelled, with `context_sys_id` available. It cannot call scoped script includes.

```javascript
// On-cancel script of a workflow version (server-side, global scope, asynchronous)
var ctx = new GlideRecord('wf_context');
ctx.get(context_sys_id);
var item = new GlideRecord('sc_req_item');
if (item.get(ctx.id)) {
    item.comments = 'The workflow for this item was cancelled.';
    item.update();
}
```

## Scheduled workflows

**Workflow > Scheduled Workflows**: **Name**, **Workflow** (published), **Active**, **Run** (Daily, Weekly, Monthly, Periodically, Once) with **Time**, **Day**, **Repeat Interval**, **Starting**. There is **no current record**, so Create Task, Catalog Task and other record-dependent activities are unavailable: when they are needed, use a scheduled job that inserts a record which starts the workflow ([[Scheduled Jobs]]).

## Script errors

A syntax error in an activity's script does not stop the workflow by itself: the activity ends and the run continues on whatever exit matches.

| Activity | Red banner | State / result on error |
|---|---|---|
| Approval - User, Approval - Group | yes | Error / **skipped** (then follows the Approved exit) |
| If | yes | Error |
| Run Script, Notification | yes | Error / error |
| Catalog Task, Create Task | no (log only) | Finished |

- **Error exit**: right-click the activity > **Add condition**: Name *Error*, Condition `activity.state == 'faulted'`; connect it to a notification or log.
- **Guard the approval exit**: on the *Approved* condition append `&& activity.state != 'faulted'`.
- A **skipped approval** also comes from a missing, invalid or since-deactivated approver, or an empty dot-walk such as `current.opened_by.department.manager`: open the context > Show Workflow > find the approval with State Finished and Result Skipped > fix **Users** / **Groups** in the workflow.
- Logs: the context's Workflow Log; property *Log workflow debug messages* (**Workflow > Administration > Properties**) adds activity names. Credential failures of Orchestration activities are logged with target and credential.

## Execution path forensics

Context > *Workflow Activity History* > right-click a row > **Workflow Debug > Toggle Execution Path Highlighting** colours the activities of that path; **Toggle Rollback Highlighting** colours those restarted by one rollback. Useful to find tasks and approvals left unresolved by rollbacks, cancels or deletions.

## Run time metrics

- **Estimated Run Time (ERT)** per workflow (properties > Estimated Runtime; on by default for new workflows, off for shipped ones). Outlier range = ERT ± ERT × threshold / 100 (10 s at 20% = 8 to 12 s). A run inside the range updates the ERT as a cumulative moving average, rounded to the second; a run outside is an *outlier*.
- **Workflow > Operations > Workflow Operations Dashboard** (`workflow_admin`): contexts with run time metrics, active workflows started per hour, workflows by state, aged contexts, runs by table; more gauges can be added (outlier finished or long-running workflows, contexts without a current record, running contexts).
- **Performance timing**: add property `glide.workflow.show_timing` = true; the engine then writes one record per context to Workflow Timing (`wf_workflow_timing`).

## Pause utility

Plugin *Workflow Pause Utility* (`com.glideapp.workflow.pause`, requested through Now Support). For maintenance windows, or when a system a workflow calls is down.

| Scope | How |
|---|---|
| One context | context > **Pause** > **Resume At** (date and a future time); **Resume** to resume early |
| Many or all | **Workflow > Operations > Group Pause Requests > New**: **Pause All**, or a **Filter** on contexts; **Pause**, **Resume At**, **Resume**; *Do Not Pause Incoming Workflows* |
| Monitor | **Workflow > Operations > Pause Requests**: state Paused / Resumed, counts of paused, resumed and stuck activities, percentages |

A context pauses after its current activity finishes, before the next starts. Tables: `wf_pause_request`, `wf_pause_status`, `wf_pause_group_request`, `wf_pause_snapshot`. Roles: `workflow_admin`, `workflow_publisher` or `workflow_creator` (with the script writer permission).

## Encrypted scratchpad

Scratchpad data is plain text by default. Plugin *Encrypted Workflow Scratchpad* (`com.snc.encrypted.scratchpad`, activated by Support; brings Encryption Support `com.glide.encryption`) encrypts the scratchpads of `wf_context` and `wf_executing`. **Incompatible with domain separation.** Activation on production: quiet period, pause all workflows first, resume afterwards.

## Workflow events (engine internals)

Not the registered platform events of [[Events and the Event Queue]]: workflow events are strings handled only inside a context, matched against `wf_executing.registered_events`, and dispatched to the `on<Event>` handler of the executing activity's definition.

| Event | Meaning |
|---|---|
| `execute` | start an activity (also the Lock activity's retry) |
| `activityComplete`, `otherEvent` | used by Join |
| `timer` | a Timer expired (from a scheduled job) |
| `determineApprovalState` | approval activities re-evaluate |
| `cancel` | the workflow is being cancelled (End broadcasts it to whatever is still executing) |
| `stop` | lets End finish without cancelling |
| `listener` | a subflow finished: the parent continues |
| `probe_complete` | a MID Server finished an Orchestration task |
| `pause`, `resume` | from an SLA to its timer |

Threads completing at the same time queue their events in `wf_command`.

| Call | From | Does |
|---|---|---|
| `workflow.fireEvent('name')` | an activity script | wakes activities of this context registered for the event (for example *Wait for WF Event*) |
| `workflow.broadcastEvent('name')` | an activity script | sends it to every executing activity of this context |
| `workflow.registerForEvent('name')` / `unRegisterForEvent` | an activity script | adds or removes a registration |
| `new Workflow().fireEvent(executingGR, 'name')` | any server script | targets one executing activity (a `wf_executing` record). The docs also describe variants taking the record's sys_id and an optional JSON object; their exact signatures are not confirmed here |
| `new Workflow().broadcastEvent(contextId, 'name')` | any server script | every executing activity of that context |

Record inserts start workflows; updates, deletes and queries of a record with a running context wake the engine to advance it.

## Related

- [[Classic Workflow Overview]] · [[Classic Workflow Activities Reference]] · [[Classic Workflow Stages, Validation and Update Sets]] · [[Flow Administration, Execution Details and Access]]
