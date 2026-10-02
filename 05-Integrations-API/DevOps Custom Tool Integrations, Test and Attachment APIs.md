---
type: reference
tags: [reference, change, integrations, api, flows, scripting]
status: documented
source: ServiceNow Australia IT Service Management PDF, "DevOps Change Velocity" > test type mappings and decision tables, test API, attachment API, user-created security, GitLab security and orchestration tool integrations, DevOps subflows and standard payloads, custom planning fields, workspace tool integration builder, token webhooks, credential updates and expiry notifications (pp. 1244-1312), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# DevOps Custom Tool Integrations, Test and Attachment APIs

**What it is:** the reference for extending DevOps Change Velocity beyond the shipped connectors: endpoints and authentication, standard payloads, the subflow contracts, test result handling, and credential maintenance.

Overview of the objects (tool integration, capability mapping, integration capability, inbound event errors): [[DevOps Quality, Security and Other Tool Integrations]].

## Endpoints and authentication

| Purpose | Endpoint |
|---|---|
| Inbound events (v2, token) | `POST <instance>/api/sn_devops/v2/devops/tool/{capability}?toolId=<toolId>` with capability `plan`, `code`, `orchestration` (also `artifact`, `test`, `softwarequality`) |
| Inbound events (v1, basic auth) | `POST <instance>/api/sn_devops/v1/devops/tool/{capability}?toolId=<toolId>` |
| Test results | `POST /api/sn_devops/v1/devops/tool/test?toolId=<toolId>&testType=<test type>` |
| Security results | `POST /api/sn_devops/v1/devops/tool/security?toolId=<toolId>` |
| Change of a stage | `GET /api/sn_devops/devops/orchestration/changeInfo?pipelineName=...&toolId=...&buildNumber=...&stageName=...` (returns the change, including `sys_id`) |
| Change control | `POST /devops/orchestration/changeControl` |
| Artifact, package | `/artifact/registration`, `/package/registration` |

Token authentication, either:

- header `Authorization: sn_devops.DevOpsToken <ToolId>:<Token>`, or
- query parameter `&ni.nolog.token=<Token>`.

Tool id, instance URL and token are copied from the tool record (**Configure manually**). Other schemes: implement your own check, for example an `authenticateToken` function in the handler class (admin).

## Standard payloads (Notification capability)

The subflow input is `current` (reference to Inbound Event); it writes the result to `transformed_payload`. No outputs.

| Tool type | Fields |
|---|---|
| Planning | `id`, `type`, `shortDescription`, `state`, `createdDateTime`, `assignedTo` {`name`, `userName`, `id`, `email`}, optional `version` {`id`, `shortDescription`, `url`, `app`}, `app` {`id`, `url`}, `url` |
| Coding | `url`, `committedDate`, `repository` {`name`, `url`}, `branch` {`name`, `path`}, `committer`, `details` [{`additions`, `deletions`, `totalChanges`, `file`, `action`, `changes` (URL-encoded diff)}] |
| Orchestration | `toolId`, `buildNumber`, `nativeId`, `name`, `id`, `url`, `isMultiBranch`, `orchestrationTaskUrl`, `orchestrationTaskName`, `upstreamTaskUrl`, `upstreamId`, `result`, `startDateTime` |
| Test, functional | `name`, `duration`, `passedTests`, `failedTests`, `skippedTests`, `blockedTests`, `totalTests`, `startTime`, `finishTime`, `passingPercent`, plus one linkage |
| Test, performance | `name`, `url`, `duration`, `maximumVirtualUsers`, `throughput`, `maximumTime`, `minimumTime`, `averageTime`, `ninetyPercent`, `standardDeviation`, plus one linkage |
| Artifact | `artifacts` [{`name`, `version`, `semanticVersion`, `repositoryName`}] and `pipelineName`, `taskExecutionNumber`, `stageName`, `branchName` (Jenkins freestyle: `projectName`, `taskExecutionNumber`) |

Test linkage: send one of `packages` [{`name`}], `artifacts` [{`name`, `version`}], or `buildNumber` + `stageName` + `pipelineName`. If several are sent, priority is packages, then artifacts, then build. `pipelineName` must equal **Orchestration pipeline** on Pipeline (`sn_devops_pipeline`), `stageName` must equal **Orchestration stage** on Step (`sn_devops_step`).

