---
type: concept
tags: [concept, change, integrations, api, automation, security]
status: documented
source: ServiceNow Australia IT Service Management PDF, "DevOps Change Velocity" > "Azure DevOps integration with DevOps Change Velocity" (pp. 899-986), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# DevOps Azure DevOps Integration

**In one line:** connecting Azure DevOps (ADO) to DevOps Change Velocity: Boards (planning), Repos (coding), Pipelines (orchestration: build pipelines with agent and agentless jobs, and release pipelines), Azure Artifacts, tests and SonarQube scans, with change control inside the pipeline.

Common onboarding pattern and step fields: [[DevOps Change Velocity Setup and Onboarding]]. DevOps calls a tool occurrence an *instance*; ADO calls it a *project*.

## Organization or project

| Connect at | When |
|---|---|
| Organization (recommended) | one credential set discovers all projects; then pick the projects to configure |
| Project | to restrict access per project (access groups are per tool, so one tool per project); repeat for each project |

Tool URL: `https://dev.azure.com/<organization>` or `https://dev.azure.com/<organization>/<project>`.

## Authentication

- **Personal access token (PAT)** (Basic Auth with the ADO username) or **OAuth 2.0**.
- Webhooks ADO → ServiceNow use **token authentication** by default. Integration user name and password are only asked for when DevOps Config is installed or when the property *This property decides whether to create a Generic Connection on configure operation for Azure DevOps* is enabled (needed for the Invoke REST API approach). If user `devops.system` does not exist, set the property *Switch to this user after token based authentication is successful*.
- Tokens can be regenerated from the tool record (*auto-configure with new token*); do it periodically.
- Onboarding needs the PAT owner to be in **Project Collection Administrators** (organization) or the project's **Project Administrators** (project). The privilege can be dropped after onboarding.

### PAT scopes

| Capability | Scope | Level | Why |
|---|---|---|---|
| Boards | Work item | Read | discover boards, receive work items |
| Repos | Code | Read | repositories, branches, commits, tags |
| Build pipelines | Build | Read and execute | read executions; execute to pause and resume for change control |
| Release pipelines and gates | Release | Read, write, execute | same |
| Tests | Test management | Read | test results |
| Service connections | Service connection | Read, query, manage | create the service connection automatically |
| Packaging | Packaging | Read | feeds and packages |

Also needed on the pipeline: the *Update build information* permission. Limitation: a tool created with custom access levels and later reconfigured leaves the old *release created* and *release deployment* service hooks and adds two new ones; create the tool with full access to avoid duplicates.

### OAuth 2.0 setup (outline)

1. Microsoft Entra: a tenant (Workforce), a user with Global Administrator, an ADO organization in that tenant.
2. Azure portal **App registrations > New registration**: single tenant, redirect URL = the instance URL. Note **Application (client) ID** and **Directory (tenant) ID**, add a client secret, add API permission Azure DevOps `vso.project` and copy its **Resource App ID**.
3. Instance, **System OAuth > Application Registry > New > Connect to a third party OAuth Provider**: client id and secret (`<CLIENT_ID>`, `<CLIENT_SECRET>`), **Default Grant type** = Client Credentials, URLs `https://login.microsoftonline.com/<tenant-ID>/oauth2/v2.0/authorize` and `.../token`. In **OAuth Entity Scopes** add `<Resource App ID>/.default`.
4. ADO **Organization Settings > Users**: add the app, give it the project with Project Administrator; add it to the default project team (**Project Settings > Permissions**). If release or classic pipelines do not show, switch off *Disable creation of classic release pipelines*.
5. Instance, **Connections & Credentials > Credentials > New > OAuth 2.0 Credentials** with the default OAuth entity profile, then **Get OAuth Token**. Create **separate credential records for build, release and feeds**.

## After connecting

- Tool record > **Projects** tab > a project: **Discover** (plans, repositories, pipelines) and **Configure** (webhooks). **Discover projects** / **Configure projects** on the tool record work across the organization.
- Webhooks created per project: Build completed, Code pushed, Release created, Release deployment completed, Run stage state changed, Work item created / deleted / restored / updated. Test one in ADO under **Project settings > Service hooks > Edit > Test**.
- Manual webhook: ADO **Service Hooks > new subscription**; URL as in the common pattern plus `&projectId=<project sys_id>` (column `native_id` of table `sn_devops_project`); HTTP header `token : <secret token>`.
- **Track only some pipelines**: add field **Track Specific Pipeline** to the tool form and select it, then set **Track** = true on the wanted pipelines. With it selected only tracked pipelines reach the Inbound Events table (`sn_devops_inbound_event`); unselected, every pipeline's events are processed, which slows things down.
- Classic experience: imported plan data lands in related lists Work Items (tasks, bugs, stories), Plan Versions (releases) and Features (epics, features); a plan and a repository each need an associated App.

