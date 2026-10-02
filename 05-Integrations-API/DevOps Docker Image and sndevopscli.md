---
type: reference
tags: [reference, change, integrations, api, automation]
status: documented
source: ServiceNow Australia IT Service Management PDF, "DevOps Change Velocity" > "Implement custom actions for pipelines using Docker image" (pp. 1444-1464), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# DevOps Docker Image and sndevopscli

**What it is:** a generic container image (`servicenowdocker/sndevops:<version>`; the guide uses 6.2.0) carrying the `sndevopscli` command, used in GitLab, GitHub Actions and Harness pipelines to create and update changes and to register artifacts, packages, Sonar and security results in DevOps Change Velocity.

The image can be rebuilt from the public repository `ServiceNow/app-devops-gitlab` (`docker build`, `docker push`) and customised. Put `image:` at the top of the `.yml` (or per job when several images are used).

## Environment variables

| Variable | Value |
|---|---|
| `SNOW_URL` | instance URL |
| `SNOW_TOOLID` | sys_id of the tool record |
| `SNOW_TOKEN` | the tool's token (**Copy token** on the Tool record, `sn_devops_tool`); masked |

Configuring a GitLab project or GitHub repository from ServiceNow creates these; after an upgrade, reconfigure or add them by hand. Values are shown in the tool record's *Configure manually* dialog.

GitHub Actions passes context too (optional, taken from `github.*`): `PIPELINE_ID`, `JOB_ID` (`github.run_id`), `API_V4_URL` (`github.server_url`), `PROJECT_PATH` and `PROJECT_TITLE` (`<repository>/<workflow>`), `REPOSITORY_NAME`, `RUN_ATTEMPT`, `COMMIT_BRANCH` (`github.ref_name`), `WORKFLOW_NAME`, and `JOB_NAME` per job.

Harness: `HARNESS_STAGE_NAME` = `<+stage.identifier>`, `HARNESS_PIPELINE_NAME` = `<+org.identifier>/<+project.identifier>/<+pipeline.name>`.

Proxy: `PROXY_ENDPOINT` (HTTP or HTTPS; `HTTP_PROXY` / `HTTPS_PROXY` also honoured), optional `PROXY_USERNAME` + `PROXY_PASSWORD` or `PROXY_AUTH` (API key). `NODE_TLS_REJECT_UNAUTHORIZED=0` for self-signed certificates is for testing only.

## Commands

| Command | Arguments |
|---|---|
| `sndevopscli create change -p '<json>'` | `changeStepDetails` {`timeout` (default 3600 s), `interval` (default 100 s)}, `attributes` {change fields}, `autoCloseChange`, `deploymentGateDetails` {`jobName`}. Optional `-ctx '<json>'` (extra context, for example `projectId`, `attemptNumber`; Harness: `pipelineExecutionUrl`, `stageIdentifier`, `stageNodeExecutionId`, `pipelineName`, `upstreamStage`) and `-w` (whether to wait for creation and approval; waits by default) |
| `sndevopscli get change -p '<json>'` | `buildNumber` (job id of the change job), `stageName` (its job name), `pipelineName`: all mandatory unless run in the same job as the create. Writes `sndevopschg.json` {`status`, `changeRequestNumber`} |
| `sndevopscli update change [-n '<CHG number>'] -p '<json>'` | key:value pairs (`short_description`, `description`, `assignment_group`, `work_notes`, `state` ...). Without `-n` the number comes from `sndevopschg.json`; a number in the yml wins. Put `state` last |
| `sndevopscli create artifact -a '<json array>'` | [{`name`, `repositoryName`, `version`, optional `semanticVersion`}] |
| `sndevopscli create package -n "<name>" -a '<json array>'` | package name and its artifacts |
| `sndevopscli create sonar -url '<sonar url>' -projectKey '<key>'` | optional `-branch` |
| `sndevopscli create securityScan -p '<json>'` | `pipelineInfo` {`buildNumber`, `pipelineExecutionUrl` or `taskExecutionUrl`, ...} and `securityResultAttributes` (see [[DevOps Quality, Security and Other Tool Integrations]]) |

Naming rules: the change job's name must contain *ServiceNow DevOps Change*; the Sonar job must be named *ServiceNow DevOps SonarScan Results*. To run Sonar and security steps in the same stage under other names, change `sonar_step_names` and `security_step_names` in table `sn_devops_tool_integration_configuration`.

If a timeout exists both here and in the tool, the earlier one applies. Do not put the Docker change step and a `when: manual` change step in the same job.

## Deployment gate (GitLab)

Combines the CLI (to pass data when creating the change) with a manual job that the change decision releases:

```yaml
ServiceNow DevOps Change:
  stage: DevOpsChangeApproval
  script:
    - sndevopscli create change -p '{"changeStepDetails":{"timeout":3600,"interval":100},"deploymentGateDetails":{"jobName":"sn-change-job"},"attributes":{"short_description":"Example deployment"}}'

sn-change-job:
  stage: deploy
  needs:
    - job: ServiceNow DevOps Change
  when: manual
  allow_failure: false
  script: echo deploy
```

`deploymentGateDetails.jobName` names the downstream manual job.

## Passing the change job id between GitLab jobs

Write the job id to a dotenv file in the change job (`echo "CHG_JOB_ID=$CHG_JOB_ID" >> generated_job_id.env`, exposed as an artifact), `source` it in the get-change job, and expose `sndevopschg.json` as an artifact for the update job (`dependencies:`).

## Limits

- Sonar results on merge pipelines use `MERGE_REQUEST_SOURCE_BRANCH_NAME`, on tag pipelines the default branch, because `COMMIT_BRANCH` is not set there.
- Harness: set `upstreamStage` to the node execution id of the stage before the change (omit it when the change stage is first). Webhook: see [[DevOps Planning, Code, Artifact and Deployment Tool Integrations]].

## Related

- [[DevOps GitLab Integration]] · [[DevOps GitHub Integration]] · [[DevOps Artifacts, Packages, Commits and Pipeline UI]]
