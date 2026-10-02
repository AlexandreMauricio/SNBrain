---
type: concept
tags: [concept, change, task, flows, cmdb]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Change Management" (pp. 544-773), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Change Management overview and lifecycle

**In one line:** a change request ([[change_request]]) moves through states defined by its **type** or **model**; approvals are generated in Assess and Authorize, the work happens in Implement through change tasks, and Review closes it with a close code.

## Types

| Type | Pre-approved | CAB | States |
|---|---|---|---|
| Standard | yes (from a template in the standard change catalog) | no | New → Scheduled → Implement → Review → Closed |
| Normal | no | yes | New → Assess → Authorize → Scheduled → Implement → Review → Closed |
| Emergency | no | yes (straight to it) | New → Authorize → Scheduled → Implement → Review → Closed |

Canceled is reachable from any state up to Implement, **not** from Review or Closed. State values are in [[change_request]].

Since Quebec, types are implemented as **change models**: see [[Change Models and Change Templates]].

## Creating

- **Change > Create New**: the landing page shows **Models**, **Preapproved**, **Pinned**, **All** tabs.
- From an incident or problem: **Create Normal / Standard / Emergency Change**.
- **Copy Change** (not for standard changes); see properties below.
- From a CI list: list action **Add to new / existing Change Request** (business services go to Impacted Services, the rest to Affected CIs).
- Standard: **Change > Standard Change > Standard Change Catalog** ([[Standard Change Catalog]]).
- Automatically: **unauthorized change** (below).

## Processing

| Action | Effect |
|---|---|
| **Request Approval** | Normal → Assess (approvals for the assignment group); Emergency → Authorize; Standard → Scheduled |
| Approve / Reject (approver, **Self-Service > My Approvals**) | next state / back to New |
| **Revert to New** (context menu) | Normal from Assess, Emergency from Authorize: restarts the flow and cancels pending approvals |
| **Implement** | state Implement; creates tasks *Implement* and *Post-implementation testing* |
| **Review** | state Review; open flow-created tasks are canceled |
| **Close** | needs **Close code** and **Close notes**; all tasks must be closed or canceled |
| **Cancel Change** (context menu) | asks a reason, written to work notes |

Default normal flow logic: in Assess anyone in the assignment group can approve; in Authorize, Risk Moderate/High goes to CAB, Risk Low goes to the group manager (skipped if that manager already approved in Assess).

Field editability narrows with the state: everything in New; read-only after authorization; in Implement and Review only activity and closure fields.

Approvers with only `approval_user` do not see the change itself, only a summary on the approval record.

## On hold

**On hold** + **On hold reason**: pending approvals become *No Longer Required* and are re-requested when the hold is removed; the only possible transition is Canceled; active [[change_task]] records follow.

## CIs on a change

- **Configuration item** (primary), **Affected CIs** (`task_ci`, addable only in New), **Impacted Services/CIs** (`task_cmdb_ci_service`), **Service Offerings**.
- **Refresh Impacted Services** runs manually, when leaving New, and after conflict detection.
- A dynamic CI group as the CI fills Affected CIs with its members.
- Multiple-CI association is enabled per table by `com.snc.task.associate_ci` (default `change_request, incident`).
- **Mass Update CI** (plugin `com.snc.change_management.mass_update_ci`, normal and emergency only): tick **Mass update CI class**, choose a class and proposed field changes, add affected CIs of that class, then **Apply Proposed Changes** in Implement or Review.

## Unauthorized changes

With Service Mapping, an unplanned change detected on a CI that belongs to an application service raises event `ci.change.unplanned`. If **Enable event processing** (`com.snc.change_request.enable_unauthorized`, default false) is on, an **Emergency** change is created with **Unauthorized** ticked, assigned to Change Management. On approval it goes straight to Review and a *Post Implementation Review* task is created. **Change > Administration > Unauthorized Change Properties**: ignore period (default 1 day), query defining what counts as a valid covering change, CI classes monitored. Turn processing off before bulk CI updates.

## Roles

| Role | Does |
|---|---|
| itil | create and work changes |
| `sn_change_read` / `sn_change_write` | granular roles |
| `change_manager` | models, templates, approvals policy, conflict settings |
| `sn_change_admin` | all change configuration (contains write, CAB manager, change manager) |
| `sn_change_cab.cab_manager` | CAB definitions and meetings |
| `sn_chg_soc.change_soc_admin` | change schedules |
| `itil_admin` | blackout/maintenance schedules, risk assessments |

## Flows

Since Yokohama, base flows in Workflow Studio replace the legacy workflows (*Change Request - Normal / Standard / Emergency*): *Change - Normal - Assess / Authorize / Implement*, *Change - Emergency - Authorize / Implement / Review*, *Change - Standard*, *Change - Standard - Implement*, *Change - Standard - Proposal*, *Change - Unauthorized - Authorize / Review*, *Change - Cloud Infrastructure - Authorize*. ITSM spoke actions: **Apply Change Approval Policy**, **Evaluate Change Model**, **Cancel Change Tasks from Flow**, **Check Change for User Approval**, **Disregard change approvals**.

## Key properties (Change > Administration > Change Properties)

| Property | Default | Effect |
|---|---|---|
| `com.snc.change_request.enable_copy` | true | **Copy Change** |
| `com.snc.change_request.copy.attributes` | category, cmdb_ci, priority, risk, impact, type, assignment_group, assigned_to, short_description, description, change_plan, backout_plan, test_plan | fields copied |
| `com.snc.change_request.copy.related_lists` | task_ci, task_cmdb_ci_service, change_task | lists copied (only these three allowed) |
| `com.snc.change_request.attach.enable_copy` | true | copy attachments |
| `com.snc.change_management.enforce_data_requirements` | true | enforce the form's data rules server-side for every update path (flow, REST, script) |
| `glide.ui.risk_calculate_rule` | ui_action | risk calculation mode |
| `com.snc.change_request.event.state_updated.enabled` / `.states` | false / empty | raise event `sn_change.state.updated` on state changes |
| `com.snc.task.refresh_impacted_services` | incident, change_request | tables with **Refresh Impacted Services** |
| `com.snc.change_request.auto.discovery` | Off | trigger Discovery on affected CIs (states in `...disco.auto.state` = Review, `...disco.manual.state` = Implement, Review; use the internal value `0` on multi-language instances) |
| `com.snc.change_request.ci_assignment_group.field_name`, `...service_offering_assignment_group.field_name` | (add) | field used by *Populate Assignment Group based on CI/SO* |

## Other

- Notification *Change request state change* goes to **Requested by** on Scheduled, Implement, Review, Canceled.
- Integrations: Hardware Asset Management (**Asset action** on affected CIs: Deploy, Update/Repair, Retire; mandatory before Review), Software Asset Management (license change projection), Discovery.
- Domain separation: **Basic**. Properties are global.
- Customising the legacy state model by script (`ChangeRequestStateHandler`, `ChangeRequestStateModel_<type>` with `canMove` / `moving` functions, interceptor answer, workflow copy) is still documented, but models are the supported path.
- Enhanced security plugin `com.snc.itsm.enhanced_security`: deny-unless ACLs on `change_request` and `change_task`.

## Related

- [[Change Models and Change Templates]] · [[Standard Change Catalog]] · [[Change Approval Policies]] · [[Change Conflict Detection and Maintenance Schedules]] · [[Change Risk Calculation and Assessment]] · [[CAB Workbench]] · [[Change Schedules Timeline]]
- [[change_request]] · [[change_task]]
