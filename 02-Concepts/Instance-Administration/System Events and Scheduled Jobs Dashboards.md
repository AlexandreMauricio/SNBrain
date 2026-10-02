---
type: concept
tags: [concept, instance-admin, automation]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Monitor System Events and Scheduled Jobs dashboards" (pp. 2786-2794), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# System events and scheduled jobs dashboards

**In one line:** two dashboards under **System Diagnostics** that show whether the event queue and the scheduler are healthy, and let you clean up broken jobs.

## System Events dashboard

**System Diagnostics > System Events Dashboard** (roles `events_scheduler_dashboard_viewer` and `scheduler_dasboard_viewer` as spelled in the guide; the dashboard application must be installed). Filter by queue, event and date range.

- **Health cards**: Active Delegators / Active Processors (queues on the older delegator model) or Active Jobs (queues on the processing framework), Event Processing Alerts (last 5 hours), Event Jobs on Schedule. Red numbers need attention.
- **Current scores** from [[sysevent]]: Total, Ready, Processing, Processed, Error, Transferred.
- **Trends** (24 hours by default, up to 15 days): delegation, processors, specific events, email/script action handlers.
- **Alerts**: five shipped; conditions at **System Policy > Events > Configure Alerts**, raised alerts at **System Policy > Events > Alerts**, evaluated about every 15 minutes. **Reset alert** clears one.

A growing **Ready** count means events are not being processed fast enough: notifications arrive late.

## Scheduled Jobs dashboard

**System Diagnostics > System Events and Job Monitoring > Scheduled Jobs Dashboard**.

| Card | Meaning | Action |
|---|---|---|
| Stuck Jobs | jobs in `sys_trigger` pinned to a node (**System ID**) that no longer exists. Typical **after a clone** | **Recover** (clears System ID) or delete |
| Permanent Error Jobs | state Permanent Error (also set by an upgrade fix script for jobs pinned to vanished nodes) | Recover (back to Ready) or delete |
| Pending / Running Jobs | about to run / running | |
| Total Execution Count, Average job wait time | last 24 hours, up to 7 days, from `sys_scheduler_job_history` | |
| Scheduled Job Trends | completed jobs per **job classification** (default `TriggerType.JobName`; rules in Job Classification Rules): priority, execution count, average and total processing time | |

**Wait time** = now minus **Next Action** when that is in the past; 0 otherwise. Lower priority number = higher priority.

## Related

- [[Events and the Event Queue]] · [[Monitoring and Troubleshooting Instance Performance]] · [[Instance Clone Overview]]
