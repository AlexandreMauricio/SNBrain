---
type: reference
tags: [reference, change, roles, automation, notifications, admin]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Digital Product Release" (pp. 2358-2376 and 2378-2379: Policy Content Pack data collectors and policies, installed roles, scheduled jobs, tables, properties, email notifications, policy status aggregation; pp. 2386-2387: domain separation), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Digital Product Release Reference

**What it is:** roles, tables, scheduled jobs, properties, notifications and the shipped policy content of [[Digital Product Release]].

## Roles

| Role | For | Notable contained roles |
|---|---|---|
| `sn_dpr_model.release_admin` | defines the process, monitors releases | `sn_dpr_model.release_calendar_admin`, `sn_dpr_model.release_template_admin`, `sn_pace.admin`, `sn_pace.mapping_admin`, `sn_devops.tool_owner`, `sn_change_write`, `pd_operator` |
| `sn_dpr_model.product_manager` | manages products and services | `sn_dpr_model.release_user`, the product feature create / write / delete roles, `sn_devops.app_owner`, `sn_change_write`, `asset`, `model_manager`, PaCE reader and mapping roles |
| `sn_dpr_model.release_coordinator` | supports product teams | `sn_change_write`, `pd_operator`, PaCE reader and mapping roles |
| `sn_dpr_model.release_user` | views releases, updates and approves tasks; cannot create releases | `sn_dpr_workspace.workspace_user`, `sn_dpr_model.product_feature_read`, `sn_devops.viewer`, `sn_change_read`, `sn_incident_read`, `sn_problem_read`, `sn_request_read`, `task_editor` |
| `sn_dpr_model.release_calendar_admin` | calendars; only works together with another DPR role | `sn_change_read`, `personalize_choices` |
| `sn_dpr_model.release_template_admin` | templates | `template_editor_global`, `sn_pace.policy_reader`, `sla_manager` |
| `sn_dpr_model.product_feature_create` / `_read` / `_write` / `_delete`, `sn_dpr_model.product_enhancement_read` | granular access | |
| `sn_dpr_workspace.workspace_user` | opens the workspace | `cmdb_read` |

## Tables

| Table | Holds |
|---|---|
| Release (`sn_dpr_model_release`) | releases |
| Release Phase (`sn_dpr_model_release_phase`), Release Task (`sn_dpr_model_release_task`), Key Date (`sn_dpr_model_release_key_date`) | the parts of a release |
| Release Template (`sn_dpr_model_release_template`), Release Association (`sn_dpr_release_association`) | templates and the link release ↔ template |
| Release Calendar (`sn_dpr_model_release_calendar`), Release Readiness Target (`sn_dpr_model_release_target`) | calendars and targets |
| Approval Definition (`sn_dpr_model_approval_definition`) | approval routing |
| Product Feature (`sn_dpr_model_product_feature`), Product Enhancement (`sn_dpr_model_product_enhancement`), Work Item mapping (`sn_dpr_model_product_enhancement_work_item_mapping` → `sn_devops_work_item`) | scope |
| Product Model Settings (`sn_dpr_model_product_settings`) | product-level release settings |
| Policy (`sn_dpr_pace_policy_mapping`, extends `sn_pace_policy_mapping`), Release Phase M2M (`sn_dpr_release_phase_m2m`), Release Policy Execution (`sn_dpr_policy_execution`) | policies mapped to phases and their results |
| Release Phase CI (`sn_dpr_model_release_phase_ci_m2m`), Release Phase CR (`sn_dpr_model_release_phase_cr`), Related Tasks (`sn_dpr_model_release_related_task_m2m`), Release Artifact (`sn_dpr_model_release_artifact`) | what is attached to a release |
| Release Bundle (`sn_dpr_model_release_bundle`, `sn_dpr_model_release_bundle_m2m`) | bundles |
| Release notes (`sn_dpr_model_release_notes`) | generated or manual notes |

Products: `cmdb_application_product_model`; services: `cmdb_service_product_model`.

## Scheduled jobs

| Job | Runs | Does |
|---|---|---|
| Release state transition | hourly | Pending → In progress on the planned start date; In progress → Review when all phases are complete |
| Release phase state transition | hourly | completes a phase whose planned end date is today and whose policy status is compliant, and starts the next |
| DPR Execute policies for all active release phases | daily | runs mapped policies for phases in progress |
| Clean 6 month old unused release target | daily | deletes unused targets older than six months |

## Properties

