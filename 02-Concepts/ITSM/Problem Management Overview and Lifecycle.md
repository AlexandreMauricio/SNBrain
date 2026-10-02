---
type: concept
tags: [concept, problem, incident, knowledge]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Problem Management" (pp. 3005-3100), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Problem Management overview and lifecycle

**In one line:** a problem ([[problem]]) records the root cause behind incidents; it moves through guided states from New to Closed, with tasks for analysis, a workaround and fix communicated back to the incidents, and optionally a known error article and a change request.

## States and guided actions

State is **read-only**; buttons move it (state model plugin `com.snc.best_practice.problem.madrid.state_model`, default on new instances since Madrid).

| State | Actions available | Goes to |
|---|---|---|
| New | **Assess** (asks for the mandatory fields in a dialog; a new problem with them already filled goes straight to Assess) | Assess |
| Assess | **Confirm** | Root Cause Analysis |
| Assess / Root Cause Analysis | **Mark Duplicate** (related records move to the original), **Cancel** | Closed (Duplicate / Canceled) |
| Root Cause Analysis | **Fix** | Fix in Progress |
| Root Cause Analysis / Fix in Progress | **Accept Risk** | Closed, or Resolved if `problem.acceptrisk.move_to_closed` is false; code Risk Accepted |
| Fix in Progress | **Resolve** | Resolved (Fix Applied) |
| Resolved | **Complete** | Closed (Fix Applied) |
| Resolved / Closed | **Re-analyze** | Root Cause Analysis |

Problem tasks ([[problem_task]]): New → Assess → Work in Progress → Closed (Complete or Canceled), with **Re-assess**.

Legacy model (instances from before Madrid that have not migrated): Open, Known Error, Pending Change, Closed/Resolved.

## Roles

| Role | Does |
|---|---|
| `problem_task_analyst` | works problem tasks |
| `problem_coordinator` | owns a problem through its life (contains task analyst and itil) |
| `problem_manager` | process owner, settings, can act as coordinator |
| `problem_admin` | plus delete |
| `sn_problem_read` / `sn_problem_write` | granular roles (ITSM Roles plugin) |
| itil | create problems, add incidents, create tasks |

**Assigned to** on a problem is filtered to coordinators, managers and admins.

## Creating

- **Problem > Create New**; **Create Problem** on an incident (copies `com.snc.problem.create_from_incident.attributes`; attachments with `com.snc.problem.create_from_incident.copy_attachments`); record producer; inbound email action; from an interaction (`glide.problem.interaction.allow_create`).
- Automatic on major incident promotion only if the flow *Create Problem from Major incident* is activated (inactive by default).
- **Incidents** related list > **Add** attaches many incidents (extension point `global.MRABulkAddRecordsFilter` filters the picker).
- Priority: data lookup on Impact × Urgency (`dl_problem_priority`); changing it later makes **Work notes** mandatory.
- Assignment: business rule *Populate Assignment Group based on CI/SO* (override properties `com.snc.problem.ci_assignment_group.field_name`, `com.snc.problem.service_offering_assignment_group.field_name`), then [[Assignment Rules and Data Lookup Rules]] (shipped examples: Network Problem, Database Problem by CI class).

## Communicating back to incidents

| Event on the problem | Effect on related incidents |
|---|---|
| **Communicate Workaround** (related link) | incidents not resolved/closed/canceled: workaround copied to work notes (or additional comments, see [[Incident Properties Reference]]); assignee and work notes list notified |
| **Communicate Fix** | fix notes copied to the incidents; assignee notified |
| Problem Resolved/Closed with **Fix Applied** | incidents On Hold / Awaiting Problem become **Resolved**, resolution code *Resolved by problem*; caller and assignee emailed |
| Problem closed **Risk Accepted** | the risk accepted reason is copied to the incidents' work notes; they are not resolved |

## Known errors and knowledge

- **Create Known Error Article** (related link; plugin `com.snc.best_practice.problem.madrid.knowledge`): article in the Known Error knowledge base, table `kb_template_known_error_article`, linked in **Primary Known Error article**; **Publish** sends it through the knowledge base workflow.
- Legacy: **Knowledge** check box (business rule *Problem Create Knowledge* on close), **Post Knowledge**, **Known Errors** module.

## Fixing

- **Create Normal Change** / **Create Emergency Change** from the context menu; **Change Requests** related list > **Add** for existing ones.
- The coordinator is notified when all fix records listed in `problem.fix.records` are completed or canceled. Adding a table there also needs a business rule like *Check Related Problem Fixes - Change Req*.

## Properties (Problem > Administration > Problem Properties)

| Property | Default | Effect |
|---|---|---|
| `problem.acceptrisk.move_to_closed` | true | Accept Risk closes instead of resolving |
| `problem.closed.can_create_tasks` | false | allow new tasks on a closed problem |
| `problem.closed.cancel_open_tasks` | true | cancel open tasks when the problem closes |
| `problem.closed.role.reanalyze_from_canceled` / `_from_closed_riskaccepted` / `_from_completed` | problem_manager (first one) | who may re-analyze |
| `problem_task.closed.role.reaassess_from_closed` | problem_coordinator | who may re-assess a closed task |
| `problem_task.closed.can_reassess_on_closed_problem` | false (new), true (upgrade) | |
| `problem.fix.records` | `change_request.parent, rm_defect.parent, rm_release.parent, rm_enhancement.parent, sn_cim_register.source_id` | records tracked as fixes |
| `problem.duplicate.records_to_move` | `incident.problem_id, sn_customerservice_case.problem, problem_task.problem` | records moved to the original on Mark Duplicate |
| `problem.role.relate_closed_incidents` | coordinators (new), nobody (upgrade) | |
| `com.snc.problem.create_from_incident.attributes` | number, description, short_description, cmdb_ci, impact, urgency, priority, company, sys_domain, business_service, category, subcategory | |
| `com.snc.problem.create_from_interaction.save` | yes (new) | |

## Problem models

Property `com.snc.problem_management.models.enabled` (on for new instances since Yokohama). A model (`prb_model`, **Problem > Administration > Problem Models**) lists **Model States**, each with **Model State Transitions** (From, To, **Automatic transition**) and optional **Transition Conditions** (condition builder or script). **Default problem model** makes it the one used for new problems. Task models (`prb_task_model`) are offered through an **interceptor** answer whose target URL is `problem_task.do?sys_id=-1&sysparm_query=prb_task_model=<sys_id>`. Records created before enabling keep the non-model life cycle. Same idea as [[State Models and State Transitions]].

## Migrating from the legacy states

Store app *Problem Management Migration Utility* (guided setup): resolve blocking modifications, map old states to new (default 1 Open → 101 New, 2 Known Error → 107 Closed/Risk Accepted, 3 Pending Change → 104 Fix in Progress, 4 Closed → 107 Closed/Fix Applied), activate the state model plugin (irreversible), repair base plugins, migrate active then inactive records, then manual clean-up (old modules, UI actions, business rules, dashboard filters using `state = 4` → `active = false`). Practise on a clone first.

## Other

- Assess dialog fields: **System UI > Form Sections**, views *Assess Dialog Form View* / *PTASK Assess Dialog View*.
- SLAs on a whole problem are not recommended; inactivity monitors are.
- Domain separation: Standard. Legacy dashboards deprecated since Xanadu.
- Quick start (ATF) tests: plugin `com.snc.problem.atf`.

## Related

- [[problem]] · [[problem_task]] · [[Incident Management Overview and Lifecycle]]
