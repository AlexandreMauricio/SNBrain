---
type: concept
tags: [concept, automation, notifications, scripting, business-rule]
status: documented
source: ServiceNow Australia Platform Administration PDF, "System Events" (pp. 2724-2741), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Events and the event queue

**In one line:** an event is a record in [[sysevent]] saying "this happened to that record"; scheduled jobs read the queue and hand each event to whatever listens to it: notifications, script actions, workflow activities, inactivity monitors.

## Life of an event

1. Something calls `gs.eventQueue()`, usually an **after** business rule (for example *incident events*).
2. A row is written to `sysevent` in state **Ready**.
3. An event-processing scheduled job picks it up and passes it to its handlers.
4. State becomes **Processed** (or **Error**).

An event that nobody listens to is still Processed: nothing happens by itself.

```javascript
if (current.operation() != 'insert' && current.comments.changes()) {
    gs.eventQueue('incident.commented', current, gs.getUserID(), gs.getUserName());
}
```

| Argument | Meaning |
|---|---|
| name | registered event name, e.g. `incident.commented` |
| record | usually `current` (a GlideRecord when called from a scheduled job) |
| parm1, parm2 | two free strings; readable later as `event.parm1` / `event.parm2`, or `${event.parm1}` in a notification |

Records written through the event mechanism do not fire business rules on the event itself (the guide: `gs.eventQueue` works directly with the back end).

## Event states

| State | Meaning |
|---|---|
| Ready | queued |
| Processed | ran (whether or not anything reacted) |
| Error | failed, often invalid parameters; try reprocessing |
| Transferred | the row was rotated to another shard of `sysevent`; a copy is processed from the active shard |

## Registry

**System Policy > Events > Registry** (`sysevent_register`, role `events_admin`). An event must be **registered** for notifications and script actions to offer it in their event pickers. Fields: **Event name**, **Table**, **Queue** (lowercase and underscores only), **Priority** (lower runs first; property `com.glide.sysevent.priority.enabled`), **Caller Access**, **Fired by** (documentation only), **Description**.

`global.events(current)` in a business rule produces the standard set for a table: `<table>.inserted`, `.updated`, `.commented`, `.assigned`, `.inactive`.

## Who reacts

- **Notifications** with *Send when: Event is fired* ([[Email Notifications]]). parm1/parm2 can carry recipients.
- **Script actions** (**System Policy > Events > Script Actions**, role `sysevent_script_action_admin`): a server script per event with **Execution order**, **Condition script** and **Script**; variables `event` (the `sysevent` row: `event.parm1`, `event.parm2`, `event.sys_created_on`, `event.user_id`) and `current` (the record).
- Workflow activities and inactivity monitors. A workflow can fire an event with two parameters and a mail script reads them with `event.parm1`.

## Queues

- Events without a queue go to the default queue. A custom **Queue** isolates slow or urgent events; **Move to Default Queue** / **Move to Adaptive Event Queue** on the registration form switches. Timings: **System Diagnostics > Stats > Adaptive Events**.
- **Queue Registration** (link on the registration form) sets up **automatic job scheduling** for a queue: **Event Processing Order** *Parallel* or *Sequential* (cannot be edited afterwards; delete and recreate), **Job configuration type** *Constant* or *Scale with node*, **Scale factor**, **Poll interval**. **Rollback** returns to the manual configuration.

## Monitoring and replay

- **System Logs > Events** shows Created, Name, Parm1, Parm2, Table, Processed, Processing time (ms), Queue.
- **Reprocess Event** (related link on an event) puts it back in the queue: good for testing a notification.
- During a platform upgrade only some events are processed: `glide.event_processor.all_events_upgrade_safe` (false) and `glide.event_processor.upgrade_safe_events` (list).

## Related

- [[Create and Register an Event]] · [[Baseline Email Notifications and Events]] · [[Order of Execution for Rules, Engines and Notifications]] · [[System Events and Scheduled Jobs Dashboards]]
