---
type: concept
tags: [concept, workspace, users, roles, reporting, admin]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Workforce Optimization for ITSM" (pp. 3873-4075), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Workforce Optimization for ITSM

**In one line:** Workforce Optimization (WFO) gives team managers a **Manager Workspace** to watch queues in real time, plan shifts and schedules, assign work by skill, track team KPIs and coach agents; agents see their side in Service Operations Workspace.

> **Being deprecated.** The guide says WFO for ITSM is being prepared for deprecation "starting with the Brazil release" (hidden, not installed on new instances, still supported), and its Admin Console from Australia. Treat it as legacy on new projects.

Store app *Workforce Optimization for ITSM Configurable Workspace* (`sn_wfo_cfg_itsm`, ITSM Enterprise); installs Team Performance (`sn_team_perf`), Coaching (`sn_coaching`), core `sn_wfo_cfg_ws`, `sn_wfo_common`. Demand Forecast needs MetricBase (`com.snc.clotho`) activated **first** (then `com.sn_agent_forecast` comes with it). Optional: Process Mining (`com.sn_po`), ITSM Virtual Agent (time-off topic), ITSM Mobile Agent.

Menu **Workforce Optimization for ITSM > Manager Workspace**, **> Admin Center**, plus per-module administration.

## Foundation: groups

- A team = an assignment group (`sys_user_group`). Each group needs a **manager**; **additional managers** get visibility without managing.
- Every agent needs a **Primary Assignment Group** on the user record (view *WFO Workspace*); without it the agent cannot see schedules in Service Operations Workspace, and it decides whose calendar, coaching and approvals apply.
- **Admin Center** (role admin): *Manage assignment groups* (**Add groups** marks them type `WFO_ITSM`; managers, members, primary group) and *Define application access* (per application: **Group access**, **Manager access**).
- Roles for the workspace: `sn_wfo_cfg_ws.manager` or `sn_wfo_cfg_itsm.manager`; `sn_wfo_cfg_itsm.admin`; agents `sn_wfo_cfg_itsm.employee`.

## Channels (Channel Management)

Built on Advanced Work Assignment: service channels (`awa_service_channel`), queues (`awa_queue`), assignment rules and eligibility pools.

| Role | Contains |
|---|---|
| `sn_channel_mgmt.user` | `awa_manager` |
| `sn_channel_mgmt.admin` | user, `awa_admin`, `sn_wfo.admin`, `report_admin` |

- Setup (**Channel Management > Service Channels / Queues**): create the assignment rule before the channel; on a queue, *Assignment Eligibility* (rule, **Eligible at**, **Groups**).
- **KPIs** are single-score reports added in the related lists *Reports* (channel, queue) and *Agents Reports*; the five with the lowest **Order** show on the channel card. For your own report, add its table and field to the interactive filter *Channel Management Groups Filter* (or *Agent*, *Queues*, *Service Channel Filter*).
- **Supervisor lists**: up to three per channel, each backed by a database view (**List Title**, **Tab Title**, **View Name**, **Order**). See [[Create a Database View]].
- Manager actions: monitor work items per channel and queue; **Allocate** a pending item to an agent (one at a time; shows presence, capacity such as 0/4, matching skills; the item goes Pending Accept → Accepted, or back to Queued if rejected); join a chat where **Help Requested** is set (**Join Conversation** or **Send Private Message**; list *Conversation Monitoring*); **Capacity Override** for one agent and channel (lasts 12 hours by default; job *Reset Temporary Capacity Override* runs every two minutes); Agent 360 profile (current work, time off, training, skills, presence history).
- Daily email to managers: scheduled job *Send Daily Agents Report* → event `sn_channel_mgmt.agents_report` → notification *Daily Agents Report* → mail script `daily_agents_reports`.
- Extension points: `sn_channel_mgmt.ChannelMgmtExtensionPoint` (sort order of the All Agents and All Queues lists; lowest-order implementation wins), `sn_channel_mgmt.AgentListColumns`, `sn_channel_mgmt.QueueListColumns` (`getColumns`).

