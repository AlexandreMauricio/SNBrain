---
type: reference
tags: [reference, change, integrations, roles, troubleshooting, instance-admin]
status: documented
source: ServiceNow Australia IT Service Management PDF, "DevOps Change Velocity" > reference (pp. 1473, 1493-1533, 1548-1552): components installed, properties, System Health dashboard, log levels, common errors, software quality results, domain separation, health scan checks; read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# DevOps Change Velocity Reference

**What it is:** users, roles, jobs, tables, properties, error messages and health checks of DevOps Change Velocity (scope `sn_devops`, application DevOps Data Model; Store application `sn_devops_chgvlcty`).

**Where:** workspace **System configuration > Properties**, or **DevOps > Administration > Properties**.

## Users and roles

Users: `devops.integration.user` (set its password before it is used to configure a tool) and `devops.system` (runs most server-side processing).

| Role | For | Contains |
|---|---|---|
| `sn_devops.admin` | everything; only role with the Administration module | `sn_devops.app_owner`, `sn_devops.integration`, `sn_devops.tool_owner`, `action_designer`; with the health scan pack also `sn_cicd.sys_ci_automation`, `scan_user` |
| `sn_devops.integration` | inbound access for the tools | `flow_operator`, `cmdb_read` |
| `sn_devops.app_owner` | create, update, delete applications; associate objects; change automation and pipeline steps; sees tools without editing them; may run Discover on connected tools | `sn_devops.viewer`, `cmdb_read` |
| `sn_devops.tool_owner` | create tools; Discover, Configure, manual configuration mode, update credentials, check permissions, delete tool; sees System health and Troubleshooting and the Insights dashboards. Credentials only for tools whose access groups include them (or unrestricted tools) | `sn_devops.viewer` (plus vulnerability roles when those plugins are installed) |
| `sn_devops.viewer` | read access | `sn_devops_ws.workspace_user`, `cmdb_read`, `sn_devops.report_viewer` |
| `sn_devops.report_viewer` | needed to see reports on DevOps tables | |

- If a field-level ACL exists on `sys_connection`, add `sn_devops.admin` to it or put `connection_admin` into `sn_devops.admin`, so `devops.system` keeps access.
- After uninstalling DevOps Config, delete empty rows in the roles' *Contains Roles* list (`sys_user_role_contains`) before discovering tool objects.

## Scheduled jobs

| Job | Does |
|---|---|
| *[DevOps] Daily Data Collection* | Performance Analytics collection for Insights (active; run as an admin) |
| *[DevOps] Historical Data Collection* | one-off, on demand, after installing Insights |
| *DevOps auto discover tool associations* | daily discovery of new pipelines, plans and repositories on connected tools |
| *Tool connectivity history* | hourly: checks each tool's connectivity (**Connection state**) and updates **Last webhook activity** |
| *DevOpsImportPolling* | daily import polling when enabled |
| *Retry Errored Inbound Events* | every 2 minutes |
| *Trigger DevOps Health Check Email Notification* | weekly system health email to group *DevOps Report* |

## Tables

`sn_devops_` + `api_schema_definition`, `app`, `artifact`, `artifact_repository`, `artifact_staging`, `artifact_version`, `base_planning_item`, `branch`, `build_test_result`, `build_test_summary`, `callback`, `commit`, `committer`, `commit_details`, `contributor_score_chg_factor`, `environment`, `event`, `event_processor`, `import_filter`, `import_request`, `import_request_page`, `inbound_event`, `integration_capability` (extends Application File), `m2m_app_plan`, `m2m_artifact_execution`, `m2m_artifact_version_commit`, `m2m_artifact_version_package`, `m2m_branch_commit`, `m2m_commit_execution` (Run Commit), `m2m_work_item_plan_version`, `orchestration_task`, `orchestration_task_definition`, `package` (extends Configuration Item), `participant`, `pipeline`, `pipeline_execution`, `plan` (extends Base Planning Item), `plan_version`, `repository`, `step`, `step_execution`, `tag`, `task_execution`, `test_execution`, `test_result`, `test_type`, `tool`, `tool_action`, `tool_capability_mapping`, `tool_integration`, `tool_type_capability`, `work_item`. Others met elsewhere in the guide: `project`, `pull_request`, `processed_inbound_event`, `change_reference`, `tool_connection_status`, `tool_connectivity_history`, `tool_permission`, `capability_activity_mapping`, `tool_integration_configuration`, the software quality tables, `security_orchestration_relation`.

