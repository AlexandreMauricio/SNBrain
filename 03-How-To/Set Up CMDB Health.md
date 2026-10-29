---
type: how-to
tags: [how-to, cmdb, data-integrity]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB Health > Configuring CMDB Health and its procedures, Create a CMDB remediation rule (read in full through the docs site API 2026-10-29). https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/c_CMDBHealthSetupandConfig.html
sn-release: Brazil
verified:
updated: 2026-10-29
---

# Set Up CMDB Health

**Goal:** get meaningful health scores on the CMDB Health Dashboard.
**Prerequisites:** `sn_cmdb_admin` (or `itil_admin` on top of `itil`); `personalize_dictionary` for mandatory and recommended fields; CMDB Workspace installed.
**Navigation:** All > Configuration > Health Preference; All > Configuration > CI Class Manager

Background: [[CMDB Health]]. Every setting: [[CMDB Health Configuration Reference]].

## Steps

1. **Health Preference > Health Metrics**: switch off KPIs and metrics you will not report; set a **Failure Threshold** per metric; tick **Create Task** and a **Task Assignee Group** where you want tasks.
2. In **CI Class Manager**, per class you care about:
   - **Attributes**: mark truly required fields **Mandatory** (this applies on every form).
   - **Health > Completeness > Recommended Fields**.
   - **Health > Correctness > Orphan Rule** and **Staleness Rule** (default 60 days on `cmdb_ci`).
   - **Health > Health Inclusion Rules** to leave out CIs (e.g. retired) or noisy classes for now.
3. For compliance: activate audits and create compliance-type audits.
4. Check the **System Properties** in Health Preference (owner field, logging).
5. **Health Preference > Scheduled Jobs**: activate the Completeness, Correctness and Compliance score jobs (and the relationship ones only if needed), set **Run** and **Time**, then **Execute Now** once.
6. Optional: **All > Configuration > CMDB Remediations** > **New** to attach a published workflow to failing tasks, Manual or Automatic.

## Result / how to check it worked

The dashboard (**All > Configuration > CMDB Health Dashboard**, Class View) shows scores per KPI and an overall score; `cmdb_health_metric_status` shows Complete for each metric. A CI's **CI Health** tile in the workspace shows green or red per metric.

## Example

Class *Linux Server*: **Mandatory** on *Serial number*, recommended *IP Address* and *OS Version*, staleness 30 days, orphan rule "no relationship of any type to any class", inclusion rule *Operational status = Operational*. Correctness threshold 5,000 with tasks to *Example CMDB Team*. Jobs daily at 02:00. Next morning the dashboard shows the Linux Server tile under Orphan CIs with its count.

## Tables / fields involved

- `cmdb_health_metric_pref`, `cmdb_health_orphan_rule`, `cmdb_health_staleness_rule`, `cmdb_recommended_fields`, `cmdb_health_config`, `cmdb_health_metric_status`

## Gotchas

- Rules that are too broad hit the failure threshold and leave the KPI as "Incomplete score": see [[CMDB Health Scores Missing or Incomplete]].
- A mandatory flag is global, not only for health.
- Scripted audits must record their run time or compliance ignores them.
