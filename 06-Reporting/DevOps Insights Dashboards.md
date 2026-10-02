---
type: reference
tags: [reference, reporting, change, integrations]
status: documented
source: ServiceNow Australia IT Service Management PDF, "DevOps Change Velocity" > "DevOps Insights reports", "Group DevOps applications into a product", "DevOps Insights properties" and "DevOps Insights Standard dashboard - Classic" (pp. 1473-1493 and 1533-1548), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# DevOps Insights Dashboards

**What it is:** the Performance Analytics dashboards of DevOps Change Velocity: flow, change acceleration, DORA-style "accelerate" metrics, quality, development and operational stability, per application or product.

**Where:** DevOps Change Workspace > **DevOps Insights** icon. The classic *Insights Standard* dashboard is deprecated for new users.

## Data collection

- **Performance Analytics > Data Collector > Jobs**: *[DevOps] Daily Data Collection* (active by default; **Run As** an administrator; schedule it for a quiet period) and *[DevOps] Historical Data Collection* (inactive; run once, on demand, when Insights is installed after DevOps has been in use).
- With demo data loaded after installing Insights, first run scheduled script *Load Change Request Repo Detail* (fills `sn_devops_insights_change_request_repo_detail`).
- Reports show the last 30 days by default; a data point opens the KPI details. Filters: date, application, product and others.
- Insights is disabled when property *Categorize DevOps changes requests on "DevOps change" field* is on.

Most metrics count only pipeline steps of type **Prod Deploy** in a completed state, and need repository, plan and pipeline to be tracked and associated to the same application.

## Tabs and reports

| Tab | Reports |
|---|---|
| Summary | Average WIP cycle time; Average lead time; Average deployment frequency; Average test pass %; Work items completed (by type); Activity, last 30 days, per application |
| Flow metrics | Average flow time (work item creation to end of a successful production deployment); Average work item cycle time (time in a state); Average WIP count; Work items completed (deployed through a pipeline; filters do not apply); Throughput and distribution (by type); Average planned to deploy flow time; Work in progress |
| Change acceleration | DevOps change volume; Time to close changes (hours, by application); Automated vs manual changes; Changes awaiting approval; Change policy decision: auto-accept and auto-reject (by decision); Change acceleration savings; Developer hours saved |
| Accelerate metrics | Average lead time and Commit to deploy lead time (earliest commit to production); Average and Production deployment frequency; Average MTTR and Mean time to restore from incidents caused by DevOps changes; Average DevOps change failure rate and Change failure rate from incidents; Deployment success rate; Deployments failed |
| Quality | Code coverage % (scan detail category Coverage); Test pass %; Security vulnerabilities; Bug counts |
| Development | Commit frequency; Active committers; Top committers and Top reverters (30-day running sum); Average commits per committer (higher is better); Average commits per pipeline execution (lower is better); Commits without work items (by committer); Pipeline pass percentage |
| Operational stability | Incidents, Outages (`cmdb_ci_outage`), Service availability and Error budget remaining for the service on the Prod Deploy step. Error budget needs the Site Reliability Operations application; availability needs the service offering under that service |

Definitions worth keeping:

- A **DevOps change** is one attached to a step execution. **Automated** = a change policy took the approve or reject action; **manual** = assigned to a person or group and not acted on by a policy.
- **Change failure rate** = DevOps changes that caused an incident ÷ all DevOps changes deployed to production. A change counts once however many incidents it caused; the incident's **Caused by change** must point to it.
- **Deployment success rate** = successful ÷ total production deployments in 30 days × 100. Failed = step execution failed or user-cancelled.
- **Developer hours saved** = work items in the change × hours per developer. **Savings** = hours saved × average hourly developer cost.

## Properties

Workspace **System configuration > Insights properties**.

| Property | Meaning | Default |
|---|---|---|
| *X hours per Developer time* | hours a developer would spend per work item associating evidence by hand | 1 |
| *Change Request Awaiting States* | change states counted as awaiting approval. Values: New -5, Assess -4, Authorize -3, Scheduled -2, Implement -1, Review 0, Closed 3, Canceled 4 | -5, -4 |
| *Average Hourly Developer Cost* | in the selected currency | 100 |

## Products (roll-up of applications)

For the **Product** filter. An application can belong to several products, and products can nest (application > team > product > portfolio).

1. On each application's model (`cmdb_application_product_model`) set **Model categories**.
2. Create an application model for the product with **Model categories** = Bundle.
3. In Model category of component (`cmdb_m2m_model_component`) add one row per member: **Model category of component**, **Component** (the application), **Bundle** (the product).

The application must already have execution data. The daily collection picks the change up; when running by hand, run *Update Repo Details and Work Item State Detail* before the collection job.

## Classic dashboard (deprecated)

Tabs: Change Acceleration (total changes per year, average time to close, DevOps and non-DevOps approval rate, change volume, pending changes per pipeline, changes awaiting approval), Accelerate Metrics, Operational Stability (needs plugin `com.snc.service_portfolio` for the availability widgets), Development (commit frequency, average branches per repository, commits per pipeline execution, commits without work item, work items), Commit Insights (active committers, commits per committer, files added per commit, % commits reverted, top committers and reverters, commits per application), Deployments, System Health (task execution success rate, number of task executions, number of API calls).

## Related

- [[DevOps Change Velocity Reference]] · [[DevOps Change Velocity and DevOps Config]] · [[ITSM Platform Analytics Dashboards and KPIs]]
