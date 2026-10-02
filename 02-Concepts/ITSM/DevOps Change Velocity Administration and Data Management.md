---
type: concept
tags: [concept, change, integrations, data-management, instance-admin, admin]
status: documented
source: ServiceNow Australia IT Service Management PDF, "DevOps Change Velocity" > "Managing DevOps Change Velocity": generic playbook, onboarding catalog items and APIs, historical import and polling, cloning guidelines, permission checks and required permissions, webhooks from the tool record, throttling, retrying inbound events, custom lists, record deletion, alias reparenting and cleanup, health scans, manual configuration mode, inbound event cleanup, archiving, retry policy, run commits, commit message parsing, event filters (pp. 1397-1473), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# DevOps Change Velocity Administration and Data Management

**In one line:** the operational side of DevOps Change Velocity: bulk onboarding, imports and polling, cloning, throttling and retries, deletion rules, and how its fast-growing tables are cleaned, rotated and archived.

## Onboarding at scale

- Catalog items *DevOps Tool Onboarding* and *DevOps App Onboarding* are **inactive by default**: activate them under **Service Catalog > Catalog Definitions > Maintain Items**. To show them in the portal give them category DevOps and the Service Catalog catalog (create the category on catalog *DevOps Onboarding* if missing); for Employee Center add an **Assigned Topics** entry (taxonomy Employee, *IT > IT for IT*).
- Flow *Request for onboarding approval* approves requests automatically once activated; edit its *Ask For Approval* action for a human approver. A rejected request leaves an inbound event with the error log.
- APIs: `POST /devops/onboarding/tool` and `POST /devops/onboarding/app` accept arrays (`tools`: [{`name`, `type`, `url`, `username`, `password`, `useMidServer`}], plus `credentials` of the integration user) and are processed asynchronously. Never keep such payloads with real credentials in notes or repositories.
- **Generic playbook** for custom tools: stages *Connect to a tool* (connect, access, configure), one stage per capability (select to track, import data, associate services for orchestration), *Summary*. Activity definitions: *DevOps CreateTool AD*, *Configure & Test AD*, *Select Associated Objects AD*, *Import Data AD*, *Associate Services AD*, *Summary AD*. Table `sn_devops_capability_activity_mapping` maps them to capabilities with a condition per tool (for example no import activity for GitLab or JFrog). Only Create Tool has several activity UIs, chosen by condition.

## Historical import and polling

- Up to 90 days. Through the App Onboarding catalog item for an already onboarded tool: Jira (plan), GitHub and GitHub Enterprise (code), Jenkins (orchestration); also Azure DevOps and GitLab (role admin; the request must be approved, then the import starts).
- One import request has child **import request pages**: Jira one per 15 days, GitHub one per 100 commits, Jenkins one per build. Plan imports run first, then repositories and pipelines.
- A failing page is retried automatically (property *Maximum retries per page while importing*); if it still fails the other pages continue and the request ends in error. **Retry import** retries by hand.
- **Polling**: property *Enable Import Polling* switches on scheduled job `DevOpsImportPolling` (daily at midnight, system time zone; never more often than daily). For active applications with tracked objects it imports from the last successful import or 30 days back, whichever is later. Jira times are in the Jira server's zone, Jenkins in UTC.
- Other import properties: *Maximum number of pages to process at a time for an import request*; save payloads as attachments on the import request page (value `true`).

| Tool | Import limits |
|---|---|
| Azure DevOps | 20,000 work items per 15 days; 200 run commits per pipeline execution; test results older than 7 days not returned; SonarQube results not imported; tests, artifacts and packages are linked to pipeline executions, not steps |
| GitLab | 6,400 commits per branch; only artifacts published with the `artifacts` keyword; no test results for expired artifacts; when GitLab gives no "before" SHA (new branch, manual run) the latest commit is used as run commit; pipelines follow their repository |

## Run commits and work items

- A commit must already exist in ServiceNow before the run to appear as a run commit. On reruns of the same commit: Azure DevOps shows none, GitLab and Jenkins only the last commit.
- Commits per payload: Azure DevOps 200, or up to 2,000 since the last successful build with property *Enable whether Azure DevOps Run Commits must be determined from the last successful pipeline build*; GitHub the last commit, or the first 2,000 after the last successful run with the matching GitHub property; GitLab 20.
- **Work items from commit messages** (Azure DevOps, Bitbucket, GitHub, GitLab): the native id is parsed from the message. Shipped patterns: colon (`STRY1, STRY2: text`), hash (`#STRY1`, `AB#123`), Jira key (`JRA-123`). Add patterns by overriding `getWorkitemsFromCommitMessage(message, branchName)` in script include `DevopsCommitMessageParser` (extends `DevopsCommitMessageParserSNC`; server-side): call the parent, add your own regex matches, de-duplicate with `getUniqueWorkItems`. Linking in the Azure DevOps UI also works.

## Event handling

