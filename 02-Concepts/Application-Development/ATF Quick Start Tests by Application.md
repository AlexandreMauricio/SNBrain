---
type: reference
tags: [reference, platform, automation, incident, problem, change, sla, cmdb, knowledge, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Testing and debugging applications > Automated Test Framework (ATF) > Test types and techniques > Quick start tests > Available quick start tests by application or feature (one page, 4,570 cleaned lines, processed 2026-10-08). NOT read line by line - the page is a catalogue of test names. For every application the required plugins and the suite names were extracted by script; the individual tests were read for Change Management, Incident Management (and its Service Operations Workspace suite), Problem Management, Major Incident, Service Level Management, On-Call Scheduling, CMDB, Integration Commons for CMDB, Hardware Asset Management, Walk-up Experience, Employee Center, Assessments and Surveys, DevOps, Dashboards. Test lists of the other applications are not in this note. https://www.servicenow.com/docs/r/application-development/automated-test-framework-atf/available-quick-start-tests.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# ATF Quick Start Tests by Application

**What it is:** which ready-made ATF suites exist per application and which plugin installs them, with the individual tests for the ITSM processes. Quick start tests pass only with the application's **demo data** and the base-system process: copy them and adapt the copy ([[ATF Building and Running Tests]]).

From the Brazil docs. See `source` for what was and was not read in detail.

## ITSM suites in detail

### Change Management (plugin `com.snc.change_management.atf`)

| Suite | Tests |
|---|---|
| CHG: Emergency Type Change Request | full flow new to closed; on hold; copy; reject by approver; revert to new; convert emergency to normal; cancel |
| CHG: Normal Type Change Request | full flow; convert normal to emergency; copy; on hold; rejection state; revert to new; cancel |
| CHG: Standard Change Proposal | create, approve and publish a standard change template |
| CHG: Standard Type Change Request | full flow; convert standard to emergency; convert standard to normal |
| CHG: Unauthorized Change Request and Outage | unauthorized change flow; create a planned outage and an outage from a change |
| CHG: Risk Conditions with Best practice plugin | low, moderate, high and leave-alone risk through the UI action property; high and moderate through the business rule property |
| CHG: Change Request against Conflict Sources | change against a blackout window; CI already scheduled; conflict sources |
| CHG: Change Schedule Definition and Sharing | create a change schedule definition; share panel; share; create a standard change from Service Portal |

### Incident Management (plugin `com.snc.incident.atf`)

Suite *Incident Management test suite*: resolution SLA and response SLA baselines; copy incident (also from a closed incident); create standard, emergency and normal change from an incident; create problem; create knowledge (the **Create Knowledge** UI action needs `com.snc.incident.knowledge`); state flow; reopen; assignment; create child incident and check the copied fields; self-service creation through the *Create Incident* catalog item; parent and child state synchronisation, also after reopening.

*Incident Management in Service Operations Workspace test suite*: ships with Service Operations Workspace ITSM Applications (`sn-sow-itsm-cont`) 6.0 or later; for example the **Assign to me** action.

### Problem Management (plugins `com.snc.best_practice.problem.madrid`, `com.snc.problem.atf`, `com.snc.best_practice.problem.madrid.state_model`)

Suite *PRB MGMT: Problem Management test suite*: state management; cancel from Assess and from Root Cause Analysis; mark as duplicate from both states; accept risk (with `problem.acceptrisk.move_to_closed` false, from Fix in Progress); re-analyse a problem closed as Fix Applied, Canceled or Risk Accepted (back to Root Cause Analysis); create emergency and normal change; create a known error article; communicate workaround and fix; the risk-accepted reason and the fix notes reaching the waiting incidents (which become Resolved); problem task state management.

### Major Incident (plugin `com.snc.incident.mim`)

Suite *MIM: Major Incident Management test suite*: create a candidate (module and trigger rule); propose, with and without an assignment group; promote a candidate, both cases; reject; demote; closure; state synchronisation with incident communication plans and tasks; plan attached by condition; resolve with post-incident report; workbench layout; communication task from the workbench.

### Service Level Management (plugin `com.snc.service_level_management.atf`)

Task SLA completed workflow; task SLA cancelled workflow; SLA timer REST API response.

### On-Call Scheduling (plugin `com.snc.on_call_rotation`)

Overlapping shifts with and without a template and with overlap disallowed; time-off with approval; shift managers; search by user, group or schedule; roster details per escalation rule (incoming shift, outgoing shift, all shifts); calendar preview with time zones; active shifts; draft and publish; workbench; hide or show shifts.

### CMDB (plugins `com.snc.cmdb`, `com.snc.cmdb.atf`)

Suites: *CMDB BSM* (dependency views), *CMDB HEALTH* (health dashboard jobs and KPIs), *CMDB IRE* (identification and reconciliation rules by role), *CMDB QB* (Query Builder, including the read-only role), *CMDB REL* (relationship editor and formatter), *CMDB SDK* (REST: query metadata, create / update / query a CI, create and delete a relationship).

*CMDB INT: CMDB Integrations Validation* (Integration Commons for CMDB): validates an integration's application feeds, discovery source, entity mappings, fields, lookups, operations, references, related entries and relationships.

### Others read

| Application | Tests |
|---|---|
| Hardware Asset Management (Store) | disposal, deployment, swap, standard request, refresh, loaner allocation and request, lease expiration, RMA (also from portal), contract renewal |
| Walk-up Experience (`com.snc.walkup`, demo data) | onsite check-in as ITIL user, self-service user and guest |
| Employee Center | ad hoc delegation of approval and HR tasks, favourites, approval hub approve and reject, topic page, home page widgets, taxonomy and topics, portal search, standard ticket page |
| Assessments and Surveys (ATF for Survey plugin) | dynamic validation, clone, question bank, survey creator flow, assign and take an assessment |
| DevOps (Store) | code, plan and orchestration tool flows, with and without change request |
| Dashboards (`com.glide.automated_testing_impl.dashboards`, active by default) | responsive dashboard visibility by impersonation |
| Reporting (`com.glide.automated_testing_impl.report`, active by default) | report visibility; the page notes they do not test report content |

## All applications: plugins and suites

| Application | Plugins or application named | Suites |
|---|---|---|
| Agile Development 2.0 | `com.snc.sdlc.agile.2.0`, `com.snc.sdlc.agile.2.0.atf` | Agile Development 2.0 quick start tests |
| Enterprise Architecture (Application Portfolio Management) | `com.snc.apm.atf` | Create Business application and capability |
| Cloud Provisioning and Governance | `com.snc.cloud.mgmt` | Azure; AWS |
| Coaching | `com.sn_coaching` | Coaching |
| Communities | `com.sn_customer_communities`, `com.sn_communities_demo` | Community |
| Configuration Compliance | `sn_vulc`, demo data | reapply and delete a group rule |
| Continual Improvement Management | `com.sn_cim.atf` | Continual Improvement Management tests |
| Customer Service Management | `com.snc.customerservice.demo` and feature plugins (complaints, onboarding, portals, proxy contacts, orders, major issue, walk-up) | Case Management; Configurable Workspace; Case Types Complaint and Onboarding; Operations Dashboard; CSM Portal; CSP Portal; Guided Decision - Next Best Action; Targeted Communications; Walkup; Customer Project Management |
| Essential SAFe | `com.snc.sdlc.safe`, `com.snc.sdlc.safe.atf` | Essential SAFe |
| Event Management | `com.glideapp.itom.snac` | Event Management quick start tests |
| Field Service Management | `com.snc.work_management` (+ demo), `com.snc.fsm_contractor_management` | FSM |
| Finance Close Automation | ? | FCA |
| Financial Management | `com.snc.financial_management.atf` | ITFM: Financial Modeling flow |
| Granular Delegation | `com.glide.granular_service_delegation` | delegation rule tests |
| GRC | `com.sn_audit`, `com.sn_compliance`, `com.sn_risk`, `com.sn_vdr_risk_asmt` | Audit Management; Continuous Authorization and Monitoring; Policy and Compliance; Risk Management; Vendor and Third-party Risk |
| HR Service Delivery | `com.sn_hr_core`, `com.sn_employee_document_management` | HR case tests; Lifecycle Events; Knowledge blocks |
| Investment Funding | `com.snc.investment_planning.atf` | Investment Funding |
| Knowledge Management | `com.glideapp.knowledge`, `com.snc.knowledge_advanced.installer`, `com.snc.knowledge_blocks` | KM: Knowledge Management |
| Leader Hub | `sn_egd_lh` | Leader Hub |
| Legal Request Management | `sn_lg_ops`, `sn_lg_workspace` | Legal Request |
| Metric Intelligence | `com.snc.sa.metric` | Metric Intelligence |
| Predictive Intelligence | `com.glide.platform_ml` | Predictive Intelligence: ATF Test Suite |
| Project Portfolio Management | `com.snc.financial_planning_pmo.atf`, `com.snc.ppm_multicurrency(.atf)` | PMO: Financial; Innovation Management; Project Management (with child suites); Resource Management; Project Currency |
| Software Asset Management (basic) | `com.snc.samp` and publisher packs | Software Asset Management |
| Security Incident Response | `com.snc.security_incident` | Security Incident Response tests |
| Service Mapping | `com.snc.service-mapping` | Service Mapping |
| Service Portfolio Management Premium | `com.snc.spm` | Service Portfolio Management Premium - ATF Tests |
| Skills Management | `com.snc.skills_management` | Skills Management |
| Test Management 2.0 | `com.snc.test_management.2.0`, `.atf` | Test version; Test results rollup |
| Universal Request | `com.snc.universal_request`, `com.snc.incident.universal_request`, `com.sn_hr_core` | Universal Request quick start tests |
| Vulnerability Response | `sn_vul` | Vulnerability Response tests |

## Related

- [[ATF Building and Running Tests]] · [[Automated Test Framework Overview]] · [[ATF Test Suites, Schedules and Administration]]
