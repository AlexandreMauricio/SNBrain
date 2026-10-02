---
type: concept
tags: [concept, workspace, incident, change, request, knowledge]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Service Operations Workspace for ITSM", topics "Operating IT services in your organization" (guided tours, quick links, lists, Live Agent chat, Interaction Management, Incident Management in SOW incl. contextual side panel, list page, close and reopen, batch-processing extension point, quick start tests, Request Management, approvals, Change Management, change templates, proposed CI changes, standard change catalog, change tasks, CAB definitions and meetings, CAB workbench) and "Managing IT services" (Knowledge Management, Major Incident Management in SOW, communications, post incident report, Problem Management in SOW and its models, Teams integration, SLM, Walk-up, Collaboration and conference calls, CTI, Universal Request, Universal Task, password reset, Workforce Optimization for agents) (pp. 3478-3589, 3618-3630, 3645-3694), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Working records in Service Operations Workspace

**In one line:** what an agent can do on each record type in Service Operations Workspace (SOW), and the properties, roles and tables behind the behaviours that differ from the classic UI. The processes themselves are in the ITSM notes linked per section.

## Interactions

An interaction (`interaction`) is one request for help through a channel (chat, phone, walk-up, messaging). Lists: Assigned to me, Active, All. Without Now Assist, **Opened for** and **Short description** are required.

| Action | Notes |
|---|---|
| **Create incident** | the incident is assigned to the interaction's assignee |
| **Create change** | only pre-approved (standard) change types |
| **Create request** | opens the catalog; **Request for** defaults to the person in the interaction |
| **Create problem** | only if property `glide.problem.interaction.allow_create` is on |
| **Complete** / **Abandon** | state Closed Complete / Closed Abandoned, ends the conversation |
| **Associate record** | links existing tasks (several at once) |
| Side panel | requester's assigned assets (with **View device health** if DEX is installed), recent interactions and tasks; Agent Assist (roles itil or `interaction_agent`); attachments; templates; Teams chat (start, view, import) |

Chat arrives in the inbox (Agent Chat); once accepted the inbox hides.

## Incidents

Process: [[Incident Management Overview and Lifecycle]]. Lists: Assigned to you, Unassigned, Open, Resolved, All. Row actions: Assign to me, Reassign, Copy URL, Copy sys_id, edit in a side panel (Details / Activity), export (CSV, PDF, HTML), group by, show matching, filter out.

**Tabs**: Overview (Summary, Impact, Cause, Resolution + compose), Investigation ([[Investigation Framework, CI Actions and Remedial Actions]]), Communicate, Post incident report (resolved major incidents), Details, Related records.

Behaviour worth knowing:

- Changing **Impact** / **Urgency** asks for a work note; **On Hold** asks for the reason and a comment; **Resolved** asks for **Resolution code** and **Resolution notes**.
- An *AI summary and suggestions* card (**Generate**) replaces the static summary card.
- Cards **Affected CIs**, **Impacted Services/CIs**, **Assets**: adding more than 50 records is processed asynchronously in the background (async threshold 50).
- **View impacted locations** (major incidents with `sn_sow_mim`): world map; impacted users are counted from the caller, child incident callers and, with Service Portfolio Management, the service offering's subscribers. Extra locations go in the *Affected location* related list.
- Empty reference fields show only recent selections unless UX page property `ref_search_on_click` is true.
- Batch updates from related lists: script include `RelatedListIncidentItemUpdateHandler` implements extension point `global.RelatedListItemUpdateHandler` (functions initialize and post update) so one handler runs instead of a business rule per record, for example when attaching many child incidents. Server-side, global.

**Record information panel**: Active calls (major incidents, up to five; Twilio shows text, not a link), *SLAs and timings* (major incident duration, response and resolution SLA, View all SLAs), Caller (tier 1 sees it first; VIP decorator; assets, 10 recent interactions / incidents / requests), Origin (the interaction, change or problem it came from; chat transcript and work notes for a closed chat), Assigned to (Assign to me; additional collaborators = past assignees, commenters on a major incident, people in collaboration channels).

- Property `sn_sow_inc.autoclose_origin.interaction` = true: resolving the incident moves the originating interaction to Wrap up (if scheduled script *Fallback Timeout for interactions in Wrap Up* is active) or Closed complete; business rule *Close interaction from incident*.

**Actions**: Create change request, incident task, outage, problem, request; Resolve; Assign to me / Assign / Reassign (when the group changes, **Assigned to** is kept only if the user belongs to the new group); Book Walk-up Appointment; Compose Email; Copy Incident; Propose / Promote to Major Incident; **Report Knowledge Gap** (creates a knowledge feedback task); Delete; side panel: recommendations, Agent Assist, experts on-call, on-call escalations, Collaborate, attachments, DEX action library, templates, playbook, response templates (role `sn_templated_snip.template_snippet_reader`).

