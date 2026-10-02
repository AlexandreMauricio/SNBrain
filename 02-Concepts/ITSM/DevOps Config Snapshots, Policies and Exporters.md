---
type: concept
tags: [concept, change, integrations, data-integrity, scripting, admin]
status: documented
source: ServiceNow Australia IT Service Management PDF, "DevOps Config" (pp. 1591-1598 and 1668-1725: defining and mapping policies, running validation, fixing validation failures, activity history, deleting applications and changesets, validation process and CdmPolicyUtil, component libraries and shared components, snapshots, snapshot comparison, exporters, alert investigation, Insights dashboard), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# DevOps Config Snapshots, Policies and Exporters

**In one line:** every commit in DevOps Config produces a snapshot per affected deployable; policies validate the snapshot, only published snapshots can be exported, and exporters turn a snapshot into the data a deployment tool consumes.

Data model and editing: [[DevOps Config Data Model and Changesets]]. Shipped policies and exporters, roles and APIs: [[DevOps Config Reference]]. Product status: preparing for deprecation.

## Snapshots

Application > **Snapshots** tab: per deployable, a list with **Name** (default `<deployable>_<n>`, editable), **Description**, **Published**, **Validation**, **Last validated**, **Created**, **Created by**, **Changeset**, **Tags**.

| Validation status | Meaning |
|---|---|
| Not validated | no policy has run |
| Requested / In progress | the validation flow has started / policies are running |
| Passed | all policies passed |
| Failed | at least one policy returned a failure |
| Execution error | a policy did not finish, mostly because it did not use `CdmPolicyUtil` to report |
| (decision) Compliant with exception | passed thanks to an active policy exception |

- **Publish** / **Unpublish** (roles `sn_cdm.cdm_editor`, `sn_cdm.cdm_admin`): exporters only run on published snapshots and by default take the most recently created published one. The deployable must be connected to a service to publish. A deployable can be set so only validated snapshots can be published or exported (**Restrict export** / **Enforce Compliance**).
- Do not re-validate snapshots that are already validated and published; to try out a policy use the test playground (results are flagged as test).
- **Compare**: tab **Config data changes** on a snapshot compares it with an older snapshot of the same deployable (Added, Deleted, Edited; *Changes only*; script view). The Config Data Analyzer also compares snapshots or changesets across applications (compare type Snapshot or Changeset).
- Deleting an application sets it to Deleted, disconnects it from the SDLC component and its deployables from CMDB services; querying its snapshots then returns an error. A deployable's environment type cannot be changed afterwards.

## Policies (PaCE)

1. **Admin** view > **Policies**: pick a shipped policy or **New** (name, category, description). A policy **version must be published and the policy activated** before it can run. Shipped policies cannot be changed, only copied.
2. **Map** the policy to deployables (roles `cdm_policy_editor`, `cdm_editor`, `cdm_admin`):

| Mapping | How |
|---|---|
| Static | application **Policies** tab > **Manage static mappings > Add**: choose a deployable and any number of policies |
| Dynamic | a condition on CDM Deployable (`sn_cdm_deployable`), for example Environment is Production, associated with policies; evaluated at run time, so it covers deployables across applications |

Mapped policy columns: **Policy name**, **Input** (configurable settings), **Dynamic mapping**, **Condition**, **Category**, **Input status** (whether the mapping inputs are still valid; they become invalid if the policy version is archived or deleted; this is not the validation result), **State** (only active mappings run), **Tags**. **View mapped policies** shows both kinds per deployable.

3. **Validate**: choose *Validate snapshots* when committing, or **Validate** on a snapshot, or the REST API. All statically and dynamically mapped policies run. In a pipeline the result comes back as JSON and the pipeline decides whether to continue.

### Results

Snapshot > **Validation results**: a card per policy (failures, warnings, dynamic mapping) and a list with **Description**, **Type** (Information, Failure, Warning), **Policy**, **Impacted data** (the CDI), **Path**. Per policy: **Execution record** (policy, version, end time, **Decision**: Compliant, Non-compliant, Execution error, Compliant with exception), **Open policy**, **Open business condition**.

Fixing: in a changeset the **Validation failures** panel lists snapshots with errors, warnings or execution failures; a card opens the editor on the offending CDI. Mark each as Unresolved, Resolved or Ignored (the marks belong to that changeset), then commit and validate again.

Deciding what a failure means is left to the pipeline, for example: deploy to Test whatever the result; stop Production on any error; stop Production on warnings only for critical applications.

### Writing policies

