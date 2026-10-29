---
type: concept
tags: [concept, cmdb, data-integrity, reporting]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CSDM and CMDB Data Foundations Dashboards (4 topics, 410 cleaned lines, read in full through the docs site API 2026-10-29) - Monitor health, CMDB Data Foundations dashboard, CSDM Data Foundations dashboard, scheduled jobs. The CSDM stage reports (Foundation to Fly) are separate pages not in this chapter. https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/csdm-cmdb-foundations-dashboards.html
sn-release: Brazil
verified:
updated: 2026-10-29
---

# CMDB and CSDM Data Foundations Dashboards

**In one line:** a store app (plugin `com.snc.cmdb.getwell`, active by default) with two dashboards that score how well the CMDB and CSDM are set up against ServiceNow's benchmarks, each metric with a priority, a percentage and a link to a remediation playbook article.

From the Brazil docs. Complements [[CMDB Health]] (which tests individual CIs); these check configuration and practice. **No domain separation support.**

Access: **All > Configuration > CMDB Data Foundations Dashboard** or **CSDM Data Foundations Dashboard**; or [[CMDB Workspace]] > Management > Optimize. A *change dashboard* icon switches between them. CMDB dashboard roles: `sn_cmdb_admin`, `admin`, `itil_admin` or `asset` (drill-downs into Performance Analytics may need more, e.g. `itil` or `sn_incident_read`).

## How it collects

| Job | Does |
|---|---|
| *CMDB Get Well Metric Collection* | daily; computes metric scores into `sn_getwell_cmdb_score` and the compliant-CI lists. Nothing shows before its first run |
| *CMDB Data Foundations PA Metric Collection* | daily; Performance Analytics totals of non-compliant CIs and trends (the drill-down tiles) |
| *CMDB Get Well CIs Processed Via IRE Metric Batch Collection* | started daily by the first job; runs 10 minutes on, 1 minute off, in batches of 1,000 CIs |
| *CSDM Data Foundations PA Metric Collection* and one *CMDB DF Collection - ...* / *CSDM DF Collection - ...* job per indicator | per-indicator PA collection |

Drill-down: select a tile to open Analytics Hub; with **Real-time** on, **Show Records** lists the CIs.

## Metric list columns

**Name**, **Priority** (1 Critical to 5 Low, from the metric's weight and how bad the score is), **Result** (% compliant; some metrics show 0 when below a lower threshold), **Remediation playbook URL** (Now Support article).

## CMDB dashboard metrics

| Tab | Metric | Measures (compliant = ...) |
|---|---|---|
| **Best Practices** | Create Asset Business Rule is Enabled | business rule *Create Asset on insert* exists (100 or 0) |
| | Custom CMDB Attributes at the Right Level | custom attributes that could live higher in the hierarchy; (10 − count) × 10, 0 above 10 |
| | Hardware CIs with Serial Numbers | installed, operational Computer or Network Gear with a serial number; 0 below 70 % |
| | Services with Owners | operational `cmdb_ci_service` with `owned_by` |
| **Customizations** | Base System Business Application Table Usage | no custom table extending `cmdb_ci` named `u_`/`x_` containing "bus" and "app" |
| | Base System CMDB Relationship Types Usage | custom relationship types (`cmdb_rel_type`, package global, excluding *Manages::Managed by*); (10 − count) × 10 |
| | Base System Relationship Types Not Deleted or Recreated | same formula on deleted or recreated shipped types |
| | Custom CMDB Tables Using Standard Naming | custom CMDB tables starting `u_` but not `u_cmdb_ci`; 0 above 6 |
| | Use of Custom Attributes | `u_` columns on `cmdb_ci*` tables: 100 under 10, 0 over 50 |
| **Data Management Practices** | Active CIs Updated in Last 90 days | installed, operational hardware and VM instances updated in 90 days; 0 below 65 % |
| | CIs Processed via IRE | same set with a row in `sys_object_source` ([[Identification and Reconciliation Engine (IRE) Overview]]); PA view needs `sn_cmdb_admin`, `admin` or `discovery_admin`, no Show Records |
| | CIs with Names | hardware, VM instances, applications without a name; 0 above 200 |
| | CIs with Relationships to Parent and Child | `cmdb_rel_ci` rows whose parent or child class is empty count as orphans |
| | Handled Duplicate CIs | hardware and VMs with `duplicate_of` set and not remediated; 0 above 200 ([[Duplicate CI Remediation]]) |
| | Installed Server CI Naming Reflecting Hostname | installed servers whose name matches the host name up to the first dot |
| | Managed CIs with Model Entries | hardware with `model_id` |
| | Servers with Location | installed, operational servers with a location |
| | Unique Locations | `cmn_location` names used only once |
| **ITSM Processes** | Changes Referencing a CI | changes of the last 90 days with `cmdb_ci` |
| | Changes Relating to both a Service and a CI | changes with `cmdb_ci` and `business_service` |
| | Incidents Referencing a CI | incidents of the last 60 days with `cmdb_ci` |
| | Incidents Relating to both a Service and a CI | incidents of the last 60 days with both |

The docs' formula for CIs with Names is printed with misplaced brackets; read it as (200 − count) / 200 × 100. To refresh the hostname widget by hand, run the Get Well collection first, then the PA collection.

## CSDM dashboard

Tabs follow the CSDM maturity stages: **Foundation**, **Crawl**, **Walk**, **Run**, **Fly** (CSDM (chapter not read yet; see [[Service Catalog and CSDM]])). Indicators collected include: application services missing or with incorrect business application relationships, missing business service offerings, business applications without an application service, business units without companies, CIs whose operational status and life cycle stage disagree, custom service tables, dynamic CI groups without a CMDB group, information objects (and those without a business application), locations without parent, product models without owner, technical service offerings (without support or change group, without a technical service).

## Performance

All metrics live in **CMDB/CSDM Get Well Metrics** (`sn_getwell_metric`):
- **Active** = false stops a metric (kept across upgrades).
- **Aggregate limit**: maximum non-compliant CIs counted; reaching it sets the score to 0 (not customisable).
- **Runtime threshold** (seconds) and **Fail count threshold**: after that many consecutive over-time runs, the metric deactivates itself; set Active again to resume.
- Tunable metrics: CIs Processed via IRE (fail count 3, runtime 72,000 s daily total of its batch runs, no automatic 0), CIs with Relationships to Parent and Child (limit 1,000, 3, 3,600), Hardware CIs with Serial Numbers (30 %, 3, 3,600), and three CSDM application service / business application metrics.

## Related

- [[CMDB Health]] · [[CMDB Workspace Insights and SGC Central]] · CSDM (chapter not read yet; see [[Service Catalog and CSDM]]) · [[CMDB Coverage]]