## Modelling a pipeline

**DevOps > Apps & Pipelines > Apps** > application > Pipelines. **Orchestration pipeline** = `<Project>/<Pipeline name>`. Select **Track**. Steps are created automatically on the first run when the ServiceNow DevOps extension is used; otherwise create one step per ADO job with **Orchestration stage** = the job name (case-sensitive) and link each orchestration task to its step (tool record > Orchestration Tasks > **Step**).

Release pipelines: change control only in **pre-deployment gates**, and only on the first step of the stage. A phase maps to a step; for multi-configuration or multi-agent jobs the step name is the phase name. Task executions of skipped jobs are marked failed.

## The ServiceNow DevOps extension

Install from Visual Studio Marketplace into the organization, then **Project settings > Pipelines > Service connections > New > ServiceNow DevOps**: authentication method (token or basic), instance URL, **Tool ID** (sys_id of the orchestration tool), API token or integration user, connection name, *Grant access permission to all pipelines*. Automatic webhook configuration creates this service connection for you.

| Task | Use |
|---|---|
| ServiceNow DevOps Release Gate | change control in release pipelines (pre-deployment conditions) |
| Server / Agent **Change Acceleration** | creates the change request in a build pipeline; fields **Upstream job executed**, **Change request details** |
| Server / Agent **Artifact Registration**, **Package Registration** | register artifacts and packages (not supported in release pipelines for the agent variants) |
| Server / Agent **Get Change**, **Update Change** | read the change number; update the change |
| Build / Release **Sonar Registration** | send SonarQube scan references (place after *Run Code Analysis*) |
| Build / Release **Security Results** | send security scan results |

The Job Notification tasks are no longer needed and can be removed.

Release gate evaluation options: *time between re-evaluation of gates* (keeps re-checking a rejected or cancelled change until timeout) and *timeout after which gates fail* (later jobs of the stage are then marked failed).

### Alternative: Invoke REST API

Needs the Generic Connection property enabled and a generic service connection in ADO; a server (agentless) task `InvokeRESTAPI@1` with `waitForCompletion: 'true'` posts to the change control endpoint.

| Pipeline | Body |
|---|---|
| Build | `buildNumber` = `$(build.buildId)`, `isMultiBranch`, `branchName` = `$(build.sourceBranchName)` |
| Release | `releaseNumber` = `$(Release.ReleaseId)`, `projectName` = `$(System.TeamProject)`; set **Pre-deployment conditions > Advanced > Completion event** = Callback |

Add `attemptNumber` (`$(system.jobAttempt)` or `$(Release.AttemptNumber)`) to support reruns; default 1. With duplicate job names use `stageName` = `<azureStageName>/<jobName>`.

## Get and update the change from the pipeline

Get Change inputs: project, pipeline, stage, job, build id, attempt number (optional; latest by default), branch (multibranch). With no inputs it returns the change of the current pipeline and stage. Give the task a reference name and pass `<task_name>.<changeRequestNumber>` to Update Change.

Update Change takes key:value pairs such as `short_description`, `priority`, `start_date`, `end_date`, `justification`, `description`, `cab_required`, `comments`, `work_notes`, `assignment_group` (sys_id), `state`, `close_code`, `reason`. State transitions allowed:

| To | Value | From | Mandatory |
|---|---|---|---|
| Canceled | 4 (property `sn_devops.change_request.cancel_state`) | Implement | `reason` |
| Closed | 3 (property `sn_devops.change_request.closed_state`) | Implement or post-implement (Review) | `close_code` (`successful`, `successful_issues`, `unsuccessful`) and `close_notes` |

## Change state in the pipeline log

On creation and on each state change the console log shows `number`, `details`, `status` (of the step execution), `sys_id`, `type`, `risk`, `priority`, `changeState`, `plannedStartDate`, `plannedEndDate`, `changeRequestURL`, plus the policy decision (auto-approve, auto-reject, manual) and the conditions behind it when the *DevOps Change Request Minimal* or *Advanced Automation Policy* is used (the *DevOps Model Change Policy* logs state only). Policy inputs are stored in Decisions (`sys_decision_question`). Conditions are logged for the fields `code_coverage`, `commits_without_work_item`, `integration_tests_failed`, `load_tests_failed`, `regression_tests_failed`, `num_of_outages_in_last_7_days`, `num_of_current_outages`, `num_of_open_incidents`, `total_num_of_commits`, `tests_passing_percent`, `risk`, `code_security`, `commits`; other fields added to a policy must be added to the flow by hand. With change receipt on, the very first (New) log line may be missing.