- **Close** a resolved incident: `itil_admin` or admin. **Reopen** (asks for a customer-visible comment, state back to In progress): itil or `sn_incident_write` in SOW for any incident; on portals only the caller or **Opened by**. A Closed incident cannot be reopened; replying to the resolution email creates a new incident with copied values.
- Quick start (ATF) tests shipped with SOW ITSM Applications 6.0: create problem from incident, Assign to me.

## Requests

Application `sn_sow_req`. Process: [[Request Management Data Model and Process]]. Categories Request and Catalog Task. The classic form layouts, UI actions, UI policies and client scripts apply to Request, Requested Item and Catalog Task; the variable editor shows only if it is on the classic form. **Create request** from an incident or interaction (or through Agent Assist): pick an item, order guide or record producer, **Order Now**, **Checkout**; the request is linked to the parent. Roles itil or `sn_request_write`.

**List > Approvals > My Approvals** (change, request, catalog task, requested item) appears only if the Approvals component is in the layout and the user has approvals; roles itil, `sn_change_read` or `sn_request_read`.

## Changes

Process: [[Change Management Overview and Lifecycle]]. Created from the change list (optionally from a **template**), an incident, an interaction (pre-approved only) or a problem; pick the model (Normal, Standard, Emergency, DevOps models) and fill **Short description**, **Description**, **Justification**; then sections Scope and impact, Assignment, Schedule, Risk evaluation, Change tasks.

- **Assignment group** can default from the CI's or service offering's group: business rule *Populate Assignment Group based on CI/SO* (plugin `com.snc.best_practice.itsm_csdm.quebec`, new customers only), properties `com.snc.change_request.ci_assignment_group.field_name` and `com.snc.change_request.service_offering_assignment_group.field_name` (defaults: support group for incident and problem, change group for change).
- **Set schedule**: planned dates, conflicts tab (types as in [[Change Conflict Detection and Maintenance Schedules]]), **Check conflicts**, **Next conflict-free** slot.
- **DevOps data** (category DevOps, role `sn_devops.viewer`): associate artifact versions, release versions, build numbers or work items; review work items, commits, pull requests, test, quality and security summaries.
- **Related release** card (Digital Product Release 2.4): assign the change to a release phase; **Add CIs from release phase** imports affected CIs asynchronously.
- **Propose single change** on an affected CI: pick fields and proposed values; **View proposed change**; **Apply proposed changes** appears in Implement and writes them to the CI. **Propose mass CI update** for a class.
- Buttons: Request Approval, Implement (creates the Implement and Post-implementation testing tasks), Review (open tasks are canceled), Close (close code and notes), Refresh Impacted Services, Create Outage, Cancel. The state buttons show only if **On hold** is on the SOW form.
- Templates: from the model picker, **Create template for selected model** / **Edit template** (opens the classic UI; role `change_manager`); standard change: **Propose a new template**, **Edit template** ([[Standard Change Catalog]], [[Change Models and Change Templates]]).
- Change task types: Planning, Implementation, Testing, Review; implementation task dates must fall inside the change's planned dates.

### CAB

[[CAB Workbench]]. Role `sn_change_cab.cab_manager`. Lists under *Change Advisory Board*: My / All CAB Definitions, All CAB meetings, My upcoming CAB meetings.

- **CAB definition**: manager, delegates, board members and groups, **Rolling Meeting Window** (days of meetings to generate), **CAB Type** (Normal, Emergency), time zone, locations, conference details; agenda management (**Notification lead time**, **Use filter criteria to drive Change Request date range**, **Automatically Add Change Requests**, **Time per Agenda Item**, **Complete Preapproved Changes**, **Auto Add Agenda Decisions**); related lists *Scheduled Entries* (recurrence) and *Related Schedules* (for example holidays); **Refresh CAB Meetings** generates the meetings.
- **CAB meeting**: states Pending, In progress, Complete, Canceled; adding an agenda item sets the change's **CAB date**; agenda item fields **Task**, **Order**, **Decision**, **Allotted time**, **Elapsed time**; **Refresh agenda items**; **Send meeting request to attendees**.
- **Open in CAB Workbench > Start meeting**: per-item timer, **Make approval decision** (approvers only), Pause / Resume / Next item, tabs Up next, Deferred (**Restore**), All; decisions are written to **Meeting notes**; **End Meeting** sets Complete.

## Knowledge

