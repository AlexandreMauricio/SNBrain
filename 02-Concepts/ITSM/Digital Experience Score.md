---
type: concept
tags: [concept, reporting, assets, incident, sla, admin]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Digital End-User Experience" > "Digital Experience Score" (pp. 2053-2083: overview, score hierarchy, installation and demo data, metric definitions, qualitative mapping, survey configuration, dashboard tracking, installed roles and tables, properties, metric lists, calculation, normalization, data collection frequency), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Digital Experience Score

**In one line:** Digital Experience Score (`sn_dex_score`, "DEX Score") rolls monitored metrics, survey sentiment and service desk results into one 0-100 score per application, device group and organisation.

Builds on [[Digital End-User Experience Overview and Architecture]]. Installing it (role admin) also brings ITOM Java Utilities (`com.itom.jutils`), Digital Experience Feedback Survey (`sn_dex_feedback_sur`) and the DEX suite.

## Hierarchy and weights

| Level | Made of | Default weights |
|---|---|---|
| Digital experience score | application experience, device experience | 50 / 50 |
| Application experience (average over monitored applications) | application health metrics, user sentiment, service experience | 50 / 30 / 20 |
| Device experience (average over devices, shown per device OS group) | device health metrics, user sentiment, service experience | 50 / 30 / 20 |

Weighted average = Σ(score × weight) ÷ Σ(weights), rounded. Ranges: **Good** above 75, **Average** 45 to 75, **Poor** below 45. Weights live in DEX Score Hierarchy Weights (`dex_score_hierarchy_weights`).

### Metrics

| Group | Metrics |
|---|---|
| Application health | installed: Application crashes, CPU usage, Memory usage; web: Average DNS lookup, Average page load time, Average response time, Failed web requests |
| Device health | Battery health, CPU usage, Disk usage, Memory usage, Wifi receive rate, Wifi RSSI, Wifi transmit rate |
| User sentiment | Application survey, Device survey (ratings 1 to 5) |
| Service desk, contributing | CSAT of resolved incidents (submitted surveys only), mean time to resolve (hours, creation to resolution), % first assignment resolution (**Reassignment count** `reassignment_count` = 0), % incidents that breached SLA (**Has breached** true in Task SLA `task_sla`), % reopened (**Reopen count** above 0) |
| Service desk, shown but not contributing | number of resolved incidents, number of closed major incidents (Major Incident Management active and major incident state Accepted), total outage hours (Outage `cmdb_ci_outage`) |

### Normalization

Each raw value is mapped from its Good, Average or Poor value range onto the matching range of the 0-100 scale. L1, H1 = low and high of the target range; L2, H2 = low and high of the metric's value range; M1 = the value.

- Higher is better (Wi-Fi receive rate): `L1 + ((M1 - L2) / (H2 - L2)) × (H1 - L1)`
- Lower is better (CPU usage): `H1 - ((M1 - L2) / (H2 - L2)) × (H1 - L1)`

## Configure

Role `sn_dex_score.digital_workplace_leader` (metric definitions also `sn_dex.admin`). Menu **Digital Experience Score**.

| Module | What |
|---|---|
| **Metric Definition Configuration** (`dex_score_metric_definition`) | **Metric visibility** (*L1 checklist*: shown to service desk agents on the incident Investigation tab; *Advanced*: administrators and operators, and agents via *Show additional metrics*), **Metric category** (a device health category of [[DEX Self-Service and Device Actions]]), **Good / Average / Poor lower bound**, **Max upper bound**, **Weight**, **Contributes to DEX score**, **Value type** (quantitative or qualitative), **Active** (only active metrics are calculated) |
| **Qualitative Metric Score Mapping** | **Metric**, **Normalized score** (1-100), **Qualitative value** (Poor, Moderate, Good), for example Battery health |
| **DEX Survey Configuration** (`dex_survey_configuration`) | **Survey feedback type** (application or device), **Survey trigger group** (default *Random group every week*), **Repeat survey after**, **Active from**, **Active**, **Trigger criteria** and **Minimum threshold (per week)** (application surveys only, for example usage above 15 hours a week) |

Properties: `sn_dex_score.active` (default true; false makes calculations, dashboard and configuration unavailable), `sn_dex_score.company_target_score` (default 75, 0-100; the target line on the dashboard).

## Dashboard

**Digital Experience Score > Dashboard** (roles `sn_dex_score.digital_workplace_leader` or `sn_dex_score.dashboard_user`). Period Weekly (default) or Monthly; optional location filter; **See how it's calculated** on each page.

- **Application experience** tile: score and trend, applications by experience (Good, Average, Poor), the three applications needing attention. **View all applications** > Installed or Web tab > application: tabs *Application health metrics* (with **Suboptimal devices** > **Show device list**), *User sentiment*, *Service experience*. **No. of devices** gives the score per device.
- **Device experience** tile: the same per device OS group (*Device groups needing attention*, **View all device groups**, per-device scores).

Data availability: daily aggregation starts at 00:00 UTC and shows on the third day; weekly data shows on Monday of the next week; monthly data on the 2nd of the next month. Own reports: Performance Analytics or reports over the DEX Score tables ([[DEX Reference]]; KB1808487).

## Roles and tables

| Role | Access |
|---|---|
| `sn_dex_score.digital_workplace_leader` | dashboard plus all configuration (contains `sn_dex_score.dashboard_user`, the feedback survey admin role, `sn_dex.user`) |
| `sn_dex_score.dashboard_user` | dashboard (contains `sn_sow.sow_user`) |
| `sn_dex_score.dashboard_application_pages_user` / `.dashboard_device_pages_user` | only the application / device pages |
| `dex_feedback_survey_admin` | survey configuration (contains `survey_admin`) |

Tables: `dex_score_hierarchy_weights`, `dex_score_metric_definition`, Survey Configuration (`dex_survey_configuration`), Survey Feedback Topic Definition (`dex_survey_feedback_topic_definition`: the areas rated in the survey).

## Demo data

Non-production instances only. **System Definition > Scheduled Jobs** > *CreateDemoDataForDEXScoreJob* > **Execute Now**: creates demo agents, score records and 90 days of health, survey and SLA data.

Removal: run *DeleteAggregatedDemoDataDexScore*, wait until it is gone from Pending and Running Scheduled Jobs, then *DeleteDemoDataDexScore*, then delete the global-scope leftovers. The guide gives a **Scripts - Background** script (server-side, global scope, **deletes records**) that removes Computer (`cmdb_ci_computer`), User (`sys_user`) and Location (`cmn_location`) records whose name starts with the demo prefix:

```javascript
// Scripts - Background, scope global. Deletes: preview with a list filter first.
var prefix = "[DEXScore Demo]";
["cmdb_ci_computer", "sys_user", "cmn_location"].forEach(function (table) {
    var gr = new GlideRecord(table);
    gr.addEncodedQuery("nameSTARTSWITH" + prefix);
    gr.query();
    gr.deleteMultiple();
});
```

## Example

Application *Example App*: health 55 (weight 50), sentiment 58 (30), service 72 (20) → (55×50 + 58×30 + 72×20) ÷ 100 = 59, Average. A CPU usage of 79 in an average value range 55-84 mapped (lower is better) onto 65-74 gives 74 − ((79 − 55) ÷ (84 − 55)) × 9 ≈ 66.

## Related

- [[DEX Self-Service and Device Actions]] · [[DEX Workspace Pages, Insights and Device Investigation]] · [[DEX Reference]] · [[ITSM Platform Analytics Dashboards and KPIs]]
