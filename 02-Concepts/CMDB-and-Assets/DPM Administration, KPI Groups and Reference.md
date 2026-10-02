---
type: reference
tags: [reference, cmdb, workspace, reporting, roles, admin]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Digital Portfolio Management" (pp. 2174-2190: configuration overview, activation, Admin Center, header, Info tab, scheduled email, solution cards, relationship views, CSDM guidelines and terms; pp. 2197-2212: KPI groups and mappings, copying and updating KPIs, Needs attention attributes, experience configuration, business capabilities, Process Mining; pp. 2241-2259: roles, tables, base KPI groups, related applications and data sources, Process Mining components; p. 2262: domain separation), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# DPM Administration, KPI Groups and Reference

**What it is:** how a DPM admin (`sn_dpm.dpm_admin`) sets up [[Digital Portfolio Management]], plus roles, tables, properties, shipped KPI groups and the plugins each data view needs.

## Setup order

1. Install Digital Portfolio Management from the Store (plugins are installed by an admin).
2. **All > Digital Portfolio Management > DPM Admin Center**.
3. Align data with CSDM (below).

## Admin Center

| Tab | Use |
|---|---|
| **Overview** | **Configure** on a solution card (services with offerings, business applications, service instances) starts a guided walk-through: identify solutions, identify portfolios, assess planning items, assess build metrics, map KPI groups, next steps. Also create and review portfolios. An empty screen in a step usually means missing access |
| **Settings** | per solution: personal portfolio solution cards, header fields, Plan / Build / Run / Risk fields, Info tab sections and general info fields, portfolio properties, KPI group properties, DevOps properties, email properties; show or hide tabs and sections |
| **Troubleshoot** | recalculate availability for chosen services and offerings over a date range (**Recalculate availability**; progress in the event log) |

The walk-through's cards count how records attach to solutions, for example *Business applications related to changes* by the business application field, the configuration item field, affected CIs or impacted services; a card is "Ready for DPM" when any count is above zero. An incident logged against a service instance rolls up to the business application that consumes it.

**Header, General info and solution card fields** (Settings > the item > **Configure**): a record with a *Secondary Values* list, one row per field: **Field**, **Order**, **Active**, **Conditions** (Table, Application and Workspace are fixed). You must be in the record's application scope to edit.

**Scheduled email of KPI metrics** (Settings > **Email properties**): toggle the **Send email** button on enterprise portfolio pages; toggle the scheduled metrics email to DPM managers who own solutions (every two weeks by default; maximum recipients per period). To change the frequency edit the two scheduled jobs *Generate visualization attachments* and *Email performance metrics for DPM managers*; the first must run at least two hours before the second.

## Other administration menus

**Digital Portfolio Management > Administration**: Service instance properties, Business application properties, Service and offering properties, DevOps properties, KPI groups properties, Settings (system properties), **Available item types** (set **Active** false to hide a solution type from cards, personalisation, status conditions and filters).

**Needs attention > Needs attention attributes**: Critical incidents, Outages, Changes, Alerts, Risks, Audits, Critical problems. Columns to add: **Solution type**, **Order**, **Active**, **Show on homepage**, **Show on needs attention**, **Threshold for moderate**, **Threshold for severe** (0 = empty). These defaults apply until a user personalises the home page (KB1519343).

**Business capabilities** show on a service or business application after a relationship in `cmdb_rel_ci`: **Parent** = the business capability, **Type** = *Provided By::Provides*, **Child** = the service or application.

### Properties

| Property | Default | Effect |
|---|---|---|
| `sn_dpm.kpi_groups.show_latest_score` | true on new instances | KPI cards show the last collected score instead of a sum or average |
| `sn_dpm.standard_needs_attention` | true | standard (configurable) Needs attention panels |
| DevOps property (under DevOps properties; name not given) | off | flow and accelerate metrics on business application Build and Run tabs; hides epics, stories, sprints and releases |
| `sn_dpm.enable.po.dpm` | false | Process Mining from KPI groups |
| `sn_itsm_dpm.po_mining.run_frequency` | 7 days | minimum interval between re-mining (the job text calls it `dpm.po_mining.run_frequency`) |
| `dpm.homepage.cmdb_ci_service_limit`, `dpm.homepage.cmdb_ci_business_app_limit` | 750, 250 | default home page card limits |

