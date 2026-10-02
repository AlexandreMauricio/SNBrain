---
type: concept
tags: [concept, sla, task, flows]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Service Level Management", topics "Service Level Management concepts", "SLA processing", "Configure Service Level Agreement (SLA)", "SLA duration types", "Schedules within SLA", "Time zones in SLAs", "SLA conditions", "SLA transitions", "SLA condition rules", "Flows for SLA", "SLA notifications", "SLA process example", "Define a service contract" (pp. 3137-3144, 3155-3165, 3174-3186), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# SLA definitions and task SLAs

**In one line:** an SLA definition (`contract_sla`) says, for one task table, when a clock starts, pauses, stops and resets and how long it may run; every time it applies to a task the engine creates a task SLA ([[task_sla]]) that carries the timing.

## SLA definition fields

**Service Level Management > SLA > SLA Definitions** (roles `sla_admin`, `sla_manager`, admin).

| Field | Meaning |
|---|---|
| **Type** | SLA, OLA, Underpinning contract (reporting only) |
| **Target** | None, Response, Resolution (filtering and reporting only) |
| **Table** | any table extending [[task]] |
| **Flow** / **Workflow** | what runs on each task SLA (one or the other); default *Default SLA flow* |
| **Duration type** | *User specified duration* (+ **Duration**) or a **relative duration** (*Breach on Due Date*, *End of next business day*, *Next business day by 4pm*; script-based; **Relative duration works on** Task record or SLA record) |
| **Schedule source** | *No schedule* (24x7), *SLA definition* (+ **Schedule**), or a field on the task (for example Configuration item > Schedule) |
| **Timezone source** | caller, SLA definition (+ **Timezone**), CI location, task location, caller location; falls back to the system time zone |
| **Enable logging** | debug log for this definition only |
| **Condition type** (add to form) | an SLA condition rule overriding the global one |

**Days in Duration are 24-hour blocks.** 1 day on an 8-hour schedule = three business days. Maximum duration `com.snc.sla.maximum_duration` = 1095 days.

## Conditions

| Tab | Options |
|---|---|
| **Start condition** | **When to cancel**: *Start conditions are not met* (default), *Cancel conditions are met*, *Never*. **Retroactive start** + **Set start to** (a date field such as Created or Opened) + **Retroactive pause time** |
| **Pause condition** | **When to resume**: *Pause conditions are not met* (default) or *Resume conditions are met* |
| **Stop condition** | completes the task SLA, breached or not |
| **Reset condition** | completes the running one and attaches a new one (start must still match); supports *changes / changes from / changes to* |

## How the engine evaluates (on every insert or update of the task)

1. Definitions with no active task SLA on this task: **attach** if Start matches and Stop (and Cancel) do not.
2. Each active task SLA, in this order: Stop matches → **Completed**; Reset and Start match → Completed and a new one attached; Start no longer matches (or Cancel matches) → **Cancelled**; Pause matches while In Progress → **Paused**; Pause no longer matches (or Resume matches) while Paused → **In Progress**.

Consequences:

- Start a subset of Stop → never attaches.
- Start and Pause mutually exclusive (Start *State is New or Active*, Pause *State is On Hold*) → the SLA is **cancelled** instead of paused, unless **When to cancel** is changed.
- Pause a subset of Start → attaches already paused, then cancels when it "resumes".

The logic lives in script include `SLAConditionBase` (methods `attach`, `pause`, `complete`, `reattach`, `cancel`; `resume` in the transition list). **Service Level Management > Administration > SLA Condition Rules** (`sla_condition_class`) lists the rules; `SLAConditionSimple` is a shipped variation. Global default: property `com.snc.sla.default_conditionclass`. Do not edit the base class; extend it.

## Actual versus business time

- **Actual** fields count 24x7. **Business** fields count only inside the schedule. With no schedule, business = actual (property `com.snc.sla.always_populate_business_fields`).
- Example: schedule 8:00 to 17:00 weekdays, incident opened Friday 21:00, now Monday 9:30 → business elapsed 1 h 30 min, actual elapsed 60 h 30 min.
- Flow percentage timers (50 %, 75 %) run on **business** time. Exception: with a relative duration they use actual time unless property `com.glideapp.workflow.duration.relative_uses_schedule` (create it) is true.
- Pause conditions are not compatible with relative durations.

## Retroactive start

Without it, an SLA attached after a priority change counts from the change. With **Retroactive start** = Created or Opened, it counts from then; **Retroactive pause time** credits pauses that happened before attachment. An SLA can attach already breached: the flow/workflow then does not run unless `com.snc.sla.flow.run_for_breached` (create it) / `com.snc.sla.workflow.run_for_breached` is true.

## Notifications

*Default SLA flow* / *SLA Notification and Escalation flow* raise events: at 50 % to **Assigned to** and the CI's **Supported by**; at 75 % and at breach to **Assigned to** and their manager. Since Yokohama flows replace the legacy SLA workflows. Do not print the elapsed percentage in the email (it shows the last calculated value); use one notification per threshold.

## Dot-walked fields in conditions

Timeline and repair replay the **task's** audit history only. A condition on a dot-walked field (for example `company.cost_center`) is evaluated with the field's **final** value. If history matters, copy the value into a field on the task with a business rule and condition on that.

## Service contracts

Plugin `com.snc.sla.contract2`: **Service Level Management > Service Contracts** (`ast_service`, extends `ast_contract`) groups SLA definitions with contract CIs, locations, groups and users; add **Contract** to the task form. **Process non-contractual SLAs** lets OLAs run beside contractual SLAs.

## Walkthrough (base data)

P1 incident → *Priority 1 resolution (8 hour)* attaches. Impact to 2 → P1 SLA Cancelled, P2 attached. Put on hold awaiting the caller → Paused (pause duration is written only when the pause ends). Back to active → In Progress. Resolved → Completed.

## Related

- [[task_sla]] · [[SLA Engine, Repair, Timeline and Breakdowns]] · [[Create an SLA Definition]] · [[SLA Does Not Attach or Cancels Instead of Pausing]] · [[Schedules and Schedule Entries]]
