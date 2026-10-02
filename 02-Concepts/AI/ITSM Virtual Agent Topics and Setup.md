---
type: concept
tags: [concept, ai, incident, request, portal, notifications, integrations]
status: documented
source: ServiceNow Australia IT Service Management PDF, "ITSM Virtual Agent" (pp. 2763-2853), "ITSM Virtual Agent Lite" (pp. 2853-2855), "ITSM Employee Slate for Moveworks" (pp. 2855-2862), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# ITSM Virtual Agent: topics and setup

**In one line:** ITSM Virtual Agent is a store pack of pre-built chatbot conversations (topics) for IT self-service and for fulfillers, plus actionable notifications and **Issue Auto Resolution**, which intercepts incidents created outside chat and offers a conversation that may resolve them.

The generative replacement (LLM topics, AI agents) is in [[Otto for ITSM Skill Inputs, Triggers and Customization]]; the guide says the generative Virtual Agent now replaces this NLU pack.

## Setup

1. Activate Glide Virtual Agent (`com.glide.cs.chatbot`).
2. Install *ITSM Virtual Agent Conversations* (`com.snc.itsm.virtualagent`; includes the *ITSM NLU Model for Virtual Agent Conversations*) from the store.
3. Shipped topics are read-only templates, named *... (Template)*, inactive and unpublished: **Conversational Interfaces > Virtual Agent > Designer**, **Duplicate** in the *ITSM Virtual Agent Conversations* scope (duplicating Office 365, Active Directory or meeting topics in another scope breaks their scripts), rename, activate, **Publish**, **Test**.
4. Choose keywords only (quick) or NLU (better). English NLU models are active; other languages must be activated: German, French, Canadian French, Korean, Spanish, Brazilian Portuguese, Japanese, Italian, Dutch, Simplified Chinese. Topic messages are translated through `gs.getMessageLang()` reading `sys_ui_message` in the language from `vaContext.getRequesterLang()` (server-side topic scripts).

Roles admin or `virtual_agent_admin`. Dialog acts are enabled at topic level. Edge Encryption is supported with its usual limitations.

Automatic status notifications: a Virtual Agent notification on `task` (task type Incident or Requested item) messages the user when the state changes; one on `sysapproval_approver` alerts approvers.

## Topic catalogue

| Category | Topics | Needs |
|---|---|---|
| ITSM Fulfiller (itil) | Create Change Request (normal and emergency ask for short description, justification, CI, assignment group, planned dates; standard gives a link to the standard change catalog), Create Problem, Identify Available Change Windows, Identify Scheduled Changes (per CI), Resolve Incident (close code and notes), Update Assigned Task (comment or work note on one or all), Update Change Request (actual dates, move to work in progress or closed) | |
| ITSM IT Issues | Collaboration Applications (blocks Troubleshoot Cisco Webex / Microsoft Teams / Zoom), Email Issues, Email Setup, Guest WiFi Access, Hardware Issues, Local Admin Access, Meeting Room Issues, Printer Issues, Repository Access, RSA Token, Troubleshoot Slow Computer, VPN Connectivity | fallback search type from property `sn_itsm_va.fallback_search_option` (AI Search or contextual search) |
| ITSM Self-Service | Check IT Ticket Status, Check Ticket and Support Status (incident, case or HR ticket by number or text, updated in the last month), Escalate IT Ticket (urgency up one level with justification), My Assigned Equipment, **Open IT Ticket 2.0** (finds similar open incidents first and offers to comment on one; needs `com.snc.incident.ml`; replaces *Open IT Ticket* and *Report IT Issue*), Process Approval (`approver_user`), Service Disruptions, Walk-up Check-in (`com.snc.walkup`), Book Conference Room EXO / OnPrem, Get Zoom Meeting Recording, Set OOO reply (Exchange Online / Server), Windows 365 Cloud PC, Submit a request (deprecated in favour of the fallback setup topic), Get Password Reset Link (deprecated) | spokes: Exchange Online (`sn_ex_online_spke`), Exchange Server (`sn_exchange_spoke`), Zoom (`com.sn.zoom.spoke`), Azure AD (`com.sn.azure_ad.spoke`) |
| Password Reset | Change Password (logged in), Reset Password, Unlock Account | `com.glideapp.password_reset`, `com.snc.password_reset.virtual_agent`; process flagged **Enabled on Virtual Agent** |
| Office 365 groups | Add Owner, Add User, Create Group, Get Group Details, Remove Owner, Remove Users | Azure AD spoke |
| Active Directory | Add User to AD Group, Create AD Distribution Group, Remove User from AD Group, Show My AD Group Membership | AD spoke (`com.sn.ad.spoke`) |
| Meetings | Manage Meetings EXO v1.0 (schedule, reschedule, cancel; optional Teams, Webex, Zoom links), Manage Meetings EXS | Exchange spokes; attendees need emails in `sys_user` |
| Citrix | Reset Citrix Sessions, Provision Citrix Desktop/Apps | Citrix ITSM Connector (`x_cion_citrix_it_s`) |
| Cloud VMs | *CAI* topics (Start, Stop, Terminate, Describe on AWS and Azure; role `sn_managevm_va.cai_vm_user`); Manage Virtual Machine and Provision Virtual Machine | the latter two need Cloud Provisioning and Governance (`com.snc.cloud.mgmt`) |
| Setup | Dynamic Greeting Topic (first name, time of day, open incidents and requests, current outages) | |

