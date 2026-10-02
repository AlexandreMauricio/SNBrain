---
type: concept
tags: [concept, users, roles, workspace, ai, domain-separation, admin]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Workforce Optimization for ITSM" (pp. 3873-4075), second half of the chapter (coaching and learning, skills, reference, mobile, landing pages, advanced configuration), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Workforce Optimization Learning, Skills and Reference

**In one line:** the coaching, learning and skills parts of Workforce Optimization for ITSM (WFO), plus the chapter's reference material: roles, domain separation, mobile shift requests, landing pages, filters and group visibility in the Manager Workspace.

Channels, scheduling, demand forecast, work scheduler and teams are in [[Workforce Optimization for ITSM]]. Coaching opportunities and assessments themselves are in [[Coaching]].

## Coaching and learning inside WFO

### Coaching Overview page

Manager Workspace page showing learning tasks, an assessments donut, average quality and skill demand. The quality indicator shown by default comes from property `sn_coaching.coaching_overview_default_quality_indicator` (scope Coaching), a JSON value of the form `{"title": "<indicator title>", "sys_id": "<indicator sys_id>"}`.

Shipped coaching opportunities: *Incident SLA breach*; phone interaction longer than 10 minutes, chat longer than 30 minutes, walk-up longer than 60 minutes. Shipped surveys: *Phone Quality Survey*, *Chat Quality Survey*, *Walk-up Quality Survey*. Assessments can also be created ad hoc from the Assessments icon; surveys are created, published and then assigned.

### Learning content

| Thing | Notes |
|---|---|
| Course catalog (`sn_lc_catalog`) | groups courses; managed by catalog managers |
| Learning library | a set of content with **applicable groups** (who may see it) |
| Internal content (`sn_lc_content`) | type URL, knowledge article, free form or quiz; **Days to complete** default 5 |
| External content (`sn_lc_external_content`) | courses synchronised from a third-party learning system |
| Course item (`sn_lc_course_item`) | a course in a catalog |
| Learning path | ordered set of courses; Draft, then published through the publish flow |
| Learning task (`sn_lc_learning_task`) | one assignment of a course or path to a person: can be **mandatory**, with a **due date** |
| User course activity (`sn_lc_user_course_activity`) | activity log; auto-flushed after 365 days (`sys_auto_flush`) |
| Learning system configuration (`sn_lc_learning_system_configuration`) | one record per connected learning system |

Recommendation groups define which content is suggested to which audience.

### Learning roles

| Role | For |
|---|---|
| `sn_lc.learning_admin` | everything in learning |
| `sn_lc.learning_course_catalog_admin` | course catalogs |
| `sn_lc.catalog_manager`, `sn_lc.catalog_group_manager` | a catalog, or the catalogs of a group |
| `sn_lc.content_writer` | authoring internal content |
| `sn_lc.learning_advisor` | recommending learning |
| `sn_lc.task_creator` | assigning learning tasks |

### Learning properties

| Property | Meaning |
|---|---|
| `sn_coach_lrn.learning_list_menu_props` | JSON defining the list menu over `sn_lc_learning_task`, `sn_lc_catalog`, `sn_lc_course_item`, `sn_lc_content`, `sn_lc_external_content` |
| `sn_coach_lrn.learningpath_detail_viewmore` | items shown before "view more" on a learning path (50) |
| `sn_coach_lrn.sn_lc_enable_discover` | turns the Discover area on |
| `sn_coach_lrn.sn_lc_enable_recommendations` | turns recommendations on |

### Third-party learning integration

Built on the Enterprise Service Management Integrations Framework, with spokes for Cornerstone, Pluralsight, Udemy and ServiceNow University.

- Configure under **Learning > Administration > Learning System Configuration**. Source properties: `page_size`, `full_pull`, `url_prefix`, `pull_offset_hours`.
- Synchronisation is done by flows named *Trigger ... Learning Sync*.
- Set system properties `com.glide.transform.json.max-partial-length` and `com.snc.process_flow.reporting.serialized.val_size_limit` to 1638400 so large payloads are processed.
- User matching can be overridden per source in script include `sn_lc.UserMappingUtil` (server-side, scope Learning), for example function `getCornerstoneUser`.

## Skills

### Skill matrix and skill review

- **Skill matrix** (role `skill_manager`): managers see their agents against skills, **Add** a skill, and **Approve** or **Reject** recommended ones.
- **Skill review**: a manager uses **Generate skill request**; the request moves between agent and manager (state *Pending manager review* and its counterpart for the user).