Agents work on their articles, feedback tasks, flagged and translation tasks (translation needs `com.glideapp.knowledge.i18n2`; knowledge blocks need `com.snc.knowledge_blocks`). Actions: Checkout, Translate, Request translations, View Article, Retire. *Most recent task* list (from `m2m_kb_task`) shows if property `glide.knowman.recent_task.display` is on.

## Major incidents

Process: [[Major Incident Management]]; setup: [[Service Operations Workspace Admin Center and Process Setup]].

- **Propose Major Incident** (itil: work notes + business impact) → manager **Promote** or **Reject** in the playbook's *Review Situation* step (or **Promote to Major Incident** directly).
- Playbook steps (*MI playbook*): Review Situation, Communicate, Collaborate, Adhoc Communications & Collaborations, Resolve, Create problem, Post Incident Review. *Advanced MI playbook* merges communication and collaboration into one configurable section.
- *Create problem* step shows only if no problem is linked, the Madrid problem state model plugin is active and flow *Create problem from major incident* is inactive (shipped inactive; when active it creates the problem at promotion). Copied fields: property `com.snc.problem.create_from_incident.attributes`.
- Child incidents: **Find similar** uses a similarity solution to add duplicates as children.
- **Communicate** tab: tasks grouped by plan or by status (Overdue, Upcoming, Completed, Skipped); **Compose** (email with templates, including generative ones; SMS; DEX Desktop Assistant; Teams; Slack), **Manage recipients** (users, groups, lists, with a role), **New communication** (Now / Later, One time / Recurring with **Due in (minutes)**; `major_incident_manager`, or `ia_admin` + itil), Start, Snooze, Close (Completed if something was sent, otherwise Skipped), **Manage announcements** (portal banner or widget; needs `announcement_admin` or `sp_admin`). Notifications can go to all users in the affected locations. See [[Incident Communications Management]].
- **Collaborate** panel: Call and Chat tabs; start a sidebar discussion or Teams chat (Slack not supported), or a Webex, Teams, Twilio or Zoom meeting.
- **Resolve** (resolution code + note) then **Close**.
- **Post incident report** tab (Resolved major incident): timings (time to identify, to respond, to resolve), co-contributors, incident summary, timeline (events created, proposed, accepted, resolved, closed, incident tasks, custom events; hide / add / order / group), related records, **Preview** (property `sn_sow_inc.pir_pdf_preview_sow_page`), **Download** PDF. Publish deadline: property `sn_sow_inc.pir.publish.hours`. Read needs `sn_incident_read`; editing needs `major_incident_manager` or being a co-contributor.

## Problems

Process: [[Problem Management Overview and Lifecycle]]. Lists: Assigned to you, Unassigned, Open, Resolved, Risk Accepted, Known Errors, All. Tabs: Overview (summary, analysis, resolution, tasks, impact), Details (**State** is read-only: use the buttons), Problem Tasks, Fix Tasks (only change requests count as fix tasks; property listing the related task tables tracked as fixes), Related records (incidents, affected CIs, outages, attached knowledge).

- Buttons follow the base life cycle: **Assess**, **Confirm** (to Root Cause Analysis), **Fix** (cause and fix notes), **Accept risk**, **Mark duplicate**, **Cancel problem**, **Re-analyze** (from Resolved or Closed back to Root Cause Analysis); **Create problem task**, **Create change request**, **Create outage**, **Create known error article**, **Share workaround**, **Share fix**. Optional shortcuts: Create defect / enhancement (Agile Development 2.0), Create improvement initiative.
- If the instance does not use the base life cycle (plugin `com.snc.best_practice.problem.madrid.state_model`; migrate with the *Problem Management Migration Utility* store app), the page shows **Continue problem** / **Continue problem task**, which opens the classic form for state changes.
- Recommendation *Create article* appears for a `problem_coordinator` when impact is high, no known error article is attached and work notes exist.
- Problem task types: Root cause analysis, General; buttons **Assess**, **Start work**, **Complete**, **Cancel task**, **Re-assess**. Roles: itil or `problem_coordinator` (life cycle), `problem_task_analyst` (task state), `problem_admin` (delete).
- **Problem models** (property `com.snc.problem_management.models.enabled`, from Xanadu, optional): custom states, transitions and conditions per model; shipped models *General* (problem) and *Root cause analysis*, *General* (problem task) replicate the base life cycle. Records created before enabling keep the non-model life cycle. SOW 6.x supports models; with SOW 5.x, enabling models sends problem work back to the classic UI. Test in sub-production first.
- Assignment group default from CI or service offering: properties `com.snc.problem.ci_assignment_group.field_name`, `com.snc.problem.service_offering_assignment_group.field_name`.

## Collaboration and calls

