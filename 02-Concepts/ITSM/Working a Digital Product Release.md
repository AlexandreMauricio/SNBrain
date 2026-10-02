---
type: concept
tags: [concept, change, workspace, automation, cmdb]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Digital Product Release" > "Using Digital Product Release" (pp. 2307-2357: requesting products and services, included products, creating releases quick and by wizard, features, enhancements, work items, external tool data, release planning board, timeline-oriented and stage-oriented execution for single and multiple products, restart phase, adding and removing products, scope, configuration items, change requests, AI release notes, artifacts, approvals, retargeting, hold, closing, readiness target view; pp. 2380-2383: request, release and key date forms), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Working a Digital Product Release

**In one line:** the product manager's and release coordinator's path through the [[Digital Product Release]] workspace, from requesting a product to closing its release.

Roles: `sn_dpr_model.product_manager`, `sn_dpr_model.release_coordinator` or `sn_dpr_model.release_admin` unless stated. Setup: [[Digital Product Release Configuration and Templates]].

## Products and services

Products and services icon > **Request new**: **Name**, **Owner**, **Configuration item** (types allowed by property `sn_dpr_workspace.cmdb_model_creation.supported_ci_types`: technology management service, business service, service instance, business application), **Type** (product or service), **Short description**.

Flow *DPR Service Catalog Request approval* auto-approves and triggers flow *Request Product* (both editable in Workflow Studio). Products are stored in Application Models (`cmdb_application_product_model`), services in Service Models (`cmdb_service_product_model`); a matching DevOps application is created.

- **Included products** tab: **Add** existing products, **Request new product**, **Remove**. This hierarchy drives multi-product releases.
- **External tools** tab: associate plans, repositories and pipelines (services: plans only), artifact repositories and artifacts. With **Auto-create product versions from plan versions** (one plan record selected), each new Agile Development 2.0 release, Jira fix version or GitLab milestone creates a product version and a release, and its work items appear in the release scope. Mappings: `sn_devops_m2m_plan_version_software_model`, `sn_devops_m2m_work_item_plan_version`.

## Scope

| Item | How |
|---|---|
| Product feature | **Product features > Add feature** (**Feature name**, **Priority**, **Description**); then state, owner, assignment group, attachments; its enhancements on the **Product Enhancements** tab |
| Product enhancement | **Product enhancements > Add enhancement** (**Name**, **Product feature**, **Release**: only Pending releases that validate a version; empty = backlog; **Priority**, **Description**); **Link work items** for the development items behind it |
| Enhancement from a work item | **Add enhancement from work item**: lists work items of the linked project whose type is in `sn_dpr_workspace.enhancement_work_item_types` (default epic) and that have no enhancement yet. Automatic for primary epics when `sn_dpr_workspace.auto_create_product_enhancement_for_primary_epic` is true |

**Release planning** (per product): a board with a backlog lane and one lane per Draft or Pending release that validates a version, newest first. Drag enhancement cards between lanes; order within a lane is priority. Lane menu: **View release**, **Edit release** (draft), **Create release**.

## Create a release

- **Quick create** (lane menu, or the arrow next to **Create release** on the Releases list): **Release name**, **Release validates a new product version**, **Product or service**, **Version**, **Release template**, **Release readiness target**, or **Out of band** with **Release date** and **Release calendar**. Template or target missing → Draft; otherwise Pending.
- **Wizard** (**Create release**): *Release details* (name, owner, description, **Validates product or service version**) → *Version details* (primary product, existing or new version; included products listed, add or remove; limit `sn_dpr.multi_product.included_products_limit`) → *Release template* → *Release target* (calendar, date; a target is created if none exists there). Draft releases reopen in the wizard.

Rules:

- *Validates version* on: only versions not yet validated by another release and only templates with that option; a new version number must be unique. Off: any version, and only templates without the option.
- Several products: property `sn_dpr.multi_product.create_independent_releases` false (default) → one main release with dependent child releases; true → a release bundle of independent releases.
- A timeline template with a schedule recalculates dates on working days; creation fails if a start date would fall in the past (unless `sn_dpr_model.allow_any_release_dates`) or the duration exceeds the maximum.
- Out of band needs `sn_dpr.out_of_band_release_allowed` (or the product setting) and a role listed in `sn_dpr.out_of_band_release_roles`.
- Artifacts associated with the product are added; restricted access and product team are copied.

## Run a release

Open the release > **Start release** (if not started). Sections:

| Section | Use |
|---|---|
| Overview | dashboard and risk score; **Details** tab (name, owner, schedule, attachments); **Quality** tab |
| Release scope | enhancements and work items; **Planning Items** (needs Strategic Planning with the Digital Product lens); related tasks: incidents, problems, requests (types from the related-task-types property) with **Add** / **Remove** |
| Configuration items | **Add** (classes from the product settings, filtered by `sn_dpr.ci_default_query`; placed in the phase given by `sn_dpr.default_phase_for_cis`); a CI once per phase, but in several phases |
| Change requests | **New** (pick a change model, fill the change form) or **Add** existing; attached to the phase given by `sn_dpr.default_phase_for_changes`; the change's **Software model** is set to the release version (cleared on **Remove**). On the change: **Affected CIs > Add CIs from release phases**; header **Attached to phases** |
| Artifacts (number in the header) | **Add artifact**: latest version, or clear **Use latest version** and give a semantic version (major.minor.patch); once per release |
| Release timeline | phases, key dates, activity log; **Complete phase**; stage releases set planned dates per phase and offer **Restart phase** |
| Release tasks | per phase, list or Kanban (lanes from `sn_dpr.release_kanban_lanes`), **My tasks**; **Add task** (name, phase, end date, description, **Need approval** with **Assigned to** and **Approval definition**; cannot be changed after saving) |
| Release policies | **Add** / **Remove** mappings (not on completed or cancelled phases); **Run policies** |
| Release notes | **Add manually** or **Generate** |

- **Policies** run in the background for the phase in progress, on demand and by a daily job; statuses roll up into **Policy status** on the Details tab. Removing an executed policy from a running phase re-runs the rest. With GRC, a failed policy offers **Request exception** (reason, dates, justification).
- **Complete phase** needs all tasks complete and policies compliant; with a non-compliant policy only roles listed in `sn_dpr.complete_phase_override` (default release admin) can force it.
- **Key dates** (timeline): **Add key date**: **Name**, **Type** (Milestone, Key event, Deadline, Important date), **Due date** (future, within the release, not a holiday), **Assigned to**, **Description**.
- **Approvals**: the approver (role `approver_user`) uses **Service Desk > My Approvals**. Approve → task **State** Closed Complete, **Approval** Approved, other group members' approvals No Longer Required. Reject (with comments) → task stays Open, **Approval** Rejected, comments land in the task's activity.
- **Multi-product**: **View by** *All products* (timeline, tasks, policies and changes for all; a task added to a phase is added to every product's release) or one product (its overview, scope, CIs, changes, notes). **Dashboard > Products**: **Add product** (product, version) / **Remove product**. Restarting a phase resets it for every product.

## Change course

| Action | Notes |
|---|---|
| **Retarget release** (release actions) | pick another readiness target (from the product's calendars when configured) or **Out of band** with a calendar. Timeline phases and key dates shift by the difference; change requests' planned dates are **not** updated |
| **Mark on hold** | from Pending or In Progress; a hold reason is asked. Later **Resume release** (back to the previous state) or **Cancel release**. No product can be added while on hold |
| **Cancel release** | release admin only; reason required |
| **Complete release** | from Review. In a multi-product release only with *All products and services* selected |

## Related

- [[Digital Product Release]] · [[Digital Product Release Configuration and Templates]] · [[Digital Product Release Reference]] · [[Change Management Overview and Lifecycle]]
