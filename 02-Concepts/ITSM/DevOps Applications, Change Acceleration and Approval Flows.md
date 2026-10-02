---
type: concept
tags: [concept, change, flows, automation, integrations]
status: documented
source: ServiceNow Australia IT Service Management PDF, "DevOps Change Velocity" > applications, accelerating the change process, approval flows and policies, customizing flows, automating change creation, manual DevOps changes, category property, data retrieval errors and callback timeout (pp. 1312-1347), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# DevOps Applications, Change Acceleration and Approval Flows

**In one line:** how a DevOps application groups tool objects, and how a pipeline-created change request is decided (manually or by policy) and reported back to the pipeline.

Setup and step fields: [[DevOps Change Velocity Setup and Onboarding]]. Artifacts, commits and closure: [[DevOps Artifacts, Packages, Commits and Pipeline UI]].

## Applications

A DevOps application (`sn_devops_app`) groups plans, repositories and pipelines so their data is tracked and linked (commits to work items, and so on). It is required for traceability, pipeline modelling, change governance and metrics.

| Created from | Result |
|---|---|
| New name | new DevOps application + new application model + new SDLC component in the CMDB with the same name |
| Existing application model | DevOps application named after the model; the model's SDLC component is linked, or created if missing |

With DevOps Config installed the application is also linked to a CDM application (`sn_cdm_application`); the CSDM application model is the link between the DevOps products.

- Create: workspace **Create an application** (roles `sn_devops.admin` or `sn_devops.app_owner`): name, **Business app**, optional **Maintained by** groups, then associate pipelines (and assign services to steps), plans and repositories, then import up to 90 days of history. Classic: **DevOps > Apps & Pipelines > Create App (legacy)** or catalog item *Create DevOps Application*.
- Access with **Maintained by** set: App Owners and Administrators in the groups edit; other DevOps roles view; DevOps users outside the groups cannot see the application. DevOps admins always see everything.
- Active applications are polled daily for their plans, repositories and pipelines. Fields: **Business app**, **State**, **Log Level**.
- Property *Enable automatic association of repos to apps on pipeline execution*: a repository whose commits show up in an application's pipeline is associated automatically, and unassigned pipelines of an associated repository follow it.
- Historical import of plans is not supported for GitHub Issues.

## Change control process

1. A step with change control creates the change (category DevOps). With an assignment group it goes to **Assess** to ask for approval.
2. Approved (by a person or a policy) → **Implement**; the pipeline resumes and the job runs.
3. Job finished → the change is closed with close code *successful*, or *unsuccessful* on error.
4. Not approved (rejected, cancelled) → the job is marked failed and the console says so (Jenkins: "Job was not approved for execution"; GitHub: "Change has been created but the change is either rejected or cancelled"; Azure DevOps: `"changeState":"Closed"`).

**Change receipt**: the change is created with all pipeline data, the pipeline does not pause, and the change moves to the post-implement states by itself. Property `sn_devops.enable_change_receipt_state_transition` = false stops that automatic transition.

Active changes: **DevOps > Orchestrate > Pipeline Change Requests** (workspace **Changes > Pipeline change requests**).

## Approval flows

Keep **exactly one** DevOps flow active. A flow applies to changes with category DevOps (or flagged as DevOps change), created automatically, without change receipt. Each flow sets the step execution state from the change, which triggers the callback to the pipeline:

| Change | Step execution | Change state after | Pipeline |
|---|---|---|---|
| approved | approved | Implement | resumed |
| rejected | rejected | New | terminated |
| cancelled | canceled by user | Canceled | cancelled |

