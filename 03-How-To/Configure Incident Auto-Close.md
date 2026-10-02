---
type: how-to
tags: [how-to, incident, automation]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Incident Management", topics "Configure incidents to close automatically", "Configure default user for auto-closing incidents" (pp. 2445, 2488-2489), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Configure incident auto-close

**Goal:** have Resolved incidents move to Closed after a number of days without anyone doing it.
**Prerequisites:** role admin.
**Navigation:** All > Incident > Administration > Incident Properties

## Steps

1. Open **Incident Properties**.
2. Tick *Enable auto closure of incidents based on Resolution date* (`com.snc.incident.autoclose.basedon.resolved_at`) to count from **Resolved**; untick to count from **Updated**.
3. In *Number of days after which Resolved incidents are automatically closed* (`glide.ui.autoclose.time`) enter the days. 0 disables.
4. Save.
5. Optional, to control who appears in **Updated by**: open the scheduled job **Autoclose Incidents** (**System Scheduler > Scheduled Jobs > Scheduled Jobs**) and add to **Job context**: `fcRunAs=<user_name>` and `fcScriptName=incident autoclose`.

## Result / how to check it worked

After the job runs, incidents resolved more than N days ago are Closed. Filter: State is Resolved and Resolved before N days ago: the list should be empty.

## Example

`glide.ui.autoclose.time` = 5, based on resolution date: an incident resolved on Monday closes the following Saturday even if someone adds a comment on Wednesday.

## Tables / fields involved

- [[incident]]: **State** (`state`), **Resolved** (`resolved_at`), **Updated** (`sys_updated_on`)
- `sys_properties`; scheduled job *Autoclose Incidents* running business rule *incident autoclose*

## Gotchas

- Counting from **Updated** means any update (even an inactivity monitor firing) restarts the clock. Give inactivity monitors the reset condition *Incident state is not Resolved*.
- Accepted **major incidents are never auto-closed**.
- Child incidents are closed by this job or by their caller, not by closing the parent.
- Troubleshooting: [[Resolved Incidents Are Not Closing Automatically]].