## Properties

Change behaviour:

| Property | Meaning | Default |
|---|---|---|
| `sn_devops.change_request.implement_state` | implement state | -1 |
| `sn_devops.change_request.post_implement_state` | post-implement state | 0 (Review) |
| `sn_devops.change_request.closed_state` | closed state | 3 |
| `sn_devops.change_request.cancel_state` | cancel state | 4 |
| `sn_devops.change_request.approved_approval` | approval text | Approved |
| `sn_devops.change_request.apply_attributes_on_creation` | apply pipeline attributes at insert (so data policies are enforced then) | false |
| `sn_devops.change_request_handler_subflow` | subflow that defaults change fields | `sn_devops.default_change_handler_subflow` |
| `sn_devops.change_request_reusability_decision` | subflow deciding reuse on rerun | `sn_devops.change_request_reusability_subflow` |
| `sn_devops.devops_reused_model_change_request` | subflow run when a change is reused | same name |
| `sn_devops.enable_change_receipt_state_transition` | move states automatically with change receipt | true |
| `sn_devops.enable_change_request_state_transition` | New → Assess directly when the manual approval flow is active | true |
| `sn_devops.cancel_change_on_pipeline_cancel` | cancel the change when its stage fails or is cancelled (not if already rejected, or in Implement or Review) | false |
| `sn_devops.custom_change_categorization` | recognise DevOps changes by the DevOps change field | false |
| `sn_devops.enable_change_creation_with_partial_data` | create the change despite data retrieval errors | false |
| `sn_devops.change_request_callback_timeout` | minutes | 120 |
| `sn_devops.change_request.auto_close_successful_code`, `..._partial_successful_code`, `..._failure_code` | close codes used by auto close | `successful`, `successful_issues`, `unsuccessful` |
| `sn_devops.import_based_evidence_collection` | skip step-level events, collect by import | false |
| `sn_devops.commit_rel_change_step_type` | step types using the Prod Deploy commit logic | |

Events, import, discovery:

