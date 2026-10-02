---
type: concept
tags: [concept, workspace, admin, incident, problem, notifications, security]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Service Operations Workspace for ITSM", topics "Notifications", "Configuring Major Incident Management in Service Operations Workspace", "Configuring Problem Management", "IT Agent Dashboard", "Collaboration services", "Setting up Service Desk assisted Password Reset", "Setting up AI Search", "Install Universal Request / Universal Task", "Admin Center in Service Operations Workspace for ITSM", "Migrate the existing charts to PAR dashboard" (pp. 3324-3372, 3393-3415), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Service Operations Workspace: Admin Center and process setup

**In one line:** the Admin Center (**All > Service Operations Workspace > Overview**, or **Service Operations Workspace Admin Center**) is the single page from which an admin sets up Service Operations Workspace (SOW) for each ITSM process; this note lists what each card configures and the records behind it.

Roles: admin (everything), `sn_sow_itsm_admin.sow_admin_user` (incident configuration), `change_manager` (change configuration). Tabs: **Overview**, **Configurations**, **Learning**.

## What the Admin Center offers

| Card / option | What it sets |
|---|---|
| Migrate from ITSM Agent Workspace to SOW | [[Migrating from ITSM Agent Workspace to Service Operations Workspace]] |
| Configure the landing page | redirection properties, greeting, donut list collapsed by default (faster load), section visibility; see [[Service Operations Workspace Access and Landing Page]] |
| Contextual side panel | activate / deactivate a tab's app route for all pages, and its **Order** (the user's scope must be the app route's scope) |
| SOW properties | email notification redirection to SOW; `fuzzyCount` (how list record counts are shown, for performance); **Reference search on click** (`ref_search_on_click` UX page property: false = an empty reference field shows only recent selections instead of searching everything); hide the page-level contextual side panel for given table + tab pairs |
| SOW vs Classic UI16 redirection | send classic module links to SOW for all users or a custom set; role `sn_exp_redirect.sn_redirect_config_admin`. On new instances it is on by default; the Admin Center option exists only on upgraded instances |
| Service desk agent role | **Initial setup > Service desk agent role**: tabs *Service Desk Agents* and *Available groups and users*; **Assign service desk agent role** |
| Incident record page | Overview tab (tier 1 visibility, Summary / Impact / Cause / Resolution sections), Details tab (record and new-record layouts), response templates, incident properties |
| Major Incident Management | see below |
| Problem Management | Overview tab on/off, problem and problem task layouts |
| Change Management | Modern change adoption (models, approval policies, risk and success scores, DevOps automation), change and change task layouts; see [[Change Management Plugins, Tables and Workspace Configuration]] |
| On-Call Scheduling | guided cards: groups and preferences, schedule / group / shift / escalation policy / contact preference templates, trigger rule table configuration, properties; each can be marked complete or skipped; see [[On-Call Scheduling]] |
| Service Reliability Management | Assign and import, Governance and Autonomy, Integrations (not for the SOW admin role) |
| Notify | provider preferences and Notify properties |
| Service Desk Assisted Password Reset | see below |

### Charts to Platform Analytics dashboard

**Initial setup > Landing page > Learn more > Preview migration > Migrate to configurable charts** moves the customised landing page charts to a Platform Analytics (PAR) dashboard. Once only. Scope must be *Service Operations Workspace ITSM Common*. An uncustomised landing page is migrated automatically. Overrides must live in the non-SNC script includes (`SowIncidentLandingPageUtils`, `SOWLandingPageTier2Utils`); copy any made in the `...SNC` versions.

## Notifications in the workspace

- **Workspace Experience > Administration > Notification triggers**: in-workspace notifications for Incident, Problem, Change and Delegation; the notification **Category** must match. Plugin `com.glide.notification.provider.next.experience`.
- Links in emails open SOW instead of the classic UI through `sow_email_notification_redirect` (plugin `com.snc.itsm.notifications_redirection`), for incident, problem and request.
- Interaction search uses **Contextual Search > Search Contexts > Interaction (SOW)**; see [[Contextual Search]].

## Major Incident Management setup

Install *Major Incident Management for Service Operations Workspace* (`sn_sow_mim`) from the Admin Center. Process: [[Major Incident Management]].