| Flow | Behaviour |
|---|---|
| *DevOps Change Request Manual Approval Flow* (active by default) | waits for the change to be rejected, cancelled or implemented (model-based: one of the model's implementation states or the implement state in the DevOps property). Does not run for the shipped *DevOps* and *DevOps Simplified* models |
| *DevOps Change Request Minimal Automation Approval Flow* | gathers DevOps data and runs the minimal policy: auto-approve, auto-reject or manual. For type or model Normal. Optional action *DevOps - Update Minimal Automation Policy Decision Reason* writes the reason to the step execution change comment and the change work notes |
| *DevOps Change Request Advanced Automation Approval Flow* | runs the advanced policy. On approval the change goes to **Scheduled**, and at the planned start date to Implement; then the pipeline resumes |
| *DevOps Demo Change Automation flow* (demo data) | policies *DevOps Low Risk Auto Approval* (failed tests = 0) and *DevOps High risk manual approval* (failed tests > 0) |

An error raised by a business rule or data policy while a flow updates the change is written to the change work notes and the pipeline console.

### Customising

Copy the flow (**More Actions > Copy flow**, application *DevOps Data Model*), change it, **Test**, **Activate**, and deactivate the others. The action that must be called once the change is decided:

| Flow | Action | From a script (server-side) |
|---|---|---|
| Manual | *Update state of step execution based on change approval* (this triggers the *Change Control Callback* flow) | `sn_fd.FlowAPI.executeAction('sn_devops.update_state_of_step_execution_based_on_change_approval', inputs)` |
| Minimal | *DevOps - Update Step Execution and Change Request States* | `sn_fd.FlowAPI.executeAction('sn_devops.devOps-_update_step_execution_and_change_request', inputs)` |
| Advanced | *Update step execution record* | `sn_fd.FlowAPI.executeAction('sn_devops.update_step_execution_record', inputs)` |

## Change approval policies

Shipped: *DevOps Model Change Policy*, *DevOps Change Request Minimal Automation Policy*, *DevOps Change Request Advanced Automation Policy* (decision tables; edit or add your own). Inputs come from work items, commits, pull requests, test, security and quality summaries. Outcomes: auto approval (conditions met), auto reject, manual approval (with notifications to the approvers). Applied with the *Apply Change Approval Policy* action: see [[Change Approval Policies]]. The guide shows the default conditions only as images, so they are not recorded here.

Work notes written (fixed text + policy name + action label): "Change Approval Policy not found. Change Request has been rejected", "... is inactive. Change Request has been rejected", "No Decisions matched. ... has been skipped", "No approvals were generated from matched Decisions. ... has been skipped", "Change Request has been rejected by ...", "Change Request has been approved by ...".

**DevOps Risk Condition**: risk and impact from the committer risk score; inactive by default.

## Where change field values come from

Sources: the step record, the *Default Change Handler* subflow, an approval flow, a template, model presets, or attributes passed in the pipeline.

- **Default Change Handler subflow** fills **Requested by**, **Justification**, **Implementation Plan**, **Backout plan**, **Test Plan**, **Short Description**, **Description**, **Start Date**, **End Date**, **Risk Impact Analysis**, and **overrides template values**. Replace it through property `sn_devops.change_request_handler_subflow`.
- Templates: do not set **Category** or the change type in the template.
- If business rules depend on the values at insert, set `sn_devops.change_request.apply_attributes_on_creation` = true so pipeline attributes are applied when the change is created, not afterwards.
- Implementation details from the tool are added to **Work notes** (up to 5 KB of the step's log).

Related lists on an automatic change: Commits, Work Items, Artifact Versions (of the package linked to the pipeline execution; empty without a package), Test Summaries, Software Quality Summary, Security Summaries.

### Custom states

Properties *DevOps change request implement state*, *post implement state*, *cancel state*, *approval text*. To use your own state: add a choice (for example DevOps_Implement = 10), add it to script include `ChangeRequestStateHandlerSNC` (the guide says to add it there, although SNC includes are normally not edited: see [[Service Builder]] for the general rule), then put the value in the property.

## Automate change creation (workspace wizard)

Roles `sn_devops.admin`, `sn_devops.tool_owner` or `sn_devops.app_owner`. Home > **Automate change creation**: application → pipeline (the tool's connection state is shown) → step → change attributes and **Change receipt** (can be skipped to manage attributes in the pipeline; change receipt can only be set here) → the wizard shows the snippet to add to the pipeline for that tool.

## Manual change with DevOps data

Workspace: application > **Create manual change**, **Category** = DevOps, **Add DevOps data**. Classic: **Change > Create New > Create Normal Change**, category DevOps (or Other with **DevOps Change** selected), button **Add DevOps Data**.

- **Data type**: Artifact version, Release version or Build number (several artifact versions or builds allowed; build number also needs application, pipeline and build; searchable by branch).
- Verify the tabs Work Items, Commits, Pull Requests, Test Summaries, Artifact Versions, Software Quality Summaries, Security Scan Summaries.
- **Edit DevOps data** later; not possible in Implement, Post-Implement or Cancelled.

## Changes not categorised as DevOps

Property *Categorize DevOps changes requests on "DevOps change" field* (off by default; scope DevOps Data Model): pipeline changes are then recognised by the DevOps change flag whatever their category, so category-specific templates (Hardware, Software, Database) can be used. **DevOps Insights is disabled when it is on.**

## Data retrieval errors

Supported for Azure DevOps, GitHub Actions, GitLab, Jenkins and Harness. Property *Enable change request creation even with errors in DevOps data retrieval*:

| Value | When work items, commits, tests or security data cannot be retrieved |
|---|---|
| off (default, also after upgrade) | the pipeline is aborted; the reason goes to the inbound event's **Processing details** and the tool console |
| on | the change is created with what could be retrieved; the reason goes to the console, the step execution's **Change Comments** and the change work notes. Policy input `is_change_with_partial_data` = true forces a **manual** decision (action *Is change with partial data* in subflow *DevOps Gather Change Policy Data*). The stage card is yellow in the Pipeline UI |

Exceptions: when a release pipeline's events are processed before the build pipeline's, the change may be created with incomplete build data yet `is_change_with_partial_data` stays false. A failing Azure DevOps artifact package step is not reported anywhere.

## Callback timeout

Property `sn_devops.change_request_callback_timeout` (default 120 minutes, minimum 60): if an inbound event stays waiting longer, the pipeline is aborted and the reason logged in the tool console and the step execution's callback record. With the GitHub, GitLab or Harness change actions (which poll at their own `interval`), if a step notification never reached ServiceNow the change is never created and ServiceNow cannot say why in the console: the pipeline ends on the tool's own timeout.

## Related

- [[DevOps Change Velocity and DevOps Config]] · [[DevOps Change Models]] · [[Change Approval Policies]] · [[Change Models and Change Templates]]
