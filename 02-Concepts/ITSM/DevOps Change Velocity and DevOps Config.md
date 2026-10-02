---
type: concept
tags: [concept, change, integrations, automation]
status: documented
source: ServiceNow Australia IT Service Management PDF, "DevOps Change Velocity" (pp. 878-1552), read in full 2026-10-02 and detailed in the linked notes; "DevOps Config" (pp. 1553-1775), read in full 2026-10-02 and detailed in the DevOps Config notes linked below
sn-release: Australia
verified:
updated: 2026-10-02
---

# DevOps Change Velocity and DevOps Config

**In one line:** DevOps Change Velocity ingests data from the CI/CD toolchain (plans, commits, builds, tests, scans, artifacts) so a pipeline can create a change request automatically and have it approved, rejected or routed by policy, with full traceability. DevOps Config manages application configuration data alongside it.

This note is the entry point; the detail is in the notes below.

## DevOps Change Velocity

| Pillar | What it does |
|---|---|
| Change automation | a pipeline step creates a **DevOps change request**, waits for the decision (auto-approve, auto-reject or manual via [[Change Approval Policies]]) and closes it when the stage or pipeline ends |
| Change traceability | work items, commits, pull requests, artifacts, packages, test, quality and security results and pipeline executions are related to the change |
| DevOps Insights | flow, change acceleration and accelerate (lead time, deployment frequency, failure rate, MTTR) metrics |

### Map of the notes

| Topic | Note |
|---|---|
| Install, roles, integration user, onboarding pattern, step fields | [[DevOps Change Velocity Setup and Onboarding]] |
| Applications, change control, approval flows and policies, data errors, callback timeout | [[DevOps Applications, Change Acceleration and Approval Flows]] |
| Model-based changes, attribute precedence, pull requests, import based evidence | [[DevOps Change Models]] |
| Artifacts, packages, commit logic, Pipeline UI, `changeRequestDetails` and auto close | [[DevOps Artifacts, Packages, Commits and Pipeline UI]] |
| Imports, polling, cloning, throttling, deletion, archiving | [[DevOps Change Velocity Administration and Data Management]] |
| Roles, tables, properties, errors, health scans | [[DevOps Change Velocity Reference]] |
| Dashboards | [[DevOps Insights Dashboards]] |
| Azure DevOps | [[DevOps Azure DevOps Integration]] |
| GitHub and GitHub Actions | [[DevOps GitHub Integration]] |
| GitLab | [[DevOps GitLab Integration]] |
| Jenkins | [[DevOps Jenkins Integration]] |
| Jira, Rally, Agile Development 2.0, Bitbucket, JFrog, Argo CD, Harness | [[DevOps Planning, Code, Artifact and Deployment Tool Integrations]] |
| SonarQube, Veracode, Checkmarx, Split, tests | [[DevOps Quality, Security and Other Tool Integrations]] |
| Custom integrations, payloads, test and attachment APIs | [[DevOps Custom Tool Integrations, Test and Attachment APIs]] |
| Docker image and CLI | [[DevOps Docker Image and sndevopscli]] |

### Core data model (scope `sn_devops`)

Tool (`sn_devops_tool`) → Plan (`sn_devops_plan`) → Work Item (`sn_devops_work_item`); Repository (`sn_devops_repository`) → Branch, Commit (`sn_devops_commit`); Pipeline (`sn_devops_pipeline`) → Step (`sn_devops_step`) and Pipeline Execution → Step Execution and Task Execution (`sn_devops_task_execution`); Artifact Repository → Artifact → Artifact Version; Package (`sn_devops_package`); App (`sn_devops_app`) groups plans, repositories and pipelines; Inbound Event (`sn_devops_inbound_event`) stages every notification. Domain separation is not supported.

## DevOps Config

Application (CDM scope `sn_cdm`, policies by PaCE) that stores application configuration data as a single source of truth, validates it against policies before deployment and snapshots it per deployable (`sn_cdm_deployable`). **Being prepared for deprecation since Washington DC**: hidden and not activated on new instances, still supported.

| Topic | Note |
|---|---|
| Components, collections, deployables, uploads, changesets, conflicts, CDM properties | [[DevOps Config Data Model and Changesets]] |
| Snapshots, validation, policies, exporters, component libraries, alert investigation | [[DevOps Config Snapshots, Policies and Exporters]] |
| Azure DevOps tasks, Jenkins actions, GitHub actions | [[DevOps Config Pipeline Integration]] |
| Roles, APIs, domain separation, shipped policies and exporters | [[DevOps Config Reference]] |

## Related

- [[Change Management Overview and Lifecycle]] · [[Change Models and Change Templates]]
