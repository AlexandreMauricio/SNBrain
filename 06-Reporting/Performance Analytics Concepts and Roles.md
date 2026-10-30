---
type: concept
tags: [concept, reporting, roles, schema, scripting]
status: documented
source: ServiceNow Brazil docs, Platform Analytics guide > Performance Analytics (Indicator data sources) > Explore, Configure fundamentals overview pages, Activating your subscription, Scripting, Real-time scores, Time series, In-form analytics, Reference > Roles, read 2026-10-30. Indicator and breakdown form field pages, formula methods, score forecasts, targets admin pages, Domain separation, Integrations (Analytics Hub, widgets) and external data were listed, not read in detail. https://www.servicenow.com/docs/r/now-intelligence/performance-analytics/pa-overview.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Performance Analytics Concepts and Roles

**In one line:** **Performance Analytics** (PA) takes regular snapshots of process tables and stores scores, so **indicators** (KPIs) show trends, targets and forecasts, whereas table data shows only the current state. It is now the indicator data source of Platform Analytics; its old front end (widgets, Analytics Hub) is replaced by data visualizations and KPI Details, and its admin side sits under **Platform Analytics Administration**.

From the Brazil docs; not tested. **The docs warn:** do not configure PA without training, since a poor design can severely hurt or destabilise the instance. Try **Platform Analytics Solutions** in non-production first.

## Building blocks

| Term | Meaning |
|---|---|
| **Indicator** (KPI) | a data set plus an aggregate such as Count, plus optional conditions, measured at intervals. Types: **automated**, **formula**, **manual**, **external**, and Data snapshots |
| **Indicator source** | one table or database view, conditions, frequency (not a rotated table); frequency must match the indicator. All indicators on a source share the same point in time |
| **Breakdown** and **elements** | qualitative grouping (Priority) and its values (Critical). Automated, manual or external. Maximum **two levels**, except with [[Data Snapshots and Multiple Breakdowns]] |
| **Breakdown source** | which elements exist: records from a table or view, or a bucket group |
| **Breakdown mapping** | links a breakdown to an indicator source through a field or a script (**scripted breakdown**) |
| **Bucket group** | groups values into ranges: `pa_bucket_groups`, `pa_buckets` |
| **Data collector** | job that writes scores and snapshots; see [[Performance Analytics Data Collection]] |
| **Snapshot** | list of sys_ids behind a score, only with *Collect records* on; kept for the indicator and first-level breakdowns, second level by intersection |
| **Time series aggregation** | AVG or SUM over a time formula: Period, Running, To date. A `+` in the name includes partial periods, which can skew averages. Not on business or fiscal calendars |

A PA **day is always 24 hours**: no business days.

## Designing

Design top down: goals > success factors > KPIs. Build bottom up: table > record subsets > as **few indicator sources as possible** (collection queries per source, so fewer is faster and gives one source of truth) > indicators > breakdowns > jobs. Put conditions on the source when shared, on the indicator when specific. Look for existing ones first.

Before creating, ask what you measure, whether more or less is better, what skews it, who owns it, and what you will do if it turns bad.

For a breakdown source on `sys_choice`, condition on Table, Element and Language, and filter out inactive. Always use a facts field with a unique value, usually Sys ID. Only `pa_data_collector` and above create breakdown sources.

## Subscription

Base system: **Complimentary PA for Incident Management**: no adding or deleting indicators, 180 days of history, global domain only. A subscription adds custom content, Data snapshots, longer retention, text analytics widgets and proactive insights. Subscription Management activates it on hosted production instances since Tokyo; on self-hosted and non-production install the *Performance Analytics premium* plugin. Check entitlements at `subscription_entitlement_list.do`.

## Scripting

Server side, in PA scripts (**Platform Analytics Administration > Indicators > Scripts**, `admin` or `pa_admin`) and formula indicators. Each script names one **Facts table** and its **Fields**, and uses column names. A breakdown script returns an element sys_id or a bucket integer; an indicator script returns a value.

