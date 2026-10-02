---
type: reference
tags: [reference, change, integrations, api, automation]
status: documented
source: ServiceNow Australia IT Service Management PDF, "DevOps Config" > "Integrating your pipeline in DevOps Config": Azure DevOps pipeline tasks, Jenkins pipeline actions, GitHub pipeline actions, and "Using DevOps Config" consumption process (pp. 1595-1596 and 1602-1644), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# DevOps Config Pipeline Integration

**What it is:** the pipeline steps that upload configuration files into DevOps Config, validate and publish the resulting snapshot, attach it to a change request and export the data for deployment tools.

Data model: [[DevOps Config Data Model and Changesets]]. Product status: preparing for deprecation.

**Where:** Azure DevOps (ServiceNow DevOps extension), Jenkins (ServiceNow DevOps plugin), GitHub Actions; Argo CD through its plugin (Store, Ancillary Software).

## The flow

1. A developer commits a config change; the build starts.
2. **Upload** the files to a component, collection or deployable. Committing creates a snapshot per affected deployable.
3. **Get** the snapshots and check their validation status (policies mapped to the deployable).
4. **Publish** the valid snapshot.
5. **Change request** through DevOps Change Velocity with the snapshot attached (tab **Config changes** on the change). Approve.
6. **Export** the snapshot for the deployment tool; deploy; the change is closed.

## Common parameters

| Parameter | Meaning |
|---|---|
| application name | the DevOps Config application |
| target (`uploadTarget` / `target`) | `component`, `collection` or `deployable` |
| collection name, deployable name | required for those targets |
| name path | node path in the data model; start with `vars/` to upload into a variables folder (target must then be deployable, collection or component accordingly) |
| config file (path) | file or pattern in the workspace |
| data format | JSON, YAML, XML, INI, CSV, Properties, RAW. Jenkins: omit it and use a wildcard to upload mixed formats |
| convert path | keep the directory structure as paths in the data model |
| changeset number | reuse an open changeset for several uploads; otherwise a new one is created |
| auto commit, auto validate, auto publish | what to do after the upload |

Several uploads in one commit: first upload with auto commit false and capture the changeset number; pass it to the following uploads; commit (and validate) on the last.

## Azure DevOps tasks

All take `connectedServiceName` (the ServiceNow service connection).

| Task | Inputs | Output |
|---|---|---|
| `ServiceNow-DevOps-Config-Agent-Upload-Config` | `applicationName`, `uploadTarget`, `collectionName`, `deployableName`, `namePath`, `configFilePath`, `convertPath` (false), `dataFormat`, `changesetNumber`, `autoCommit` (false), `autoValidate` (true) | `changesetNumber` (name the task to reference it: `$(componentUpload.changesetNumber)`) |
| `...-Get-Snapshot` | `applicationName`, `deployableName`, `changesetNumber`, `isValidated` (true: only passed or passed with exception), `continueWithLatest` (false: return the latest snapshot when the upload produced none) | `snapshotObjects` (JSON); also writes validation results as a JUnit XML file |
| `...-Get-Snapshot-Name` | `deployableName`, `script` (inline script that finds the snapshot for the deployable in the JSON and prints its name) | `snapshotName` |
| `...-Publish-Snapshot` | `applicationName`, `deployableName`, `snapshotName` | true or false |
| `...-Validate-Snapshot` | `applicationName`, `deployableName`, `snapshotName`, `showResults` | |
| `...-Export-Snapshot` | `applicationName`, `deployableName`, `snapshotName`, `exporterName`, `args`, `exportFormat`, `saveFile` (save into the repository; needs permission), `fileName` | file in the workspace |
| `...-Register-Pipeline` | `applicationName`, `changesetNumber` or `snapshotName` | ties them to the pipeline execution (shown in the Pipeline UI) |
| `ServiceNow-DevOps-Server-Change-Acceleration` | `applicationName`, `snapshotName` | change request with the snapshot attached (server job) |

Validation results in the build's test tab: publish the generated file with `PublishTestResults@2` (`testResultsFormat: 'JUnit'`, file pattern `TEST_DATA_$(Build.DefinitionName)_$(Build.BuildNumber)_*.xml`). Values pass between stages with `stageDependencies.<stage>.<job>.outputs['<task>.<variable>']`.

## Jenkins actions

Scripted and declarative pipelines.

| Action | Does |
|---|---|
| `snDevOpsConfig(...)` | upload, validate and publish in one step (combines upload, get snapshots and register pipeline). Extra arguments `autoPublish`, `markFailed` (fail the pipeline if validation could not run), `showResults`, `isValidated`, `continueWithLatest`. Defaults: commit, validate and publish true. Returns the snapshots |
| `snDevOpsConfigUpload(...)` | upload only; defaults commit and validate false; returns the changeset number; accepts patterns and may be called repeatedly |
| `snDevOpsConfigGetSnapshots(...)` | snapshots for a deployable or all affected ones; writes `<snapshot>_<project>_<build>.xml` for the `junit` step |
| `snDevOpsConfigValidate(...)` | validates a snapshot (or the latest) |
| `snDevOpsConfigPublish(...)` | publishes a snapshot |
| `snDevOpsConfigExport(...)` | `exporterName`, `exporterArgs`, `exporterFormat`, `fileName` (default application + deployable name), optional `snapshotName` (default latest) |
| `snDevOpsConfigRegisterPipeline(...)` | `changesetNumber` **or** `snapshotName`, not both |
| `snDevOpsChange(applicationName: ..., snapshotName: ...)` | change request with the snapshot |

Argument names as used in the guide: `applicationName`, `target`, `collectionName`, `deployableName`, `namePath`, `configFile`, `dataFormat`, `autoCommit`, `autoValidate`, `changesetNumber`.

## GitHub Actions

| Action | Inputs | Outputs |
|---|---|---|
| `ServiceNow/servicenow-devops-config-validate` | `instance-url`, `devops-integration-username`, `devops-integration-user-password` (from secrets), `application-name`, `target`, `deployable-name`, `collection-name`, `name-path`, `config-file-path` (Ant-style pattern), `data-format`, `data-format-attribute`, `auto-commit`, `auto-validate`, `auto-publish` (all default true), `changeset`, `snapshot-validation-timeout` (minutes, 60), `terminate-on-policy-validation-failures` (false) | `changeset-number`, `snapshot-name`, `validation-status` (`passed`, `passed_with_exception`, `failed`, `execution_error`, `not_validated`), `validation-results` (JSON) |
| `ServiceNow/servicenow-devops-config-export` | credentials, `application-name`, `deployable-name`, `exporter-name`, `snapshot-name` (default latest), `exporter-data-format`, `exporter-arguments` (JSON object as a string) | `exporter-content` |

Credentials belong in repository secrets, never in the workflow file.

## Example

A generalised Azure DevOps sequence for an application `Example App` with deployable `Production`:

1. Stage 1: Upload-Config (target component, `autoCommit: true`, `autoValidate: true`), task named `componentUpload`.
2. Stage 2: Get-Snapshot with the changeset number from stage 1 and `continueWithLatest: true`; Get-Snapshot-Name for `Production`; publish test results; Register-Pipeline.
3. Stage 3: Publish-Snapshot with the snapshot name.
4. Stage ChangeRequest (server pool): Server-Change-Acceleration with application and snapshot name.
5. Stage 4: Export-Snapshot with an exporter, `dataFormat: 'yaml'`, `saveFile: true`.

## Related

- [[DevOps Config Data Model and Changesets]] · [[DevOps Config Snapshots, Policies and Exporters]] · [[DevOps Azure DevOps Integration]] · [[DevOps Jenkins Integration]]
