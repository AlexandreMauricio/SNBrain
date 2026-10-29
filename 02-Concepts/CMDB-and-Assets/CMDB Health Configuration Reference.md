---
type: reference
tags: [reference, cmdb, data-integrity, admin]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB Health > Configure (KPI and metrics preferences, mandatory, recommended, orphan rule, staleness rule, inclusion rule, aggregation weights, system properties, dashboard jobs) and Reference > Components (read in full through the docs site API 2026-10-29). https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/c_CMDBHealthSetupandConfig.html
sn-release: Brazil
verified:
updated: 2026-10-29
---

# CMDB Health Configuration Reference

**In one line:** every switch, rule, job, property and table behind [[CMDB Health]].

From the Brazil docs. Two places: **All > Configuration > Health Preference** (also *CMDB Health settings* on the dashboard) for metrics, jobs and properties; **CI Class Manager > Health** for per-class rules ([[CI Class Manager]]).

Roles: `sn_cmdb_editor` and `itil` read; `sn_cmdb_admin` or `itil_admin` (on top of those) change rules. Mandatory and recommended also need `personalize_dictionary`.

## Health Preference > Health Metrics

Per KPI: **Active**. Per metric: **Active**, **Failure Threshold** (failing CIs at which the metric stops for the cycle; capped at 100,000), **Create Task**, **Task Assignee Group**. All KPIs and metrics are active in the base system.

## Per-class rules (CI Class Manager)

| Rule | Where | Notes |
|---|---|---|
| Mandatory field | Class Info > Attributes > Added > **Mandatory** = true | global: the field becomes mandatory on every form; does not show correctly with Service Mapping tag-based discovery |
| Recommended fields | Health > Completeness > **Recommended Fields** | a child starts with its parent's list; removing all reverts to the parent's. No dot-walking here; directly in `cmdb_recommended_fields` one level of dot-walk is allowed. Jobs *Add / Remove Identifier Fields In Recommended Rules* add or remove identification rule criterion attributes |
| Orphan rule | Health > Correctness > **Orphan Rule** (`cmdb_health_orphan_rule`) | one per class. **Attributes** (conditions), **Condition** (AND/OR), **Relationship** (relationships the CI must lack; *Any Relation* + *Any Class* = no relationships at all). Example: a disk without *Contains::Contained by* to a computer. Should not equal an inclusion rule's conditions |
| Staleness rule | Health > Correctness > **Staleness Rule** (`cmdb_health_staleness_rule`) | **Applies to**, **Effective Duration** (an entry like "15 x" keeps "15"; fully invalid keeps the previous value). Inherited from the parent class until overridden |
| Health inclusion rule | Health > **Health Inclusion Rules** (`cmdb_health_config`) | **Applies to**, **Active record condition**, **Applies to metric** (required, orphan, recommended, duplicate, staleness). None in the base system = all CIs. A rule on `cmdb_ci` can hide everything. For duplicates: global domain only, no dot-walking. Child-class rules replace the parent's. Use to park noisy classes until fixed |

## Aggregation weights

`cmdb_health_metric_pref`, field **Weighted average contribution** on each metric, KPI and the *Overall* row; metrics of a KPI must total 100, the three KPIs must total 100. **Used only with legacy calculation methods on.** Per domain with Domain Extensions.

## System properties

| Property | Default | Meaning |
|---|---|---|
| `glide.cmdb.health.metricProcessor.maxRunningTime` | 120 | minutes a metric processor runs per cycle before pausing; do not exceed 120 |
| `glide.cmdb.health.ci_ownership_field` | `managed_by_group` | `cmdb_ci` field used as owner in charts |
| `glide.cmdb.logger.use_syslog.CMDBHealth` | error | log levels: `info`, `error`, `warn` comma-separated, or `*` |
| `glide.cmdb.health.src.cmdb_health_audit_only` | false | count only CMDB Health's own results (ignore e.g. Discovery staleness) |
| `glide.cmdb.health.staleness_exclude_dependent_cis` | false | skip dependent CIs in the staleness test |
| `glide.cmdb.services_hierarchy_limit` | 10,000 (0 to 100,000) | service CIs in the service view (add the property) |
| `glide.cmdb.services_query_limit` | 1,000 (1 to 10,000) | application services processed for the service view |
| `glide.cmdb.service_associated_ci_query_limit` | 1,000 (1 to 10,000) | CIs of those services processed |

## Scheduled jobs (inactive by default)

**CMDB Health Dashboard -** *Completeness Score Calculation*, *Compliance Score Calculation*, *Correctness Score Calculation*, *Relationship Score Calculation*, *Relationship Compliance Processor* (only if you need the relationship compliance reports: performance). Plus *Add Identifier Fields In Recommended Rules* and *Remove Identifier Fields In Recommended Rules*. Form: **Active**, **Conditional**, **Run** (periodic or On Demand), **Time zone**, **Run this script** (do not change), **Execute Now**. Role `sn_cmdb_admin` or `admin`.

## Tables

| Table | Content |
|---|---|
| `cmdb_health_metric` | KPI and metric settings (enabled, threshold) |
| `cmdb_health_metric_pref` | preferences and weights (domain separated) |
| `cmdb_health_result` | failures from the latest cycle |
| `cmdb_health_scorecard` | scores: latest *Complete*, older *Historic* |
| `cmdb_health_orphan_rule`, `cmdb_health_staleness_rule`, `cmdb_recommended_fields`, `cmdb_health_config` | rules |
| `cmdb_health_metric_status` | state per KPI and metric: In Progress, Complete, Max Failures, Daily Time Out Pause |
| `cmdb_health_processor_status` | per class progress (Draft, In Progress, Complete) with update times |
| `cmdb_health_result_rel_all` | results for the all-relationship-rules report |

## Related

- [[CMDB Health]] · [[Set Up CMDB Health]] · [[CMDB Health Scores Missing or Incomplete]] · [[CI Class Manager]]