- `score_start`, `score_end`: first and last second of the collected period.
- In **scripts** they are `GlideElementGlideObject`: `score_end.getGlideObject().getDayOfWeek()`. Time zone is the job's **Run As** user.
- In **formulas** they are already `GlideDateTime`: `score_end.getDayOfWeek()`. Time zone is the **viewer's**, so dates can differ per viewer.
- `pa`: formula only, Analytics Hub attributes and methods.
- Database view fields need the prefix: `taskslatable_business_duration` in `incident_sla`.

Avoid GlideRecord and GlideAggregate in these scripts; limit dot-walks, as each adds a join; prefer reporting fields and script includes. Background scripts reading scores for a scoped application need that application's role.

## Other parts

- **KPI Composer** (Store application): designs goals, success factors and KPIs as a tree, then generates tasks. **Being prepared for future deprecation.**
- **Spotlight** (needs its plugin): ranks records by weighted criteria, not one field, so low priority items that linger surface. A **group** defines records and a threshold, **criteria** add weights; records over the threshold get a Spotlight. Scheduled jobs score them; results appear in interactive analysis or a List on a dashboard through `spotlight`. Share by URL to `pa_spotlight_viewer`.
- **Diagnostics** (**Platform Analytics Administration > Troubleshooting > Diagnostics**, `sn_pa_diagnostics.pa_diagnostic`): read-only checks, stop after 2 minutes. They do not know about Platform Analytics artifacts, so a *not used* result may be wrong.
- **External indicators**: SQL over a JDBC data source (MySQL 3306, SQL Server 1433, Oracle 1521); only scores are stored. Separate from Workflow Data Fabric tables.
- **Scores tables**: `pa_scores` split into `pa_scores_l1` and `pa_scores_l2` in Istanbul; older instances migrate (KB1294371; monitor under **Indicator Settings > Scores Migration Monitor**).
- **Domain separation** (Enhanced; needs the Domain Extension Installer): **Global** records with domain-aware collection (used by Solutions, usually best), **Domain-specific**, or **Hybrid**. Many domains can slow retrieval.

## Real-time scores

Automated indicator, configured for it, no scripted aggregate, no database view source, no scripted breakdowns. Come directly from facts tables, so ACLs make them differ per viewer.

## In-form analytics

A UI action opens a breakdown dashboard from a form field. **Core UI responsive dashboards only**, and not available on net new instances.

## Roles

**`pa_admin` and `pa_data_collector` are equivalent to `admin` from a security view.**

| Role | Can | Contained by |
|---|---|---|
| `pa_viewer` | formerly needed for the Hub, may be needed on upgrade | all except `pa_contributor` |
| `pa_contributor` | scoresheets for indicators where they are Contributor | `pa_power_user`, `pa_admin` |
| `pa_target_admin` | all targets | `pa_power_user`, `pa_admin` |
| `pa_threshold_admin` | global and all thresholds | `pa_power_user`, `pa_admin` |
| `pa_analyst` | text analytics words | `pa_power_user`, `pa_admin` |
| `pa_kpi_signal_admin` | dismiss signals, reset baselines | `admin` |
| `sn_pa_diagnostics.pa_diagnostic` | run diagnostics | `pa_admin` |
| `pa_power_user` | indicators, breakdowns, widgets, bucket groups, groups; contains `viz_admin` and the above | `pa_admin` |
| `pa_data_collector` | jobs, sources, units, scripts, bucket groups, Data snapshots on or off | `pa_admin` |
| `pa_admin` | Admin Console, Dependency Assessment, properties read | `admin` |
| `pa_spotlight`, `pa_spotlight_viewer`, `pa_spotlight_copy_breakdown`, `pa_spotlight_copy_domain` | Spotlight | |

The action table writes `pa_target_administrator` and `pa_threshold_administrator`: unconfirmed variants of the names above.

## Example

Indicator source *Example Open Incidents Daily* on `incident`, condition *Active is true*, daily; automated indicator *Example Open Count* with Count; breakdown *Example Priority* on `sys_choice` with a field mapping to `priority`.

## Related

- [[Performance Analytics Data Collection]] · [[KPI Details and KPI Signals]] · [[Platform Analytics Roles, Caching and Library Recommendations]] · [[ITSM Platform Analytics Dashboards and KPIs]] · [[Benchmarks]]
