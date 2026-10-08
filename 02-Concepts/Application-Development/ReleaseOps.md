---
type: concept
tags: [concept, platform, update-sets, automation, instance-admin, roles, ai, change, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Deploying applications (chapter introduction) and ReleaseOps (whole section, 1,267 cleaned lines, read in full 2026-10-08 through the docs site) - Exploring (overview, users, workflow, pipelines, releases, deployment requests, deployment analyzer, runbook tasks, release lifecycle documentation AI agent), Configuring (install, guided setup, manual setup, multi-instance management, custom pipeline, instances, ATF code coverage threshold, AI agent and its roles), Using (promote an update set, deployment requests for scheduled and on-demand releases, attach an update set, create a release, runbook task, reconcile a deployment task, generate release notes and update set descriptions), Reference (glossary, deployment request states, release states, both forms, deployment analyzer rules). https://www.servicenow.com/docs/r/application-development/releaseops/releaseops-landing.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# ReleaseOps

**In one line:** a Store application that moves update sets (and application installs) from development through test to production automatically: developers bundle update sets into **deployment requests**, an *assessment playbook* tests each request, and a **release** carries all the ready requests to the target instance on its date.

From the Brazil docs. The update sets it moves: [[Update Sets]]. Used with App Engine pipelines: [[AEMC Pipelines and Deployments]]. Playbooks: [[Playbooks Overview and Components]].

- Not supported in regulated environments or on-premise; check entitlement.
- Everything is run from the **production instance** (the *controller*): the playbooks execute there and reach the other instances through multi-instance management, so no credentials are set up per instance pair ([[Otto for Setup and Multi-Instance Trust]]).

## The objects

| Object | What it is |
|---|---|
| **Pipeline** | two playbooks: an **assessment playbook** (per deployment request, through sub-production) and a **release playbook** (all ready requests to the target). Also the map from instance labels used in the playbooks (such as *Test*) to real instances, and optionally ATF suites every request must pass |
| **Release** | what goes to the destination and when. *Scheduled* (many deployment requests, freeze date, release date) or *on-demand* (created automatically for exactly one request, deployed as soon as it is ready). Several release tracks can coexist (weekly, daily), but **only one release deploys to a target at a time**. Can be tied to a change request |
| **Deployment request** | a unit of work: one or more update sets or application installs, with the source instance. Attached to a release, or to a pipeline when the release does not exist yet (so assessment can start early) |
| **Deployment request update set** | the mapping row between the two; visible, not meant to be edited |
| **Deployment task** | created when assessment or deployment finds a problem (ATF failure, low coverage, preview conflict); must be resolved for the request to continue |
| **Runbook task** | a planned pause: an activity added to one deployment request that stops the playbook before or after a chosen stage until it is resolved (application install or update, XML data import, manual action, scheduled-job script, update set commit). Replaces the deployment spreadsheet without changing the playbook |
| **Deployment analyzer** | a playbook activity that compares the request's update sets with the target and evaluates rules; the playbook branches on the results |

Sample playbooks (duplicate them; never edit the samples, so upgrades keep delivering new features):

| Playbook | Stage | Does |
|---|---|---|
| Deployment request assessment | assessment, scheduled | moves the update sets to test, runs the ATF suites of the request and of the pipeline |
| On-demand deployment request assessment | assessment, on-demand | deployment analyzer and Instance Scan with sample rules decide whether the on-demand deployment is allowed; **no ATF** |
| Release deployment | release, both types | prepares the release: defers requests that are not ready, computes update set order, deploys |

People: pipeline manager (pipelines, playbooks), release manager (releases, removes requests that do not belong), developer (deployment requests), tester (signs off ATF failures or sends back).

## Flow

1. Release manager creates a release on a pipeline and activates it.
2. Developer completes an update set and promotes it into a deployment request (new or existing, **Draft**).
3. Developer selects **Ready to assess**: assessment starts at once (update sets move to test, ATF, instance scan, analyzer, runbook tasks of that stage).
4. Findings become deployment tasks (**Reconciling**); when all have an outcome the request is reassessed, until **Ready for Deployment** (locked).
5. At the **freeze date** the release goes to *Preparing*: requests not ready are **deferred** (removed; attach them to a later release, which puts them back in Draft); update sets are ordered **in the order they were deployed on the previous instance**.
6. At the **release date** the release playbook moves everything to the destination; release and requests become *Complete*.

### Deployment request states

| State | Meaning |
|---|---|
| Draft | the only state in which update sets can be added |
| Ready for Assessment | trigger of the assessment playbook |
| Assessing | tests, scans and playbook checks running; update sets moving from development to test |
| Reconciling | open deployment tasks |
| Ready for Deployment | locked: a change now means cancelling the request. On-demand: deploys immediately; scheduled: waits for the release |
| Deploying; Complete | |
| Failed | needs manual intervention before it can be resubmitted |
| Cancelled | |

### Release states

| State | Meaning |
|---|---|
| Draft | ignored by ReleaseOps whatever its dates; not selectable on deployment requests |
| Active | open until the freeze time; requests can be added or removed |
| Preparing | frozen; requests validated or deferred; order generated; only a release administrator can remove a request |
| Ready for Release | nothing can be added or removed; manual playbook steps done |
| Deploying | started by the scheduler at the release time (or the change request's time) |
| Reconciling | a request hit a problem, for example a preview conflict: a deployment task exists |
| Complete; Cancelled | |
| Failed | typically: an update set could not be retrieved; one was already retrieved and committed out of order; one was committed unexpectedly after retrieval |

### Resolving a deployment task

**ReleaseOps > Deployment tasks** > open > choose the outcome > **Resolve**.

| Outcome | Effect |
|---|---|
| Needs code changes | request back to Draft |
| Rerun tests | request back to Assessing, immediately |
| Sign off | an authorised person accepts the exception; request becomes Ready for Deployment |

## Deployment analyzer

| Default rule | Rule set | Match | Detects |
|---|---|---|---|
| Has Code Change | Default | Any | any script change |
| Has Security ACL Roles | Security | Any | new or changed roles |
| Has Security ACLs | Security | Any | new or changed ACLs |
| Only Catalog Item Changes | Default | All | the update sets contain only records of specific catalog tables |
| Schema Change | Default | Any | new columns, only on tables with more than 10,000 rows |

*Any* = combined with other rules as OR; *All* = matches only if no other rule matches. New rule types, definitions and rules appear automatically as playbook conditions.

**ATF code coverage:** below **70%** coverage of the request's code, the request goes to Reconciling with a test failure task ([[ATF Test Suites, Schedules and Administration]]). Change it in *your* assessment playbook: Workflow Studio > the playbook > activity **Check test results** > *Branches* > *low code coverage* > **Modify condition** > the number.

## Setting up

1. **Install** ReleaseOps from the Store on **every** instance (role admin). The test instance also needs *ATF Test Generator and Cloud Runner*.
2. **Guided setup** (ReleaseOps 1.2.1+): **ReleaseOps > ReleaseOps Guided Setup** on the controller: select the instances (the controller and at least one of type *Test*) and check each **Instance type**; add them as managed instances and approve each request on the instance itself (**Approve Manager Instance**, admin); review the generated deployment instances; create or verify the **remote instance** (update source) records, with **Test connection**; set the controller property on development.
3. Or **manual setup**, on production unless stated:
   - **Multi-Instance Management > Managed Instances > Add managed instances**; on development and test approve under **Manager Instances** (role admin or `sn_mif.mif_admin`).
   - **ReleaseOps > Deployment Instances**: one record per instance (**Instance**, **Instance type**).
   - **ReleaseOps > Pipelines** > each sample pipeline > *Pipeline instances* > **New**: the test deployment instance, **Label** *Test*. Only intermediate instances are mapped: the source comes from the deployment request and the destination from the release.
   - **System Update Sets > Update Sources**: production needs valid sources for development and test; test needs one for development.
   - On **development**: property `sn_releaseops.deployment_controller` = URL of the production (controller) instance.

Because the label is the link between playbook and instance, one playbook serves several pipelines with different instances; one pipeline can take several development sources and release to several destinations.

### Custom pipeline

Duplicate a sample playbook in Workflow Studio, add stages or decisions, **Activate**; then **ReleaseOps > Pipelines > New**: name, **Assessment playbook**, **Release playbook** (custom or sample), save, and add the *Test* pipeline instance. The analyzer belongs before *Move to test*; nothing should come after *Ready for deploy*. Use custom playbooks for steps that happen every time and runbook tasks for the variable ones.

The docs' example (skip ATF when there is no code change): add a stage with the **Run Deployment Analyzer** activity (input: *Parent Record - Deployment Request*); in *Run ATF Tests*, after *Transition to Assessing*, add a decision with a branch *Skip Tests* on `Deployment Analyzer > Outputs > Has Code Change` is false, connected to the junction after *Create Test Failure Task*; the default branch stays on *Run ATF Tests for Deployment*.

## Using it

| Task | Steps |
|---|---|
| Promote an update set | development: **System Update Sets > Local Update Sets** > the set > **State** Complete, save > **Promote update set** (shown only when complete). You land on the *Deploy an update set* form on production |
| New request, scheduled | tick **Create new deployment request**: **Short description**; **Assignment group** or **Assigned to** (one is required); **Source environment**; a **Release** (must be active) or a **Pipeline**; optional **ATF suites** (from production; the pipeline may add more) > **Submit** > when finished **Ready to assess** |
| New request, on-demand | the same, with **On demand** ticked; optional **Pipeline** (default: the base on-demand pipeline) |
| Add to an existing request | on the same form choose the **Deployment request** (Draft ones only) |
| Create a release | **ReleaseOps > Releases > New**: **Destination environment**, **Pipeline** (editable only in Draft), descriptions, **Freeze date**, **Release date** (taken from the change request when one is linked) > **Activate release** |
| Runbook task | deployment request > *Deployment request tasks* > **New**: **Pipeline stage** (assessment or release), **Playbook stage**, **Wait for runbook activity** (before or after the stage), **Short description** |

Other form fields: release **Release type**, **Change request**, **Release window** (system-set), **Configuration item** (no effect on behaviour); request **Destination environment** (used for Code Diff and for on-demand), **Deferred**.

## Example

A weekly release *Example Weekly Release* targets production with a freeze on Thursday and release on Friday. A developer completes update set *Example Feature* on development, promotes it into a new deployment request assigned to *Example Group* and selects **Ready to assess**. ATF coverage comes back at 55%: a test failure task appears; the tester chooses *Sign off*. On Thursday the request is Ready for Deployment and stays in the release; another request still Reconciling is deferred. On Friday both the release and the request end *Complete*.

## Release lifecycle documentation AI agent

Writes **update set descriptions** and **release notes**. Inactive by default: install ServiceNow Otto for Creator, then **AI Agent Studio > AI Agents** > the agent > *Select channels and status* > active ([[Otto for Creator and Otto for App Engine]]). Each generation is one assist against the Now Assist subscription.

| Action | Where | Conditions |
|---|---|---|
| **Generate description** | on an update set record | local: In progress or Complete; retrieved: Loaded or Reviewed; never the default update set |
| **Generate release notes** | on a release record | release must be *Complete*. Versions are kept on the *Release notes* tab and can be edited; **Regenerate** also from AEMC's *Release management* tab |

Roles: `update_set_admin` and `sn_aia.viewer`; `sn_releaseops.release_notes_user` for release notes (included in the ReleaseOps admin role).

## Discrepancies in the docs

- Role names are written inconsistently: `sn_releaseops.releaseops_pipeline_admin` and `releaseops.pipeline_admin`; "developer or release_admin" beside `sn_releaseops.releaseops_developer` and `sn_releaseops.releaseops_tester`; `sn_releaseops.release_notes_user` beside `release_notes.admin`. The exact role names are unconfirmed (?).
- The state is called *Ready for Assessment* in the state table and the button *Ready to assess*; the release state is *Ready for Release* in the reference and *Ready for deployment* in the overview.
- No table names are given anywhere in the section.

## Related

- [[Update Sets]] · [[AEMC Pipelines and Deployments]] · [[App Engine Management Center]] · [[ServiceNow Studio Source Control, Fluent Apps and Deployment]] · [[Instance Scan]] · [[Change Management Overview and Lifecycle]] · [[Application Development Good Practices - Plan, Build, Validate, Deploy]]