## Reruns and change reuse

- Rerunning a failed or cancelled job, stage or pipeline is recorded as a further **attempt of the same pipeline execution** (Pipeline UI: *View all attempts*).
- Subflow *DevOps Change Request Reusability Decision Subflow*: by default the previous attempt's change is **reused when it is in Implement or post-implement**; in any other state a new change is created. Copy and publish a variant and name it in **DevOps Properties > DevOps Change Request Reusability Decision Subflow** to change this.
- When a change is reused, subflow *DevOps Change Request Reusability Model Subflow* runs instead of the model change flow (also replaceable through its property).
- Reused change: test and scan results of every attempt are listed. New change: only the latest.
- A repeated artifact version registration is ignored; a repeated package registration creates a new package (the change shows the artifacts of the latest).
- Reruns made before an upgrade are ignored: run a fresh pipeline after upgrading.

## Parallel stages and jobs

- Release pipelines: parallel stages are processed concurrently and shown in parallel in the Pipeline UI. Build pipelines are still shown serially.
- **Do not put a change in a stage that contains parallel jobs**, and with parallel stages do not make the change the first job of a stage.
- Reason: ADO reports jobs in queue order, so a parallel job queued earlier is taken as upstream and the change waits for it, while the stage completion waits for the change job: a deadlock that ends as a 500 from the event API. Rerunning the job clears it.
- A release gate on more than one start stage can create several pipeline executions.

## Work items (Azure Boards)

Original values are kept in **Native State** and **Native Type**; unrecognised values become *Other*. Historical import is not supported for the CMMI process.

| DevOps type | Basic | Agile | Scrum |
|---|---|---|---|
| Task | Task | Task, Test case | Task, Impediment, Test case |
| Bug | Issue | Bug, Issue | Bug |
| Story | | User story | Product backlog item |
| Epic | Epic | Epic | Epic |
| Feature | | Feature | Feature |

States map to Planned (To Do, New, Open, Approved, Committed), WIP (Doing, Active, Design, In Progress), Complete (Done, Ready, Closed) and Deleted (Deleted, Completed `?`, Removed); the guide's table is flattened, so the exact per-process split is unconfirmed.

Custom processes: override `setDefaultProcess(projectProcess)` in script include `DevOpsAzureDevOpsWorkItemHelper` (extends `DevOpsAzureDevOpsWorkItemHelperSNC`; server-side, scope DevOps): optionally `this.setParentProcess('Basic')` to inherit, then `this.setStates({...})` and `this.setWorkItemTypes({...})` with maps from the native value to `planned`, `wip`, `story`, `task` and so on.

## Artifacts

| Source | Behaviour |
|---|---|
| Build artifacts (tasks PublishBuildArtifacts, PublishPipelineArtifacts) | created automatically; repository name defaults to the build pipeline name; no extension task needed |
| Azure Artifacts | only **Universal** packages, project-scoped feeds, published by a pipeline; set **Track** = true on the artifact repository; job *ADO Artifacts Daily* links them to a build pipeline within 24 hours (heavy: do not run often) |

Mapping: Feed → Artifact Repository, Package → Artifact, provenance / build number → Version (`<artifact-name>-<1.build-number.0>`). Limits: 4,000 feeds per project, 800 packages per feed, 200 packages per pipeline. Orphan artifacts and artifacts published from release pipelines are not supported.

For release pipelines taking a build artifact: repository name must equal the build pipeline name, and the build artifact's name must equal the release artifact's source alias; the version must be `MAJOR.MINOR.PATCH`. For other sources implement extension interface `DevOpsArtifactSemanticVersionAPI`.

## SonarQube scans

Needs a SonarQube tool record ([[DevOps Quality, Security and Other Tool Integrations]]), the SonarQube ADO extension and the Sonar Registration task with **Sonar project Key** and **Sonar Instance Url** (same values as in the scan tasks). Subflow *FetchSonarScanId* processes the inbound event. Results appear on the task execution (**DevOps > Orchestrate > Task Execution** > Software Quality Summary) and on the change.

## Bulk commits

Install plugin `com.glide.hub.action_type.datastream`; set `com.snc.process_flow.reporting.level` to Off for performance. About 8,000 to 9,000 commits per push can be processed; at most 200 run commits are listed per task execution.

## Related

- [[DevOps Change Velocity Setup and Onboarding]] · [[DevOps Change Velocity and DevOps Config]] · [[DevOps GitHub Integration]]
