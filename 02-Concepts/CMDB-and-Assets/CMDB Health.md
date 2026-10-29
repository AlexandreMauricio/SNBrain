---
type: concept
tags: [concept, cmdb, data-integrity, reporting, domain-separation]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB Health (26 topics, 1,307 cleaned lines, read in full through the docs site API 2026-10-29) - landing, Explore, Overview, KPIs and metrics, Configure (8 topics), workspace experience, Dashboard, relationships health, CI health, remediation rules and applying them, tracking and troubleshooting, Reference (domain separation, components). https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/overview-cmdb-health.html; also View CMDB benchmarks (https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/view-cmdb-benchmarks.html), read 2026-10-29
sn-release: Brazil
verified:
updated: 2026-10-29
---

# CMDB Health

**In one line:** scheduled jobs test every CI for completeness (required and recommended fields), correctness (orphan, stale, duplicate) and compliance (audits), plus relationship health, and roll the results into scores per class, health group and service on the CMDB Health Dashboard; failing CIs can get tasks and remediation workflows.

From the Brazil docs. Part of `com.snc.cmdb`. Setup: [[Set Up CMDB Health]]. Settings and tables: [[CMDB Health Configuration Reference]]. When scores are missing: [[CMDB Health Scores Missing or Incomplete]]. Non-CMDB tables are not supported.

**Nothing is collected until the CMDB Health Dashboard jobs are enabled** (they ship inactive).

## KPIs and metrics

| KPI | Metric | A CI fails when |
|---|---|---|
| **Completeness** | Required | a field mandatory in the dictionary is empty |
| | Recommended | a recommended field is empty (none recommended out of the box) |
| **Correctness** | Orphan | it matches the class's orphan rule (attribute conditions and/or missing relationships), or a record is missing in one of its tables of the hierarchy |
| | Staleness | not updated (`sys_updated_on`) within the class's staleness rule **Effective Duration**; base rule on `cmdb_ci` = 60 days, inherited until a class overrides it. Discovery marking vCenter CIs stale also counts (source *Cloud Discovery*) unless `glide.cmdb.health.src.cmdb_health_audit_only` = true |
| | Duplicate | the identification rules ([[IRE Identification Rules]]) find duplicates; independent CIs only; a set of n counts n−1. Identification inclusion rules also affect it (KB0726425) |
| **Compliance** | Audit | it fails any compliance-type audit in the most recent complete audit run (by **Last run date**). Audit must be activated. Scripted audits do not set Last run date: make the script record it or the results are skipped ([[Scripted Compliance Audits]], [[CMDB Compliance - Desired State, Architecture Compliance and Audits]]) |
| **Relationships** (not configurable) | Duplicate, orphan, stale relationships | same parent, child, type (and port); missing parent or child; a stale CI at either end. One relationship can fail several |

Relationship compliance reports also count relationships not matching suggested relationships, containment rules or hosting rules ([[CMDB Dependent Relationship Rules - Hosting and Containment]]). A relationship is tested only if a rule exists for its parent and child classes (ancestors count); no rule = compliant; with several rules, matching one is enough.

## Scores

- A KPI tile is a donut: green = CIs passing all the KPI's metrics, red = failing at least one. Hover, the "i" icon for calculation details, select a metric tab for the ten worst classes (with pies by discovery source and by owner), drill to CIs.
- **Overall score** = simple average of the three KPIs. With **Use legacy calculation methods** on (`sn_cmdb_admin`; how it worked until Washington DC) weights apply instead, e.g. Required 60 % / Recommended 40 % inside Completeness.
- "x % since date" shows change; a warning icon means the metric hit its **failure threshold**: processing stopped for that cycle and the scores show 0 %.

## Where to look

| View | Access | Content |
|---|---|---|
| **CMDB Health Dashboard** | CMDB Workspace > Home > Quick links; Service Graph Workspace > Insights > CMDB Health; **All > Configuration > CMDB Health Dashboard** | **Class View** (default; pick a class to filter), **Health Group View** (CMDB groups of type Health, [[CMDB Groups]]), **Service View** (needs Event Management and Service Mapping Core; only `cmdb_ci_service_auto` and children) |
| **Relationship Health Dashboard** | CMDB Workspace Quick links | donuts by relationship type; drill to non-compliant relationships (the *Failure Description* names only one failed rule). Needs the *Relationship Compliance Processor* job, which can hurt performance |
| **CI Health** tile on the CI form | workspace CI form, or *Open in Workspace* ([[CI Form in CMDB Workspace]]) | green pass, red fail, grey not tested; "not applicable" or "missing rule" notices when no identification, orphan or staleness rule or audit applies |

Roles: dashboard `asset`, `sn_cmdb_editor`, `cmdb_user` or `itil`; relationship dashboard `sn_cmdb_editor`, `asset` or `itil`; CI health `sn_cmdb_user`. From CMDB Workspace 7.0 the workspace is required for these views.

Completeness and correctness on the CI tile are always current; compliance depends on audit runs and the compliance job (use **Execute Now**).

## Tasks and remediation

- Per metric, **Create Task** opens a task for each failing CI, assigned to **Task Assignee Group**. Not for duplicates (use de-duplication tasks, [[Duplicate CI Remediation]]) or audits (use the audit tasks; a CI can have several, the rest in **Additional Tasks**).
- **CMDB remediation rules** (**All > Configuration > CMDB Remediations**; `sn_cmdb_admin` or `itil_admin`): **Name**, **Task type**, **Task filter** (dot-walk to CI fields), **Execution** Manual or Automatic, **Active**, **Workflow**. The workflow is a published classic or Orchestration workflow (`wf_workflow`) on the same table as the task type, with *If condition matches* = None. Automatic runs once when a matching task is created (business rule *Run remediations for CMDBHealth task*).
- Manual: dashboard (Class view) > KPI > metric tab > class > the CI's **Task** link > **Remediate** > pick a workflow > **Next**.

## Benchmarks

**Benchmarks > Dashboard** > IT Operations Management > ALL or CMDB shows three CMDB benchmarks: **% of non-compliant CIs**, **% of duplicate CIs**, **% of stale CIs**, as monthly averages with trends, compared with the average of peer instances. Needs the health jobs running and the CMDB KPIs enabled under **Benchmarks > Setup** (IT Operations Management). A day without a job run takes the most recent result; with several runs in a day only the last counts; the global average skips instances whose average is 0. (Chapter *View CMDB benchmarks*, read 2026-10-29.)

## Domain separation

Domain aware (with Domain Support - Domain Extensions):
- Jobs and system properties are **not** domain separated: one job run covers all active domains. With many domains (over 100) jobs run long; deactivate root domains you do not need in Health Preferences.
- Metric preferences (active, threshold, task) are per domain (`cmdb_health_metric_pref`), except relationship metrics' threshold, which always uses global.
- Domain separated: recommended fields, orphan rules, staleness rules, inclusion rules (`cmdb_health_config`), audits. Not: required fields (dictionary) and duplicates (identification rules).
- Since Tokyo, global CIs are tested only by global tests, subdomain tests only test subdomain CIs. A child domain inherits its parent's settings unless it overrides them.
- The dashboard follows domain mapping visibility for the logged-in domain, not extra visibility granted to the user.

## Related

- [[Set Up CMDB Health]] · [[CMDB Health Configuration Reference]] · [[CMDB Health Scores Missing or Incomplete]] · [[CMDB Workspace Insights and SGC Central]] · [[CI Class Manager]] · [[CMDB Data Manager]]
