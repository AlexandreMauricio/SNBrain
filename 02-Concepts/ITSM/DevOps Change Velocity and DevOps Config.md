---
type: concept
tags: [concept, change, integrations, automation]
status: documented
source: ServiceNow Australia IT Service Management PDF, "DevOps Change Velocity" (pp. 878-1552) and "DevOps Config" (pp. 1553-1775), read 2026-10-02 at overview depth: only the introductions, outline and component names were read. The per-tool integration procedures (pp. 899-1311), pipeline configuration, health scans and CDM reference were not transcribed
sn-release: Australia
verified:
updated: 2026-10-02
---

# DevOps Change Velocity and DevOps Config

**In one line:** DevOps Change Velocity ingests data from the CI/CD toolchain (plans, commits, builds, tests, artifacts) so a pipeline can create a change request automatically and have it approved, rejected or routed by policy, with full traceability.

## DevOps Change Velocity

| Pillar | What it does |
|---|---|
| Change automation | a pipeline stage creates a **DevOps change request**, waits for the decision (auto-approve, auto-reject or manual via [[Change Approval Policies]]) and closes it when the stage ends |
| Change traceability | work items, commits, artifacts, packages, test results and pipeline executions are related to the change |
| DevOps Insights | flow and change-acceleration metrics |

**Integrations documented:** Azure DevOps, GitHub, GitLab, Jenkins, Argo CD, Harness (orchestration); Jira, Rally, Agile Development 2.0 (planning); Bitbucket (code); JFrog (artifacts); SonarQube, Veracode, Checkmarx (quality and security); Split.io (feature flags); plus user-created integrations and webhooks.

**Data model (scope `sn_devops`):** `sn_devops_tool`, `sn_devops_tool_integration`, `sn_devops_app` (application) `?`, `sn_devops_plan`, `sn_devops_work_item`, `sn_devops_repository`, `sn_devops_pipeline`, `sn_devops_step`, `sn_devops_pipeline_execution`, `sn_devops_step_execution`, `sn_devops_task_execution`, `sn_devops_package`, `sn_devops_test_result`, `sn_devops_inbound_event` (raw webhook events, with retry and archiving).

**Roles:** `sn_devops.admin`, `sn_devops.tool_owner`, `sn_devops.app_owner`, `sn_devops.integration` (the integration user), `sn_devops.viewer`, `sn_devops.report_viewer`.

**Properties seen:** `sn_devops.change_request.implement_state`, `.closed_state`, `.cancel_state` (which change states the pipeline drives), `sn_devops.cancel_change_on_pipeline_cancel`, `sn_devops.change_request_callback_timeout`, `sn_devops.change_request.apply_attributes_on_creation`, `sn_devops.change_request_handler_subflow`, `sn_devops.devops_reused_model_change_request`, `sn_devops.enable_change_receipt_state_transition`, `sn_devops.devops_log_level`.

DevOps change models are among the shipped models in [[Change Models and Change Templates]]. Cloning needs care (tool connections and credentials); health scans exist in Instance Scan.

## DevOps Config

Application (scope `sn_cdm`) that stores application configuration data as a single source of truth, validates it against policies before deployment and snapshots it per deployable (`sn_cdm_deployable`). **Being prepared for deprecation since Washington DC**: hidden and not activated on new instances, still supported. Roles `sn_devops_config.admin` / `editor` / `viewer`, `sn_cdm.cdm_admin`.

## Related

- [[Change Management Overview and Lifecycle]]