| Property | Default | Effect |
|---|---|---|
| `sn_dpr.sequential_task_execution` | true | open tasks one at a time by order |
| `sn_dpr.stage_workflow_auto_transition` | true | stage-oriented releases and phases move automatically |
| `sn_dpr.auto_transition_release_to_review` | true | In Progress → Review automatically |
| `sn_dpr.auto_transition_release_to_completed` | false | Review → Completed automatically |
| `sn_dpr.complete_phase_override` | `sn_dpr_model.release_admin` | roles that may complete a phase with non-compliant policies |
| `sn_dpr.default_phase_for_changes`, `sn_dpr.default_phase_for_cis` | `current_phase` | phase used when attaching a change or CI (first phase before start, last after completion); alternative `release_readiness_phase` |
| `sn_dpr.ci_default_query` | excludes end-of-life, end-of-operation and missing life-cycle stages, or certain operational statuses | filter on the CI picker |
| `sn_dpr.mandate_release_target` | false | target required for stage-oriented releases |
| `sn_dpr.max_template_duration` | 730 | maximum total days of a template |
| `sn_dpr.multi_product.create_independent_releases` | false | true = a bundle of independent releases instead of main + child releases |
| `sn_dpr.multi_product.included_products_limit` | 10 | maximum included products at creation |
| `sn_dpr.out_of_band_release_allowed` | true | releases without an existing target |
| `sn_dpr.out_of_band_release_roles` | ? | roles that may create them |
| `sn_dpr.release_calendar_exclusions` | empty | encoded query on `cmn_schedule` for extra exclusion schedules |
| `sn_dpr.release_kanban_lanes` | `1,2,3` | task states shown as Kanban lanes (Open, Work in Progress, Closed Complete) |
| `sn_dpr.VulnerabilitiesTypeMapping` | ? | maps tool-specific vulnerability levels to the standard ones for the Quality dashboard |
| `sn_dpr_model.allow_any_release_dates` | false | allow timeline releases, tasks and retargets with dates in the past |
| `sn_dpr_model.release_related_task_types` (also written `sn_dpr.release_related_record_types`) | incident, problem, sc_request | JSON list of task tables (table, view, label) attachable to a release |
| `sn_dpr_model.rmv2.migration_roles` | ? | extra roles for the Release Management v2 migration |
| `sn_dpr_workspace.enhancement_work_item_types` | `epic` | work item types that can become enhancements; empty = no automatic creation |
| `sn_dpr_workspace.auto_create_product_enhancement_for_primary_epic` | ? | create enhancements automatically from primary epics |
| `sn_dpr_workspace.allowed_states_for_create_auto_product_enhancement` | created, planned, wip, complete, proposed, active, design, ready | epic states considered |
| `sn_dpr_workspace.cmdb_model_creation.supported_ci_types` | `cmdb_ci_service_technical`, `cmdb_ci_service_business`, `cmdb_ci_service_auto`, `cmdb_ci_business_app` | CI types linkable when requesting a product or service |

## Email notifications

| Notification | When | To |
|---|---|---|
| Failed policies for a release phase | on the phase end date | release owner |
| Release task 2-days due reminder | 2 days before the task due date | assignee |
| Release readiness reminder | 1 day before the readiness date | release owner |
| Release phase closed | phase state change | release owner |
| Policies are non-compliant for a release phase | a policy run ends non-compliant | release owner |
| Release task rejected | approval rejected | release owner |
| Release task approval request | approval requested | approver |

A mail is also sent when AI release notes are ready.

## Policy Content Pack

### Data collectors

| Collector | Returns |
|---|---|
| Approval Task Completeness | true when all approval tasks of the phase are approved (false also when there are none) |
| Artifact Story Complete | % of stories completed for the release artifacts (cancelled and deleted excluded) |
| Planned Story Completeness | the same for stories of the release's epics, plus those of the plan version when one is linked |
| Change Request State Validation | number of change requests in given states, for one phase or all |
| Code Coverage | % coverage from artifact versions |
| Commits Without Work Item | % of commits with no work item |
| Work Items Have Commits | % of completed stories without commits |
| Security Vulnerability | count per category: blocker, critical (DevOps critical plus SecOps very high), high, medium, major, minor |
| Test Pass | % passed (skipped excluded), optionally for one test type |

### Policies

| Policy (name) | Non-compliant when | Input |
|---|---|---|
| All Completed Stories Have Associated Commits (`all_completed_stories_have_associated_commits`) | a completed story has no commit | |
| All change requests are closed or inactive (`all_change_requests_are_closed_inactive`) | any change of the phase is still active | |
| All Planned Stories Are Completed (`all_planned_stories_are_completed`) | completion below 100% | |
| Code Coverage Exceeds Threshold (`code_coverage_threshold`) | average coverage across artifact versions (those without data excluded) below the threshold | `minCodeCoverageThreshold` (100) |
| Integration / Load / Regression / Smoke / System / User Acceptance Test Pass Exceeds Threshold (`integration_test_pass_threshold`, `load_test_pass_threshold`, `regression_test_pass_threshold`, `smoke_test_pass_threshold`, `system_test_pass_threshold`, `user_acceptance_test_pass_threshold`) | pass percentage below the threshold | `minTestPassThreshold` (100) |
| No Critical Vulnerabilities Found (`no_critical_vulnerabilities`) | any blocker, critical, high or major vulnerability | |
| Validate change requests (`validate_change_requests`) | a change is not in one of the given states | *Validate all phases* (false), *States to validate* (numeric state values) |

For service releases only the two change-request policies and the planned-stories policy apply.

## Domain separation

Supported at **Standard** level: every DPR table has the **Domain** field (normally `sys_domain` on the platform; the guide gives only the label) and application properties are domain-aware as needed; the instance owner configures business logic and data per tenant.

## Related

- [[Digital Product Release]] · [[Digital Product Release Configuration and Templates]] · [[Working a Digital Product Release]]