| Property | Meaning | Default |
|---|---|---|
| `sn_devops.max_retry_count_inbound_event` | retries of errored events | 3 |
| `sn_devops.inbound_events_error_retry_mins_ago` | look-back in minutes (the guide's table says "1440 (7 days)"; 1440 minutes is 1 day) | 1440 |
| `sn_devops.inbound_events_retry_error_list` | errors that are retried | `TimeOutException,FlowObjectAPIException` |
| `sn_devops.enable_import_polling` | daily polling | false |
| `sn_devops.import.max.retries.per_page` | | 3 |
| `sn_devops.import.max.pages.processing.per_import` | pages processed at a time | 10 |
| `sn_devops.import.max.processing.time.seconds.per_page` | | 300 |
| `sn_devops.import.save.payloads.as.attachments` | | false |
| `sn_devops.import.coding_tool.commits.per_page` (GitHub, Bitbucket), `...branches.per_page`, `...repos.per_page` | page sizes; lower the repositories value for very large tools to avoid timeouts | 100, 19, 100 |
| `sn_devops.import.planning_tool.issues.per_page`, `sn_devops.import.planning_tool.itbm.issues.max.limit` | | 100, 1000 |
| `sn_devops.import.orchestration_tool.executions.per_page`, `...executions.maximum` (Jenkins freestyle) | | 50, 1000 |
| `sn_devops.discover.jenkins.folder.depth` | Jenkins folder nesting discovered (another page of the guide calls it `sn_devops.discover.folder.depth`) | 3 |
| `sn_devops.discover.max.pipelines.ado` | pipelines discovered per Azure DevOps project | 15000 |
| `sn_devops.max_retry_count_discover` | retries of a rate-limited discover | 10 |
| `sn_devops.throttle.reset.time.default` | minutes | 15 |
| `sn_devops.enable_automatic_associations` | auto-associate repositories and pipelines to applications | true |
| `sn_devops.enable_ado_bulk_run_commits`, `sn_devops.enable_github_run_commits` | run commits since the last successful run (up to 2,000) | false |
| `sn_devops.bulk_flow_timeout` | milliseconds | 60000 |
| `sn_devops.bitbucket_default_branch` | branch used for import | master |

Tools and connection:

| Property | Meaning | Default |
|---|---|---|
| `sn_devops.tool_capabilities`, `sn_devops.supported_webhook_capabilities` | | `code,plan,orchestration,artifact,test` |
| `sn_devops.github.url`, `sn_devops.github.api_url`, `sn_devops.github.api_version_path` | | `https://github.com`, `https://api.github.com`, `/api/v3` |
| `sn_devops.enable_ado_generic_connection` | create a generic connection in Azure DevOps on configure (then integration user credentials are asked) | false |
| `sn_devops.token_auth.user` | user switched to after token authentication | `devops.system` |
| `sn_devops.track.gitlab.pullrequests`, `sn_devops.track.azure.pullrequests` | track merge / pull requests | true |
| `sn_devops.permission_check_timeout` | milliseconds per permission check; raise it if checks error out | 10000 |
| `sn_devops.credential_expiration.notify_on_expiration`, `...notify_before_days` | expiry task and notice; days of advance notice (GitHub basic) | true, 3 |
| `sn_devops.last_event_received.warning`, `...critical` | days without events before **Last event received** turns yellow, red | 2, 7 |
| `sn_devops.non_admin_software_quality_summary_flag` | SonarQube with a non-admin token | false |
| `sn_devops.default_test_type` | | JUnit |

Other:

| Property | Meaning | Default |
|---|---|---|
| `sn_devops.devops_log_level` | Error, Warning, Information, Debug, Trace (replaces `sn_devops.enable_debug`). If an application has its own level, the more verbose one applies | Warning |
| `sn_devops.discovered.user.auto.assign.role` | role given automatically to active DevOps users (for example committers); only `sn_devops` roles | `sn_devops.viewer` |
| `sn_devops.sq_ui_category_preferences` | quality columns in the Pipeline UI | `coverage,lines_of_code,bugs,code_smells,duplications,vulnerabilities` |
| `sn_devops.health_duration_report` | days in the system health report | 7 |
| `sn_devops.cascade_delete_threshold` | foreground deletes | 1000 |
| `sn_devops.table_auto_archive_duration` | months | 9 |
| `sn_devops.committer.score.default`, `sn_devops.committer.score.multiply.factor` | committer risk score | 50, 1 |

Workspace recommendation prompts in the classic catalog items (*Create DevOps Application*, *Create DevOps tool*, *DevOps App Onboarding*, *DevOps Tool Onboarding*): comment out the call to `showWorkspaceAdvertisement()` in their catalog client scripts (client-side).

## System Health dashboard

Workspace **List > System health > System health dashboard** (data model 1.33+). Scores are not real time and cannot be drilled into. Reports: Event count (7-day running sum over `sn_devops_inbound_event`, `sn_devops_event` and the processed table), Events by state, Events by tool, Retry count, Processed count, Error count, Waiting count, Event trend, Processing duration. **Administration > System health > Tool connectivity** lists the connection status and history of each tool. The weekly email (notification *DevOps Health Report*) goes to group *DevOps Report*: add DevOps admins to it.

## Software quality results

**DevOps > Software Quality Results > Software Quality Summaries**: one record per scan with **Number**, **Initiated By**, **Scan ID**, **Project Name**, **Last Scanned Date**, **Scan URL**, **Scanner name**, **Tool** (scan id, last scanned by and initiated by are not retrieved with a non-admin token). Details per category, overall and new code: Coverage, Bugs, Reliability rating, Code smells, Duplications, Security rating, Lines of code, Lines to cover, Vulnerabilities, Security hotspots, Security review, Technical debt, Maintainability rating. Subcategories for Vulnerabilities (**DevOps > Integrations > Software Quality Sub Categories**): Blocker, Critical, Major, Minor, Info, plus custom ones.

## Common errors

| Message or symptom | Fix |
|---|---|
| Tool URL invalid or incorrect | official URL format, no trailing space or slash; GitHub Enterprise Cloud uses `https://api.github.com` |
| Platform version cannot be determined | create system property `glide.buildtag.last` |
| CreateDevOps tool connection invalid / credentials incorrect / URL incorrect | on alias *CreateDevOpsTool* (**Connections & Credentials > Connection & Credential Aliases**) create a connection with a basic auth credential and URL `https://<instance>.service-now.com` (needs `connection_admin`) |
| No connection and credential aliases available for DevOps Data Model scope (OAuth) | create a new alias in application DevOps Data Model |
| Technical issue creating the credential or connection record | look at the last execution of subflow `sn_devops.devops_create_credentials` or action `sn_devops.create_connection_for_tool` |
| Credential and domain combination already exists | use another credential |
| Validate subflow not configured (custom integrations) | copy *DevOps Demo Validate Action* and *DevOps Demo Validate Subflow* into DevOps Integrations, set the REST resource path and API version, publish, and reference the subflow from an integration capability with action Validate |
| GitHub app slug name incorrect | the slug is the last part of `https://github.com/settings/apps/<slug>` |
| Password value is too long | Atlassian API tokens are longer since January 2023: enlarge the password field of `discovery_credentials` beyond 255 (KB1269878) |
| Circular redirect to bitbucket.org sign-in | this message's guidance says Bitbucket Cloud is not supported and to use Bitbucket Server through a MID Server, which contradicts the Bitbucket Cloud onboarding in the same guide; treat as a wrong URL or credential type first |
| Mismatch in tool URL (Jenkins) | the URL in **Manage Jenkins > System > Jenkins Location** must equal the tool URL |
| Unable to process the request (GitHub) | more than 20 instances on one webhook |
| Rate limit exceeded | wait; see throttling in [[DevOps Change Velocity Administration and Data Management]] |
| Change cannot be created: type compatibility flag disabled / neither type nor model configured | see [[DevOps Change Models]] |
| Import request stuck in Requested | delete it and import again |
| Tool connection fails | remove the trailing slash from the HTTP connection URL |
| No change for a Jenkins job under change control | not supported when the job is standalone, first in the pipeline, or triggered directly instead of from the pipeline start |
| Jenkins does not wait for approval | set (and re-save) the Jenkins URL in Jenkins Location |
| Events logged as Not Connected | a manually connected tool was disconnected by a change to its alias, type, connection or MID setting: reconnect in manual configuration mode |
| Pipeline waits forever on a Sonar step | the SonarQube tool record does not exist: create it and retry the inbound event |
| Broken links between stages in the Pipeline UI | check **Upstream executions** on the task executions |

## Health scan checks

Scheduled suite: subflows frequently exceeding the 45-second timeout (raise **Timeout** on the integration capability); empty roles in base roles (KB1642669); duplicate pipelines (delete the one without executions or application); `devops.system` access to key tables; related `sn_devops*` plugins not on the same version as `sn_devops_chgvlcty`; pipelines failing for ten executions or waiting; discover and import requests stuck for 5 to 6 hours; scheduled jobs running as an invalid or non-admin user.

On-demand suite: module access policies left on Reject (set to Track; KB1112530); change-controlled steps on untracked pipelines; Jenkins plugin version; customisations in the DevOps scope found in update records; files skipped during upgrade (KB0952456); webhook configuration of tracked objects (GitHub, GitLab, Azure DevOps, Jenkins); GitHub OAuth app configuration (App ID and Client ID against the Application Registry and JWT provider); callbacks open for more than a day or in error; integrity of shipped ACLs and their roles.

## Domain separation

**No support.** Domain fields exist on the tables (data separation only), there is no delegated administration.

## Related

- [[DevOps Change Velocity and DevOps Config]] · [[DevOps Change Velocity Administration and Data Management]] · [[DevOps Insights Dashboards]]
