---
type: how-to
tags: [how-to, sla, incident]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Service Level Management", topics "Create an SLA definition", "Configure SLA retroactive start and pause", "Verify SLA definition using SLA timeline" (pp. 3155-3160, 3174), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Create an SLA definition

**Goal:** attach a timed commitment to tasks that match a condition.
**Prerequisites:** role admin (or `sla_admin` / `sla_manager`). A schedule if the clock should only run in working hours ([[Define a Schedule]]).
**Navigation:** All > Service Level Management > SLA > SLA Definitions

## Steps

1. Select **New**. Fill **Name**, **Type**, **Target**, **Table**.
2. **Duration type** = User specified duration and **Duration**; or pick a relative duration.
3. **Schedule source** (and **Schedule**), **Timezone source**.
4. **Flow** (for example *Default SLA flow*) for notifications.
5. **Start condition** tab: conditions; **When to cancel**; optionally **Retroactive start** with **Set start to** and **Retroactive pause time**.
6. **Pause condition** tab and **When to resume**.
7. **Stop condition** tab. Optional **Reset condition**.
8. Submit.
9. Open the definition again and select **Validate SLA Definition**: pick an existing task to see on the timeline how the definition behaves against its history.

## Result / how to check it worked

Create or update a task that meets the start condition: a row appears in its **Task SLAs** related list in stage In Progress with a **Breach time**.

## Example

| Field | Value |
|---|---|
| Name | Example P2 resolution (2 business days) |
| Table | Incident |
| Target | Resolution |
| Duration | 16 hours (two 8-hour days; do not enter 2 days) |
| Schedule | 8-5 weekdays excluding holidays |
| Start condition | Active is true AND Priority is 2 - High; When to cancel = Start conditions are not met |
| Retroactive start | Opened; Retroactive pause time ticked |
| Pause condition | State is On Hold AND On hold reason is Awaiting Caller |
| Stop condition | State is one of Resolved, Closed |

## Tables / fields involved

- `contract_sla` (definitions), [[task_sla]], `cmn_schedule`

## Gotchas

- **Days are 24-hour blocks**: on an 8-hour schedule, "1 day" breaches after three business days.
- Keep Start and Pause compatible: if the pause state makes the Start condition false, the SLA is cancelled, not paused.
- Avoid dot-walked fields that change in conditions.
- Existing open tasks get the new SLA only when they are next updated; **Repair SLAs** applies it immediately.
- After changing a definition, running task SLAs keep their old values until repaired.
- Background: [[SLA Definitions and Task SLAs]].