| Mechanism | Detail |
|---|---|
| Event filter | Azure DevOps and GitHub drop ignorable events (tool not connected, object not tracked or unknown) before a flow starts: scripted extension point `sn_devops.DevOpsEventFilterAPI`, one extension instance per tool, **Active** |
| Throttling | Azure DevOps, GitHub, GitLab: on a rate-limit response the tool status becomes **Throttled** and inbound events wait in state **Deferred** until the reset time given by the tool, or property `sn_devops.throttle.reset.time.default` (15 minutes). Table Tool Connection Status (`sn_devops_tool_connection_status`): tool, throttle reset time, throttle active. Log entry `REST_RATE_LIMIT_ERROR` |
| Retry of errored events | scheduled job *Retry Errored Inbound Events* (every 2 minutes). Properties: *Maximum retries for errored inbound events* (3), *Time elapsed (in minutes)* (1440), *Errors or exceptions (comma separated) for which errored inbound events are set to Retry* (`TimeOutExceptions, FlowObjectAPIException`), matched against the event's **Processing Details** |
| HTTP retry | *DevOps Custom HTTP Retry Policy* (**IntegrationHub > Retry Policy**): enable *Retry Policy* on the action's REST step and select it as the override on the alias |

Inbound event states met in the guide: New, In Progress, Retry, Deferred, Waiting, Processed, Ignored, Unmatched, Error.

## Webhooks and connection

- Tool record **Configure**: *Auto configure with existing token*, *Auto configure with new token*, *Configure manually* (also on a project, plan or repository record).
- **Manual configuration mode** (all planning, coding and orchestration tools): when someone else adds the webhook in the tool, **Enter Manual Configuration Mode**, set **Connection state** = Connected, exit. Needs only read access to the tool. The state returns to disconnected whenever URL, credentials, alias, type or MID Server change.
- Testing: Azure DevOps and GitLab have a Test button (GitLab: **Settings > Webhooks > Test > Push events**; two project hooks, code and orchestration). Rally, Split, Jira, Bitbucket and Argo CD cannot test: check that the webhook exists and is active, that tool id and token in its URL are right, or reconfigure from ServiceNow.
- **Permission check** (not for SonarQube, Rally, Argo CD): tool record **More Actions > Check credential permissions**; fields **Permission check result** and **Last Permission check**.

### Permissions needed in each tool

| Tool | Permissions |
|---|---|
| Azure DevOps | Work Items read; Code read; Build read and execute; Release read, write, execute; Test Management read; Service Connections read, query, manage; Packaging read; Project Administrators (webhooks and service connections) |
| Bitbucket | Account read; Projects read; Webhooks read and write; Pull requests read |
| GitHub, basic | `repo`; `admin:repo_hook` (`write:repo_hook`, `read:repo_hook`); `user:email` |
| GitHub, OAuth app | Actions, Contents, Environments, Metadata, Secrets, Pull requests, Checks read-only; Deployments and Webhooks read and write |
| GitLab | `api` read and write |
| Jenkins | Overall read; Job read |
| JFrog | role Administer Platform |
| Jira | group jira-software-users; Jira Administrators (to create webhooks) |

## Connection aliases

- Jira, Jenkins and GitHub tools created since version 1.33 take the spoke alias as parent (`sn_jira_spoke.Jira`, `sn_jenkins_v2_spoke.Jenkins_v2`, `sn_github_spoke.GitHub`) when the spoke is set up (Jira spoke 3.1+, Jenkins spoke 2.1.1+, GitHub spoke 2.2.2+; needs Integration Hub). Older tools keep `sn_devops.DevOps_BasicAuth`: copy the script of script include `DevOpsReparentingConnectionAliasFixScript` into **Scripts - Background** (global scope) to re-parent them.
- Orphan aliases (name starts with `DevOps-_-`, no HTTP connection): a background script in global scope that queries `sys_alias` with `nameSTARTSWITHDevOps-_-` and deletes each alias for which no `http_connection` has `connection_alias` = that alias. It deletes records: run it in sub-production first.

## Cloning (Utah and later)

Excluded and preserved by default: `http_connection`, `discovery_credentials`, `oauth_entity_profile`, `oauth_entity`, `jwt_provider`, `jwt_keystore_aliases`, `sys_certificate`, `token_verification`. Not excluded: `sys_alias`, `sys_user_group`, `cmdb_ci_business_app`, `cmdb_ci_sdlc_component`, `cmdb_application_product_model`.

**Tools cloned from the source** arrive with their alias but no connection, credential or token: URL empty, connect fails, no events. Fix: related link **Create New Connection & Credential**, then **Connect**; then **Regenerate token** (re-creates webhooks for configured objects) or **Configure** with the integration user. Cloned applications need nothing.

**Keeping the target's own setup** needs data preservers:

| Level | Tables (suggested filter) |
|---|---|
| 1 | `sn_devops_tool` (`connection_state=connected`), `sys_alias` (`idLIKEdevops^ORidLIKEspoke`), `sn_devops_app` |
| 2 | `sn_devops_artifact_repository`, `sn_devops_artifact`, `sn_devops_pipeline`, `sn_devops_plan_version`, `sn_devops_plan`, `sn_devops_project`, `sn_devops_repository` (by tool), `sn_devops_m2m_app_artifact_repository`, `sn_devops_m2m_app_artifact`, `sn_devops_m2m_app_plan` (by app), `sn_devops_security_orchestration_relation` |
| custom integrations | `sn_devops_integration_capability`, `sn_devops_tool_capability_mapping`, `sn_devops_tool_integration`, `sn_devops_tool_permission`, `sn_devops_ws_onboarding_task_type` |
| 3 | every DevOps Data Model table (preserve and exclude): apps, artifacts and versions, branches, commits and details, committers, callbacks, change references, import requests and pages, inbound and processed inbound events, all `sn_devops_m2m_*` tables, orchestration tasks, packages, pipelines and executions, plans, projects, pull requests, repositories, software quality tables, steps and executions, tags, task executions, test tables, tool connection status and history, work items |

After a level 1 preserve: re-set **Maintained by**, **Discover** (Azure DevOps: *Discover projects* first), re-track, reconfigure (mandatory for Azure DevOps because project sys_ids change; check for duplicate webhooks), re-import history; for applications re-associate plans, repositories and pipelines and re-link the SDLC component and application model.

## Deleting records

Role `sn_devops.admin`, and the scripted ACL must allow it. Deletion cascades to children, asks for confirmation, and **does not run business rules or flows**.

| Record | Deletable when |
|---|---|
| Pipeline, Pipeline Execution | no other pipeline execution depends on artifact versions they produced |
| Task Execution | no step execution or downstream task execution references it, and nothing depends on its artifact versions |
| Step | no orchestration task or step execution references it |
| Orchestration Task | no task executions (with a step); or, without a step, nothing depends on its artifact versions |
| Repository | none of its commits is linked to an artifact version or a task execution (delete the pipeline side first) |
| Branch | no commits linked |
| Commit | not linked to an artifact version or task execution, not referenced as a revert |
| Plan | none of its work items is referenced by a commit |
| Work Item | not a parent, no commits |
| Plan Version | no work items |
| Test Summary | no relation in Test Summary Relations |
| Artifact, Artifact Repository | all children deletable |
| Artifact Version, Package | **built by task execution** empty (package: also no pipeline execution) |
| Artifact Staged Request | orphaned, or state Processed or Error |
| Tag, DevOps Tool, Build Test Summary, Build Test Result, Commit Details, Event, Inbound Event | never by `sn_devops.admin` |

Cascade: Pipeline → steps, orchestration tasks, executions (step executions, callbacks, task executions with packages, run commits, test data, artifact versions). Repository → tags, branches, commits and their details. Plan → work items, app-to-plan, plan versions. Tool → everything under it. Property *Cascade delete threshold* (1000): beyond it the rest is deleted in the background, bottom-up, so the parent can stay visible for a while. Artifact versions, build test summaries and packages are always deleted in the foreground.

## Table growth

| Mechanism | Detail |
|---|---|
| Processed inbound events | Processed and Ignored events are copied to `sn_devops_processed_inbound_event`, which has **table rotation**: 8 shards of 7 days (56 days) |
| Table cleaners on `sn_devops_inbound_event` | one for Processed and Ignored, one for New, Retry, In-progress and Deferred; **Age in seconds** 4,838,400 (56 days) against `sys_created_on`. A scheduled job enables them two weeks after an upgrade (or one week if the processed table already holds data older than seven weeks); the processed cleaner then runs every 30 minutes |
| Archive rules | property *Auto archive (in months)* (9) for the DevOps archive rules; changing it overwrites any per-rule duration (except rules outside the DevOps scope or inactive). Archived to `ar_<table>`: artifact staging, artifact versions, branches, build test results and summaries, callbacks, commits and details, the m2m tables for artifact execution, artifact version to commit, branch to commit, run commit and commit to work item, pipeline executions, software quality scan summaries and relations, step executions, tags, task executions, test summaries and relations, work items |
| Destroy rules | archived rows are deleted after 36 months (1,095 days) |

Parent archive rules run before their children; to change a child rule, detach or disable the parent first. A restored record is not re-archived unless **Auto rearchive** is set on the rule. Background: [[System Archive and Archive Rules]], [[Database Rotation - Table Rotation and Table Extension]], [[Table Cleaner]].

## Other

- **Health scans**: application *DevOps Change Health Scan Content Pack*. Suite *DevOps Change Velocity Health* with children *Scheduled* and *On-demand*; workspace **Lists > Health scans > Suites > Execute suite scan**; results and findings lists and the home page widget *Health scan findings*. Versions 3.0 to 5.0: Classic UI only.
- **Custom lists**: in the List, Change, Tools or Administration module, **My Lists > Add new list**, from an existing list or from a table, with columns, filters and sort.
- Recommendation prompts for the workspace can be disabled (see the properties in [[DevOps Change Velocity Reference]]).

## Related

- [[DevOps Change Velocity Setup and Onboarding]] · [[DevOps Custom Tool Integrations, Test and Attachment APIs]] · [[DevOps Change Velocity Reference]]
