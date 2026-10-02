---
type: reference
tags: [reference, change, admin, workspace, reporting]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Change Management", topics "Change Management plugins" and "Installed with..." (pp. 556-588), "Legacy Add a state to the state model" (pp. 654-658), "Mobile experience for Change Management" (pp. 715-717), "Legacy Change Management Platform Analytics Solutions" (pp. 717-730), "Change Management troubleshooting properties" (pp. 730-731), "Manage the workspace configuration for a Change request in Service Operations Workspace" (pp. 731-735), "Agentic AI in change management" (pp. 735-736), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Change Management plugins, tables and workspace configuration

**What it is:** the reference material of the Change chapter that does not belong to one process note: which plugin brings which tables, the logging properties, the legacy dashboards, and how the Service Operations Workspace change page is configured.

## Plugins and what they install

| Plugin | Brings |
|---|---|
| Core `com.snc.change_management` | types Normal / Standard / Emergency (renames Comprehensive → Normal, Routine → Standard); adds **Manual Proposed Change** (`manual_proposed_change`) to `task_ci` |
| State Model `com.snc.change_management.state_model` | state labels and transitions. The guide warns it does not work as expected if Core is installed separately first |
| Collision Detector `com.snc.change.collision` | `conflict`, `cmn_schedule_blackout`, `cmn_schedule_maintenance`, `cmn_schedule_condition` |
| Risk Calculator `com.snc.bestpractice.change_risk` (active by default) | `risk_conditions` |
| Risk Assessment `com.snc.change_management.risk_assessment` | activates Assessment Components `com.snc.assessment` and Assessment Designer `com.glide.assessment_designer` |
| Standard Change Catalog `com.snc.change_management.standard_change_catalog` | `std_change_proposal`, `std_change_template`, `std_change_record_producer`, `std_change_producer_version` (template version, with counts and percentages of successful and unsuccessful changes), `std_change_properties`; adds the template version to `change_request` |
| Change Schedule `com.snc.change_management.soc` (+ `.soc.foundation`, six sample schedules) | `chg_soc_definition`, `chg_soc_definition_child`, `chg_soc_style_rule`, `chg_soc_definition_style_rule`, `chg_soc_def_child_style_rule` (all extend `chg_soc_style_rule_core`); script includes `SoC*` / `SoC*SNC` |
| CAB Workbench `com.snc.change_management.cab` | `cab_definition`, `cab_meeting`, `cab_agenda_item`, `cab_attendee`, `cab_runtime_state`, each extending a generic `mtg_*` parent (`mtg_definition`, `mtg_meeting`, `mtg_agenda_item`, `mtg_runtime_state`); needs Service Portal |
| Approval policy `com.sn_chg_pol_appr` | `chg_policy_approval` (extends Change Policy) |
| Mass Update CI `com.snc.change_management.mass_update_ci` (inactive by default) | field **Mass Update CI Class** (`is_bulk`) on `change_request`; activates Bulk CI Changes `com.snc.bestpractice.bulkchange` |
| Change Success Score `com.snc.change_management.change_success_score` (+ `.foundation`) | `chg_success_score_rating`; jobs *Change success score metrics (Daily)* at 02:00 UTC, *Change success score for today*, and two *(Historical data)* jobs that recompute the last 30 days (run them after changing multipliers) |
| Success Probability `com.snc.change_management.success_probability` | probability definitions and risk lookup |
| Predictive Intelligence Core `com.snc.change_management.ml` (role maint; requested through Now Support) | `chg_ml_prop`, `chg_ml_prop_solution`, `chg_ml_similarity_boosters` |
| Risk Intelligence `com.snc.change_management.ml.risk` | `chg_ml_prop_risk`, `chg_ml_prop_risk_solution_cat`, `chg_ml_prop_risk_solution_sim` |
| Standard Change Template Intelligence `com.snc.change_management.ml.sctp` | `chg_ml_prop_sctp`, `chg_ml_prop_sctp_solution`, `std_change_template_candidate` |
| Change Model Foundation Data `com.snc.change_management.change_model.foundation` | shipped models and change flows |
| ATF tests `com.snc.change_management.atf` | |
| Data archiving `com.glide.auxdb` | |
| Dashboards | `com.snc.pa.change`, Process Optimization `com.sn_process_optimization` |

Script includes ending in `SNC` are read-only base classes; customise the extension without the suffix (an edited `SNC` include stops receiving upgrades).

## Logging properties (`sys_properties`)

| Property | Default |
|---|---|
| `change.conflict.log` | notice |
| `com.snc.change_management.cab.log` | info |
| `com.snc.change_management.core.log` | warn |
| `com.snc.change_management.policy.approval.log` | debug detail for the approval policy activity |

## Legacy script-based state model (pre-model instances)

Adding a state means: a new choice on **State** (unused numeric value); in `ChangeRequestStateHandler` a constant and an entry in the `STATE_NAMES` map (number → name); in `ChangeRequestStateModel_<type>` the state object with `nextState` and per-target `canMove` / `moving` functions; a UI action copied from *Implement* whose condition calls `new ChangeRequestStateHandler(current).isNext('<state>')` (`canMoveTo` also runs the `canMove` checks); a **System UI > Process Flow** record for the formatter; and the workflow of that type. Server-side script includes and a client-callable `ChangeRequestStateHandlerAjax`, global scope. Prefer [[Change Models and Change Templates]].

## Service Operations Workspace change page

**Change > Workspace Configuration**:

| Record | Purpose |
|---|---|
| **Overview Container** | which layout applies: **Condition** (typically per state or model), **First to match order** (lowest wins), **Display action bar** (activity stream bar at the bottom) |
| **Overview Card** | cards in a container: **Display order**, **Expanded**, **Display for new record**, **Heading**; reusable across containers |
| **Overview Journal Field** | which of Work notes / Additional comments a card shows |

Fields on the cards come from the form view **SOW-Change-Overview** (**Configure > Form Layout**, role `personalize_form`).

## Mobile

Plugin `com.sn_itsm_mobile`, app *ServiceNow Agent*: **My Work > Change tasks** (view, comment, reassign, swipe to **Close task**), push notifications, approve or reject changes and requested items.

## Legacy dashboards (deprecated since Xanadu)

Change Premium, Change Management, Open Changes Reports, Open Changes State Monitor, Age of Open Changes Monitor, Change Velocity; replaced by the Platform Analytics *Change Management dashboard*. Useful indicator definitions: change backlog growth = new − closed; % of urgent changes; average implementation time of closed changes (Implement → closed); number of unsuccessful changes (close code Unsuccessful); overdue = state New/Assess/Authorize/Scheduled with planned start in the past.

## Agentic workflows for change

Assess conflicts for a change request; Assess quality of a change request (against similar closed changes or policy documents); Explain SLA; Schedule a change; Suggest configuration items; Create outages; Create standard change request; Create standard change template proposal. See [[Otto for ITSM Skills and Agentic Workflows]].

## Related

- [[Change Management Overview and Lifecycle]] · [[change_request]] · [[Service Operations Workspace for ITSM]]
