---
type: how-to
tags: [how-to, sla, admin]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Time configuration", topics "Define a schedule", "Schedule fields", "Schedule entry fields", "Holidays" (pp. 2047-2053), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Define a schedule

**Goal:** create business hours with holidays excluded, to use in an SLA or elsewhere.
**Prerequisites:** role `schedule_admin` or admin.
**Navigation:** All > System Scheduler > Schedules > Schedules

## Steps

1. Select **New**. Fill **Name**, **Time zone** (a real zone, or Floating), optional **Type**. Save (context menu > Save).
2. In **Schedule Entries** select **New**: **Name**, **When** from/to, **Repeats** = Weekly, tick the days in **Repeat on**. Submit.
3. For holidays: create a second schedule; add one entry per holiday with **All day** ticked, **Repeats** yearly where it applies, and **Type** = Excluded.
4. Open the first schedule, related list **Child Schedules** > **Edit** (or New) and add the holiday schedule.
5. Select **Show Schedule** to check the result.

## Result / how to check it worked

The calendar shows working spans on weekdays and the holidays as excluded. Attach the schedule to an SLA definition and check **Business time left** on a test task.

## Example

| Record | Values |
|---|---|
| Schedule | *Example 9-18 weekdays*, Europe/Lisbon |
| Entry | *Work hours*, 09:00 to 18:00, weekly, Mon to Fri |
| Schedule | *Example holidays PT* |
| Entry | *25 December*, all day, yearly, type Excluded |
| Child schedule | *Example holidays PT* under *Example 9-18 weekdays* |

## Tables / fields involved

- `cmn_schedule`, `cmn_schedule_span`, `cmn_other_schedule` (child schedule link)

## Gotchas

- A warning about "no active entries" on a holiday-only schedule can be ignored.
- After saving a schedule of type maintenance, a UI policy hides **Type** on the form; change it from the list.
- Background: [[Schedules and Schedule Entries]].
