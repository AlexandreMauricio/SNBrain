---
type: concept
tags: [concept, change, workspace, automation, ai, reporting]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Digital Product Release" (pp. 2262-2293: overview, workflow, personas, key terms, workspace, release processes, multi-product releases, restricted access, release states, AI release notes, dashboards, holiday schedules, flow actions, GRC integration, Service Operations Workspace; pp. 2338-2340: release bundles; pp. 2384-2386: risk score), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Digital Product Release

**In one line:** Digital Product Release (DPR, `sn_dpr`) plans and runs releases of digital products and services: scope by product enhancements, phases with tasks, approvals and policy gates from a template, and a readiness target date on a release calendar.

**Where:** **Workspaces > Digital Product Release Workspace**. Not the classic [[Release Management]] application (a migration utility exists). Setup: [[Digital Product Release Configuration and Templates]]. Day-to-day: [[Working a Digital Product Release]]. Lookup: [[Digital Product Release Reference]].

## Life cycle

1. Create a product or service; add features, product enhancements and versions.
2. Plan scope: move enhancements into releases.
3. Initiate a release with a template and a release readiness target.
4. Execute: work through phases and their tasks.
5. Validate each phase against its mapped policies.
6. Be ready by the target date (readiness, not the deployment date).

| Persona | Does |
|---|---|
| Release manager / release admin | calendars, templates, policies, the release process |
| Release coordinator or program manager | dependencies, scope approval, status |
| Product manager | products, features, enhancements, scope, starts releases, release notes |
| Engineering lead | links development work to a release |

## Terms

| Term | Meaning |
|---|---|
| Release | everything planned for one version of a product or service, split into phases |
| Release template | blueprint of phases, tasks, approvals, key dates and policies |
| Release readiness target ("release target") | the date a release must be ready; lives on a release calendar; single or recurring |
| Release calendar | targets, releases and change requests, plus exclusion schedules (blackout, maintenance, others) |
| Approval definition | who approves a task (user or group) and when it counts as approved |
| Included products | child products of a product, forming a hierarchy |
| Release bundle | several independent releases tracked together |
| Out-of-band release | a release on a date without an existing target; a target is created for it |

## Two processes

| | Timeline-oriented | Stage-oriented |
|---|---|---|
| Fits | fixed deadlines | finishing objectives regardless of dates |
| Phase start | on the planned start date | manually |
| Phase end | automatically on the planned end date when all tasks are complete and policies compliant | automatically when tasks are complete and policies compliant or compliant with exception (property `sn_dpr.stage_workflow_auto_transition`) |
| Going back | no | **Restart phase** from any completed phase: that phase and later ones, with their tasks, approvals and policy status, are reset |
| Target date | required | optional (property `sn_dpr.mandate_release_target`) |

Only one phase is in progress at a time. Tasks open one after another by order when `sn_dpr.sequential_task_execution` is true (approval tasks go to Requested), otherwise all at phase start. When all phases are complete the release goes to Review (`sn_dpr.auto_transition_release_to_review`), then Completed (`sn_dpr.auto_transition_release_to_completed`, or **Complete release**).

### Release states

| State | Meaning |
|---|---|
| Draft | template or readiness target missing; finish from Release planning or the Releases list |
| Pending | set up; a scheduled job starts it on the planned start date |
| In Progress | moving through phases |
| On Hold | paused: banner shown, **Complete phase** and automatic progression blocked; task updates, edits, CI and change association and policy runs still work |
| Review | all phases complete, awaiting final review |
| Completed | closed |
| Cancelled | discontinued |

## Multi-product releases

A main release for the primary product with a child release per included product. Phases and readiness are managed on the main release; scope, approvals and policies per product. (A bundle, by contrast, only *watches* independent releases.)

- A child cannot complete a phase ahead of the main release; the main release cannot advance until every child reached its current phase.
- **Add a product** (release Pending or In Progress): a child release is created from the template. In an in-progress release the new child starts at the first phase and its policies run phase by phase until it catches up or one fails; then it stays there as *Non Compliant - policy execution failed* until fixed or forced with **Complete phase**. The main phase cannot close until it catches up.
- **Remove a product** (included products only, one at a time): the child release is cancelled with a reason, its open phases and tasks cancelled, its policy mappings deactivated.
- **Policy status** of the main release is the lowest across products, in the order In progress, Not run, Non-compliant, Compliant with exception, Compliant.

Policy run statuses: Not run, In progress, Compliant, Non-compliant, Compliant with exception.

## Restricted access

