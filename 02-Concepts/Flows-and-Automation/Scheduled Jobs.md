---
type: concept
tags: [concept, automation, scripting, reporting]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Time configuration", topics "System scheduler", "Scheduled jobs", "Create a scheduled job", "Automate generation and distribution of a report", "Automatically generate something from a template", "Automatically run a script of your choosing", "Special cases in job schedules", "Advanced options", "Set an inactivity monitor" (pp. 2060-2081), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Scheduled jobs

**In one line:** a scheduled job runs something at a time or on a recurrence: a script, a report email, or a record generated from a template.

## Two layers

| Layer | Table | Use |
|---|---|---|
| Scheduled job definition | `sysauto` and children: `sysauto_script` (script), `sysauto_report` (report), `sysauto_template` (record from template), `scheduled_import_set` (import) | where you create and edit. **System Definition > Scheduled Jobs** |
| Schedule item (trigger) | `sys_trigger` | what the scheduler actually executes. View under **System Scheduler > Today's Scheduled Jobs**; do not edit these, edit the job |

States of a job: Ready, Running, Queued, Error. Monitor with [[System Events and Scheduled Jobs Dashboards]].

## The three kinds

- **Run a script** (role admin): **Run this script**, optional **Conditional** + **Condition** (last expression must evaluate to true/false), optional **Run as** (add the field to the form).
- **Report** (role `system_scheduler_admin`; `report_scheduler` through the report UI): **Report**, **Users**, **Groups**, **Email addresses**, **Subject**, **Introductory message**, **Type** (PDF, Excel, CSV, PNG, embedded PNG), **Omit if no records**, **Include with**. Recipients need **Notification** enabled on their user record. Calendar, map and single-score reports cannot be scheduled. The report's relative dates ("today") use the time zone of the **Run as** user unless **Run as tz** is set.
- **Template** (role `template_scheduler`): **Generate this** = a template record; creates an incident, change, CI and so on.

## Run options

Daily, Weekly, Monthly, Periodically (**Repeat interval** from **Starting**), Once, On Demand, Day and Month in Year, Day in Week in Month in Year, Week in Month, Business Calendar: Entry Start / Entry End (with an offset before or after).

- **Time zone**: *None* = the time zone of the user who runs the job; *Use System Time Zone*; or a named zone. Set the time zone first, then the times.
- **Advanced** (for recurring types): **Starting** and **Ending** define a window, **Repeat every** N units. A daily job with window 1 to 30 June at 09:00 repeating every 2 days runs 1, 3, 5 ... 29 June.
- **Priority**: essential jobs below 100. When 70 percent or more of jobs are overdue, jobs above 100 do not run.

## Special cases

- Day **31** = last day of the month in shorter months. Avoid 29 and 30 (skipped in February).
- Weekdays only: use a condition script.

```javascript
var d = new Date().getDay(); // 0 = Sunday, 6 = Saturday
answer = (d != 0 && d != 6);
```

- Condition scripts of **scheduled reports** run in the sandbox: no function definitions, limited API. For complex logic use a scripted job that triggers the report:

```javascript
var rpt = new GlideRecord('sysauto_report');
rpt.get('<sys_id of the scheduled report>');
gs.executeNow(rpt);
```

- Run a job from another script:

```javascript
var job = new GlideRecord('sysauto_script');
job.get('name', '<job name>');
SncTriggerSynchronizer.executeNow(job);
```

- **Scheduled jobs are data, not captured in update sets.** Move them by XML export/import; the imported job has no `sys_trigger` until you **update the job record** on the target instance.
- Domain-separated instances: **Domain iterator** runs a script job once per domain taken from a source table.
- After a clone, jobs may be pinned to nodes that no longer exist (stuck jobs).

## Inactivity monitors

**System Policy > SLA > Inactivity Monitors** (role `system_scheduler_admin`). For task tables only: when a task matching the **Condition** has had no **user** update for **Wait**, the event `<table>.inactivity` fires (and repeats). React with a notification or script action.

- At least one condition is required. System updates do not count as activity.
- Only one monitor per task: with several matching, lowest **Order** wins.
- Changing a monitor's conditions stops it tracking the records it tracked; records created before the monitor are not tracked.
- With incident auto-close, set a **Reset condition** or auto-close misbehaves.

## Related

- [[Create a Scheduled Script Job]] · [[Events and the Event Queue]] · [[Schedules and Schedule Entries]] · [[Update Jobs, Delete Jobs and One-Time Delete Rules]]