| Role | Can |
|---|---|
| `sn_wfo_skillreview.manager` | create, read, update, delete skill review requests |
| `sn_wfo_skillreview.user` | create, read, update skill review requests |

Notifications (**System Notifications > Provider > Notifications**; all on by default): *Skill Request Pending Manager Review* (to the manager when the agent submits), *Skill Request Reviewed* (to the agent when the manager has reviewed), *Skill Request Cancel* (to the assignee when either side cancels), *Skill Request Pending User Review* (to the agent when the manager sends a request for the agent to review).

Sample skills come with plugin `com.snc.skills_management.seed_data`.

### Skill determination rules (skills required by a work item)

**All > Skills > Skill Determination Rules**. The business rules *Skill determination for incident* and *Skill determination for interaction* (server-side, on `incident` and `interaction`) apply them to new records. Shipped rules:

| Rule | Table | Type | Condition → required skills |
|---|---|---|---|
| Language Detection Incident | Incident (`incident`) | Advanced | language of **Short description** (`short_description`) → that language |
| Language Detection Interaction | Interaction (`interaction`) | Advanced | same, on the interaction |
| SAP Skills | `incident` | Simple | **Service** starts with SAP → SAP, Backoffice |
| VPN Incident | `incident` | Simple | **Short description** contains VPN → Router and Switch, Network |
| VPN Interaction | `interaction` | Simple | same, on the interaction |
| Windows Incident | `incident` | Simple | **Configuration item** contains Windows → Windows Installation/Setting, Windows Servers |

The simple rules match three spellings (upper, lower, capitalised). Language detection needs the Dynamic Translation API configured.

### Skill recommendation (skill prediction)

Plugin `com.snc.sre`. Uses Predictive Intelligence to predict which skills resolve an incident, and from that which skills an agent appears to have.

| Role | Can | Contains / contained by |
|---|---|---|
| `sn_sre.user` | view the skill recommendation tables | contained by `wfo.user` (as printed in the guide; elsewhere the role is `sn_wfo.user`, exact name unconfirmed) |
| `sn_sre.admin` | edit the properties | the guide lists `wfo.admin` and `sn_sre.user` |

Properties (**Skill Recommendation > Configuration**):

| Property | Meaning | Default |
|---|---|---|
| `sn_sre.enable_skill_recommendation` | recommend skills for agents | true |
| `sn_sre.max_supervised_skills` | most skills predicted per incident by supervised learning, by confidence | 3 |
| `sn_sre.max_unsupervised_skills` | same for unsupervised learning | 3 |
| `sn_sre.number_of_similar_incidents` | resolved similar incidents used for a prediction | 15 |
| `sn_sre.user_predicted_skill_threshold` | times a skill must be predicted for an agent before it is recommended | 20 |
| `sn_sre.unsupervised_solution_definition_for_incidents` | solution definition (replaceable by your own) | `ml_sn_sn_sre_global_recommend_similar_skills_for_incidents` |
| `sn_sre.supervised_solution_definition_for_incidents` | solution definition (replaceable by your own) | `ml_sn_sn_sre_global_recommend_skills_from_similar_incidents` |

The guide's descriptions of the last two are swapped or duplicated (both are called "similarity solution definition"); which is truly supervised is unconfirmed.

- Scheduled job *Start skill prediction*: inactive until switched on; daily at 01:00 over the incidents closed the previous day.
- Tables: User Predicted Skill (`sn_sre_user_predicted_skill`: how often each skill was predicted for a user; entries not recommended in 60 days are deleted) and Task Predicted Skill (`sn_sre_task_predicted_skill`: skills predicted per incident; records older than 60 days are deleted).
- Extension point `sn_sre.SkillPredictionAPI` to change the prediction logic.

## Roles reference

Manager Workspace:

| Role | Grants | Contains |
|---|---|---|
| `sn_wfo_cfg_ws.user` | read access to the workspace | `workspace_user`, `canvas_user` |
| `sn_wfo_cfg_ws.manager` | primary assignment groups and additional managers; home and list modules | `sn_wfo_cfg_ws.user`, `sn_wfo.user`, `sn_wfo_skillreview.manager` |
| `sn_wfo_cfg_ws.admin` | all Manager Workspace applications and settings | `sn_wfo_cfg_ws.manager`, `workspace_admin`, `ui_builder_admin`, `canvas_admin`, `sn_wfo.admin` |

