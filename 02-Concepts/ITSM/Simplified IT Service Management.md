---
type: concept
tags: [concept, incident, change, request, ai, admin, portal]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Simplified IT Service Management" (pp. 223-291), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Simplified IT Service Management

**In one line:** Simplified ITSM is a pre-configured, AI-first packaging of ITSM: one-click defaults, a single **Configuration Console** where each area is set by a guided page or by a conversational AI agent, a simplified employee portal and a simplified agent view inside Service Operations Workspace.

## Applications and installation

| Application | Gives |
|---|---|
| IT Service Management (`sn_ai_itsm_cont`) | Incident and Request Management with default configuration, one-click install and upgrade |
| IT Service Management Advanced (`sn_itsm_adv_cont`) | adds Change (configured here), and Problem, Major Incident, On-Call, Walk-up (configured in the SOW Admin Center) |
| ServiceNow Otto for Setup (`sn_ia`) | prerequisite: the configuration console and its AI agents |

Auto-installed by subscription; otherwise **Admin Center > Application Manager**. Then **Admin > Admin Home > Manage your products > IT Service Management** (the Product Hub) > **Apply default configurations** (do not switch scope while presets are applied) > **Configure**.

Roles: admin; `sn_incident_admin` and `sn_request_admin` for those sections; change roles below.

## Configuration Console

Left pane: configuration summary and progress; **Configure with AI** (lists the agents); sections *Platform setup and integrations*, *Employee experience*, *Fulfiller experience*. Each page ends with **Mark as configured**. **Package and download** exports all configuration changes as an update set XML for another instance.

### Employee experience

| Area | Default | Notes |
|---|---|---|
| Employee Slate | none | AI-first home (search, requests, tasks, knowledge, communications), built either for Moveworks or for Otto; when it is installed on an upgraded instance the Taxonomy section is hidden |
| Service channels | Live agent chat routing and email inbound actions preconfigured; phone not | phone through ServiceNow Voice with Amazon Connect or Genesys |
| Virtual Agent | general settings, branding, live agent and generative settings | Teams and Slack integrations optional |
| Taxonomy | predefined for Employee Center | |
| Catalog items | prebuilt items and record producers active (list below) | Catalog Builder |
| Surveys | satisfaction surveys after incident resolution and request fulfilment | Survey Designer |

### Fulfiller experience

| Area | Default |
|---|---|
| Incident forms, lists, related lists | preconfigured |
| Incident categories | none (agent can propose industry sets or bulk import from Excel / CSV) |
| Agent inbox | incident routing to the inbox preconfigured (routing condition, work item size, max wait, group) |
| Routing | none: assignment rules, see [[Assignment Rules and Data Lookup Rules]] |
| SLA | response and resolution SLAs for P1 to P4 with their flows, see [[SLA Definitions and Task SLAs]] |
| Notifications | aligned with the Employee Center template |
| Requested item and catalog task forms and lists | preconfigured |
| Analytics | landing page dashboard (Assigned to you, Overdue, Unassigned) |
| Otto for ITSM | requester agents and the fulfiller workflows *Triage* and *Investigate and resolve* enabled; skills KB generation, incident and chat summarization, resolution notes, email generation enabled |

## Simplified Change Management

Plugin *ITSM Change Management Admin Experience* (`sn_itsm_chg_admin`). Same engine as [[Change Management Overview and Lifecycle]], reduced to Standard, Normal and Emergency with opinionated defaults; for multi-stage CABs or heavy workflow customisation use the full application. Console path **ITSM fulfiller experience > Change Management**.

Roles: `sn_itsm_chg_admin.admin` contains `sn_itsm_chg_admin.forms_config`, `sn_chg_setup.lists_config`, `.team_roles_config`, `.risk_config`, `.cab_config`, `.change_models_config`, `.change_schedules_config`, `.notification_config`. These **no longer inherit `sn_ia_config.ia_user`**: assign it explicitly or the console cannot be configured after an upgrade.

| Section | What is set |
|---|---|
| Forms | links to the workspace and to Form Builder (view *AITSM*) |
| Lists | columns of default and related lists |
| Team roles | **Change Manager** users or groups receive `change_manager`; **Implementation groups** receive `sn_change_write`; removing revokes. A group cannot be added if its parent is already there |
| Risk configuration | eight seeded risk assessment questions (question, order, type, active; each response has a score; mandatory flag); thresholds: 0-25 Low, 26-50 Moderate, 51+ High (Moderate threshold must be below High). The level routes the change to its approvals. See [[Change Risk Calculation and Assessment]] |
| CAB | members, **CAB manager**, recurring meeting schedule (weekly, monthly, specific), and the conditions that put a change on the agenda (risk, type, priority...); at least one condition. See [[CAB Workbench]] |
| Change models | below |
| Change schedules | blackout (blocked) or maintenance (allowed only then) schedules; scope All CIs, a CI class, or change request attributes; one time, weekly, monthly, yearly, specific. See [[Change Conflict Detection and Maintenance Schedules]] |
| Notifications | shipped set: assignment, work note and comment updates, approved / rejected, on hold, state changes, emergency and unauthorized change created, CAB invitations, calendar events, external change registered, survey. New ones through the standard notification form |

