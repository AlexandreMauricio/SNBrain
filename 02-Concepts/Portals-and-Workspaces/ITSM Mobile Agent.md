---
type: concept
tags: [concept, incident, notifications, workspace, admin]
status: documented
source: ServiceNow Australia IT Service Management PDF, "ITSM Mobile Agent" (pp. 2605-2728), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# ITSM Mobile Agent

**In one line:** the ITSM content for the ServiceNow Agent mobile app (application `sn_itsm_mobile_agt`): applets for an agent's own incidents and tasks, a manager's team view, major incidents and on-call, with push notifications that can be acted on from the lock screen.

Replaces the *ITSM Mobile* plugin (`com.sn_itsm_mobile`, deprecated in Quebec).

## Roles and optional plugins

itil (or `sn_incident_write`, `sn_change_write`, `sn_request_write`); `major_incident_manager` for the major incident applets; `rota_manager` for team on-call; `approver_user` for hardware asset approvals; `sn_shift_planning.admin` for shift planning. Features light up with: Major Incident Management (`com.snc.incident.mim`), On-Call Scheduling (`com.snc.on_call_rotation`), Notify (`com.snc.notify`), Incident Communications (`com.snc.iam`), Collaboration services (`sn_tcm_collab_hook`), Slack spoke, Event Management, Hardware Asset Management, Shift Planning, the PA content packs for ITSM and major incident.

## Applets

| Area | Applets and actions |
|---|---|
| Landing | search; **+** creates an incident (caller, short description, urgency, impact, read-only priority, description, service, CI, assignment group, assigned to) |
| My work | My incidents, Incidents at risk, Breached incidents, Change tasks (card shows risk), Catalog tasks, approvals; swipe left: **Add comments**, **Reassign**, **Resolve** (resolution code and notes). Record tabs DETAILS (menu: reassign, edit, propose as major incident), ACTIVITY (video, photo, file, comment with a customer-visible toggle, work note), RELATED (child incidents, incident tasks, alerts, task SLAs, impacted services, affected CIs, attached articles), CALLS |
| On-call Schedule | Upcoming shifts (swipe: **Request time-off** with group, dates, proposed coverage, notes), Time-off requests (pending / completed), Who is on-call |
| My team (group manager) | dashboard (incidents at risk, breached, overdue changes), Unassigned incidents (**Assign to me**, **Assign**), Overdue changes (comment, **Cancel change** with reason; PLANNING tab), team shifts (**Provide Coverage**), approve or reject time-off (reason needed to reject), Gaps and conflicts, performance metrics (MTTR, CSAT, breached SLAs, incidents per week) |
| Major incidents | Active major incidents (assign, resolve, comment; TASKS tab: **Close task**, **Snooze**), Major incident candidates (**Promote** with reason and business impact, **Reject** with work note), Resolved, dashboard (count, mean time to identify and to resolve), Active collaborations (calls, chats) |

**Summarize** (generative): when adding work notes or reassigning, in My work, My team and Major incidents. Needs the incident summarization skill ([[Otto for ITSM Skill Inputs, Triggers and Customization]]); if the skill was configured before the mobile app was installed, activate the *Input form actions* labelled Summarize of application ITSM Mobile Agent (*Incident summarize action*, *Incident summarize action (Reassign)*).

**Collaboration** on incidents, incident tasks and major incidents (needs Collaboration services, Notify and the Notify connector for Microsoft Teams, `com.sn.ms_teams`): tap **Caller** or **Assignment group** to open a Slack or Teams chat (shown only when the person or group has such an account); **Collaborate > Start call** (conference bridge Microsoft Teams, users, groups), add participants (recommended ones are those on the incident), join, view active / inactive participants, **End call** (host or incident manager). Deep links: property `glide.sg.allowed_external_deeplinks` = `Slack,Teams`.

## Search