Application:

| Role | Grants | Contains |
|---|---|---|
| `sn_wfo.user` | read primary group and additional managers | `pa_analyst`, `sn_agent_forecast.user`, `approver_user` |
| `sn_wfo.admin` | manage additional managers | `sn_wfo.user`, `pa_analyst`, `sn_agent_forecast.admin` |
| `sn_wfo_cfg_itsm.employee` | read Coaching, Scheduling, Teams | `sn_wfo.user`, `sn_shift_planning.agent`, `sn_coaching.trainee`, `sn_team_perf.team_performance_user`, `awa_agent`, `canvas_user`, `sn_wfo_skillreview.user` |
| `sn_wfo_cfg_itsm.manager` | create, read, update in Coaching, Scheduling, Teams, Channel Management | `sn_wfo_cfg_ws.manager`, itil, `sn_walkup.walkup_manager`, `sn_agent_forecast.user`, `sn_shift_planning.admin`, `sn_coaching.coach`, `sn_team_perf.team_performance_manager`, `sn_channel_mgmt.user`, `sn_sre.user`, `pa_target_admin`, `awa_agent`, `skill_manager`, `sn_wfo_work_sched.manager`, `sn_process_optimization_analyst`, and `sn_cti_core.user_manager` when ServiceNow Voice is integrated |
| `sn_wfo_cfg_itsm.admin` | full rights in those applications | `sn_wfo_cfg_itsm.manager`, `sn_shift_planning.admin`, `sn_coaching.admin`, `sn_team_perf.team_performance_admin`, `sn_agent_forecast.admin`, `sn_sre.admin`, `skill_admin`, `sn_wfo_work_sched.admin` |
| `sn_wfo_cfg_itsm.base_manager` | manager landing page and list module (base system role) | `sn_wfo_cfg_itsm.base_employee`, `sn_sre.user`, `pa_target_admin`, `skill_manager`, `awa_agent`, `sn_wfo_cfg_ws.manager`, `survey_creator` |
| `sn_wfo_cfg_itsm.base_employee` | Service Operations Workspace landing page (base system role) | `canvas_user`, `sn_sow.sow_user`, `sn_wfo.user`, `awa_agent`, itil |

Scheduled job *WFO data collection*: run on demand, collects data for all WFO indicators.

## Domain separation

Support level Basic; no setup needed.

| Area | Separated tables / behaviour |
|---|---|
| Channels | `interaction` (and `sn_customerservice_case`); follows Advanced Work Assignment |
| Scheduling | `sn_shift_planning_agent_schedule`, `_agent_schedule_request`, `_break`, `_day`, `_event`, `_schedule_plan`, `_schedule_shift`, `_schedule_shift_agent`, `_shift_plan`, `_shift_swap_request`. A generated schedule exists only in the agent's domain |
| Teams | `sn_wfo_add_manager`: additional managers see only users in their domain |
| Skill recommendation | `sn_sre_task_predicted_skill`, `sn_sre_user_predicted_skill` |
| Coaching | see [[Coaching]] |

## Global search

Searches users, groups, shifts, schedules and tasks. Shifts and schedules are found only after generating the text index for Schedule (`sn_shift_planning_schedule_plan`) and Shift Plan (`sn_shift_planning_shift_plan`).

## Shift requests in the mobile app

Needs ITSM Mobile Agent 5.0 ([[ITSM Mobile Agent]]). Role `sn_shift_planning.agent` for agents, `sn_wfo_cfg_ws.manager` for managers.

- **Time off**: *Schedule > My calendar* > date > shift > **Request time off** (or swipe left on the shift), with **Title** and **Description**; or *Work shift time-off requests* > menu > **Request time off** with **Start time** and **End time**. The manager is notified.
- **Shift swap**: on the shift, **Request shift swap**, pick **Swap with** (agent) and **Requested shift**. The peer approves or rejects under **Approvals** (or straight from the notification), then the manager.
- **Managers**: *My team > Team Calendar* to see shifts; *My work > Approvals* to approve or reject. An approval updates the calendar.
- With On-Call Scheduling mobile also installed, the Schedule section also shows *My calendar*, *On-call time-off requests* and *Who is on-call* ([[On-Call Scheduling]]).
- How many days of shift events the app shows is a scheduling system property (set by `sn_wfo.admin`; see the Scheduling properties in [[Workforce Optimization for ITSM]]).

