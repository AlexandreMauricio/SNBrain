---
type: concept
tags: [concept, sla, change, admin]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Time configuration", topics "Schedules", "Holidays", "Parent and child schedules", "Define a schedule", "Schedule fields", "Schedule entry fields", "Repeat a monthly schedule", "Define a relative duration" (pp. 2046-2060, 2099-2102), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Schedules and schedule entries

**In one line:** a schedule is a named set of time spans that says which time *counts* (business hours) or is *excluded* (holidays), used by SLAs, inactivity monitors, on-call rotations and change windows.

## Structure

| Piece | Table | Holds |
|---|---|---|
| Schedule | `cmn_schedule` | **Name**, **Time zone**, **Parent**, **Type**, description |
| Schedule entry | `cmn_schedule_span` | one time span or repeating span: **When** (start/end, **All day**), **Repeats** (daily, weekly, monthly, yearly) with **Repeat every**, **Repeat on**, **Monthly type**, **Yearly type**, **Repeat until**; **Type**; **Show as** (Busy, Free, Tentative, On call) |
| Child schedule | related list on the schedule | another schedule included in this one |

Module **System Scheduler > Schedules > Schedules**. Roles `schedule_admin` or admin. **Show Schedule** (related link) displays the result, including child schedules, in a calendar where entries can also be created by clicking or dragging.

## Time zone

- A specific zone: the hours are in that zone; users elsewhere see them converted.
- **Floating**: the hours apply in whatever time zone the process or person using it is in (8:00 to 17:00 is 8:00 to 17:00 for everyone).

## Type values with meaning

| Type | Effect |
|---|---|
| Excluded | time removed from SLA counting (holidays) |
| Maintenance | windows where change work is allowed |
| Blackout | windows where change work is not allowed |
| (anything else) | just a label |

A schedule (including its children) cannot mix maintenance and blackout entries. A parent schedule needs at least one entry that is not excluded.

## Holidays

Create a holiday schedule (one entry per holiday, type Excluded) and add it as a **child schedule** of the working-hours schedule. Base example: *8-5 weekdays excluding holidays* contains *U.S. Holidays*.

Several regions with the same hours but different holidays: one work schedule plus one holiday schedule per region, with the **work schedule as child of each regional holiday schedule** (regions + 1 schedules), then use the regional schedule in the SLA.

## Base schedules

*8-5 weekdays*, *8-5 weekdays excluding holidays*, *U.S. Holidays*, *Weekends*, plus maintenance/blackout samples and the Project/Resource Management defaults (8:00 to 12:00 and 13:00 to 17:00 on weekdays).

## Repeating monthly entries

- `glide.schedules.repeat_nth` = `day` (default): "first Monday" means the first Monday. `week` (legacy): the Monday of the same week number.
- `glide.schedules.fifth`: what a "fifth Thursday" entry does in a month with four: `last` (default: last Thursday), `next` (first of next month), `strict` (skip the month).

## Relative durations

**System Scheduler > Relative Durations**: scripted durations for SLAs such as *Next business day by 4pm*, *2 business days by 4pm* (adds a day if after 10:00), *3 business days by 4pm*, *End of next business day*. Chosen in an SLA definition with **Duration type** = relative duration. The end time in the script is hard-coded, not taken from the schedule. Without a schedule a "business day" is 24 hours. **Pause conditions do not work with relative durations.**

## Gotchas

- Changing the global date format affects how **All day** entries are calculated.
- Schedules are domain-separated (entries inherit the schedule's domain).
- Business calendars are the newer way to define period-based calendars: [[Business Calendars and Fiscal Calendars]].

## Example

Schedule *Example Lisbon business hours*, time zone Europe/Lisbon, entry 09:00 to 18:00 repeating weekly on Monday to Friday, child schedule *Example PT holidays* (excluded entries). An 8-hour SLA started Friday 16:00 breaches Monday 15:00.

## Related

- [[Define a Schedule]] · [[Scheduled Jobs]] · [[Date and Time Fields, Formats and Time Zones]]