Details worth keeping:

- **Local Admin Access** (macOS only): Agent Client Collector spoke (`com.sn.acc.spoke`), ACC plugin *admin-access-mac*, check definitions *check-admin-access* / *grant-admin-access*, and a sudoers entry allowing the `_servicenow` user to run the grant script. Access is removed for all users on the device after the set time, except those listed in `DEFAULT_ADMIN_USERS`.
- **Open IT Ticket**: with the Universal Request plugin and property `com.snc.create_universal_request_with_incident` = Yes (default; **Incident Properties**, category *Incident VA Conversation*), a universal request is created with the incident and its card is shown.
- **Submit a request**: non-conversational items open in a popup unless they have Custom, Custom with label or UI Page variables, in which case they open in the portal named by `sn_itsm_va.com.snc.itsm.virtualagent.portal_url`.
- Conference room lookups run in batches (10 rooms online, 50 on-premises), five shown at a time; minimum duration 30 minutes.

### Reusable topic blocks

(Many come with `com.glideapp.cs.sm_topic_blocks`.)

| Block | Inputs → outputs |
|---|---|
| Contextual Search | `context` (sys_id of a `cxs_context_config`), `query`, `portal` (URL suffix: sp, esc, csm, hr), `kb_knowledge_base` → `results_returned`, `results_helpful` |
| Create Incident | `caller`, `short_description`, `urgency`, `description`, `cmdb_ci` → `created_incident_sys_id` |
| Describe / Start / Stop / Terminate Virtual Machine | `vm_name`, `vm_sys_id` (`cmdb_ci_vm_instance`) → `incident_short_description` |
| Display Password Reset URLs | `unlock_account` |
| Request Catalog Item, Search Catalog Item | Service Catalog topic blocks |
| Schedule / Reschedule / Cancel a Meeting EXO, Conference Room Availability, Get MS Teams Meeting Link, Webex Meeting Actions, Zoom Meeting Actions | meeting data → status codes such as `MEETING_SCHEDULED`, `NO_ROOMS_AVAILABLE`, `TECHNICAL_ISSUE` |

## Actionable notifications

Interactive messages with buttons, sent on the user's chat channel. Enable under **System Notification > Provider > Notifications** (set **Active**), activate the Workflow Studio flows *ITSM Actionable Notifications trigger flow - Approval Reminder*, *- Incident commented*, *- Software Installation*, and enable notifications in Virtual Agent.

| Area | Notifications |
|---|---|
| Incident | commented (view the three latest comments, add one, resolve), opened on behalf of caller, resolved (close or mark unresolved, which reopens), update |
| Requested item | approved or rejected, approval reminder (approve or reject in chat), commented, opened on behalf, update, software installation (related articles from table `sc_2_kb`, or the one in property `sn_itsm_va.cat_item_related_kb`), Citrix provisioning |
| Approvals | requested item, request / change, knowledge article, other (non-task), task approval; fields shown come from script variable `approval_default_task_fields` in topic *_show_approval_details_* |
| Password | expiration reminder |
| Virtual machine | start or stop success / failure |
| Issue Auto Resolution | offer of help, reminder |