On a product (**Release settings > Product team > Restrict access to product releases**) the product owner names users and groups (only holders of `sn_dpr_model.release_user`). Each new release copies the flag and the team as its *release team* (**Restricted access for releases enabled**, **Release team** on the release's Details tab); the release owner or product owner can change it; administrators can override. Users outside the team cannot see the release or its records. In a multi-product release the main release's team applies to every child (child fields read-only), and adding a product adds its team to the main one.

## Release bundles

Releases icon > **Bundles > New** (name, owner, description) > add releases (not Draft ones). A release can be in several bundles. Tabs: **Overview** (releases by state, tasks, policies, approvals, enhancements), **Details**, **Releases**, **Change requests**.

Bundle state: Draft (empty), Ready (all Pending or Draft), In Progress (any In Progress, Review or Restarting, or a mix of Draft and Completed), Completed (all Completed or Cancelled; **Active** becomes false).

## Dashboards

Landing page: active releases, open approvals, policy compliance, for releases where you are owner or team member (items of cancelled or superseded phases are not counted). Release admins also see an **Onboarding** section.

| Dashboard | Shows |
|---|---|
| Release overview | start, end and target dates; **Risk score**; release tasks, change requests, policies, approvals, enhancements, work items, related tasks by state |
| Multi-product (View by **All products**) | the same totals across all child releases; per product when one is selected |
| Quality (tab; product releases in progress only) | by **Build** (pipeline executions of the last 30 days), **Artifact** (versions of the last 30 days) or **Package** (latest, or the release candidate): vulnerabilities, overall coverage, bug count, code smells; unit, functional and performance test results. Needs pipelines connected through the DevOps tool integrations ([[DevOps Change Velocity and DevOps Config]]) |

### Risk score

Calculated for the phase in progress each time the overview is opened; 0 for completed or cancelled releases.

- **Timeline-oriented**: `Round((overdue task score × overdue weight + policy failure score × policy failure weight) × days elapsed ÷ total days)`, the two weights summing to 1. Each score is 0 (under 10% overdue or failed), 1 (10-40%) or 2 (over 40%). A task without an end date uses the phase end. Levels: Low 0-1, Medium 2, High 3-4. (The page also says the score ranges 0-100, which does not fit this formula.)
- **Stage-oriented**: `Round((0.3 × work risk + 0.4 × policy risk + 0.1 × stage progress risk + 0.2 × time pressure risk) × 100)`; without a readiness date the weights are 0.5, 0.4, 0.1. Work risk = 1 − closed tasks ÷ total (0 with zero or one task); policy risk = non-compliant ÷ completed executions; stage progress risk = max(0, 1 − closed ratio ÷ 0.2); time pressure = 1 − days remaining ÷ 14 (1 once the date has passed).

## Holiday schedules

A timeline release can carry an *Excluded*-type schedule from Schedule (`cmn_schedule`). Phase durations then count working days: dates are computed backwards from the readiness target, skipping non-working days, so the calendar span grows while durations stay fixed; a key date landing on a non-working day moves to the previous working day. The guide's example: phases of 10, 25, 15 and 10 working days ending on a Friday target stretch to 87 calendar days once weekends and three public holidays are skipped.

## AI release notes

Skill *Generate Release Notes* (Otto for ITSM `sn_itsm_gen_ai` 12.0.0+, DPR 2.3+; [[Otto for ITSM Skills and Agentic Workflows]]). Available once the readiness phase is in progress or completed. Built from the release scope (enhancements and work items, incidents, problems, requests) into an *Executive summary* and a *Scope of work*. Draft is editable rich text; **Save**, **Regenerate**, **Publish** (read-only), **Download** (PDF), **Copy link**, **Edit**. Notes can also be written by hand.

## Integrations

- **GRC: Policy and Compliance Management** (`sn_compliance` 21.1.3+, DPR 2.3+): the compliance manager maps a control objective to PaCE policies (only exception-enabled ones); running those policies in a release creates controls with the results; a failed policy can get an exception (reason, dates, justification) approved by the compliance group, after which the next run reports *Compliant with exception*. Seeing the PaCE tabs needs `sn_dpr_model.release_user` and `sn_compliance_ws.corporate_compliance_manager`.
- **Service Operations Workspace** (DPR 2.4+, SOW 9.0.0+; [[Service Operations Workspace for ITSM]]): a **Releases** list (Open releases, My releases, All releases, Release bundles) with release execution for holders of DPR roles; on a change, a **Related release** side panel card (owner, target and release dates, current phase, attached phase, policy status, state; **Assign** when none) and import of affected CIs from release phases (asynchronous for large sets).
- **Workflow Studio actions**: Create release, Create out-of-band release, Apply release template, Apply template for out-of-band releases, Add product to multi-product release.

## Related

- [[Digital Product Release Configuration and Templates]] · [[Working a Digital Product Release]] · [[Digital Product Release Reference]] · [[Release Management]] · [[ITSM Application Suite Overview]]
