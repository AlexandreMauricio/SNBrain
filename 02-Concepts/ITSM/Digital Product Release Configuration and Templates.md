---
type: concept
tags: [concept, change, workspace, automation, admin, instance-admin]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Digital Product Release" > "Configuring Digital Product Release" (pp. 2293-2306: onboarding, installation, migration from Release Management v2, external tools, release calendar, release readiness targets, approval definitions, policies, release templates, custom template fields; pp. 2308-2309: product-level release settings; pp. 2376-2380: approval definition and readiness target forms), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Digital Product Release Configuration and Templates

**In one line:** what a release admin (`sn_dpr_model.release_admin`) sets up before anyone can run a release in [[Digital Product Release]]: tools, calendars, readiness targets, approval definitions, policies and templates.

Order: install → connect external tools → release calendar → release readiness targets → approval definitions → policies → release templates. The workspace home page shows an **Onboarding** section to admins.

## Install

Application `sn_dpr` (role admin; optional demo data). Brings: Global Ranking (`com.snc.sdlc.ranking`); Digital Product Release Data Model (`sn_dpr_model`), Workspace (`sn_dpr_workspace`), Policy Content Pack, Release Timeline Component; Policy as Code Engine (`sn_pace`, `sn_pace_builder`); CMDB CI Class Models; Roadmap and Playbook components; DevOps (`sn_devops`, `sn_devops_ws`, `sn_devops_ints`).

**Migration from Release Management v2** (admin; other roles via property `sn_dpr_model.rmv2.migration_roles`; KB1644412): copies `rm_product` records into Application Product Models and can build a release template from the phases and tasks of an existing v2 release. Define custom field mappings and post-processing first; run from the `rm_product` list or as a script in the `sn_dpr_model` scope.

## External tools

Workspace tools icon > **Connect a tool** > category, tool, name > guided setup. These are the DevOps Change Velocity integrations ([[DevOps Change Velocity and DevOps Config]]). They feed work items (epics, stories), the data collectors behind policies, and the Quality dashboard.

## Release calendar

Roles `sn_dpr_model.release_calendar_admin` or release admin. Calendar icon > actions > **Create release calendar**: **Name**, **Release admin**, **Description**, **Exclusion schedules** (blackout and maintenance schedules from `cmn_schedule`; an *Others* category appears when property `sn_dpr.release_calendar_exclusions` holds an encoded query on that table).

The calendar shows targets, releases and change requests, colour-coded, filterable by type and by exclusion schedule, in week or month view and any time zone; a side panel lists the day's events.

## Release readiness targets

On a calendar, **Create release target**: **Name** (may repeat on different days), **Release admin**, **Description**, **Date** or **Recurring** (repeat, start, recurrence, end), **Schedules excluded from target** (from the calendar). **Next** lists dates that collide with exclusion schedules: tick **Opt-in** to create those anyway (unticked by default). The date cannot be changed once a release is attached. A job deletes unused targets older than six months.

To see what is planned for a target: open it from the calendar, list or agenda view > tab **Releases**.

## Approval definitions

Roles product manager, release coordinator or release admin. Release administration icon > **Approval definitions > New**:

| Field | Options |
|---|---|
| **Name**, **Active** | only active ones can be chosen on tasks |
| **Approver source** | *Approval Definition* (a fixed user or group), *Digital Product* (a user field on the Application Model), *Release Task* (a user field on the task, or on the release by dot-walking), *Service* (a user field on the Service Model) |
| **Approval action** | user or group |
| **User field** / **Group field** | which field supplies the approver, for example Manager of the task assignee |
| **Wait for** | All responses, First response, or Percentage of users (with **Percentage**) |

## Policies

Written with Policy as Code Engine (PaCE). Policy administration icon > **New** (created inactive with a draft version) > tab **Version** > draft > **Policy Builder** (variables, config parameters, record references, data collectors) > **Test Playground** > **Save** (or **Save as template**) > **Publish**, optionally **Activate this policy**. With GRC installed, **Enable exceptions** adds an **Exceptions** tab. Shipped policies and data collectors: [[Digital Product Release Reference]]. Shipped policies cannot be edited, only copied.

## Release templates

Roles `sn_dpr_model.release_template_admin` or release admin. Release administration > **Release templates > New**: name, description, **Type**, **Enable release to validate product versions** > **Create**. A playbook then walks through activities; each is locked with **Mark as done**.

| Activity | What to define |
|---|---|
| Release Process | timeline-oriented or stage-oriented (cannot be changed afterwards) |
| Phases | name, description, **Duration** in days (timeline only; total at most `sn_dpr.max_template_duration`, default 730); order; **Release readiness target phase** (its end date is the target date); default **Schedule** of type Excluded (timeline only) |
| Tasks (per phase) | **Task name**, **Need approval** and **Approval definition**, extra fields with default values (from Release Task `sn_dpr_model_release_task`), attached files; **Reorder tasks** sets the execution order |
| Key dates (timeline only) | **Type**, description, days from the start or before the end of a phase |
| Policies (per phase) | **Map policies** |

Then publish (or later with **Publish template**). On the template record: **Edit release template** (makes it inactive while edited), **Clone template**, **Delete**.

Custom fields added to template tasks are copied to release tasks but only show in the workspace after adding them to the form view *DPR Release Task* (`dpr_rel_task_view`) of `sn_dpr_model_release_task`: a one-time form layout change.

## Product-level release settings

Roles release admin or product manager. Products and services icon > product > **Release settings** (stored in `sn_dpr_model_product_settings`):

| Setting | Effect |
|---|---|
| Release readiness dates | allow out-of-band releases for this product (shown when `sn_dpr.out_of_band_release_allowed` is true) |
| Release calendars, Release templates | the only ones offered when creating a release |
| Change models | change models (those with *Available in Create New*) and active standard change templates offered for the release's changes ([[Change Models and Change Templates]]) |
| CI classes | classes offered when adding configuration items |
| Product team | restricted access ([[Digital Product Release]]) |

Left empty, everything is offered.

## Related

- [[Digital Product Release]] · [[Working a Digital Product Release]] · [[Digital Product Release Reference]]
