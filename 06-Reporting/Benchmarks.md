---
type: concept
tags: [concept, reporting, incident, change, problem, cmdb]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Benchmarks" (pp. 510-543), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Benchmarks

**In one line:** Benchmarks compares your instance's monthly KPIs (incident, problem, change, request, knowledge, CMDB, Virtual Agent, security) with anonymous aggregates of other opted-in customers, and shows your percentile rank.

## How it works

- Performance Analytics indicators named `Benchmark: ...` collect daily on the instance. Only counts and durations leave the instance, no record content.
- Scheduled jobs: **Upload the benchmark scores** (previous month, start of the month; the guide says both the 1st and the 3rd) and **Download the benchmark scores** (global results mid-month; the guide says both the 9th and the 11th). Both can be run on demand under **System Definition > Scheduled Jobs**. An email announces new data.
- A user `bm.scheduler` (Benchmark Scheduler) is created for data collection.
- Opt in from a **production** instance only (**Benchmarks > Setup > Opt-In Agreement**, or **Continual Improvement > Administration > Guided Setup**); not available to Express, federal or on-premise customers. Opt out any time (takes up to two monthly cycles; your data leaves the set and you lose the aggregates).
- Comparison groups (one filter at a time, for anonymity): global, industry, user size (active users), similar industry and size, region; Managed Service Providers see an MSP aggregate. A group with fewer than 20 participants is shown as *Other*. Six months of history.
- A change to a KPI's status or conditions takes one to two months to show cleanly in monthly values.
- Needs Service Portal for the dashboard. Domain separation: not supported.

## Roles

| Role | Can |
|---|---|
| `sn_bm_client.benchmark_admin` | opt in or out, enable and modify KPIs, everything below |
| `sn_bm_client.benchmark_data_viewer` | dashboard, trends, downloads; needs `pa_viewer` to drill into scorecards |
| `sn_bm_client.benchmark_recommendation_viewer` | recommendation candidates (contains `sn_process_optimization_viewer`) |

Roles can be attached to a KPI category (**Benchmarks > Administration > Category > View Roles**, admin) to restrict who sees it. Changing a KPI's conditions also needs the role of the source table's application (for example `knowledge_admin`, `sla_admin`).

## Setting up KPIs

**Benchmarks > Administration > Setup**: slider per KPI; click a KPI for its description, formula, conditions and source tables. New KPIs arrive enabled; upgrades keep your settings.

**Resolved incident KPIs** read **Resolved** (`resolved_at`) on `incident`. If the field does not exist, install *Incident Resolution Fields* (`com.snc.incident_resolution_fields`). If you track resolution in a custom field: change the condition of indicator source *Benchmark.Incidents.Resolved* (**Performance Analytics > Sources > Indicator Sources**) and replace `resolved_at` in the script *Benchmark.Incident.ResolveTime.Hours* (**Performance Analytics > Automation > Scripts**; a server-side PA script), then check the *Benchmarks Data Collection* job log.

Adapt conditions to your process (for example which priorities count as high). You can link an existing PA indicator to a Benchmark indicator to get breakdowns when drilling down.

## KPIs and their definitions

| Area | KPI | Definition | Better |
|---|---|---|---|
| Incident | % of high priority incidents resolved | P0 + P1 resolved / all resolved in the month | lower |
| | % resolved on first assignment | **Reassignment count** = 0 | higher |
| | % resolved within SLA | from `task_sla` | higher |
| | % reopened | **Reopen count** > 0 | lower |
| | Average time to resolve (all, and high priority) | creation to resolution | lower |
| | Incidents created per user | | lower |
| Problem | % of high priority problems; % of incidents resolved by problem; average time to close | | |
| Change | % of emergency changes; % of failed changes; average time to close | all = standard + normal + emergency | lower |
| Service Catalog | % of closed requests with breached SLAs; average time to fulfil (closed `sc_req_item`); requests created per user | | |
| Knowledge | % of incidents resolved using KB articles; article views per user (`sys_view_count`) | | higher |
| ITSM Virtual Agent | % call deflection (incidents and requests created through Virtual Agent, by deflection pattern); % of incidents auto-resolved | | higher |
| Other | Average customer satisfaction (`metric_results`, base Customer Satisfaction Survey, normalised); requesters per fulfiller ((active users − active ITIL users) / active ITIL users) | | |
| CMDB | % duplicate, % non-compliant, % stale CIs | from `cmdb_health_scorecard` | lower |
| Virtual Agent | % of users using it; % handed over to a live agent; CSAT | | |
| Security | % critical and high security incidents; vulnerability age, per asset, MTTR, remediation efficiency | | |
| Success Dashboard | self-solved %, call deflection %, structured tickets %, CSAT, MTTR, breached SLA %, first assignment resolution, automated resolutions | needs the Success Dashboard app | |

Each ratio KPI is a formula indicator over two `Benchmark: Number of ...` / `Benchmark: Total time ...` indicators (for example average time to close a change = total time to close changes / number of changes closed).

**Percentile rank**: 90% means your value is better than 90% of the peer group.

## Using it

- **Benchmarks > Dashboard**: list or card view per category, **Compare with** filter, thumbs up / down against global, six-month trend, PDF download. Time unit hours or days: property `sn_bm_client.dashboard_display_unit`.
- Click a KPI for the trend chart; click one of your data points to open the PA scorecard.
- Year-over-year analysis: property `sn_bm_client.months_copy_historical_pa_bm` (months), run PA job *Benchmarks Historical Data Collection* (24 months recommended; wait for state Collected), then scheduled job *Copy historical scores from PA to Benchmarks table*. Roles `sn_bm_client.benchmark_admin`, `pa_data_collector` or admin.
- Recommendation candidates are refreshed monthly.

## Related

- [[Continual Improvement Management]] · [[Incident Management Overview and Lifecycle]] · [[SLA Definitions and Task SLAs]]