- Retrieve data with script include `CdmQuery` (with secrets, so nothing is missed), never with GlideRecord.
- Report with the global script include `CdmPolicyUtil`, called as `CdmPolicyUtil.method(...)` (no `new`): `addFailure(output, cdmNode, name, description)`, `addWarning(...)`, `getLastCreatedSnapshotIds(additionalDeployables)`, `getLastPublishedSnapshotIds(additionalDeployables)`. Inserting results by hand gives Execution error. Any failure makes the decision `non_compliant`.
- Use mapping input parameters instead of hard-coded names or values; do not read data outside CDM (cross-scope problems); no always-compliant or always-non-compliant policies; remove debug logging before publishing.

## Exporters

**Admin** view > **Exporters** (roles `cdm_exporter_editor`, `cdm_editor`, `cdm_admin`; `cdm_viewer` can export snapshots without encrypted data, `cdm_secrets` is needed otherwise).

- Content pack exporters have **Source** = ServiceNow: usable and copyable, not editable or deletable.
- Only **published and active** exporters run in a pipeline.
- **Test playground** on the **Exporter builder** tab: *Deployable and published snapshot to export*, **Input arguments**, **Output format**, **Additional deployables** (latest published snapshots) > **Evaluate** > review output. **Generate sample API** gives invocation code in several languages.
- Custom exporter: **New** creates *Draft 0.1*; copy a script from an existing exporter; **Input arguments** tab defines arguments (**Default value**, **Mandatory**); test, **Publish**, activate.
- **Executions** tab: **Number**, **Version**, **Type** (Test or Standard), **Executed by**, start and duration, **State**, application, deployable, snapshot. Records are kept three years (Table Cleanup record for `sn_cdm_exporter_execution`, **Age** in seconds, minimum one year: see [[Table Cleaner]]).
- An exporter with a standard execution cannot be deleted, only **Archived** (cannot run, publish or be renamed; its name cannot be reused; restore by setting **State** = Active and publishing a version). Draft versions can always be deleted.
- Export limits follow the CDI limits (10,000 per deployable, 100,000 per application).

## Component libraries (shared components)

A component that several applications need is kept once in a **component library** and used from there.

- Workspace > component libraries icon: unified view with the list (All libraries, Editable libraries, search, **Create new library**), a library form (tabs Details with the applications using it, Components, Config data, Activity, and Requests when any are open) and a shared component form (Details, Config data, **Versions**).
- Create (role `cdm_admin`): **Library name** (unique across applications and libraries), **Description**, **Authoring groups** (be a member, or hold `cdm_all_app_access`). A new library is **Not Available**; switch **Available** on when ready. An unavailable library cannot be used, updated or exported, but applications already using its components are unaffected.
- Add a shared component: **Edit** (changeset) > **Create shared component** > add CDIs or file nodes > **Commit**, optionally *Publish latest version*. **Only one version is published at a time.** Rename and delete only while unused. A library can be deleted only when no application uses any of its components.
- In an application changeset, the shared components pane has tabs **Available** (published component in an available library; **Add**), **In use** (remove with X: removal, not deletion) and **Updates** (**Update** to take the newer published version; the commit dialog also warns). A shared component cannot be edited or renamed inside the application, but a collection can override its values.
- **Request** to promote a local component (roles `cdm_editor`, `cdm_admin`): shared components pane > **+ Create request** (**Component**, **Target library**, description, details). The last committed data is sent **without secret values, referenced variables and file attachments**. The library owner sees a Requests label and **Accepts** (optionally renaming and publishing) or **Rejects** with a reason. One request per component and library at a time; pending requests can be updated or withdrawn.

## Investigating an alert caused by a config change

Roles `cdm_viewer` and `evt_mgmt_user`. In Service Operations Workspace open the alert; if a change request on the same CI deployed a snapshot, open that change's **Config changes** tab:

- **Investigate configuration changes**: application, deployable, snapshot, and a **Snapshot deployment timeline** showing the alert, the target snapshot and the five most recent deployments (date range and zoom adjustable).
- **Reference snapshot** defaults to the one deployed just before the target; pick any earlier one and **Compare**.
- **Configuration changes**: node tree annotated added / deleted / edited, **Diff only**, filters on change type and key, script view with `+`, `-` and edit marks. A value that changed from text to array shows as a delete plus an add.

## Insights dashboard

Performance Analytics widgets, filterable by application, deployable and date: **Open changesets** (aim for 0: commit or discard so they do not go stale), **Failed snapshots** (aim for 0), **Policy exception and recommended actions** (do nothing or withdraw if resolved; fix before expiry; or extend the exception).

## Related

- [[DevOps Config Data Model and Changesets]] · [[DevOps Config Reference]] · [[DevOps Config Pipeline Integration]] · [[DevOps Change Velocity and DevOps Config]]
