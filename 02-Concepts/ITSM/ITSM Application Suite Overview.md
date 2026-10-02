---
type: reference
tags: [reference, incident, change, problem, request, sla]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Exploring IT Service Management", "IT Service Management applications" (pp. 11-13) and the introductions of Benchmarks (pp. 510-543), Coaching (pp. 774-808), Collaboration services (pp. 809-821), Digital End-User Experience (pp. 1776-2144), Digital Portfolio Management (pp. 2145-2261), Digital Product Release (pp. 2262-2386), ITSM Success Dashboard indicators (pp. 2728-2762), Platform Analytics ITSM Dashboards (pp. 2983-3004), Workforce Optimization for ITSM (pp. 3873-4075), read 2026-10-02. For the applications summarised only in this note, just the overview pages and component names were read
sn-release: Australia
verified:
updated: 2026-10-02
---

# ITSM application suite overview

**What it is:** a map of everything the Australia IT Service Management guide (4,075 pages) covers, pointing to the vault note for each application, with a short summary for the ones that have no note of their own.

## Core processes (read in full)

| Application | Notes |
|---|---|
| Incident Management | [[Incident Management Overview and Lifecycle]], [[Incident Properties Reference]], [[Parent and Child Incidents]], [[incident]], [[incident_task]] |
| Major incidents and communications | [[Major Incident Management]], [[Incident Communications Management]] |
| Problem Management | [[Problem Management Overview and Lifecycle]], [[problem]], [[problem_task]] |
| Change Management | [[Change Management Overview and Lifecycle]], [[Change Models and Change Templates]], [[Standard Change Catalog]], [[Change Approval Policies]], [[Change Conflict Detection and Maintenance Schedules]], [[Change Risk Calculation and Assessment]], [[CAB Workbench]], [[Change Schedules Timeline]], [[change_request]], [[change_task]] |
| Request Management | [[Request Management Data Model and Process]] |
| Service Level Management | [[SLA Definitions and Task SLAs]], [[SLA Engine, Repair, Timeline and Breakdowns]], [[task_sla]] |
| On-Call Scheduling | [[On-Call Scheduling]] |
| Task Outage, Release Management | [[Task Outages]], [[Release Management]] |
| Continual Improvement Management | [[Continual Improvement Management]] |
| Roles | [[ITSM Granular Roles]] |

## Supporting applications (summary depth)

| Application | Notes |
|---|---|
| Asset common applications, Expense Line | [[Asset Management Common Applications]], [[Models, Model Categories and the Product Catalog]], [[Expense Lines and Allocations]] |
| Service Portfolio Management, Service Builder | [[Service Portfolio Management]] |
| Service Operations Workspace, Simplified ITSM, Mobile Agent, Walk-up | [[Service Operations Workspace for ITSM]] |
| Otto for ITSM | [[Otto for ITSM Skills and Agentic Workflows]] |
| Virtual Agent, Task Intelligence, ML solutions, L1 AI Specialist, MCP Server | [[ITSM Predictive Intelligence, Task Intelligence and Virtual Agent]] |
| DevOps Change Velocity, DevOps Config | [[DevOps Change Velocity and DevOps Config]] |

## Applications summarised only here

| Application | What it is | Identifiers |
|---|---|---|
| **Benchmarks** | compares your KPIs monthly with anonymised industry averages and top performers; gives recommendations (which can become CIM initiatives). Data is collected daily from the instance; you can opt out | roles `sn_bm_client.benchmark_admin`, `benchmark_data_viewer`, `benchmark_recommendation_viewer` |
| **Coaching** | coaches assess completed work against criteria, create coaching opportunities and recommend learning (Coaching with Learning) | plugin `com.sn_coaching`; tables `sn_coaching_assessment`, `sn_coaching_recommendation`; roles `sn_coaching.admin`, `coach`, `trainee` |
| **Collaboration services** | chat channels (Slack, Teams) created from a task or a communication plan | `sn_tcm_collab_hook`, `com.snc.task_communication_management`; tables `comm_channel`, `comm_channel_definition` |
| **Digital End-User Experience (DEX)** | monitors devices, installed and web applications and networks through an agent; Application and Device Health, DEX Content Playbook (policies, checks, remediation actions), Desktop Assistant, self-service fixes, Digital Experience Score dashboard, Proactive Engagement | scope `sn_dex`; roles `sn_dex.admin`, `engineer`, `user`, `service_desk_user`. Detail: [[Digital End-User Experience Overview and Architecture]] |
| **Digital Portfolio Management (DPM)** | workspace showing services, offerings, business applications and service instances through plan / build / run, with KPI groups and personal and enterprise portfolios | roles `sn_dpm.dpm_admin`, `sn_dpm.dpm_manager`. Detail: [[Digital Portfolio Management]] |
| **Digital Product Release (DPR)** | release planning and readiness for digital products: products, features, enhancements, releases, policy checks (PaCE), AI-generated release notes | scope `sn_dpr`; tables `sn_dpr_model_release`, `sn_dpr_model_release_task`; roles `sn_dpr_model.release_admin`, `product_manager`, `release_coordinator`, `release_user`. Distinct from classic [[Release Management]]. Detail: [[Digital Product Release]] |
| **ITSM Success Dashboard indicators** | leadership KPIs on self-service and deflection | roles `sn_sd.success_dashboard_admin`, `_read`, `_details_read` |
| **Platform Analytics ITSM Dashboards** | content pack of process dashboards (incident, problem, change, request, SLA) that replaces the per-process legacy dashboards deprecated since Xanadu; *IT Agent dashboard* in the workspace | `com.snc.pa.self_service_analytics` |
| **Workforce Optimization for ITSM** | manager workspace for channels and routing, shift schedules, work scheduler, teams, skills and coaching. **Being prepared for deprecation since the Brazil release** (hidden on new instances) | `sn_wfo_cfg_itsm`, `sn_wfo_common`, `sn_shift_planning`, `sn_team_perf`; roles `sn_wfo.admin`, `sn_wfo.user`, `sn_shift_planning.admin` / `agent` |

## Related

- [[ServiceNow AI Platform Overview]]
