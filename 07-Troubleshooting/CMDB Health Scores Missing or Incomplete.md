---
type: troubleshooting
tags: [troubleshooting, cmdb, data-integrity]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB Health > CMDB Health process tracking and troubleshooting, failure threshold reached, incomplete score (read in full through the docs site API 2026-10-29). https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/c_CMDBHealthTroubleshooting.html
sn-release: Brazil
verified:
updated: 2026-10-29
---

# CMDB Health Scores Missing or Incomplete

**In one line:** where to look when the CMDB Health Dashboard shows nothing, 0 %, "failure threshold reached" or "Incomplete score".

From the Brazil docs. Background: [[CMDB Health]], [[CMDB Health Configuration Reference]].

| Symptom | Cause | Fix |
|---|---|---|
| No data at all | dashboard jobs inactive (default) | activate the *CMDB Health Dashboard -* score jobs; **Execute Now** ([[Set Up CMDB Health]]) |
| Jobs active, still no data | metric still processing, paused or aborted | check `cmdb_health_metric_status`: In Progress, Complete, **Max Failures** (aborted, restarts next run), **Daily Time Out Pause** (resumes next run) |
| "failure threshold reached", warning icon, 0 % | failing CIs reached the metric's **Failure Threshold** | narrow the rule: fewer mandatory or recommended fields, gentler orphan rule, longer staleness duration, fewer audit failures, work the de-duplication tasks. KB2487349 |
| "Incomplete score" on a KPI | a sub-metric hit its threshold, or errored | threshold: as above. Error: read the system log (source *CmdbHealth*), fix, run the KPI's job manually |
| A metric times out every day | one class takes too long | `cmdb_health_processor_status`: compare update times per class (Draft = not yet processed); weak rules are the usual cause. `glide.cmdb.health.metricProcessor.maxRunningTime` (120 min) is the per-cycle limit |
| Orphan CI you cannot open or delete; list count differs from total | a CI row was deleted from only some tables of its hierarchy, so GlideRecord cannot reach it | the orphan result names the missing table (e.g. "missing record in cmdb_ci_computer"); the sys_id must be removed from every table of the chain. Needs **Support** |
| Compliance ignores a scripted audit; error logged | the audit script does not set **Last run date** | update the script to record its run time |
| Stale count includes CIs no rule flags | Discovery marked vCenter CIs stale (source *Cloud Discovery*) | `glide.cmdb.health.src.cmdb_health_audit_only` = true to exclude them from the score |
| CI Health tile shows "not applicable" or "missing rule" | no identification, orphan or staleness rule or audit for the class or ancestors, or excluded by an inclusion rule | add the rule, or accept |

Logging: `glide.cmdb.logger.use_syslog.CMDBHealth` (default `error`; add `info,warn` for start and end of each cycle).

Duplicate and orphan relationships: KB0780988 explains finding and deleting them.

## Related

- [[CMDB Health]] · [[CMDB Health Configuration Reference]] · [[Set Up CMDB Health]] · [[Scripted Compliance Audits]]