| Property (add to `sys_properties` if absent) | Default |
|---|---|
| `sn_channel_mgmt.list_auto_refresh.enable` / `.interval.seconds` | true / 30 |
| `sn_channel_mgmt.kpi_auto_refresh.interval.seconds` | 5 |
| `sn_channel_mgmt.channels_card_auto_refresh.enable`, `sn_channel_mgmt.channel_card_auto_refresh.interval.seconds` | true, 120 |
| `sn_channel_mgmt.filter_config.enable` | true (assignment group filter) |
| `sn_channel_mgmt.awa_agent_temporary_override_time.minutes` | 12 hours |

Shipped reports include unassigned / abandoned / completed interaction work items, average handling time, agents available, breached SLA and open P1 incident work items, average walk-up wait time.

**Voice with Amazon Connect** (Cloud Call Center, `sn_cti_core`; activate AWA first): each Amazon Connect queue is tied to an AWA queue by pasting its ARN into **Cloud Call Center Source ID** (placeholder queues without routing conditions); *Group Queue Priorities* list the groups. Managers can **Monitor Call** on a live interaction and open **Call Analysis** (transcript and sentiment, generated in Amazon Connect; role `sn_cti_core.user_manager`).

## Scheduling (Shift Planning)

| Role | Can |
|---|---|
| `sn_shift_planning.user` | read schedules and shifts |
| `sn_shift_planning.agent` | own calendar, swap and time-off requests |
| `sn_shift_planning.admin` | everything; contains `sn_shift_planning.approver` |

Manager Workspace > **Schedule**:

1. **Shifts** tab: a *work shift* (name, time zone or **Use agent time zone**, start and end, days of week) with **breaks** (duration, earliest start, latest end: breaks are staggered automatically across the agents so coverage holds), or an *on-call shift* (group, times, rotation start date, **Create Rotation** with agents and daily or weekly interval, **Publish**; see [[On-Call Scheduling]]).
2. **Team Calendar** > Schedules panel > **+**: a *schedule plan* (name, start and end date, groups I manage or specific groups), **Add Shift** (shift, event type, **Assign agents**), **Save shift** (state *Generating Preview*), **Publish**.
3. Unpublish to change: a plan already started stays Published with its end date moved to tomorrow; a future one returns to Draft. Removing a group removes its agents from the shifts.

**Shift sign-up**: on the plan tick **Request Agent Signup** and set **Agents must sign-up by**; **Send for signup**; agents rank preferred shifts; **Close sign-up** (or the due date) then **+Add signed up agents**, or **Enabled for auto-assignment** (top preferences, up to `sn_shift_planning.max_shifts_to_autoassign`). States: Sign-up not enabled, Enabled for sign-up, Open for sign-up (nothing can be changed, published or deleted), Closed for sign-up. Notifications need `glide.ui_notification.max_recipients` high enough.

**Events** on the team calendar: Meeting, Training, Time-off, Custom Event, Work (ad hoc shift), Break.

- Event categories (**Scheduling > Event Categories**): **Exclude from coverage**, and an *Event field configuration* JSON describing the create and edit forms (attendees with `allowAllUsers`, start and end dates, description label, `additionalSelectors` for extra reference fields).
- Event types (**Scheduling > Event Types**): **Priority Order** (which overlapping event wins for coverage), colour, **Category**; access per type through *Evaluate access for exclusion / inclusion* user criteria with create, read, write, delete flags. Exclusion beats inclusion; with neither, role-based access applies. The **User access** tab checks the result for groups or people.
- Logic per category: extension point `sn_shift_planning.EventManager` (shipped implementations `AgentScheduleMeetingEventManager`, `...Break...`, `...Training...`, `...TimeOff...`, `...Work...`; server-side script includes).
- Load order on the calendar: property `sn_shift_planning.event_load_order` (JSON `{"fastLoad": ["<event category sys_id>"]}`, scope Shift Planning).

**Approvals**: time-off goes to the manager; a shift swap goes to the other agent, then to the managers of both. Requests by managers are auto-approved. A request not approved **two days before** the start is auto-rejected: the offset is `dueDate.addDaysUTC(-2)` in the *Ask For Approval* due-date script of the *Time-off request* and *Swap request approval* flows (Flow Designer, scope Shift Planning). Managers can swap shifts directly from the team calendar without approval.

**Outlook sync**: Exchange Online spoke with Graph permissions `Calendars.ReadWrite` (delegated and application) and `Calendars.ReadWrite.Shared`; property `sn_wfo_outlook.enable_outlook_sync` = true; user emails in `sys_user`. Custom event types need an extension point to sync.

