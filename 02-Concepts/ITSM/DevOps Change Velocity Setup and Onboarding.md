---
type: concept
tags: [concept, change, integrations, automation, workspace, admin]
status: documented
source: ServiceNow Australia IT Service Management PDF, "DevOps Change Velocity" (pp. 878-899: overview, personas, adoption journey, supported tools, dashboards, installation, roles and tasks, integration user, workspace onboarding and widgets), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# DevOps Change Velocity Setup and Onboarding

**In one line:** how DevOps Change Velocity (`sn_devops_chgvlcty`) is installed, who does what, and the common pattern every tool integration follows (connect, grant access, configure webhooks, discover, track, import).

Overview of the product: [[DevOps Change Velocity and DevOps Config]].

## What it gives each persona

| Persona | Gain |
|---|---|
| Developer | no hand-written change requests or evidence; stays in own tools |
| Change manager | automated flows and policy decisions; only changes that need a human reach them; audit answers from collected data |
| Release manager | changes correlated with releases |
| Development leadership | value-stream visibility, comparable team metrics, bottlenecks |
| Operations and support | change and incident in one tool, quicker correlation |
| Compliance officer | policy enforced automatically, evidence gathered automatically |

## Adoption journey (four phases)

1. **Connect tools and applications**: integrate the tools and create DevOps applications for the first teams. No pipeline changes.
2. **Change traceability**: keep creating changes the existing way, but attach stories, commits, tests and scans with a few clicks. No pipeline changes.
3. **Change registration**: the pipeline creates the change request (pipeline must be modified).
4. **Change automation**: changes are approved or rejected by data-driven policy.

Insights dashboards are available throughout.

## How integration works

Tools send webhook notifications or direct REST calls to REST endpoints on the instance; data can also be pulled by polling (nightly, property **Enable Polling**). The DevOps API lets any other tool be connected (user-created integrations).

Webhook URL pattern, used for manual configuration in every tool:

`https://<instance>.service-now.com/api/sn_devops/v2/devops/tool/<capability>?toolId=<tool sys_id>`

where `<capability>` is one of `code`, `plan`, `artifact`, `orchestration`, `test`, `softwarequality`. The tool record also shows a **Secret token** to paste into the tool's webhook secret.

Minimum to get change outcomes: one planning, one coding and one orchestration tool.

### Supported tools (connectors shipped)

| Type | Tools (version named in the guide) |
|---|---|
| Planning | Azure Boards, Azure DevOps Server (2022.0.1), Jira Server and Cloud, ServiceNow Agile Development 2.0, GitHub and GitHub Enterprise (3.7), Rally |
| Coding | Azure Repos, Bitbucket (7.19.2 on-premises) and Bitbucket Cloud, GitHub, GitLab (13.0.6 on-premises or cloud) |
| Orchestration | Azure Pipelines (agent and agentless jobs), Jenkins (2.289.1: freestyle, folder to 3 levels, pipeline, multibranch), GitHub Actions, GitLab, Argo CD |
| Artifacts | JFrog (7), Azure Artifacts |
| Testing | results of tests run inside the supported orchestration pipelines |
| Software quality | SonarQube (8.9.6 or cloud), on Azure DevOps and Jenkins pipelines |
| Feature flag | Split |
| Security | Veracode, Checkmarx One (1.0.17), Checkmarx SAST (1.0.16) |

Extensions needed where plain REST and webhooks are not enough: the *ServiceNow DevOps* plugin for Jenkins, the *ServiceNow DevOps* extension for Azure DevOps (Visual Studio Marketplace), and the ServiceNow DevOps custom actions for GitHub Actions. Per tool: [[DevOps Azure DevOps Integration]], [[DevOps GitHub Integration]], [[DevOps GitLab Integration]], [[DevOps Jenkins Integration]].

## Installation

Role admin. **System Applications > All Available Applications > All**, search *DevOps Change Velocity* or `sn_devops_chgvlcty`, **Install** (on a sub-production instance, request the install from the Store). Can take an hour or more. Demo data can only be loaded at install time.

Products to opt in to for a first production install: DevOps Change Velocity, Playbook Experience, CMDB CI Class Models, Expanded Model and Asset Classes, Universal Task, Jira Spoke, GitHub Spoke, Jenkins V2 Spoke.

## Setup sequence

