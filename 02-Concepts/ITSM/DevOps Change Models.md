---
type: concept
tags: [concept, change, flows, automation, integrations, script-include]
status: documented
source: ServiceNow Australia IT Service Management PDF, "DevOps Change Velocity" > DevOps change models, pipeline migration to change models, DevOpsChangeRelationshipHelper, pull and merge requests, change request attributes and precedence, import based evidence collection (pp. 1374-1397), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# DevOps Change Models

**In one line:** pipeline-created changes can follow a change model (the shipped *DevOps* and *DevOps Simplified*, or any other) instead of the Normal / Standard / Emergency types; a property decides which of the two worlds is allowed, and that in turn decides which flows approve the change and call the pipeline back.

General change models: [[Change Models and Change Templates]]. Type-based flows: [[DevOps Applications, Change Acceleration and Approval Flows]].

The DevOps and DevOps Simplified models are **not supported for Argo CD and Split** changes.

## Model or type: property `com.snc.change_management.change_model.type_compatibility`

Default false on new (or zbooted) instances: model-based only. On upgraded instances it is true, so existing type-based behaviour continues and the **Change model** field merely appears on the Step form.

| Step in ServiceNow | Passed in the pipeline | Property true | Property false |
|---|---|---|---|
| a change model | nothing | model-based change | model-based change |
| a change model | a type (`"attributes":{"type":"normal"}`) | type-based change | **error**: type compatibility is disabled |
| model 1 | another model (`"attributes":{"chg_model":{"name":"Model 2"}}`) | based on Model 2 | based on Model 2 |
| a change type only | nothing | type-based change | **error**: neither type nor model configured for the pipeline |
| a change type | a model | model-based change | model-based change |
| a change type | another type | based on the passed type | **error** |

The model can be passed by name or sys_id (`chg_model`).

## The shipped models

Both active by default, **Implementation states** = Implement, record preset Type = Normal.

| Model | States |
|---|---|
| DevOps | New, Assess, Authorize, Scheduled, Implement, Review, Closed, Canceled |
| DevOps Simplified | New, Authorize, Scheduled, Implement, Review, Closed, Canceled |

Flows, one per state:

| Flow | Does |
|---|---|
| *Change - DevOps - New* | with an assignment group, moves the change to Assess |
| *Change - DevOps - Assess* | actions *DevOps Gather Change Policy Data* and *Apply Change Approval Policy* (policy *DevOps Model Change Policy*): approved → Authorize; rejected → email to the requester and back to New |
| *Change - DevOps - Authorize* | same two actions, but the policy conditions are not met here, so no second approval: just moves to Scheduled. Customise the policy if a second approval is wanted |
| *Change - DevOps - Schedule* | at the planned start date, moves to Implement |
| *Change - DevOps - Implement* | runs in Implement |
| *Change - DevOps Simplified - New / Authorize / Schedule / Implement* | same idea; the approval happens in **Authorize** with the *DevOps Simplified Model Change Policy* (approved → Scheduled) |

Policy inputs: `regression_tests_failed`, `code_security`, `code_coverage`, `total_num_of_commits`, `tests_passing_percent`, `load_tests_failed`, `num_of_open_incidents`, `num_of_current_outages`, `change_request`, `risk` (the DevOps model also `is_change_with_partial_data`). Outcomes: auto approve, auto reject, manual.

The guide contradicts itself on the default: it says both policies ship with **only the manual approval decision active**, and also that using the DevOps model as is means approval "is automated by default". Check the active decisions of the policy on the instance before relying on either.

## Record presets and where values come from

A value set in the model's **record preset cannot be overridden from the pipeline**. Otherwise the pipeline value wins, then the Step form.

Full precedence:

| Change | Type-based | Model-based |
|---|---|---|
| Standard | 1 pipeline attributes; 2 Step record; 3 template passed in the pipeline; 4 template on the Step | 1 **model presets**; 2 pipeline attributes; then the same as type-based |
| Other | 1 pipeline attributes; 2 Default Change Handler subflow and approval flows; 3 Step record; 4 template passed in the pipeline; 5 template on the Step | 1 **model presets**; 2 pipeline attributes; 3 handler subflow and approval flows; 4 Step record; 5 and 6 templates |

