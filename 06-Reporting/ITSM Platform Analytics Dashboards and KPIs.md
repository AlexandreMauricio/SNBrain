---
type: reference
tags: [reference, reporting, incident, problem, change, request, sla]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Platform Analytics ITSM Dashboards" (pp. 2983-3004), read in full 2026-10-02 (the last rows of the legacy IT Agent dashboard table run onto p. 3005, already read with the Problem Management chapter)
sn-release: Australia
verified:
updated: 2026-10-02
---

# ITSM Platform Analytics dashboards and KPIs

**What it is:** the dashboards and Performance Analytics indicators shipped for ITSM (application `itsm_analytics`), with how each KPI is defined. Useful as a catalogue of ready-made indicators and as a model for writing your own.

Scores are collected daily; over a week, month, quarter or year counts are summed and percentages averaged.

## IT Agent dashboard (Service Operations Workspace)

Dashboard icon in the workspace. itil users see it; only admin can edit (**Edit**; if read-only, **Duplicate** and set the copy as default for the user group). Visualizations: average resolution time, closed incidents, incidents that missed SLA, % resolved without reassignment, average age of open incidents, % resolved on the day opened. More with ITSM Pro.

## Operational dashboards

| Dashboard | Visualizations (indicator) |
|---|---|
| Incident | overdue incidents; incidents nearing SLA (elapsed 50-75%, 76-85%, 86-95%, above 95%); open incidents not updated (age 1-5, 6-10, 10-30, over 30 days); created by priority; closed by channel; MTTR by priority; average reassignment; % high priority (P1 and P2); incidents created per user; % with a problem; outage hours due to incidents |
| Major incident | overdue (breached SLA); open by age and assignment, by service and state; nearing resolution SLA; closed by service; mean time to propose, acknowledge, resolve; % breached SLA; % closed without a post incident report; % with problems; outage hours |
| Change | open and open emergency changes by age (0-1, 2-5, 6-30, 31-90, over 90 days) and priority; new by risk; average age by risk; closed by priority; mean time to close; incidents caused by change; % unauthorized changes; outage hours. Tab *Change Success Score*: score by assignment group, % successful with / without issues by model and type, % failed |
| Request | open requested items by stage, state, age; due within 5 days; mean time to fulfil (also by category and item); closed by state (Skipped, Complete, Incomplete); by channel; requested items created from incidents |
| Service Catalog | best-practice deviations of active items; Virtual Agent render type; fulfilment automation level distribution; translation coverage |
| Interaction | interactions with a task (by task type); % first call resolution (closed with no task created); closed by channel |
| Problem | open by age and priority, by state and age; % open critical; % open classified as known error; average reassignment by category; closed by age and priority; mean time to close |
| On-call | active escalations by priority and acknowledgement; acknowledged by level, shift, group, channel; average acknowledged level per user (only members of on-call groups); not acknowledged; contact attempts acknowledged; % acknowledged / not by group; mean time to acknowledge by group and level; total on-call hours per user |

## Legacy content pack

Plugin *Performance Analytics - Content Pack - ITSM Dashboards* (some dashboards install inactive: configure, run the collection jobs, assign an owner, then activate in **Dashboard Properties**). Self-Service Analytics widgets: plugin `com.snc.pa.self_service_analytics` and job *[SSA] Self-Service Analytics*. Superseded by the dashboards above and by [[ITSM Success Dashboard]], but the indicator definitions remain a good reference.

### Indicator definitions

| Indicator | Definition |
|---|---|
| Number of open incidents | no **Resolved** date |
| Number of open incidents not updated in last 5 days | **Updated** more than five days ago |
| Number of open and overdue incidents | open incidents with a `task_sla` not Cancelled and **Actual elapsed percentage** over 100 |
| Number of open incidents that should be resolved in time | distinct open incidents with a non-cancelled `task_sla` |
| Number of incidents missed SLA | `incident_sla` records not closed that breached |
| Number of resolved incidents by first assigned group | |
| Number of open requested items | registered on or before today with no closed date or closed after today |
| Number of requests closed after due date | `sc_request.closed_at` > `sc_request.due_date` |
| Number of Closed Requests with Breached SLAs | distinct `task_sla` of type Request, **Has breached** true, stage not Cancelled, closed today |
| Number of open changes planned in the next 7d | planned start between today and the end of next week |
| Number of active task sla / breach task sla today | `task_sla` active today / with breach time before today |
| Cost of Incidents Resolved | daily sum of **Value** in `incident_metric` for definition *Incident Resolution Fixed Cost* |
| Cost of Requests Completed | same in `sc_request_metric` for *Request Resolution Fixed Cost* |
| Summed age / duration / reassignments | hours from opened to now, or to resolution; summed reassignment counts |

| Formula indicator | Formula |
|---|---|
| % of new critical incidents | new incidents with priority 1 / new incidents × 100 |
| % of open incidents not updated in last 5 days | not updated / open × 100 |
| % of overdue requested items | 100 − % of open requested items before due date |
| Active Breached SLAs Today | breach task sla today / active task sla × 100 |
| Average age of open incidents (days) | summed age / number open / 24 |
| Average resolution time (days) | summed duration of resolved / number resolved / 24 |
| Average reassignment of open incidents | summed reassignments / number open |
| % resolved by first assigned group | resolved by first group / resolved × 100 |
| % open and overdue incidents | open and overdue / open that should be resolved in time × 100 |
| % Resolved Incidents with Breached SLA; % Closed Requests with Breached SLA | breached / resolved (or closed) × 100 |
| Average Cost per Incident / per Request (also weekly) | cost / number resolved or completed |
| Predicted Average Cost of Open Incidents | weekly average cost × number of open incidents |
| New / Closed / Open workload | incidents + problems + requests |
| Workload backlog growth | new workload − closed workload |
| ITSM Average Overall Customer Satisfaction | normalised satisfaction score / survey instances |

Breakdowns: age, assignment group, category, contact type, item, location, opened-by or requested-by department, priority, risk, SLA and SLA definition, stage, state.

Legacy dashboards: *IT Executive*, *IT Manager* (`pa_viewer` to list indicators), *IT Agent* (single scores and heatmaps of own and group incidents, problems, requests; Spotlight reports need `pa_spotlight_viewer`).

## Related

- [[ITSM Success Dashboard]] · [[Benchmarks]] · [[SLA Definitions and Task SLAs]] · [[task_sla]]