## CSDM alignment

Phase and status shown on services come from Service (`cmdb_ci_service`). Mapping from the older Service Portfolio Management fields to the CSDM life-cycle fields:

| Phase / Status | Life-cycle stage / status |
|---|---|
| Pipeline / Requirements, Definition, Analysis, Approved | Ideation / Under evaluation |
| Pipeline / Chartered | Design / Chartered |
| Catalog / Design, Development | Design / Design |
| Catalog / Build/Test/Release | Deploy / Test |
| Catalog / Operational | Operational / In-use |
| Catalog / Retiring | Operational / Pending Retirement |
| Retired / Retired | End of life / Retired |
| Retired / Obsolete | End of life / Obsolete |

Terms as the guide uses them: *business service* (published to business users), *technology management service* (published to service owners, underpins a business service or service instance), *service instance* (a deployed application stack; label of `cmdb_ci_service_auto`), *business application* (all environments of software providing a business function), *service offering* (a service split by capability, availability, price), *service commitment* (the delivery obligation, for example an SLA).

## KPI groups

Tables: KPI group (`sn_team_perf_kpi_group`), its KPIs (`sn_team_perf_kpi_group_m2m_pa_indicators`, each pointing at a Performance Analytics indicator in `pa_indicators`), mappings. Plugins `sn_dpm`, Team Performance, `com.snc.service_portfolio`.

1. **Digital Portfolio Management > KPI Groups > New**: **Name**, **Description**, **Type** (service portfolio, taxonomy node, service, offering, service instance, business application, enterprise portfolio, enterprise taxonomy node: a group maps only to records of its type), **Order**, **Show on preview**.
2. Tab **KPIs > New**: **KPI** (the indicator), **Label**, **Parent KPI** (makes it a supporting KPI), **Display aggregate** (Average or Sum; only when latest score is off), **Order**, **Description** (the tooltip), **Chart type** (Single score, Time series Line / Column / Area / Spline / Step line, Group By), **Time range** (7, 30, 90, 180 days), **Active**.
3. **KPI Group Mappings > New**: **KPI Group** and the record to map.

**Copy** on a KPI group (needs Team Performance) duplicates KPIs, supporting KPIs and mappings as "Copy of ..."; deleting a group deletes them too. Open a KPI from its **Label** column. The DPM manager cannot map groups; holders of `service_editor`, `service_admin` or `service_author` can map them to their services. KPI groups are not inherited by service instances except through portfolios.

The deprecated (Utah) Service Offering Metric Data table and its four legacy indicators (SLA achievement, CSAT, availability, request activity) are not available with the current standard portfolio.

Worked procedure: [[Configure a Service Availability KPI in Digital Portfolio Management]].

### Shipped KPI groups

| Group | Type | KPIs (supporting KPIs) |
|---|---|---|
| Performance snapshot, Service metrics | service portfolios, services | Availability (outages, average outage duration); Open incidents (P1, MTTR, CSAT, breached SLA, not updated for 5 / 30 days); Incidents not updated for 5 days; MTTR; New requests |
| Outage and Availability | offerings | Total outage minutes (unplanned, degraded, planned, new emergency changes); Availability (unplanned, degraded, planned outages, average duration) |
| Incidents | offerings | New incidents (P1 to P4, caused by change); not updated for 5 days; breached SLA; by priority |
| Changes | offerings | Open changes (high risk, high priority, overdue); New changes |
| Problems | offerings | New problems; by priority |
| Catalog Activity | offerings | Service requests (RITMs closed complete / incomplete / skipped, average time to close); Requests by catalog item |
| Service health | service instances | Critical incidents (P1, P2, MTTR); Closed changes (emergency, high risk) |
| Availability insights | service instances | Availability; Unplanned outages; Average outage duration |
| Portfolio success metrics | enterprise portfolios | Availability; Incidents with a breached SLA; Incidents caused by changes; Successful changes |
| Business application performance | business applications | Number of incidents, problems, changes |
| Service CSAT | services | Average CSAT; CSAT ratings |

Performance snapshot indicator sources: `serviceoffering.availability.daily`, `incidents.open`, `incidents.resolved`, `[DPM]requests.new` (KB1160281).