## Connect and Discover subflows

| Subflow | Input | Output |
|---|---|---|
| Connect | `current` (DevOps Tool) | `connected` (true/false), `errormessage` |
| Discover | `current` | `discoverpayload`: JSON string of an array of objects; or, with pagination, `pageInfo` {`isLastPage`, `discoverPayload`, `pageDetails` {`curPage`, `nextPage`}} |

Discover payload items: planning {`id`, `name`, `url`, `nativeId`}; coding {`name`, `url`}; orchestration {`orchestrationTasks` [...], `pipelines` [...]} each with `name`, `url`, `projectName`.

Import request states: Requested, Processing, Completed (messages "Updated N object(s)", "Found N objects with invalid toolId", "Found N objects failed validation"), Error, Paused, Canceled, Unmatched. Action *Update Import Request* (inputs `current`, `state`, `details`) lets a Discover subflow set the state; setting `processing` stops flow execution after the subflow returns. A failed import can be retried with **Restart Import** on the import request.

Connect errors on the tool form: *Connection failed* (subflow ran, no connection), *Failed to get failure details...* (subflow failed), *Error updating the tool connect status*.

## Building a custom integration by hand

Roles: developer of the scoped app + DevOps admin. Do not edit shipped tool integration, capability or tool action records, or the DevOps main flow.

1. **DevOps > Integrations > Tool Integrations**: **Tool label**, **Table** (for example Code Tool), *Use packageable integrations*, **Integration version**, **Active**.
2. Subflow (Workflow Studio): **Run As** = System User, input labelled `current`, accessible from all scopes; it may call the tool's API for more data and transform the payload.
3. **DevOps > Integrations > Tool Capability Mappings**: integration + tool type capability.
4. **DevOps > Integrations > Integration Capabilities**: capability mapping, **Action**, **Active**, **Timeout (ms)** (default 45,000), **Subflow name** = `<scope>.<subflow_name>`, **Domain** global. Blank subflow on a Notification = default handling.
5. DevOps admin: tool record referencing the integration, with a connection alias; paste the webhook into the source tool.
6. If the integration lives in another scope: two **Application Cross-Scope Access** records (Read and Write) on table `sn_devops_inbound_event`, target scope DevOps, status Allowed.

Inbound event states: New, In Progress, Processed, Unmatched, Error (**DevOps > Administration > Inbound Events**).

## Building one from the workspace

**DevOps Change Workspace > Administration > Integrations > Tool integrations > New** (application scope set to the custom application). Steps: **Details** (name, version, logo, capabilities Orchestration / Plan / Code) → **Actions** (creates the integration capability records) → **Configurations** (extra connection fields shown in the playbook: **Field name**, **Order**, **Label**, **Mandatory**, **Field type** string or password, **Default value**, **Help text**) → **Transformation** (a generic transform script per action, with **Resource path**; extend it by subclassing `DevOpsGenericIntegrationHandlerSNC`, or map fields with record transformers) → connect an instance through the playbook to validate. An orchestration tool can alternatively be integrated with hand-written transform scripts (KB1794252).

## Custom fields for planning tools (record transformers)

For shipped planning integrations except Agile Development 2.0. Workspace **Administration > Integrations > Tool integrations** > the integration > **Edit field mappings** (scope *DevOps Integrations*).

1. **Create a record transformer** per tool action (for example Import), with a rule sequence.
2. Rules: **Name**, **Symbol** (target field in the transformed payload), **Path** (where the value is read in the incoming payload), **Order**.
3. Transformer details: **Base Path** (read from), **Record Path** (write to), **Record Transformer Rule Sequence**, **Active**.
4. **Add mapping**: the transformer, **Order**, optional symbol.

## Custom security tool

Prerequisite: the application vulnerability integration from KB1441741. Then a tool integration with capability mapping *Security* and integration capabilities **Connect** (subflow `sn_devops_vul_ints.security_tool_connect`) and **Validate** (`sn_devops_vul_ints.security_tool_validate`). Add to the tool integration form the fields **SecOps source integration** (the record in Third Party Integrations, `sn_sec_int_integration`) and **Integration handler name** = `sn_devops_vul_ints.DevOpsSecurityToolIntegrationHandler`. A "<tool> DevOps Integration" record should then exist in Application Vulnerability Integration (`sn_vul_app_integration`).

