---
type: concept
tags: [concept, reporting, forms-lists]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Time configuration", topics "Using schedules and calendars", "Timeline pages", "Create a timeline page", "Timeline sub item", "Display a metric as a timeline", "Range calculator scripts", "Timelines" (pp. 2056-2058, 2104-2119), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Timeline pages and schedule pages

**In one line:** a timeline page draws records as horizontal bars between two date fields (a Gantt-like view); a schedule page is the scripted definition behind calendar displays such as on-call or maintenance schedules.

## Timeline pages

**System UI > Timeline Pages** (`cmn_timeline_page`). Admin only by default.

| Field | Meaning |
|---|---|
| **Table**, **Start date field**, **End date field** | what each bar (span) represents |
| **Condition**, **Sort by** | which records, in what order |
| **Span text fields**, **Tooltip text fields** | labels and hover text |
| **Show left pane**, **Show summary pane**, **Show grid lines**, **Auto refresh**, **CSS span color** | display |
| **Allow horizontal moving**, **Allow start time dragging**, **Allow end time dragging** | let users change the record's dates by dragging |
| **Range calculator** | script include restricting drags or updating parents |

- **Timeline Page Span Styles**: conditional colours and label decoration, evaluated by **Order**.
- **Timeline Sub Items**: child bars from a table referencing the parent table (release > sprint > story), with a **Restriction** (None, Restrict by parent, Update parent).
- Give non-admins access with a module of **Link type** = Timeline Page (add the field to the module form). The module is partly static: pane and refresh settings are fixed at creation.
- **Metric timelines**: tick **Timeline** on a metric definition; itil users then get **Metrics Timeline** in a task's form context menu ([[Metric Definitions and Metric Instances]]).
- A dark blue bar has a start but no end date.

## Schedule pages

**System Scheduler > Schedules > Schedule Pages** (`cmn_schedule_page`): heavily scripted (HTML, client script, server AJAX processor). Opened with `show_schedule_page.do?sysparm_page_schedule_type=<type>`. Used by Project Management, Maintenance Schedules, Group On-Call Rotation, Field Service Management. The guide's advice: use the shipped ones.

## Example

Timeline *Example high priority changes*: table Change Request, start **Planned start date**, end **Planned end date**, condition priority is 1 or 2, span text **Number** and **Short description**.

## Related

- [[Schedules and Schedule Entries]]
