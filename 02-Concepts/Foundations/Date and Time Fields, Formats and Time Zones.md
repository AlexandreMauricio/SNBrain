---
type: concept
tags: [concept, platform, fields, task]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Time configuration", topics "Date and Date/Time fields", "Default date and time fields", "Time worked", "Resolve time", "Export date and time formats", "Set a system time zone", "Time zones" (pp. 2041-2046, 2097-2104, 2108-2109), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Date and time fields, formats and time zones

**In one line:** the database stores every date/time in **UTC**; what a person sees is converted to their time zone and formatted with their (or the system's) date and time format.

## Field types

| Field type | Dictionary type | Notes |
|---|---|---|
| Date | `glide_date` | no time, no time zone conversion |
| Date/Time | `glide_date_time` | stored in UTC |
| Time | `glide_time` | |
| Duration | `glide_duration` | a length of time |
| Due date | `due_date` | |

**Created** (`sys_created_on`) and **Updated** (`sys_updated_on`) exist on every table ([[System Fields on Every Table]]).

## Formats

| Setting | Property | Default |
|---|---|---|
| System date format | `glide.sys.date_format` | `yyyy-MM-dd` |
| System time format | `glide.sys.time_format` | `HH:mm:ss` |

- Pattern letters as in Java SimpleDateFormat: `yyyy`, `MM` (month), `dd`, `HH` (0-23), `hh` (1-12), `mm` (minutes), `ss`, `a` (AM/PM). `z` is not supported.
- Use a four-digit year. With `yy`, years are guessed in a window of 80 years back and 20 forward (51 becomes 1951).
- Users override both in their profile (**Date format**; **Time format** must be added to the Self-Service view of the user form).

## Time zones

- System time zone: `glide.sys.default.tz` (**System Properties > System**). Empty means America/Los_Angeles. Set it explicitly, as Region/City (handles daylight saving) and not as an abbreviation such as GMT.
- A user's **Time zone** field wins over the system one. The time zone changer in the header changes it for the session only.
- The choices offered come from the Time zone choice list on `sys_user` (**Configure Choices** to add or remove).
- **Email notifications** print times in the **system** time zone, not the recipient's; `glide.email.append.timezone` appends the zone.
- SLA definitions choose a **Timezone source** (caller's, SLA definition's, and others); the caller's zone is unreliable when callers have none.
- Scheduled reports and scheduled imports evaluate in the time zone of their **Run as** user unless **Run as tz** (add to the form) says otherwise.

## Exports

| Format | Date/time fields | Duration |
|---|---|---|
| Excel | display value | stored value (seconds) |
| XML | stored (UTC) value | stored |
| PDF | display value | display value |
| CSV | display value | see [[Exporting Data]] |

## Time fields on tasks

- **Time worked** (`time_worked`): a timer on the form (add the field to the form); on save the new time creates a row in `task_time_worked`. Editing those rows does not change the task's total unless `com.snc.time_worked.update_task_timer` is true. Does not render correctly in Service Portal.
- **Resolve time** (`calendar_stc`) on Incident and Request: seconds between **Opened** and resolved/closed, set by business rules at closure. To show it as a duration on forms and lists, add dictionary attribute `format=glide_duration` (reports and exports still show seconds).
- For "how long was it in state X or assigned to Y" use [[Metric Definitions and Metric Instances]]; for deadlines use SLAs.

## Related

- [[Schedules and Schedule Entries]] · [[Set the System Time Zone and Date Format]] · [[Field Types Reference]]