### Change models

| Model | Configurable |
|---|---|
| Normal | **Available for new change requests**; templates; approvers per risk level for **Assess** (default: member of assignment group for all levels) and **Authorize** (default CAB member for Moderate and High); automatic task creation in Scheduled, Implement, Review |
| Standard | templates only (pre-approved; no availability, approval or task settings) |
| Emergency | who may submit (only users with `sn_change_write` are selectable), who is emailed on creation and with which template, Authorize approvers, automatic tasks |
| Change Registration | records changes made outside the process by external teams or vendors; no approvals; who may register and who is notified |

Approver choices: member of assignment group (one approval suffices), manager of assignment group, change manager, CAB member, other group.

**Activating the plugin** makes the simplified Normal, Emergency and Change Registration models the active defaults and deactivates the classic global ones, except a classic Normal or Emergency model you have customised is left untouched (still not the default). Standard, Unauthorized, Cloud and Cloud Infrastructure are unchanged. Standard changes then require short description, description, risk, impact, justification, assignment group and planned dates, and **Work notes** become read-only without the change manager role. Reverting is done by ServiceNow Support, not by hand. See [[Change Models and Change Templates]].

## Employee side

- **Employee Center**: AI search (shipped external sources: Microsoft Support, Zoom, Webex, Okta, Apple Support, Zscaler), **Open IT Ticket** (record producer *Create incident with Now Assist*: solutions appear as you type; **Solution found** or **Proceed with incident creation**; **Save as Draft**), **Browse catalogs**, tasks, requests, favourites, chat (type "live agent" or **Contact Live Agent**). Can sit behind Moveworks, Teams or Slack.
- **Employee Slate**: conversational requests ("request standard laptop", "raise an incident that my vpn is not working") leading to the order or incident form.

## Fulfiller side

- Users with `sn_service_desk_agent` get the **simplified view** in Service Operations Workspace even on higher tiers; to use the full workspace (major incidents and so on) the user must not have that role alongside itil.
- Landing page: Assigned to you, Overdue (breaching or about to), Unassigned; lists of incidents, requests, catalog tasks.
- Accepting a chat (inbox status Available, with Chat and Incident capacity ticked) creates an incident; the view has a chat / details pane and an overview / related records pane. Chat quick actions: start an autopilot topic, end chat, response templates, search KB, chat summary, transfer to agent or queue.
- Incident overview: *AI summary and next steps* (summary, proposed next steps, **View steps and history**, follow-up question, open the Otto panel), *Related search results* (up to four; filter Incident, Knowledge, Catalog; actions attach article, link or copy incident, order item), Compose, Activity (inline, split or tab).
- **Service Desk Team Dashboard** (role `service_desk_manager`): incident and requested item backlog, team MTTR, missed SLAs, reassignments; filter by group and date.

## AI agents

| For | Agents |
|---|---|
| Admin setup | AI Search Configuration Agent; AI Search XCC Agent (external content connectors, SharePoint); Group and roles assignment agent; IA Operational Data Workflow Agent (imports users, groups, locations, departments through data sources and transform maps); SSO Configuration Agent (SAML, OIDC) |
| Employee and fulfiller configuration | Implementation Plan Manager Agent (surveys; incident, requested item and catalog task forms and lists); Incident routing configuration agent; Incident Category Configuration AI Agent; Notification Agent; SLA Management AI Agent; Change Forms, Lists, Team Role, Risk, CAB, Models and Schedule Configuration Agents (team roles and CAB also from an uploaded PDF, DOCX, XLSX or CSV) |
| Employees | Create Incident AI Agent (self-service first, then live agent, incident or request); Approval Assistance Agent (lists pending approvals, builds a checklist from knowledge and the requester's details, approves or rejects); Request Status Agent (existing tickets only: status, comments, attachments) |
| Fulfillers | *Investigate and resolve ITSM incidents*, *Triage and categorize ITSM incidents*: [[Otto for ITSM Agentic Workflows and AI Agents Reference]] |

## Catalog items shipped

Distribution list add / remove and create; application password reset and unlock; business applications support; shared drive create and access; data integration and API users; data reporting; storage and backup; database management; elevated or temporary admin access; employee onboarding and offboarding; end-user device management; file sharing and collaboration; general IT help; identity and access management; loaner laptop; MFA setup or reset; network infrastructure and firewall; report network issue; application access; mobile phone / SIM; new desktop, laptop, software licence, peripherals; printer access; software upgrade or patch; virtual machine; VPN access issue.

## Related

- [[Service Operations Workspace for ITSM]] · [[Otto for ITSM Skills and Agentic Workflows]] · [[ITSM Application Suite Overview]]