AI Search is on by default on new instances: publish the search profile *ITSM Mobile Agent Search Profile* (**AI Search > Search Experience > Search Profiles**). On upgraded instances: request AI Search, activate *AI Search Index Sources* (`com.glide.ais.index_sources`), index all sources, publish the profile, and set **Search Application Configuration** = *[AIS] ITSM Mobile Agent Search Configuration* on the record *ITSM Mobile Agent Search* in `sys_sg_global_search`. Searches incidents (major, breached, at risk), change tasks, catalog tasks, changes, users, knowledge. To go back to Zing everywhere (mobile and workspaces): property `glide.ais.global_search.use_zing` = true. See [[AI Search Overview]].

## Push notifications

Actionable push notifications carry up to three buttons, each mapped to a mobile function of type Action item, Navigation, URL or Chat launcher.

1. **System Mobile > Mobile Push Notifications > Push Notifications**: name, **Actionable**, optional **Screen**.
2. **Push Action Categories** (shipped: accept-reject, approve-reject and their *wcomments* variants, ack-escalate-ignore, confirm-reschedule-cancel, joinbridge, PromoteWComments-RejectWComments, queue actions, yes-no; suffix *-back* acts without opening the app, *-fore* opens it) and **Push Actions** (label, **Foreground**, response type Simple or Text response).
3. **System Mobile > Functions**: one function per button.
4. Related list **Push Action Instances** on the notification: **Push Action** → **Button** (the function).
5. Related link **Create Push Message Content** (table `sys_push_notif_msg_content`; field **Push Message Generation** holds the generated script).
6. **System Notification > Push > Create Push Notification**: the standard notification (table, conditions) whose **Push Messages** point at that content.

Other settings:

| Setting | Where |
|---|---|
| Users may switch categories on and off | property `com.glide.sg.notifications.management` = true (categories come from `sysevent_email_action`); users must log out and in |
| Email links open the app from the mobile browser | property `glide.sg.universal_links.enabled` = true; for incident, incident task, catalog task, change request, change task |
| Alert tone per incident priority | in the **Push Message Generation** script, read `current.getValue("priority")` and set `json["aps"]["sound"]` to the tone for that priority (server-side script on the push message content record) |
| Critical alerts through Do Not Disturb | mobile properties (`sys_sg_properties`, global scope, application Agent): `critical_alerts_request_prompt` = true, optional `critical_alerts_request_reprompt`; the user then allows it in the phone settings |
| Which notifications are critical | attribute **isCritical** = true on the push notification message. Shipped critical: *Major Incident Promotion Notification*, *Major Incident - ICA SLA Breached*, *Major Incident - ICT SLA Warning*. For a custom one, generate the payload with `new sn_itsm_mobile_agt.CriticalPushPayloadBuilder(current, json, attributes).buildJSON()` and add the attribute |
| Critical alert tone | script include `CriticalPushPayloadBuilder` (scope ITSM Mobile Agent; server-side): `json["aps"]["sound"]` = `{critical: 1, name: "NotificationAlert-9-Short.caf", volume: 1}`; tones NotificationAlert-1 to -14 |

## Migration notes

- From ITSM Mobile: in Studio open the *ITSM Mobile* application and deactivate its applet launchers (*Incidents*, *My Approvals*) and notifications (*Approval assigned to me*, *Incident commented*) to avoid duplicates; move custom applets and notifications to the ITSM Mobile Agent scope by copying or redefining them.
- To 5.0.3 (Next Experience theme, accessibility): on `plugin.upgraded` a script action *Run clean upgrade for ITSM Mobile Agent* converts legacy icon sections (`sys_sg_icon_section`) to navigation sections (`sys_sg_navigation_section`), UI parameters (`sys_sg_button_instance`, `sys_sg_ui_parameter`) to input form screens, and item views (`sys_sg_item_view`) to mobile cards, through script include `sn_itsm_mobile_agt.MobileUtahUpgradeEngine`. **Customised** legacy records are kept and the new default is deactivated instead: review those by hand, or users get a mixed experience.

Domain separation: Basic (`incident`, `incident_task`). Dark theme: **More > Settings > Preferences > Theme**.

## Related

- [[Service Operations Workspace for ITSM]] · [[On-Call Scheduling]] · [[Major Incident Management]] · [[Collaboration Services (Slack, Teams and Zoom on Tasks)]]
