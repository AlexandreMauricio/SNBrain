---
type: concept
tags: [concept, task, reporting]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Continual Improvement Management" (pp. 822-877), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Continual Improvement Management (CIM)

**In one line:** an improvement initiative (`sn_cim_register`, numbered CIM) is a task record with a measurable goal, worked through phases and CIM tasks (`sn_cim_task`, CIMT), approved by a group and tracked on a workbench.

Plugin `com.sn_cim` (ITSM / CSM / HRSD Professional). Menu **Continual Improvement**.

## Roles

| Role | Does |
|---|---|
| `sn_cim.improvement_requester` | create and follow requests; granted automatically to itil, incident_manager, change_manager, PA and survey roles |
| `sn_cim.improvement_coordinator` | runs the improvements assigned to them; workbench; contains the requester role and many PA, Benchmarks and CMDB read roles |
| `sn_cim.improvement_manager` | everything: accept, assign, create enterprise strategies, close, delete |

## States

| State | Who moves it | Notes |
|---|---|---|
| New | requester | **Continual Improvement > Create New**: short description and business justification |
| Accepted | manager (**Accept**; **Reject** → Canceled) | after setting **Strategies** and **CIM Coordinator** |
| Assess | manager | waits for the **Approver group** (default *CIM Approvers*, empty): one approval is enough; requests expire after 7 business days |
| Approved | approver | a default phase is created |
| Implement (In Progress) | manager / coordinator | phases and tasks are worked |
| On Hold | | active CIM tasks go on hold with it and return to Open afterwards |
| Monitor/Review | coordinator (**Review**) | when all tasks and phases are 100 % |
| Closed | manager (**Close**) | needs closure code, achieved outcome category, close notes |
| Canceled | any time | tasks become Closed Incomplete |

**Submit for Re-Approval** sends an approved or running initiative back to Assess; tasks added after approval stay **Pending** until re-approved.

## Measuring

**Goals** tab: **Success measurement method** (for example Automated: PA Indicator), **Improvement KPI**, **Base value**, **Percentage improvement**, **Target value**, **Target review date**. The **Impacted KPIs** related list (`sn_cim_related_kpi`) adds scorecards to the form.

Progress roll-up: each task contributes in proportion to its planned duration; only Closed Complete tasks count.

## Workbench

**Continual Improvement > Workbench**: **Overview** (tiles for Implement and On Hold, list for Review; badges Complete, Overdue, Due soon < 15 % time left, On Hold) and **Planning** (drag between Backlog and Work in Progress; only Approved items can be moved to Implement). List columns come from the views *Workbench Review* and *Workbench Planning*.

## Integrations

| Direction | Records |
|---|---|
| Create an initiative **from** (related link **Create Improvement Initiative**) | problem, post incident review of a major incident, Benchmarks recommendation, CMDB remediate-duplicate task, demand, GRC issue, survey, coaching opportunity |
| Create **from** an initiative or CIM task (related links) | change (**Create Change**), demand, project, story, knowledge article, coaching opportunity, PA indicator |

Tables `sn_cim_inbound_m2m`, `sn_cim_outbound_m2m`. More tables are added by implementing the extension point `sn_cim.CIMIntegrationAPI` (`getInboundIntegrationTables`, `getOutboundIntegrationTables`).

## Properties (Continual Improvement > Administration > Properties)

| Property | Default | Effect |
|---|---|---|
| `sn_cim.need_approval` | Yes | No = accepted initiatives go straight to Approved |
| `sn_cim.create_default_phase` | No | create a phase with every initiative |
| `sn_cim.initiative_copy_attributes` | short_description, description, priority, cim_estimate, benefit, assigned_to, strategic_objective, business_process, business_service, approver_group, type, service_offering | fields copied to records created from an initiative |

Domain separation: Basic.

## Related

- [[Problem Management Overview and Lifecycle]] (`sn_cim_register.source_id` is tracked as a problem fix) · [[Major Incident Management]]