- Do not set the same attribute in both the Default Change Handler subflow and an approval flow: they can run at the same time.
- Timing matters more than the list suggests: a value passed in the change step is applied at creation and can then be overwritten when the handler subflow runs; a value passed with the pipeline's *Update* function is applied after approval and so replaces the subflow's.
- Other ways to set attributes: `PUT /devops/orchestration/changeInfo/{changeInfo}` (does not work while the pipeline is paused or waiting; test thoroughly).
- With business rules that need values at insert: `sn_devops.change_request.apply_attributes_on_creation` = true.

## Callback to the pipeline

Flow *Change – DevOps – Update execution state* waits for the implementation state, sets the step execution to approved, rejected or canceled, and that triggers *Change Control Callback*.

Which state counts:

1. the model's **Implementation states** (if several, the first one reached);
2. if none is set, a model state called Implement;
3. otherwise property `sn_devops.change_request.implement_state` (default -1 = Implement).

## Moving existing pipelines to a model

Catalog item *DevOps Pipeline Migration to Change Models* (inactive by default; activate it under **Maintain Items**, fill *Available For* and *Approve By*, or activate catalog flow *Request for pipeline migration* and adjust its *Ask For Approval* action). Form: **Tool**, **Pipeline**, **Change model**. It sets the model on every step of the chosen pipelines. Roles `sn_change_read` and `sn_devops.viewer`. A data policy that blocks the update is reported in the request's work notes; the requester gets a comment, bell and email either way.

## Pull and merge requests under change control

| Pipeline | Code source | Switch |
|---|---|---|
| Jenkins | GitHub, Bitbucket (multibranch project) | plugin option **Pull Request Pipeline Tracking Check** |
| GitHub Actions | GitHub | repository **Actions > General > Workflow permissions**: *Allow GitHub Actions to create and approve pull requests* |
| Azure DevOps | Azure Repos | DevOps property *Enable to track Azure DevOps Code Pull-Requests* = Yes (configured projects) |

Running the pull request pipeline creates the change; once it is approved, merge is enabled in the tool. The change's **Pull Requests** related list shows id, commits, origin and destination branch, raised by, approver, comments and the raised, approved and merged times. Limitation: pull requests from Bitbucket built by Jenkins are not shown on the change. GitLab merge requests: [[DevOps GitLab Integration]].

## Reading a change's DevOps data in a script

Script include `sn_devops.DevOpsChangeRelationshipHelper` (server-side; callable from a business rule, UI action, flow script or scripted REST API; role `sn_devops.viewer`):

```javascript
// server-side, any scope with access to sn_devops
var helper = new sn_devops.DevOpsChangeRelationshipHelper();
var chg = new GlideRecord('change_request');
chg.addQuery('number', 'CHG0000001');
chg.query();
if (chg.next()) {
    var commits = helper.getChangeRelationData(chg, sn_devops.DevOpsCommonConstants.COMMIT_TABLE);
}
```

Returns an array of related sys_ids (empty when nothing is found). Relation types on `DevOpsCommonConstants`: `COMMIT_TABLE`, `DEVOPS_WORK_ITEM`, `DEVOPS_TEST_SUMMARY_TABLE`, `DEVOPS_SECURITY_SCAN_SUMMARY_TABLE`, `DEVOPS_ARTIFACT_VERSION_TABLE`, `DEVOPS_SOFTWARE_QUALITY_SUMMARY_TABLE`, `DEVOPS_PULL_REQUEST_TABLE`.

## Import based evidence collection

Property toggle *Import based evidence collection for orchestration capability* (off after upgrade). When on, step-level events are ignored (processing detail "IGNORED: This event is ignored because...") and the evidence is fetched with an **import request** when the change step fires, and again at pipeline completion. Less load on the instance; approval behaviour is unchanged.

- When the change step fires: a callback record (state created, change evidence status pending) and an import request with pages.
- Azure DevOps build pipelines, GitHub Actions and Jenkins: only the completion event is processed. Azure DevOps **release** pipelines still use step-level events. GitLab: the Pipeline events webhook only.
- Not supported: GitHub environment-based change, GitLab manual jobs, Jenkins freestyle. GitHub deployment gates need the GitHub App.
- **Switch it only when no pipeline is running**: a running pipeline can hang and time out, and a change already created must be cancelled by hand.
- Needs the latest Jenkins plugin.

## Related

- [[DevOps Applications, Change Acceleration and Approval Flows]] · [[Change Models and Change Templates]] · [[Change Approval Policies]] · [[DevOps Change Velocity and DevOps Config]]
