---
type: concept
tags: [concept, reporting, ai, schema]
status: documented
source: ServiceNow Brazil docs, Platform Analytics guide > Dashboards > Insights on dashboards (overview, Process Mining suggestions, jobs, system properties), read 2026-10-30. https://www.servicenow.com/docs/r/now-intelligence/proactive-analytics/proactive-analytics.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Proactive Analytics Insights on Dashboards

**In one line:** daily jobs check Performance Analytics indicators and put **insight cards** on Platform Analytics dashboards when something notable happens: a trend, a target or threshold event, a KPI signal, a key contributor or a process bottleneck.

From the Brazil docs; not tested. Needs an active Performance Analytics subscription and indicators on the dashboard. Applies only to PA indicators in Brazil, and only to Platform Analytics dashboards (technical included), not to responsive ones, even migrated. Turned on per dashboard in **Settings > Insights**, then the viewer uses the **Insights** button (orange dot = new).

## Insight types

| Type | Fires when | Button opens |
|---|---|---|
| Trend | an indicator set to maximize or minimize moves the other way | not stated |
| Target or threshold | missed or likely missed target; breached or likely breached threshold (all-time highs and lows are mentioned) | KPI Details |
| Target Suggestion | target insights on, but a target or review date is missing | modal with suggested values |
| KPI Signal | outlier (beyond 3 sigma), short run (4 scores on one side of the average, 3 beyond 2 sigma), long run (7 on one side), anti-signal (stable a long time). Needs KPI Signals active on the indicator | KPI Details with Signals pane |
| Key contributor | a breakdown with particular impact; daily indicators only; KPI Signals need not be active | KPI Details (set the filter yourself) |
| Process Mining | possible bottleneck; needs `sn_process_optimization_analyst` and the DA Process Mining Insights plugin | Analyst Workbench |
| Custom | shipped with some solutions or applications | per solution |

Cards of one type are grouped. **Unconfirmed variants:** the page gives a card lifespan of 30 days and an expiry of 14 days.

Changing a PA data collection job after key contributors start can shift the baseline; the docs suggest deleting the matching row in `pa_correlation_analyzer_state`.

## Process Mining suggestions

Job *PA Indicator Recommendations* scans indicators for anomalies in the last 15 days and proposes projects for the top three by dashboard use. Needs audit on the facts tables, a process configuration, a template project, and viewers with `sn_process_optimization_analyst`. One click on **Suggestions** creates and runs the project.

## Jobs (`sys_job`, schedule in `sys_trigger`, all daily)

| Job | Purpose | Schedule item |
|---|---|---|
| KPI Signals Analytics Job | active signals to insights and flow triggers | not stated |
| PA Forecast Job | targets against forecast | PA Forecast Job Schedule |
| PATarget | target notification summary event | Check PA Targets |
| PAThreshold | threshold reached event | Check PA Thresholds |
| Trend Insights Job | significant deviations in the last 30 days | Trend Insights Job Schedule |
| TriggerDefinitionProactiveAnalytics | activates the trigger in `sys_hub_trigger_definition` if a PA Premium plugin exists | Proactive Analytics Trigger Definition Activation Job |

## Properties

| Property | Meaning | Default |
|---|---|---|
| `com.snc.pa.insights.query_limit` | rows from `par_computed_insight` in the Insights API GET | 1000 |
| `com.snc.pa.insight.max_days_in_past` (create it) | days of insights retrieved | 14 |
| `com.snc.pa.correlation.enable_insights` | key contributor cards | true |
| `com.sys_par_insights_enabled` | the feature | not recorded |
| `com.snc.pa.xmr.processes.limit` | KPI Signals configurations (`pa_xmr_processes`) evaluated | 1000, maximum 10,000 |

## Tables

`par_computed_insight` (standard insights), `par_custom_insight_content` (custom), `par_indicator_model` (PA recommendations), `par_insight_user_actions`, `par_recommendation`, `par_recommendation_user_action`, `par_automated_kpi_promin_project`.

## Example

Indicator *Example Open Incidents*, set to minimize, with a target and review date, on dashboard *Example Service Desk Overview*: after a week of rises, a Trend card appears, and the viewer opens KPI Details to check by *Example Assignment Group*.

## Related

- [[Platform Analytics Dashboards]] · [[Platform Analytics Experience Overview]]