**Demand Forecast** (role `sn_agent_forecast.user`): the team calendar's *Total coverage/demand* row shows scheduled agents against forecast (for example 24/20); per hour green = exact, yellow = overstaffed, red = understaffed; week view uses arrows and a check mark.

| Property | Default |
|---|---|
| `sn_shift_planning.number_of_days_to_cache` | 5 (after importing schedules by table import or script, run job *Shift Planning - Delete All Agent Schedules Cache*) |
| `sn_shift_planning.max_shifts_to_autoassign`, `sn_shift_planning.max_shifts_allowed_for_signup` | 1, 1 |
| `sn_shift_planning.enable_agent_signup`, `sn_shift_planning.enable_schedule_signup_link` | true, true |
| `sn_shift_planning.days_to_signup_due_date` | 2 |
| `sn_shift_planning.display_shift_name` | true (false shows the event type; takes 24 hours or a cache clear) |
| `sn_uib_agent_sp.allow_agent_edit_break`, `sn_uib_agent_sp.allow_agent_add_remove_break` | false, false |
| `sn_itsm_mobile_agent.events_query_days_past` / `_future` | -31 / 90 |

The agent side is in [[Working Records in Service Operations Workspace]].

### Schedule adherence

Business rule *Agent Time Work Event Trigger* (activate it) writes clock-in and clock-out events from presence changes: Available or Busy = clock in; Break, Offline or logout = clock out. A forgotten clock-out is generated automatically 60 minutes after shift end.

- **Adherence** = minutes worked in shift / (scheduled shift minutes + overtime). **Conformance** = (minutes worked in shift + overtime) / scheduled shift minutes. Example: 8-hour shift (480 min), 30-minute break, 65 minutes overtime → adherence 450 / 545 = 82.57%, conformance 515 / 480 = 107.29%.
- Settings (**Shift Planning > Schedule Adherence > Settings**): enable, early check-in threshold (60 min), adherence threshold (70%), conformance thresholds (80% to 120%), auto clock-out threshold (60 min). Values outside are shown in red.
- Manager views: *Schedule Adherence* tab, team calendar bars (planned shift, available, clock-in, clock-out), lists *Time Worked Summary* and *Time Attendance* (*Available Non Planned Time* = clocked in outside scheduled work).
- Formulas can be replaced through extension point `sn_shift_planning.ScheduleAdherenceExtPt`.
- Job *Shift Planning - Delete All Agent Schedules Cache* clears `sn_shift_planning_agent_availability` daily at 02:30. Page sizes: user preferences `workspace.workShiftsPageSize`, `workspace.onCallShiftsPageSize`, `workspace.schedulePlanPageSize`.

### Demand Forecast setup

Roles `sn_agent_forecast.admin` (contains `clotho_admin`) and `.user`; work in Global scope. **Workforce Optimization for ITSM > Demand Forecast**:

| Module | Record |
|---|---|
| Data Collection Definitions | table (incident, interaction, or any), condition, date field; index the table on that date field and condition. Shipped: *Chat Interactions Created*, *P1 Incidents Created*, *Non P1 Incidents Created*, *Walkup Interactions Created* |
| Formula Parameters | a value or a script (for example *Average Chat Duration*, *Average Agent Work Time Per Day*, *Average P1 Incident Work Time*) |
| Resource Conversion Formula | for example `([FC:Chat Interactions Created] * [FP:Average Chat Duration]) / [FP:Average Agent Work Time Per Day]`; wrap in `Math.max([FP:Min Number of Agents], ...)` or `Math.min([FP:Max Number of Agents], ...)` for a floor or ceiling |
| Group Forecast Configuration | one formula per assignment group (a formula can serve many groups) |

Tables `sn_agent_forecast_configuration`, `sn_agent_forecast_parameter`, `sn_agent_forecast_configuration_m2m_sys_user_group`. Jobs: *Collect historical data for automated forecast configurations* (on demand; three years, hourly), *Collect daily data...* (02:00), *Forecast resources for future* (03:00; writes the *Agent Forecast* metric in MetricBase). Retention policy *WFO Forecast*: hourly points for three years.

