---
type: reference
tags: [reference, cmdb, workspace, reporting, incident, change]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Digital Portfolio Management" (pp. 2153-2174: service and service offering details, business application details, service instance details, KPI groups overview, DevOps value stream metrics; pp. 2190-2196: data views per integrated application; pp. 2230-2235: Needs attention panels), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# DPM Solution Pages and Needs Attention

**What it is:** what each solution page of the [[Digital Portfolio Management]] workspace shows, tab by tab, where the data comes from, and how the Needs attention panel decides what to list.

Tabs can be hidden by the DPM admin ([[DPM Administration, KPI Groups and Reference]]); a section stays empty when its source plugin is missing. The Info tab is read-only everywhere. A retired solution shows a banner.

## Services and service offerings

| Tab | Sections | Source |
|---|---|---|
| Plan | **Roadmap and backlog**; summary cards (Total ideas, Approved demands, Projects starting in the next 30 days, New improvement initiatives); **Demands** list | Strategic Planning or Portfolio Planning; Project Portfolio Management; Continual Improvement Management |
| Build | **Roadmap**; **Projects** (donut by status, overdue by month, cards for work in progress, missed key milestones, critical issues) and active projects; **Changes** (donut by state New to Canceled, overdue by month, upcoming this week, backlog growth in 30 days); **Improvement initiatives** (by state, overdue by month, overdue tasks, closed in 30 days) | PPM, Change Management, CIM |
| Run | **Service / Offering performance** (the Performance snapshot KPI group and any mapped groups); **Offering breakdown** for services (availability, open incidents, incidents not updated for 5 days, new requests per offering); for offerings **Service instance dependencies**, **Commitments**, **SLA commitments** | Performance Analytics, [[Service Offerings, Commitments and Availability]] |
| Info | description; general info (service portfolio, taxonomy node, classification, phase and status or CSDM stage and status, consumer type, last review, dates); personal portfolios; subscribers (locations, departments, groups, companies, users); offerings and service scope with business criticality and business capabilities (services); price and offering commitments (offerings); contracts | CMDB |

Side panel icons: Needs attention, Contacts, Catalog items, Knowledge articles, Attachments.

## Business applications

| Tab | Sections |
|---|---|
| Plan | roadmap and backlog; Total ideas, Approved demands, Projects starting in 30 days, Planned epics; demands |
| Build | roadmap; projects (including those of related service instances); changes; then **either** epics (ready, in progress), stories (ready, in progress, blocked), sprints, releases **or**, with the DevOps property on, **Flow metrics** (flow time for epics and features, bugs and stories, work-in-progress cycle times) and **Accelerate metrics** (lead time for deployment, commit to deploy, deployment frequency) |
| Run | **Portfolio success metrics** (availability, incidents with a breached SLA, incidents caused by changes, successful changes); **Business application performance** (incidents, problems, changes, counting records on the application or on its service instances); **Service instance breakdown**; with DevOps on, accelerate metrics (mean time to restore, change failure rate, split DevOps and other changes) |
| Risk | **Governance, Risk, and Compliance** (risk rating and count, controls out of compliance, attestations, engagements, issues, risk response and remediation tasks); **Technology lifecycle risk** (software and hardware models; needs Technology Lifecycle Management `sn_apm_tpm`) |
| Info | description; general info (enterprise portfolio, taxonomy node, department, business unit, family, category, architecture type, status, life-cycle stage and status, install type, user counts); personal portfolios; business capabilities and service instances; contract (vendor, support vendor, end date); business unit strategy, goals, information objects |

The *Business application performance* KPI group must be mapped to the application for the Run tab to show data. DevOps metrics come from [[DevOps Insights Dashboards]]; links **View Flow metrics in DevOps** and **View Accelerate metrics in DevOps** open the DevOps Change workspace.

## Service instances

Tabs Run, Info, and Risk when `sn_apm_tpm` is installed.

- **Run**: *Service instance performance* with KPI groups Portfolio success metrics, Business application performance, Service health (critical incidents, critical alerts, closed changes), Service impact, Alert trends, Availability insights (availability, unplanned outages, average outage duration); **Commitments**; **Service reliability management** (needs `sn_sow_srm`); offerings that depend on the instance.
- **Info**: business criticality, version, environment, operational status, managed by / support / approval / change groups; personal portfolios; commitments; software and hardware models; related CIs.

A service instance rolls up to the business application that consumes it (relationship *Consumes :: Consumed by* in `cmdb_rel_ci`, parent = business application). It can also sit in a service instance portfolio, so it may inherit KPI groups from both.

| Viewed from | KPI groups shown |
|---|---|
| Enterprise portfolio preview | groups inherited from the enterprise portfolio (empty when none) |
| Detail page, Run tab | all inherited groups plus those mapped directly |
| Personal portfolio or list | all KPI groups |

## KPI cards

Each KPI has an information tooltip, a spark line and a drill-down (trends, breakdowns, supporting KPIs; a timestamp in epoch milliseconds is appended to the URL). With property `sn_dpm.kpi_groups.show_latest_score` true (default for new instances since June 2024) cards show the last collected score and its date, and trends cover 30 days; otherwise a sum or average over the range.

## Needs attention

A side panel on every page; categories differ by solution. Each category shows a count; open it for record cards; **Search** keeps its text until cleared. Records listed are those created today.

| Solution | Categories |
|---|---|
| Services and offerings | critical and major incidents, outages, changes (new instances also audits and risks) |
| Service instances | outages, changes, alerts, risks (new instances also audits) |
| Business applications | critical and major incidents, changes, risks, audits |

Critical problems appear from the DPM August 2024 release. Major incidents need Major Incident Management (`com.snc.incident.mim`); risk data needs `sn_apm_tpm`; alerts need Event Management.

How records attach:

- **Offering**: named in the service offering field of the incident or change, or in the Impacted services / Affected CIs related lists. It shows on the offering, then rolls up to the parent service, once even when two offerings of the same service are involved.
- **Service instance**: named in **Configuration item**, or (since the November 2024 Store release) in Impacted services or Affected CIs. It rolls up to the business application, the taxonomy node and the portfolio.
- **Problems**: on offerings by the offering field or the related lists; on service instances by the configuration item field.

*Standard* Needs attention panels (property `sn_dpm.standard_needs_attention`) are the configurable version from Utah; new customers cannot turn it off.

## Related

- [[Digital Portfolio Management]] · [[DPM Administration, KPI Groups and Reference]] · [[Service Portfolio Management]]
