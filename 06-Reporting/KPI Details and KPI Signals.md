---
type: concept
tags: [concept, reporting, schema, roles, api]
status: documented
source: ServiceNow Brazil docs, Platform Analytics guide > Platform Analytics experience > Indicator library, KPI Details, KPI Signals, read 2026-10-30. Procedure pages for time aggregation, breakdown filtering, Data snapshots display and creating or bulk editing targets were listed, not read in detail. https://www.servicenow.com/docs/r/now-intelligence/kpi-details.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# KPI Details and KPI Signals

**In one line:** **KPI Details** is the exploration page for one Performance Analytics indicator (trend, forecast, breakdowns, records, targets); **KPI Signals** applies statistical Process Behavior Charts to it and tells responsible users when a process changes significantly.

From the Brazil docs; not tested. Indicators themselves are covered with the Performance Analytics chapter of this guide.

## Indicator library

**Platform Analytics > Library > Indicators** shows indicators with **Show in library** on (Access Control tab) that you can reach, opening each in KPI Details. `pa_power_user`, `pa_data_collector` or higher also see health tiles, the source and job state columns, **Create indicator** (Automated, Formula, Manual, External; `pa_power_user`), delete and edit. Admins see Data snapshots eligibility and **Enable Data Snapshots**.

## KPI Details

Open from the library or a point on a visualization. Role: none, though upgraded instances may need `pa_viewer`.

- **Header**: score on a date, change, target and gap. **Real-time scores** come straight from the facts tables, so ACLs make them differ per viewer and from collected scores.
- **Chart**: date range, time aggregation (AVG or SUM over a period), **Show records**. With second-level breakdowns the score and record count can disagree: the score is right (KB0748969). No records for the *Unmatched* element.
- **Chart options** (saved per user and indicator): targets, thresholds, forecast, trend, comments, labels, statistics (count, max, min, sum, average, median, change, sample standard deviation).
- **Sidebar**: breakdown and element filter, KPI Signals, targets and thresholds.
- **Run process analysis** launches Process Mining. **More actions** opens the indicator record or scoresheet.
- Abbreviation: 10,000 and above shows K, then M, then G.

Data snapshots indicators support only part of this: native ones get targets, thresholds and labels in the chart options, and no KPI Signals.

### Targets and thresholds

| | Target | Threshold |
|---|---|---|
| Purpose | a goal for a date | normal range; firing sends an email |
| Personal | yours only, KPI Details only, light line | light grey dotted line |
| Global | everyone; also time series and single score | everyone; also time series |

A target applies from its start date until the next one. Before the review date the card shows On track, Off track or Too early to track, based on the forecast on that date; afterwards Met or Not met. The header gap uses the selected date, while the card gap uses the forecast on the review date, so the two can differ.

**Target responsibility** (classic indicators, global targets only): a target admin such as `pa_target_admin` creates the first target, then `pa_admin`, `pa_target_admin`, `pa_power_user` or `admin` assign users, not groups, on the **Responsibility** tab; those users can then maintain it with any role, and pass it on. Assign only in KPI Details. Independent of signal responsibility.

### UUIDs

Each combination is one UUID, and targets, thresholds and signals work per UUID:

```
<indicator_sys_id>:<breakdown_sys_id>:<elements_filter_sys_id or element_sys_ids>:<lvl-2 breakdown_sys_id>:<lvl-2 elements>:<aggregate_sys_id>;<domain_sys_id>
```

Only the indicator is required, but a breakdown needs at least one element; `unmatched` replaces an element sys_id for scores matching none. Note the semicolon before the domain. A breakdown with no element goes in a separate parameter of `GET /now/pa/scorecards`.

### Properties

`com.snc.pa.indicator_target_default_color_schema`, `com.snc.pa.chart_default_color_schema`, `com.snc.pa.scorecards.max_breakdown_elements`, `com.snc.pa.target_batch_operation_limit` (default 100; lower it on bulk timeouts), `com.snc.pa.default_chart_line_color`, `com.snc.pa.defaut_chart_target_color` (spelled so on the page), `com.snc.pa.default_chart_personal_target_color`, `com.snc.pa.default_chart_threshold_color`, `com.snc.pa.default_chart_personal_threshold_color`.

## KPI Signals

Uses 3-sigma limits; at least five scores for the baseline. A daily indicator takes 14 scores by default. Monitoring is off per indicator until activated. It covers the indicator or one first-level breakdown element, not several elements or second-level breakdowns, and not Data snapshots.

| Result | Meaning |
|---|---|
| Outlier | a score beyond 3 sigma |
| Short run | 4 consecutive on one side, 3 of them beyond 2 sigma |
| Long run | 7 consecutive on one side (outliers count, dismissed or not) |
| Anti-signal | no signal for baseline length × anti-signal factor (default 2, so 28 days daily); stable, no action, cannot be reverted |
| No signal | nothing to report |

### Set up

1. KPI Details > filter one breakdown and element, if wanted > **Open KPI Signals**.
2. **Make me responsible** (`pa_kpi_signal_admin`, `pa_admin` or `admin`; at least one responsible user is required). Start date defaults to three months before activation.
3. Cogwheel tabs: **Signal Detection** (Active, Baseline start, number of scores, trend method Linear or No trend), **Responsibility**, **Notifications** (reminder interval, maximum reminders, anti-signal factor).
4. **Add breakdowns** monitors several elements of an indicator.

If the linear trend keeps signalling while the average is stable, try **No trend**. Reactivating monitoring resumes from the deactivation date.

### Respond

Responsible users get email even without workspace access. Temporary change: fix it and **Dismiss signal**. Lasting change: **Reset baseline** (from the first signal date by default). Both require **What has changed?**. **Past** tab > **Revert** also reverts all later decisions. Allowed: responsible user, or `admin`, `pa_admin`, `pa_kpi_signal_admin`.

**Unconfirmed variants of the role name:** `pa_kpi_signal_admin` and `pc_kpi_signals_admin` on the roles page.

### Jobs and disabling

Signals are checked when the panel opens, and when a data collection job runs for automated indicators. Formula indicators use job *PA - KPI Signals - Formula Indicator Signals Calculation Job*, every 8 hours by default; set it after your collection jobs if lag matters. Disable the feature by creating `com.snc.pa.activate_kpi_signals` = false; re-enabling resumes from the disable time.

## Example

Indicator *Example Open Incidents* filtered on *Priority = 1 - Critical*: *Test User* activates signals, gets a long run signal after a process change, resets the baseline with the note *New triage rota (example)*, and sets a global target of 20 with a review date.

## Related

- [[Proactive Analytics Insights on Dashboards]] · [[Platform Analytics Data Visualizations]] · [[Platform Analytics Roles, Caching and Library Recommendations]]
