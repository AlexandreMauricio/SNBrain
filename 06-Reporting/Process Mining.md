---
type: concept
tags: [concept, reporting, ai, roles, schema, release-specific]
status: documented
source: ServiceNow Brazil docs, Platform Analytics guide > Process Mining (landing, Explore, Architecture, Key features, Evaluation projects, Activate, content packs intro, Workspace list project, Agentic AI project, Playbook project, multi-dimensional mining, Mine a project, Cluster analysis intro, Reference: components, roles, properties, key terms, domain separation), read 2026-10-30. About 150 of 205 topics (workbench details, finding definitions, Project Builder steps, each content pack, external data, Salesforce and Workday use) listed, not read. https://www.servicenow.com/docs/r/now-intelligence/process-mining/process-mining.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Process Mining

**In one line:** **Process Mining** rebuilds how a process really ran from the **audit log**, as a map of activities, connections and routes, to find bottlenecks, rework and deviations.

From the Brazil docs; not tested. Formerly Process Optimization, so names mix both.

## How it works

The mining engine extracts audit history according to project settings and sends a file to a central **training server**, so the instance carries no load; the finished project returns through APIs and the server deletes its data (KB1584480). See [[Task Mining]] for desktop-level detail.

**Tables must be audited.** On a clone, clear **Exclude audit and log data**, or the map will be thin.

| Term | Meaning |
|---|---|
| **Project** | configured process model |
| **Activity** | a step: a tracked change in the audit log |
| **Connection** | line between two activities |
| **Route** | one distinct sequence of steps; many records can share it |
| **Breakdown** | category filter; at least one is required with one activity |
| **Finding** | discovered insight; **improvement opportunity** in the UI |
| **Attribute of interest** | hidden from the map, usable in finding rules |
| **Linked process** | connected subprocess |

## Access

Base platform: **sample mining** only. **Full mining needs a licence.**

**Evaluation projects** need no licence: Incident, CSM, HR, Security Incident; limited to 7 days and 3,600 records. Incident and CSM pre-mine monthly on production; HR and Security mine on demand, scoped to your access. Admins may add filters. Turn off with `promin.feature.enable_evaluation`.

**Content packs:** from Brazil the ITSM, CSM, HR Service Delivery, SPM, Security Incident Response and Field Service Management packs **load automatically**; others are activated manually.

Add-ons: *Process Mining for External data* (`sn_po_extdata`), *for Salesforce* (`sn_promin_sf`, needs the Salesforce Spoke), *for Workday* (ID given as `sn_workday_hr_spke`, the same as its spoke: unconfirmed).

## Projects

Open **Process Mining > Process Mining Workspace**. Created by Project Builder (guided), Classic view, a template, or **Launch Process Mining** on an audited workspace list (filters carry over).

- **Multi-dimensional mining:** add a child table such as Incident Task (`incident_task`) with a Reference or Child relationship; only created and closed events show.
- **Agentic AI project:** mines execution plans (`sn.aia.viewer`, `sn.aia.admin`); no touchpoint or idle metrics, root cause, work notes analysis, clustering or Task Mining.
- **Playbook project:** one playbook at a time, variants compared, basic analysis, no improvement opportunities.

**Limits:** full mine up to **500,000 records per table**, divided across configured tables (two tables gives 250,000). Sample up to 3,600. 50 jobs per day by default. Mining locks the map. Clustering needs 100 to 300,000 records.

Features: Summary and insights, Analyst workbench, bottleneck analysis, process step filters, compare projects, ML clustering, Performance Analytics launch (`promin.pa_integration_required_roles`), [[KPI Details and KPI Signals]], Continual Improvement Management, Benchmarks, [[Digital Portfolio Management]] and Automation Center. Retirement: default 90 days; a retired project can be remined directly.

## Roles

| Role | Can |
|---|---|
| `sn_process_mining_admin` | all projects, settings, jobs; contains power user |
| `sn_process_mining_power_user` | all projects and settings, jobs; contains analyst |
| `sn_process_mining_analyst` | create and share projects; only shared ones visible |

**Unconfirmed variants:** older names survive: *Mine a project* requires `po_analyst`, and the dashboard page uses `sn_process_optimization_analyst` ([[Platform Analytics Roles, Caching and Library Recommendations]]). Plugin is written `sn_po` and `com.sn_po`. Clustering definitions need `admin` or `ml_admin`.

Domain separation: **Basic**.

## Tables and properties

Tables use `promin_*`: `promin_activity_def`, `promin_breakdown_field`, `promin_finding`, `promin_finding_def`, `promin_process_def`, `promin_model_def_version`, `promin_permission`, `promin_job`, `promin_case_data`, `promin_arc`, `promin_node`, `promin_route`. Solutions: `ml_capability_definition_promin`.

| Property | Meaning | Default |
|---|---|---|
| `promin.limit.node_def` | parent activities; keep at 10 or lower | |
| `promin.limit.child_node_def` | child activities; 5 or lower | |
| `promin.limit.breakdown_def` | parent breakdowns; 10 or lower | |
| `promin.primary_metric` | workbench metric | `caseFreq` |
| `promin.secondary_metric` | workbench metric | `avgDuration` |
| `promin.metered_usage.allow_unrestricted` | removes guardrails; **excess is charged** | false |
| `promin.metered_usage.warning_limit` | warning threshold | -1 (none) |
| `promin.workspace.hide_from_navigation` | hide from users without roles | false |

## Example

Create *Example Incident Process* on `incident`, activities on **State** and **Assignment group**, breakdown **Priority**, run **Mine project (Sample)**, check the map, then mine in full.

## Related

- [[Task Mining]] · [[Platform Analytics Dashboards]] · [[Otto for Creator and Otto for App Engine]] · [[Granular Admin Roles]]
