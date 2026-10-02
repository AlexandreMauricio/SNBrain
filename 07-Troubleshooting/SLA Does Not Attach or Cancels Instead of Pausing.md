---
type: troubleshooting
tags: [troubleshooting, sla]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Service Level Management", topics "SLA conditions", "Understand why an SLA did not trigger as expected", "SLA calculation", "Use exact times in SLA calculations", "Repair SLA", "SLA (Legacy) engines" (pp. 3167-3169, 3178-3180, 3191-3197), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# SLA does not attach, or cancels instead of pausing

## Symptoms and causes

| Symptom | Likely cause | Fix |
|---|---|---|
| No task SLA appears | Start condition does not match, or Stop/Cancel already matches (Start is a subset of Stop) | open **Show SLA Timeline** / **Validate SLA Definition**, enable **Show all task updates**, select the update and read which condition failed |
| Task SLA goes to **Cancelled** when the task is put on hold | Start condition lists states that exclude the pause state, with **When to cancel** = Start conditions are not met | add the pause state to Start, or set **When to cancel** to *Cancel conditions are met* / *Never* |
| Attaches already Paused, then cancels | Pause condition is a subset of Start in a way that leaving pause also leaves Start | review both conditions |
| Attaches already breached and floods notifications | **Retroactive start** on an old task | tick **Retroactive pause time**; keep `com.snc.sla.flow.run_for_breached` / `.workflow.run_for_breached` false |
| Elapsed % or time left looks stale | values are refreshed by scheduled jobs, not live | `glide.sla.calculate_on_display` (cost at form load), or check the *SLA update* jobs are running |
| Breach at "99.99 %" | percentage rounded to two decimals reaches 100 | `com.snc.sla.calculation.use_time_left` = true |
| 1-day SLA breaches after 3 days | days are 24-hour blocks against an 8-hour schedule | enter the duration in hours |
| Business elapsed is 0 | the whole period is outside the schedule, or wrong time zone source | timeline shows out-of-schedule stripes |
| Task SLAs wrong after changing the definition or schedule | existing task SLAs are not recalculated | **Repair SLAs** |
| Repair gives a different result from what happened live | conditions on dot-walked fields are replayed with the final value only | copy the value to a field on the task |
| Legacy task fields **SLA due**, **Made SLA**, **Escalation** change | pre-2010 escalation engine still running | `com.snc.sla.run_old_sla_engine` = false |
| Percentage timers fire outside business hours | relative duration ignores the schedule in the flow | create `com.glideapp.workflow.duration.relative_uses_schedule` = true |

For deeper tracing tick **Enable logging** on the definition, or raise the SLA logging properties.

## Related

- [[SLA Definitions and Task SLAs]] · [[SLA Engine, Repair, Timeline and Breakdowns]]
