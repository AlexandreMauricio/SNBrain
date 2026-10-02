---
type: reference
tags: [reference, sla, admin, automation]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Service Level Management", topics "Service Level Management plugins", "SLA timer", "Configure the SLA timer", "Create SLA breakdown definitions", "SLA calculation", "Repair SLA", "Add custom business rules to SLA", "Scheduled jobs for SLA", "SLA timeline", "SLA (Legacy) engines", "Configure SLA properties" (pp. 3141, 3144-3154, 3160-3173, 3186-3201, 3210-3214), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# SLA engine, repair, timeline and breakdowns

**What it is:** the machinery behind [[SLA Definitions and Task SLAs]]: how and when times are recalculated, and the tools to check and fix them.

## Engine

- Business rule **Run SLAs** on task tables processes SLAs synchronously on each insert/update (2011 engine). `com.snc.sla.engine.async` = true moves it to the background (task SLAs appear after a short delay).
- Script includes: `TaskSLAController`, `TaskSLA`, `SLACalculatorNG`, `SLAConditionBase`, `TaskSLAworkflow`, `TaskSLAFlowSNC`.
- Elapsed values on a task SLA are **only as fresh as the last calculation**. Scheduled jobs refresh them:

| Job | Runs |
|---|---|
| SLA update (breach within 10 min) | every minute |
| SLA update (breach within 1 hour) | every 10 minutes |
| SLA update (breach within 1 day) | hourly |
| SLA update (breach within 30 days) | daily |
| SLA update (breach after 30 days) | every 5 days |
| SLA update (already breached) | daily, up to a year after breach or 1000 % elapsed |

## Engine properties (Service Level Management > Properties > SLA Engine)

| Property | Default | Effect |
|---|---|---|
| `com.snc.sla.engine.version` | 2011 | 2010 is legacy |
| `com.snc.sla.engine.async` | false | |
| `glide.sla.calculate_on_display` | false | recalculate when a task form opens (load-time cost) |
| `com.snc.sla.calculation.use_time_left` | false | breach on time left instead of the rounded percentage (99.995 % rounds to 100) |
| `com.snc.sla.calculation.percentage` | 1000 | stop refreshing beyond this actual elapsed % |
| `com.snc.sla.calculate_planned_end_time_after_breach` | false | |
| `com.snc.sla.compatibility.breach` | false | show Breached as a stage, as the 2010 engine did |
| `com.snc.sla.always_populate_business_fields` | true (new) | |
| `com.snc.sla.default_conditionclass` | SLAConditionBase | |
| `com.snc.sla.workflow.run_for_breached`, `com.snc.sla.flow.run_for_breached` | false | |
| `com.snc.sla.run_old_sla_engine` | false | the pre-2010 escalation engine (task fields SLA due, Made SLA, Escalation) |
| `com.snc.sla.repair.enabled` | on for new instances | |

Logging (**Properties > SLA Logging**, default Notice): `com.snc.sla.task_sla_controller.log`, `.task_sla.log`, `.condition.log`, `.workflow.log`, `.calculatorng.log`, `.repair.log`, `com.snc.sla.breakdown_processor.log`; destination `com.snc.sla.log.destination`.

## Repair

Deletes and recreates task SLAs by replaying the task's audit history against the **current** definitions (also creating ones that never existed). Use after changing a definition or schedule.

- Task form related link **Repair SLAs**; task SLA form **Repair**; list action **Repair SLAs for selected**, related link **Repair for all filtered definitions**. Not available on the definition itself.
- **Service Level Management > Repair Logs** (`sla_repair_log`, `sla_repair_log_entry`): each task SLA has a *Before repair* and *After repair* entry; only Before = deleted, only After = newly created.
- Same dot-walk limitation as the timeline.

## Timeline (plugin `com.snc.sla.timeline`)

**Show SLA Timeline** on a task or task SLA; **Validate SLA Definition** on a definition (pick any task to see how the definition would have behaved). Shows stages coloured by elapsed % (green < 50, yellow 50 to 75, orange 75 to 100, red breached, grey paused), out-of-schedule stripes, retroactive time. **Show all task updates** adds updates that changed nothing: select one to see each condition and the task values at that moment. It always shows what a repair **would** produce.

## Breakdowns (plugin `com.snc.sla.breakdowns`)

Records who held the task during each slice of a task SLA: table `sla_breakdown_by_assignment` (assigned to, group, start, end, business time, % of duration, breached). **Service Level Management > Breakdowns > Breakdown definitions**: one definition per task table, field mappings, linked SLA definitions. Data older than a year is removed by a table cleanup rule ([[sys_auto_flush]]).

## SLA timer (plugin `com.sn_slm_timer`)

Which task SLA a workspace timer shows: **Service Level Management > Administration > SLA Timer Configuration** (`sla_timer_config`, mappings `sla_timer_config_mapping`). **SLA timer source**: None, *First to breach* (optionally filtered by condition or **Target**), *Task to SLA mapping* (ordered list of definitions). Options **Show completed**, **Show cancelled**, **Show actual time**. Colour: green, yellow at 50 % left, orange at 25 % left.

## Custom business rules on `task_sla`

- Never update the engine's own fields.
- Never update the parent task directly (recursion). Either call `setWorkflow(false)` on the task GlideRecord before `update()` (no audit entry, no other rules) or queue the update with script include `ScheduleOnce` (`setDocument`, `script`, `schedule()`). Server-side business rules, global scope.

## Other

- Dashboard **Service Level Management > Overview** (`com.snc.sla.overview`): my at-risk (≥ 75 %), breached, active SLAs.
- Domain separation: Standard; a task SLA takes the domain of its task; definitions can be overridden in a child domain.
- ATF tests: `com.snc.service_level_management.atf`.

## Related

- [[task_sla]] · [[Scheduled Jobs]] · [[SLA Does Not Attach or Cancels Instead of Pausing]]