| Step | Detail |
|---|---|
| Major incident manager role | tabs *MI Managers* / *Available users*, **Assign MI Manager** gives `major_incident_manager` |
| Trigger rules | Activate / Deactivate / Copy; property `sn_major_inc_mgmt.com.snc.incident.mim.major_incident_creation` chooses *Create new* or *Promote* |
| Communication email templates | default table `incident_alert_task`; execution order, condition, subject, content type (HTML / Plain Text), To / Cc / Bcc, **From Generation Type** (SMTP Email Account, Select from List, Script, Text, None) |
| SMS templates | sent through Notify |
| Communication plans | task definitions, channels (Email, Sidebar discussion, DEX Desktop Assistant), contact definitions; see [[Incident Communications Management]] |
| Playbooks | *MI playbook* (Published) and *Advanced MI playbook* (Draft); property `sn_sow.mim_playbook_ids` lists the ones offered; edited in Process Automation Designer / Playbooks (trigger, flows, activities, activate, test) |
| Email notifications | the major incident notifications |
| Post incident report timeline | which incident milestones appear, ascending or descending, and grouping of events that fall within a duration |

## Problem Management setup

- Form views: *Service Operations Workspace* and *Service Operations Workspace New Record*.
- Modal views: *SOW Problem Accept Risk / Assess / Cancel / Fix Modal*; *SOW Problem Task Assess / Cancel / Complete / Complete RCA Modal*.
- Task type chooser: table `sn_sow_interceptor_record_type_selector` (**Applies to** `problem_task` or `change_task`, **Order**, **Title**, **Description**, **Target table**, **Values**). For problem task models, **Values** sets the model and the condition is "Problem.Model is not empty"; models need property `com.snc.problem_management.models.enabled`.
- SLA card: **Problem > Workspace Configuration > Contextual Sidebar**, row *SLAs and timings* active.

## IT Agent Dashboard

Role `sn_sow.it_agent_dashboard_user`. Customise by duplicating the dashboard, adding a tab, duplicating a visualization and changing its data source (for example a filter on the indicator source for open problems not updated in 90 days).

## Collaboration services

Plugin `com.snc.uib.collaboration` replaces `com.snc.uib.sow_collaboration`. After moving, deactivate the old screens in `sys_ux_screen_type`: *Collaborate Tab SNC*, *MS Teams Import*, *Start MS Teams Chat*.

## Service desk assisted password reset

An agent resets a caller's password or unlocks the account after verifying their identity. Card **Service Desk Assisted Password Reset** (role admin).

| Card | Record and main fields |
|---|---|
| Password reset agents | gives `password_reset_service_desk` to users |
| Credential stores | **Type**, **Auto generate password** (script include), **Child Alias** (several connections for one store), **Enable password policy**, **Enable password strength**, **Password policy**, **Enforce history policy** (add parameter `password_history_limit`, max 10, 0 = no limit); then **Test Connection** |
| Password reset process | **Credential store**, **Enable account unlock**, **Apply to all users** (or groups in the related list); details: **Minimum verifications**, optional verifications, **Auto-generate password** (then **Display password** and/or **Email/SMS password**, and **User must reset password**); Enrollment Reminder tab; **Active** |
| Verification settings | verification types: Personal Data Confirmation, Personal Data, Security Question, SMS Code, Email code; **Process mapping** (process → verification); **UXF routes mapping** (**Order**, **Workspace**, **Verification type**, **Route**) for the page the agent sees |
| Password policies | strength preset, min / max length, excluded special characters, disallow user data, sequence and repetition thresholds |
| Session properties | workflow polling 500 ms, workflow expiration 90000 ms, 3 failed attempts then lock-out for 1440 min, request expires after 10 min, max 5 reset-link emails per 24 h, security question counts and answer length, SMS code limits, Notify for SMS |

## Search and other add-ons

- **AI Search** in SOW (from SOW 1.3): a search application configuration and a search profile are shipped; the result card layout is an EVAM definition (*AI Search for Next Experience*). UX page property `globalSearchDataConfigId` must hold the sys_id of the AI Search configuration. When upgrading use the guided setup *Zing to AI Search Migration* (sources indexed, profile published, AI Search enabled). Q&A Genius Results need AI Search for Next Experience 3.0+ and an active Q&A configuration. See [[AI Search Overview]].
- **Universal Request** (`com.snc.universal_request`) and **Universal Task** (`sn_uni_task`) for SOW are installed from the application manager (admin).

## Related

- [[Service Operations Workspace for ITSM]] · [[Investigation Framework, CI Actions and Remedial Actions]]