1. Install.
2. **Assign roles and tasks** (admin or `sn_devops.admin`): **Workspaces > DevOps Change Workspace**, widget *Accounts and users* or **Administration > Onboarding**: *User roles*, *Group roles* (optionally also to child groups), *User tasks*, *Group tasks* (a task such as "create an application" or "connect a tool", with due date; only people whose roles allow the task are offered).
3. **Integration user** (admin): only needed when DevOps Config is installed or for the Rally and Split integrations. **Administration > Set up system accounts > Set new password** for the DevOps integration user (default `devops.integration.user`; any user with role `sn_devops.integration` can be chosen), or set the password on the user record. One-time setup; a separate integration user per tool is possible.
4. **Onboard** from the workspace Home page guide *Get started with DevOps Change Velocity*:

| Who | Role | Steps |
|---|---|---|
| DevOps admin | `sn_devops.admin` | Connect a tool → Create an application → associate pipelines → Automate change → modify the pipeline for change control |
| Tool owner | `sn_devops.tool_owner` | connects tools; asks an admin or app owner for the application |
| App owner | `sn_devops.app_owner` | creates the application and associates pipelines; asks an admin or tool owner to connect tools |

The guide is marked complete when the first pipeline-created change request exists.

## Workspace home widgets

| Widget | Shows |
|---|---|
| Tools | counts of connected, needing attention (unconfigured) and disconnected tools; by capability; by tool type; **Connect a tool** |
| Applications | applications with and without pipelines; work items, commits and pipeline executions of the last 30 days; **Create an application** |
| Automated change requests | changes created in the last 30 days, those pending approval, pipelines with change control enabled that have not yet created a change |

## The common onboarding pattern

Three experiences for every tool: the **workspace playbook** (guided), the **Service Catalog** (items *DevOps Tool Onboarding* and *DevOps App Onboarding*, which must first be activated under **Service Catalog > Catalog Definitions > Maintain Items**; the tool is created when the request is approved), and **Classic** (**DevOps > Tools > Create New (legacy)**).

Workspace entry points: Home (**Connect a tool**), the **Applications** module (*Recommended actions > Connect a tool*) or the **Tools** module. Only connecting **from an application** also discovers and tracks tool objects (plans, repositories, pipelines) in the same pass.

Playbook steps:

1. **Connection details**: tool name, URL, credential type; optional **MID Server** (needed for on-premises tools; application DevOps, capability REST).
2. **Permission check** on the credentials: required versus available permissions are listed; you may continue without all of them or re-enter credentials.
3. **Access**: groups in **Maintained by** (only groups whose members hold DevOps roles). What group members can do depends on their role: Tool Owner views and edits the tool; App Owner views it and can associate, discover, import history and change pipeline steps of its objects; Administrator edits all tools; other DevOps roles only view. With no group, every Tool Owner can edit. Option *All DevOps App Owners can view and associate tool objects to applications*.
4. **Install the tool-side extension** where one exists.
5. **Configure webhooks** automatically (real time, recommended for change automation) or manually; otherwise rely on nightly polling.
6. From an application: select **plans**, **repositories**, **pipelines** to track and associate; optionally **import historical data** (default last 30 days, at most 90 days).
7. **Assign services to pipeline steps**: per step a **Pipeline step type** and a **Service** (a CMDB application service, roughly the environment; leave empty when one step deploys to several environments). Mark at least the production deployment as *Prod deploy* so successful runs count as production deployments and operational metrics (incidents, outages) can be related.
8. Summary > **View tool record**.

Pipeline step fields used when modelling by hand (**DevOps > Apps & Pipelines > Apps** > pipeline > Steps):

| Field | Meaning |
|---|---|
| **Name**, **Pipeline**, **Order** | order drives card order in the Pipeline UI |
| **Type** | Build and Test, Test, Deploy, Deploy and Test, Manual, Prod Deploy |
| **Orchestration stage** | the tool's job or stage name, case-sensitive |
| **Business service** | service the step applies to |
| **Change control** | turns change acceleration on for the step and shows the fields below |
| **Change receipt** | the change is created with all pipeline data but the pipeline does not wait for approval |
| **Change approval group** | becomes **Assignment group** of the change; needs members and a manager so the approver is not empty |
| **Change type** | Normal (default), Standard, Emergency |
| **Change model** | see [[Change Models and Change Templates]] |
| **Template** / **Standard change template** | template for Normal or Emergency; standard change template (mandatory) for Standard |
| **Change controlled branches** | multibranch only; comma-separated, wildcards allowed |

The pipeline's **Track** check box must be true for events to be processed. If tool credentials change, update them on the tool record.

## Dashboards

- **DevOps Insights**: KPIs and trends (Performance Analytics) by application, repository, service, business application, work item type and product.
- **System Health**: for the DevOps administrator; integration health, connectivity, inbound event processing trends.
- **Pipeline UI**: visual view of a pipeline execution.

## Related

- [[DevOps Change Velocity and DevOps Config]] · [[Change Management Overview and Lifecycle]] · [[Change Approval Policies]]