Which fields the *Update credentials* page asks for: UX page property `securityToolsUIConfig` of the DevOps Change Workspace experience, JSON entry `"<tool_integration_sys_id>": {"CREDENTIAL_PAGE": {"FIELDS_TO_SHOW": ["<parameter>"]}}`.

### Security tools with GitLab (not shipped)

On the GitLab tool integration add a Security capability mapping and an integration capability with action Notification and subflow `sn_devops_vul_ints.devops_security_notification` (deactivate business rule *Seeded tool integrations not editable* first). Then customise script include `sn_devops_ints.DevOpsGitLabIntegrationHandler` (server-side): replace `handleEvent` so that a completed job whose stage name equals `SN_VERACODE`, `SN_CMARX_ONE_STAGE_NAME` or `SN_CMARX_SAST_STAGE_NAME` increments `taskExecution.securityScan.securityScanSummaryCount`, and add `getPipelineWithSecurityEventPayload` (finds the task execution by `execution_url` in `sn_devops_task_execution` and returns its pipeline). The GitLab job in that stage posts to the security endpoint with `pipelineInfo` {`buildNumber`: `${CI_JOB_ID}`, `taskExecutionUrl`: `${CI_JOB_URL}/`} and `securityResultAttributes`. This edits a shipped script include, so it will be skipped on upgrade.

## Test results

- **Test type mapping** fields: **Test type**, **Tool integration**, **DevOps Entity Id** (**Table name** = Step `sn_devops_step` or Pipeline `sn_devops_pipeline`, the only two supported; **Document** = the step or pipeline name), **Test File Paths** (Jenkins only: path of result files that are not JUnit or TestNG, comma-separated).
- Custom test types: workspace **Administration > Integrations > Test types** (**Test type**, **Test category**), then a mapping to the orchestration tool.
- Decision tables: *DevOps Test Subflow Policy* (inputs Test Result Payload, Test Type; answer = the custom subflow that transforms a raw payload, for example when type is Load and the payload contains `throughput` and `concurrency`) and *DevOps Test Type Policy* (inputs Step, Test Result Payload, Tool Integration, Pipeline; answer = the test type, needed when one step produces more than one type).
- Results: **DevOps > Test Results** (Test Summaries, Performance Test Summaries), the change's Test Results related list, the Pipeline UI quality tile.

### Test API from a pipeline

Body = the functional or performance payload above with `buildNumber`, `stageName` (Azure DevOps YAML: `<stage>/<job>`), `pipelineName`; GitHub also sends `workflow`, `repository`, `buildId`, `attemptNumber`. Azure DevOps uses `InvokeRESTAPI@1` on the generic connection with `urlSuffix`; GitHub and Jenkins use curl or `httpRequest` with basic authentication of the integration user. Limitations: no waiting logic and no rerun handling.

### Attachment API

`POST /api/now/attachment/file?table_name=change_request&table_sys_id=<change sys_id>&file_name=<name>.xml` to attach a test report to the change. The change sys_id comes from the Get Change task (`$(<taskname>.changeSysId)`) or the `changeInfo` endpoint. Azure DevOps needs property `sn_devops.enable_ado_generic_connection` and a web-service-only user with role `sn_change_write` on the generic connection.

## Tool credentials

- Update: workspace tool record **More Actions > Update credentials** (type, values, **Check permissions**), then **Connect** (the tool is disconnected after the update). Classic: the credential record in the tool's *Tool connections* related list.
- Expiry check runs hourly. On expiry: a universal task for tool owners in the **Maintained by** groups and for DevOps admins (bell, email, workspace home), and a banner on the tool record. Property *Assign a universal task and notify to update tool credentials when expired* turns this off.
- GitHub tools on basic authentication also get an advance warning (field message on **Credentials expiration**): property *Number of days before tool credential expiry to assign a universal task and notify* (default 3; 0 = off).

## Related

- [[DevOps Quality, Security and Other Tool Integrations]] · [[DevOps Change Velocity Setup and Onboarding]]