**Collaborate** panel on incident, problem, change, request and interaction: Teams chat history, **Start Microsoft Teams chat**, **Import Microsoft Teams chat** (whole conversation or selected messages; imports land in the activity stream). **Calls** tab: start a Twilio ("Telephony"), Webex, Zoom or Teams meeting (title, participants, message), **Meeting options > Add participants**, mute, **Join call** / **Leave call** / **End call**, **Reinitiate** a completed call, **View Recording**. More than 50 participants are added asynchronously. **Start Sidebar discussion** (incident, change, problem only): if the group has on-call schedules only the on-call members are added, and nobody if no one is on call; an unread message triggers a reminder email after 24 hours. CTI (OpenFrame) calls from the record information card or an on-call escalation: roles `sn_openframe_user`, `sn_customerservice_agent`, `sn_customerservice.consumer_agent`.

SLA: the landing page *Incident SLAs* card covers the agent's own incidents; on the record only one response and one resolution SLA are shown (the timer mapping with the lowest order), **View more SLAs** lists all. See [[SLA Definitions and Task SLAs]].

## Walk-up

Lists: My Stockrooms, Walk-up Locations, Location Kiosks, My Assigned Walk-ups, Open - Unassigned, Closed Walk-ups, Appointments. The agent sets status Available, accepts the pushed interaction (or **Abandon**), checks in at a kiosk, and closes it as Closed Complete; can promote it to an incident or request. **Book Walk-up Appointment** on an incident creates an appointment for the requester (related list *Walk-up Appointment*; a *Source* section then appears on the interaction).

## Universal Request and Universal Task

- **Universal Request** (`com.snc.universal_request`): a parent record a routing agent opens on behalf of a requester; its **Primary task** is the incident, HR case or other ticket that does the work. **Transfer** on the primary task (department, service, reason, notes; comments and attachments copied by default, work notes never) creates a new ticket for the target department and lists the old one under *Associated Requests*. **Needs resolution review**: when the primary ticket closes, the request stays In Progress with state reason *Confirm Response* until the routing agent accepts or rejects the resolution. Cancel only in New or In Progress and with no primary ticket. **Restrict** / **Unrestrict** for sensitive content (role `sn_uni_req.sensitiveinfo_agent`). Roles `sn_uni_req.ur_admin`, `sn_uni_req.routing_agent`, `sn_uni_req.universal_request_read` / `_write`. Agent Assist sources: similar open and closed universal requests, knowledge, catalog items, pinned articles.
- **Universal Task** (`sn_uni_task`): a task given to an employee from a ticket. Table `sn_uni_task_universal_task`; types configured per department table in `sn_uni_task_config` (for example Collect Employee Input with an **Employee form**, Mark When Complete, Checklist); templates `sn_uni_task_template`. **Ready for work** creates it in Work in Progress and notifies the employee; **Submit** leaves it New without notification. Roles `sn_uni_task.admin`, `.report_view`, `.emp_form_admin`, `.emp_form_creator`, `.template_admin`.

## Service desk assisted password reset (agent side)

Setup: [[Service Operations Workspace Admin Center and Process Setup]]. On an incident (category Password Reset for unlock) or interaction assigned to an agent with `password_reset_service_desk`: **More actions > Reset password** → identify the user and process (at most three resets per process in 24 hours) → verify (email code, SMS code, security questions, personal data; three attempts) → reset (email instructions, auto-generate, or type a new password) or **Unlock account**. Typical errors: user not enrolled, not eligible for the process, no process found, maximum attempts reached (retry after 8 hours), Notify not enabled, only one reset session at a time.

## Workforce Optimization for agents

With `sn_wfo_cfg_itsm` (role `sn_wfo_cfg_itsm.employee`): profile page (KPIs and targets, training, channels, skills, PTO); **Schedule** with *My Calendar* / *Team Calendar*, shift swap (approved by the peer, then the manager), time off, on-call time off with proposed cover, custom events, shift sign-up (limit `sn_shift_planning.max_shifts_allowed_for_signup`), break editing (`sn_uib_agent_sp.allow_agent_edit_break`, `sn_uib_agent_sp.allow_agent_add_remove_break`); clock-in when status becomes Available, clock-out on Offline or Break; **Learning** (Overview, Discover, My learning; quizzes; skills added on completion); skill review requests (`sn_wfo_skillreview.user`); surveys under the profile's Assessments tab. Time off can also be requested through the Virtual Agent topic *Time Off Request*.

## Related

- [[Recommended Actions for ITSM]] · [[On-Call Scheduling]] · [[Service Operations Workspace for ITSM]] · [[Service Operations Workspace Configuration and Customization Reference]]
