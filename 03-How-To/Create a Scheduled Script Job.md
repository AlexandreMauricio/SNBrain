---
type: how-to
tags: [how-to, automation, scripting]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Time configuration", topics "Create a scheduled job", "Automatically run a script of your choosing" (pp. 2063, 2072-2076), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Create a scheduled script job

**Goal:** run a server script at a fixed time or interval.
**Prerequisites:** role admin.
**Navigation:** All > System Definition > Scheduled Jobs

## Steps

1. Select **New**, then **Automatically run a script of your choosing**.
2. Fill **Name**; set **Run** (Daily, Weekly, Monthly, Periodically...), **Time zone**, **Time** and, where shown, **Day** or **Repeat interval**.
3. Optional: tick **Conditional** and write a **Condition** script whose last expression is true or false.
4. Write the code in **Run this script**.
5. Submit. Use **Execute Now** on the saved record to test.

## Result / how to check it worked

The job appears under **System Scheduler > Today's Scheduled Jobs** when due. After a run, check the effect of the script and the system log.

## Example

Daily at 02:00, only if there are active incidents older than 30 days.

Condition:

```javascript
var ga = new GlideAggregate('incident');
ga.addAggregate('COUNT');
ga.addQuery('active', 'true');
ga.addQuery('sys_created_on', '<', gs.daysAgo(30));
ga.query();
ga.next();
ga.getAggregate('COUNT') !== '0'
```

Script:

```javascript
gs.eventQueue('x_example.old_incidents.found', null, '', '');
```

## Tables / fields involved

- `sysauto_script`: **Run** (`run_type`), **Time** (`run_time`), **Run this script** (`script`), **Condition** (`condition`)
- `sys_trigger`: the generated schedule item

## Gotchas

- Not captured in update sets: move by XML and re-save on the target.
- Time zone *None* means the creator's time zone, which surprises people after the creator changes.
- Background: [[Scheduled Jobs]].