## Issue Auto Resolution (IAR)

Mostly part of `com.glide.cs.chatbot`; enabled automatically.

- Flow: an incident is created by portal or email → the NLU model looks for an IAR-enabled intent in **Short description** and **Description** above the confidence threshold → an actionable notification offers help → if accepted the mapped topic runs → the user says whether it worked and closes the ticket or leaves it open (then it goes to a live agent).
- While IAR holds an incident it may be assigned to *Virtual Agent*: check SLA and notification conditions that test "Assigned to is empty".
- The incident is released to an agent when: no topic for the intent in the incident's domain, topic not IAR-enabled, user not subscribed to notifications, user declines, ignores or abandons, or the topic did not solve it.
- Train: **Conversational Interfaces > Settings > Virtual Agent > ITSM Virtual Agent (IAR) > View Settings** > target table > Details > **Train**; when *Solution Complete* tick **Active**; optional **Retrain Frequency**. Training needs the record count in `glide.platform_ml.api.min_agent_zero_records` (300,000; do not raise it and keep the query under that number).
- Tab **Auto Resolution Intent Topic Maps**: shipped intents and their topics (HardwareIssues, LocalAdminAccess, VPNConnectivity, EmailIssues, RepositoryAccess, PrinterIssues, ResetPassword are mapped; CollaborationSoftwareIssues, HardwareRequest, SoftwareAccessRequest, SoftwareInstall, RSAToken, ManageDistributionList are not). Maps are inactive until you duplicate and publish the topic and activate the map. Tune intents in NLU Workbench.
- **AI Search fallback**: tab *AI Search* > **Apply AI Search** (EVAM definition *Virtual Agent Search*, search application *Service Portal default Search Application*, display topic *IAR - AI Search*). The email then offers **View recommendations** (articles, catalog items or a topic) on the portal incident's *Recommendations* tab; ordering the recommended catalog item closes the incident automatically after 24 hours.
- Dashboards: **Conversational Analytics > Virtual Agent Dashboard**, tab *Issue Auto-Resolution* (tasks solved, notifications ignored, not solved but answered); **Incident Auto-Resolution > Intent Analytics**. Roles admin, `virtual_agent_admin`, `chat_analytics_viewer`, `iar_admin`.

## Deflection tracking

Topics end in a deflection pattern; metrics are stored in `ssa_deflection_metric` (Self-Service Analytics, `com.snc.self_service_analytics_core`).

| Pattern | Outcome |
|---|---|
| ITSM VA-Self-Resolving, -Triage & Created, -KB-Resolve, -Intercept & Resolved (IAR), -AI-Search | confirmed deflection |
| ITSM VA-Search-served, -Query-response | potential deflection |
| ITSM VA-No-deflection; User Productivity and Agent Productivity (Complete, Info Provided, Incomplete) | no deflection |

These feed the Virtual Agent KPIs in [[Benchmarks]].

## Lite and Employee Slate

- **ITSM Virtual Agent Lite** (`com.snc.itsm.virtualagent.lite`, with `com.glideapp.sm_va_core`; no subscription; keyword-based): category *ITSM Self Service Lite* with *Check Ticket Status* and *Report an Issue* (record producer).
- **ITSM Employee Slate for Moveworks**: *Service Health Broadcast* widget (the three most recently updated outages, degradations or maintenance at the highest business criticality tier; statuses Outage, Degraded, Under maintenance, Operational; **View details** for all services; **Ask Otto** summarises, needs the Moveworks *Outage Lookup* plugin) and *Tech lounge* (walk-up check-in with live queue position and wait time, or book an in-person or remote appointment; needs the *IT Walk-up Visits* plugin and Walk-up Experience).

## Related

- [[Otto for ITSM Skills and Agentic Workflows]] · [[ITSM Predictive Intelligence, Task Intelligence and Virtual Agent]] · [[Contextual Search]]
