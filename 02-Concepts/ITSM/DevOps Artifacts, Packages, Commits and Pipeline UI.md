---
type: concept
tags: [concept, change, integrations, automation]
status: documented
source: ServiceNow Australia IT Service Management PDF, "DevOps Change Velocity" > artifacts and packages, staging monitoring, commits included in a change, Pipeline UI, configuring change request details within the pipeline (pp. 1347-1373), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# DevOps Artifacts, Packages, Commits and Pipeline UI

**In one line:** artifact versions and packages are how DevOps Change Velocity knows which commits, tests and scans belong to a deployment, even when build and release happen in different pipelines or at different times; the Pipeline UI shows it, and `changeRequestDetails` controls how the change is filled and closed.

## Objects

| Object | Meaning |
|---|---|
| Artifact tool | repository manager such as JFrog Artifactory; only needed when a webhook or look-up subflow must find versions |
| Artifact repository | where artifacts are published; created by hand or by the first registration |
| Artifact | the named thing that is built |
| Artifact version | one build of it, linked to a task execution (and so to its commits) |
| Semantic version | optional `MAJOR.MINOR.PATCH`; when present it decides which commits count |
| Package | the set of artifact versions going into a deployment; has a flag for deployed to production |

Setup: register artifacts in the CI pipeline, create the package in the CD pipeline. **The package step must come before the change step, in an earlier stage, and before the Prod Deploy step**, or the package is not linked to the pipeline execution of the change.

- Registration: DevOps API `/artifact/registration`; Jenkins `snDevOpsArtifact(artifactsPayload: """{"artifacts":[{"name":"<name>","version":"<v>","semanticVersion":"<v>","repositoryName":"<repo>"}],"branchName":"<branch>"}""")` or the freestyle *Register Artifact* build step.
- Package: `/package/registration`; Jenkins `snDevOpsPackage(name: "<package>", artifactsPayload: ...)` or the *Create Package* build step. The package name is mandatory.
- If the version is not known at build time, the build details (pipeline or project name, task execution number, stage, branch) are used to look it up (Jenkins plugin step `includeBuildInfo`).
- Release builds need unique artifact names per branch build.

A package gives two things: all activity of its artifact versions for the approval policy, and a record of what has been released so it is not counted again in later changes.

## Staging table

Registrations wait in `sn_devops_artifact_staging` until the rest of the data arrives (normally seconds). The **Description** says what is missing.

| Staging type | Staging code | Meaning | Final? |
|---|---|---|---|
| `create_package_association` | `WAITING_FOR_OTHER_STAGED_REQUESTS` | task execution found and post-processed, not all artifact versions found | no |
| `create_package_association` / `create_package` / `register_artifact` | `TASK_EXEC_POST_PROCESSING_PENDING` | task execution found, its Completed event not processed yet | no |
| same three | `NO_TASK_EXECUTION_FOUND` | the originating task execution is not in the system yet | no |
| `create_package` | `VERSION_NOT_FOUND` | an artifact version in the payload (or looked up from the task execution) is not found | no |
| `create_package` | `WAITING_FOR_OTHER_STAGED_REQUESTS` | version found, other staging records pending | no |
| `register_artifact` | `VERSION_ALREADY_REGISTERED` | ignored | yes |
| `register_artifact` | `NO_SUBFLOW_CONFIGURED` | version not in payload and neither webhook nor look-up subflow available | yes |
| `register_artifact` | `ERROR_CALLING_SUBFLOW` | look-up subflow did not find the version, failed, or the parent artifact does not exist | yes |

## Which commits a change shows

| Change | Commits |
|---|---|
| Manual (with DevOps data) | those of the artifact versions in the package, plus those of the task executions of the referenced pipeline executions |
| Automated, no package | those of the artifact versions linked to the pipeline execution and its task executions |
| Automated, with package | if an upstream task execution has a Prod Deploy step: everything since the last successful production deployment (each commit once); otherwise all commits of the package's artifact versions |
| fallback | the run commits of the upstream task executions |

Rules:

- An artifact version collects all commits of pipeline executions **on the same branch**, successful or failed, since the previous version of that artifact (all of them if there is no previous version).
- With semantic versions, **patch and hotfix versions are excluded** (for example 1.0.1 between 1.0.0 and 1.1.0), and previous major versions are not included.
- A build not named in a package is left out, but its commits come back in a later package that includes that build, since they have not been deployed yet.
- Revert: neither the reverted nor the reverting commit is associated. Merge and squash-and-merge commits have the merge flag.
- Property `sn_devops.commit_rel_change_step_type`: other step types (for example Deploy, Test) that should use the Prod Deploy logic.

## Pipeline UI

Opened by related link from the Pipeline form, the Pipeline Execution form or a DevOps change. It shows the steps that actually ran.

| Card colour | Meaning |
|---|---|
| Green | all step executions passed |
| Grey | not run yet |
| Yellow | waiting (pending, building, validating); also a stage with a data retrieval error |
| Red | at least one failed. Property `sn_devops.cancel_change_on_pipeline_cancel` = Yes cancels the step's change when the step fails |

- Per step: start, last run, duration, and wait time (start minus end of the upstream task execution). Order from the step's **Order**; skipped stages are not shown.
- **View change** (the change of the latest attempt), **View all attempts**, history of the last 20 pipeline executions (reload to refresh).
- Tiles: Artifacts (versions, work items, commits, packages), Test Results (type/category, pass percentage or throughput), Software Quality Results (by project; default columns from property *Software quality categories shown by default in the Pipeline UI view*), Security Results. Commits reverted within the same execution are hidden.

## changeRequestDetails

Not supported from a GitLab pipeline.

| Key | Effect |
|---|---|
| `attributes` | field values by column name of Change Request (`change_request`). All fields except `risk`, `impact` and `risk_impact_analysis` (calculated). A required dependent field must be passed too, or the change and its step execution are cancelled |
| `setCloseCode` (default true) | at stage completion, fill **Close code** and **Close notes** and move to post-implement. False: the change stays in Implement with closure empty and a link to the step execution in work notes. Disabled when `autoCloseChange` is used |
| `autoCloseChange` | at **pipeline** completion, update close code and notes, **Actual start** and **Actual end** (from the pipeline's or first/last stage's times), and close (true) or only update (false) |

Priority of attribute sources: pipeline attributes or the changeControl API, then the step record, then the template. Change type and template are always taken from a single source.

Auto close also exists as pipeline field **Auto close change** (*Update Change Only*, *Update and Close Change*) on `sn_devops_pipeline`; the pipeline's flag wins. The subflow is *DevOps auto close change on pipeline completion* (`sn_devops.auto_close_change`), replaceable. Properties `sn_devops.change_request.auto_close_allow_override_start_time` and `..._end_time` = false keep the change's own dates.

Limits: for simple pipelines with one change (with several, the latest is closed); not for Jenkins freestyle or change receipt; an Azure release pipeline is unsuccessful if any stage failed and successful with issues if any is partially successful. After an upgrade, reconfigure the orchestration tool before using it for GitHub and Azure build pipelines.

## Related

- [[DevOps Applications, Change Acceleration and Approval Flows]] · [[DevOps Jenkins Integration]] · [[DevOps Azure DevOps Integration]]
