---
type: troubleshooting
tags: [troubleshooting, incident, automation]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Incident Management", topics "Configure incidents to close automatically", "Close a major incident" (pp. 2488-2489, 2516-2517), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Resolved incidents are not closing automatically

## Symptom

Incidents stay in Resolved long after the configured number of days.

## Causes

| Cause | Check |
|---|---|
| `glide.ui.autoclose.time` is 0 | Incident Properties |
| Counting from **Updated** and something keeps updating the record | `com.snc.incident.autoclose.basedon.resolved_at` is false; look at the incident history for periodic updates |
| An **inactivity monitor** fires on resolved incidents and resets the clock | **System Policy > SLA > Inactivity Monitors**: no reset condition |
| The incident is an accepted **major incident** | **Major incident state** = Accepted: by design, closed manually by a major incident manager |
| The scheduled job **Autoclose Incidents** is inactive, stuck or in error | [[System Events and Scheduled Jobs Dashboards]] |

## Fix

- Set the property to count from the resolution date (default on new instances; upgraded instances must set it).
- Add reset condition *Incident state is not Resolved* to the inactivity monitor.
- Recover or reactivate the job.

## Related

- [[Configure Incident Auto-Close]] · [[Scheduled Jobs]]