Notifications are switched on per user in the desktop UI: **System Settings > Notifications > Allow Notifications**, category **Mobile - Shift Planning**: *Shift-swap approval request*, *Shift-swap approved / rejected by manager*, *Shift-swap approved / rejected by peer*, *Time-off approval request*, *Time off approved*, *Time off rejected*.

## Landing pages

All shipped pages and variants are read-only in UI Builder; duplicate a variant to customise. With several landing pages, the lowest **Order** wins.

| Page | Role | Content |
|---|---|---|
| Manager | `sn_wfo_cfg_ws.manager` | single scores *Open P1 Incidents*, *Incidents not updated in 24 hours*, *Incident SLAs Breached*, *Incident SLAs at Risk*, *Escalations*; indicators Mean time to resolution, First call resolution, Customer satisfaction; lists Team Performance (incidents of the manager's teams) and Unassigned incidents; breakdowns Priority, Category, Assignment Group, Assigned To; team and date range pickers |
| Channels | `sn_channel_mgmt.user` | single scores on `incident`: *Open Critical*, *Unassigned*, *Escalated*, *Updated > 7 days*, *Open for 30 days*; *SLAs breached* on [[task_sla]]; *In-progress chats* and *Help requested* (interactions); *Agent distribution* bar chart on Presence States (`awa_presence_state`); *Waiting work items*; *Available agents*; *Total open incidents* bar chart by state. PA indicator *Incidents closed this week*; breakdowns Assigned to, Assignment group |
| Coaching | `sn_coaching.coach` | indicators CSAT, Quality (average assessment score, percent), Incident Mean Time to Resolve, Completed Assessment; lists *Trainings* (Assigned Training, `sn_coaching_assessment_recommended_learning`) and *Coaching Assessments* (Assessed Record, `sn_coaching_assessed_records`); breakdowns Assigned to, Assignment group |

### Customise a page

Role `workspace_admin` or `ui_builder_admin`. **All > UI Builder** > *Manager Workspace* > pick the page (for example Landing Page or Work Scheduler) > on a variant choose **Duplicate** > **Edit page variant settings** (**Variant name**, optional **Page template**) > **Edit conditions** (**Variant Conditions**, **Order**). A duplicated variant no longer receives updates made to the original.

## Filters in the Manager Workspace

Role `sn_wfo_cfg_ws.admin`. **Workforce Optimization for ITSM > Manager Workspace Configurations > Filter Configurations** > **New**: **Filter Name**, **Table**, **Field**, **Filter Query**, **Type** (Choice or Reference), **Order**, **Workspace Module**, **Active**. The filter then appears in that module's filter panel.

Tables allowed per module:

| Module | Tables / database views |
|---|---|
| Schedule | User (`sys_user`), User Skill (`sys_user_has_skill`), Agent Schedule (`sys_shift_planning_agent_schedule` as printed; probably `sn_shift_planning_agent_schedule`), Schedule Event (`sn_shift_planning_event`), Manager Groups view (`sn_wfo_manager_group`) |
| Coaching | Skill (`cmn_skill`), Skill Category M2M (`cmn_skill_m2m_category`), Group Member (`sys_user_grmember`) |
| Channels | Manager Groups view (`sn_wfo_manager_groups`); filters here are built in around AWA channels and queues and cannot be added or changed |

The guide spells the view both `sn_wfo_manager_group` and `sn_wfo_manager_groups`; the real name is unconfirmed.

## Which groups a manager sees

By default: the groups they manage directly or as additional manager.

- **Add groups**: implement scripted extension point `sn_wfo_common.ApplicableGroupsDefinitionManager` (server-side).
- **Remove groups**: role admin, **Workforce Optimization for ITSM > Manager Workspace Configuration > Group Exclusions** > **New**: a **Name** and filter conditions. As the guide describes it, a condition such as Name does not contain Support leaves out the groups with Support in the name (so the condition selects the groups kept; worth confirming in an instance).
- **Verify**: impersonate the manager, open `sys_user_grmember.list` and filter **Group** *is (dynamic)* *MYWFOGroups*. The result reflects both the exclusions and the extension point.

## Related

- [[Workforce Optimization for ITSM]] · [[Coaching]] · [[ITSM Mobile Agent]] · [[On-Call Scheduling]] · [[ITSM Predictive Intelligence, Task Intelligence and Virtual Agent]]
