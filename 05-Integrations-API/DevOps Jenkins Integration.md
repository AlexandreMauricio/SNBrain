---
type: concept
tags: [concept, change, integrations, api, automation]
status: documented
source: ServiceNow Australia IT Service Management PDF, "DevOps Change Velocity" > "Jenkins integration with DevOps Change Velocity" (pp. 1054-1094), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# DevOps Jenkins Integration

**In one line:** connecting Jenkins to DevOps Change Velocity as an orchestration tool (single pipeline, multibranch, folder to three levels by default, freestyle), with change control driven by the *ServiceNow DevOps* Jenkins plugin.

Common onboarding pattern and step fields: [[DevOps Change Velocity Setup and Onboarding]].

## Connection

- Install and keep current the **ServiceNow DevOps Plugin** (**Manage Jenkins > System configuration > Plugins**).
- ServiceNow → Jenkins: Jenkins URL plus username and password, access token or **API token** (user menu > **Security > Add new Token > Generate**; needs overall Read and Job Read; legacy API tokens are not supported; rotate about every 6 months, one token per application). A MID Server is needed for an on-premises Jenkins.
- Jenkins → ServiceNow: basic authentication with the DevOps integration user, the tool's **secret token**, or both. With DevOps Config installed, basic authentication is recommended and Jenkins can only be configured manually.
- **Configure** in the playbook writes the *ServiceNow DevOps Configuration* in Jenkins automatically (needs Jenkins admin; overwrites the existing setup).
- Discovery depth for folders: property `sn_devops.discover.folder.depth`.

### Plugin configuration fields (Manage Jenkins > Configure System > ServiceNow DevOps Configuration)

Up to **ten** configurations (for example one per ServiceNow instance); **Name** and the pair **Instance URL** + **Orchestration Tool ID** must be unique. Values are case-sensitive.

| Field | Meaning |
|---|---|
| **Active** | every active configuration receives pipeline notifications; the change step uses only the one named in the step |
| **Default** | used when a step passes no `configurationName`; with a single configuration it must be selected |
| **Name** | generated when configured from ServiceNow |
| **Instance URL** | `https://<instance>.service-now.com` |
| **Orchestration Tool ID**, **Artifact Tool ID** | sys_ids of the tool records |
| **Credentials** | Jenkins username/password credential holding the integration user (default `devops.integration.user`) |
| **Secret Credentials** | Jenkins *Secret text* credential holding the tool's secret token |
| **Log Level** | inherit, off, severe, warning, info, config, fine, finer, finest, all. Off on new installs; after upgrade Info if Debug was on. Creates a *ServiceNow DevOps* log recorder in Jenkins: change the level here, never in Jenkins' log recorder screen (that duplicates it) |
| **Force Tracking Check** | selected: Jenkins asks ServiceNow on every run whether the pipeline is tracked. Cleared: the answer is cached in `snPipelineInfo.json` under `{JENKINS_HOME}/jobs/{jobName}` and refreshed by flows *DevOps Jenkins File Update - Track* (when **Track** changes) and *DevOps Jenkins File Update - Test Info* (when the test type mapping changes) |
| **Pull Request Pipeline Tracking Check** | track pull request pipelines |

**Test Connection** reports success per credential type.

## Modelling

**Orchestration pipeline** = the full project name in Jenkins; **Track** must be true.

| Pipeline kind | Steps | Change control |
|---|---|---|
| Declarative or scripted (Jenkinsfile) | created and mapped automatically on the first run; each root-level stage is an orchestration task | add `snDevOpsChange()` in the stage and run the pipeline |
| Freestyle | create each step by hand with **Orchestration stage** = stage name (case-sensitive) | select **Change control** on the step |

## Jenkinsfile commands

| Command | Does |
|---|---|
| `snDevOpsChange(...)` | change control for the stage |
| `snDevOpsArtifact`, `snDevOpsPackage` | register artifacts; create a package of artifacts |
| `snDevOpsGetChangeNumber` | returns the change number |
| `snDevOpsUpdateChangeInfo` | updates the change |
| `snDevOpsSecurityResult` | sends security scan attributes |

Any of them accepts `configurationName`; a wrong name fails the step unless errors are ignored. The Jenkins **Pipeline Syntax** snippet generator builds all of them.

`snDevOpsChange` parameters:

| Parameter | Meaning |
|---|---|
| `ignoreErrors` | do not fail the job on an error |
| `changeRequestDetails` | JSON: `attributes` (change fields such as `short_description`, `priority`, `start_date`, `end_date`, `justification`, `description`, `cab_required`, `comments`, `work_notes`, `assignment_group`, `chg_model`), `setCloseCode`, `autoCloseChange` |
| `pollingInterval` | seconds between status polls; the console is updated when state, assignment group, approval, planned dates or details change. Empty = no polling |
| `changeCreationTimeOut` + *Abort on change creation failure* | if the change is not created in time, abort (selected) or resume |
| `changeStepTimeOut` + *Abort on change step timeout* | if the change step is still in progress at timeout, abort (selected) or resume |
| `configurationName` | which plugin configuration |

Get: `snDevOpsGetChangeNumber(changeDetails: """{"pipeline_name": "...", "build_number": "${env.BUILD_NUMBER}", "stage_name": "...", "branch_name": "..."}""")`. Multibranch: suffix the pipeline name with the branch; nested stage: prefix with the parent (`Prod/Deploy`). No input = the change of the current pipeline and stage. Update: same key:value pairs and state rules as in [[DevOps Azure DevOps Integration]].

## What reaches the Jenkins console

- The change number as soon as the change exists (scripted: in the job log; freestyle: against the build in Build History, then in the log after the decision).
- On rejection or cancellation: the reason or comment, approver name and time. Auto-rejections send `'Auto ' + state + ' via Change Policy'`, set in the input script of action *Devops Create Auto Approval Record* (subflow *DevOps Apply Change Approval Definition*).
- Change state and policy decision lines, as for the other tools.

## Nested and parallel stages

Scripted pipelines only (freestyle stays serial in the Pipeline UI).

- Current behaviour: nested and parallel stages are processed and shown as in Jenkins; **change requests are created for nested and parallel stages**, once all upstream events have arrived, and get their own steps and step executions. Check that approval groups are mapped on the right nested step.
- Older behaviour, still described in the guide's stage-mapping section: only root-level stages were mapped, one change per parent stage. The guide states both; the newer text says the old limitation was removed.
- Upgrade off-peak with no pipeline execution in progress; rerun any that were.

## SonarQube and JFrog from Jenkins

- **SonarQube**: SonarQube Scanner for Jenkins 2.4+, plugin 1.27+, a SonarQube tool record. In **Configure System > SonarQube Servers** select *Enable injection of SonarQube server configuration as build environment variables* and use the same server details as in the tool record. The plugin detects `withSonarQubeEnv` in a stage and sends scan id and URL with the stage's end notification.
- **JFrog**: install the Artifactory plugin, configure the server, and **publish build info** with the artifacts (`server.upload(spec)` then `server.publishBuildInfo buildInfo`).

## Related

- [[DevOps Change Velocity Setup and Onboarding]] · [[DevOps Azure DevOps Integration]] · [[DevOps Quality, Security and Other Tool Integrations]]
