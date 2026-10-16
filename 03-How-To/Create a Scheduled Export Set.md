---
type: how-to
tags: [how-to, data-management, automation]
status: documented
source: ServiceNow docs, Brazil, Workflow Data Fabric > Exports > Export sets, topics "Create an export definition", "Create an export target", "Create an export set", "Schedule an export", "Export set history", https://www.servicenow.com/docs/r/integrate-applications/system-export-sets/t_ScheduleAnExport.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Create a scheduled export set

**Goal:** write chosen records to a file on a MID Server every day, sending only what changed since the last run.
**Prerequisites:** roles export_set_admin (and export_set_scheduler or export_set_admin to schedule); a MID Server that is Validated and Up (not clustered) whose service account can write to the target folder.
**Navigation:** All > System Export Sets

## Steps

1. **Export Definition > New**: **Name**, **Table**, **Fields**, optional **Filter** (do not filter on Created or Updated if you want delta exports).
2. **Export Targets > New**: **Name**, **MID Server**, **File Path** relative to the MID directory.
3. **Create Export Set**: **Name**; *What to export* = Yes + the definition; *Where to export to* = Yes + the target. Submit, then set **File name**, **Format** (CSV, XML, Excel, JSON), **Append timestamp**.
4. **Administration > Scheduled Exports > New**: **Export set**, **Run as** (a user who can read the data), **Run** Daily, **Time**; tick **Enable delta exports** with **Delta on or after** *Updated*; leave **Last export scheduled run** empty for a full first run. Optional pre / post scripts (`cancel = true` to skip a run) and **Parallel export** for 50,000+ rows.
5. **Execute Now** to test.

## Result / how to check it worked

An export history record reaches **Completed** with the file attached, and the file appears in the MID folder. The next run contains only changed records.

## Example

| Part | Value |
|---|---|
| Definition | *Example Active Incidents*: table `incident`, fields number, short_description, state, assigned_to, filter active=true |
| Target | *Example MID export folder*: MID *example-mid-01*, path `export/incidents` |
| Export set | *Example Incident Feed*, file `incidents`, CSV, timestamp appended |
| Schedule | daily 02:00, delta on Updated |

## Tables / fields involved

- `sys_export_set` and the definition, target, schedule and history records (table names not given by the docs).

## Other ways to do this

URL exports from a script or another system ([[Export Data with a URL]]); list exports ([[Exporting Data]]).

## Gotchas

- Attachments are not exported.
- Delta exports do not work on database views.
- Export limits and display-value settings: [[Export Limits and Properties]].
- Background: [[Export Sets]].
