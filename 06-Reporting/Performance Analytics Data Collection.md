---
type: concept
tags: [concept, reporting, instance-admin, troubleshooting]
status: documented
source: ServiceNow Brazil docs, Platform Analytics guide > Performance Analytics > Collecting indicator scores, Data collection (optimized collector, logs), Reference > Properties, read 2026-10-30. Job form field page and per-step log tables listed, not read in detail. https://www.servicenow.com/docs/r/now-intelligence/performance-analytics/c_ClctData.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Performance Analytics Data Collection

**In one line:** data collection jobs (**All > Platform Analytics Administration > Data Collector > Jobs**) query indicator sources on a schedule and write scores and snapshots; without active jobs, indicators stay empty.

From the Brazil docs; not tested. Roles: `pa_data_collector` or higher. See [[Performance Analytics Concepts and Roles]].

## Choosing a method

- Measures once a month, quarter or year: manual entry or import.
- More often, or no human involved: scheduled job. Match the schedule to the source frequency. One job usually serves several indicators of a source.
- New indicators on existing data: one **historical** job.

## Historical jobs

Set **Run** to **On demand**, never a schedule, then **Execute Now**. **It deletes earlier data** for the periods and indicators it covers, so avoid running it twice; for a new indicator use a new job rather than extending one. Exclude breakdowns on fields that change over the period (Assignment Group, State), or results mean nothing. Afterwards a scheduled job keeps scores coming.

## Optimized collector

Default since Tokyo. Moves score packets to an embedded on-disk database and writes at the end. Handles over 10 million records, at least 10 breakdowns with matrix, two large breakdowns up to 1 million. Not for Oracle or instances still on `pa_scores`; needs `pa_scores_l1` and `pa_scores_l2`. Disable by creating `com.snc.pa.dc.hsql` = false. Lazy loading can increase CPU.

## Logs

**Data Collector > Job Events** (what ran and fired), **Job Logs** (state Collecting, Collected, Collected with errors), and log details per step. Admin Console has daily to monthly overviews.

## Limits

Optimized jobs use the `hsql` properties, classic jobs the others. Raising them can hurt performance. Limits apply per source, so 12 indicators on 3 sources allow three times the value.

| Property | Meaning | Default |
|---|---|---|
| `com.snc.pa.dc.hsql.max_row_count_indicator_source` | records per indicator source, optimized; over it, nothing is collected for that source | 1,000,000 |
| `com.snc.pa.dc.max_row_count_indicator_source` | same, classic; overridable per source | 50,000 |
| `com.snc.pa.dc.hsql.max_breakdown_elements_limit` | elements per breakdown source, optimized | -1 (no limit) |
| `com.snc.pa.dc.max_breakdown_elements_limit` | same, classic; with nested collection only non-null scores count | 10,000 |
| `com.snc.pa.dc.hsql.max_breakdown_elements_level2_limit` | matrix of two, optimized | no limit |
| `com.snc.pa.dc.max_breakdown_elements_level2_limit` | matrix of two, classic | 1 million per example |
| `com.snc.pa.dc.script_timeout` | seconds per script; over it the record is skipped | 30 |
| `com.snc.pa.dc.query_time_limit` | minutes before a warning | 60 |
| `com.snc.pa.dc.max_error_count` | errors before a job stops | 500 |
| `com.snc.pa.dc.max_records` | sys_ids stored in one `pa_snapshots` row; excess is dropped | 5000 |

## Retention

Set under **Platform Analytics Administration > Properties > PA Properties**. Eleven values in order: daily; weekly; bi-weekly; four-weekly; monthly; bi-monthly; quarterly; fiscal quarterly; half-yearly; yearly; fiscal yearly (the first of these names is inferred; only the second half of the list was visible). Nothing older is collected. The summary page writes `com.snc.pa.dc.keep_snapshots_for` without the suffix.

| Property | Default |
|---|---|
| `com.snc.pa.dc.keep_scores_for.frequency` | 732;105;53;40;60;30;20;20;20;10;10 |
| `com.snc.pa.dc.keep_snapshots_for.frequency` | 183;26;13;10;15;8;5;5;5;3;3 |

## Display limits

| Property | Meaning | Default |
|---|---|---|
| `com.snc.pa.breakdown_element_cutoff` | above this, only elements with a score or change on the date show | 50 |
| `com.snc.pa.scorecards.max_breakdown_elements` | elements in Hub lists | maximum 10,000 |
| `com.snc.pa.scorecard.breakdown.chart.max_rows` | elements in visualizations | 10 |
| `com.snc.pa.scoresheet.max_elements` | elements in a scoresheet | 500 |
| `com.snc.pa.scorecard.max_record_num` | records auto-loaded on the Hub | 50,000 |
| `com.snc.pa.thresholds.frequency_intervals_in_the_past_limit` | intervals a threshold job checks | 2 |
| `com.snc.pa.widget.max_widget_indicators` | indicators in a widget beyond the main | 7 |
| `com.snc.pa.widgets.respect_acl` | widgets follow indicator and breakdown ACLs | true on new; false on upgrades from before Quebec |
| `com.snc.pa.fy_start` | fiscal year start month | 1 |

To hide null elements for automated indicators set the cutoff to 0 or 1; they can still appear for real-time scores and formulas. Colour properties are listed in [[KPI Details and KPI Signals]]; defaults there include `com.snc.pa.default_chart_target_color`, which the KPI page spells `defaut`: unconfirmed variants.

## Example

Job *Example Incident Daily*, **Run** daily at 01:00, covering indicators on *Example Open Incidents Daily*. Before it starts, run *Example Incident Historic* **On demand** once for 90 days, with the Assignment Group breakdown excluded.

## Related

- [[Performance Analytics Concepts and Roles]] · [[Data Snapshots and Multiple Breakdowns]] · [[Proactive Analytics Insights on Dashboards]]
