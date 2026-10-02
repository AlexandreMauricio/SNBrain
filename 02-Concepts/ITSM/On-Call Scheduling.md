---
type: concept
tags: [concept, incident, notifications, flows, users]
status: documented
source: ServiceNow Australia IT Service Management PDF, "On-Call Scheduling" (pp. 2889-2982), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# On-Call Scheduling

**In one line:** each support group gets shifts (when cover is needed) with rosters (who, in rotation, at each escalation level); trigger rules start an escalation subflow on a task, which notifies people along the escalation path until someone accepts.

Plugin `com.snc.on_call_rotation` (active on new instances). Menu **On-Call Scheduling**.

## Terms and tables

| Term | Table | Meaning |
|---|---|---|
| Shift | `cmn_rota` | period during which a group is on call, tied to a schedule |
| Roster | `cmn_rota_roster` | ordered set of members for one escalation level (Primary, Secondary...), with rotation and reminder settings |
| Member | `cmn_rota_member` | a user on a roster with **From** / **To** validity dates; all members belong to the same group |
| Coverage, time off, extra time | `roster_schedule_span` | overrides on the calendar |
| Escalation policy (escalation set) and steps | `cmn_rota_escalation_set`, `cmn_rota_esc_step_def` | custom escalation path |
| Trigger rule | `trigger_rule` (extends `sysrule_assignment`) | when to start, and what to run |
| Escalation log | `on_call_escalation` → `on_call_escalation_level` → `on_call_escalation_con_attempt` → `on_call_escalation_comm` | tracking |
| Preferences | `on_call_group_preference`, `on_call_user_preference`, `on_call_user_contact_preference`, `cmn_rota_contact_preference` | |
| Templates | `sys_on_call_group_template`, `sys_on_call_shift_template` | |
| Channel message configuration | `on_call_communication_channel_config` | |

Tables starting `v_` (`v_rotation`, `v_user_rotation`, `v_on_call`...) only feed the built-in reports; do not report on them.

## Roles

| Role | Does |
|---|---|
| itil | view schedules, set own availability and contact preferences, request time off |
| `rota_manager` (shift manager) | manage shifts of **their own** group: group manager, delegated, or named in group preferences |
| `rota_admin` (shift administrator) | all shifts, templates, trigger rules; contains `assignment_rule_admin` |
| `sn_on_call_admin` | everything including properties and trigger rule table configuration |
| `rota_prem_dashboard_user` | premium dashboard |

## Building a schedule

**On-Call Scheduling > Create/Edit Schedule** (wizard): group → shift (existing schedule such as 24x7 or Workday 8-5, or custom times; holiday schedule) → members and rotation (**Rotation interval** daily, weekly, monthly; **Rotate every**; start date) → escalation setup → review → **Finish** publishes (otherwise Draft).

- **Allow Shift Schedule overlap** enables hand-over periods; **Escalation rule on Shift overlap**: outgoing, incoming or all shifts.
- Member changes use **Add**, **Move** (Move after / Swap) and **Remove** on the roster's Members list, effective from a date and from the next rotation; ticking **Delete member** rewrites rotation history.
- Calendar actions: **Provide coverage**, **Schedule extra time**, **Schedule time off**. Time-off approval is controlled by `com.snc.on_call_rotation.pto.configuration` (With approval / Without approval / Not allowed).
- Gaps (time off without cover, user left the group or inactive) and conflicts (same user primary and secondary) appear under **Pending Actions**; weekly job *On-Call Gaps Conflicts Report*.
- iCal subscription: **Send Subscriptions** on the shift.
- New "2024" schedule engine for new shifts; migrate old ones with **Migrate Now** or job *On-Call Upgrade shifts to 2024 schedule engine*.

## Escalation

- **Escalation type**: one roster → *Rotate through members*; several rosters → *Rotate through rosters*; **Override escalation** → *Custom* steps (audience: rosters, groups, users, devices, group manager; **Time to next step**, reminders). Several policies per shift can be selected by table and condition, with one **Default**.
- Per roster: **Number of reminders**, **Time between reminders** (default 15 min). Time before escalation = (reminders + 1) × interval: 2 reminders at 10 min = 30 min.
- **Catch-All**: who is told when nobody accepted (group manager, shift manager, an individual, all).
- Channels: email, SMS and voice (need Notify), Slack (IntegrationHub spoke), Microsoft Teams (`sn_now_teams_it`), mobile push, custom. Users set them per contact attempt in **My Preferences**; a shift can **Override user preference**; a forced channel that fails is not retried on another.
- Members with time off are skipped.

### Trigger rules

**On-Call Scheduling > Administration > Trigger Rules**: **Table**, **Execution order**, **Run Trigger** (*Run once* or *Every time trigger field changes* + **Trigger fields**), conditions, optional **Group**, and **Trigger action** = Subflow, Workflow (hidden on new instances since Zurich) or Script (admin, rota_admin). They behave like assignment rules ([[Assignment Rules and Data Lookup Rules]]). Non-task tables must be registered in **Trigger Rule Table Configuration** (`trigger_rule_table_cfg`).

| Subflow | Behaviour |
|---|---|
| On-Call: Assign | assign to the current primary, no notification by default |
| On-Call: Assign and Notify | assign to the primary and notify; ends if nobody is on call |
| On-Call: Assign By Acknowledgement | notify along the path on the preferred channels; assign to whoever accepts; a rejection moves on immediately |
| On-Call: Escalations by Email | same, by email only |
| On-Call: Conference Call Escalation | calls members into a conference; reminders every 60 s |
| On-Call: Time-off approval | PTO approvals |

An escalation is **cancelled** when the task's assignment group changes to a group with no matching trigger rule. Property `com.snc.on_call_rotation.new_trigger_engine` launches subflows through the flow runner queue instead of the event queue (faster under load).

### Tracking

With `com.snc.on_call_rotation.log_escalations` on, an icon next to **Assignment group** on the task opens **On-Call Escalation Tracking** (green = active). Logs: **On-Call Scheduling > Escalations > Escalation Logs**.

## Other properties

`com.snc.on_call_rotation.allow_rota_overlap`, `com.snc.on_call_rotation.escalation_rule_rota_overlap`, `com.snc.on_call_rotation.pto.approval.required`, `com.snc.on_call_rotation.landing_page.group_limit` (20) / `.max_groups` (300), `com.snc.on_call_rotation.reminders.showtz`, `com.snc.notify.default.on_call_escalation_level` (-1 = everyone in the plan).

Reminder emails: job *On-Call Reminders*, lead time from the roster, else the shift, else 2 days; none are sent for daily rotations with a lead time above 1 day.

Domain separation: Standard.

## Related

- [[Major Incident Management]] (assignment to the on-call manager) · [[Incident Communications Management]] · [[Schedules and Schedule Entries]] · [[Create an On-Call Escalation Trigger Rule]]