## Process Mining

1. Install the ITSM Process Mining Content Pack; set `sn_dpm.enable.po.dpm` to true (**Administration > Settings**).
2. A Process Mining analyst (role written both `sn_process_optimization_analyst` and `process_optimization_analyst` in the guide) opens a KPI group > **Initiate Process Mining**: one project per KPI table (templates for incidents, problems, changes, requests).
3. Projects: **Digital Portfolio Management > DPM Projects**; **Generate model (Full)** to check mining. Adding an assignment group to a mined KPI group updates the project filter.
4. Results: enterprise portfolio > **View Details** > an incident KPI single score > tab **Process analysis** (last 30 days).

Scheduled job *Process Mining - DPM Remine Projects* runs daily and re-mines no more often than the frequency property.

## Roles

| Role | Can | Contains |
|---|---|---|
| `sn_dpm.dpm_admin` | configure the workspace and properties; create, update, delete and map KPI groups; manage every personal portfolio. Not service portfolios (needs the Service Portfolio Management roles) | `sn_dpm.dpm_manager`; `sn_ep.enterprise_portfolio_admin` once the enterprise portfolio plugin is installed |
| `sn_dpm.dpm_manager` | read everything in the workspace, manage own personal portfolios and those shared as editor, create demands and improvement initiatives, update roadmaps. Cannot edit solutions or their relationships, or use Service Builder, without the solution's own roles | `sn_devops.viewer`, `cmdb_read`, `sn_team_perf.team_performance_user`, `service_viewer`, `sn_ep.enterprise_portfolio_viewer` |

## Tables

| Table | Holds |
|---|---|
| `dpm_personal_portfolio`, `dpm_personal_portfolio_item` | personal portfolios and their items |
| `dpm_available_item_type` | solution types that can be shown |
| `dpm_navigation_history` | recently viewed |
| `dpm_home_page_item` | personalised home page |
| `dpm_unified_backlog` | backlog information |
| `sn_dpm_kpi_group_m2m_spm_nodes` | KPI groups ↔ Service Portfolio Management nodes |
| `sn_team_perf_kpi_group` | KPI groups |

## What each view needs

All optional. Data sources span more than 70 tables; the full list is a spreadsheet in KB1123710.

| View | Install | Roles beyond DPM manager |
|---|---|---|
| Roadmap (Plan, Build) | Strategic Planning (`com.sn_align_ws`; pro) or Portfolio Planning (SPM standard) | `sn_align_core.apw_user` or `apw_admin`; `sn_roadmap_plng.roadmap_editor` to edit |
| Improvement initiatives | Continual Improvement Management (`com.sn_cim`) | |
| Ideas, demands, projects | `idea_core`, `dmn_demand`, `pm_project`; Project Portfolio Management (`com.snc.financial_planning_pmo`) | |
| Epics, stories, sprints, releases | Agile Development 2.0 (`com.snc.sdlc.agile.2`) | |
| Changes | none (ITSM) | |
| Flow and accelerate metrics | DevOps, plus the DPM DevOps property | |
| Business application Run tab, deployments | Application Portfolio Management (`com.snc.apm`) | |
| Risk tab | GRC and Risk Management plugins (`com.sn_risk`, `com.snc.governance` and dependencies); Audit Management (`sn_audit`); Technology Lifecycle Management (`sn_apm_tpm`, which needs APM and Software Asset Management) | |
| Alerts on service instances | Event Management | |
| Reliability indicators | Site Reliability Metrics (plugin id written `sn_srm` and `sn_sow_srm` in the guide) | |
| Enterprise portfolios for applications and instances | enterprise portfolio plugin (roles `sn_ep.enterprise_portfolio_admin`, `sn_ep.enterprise_portfolio_viewer`) | |

## Domain separation

Supported at **Standard** level. Because DPM relies on Performance Analytics, ServiceNow must first activate Domain Support - Domain Extensions Installer (`com.glide.domain.msp_extensions.installer`); an administrator then activates Performance Analytics - Domain Support (`com.snc.pa.domain_support`).

## Related

- [[Digital Portfolio Management]] · [[DPM Solution Pages and Needs Attention]] · [[Service Portfolio Management]] · [[Continual Improvement Management]]