In Manager Workspace > Schedule > **Forecasts**: per model, forecast parameters (period length unit and length, periods to forecast, algorithm) are created in Draft, previewed on the time series and **Published** (one published at a time); a **manual adjustment** (start and end, percentage or number, applied per group) is shown as a green line, published by the next forecast job and can be ended with **End Now**. Properties: `sn_agent_forecast.historical_data_points` (8760, max 26280), `sn_agent_forecast.seasonal_frequency` (168 = weekly pattern), `sn_agent_forecast.forecast_periods` (5), `sn_agent_forecast.number_of_historical_days_in_timeseries_chart` (90). When several definitions feed one formula, the shortest forecast horizon applies.

## Work scheduler

A calendar where a manager drags work items onto agents' time. Roles `sn_wfo_work_sched.admin`, `sn_wfo_work_sched.manager`.

- **Work Scheduler > Work Configurations**: **Table** (allowed tables in property `sn_wfo_work_sched.allowed_tables`: incident, problem, change_request, change_task, sc_task, sc_request, sc_req_item, interaction), the fields used for description, assigned to, assignment group, start and end date, **Default color**, **UX app route** (card layout; *Default card*), **Extra fields**, **Matching rule**, and *Work Configuration filters*.
- Managers add **queue configurations** (work configuration, colour, order, matching rule; the queue settings icon enables up to five work item types at once), pick a queue, select a task, optionally **Show suggested only**, then drag across an agent's calendar row for the time span; drag again to reassign.
- **Matching rules** (**Work scheduler > Matching Rules**, one per table) rank agents with assignment-workbench criteria: *WFO - Availability*, *WFO - Mandatory skills*, *WFO - Optional skills*, *WFO - Timezone overlap* (all "more is better"; green at 100% match). Per criterion: **Use for** (ranking and display / display only / ranking only), ranking method, **Weight** (default 10), **Threshold**, active. Rank = sum over criteria of (normalised value × weight / total weight).
- Properties: `sn_wfo_work_sched.shift_data_categories` (event category sys_ids shown), `sn_wfo_work_sched.should_fetch_shift_data` (true), `sn_wfo_work_sched.recommend_criteria_limit` (10), `sn_wfo_work_sched.match_criteria_threshold` (0).
- Cards are UI Builder sub-pages of *Manager Workspace > Work scheduler* (duplicate a variant such as *Incident default* and give it the lowest order, or build one: client state parameter `cardProps`, page scripts *Handle card clicked*, *Handle card action clicked*, *Transform workItem to cardProps* using script include `sn_wfo_work_sched.WorkSchedulerUIBCardUtils`, page property `workItem` bound to `@state.workItem`, events `CARD_CLICKED` and `CARD_ACTION_CLICKED`; client-side UI Builder scripts). Extension point `sn_wfo_work_sched.WorkItemRecommendationManager` customises recommendations.

## Teams (Team Performance)

Roles `sn_team_perf.team_performance_user` / `_admin` / `_manager`.

- **Team Performance > KPI Groups**: **Type** = Teams; up to five parent KPIs (`sn_team_perf.kpi_group.max_parent_kpis`), each with up to ten supporting KPIs; the indicators must have the breakdowns *Assignment groups* and *Assigned to*; then the assignment groups. A group can be in several KPI groups. **Copy** duplicates everything except the group mapping.
- **KPI Thresholds** per KPI: lower and upper limit, **Status** (Critical, Positive, Warning), **Show Icon**. Drill-downs then show "Approaching threshold of ..." or "Exceeded threshold of ...".
- **Additional Managers** (**Team Performance > Additional Managers**).
- Targets per agent: global (visible to the group) or personal; a value or an improvement on the baseline (percentage or units); start and review dates. Roles `pa_target_admin` + team performance admin.
- Manager Workspace > Teams: pick the KPI group and date range (default from `sn_optimize.default_date_range`, 30 days), drill to team, agent, incident; Skills tab; *Process analysis* tab when a Process Mining project has been mined (role `sn_process_optimization_analyst`). At most 15 groups are listed (`sn_team_perf.ws.max_assignment_groups`).
- Shipped indicators: Closed Incidents, Customer Satisfaction, Quality (assessment score), Average Handling Time (MTTR), First Call Resolution, Trainee Quality Rating, Incidents triaged by VA.

## Related

- [[Workforce Optimization Learning, Skills and Reference]] (coaching and learning, skills, roles, domain separation, mobile, landing pages, filters, group visibility)
- [[Coaching]] · [[On-Call Scheduling]] · [[Service Operations Workspace for ITSM]]
