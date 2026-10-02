---
type: concept
tags: [concept, workspace, incident, change, admin]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Service Operations Workspace for ITSM" (pp. 3215-3703), read in full 2026-10-02 (this note is the overview; detail is in the linked notes). The summaries of "Simplified IT Service Management" (pp. 223-291), "ITSM Mobile Agent" (pp. 2605-2727) and "Walk-up Experience" (pp. 3792-3872) at the end are still overview depth
sn-release: Australia
verified:
updated: 2026-10-02
---

# Service Operations Workspace for ITSM

**In one line:** Service Operations Workspace (SOW) is the configurable agent workspace (ITSM Professional and Enterprise) that replaces Agent Workspace and, increasingly, the classic UI16 forms for incident, request, change, problem, major incident, on-call and walk-up work.

## Who uses it

| User | Role | Records |
|---|---|---|
| Tier 1 agent | itil or `sn_sow.sow_home`, member of a service desk group | interaction, incident, request |
| Tier 2 agent | itil | incident, request, change, problem, major incident |
| Any workspace user | `sn_sow.sow_user` | |
| Admin Center | `sn_sow_itsm_admin.sow_admin_user`, admin | |

## Applications

`sn_sow_itsm_cont` (Service Operations Workspace ITSM Applications) and `sn_sow_itom_cont` (ITOM); per-process scoped apps `sn_sow_inc`, `sn_sow_chg`, `sn_sow_req`, `sn_sow_mim`, `sn_sow_walkup`, `sn_sla`; **Admin Center** `sn_sow_admin` / `sn_sow_itsm_admin`; Recommendation Framework `sn_rf`; Advanced Recommended Actions `sn_sow_itsm_ra_adv`; migration utility from Agent Workspace `sn_sow_migration`.

Being a UI Builder workspace, its forms, lists and actions are configured in UX tables (`sys_ux_list`, `sys_ux_form_action_layout`, `sysrule_view_workspace`, `sys_highlighted_value`), not in classic form layouts and UI actions alone.

## Features called out

Tier-specific landing page (outages, announcements, assignments), incident investigation with Agent Client Collector metrics, recommended actions from similar incidents and knowledge, on-call lookup, Microsoft Teams chat from a task, requests created from incidents and interactions, CAB workbench, major incident workbench, Universal Request and Universal Task, computer telephony integration, service-desk assisted password reset, Workforce Optimization, the Otto panel.

Properties seen: `sn_sow_inc.autoclose_origin.interaction` (close the originating interaction), `sn_sow_inc.pir.publish.hours`, `sn_sow_inc.pir_pdf_preview_sow_page`.

## UI16 redirection

- **New instances**: classic module links redirect to SOW by default and this cannot be configured without ServiceNow.
- **Upgraded instances**: Admin Center > **Initial setup > SOW vs Classic UI16 redirection** (role `sn_exp_redirect.sn_redirect_config_admin`): *Global* (everyone, everything) or *Custom* per application (Incident, On-Call, Problem, Major Incident, Change, Incident Alert, Request, Walk-up) and user group. Property `sn_sow_itsm_admin.experience_redirection_enabled.sow` = true overrides all conditions.
- A module is redirectable when its **Link type** is URL and its **Arguments** call `sn_exp_redirect_redirect_handler.do?coreui=<encoded classic URL>&uib=<workspace path>&type=app_module&product=<id>`. The `coreui` and `uib` values must be URL-encoded (`?` = `%3F`, `=` = `%3D`, `&` = `%26`), otherwise the redirect fails.
- Email links: `sow_email_notification_redirect` and its per-table variants ([[Incident Properties Reference]]).

This matters for this vault: procedures written with classic navigation paths may land in the workspace on a new instance.

## Detailed notes

- [[Service Operations Workspace Access and Landing Page]]: roles, tiers, audiences, login redirection, landing page
- [[Service Operations Workspace Admin Center and Process Setup]]: Admin Center cards, major incident and problem setup, notifications, password reset setup, AI Search
- [[Service Operations Workspace Configuration and Customization Reference]]: every optional property, view, UX table and script include
- [[Working Records in Service Operations Workspace]]: what agents do per record type
- [[Investigation Framework, CI Actions and Remedial Actions]] · [[Recommended Actions for ITSM]] · [[Migrating from ITSM Agent Workspace to Service Operations Workspace]] · [[On-Call Scheduling]]

## Extra roles for the SOW admin

The SOW admin role alone does not open every Admin Center card:

| Role | Opens |
|---|---|
| `sn_admin_center.read_only` | adoption blueprint on Overview and Learning |
| `script_include_admin` | greeting and "Upcoming" configuration (script includes) |
| `ui_builder_admin` | collapsed lists, contextual side panel app routes, list display count, Overview tab toggles |
| `personalize`, `form_admin`, `personalize_form` | field layouts of incident / problem / change record pages and list views |
| `dashboard_admin` | donut configurations |
| `evam_admin` | announcements |
| `user_criteria_admin` or `user_admin` | tier 1 visibility of the incident Overview tab |
| `sn_templated_snip.template_snippet_writer` | response templates |
| `incident_manager` | incident properties, major incident trigger rules, communication plan definitions |
| `problem_manager` | problem settings |

## Components and versions

Plugins installed with `sn_sow_itsm_cont`: `com.glide.ux.user_criteria`, `com.snc.uib.sn_dyn_rel_rec` (dynamic related records), `sn_sow_record` (record page), `sn_sow_quick_links`, `sn_sow` (core), `sn_sow_chg`, `sn_sow_collab`, `sn_sow_inc`, `sn_sow_incident_rf`, `sn_sow_interaction`, `sn_sow_interceptor` (task type chooser), `sn_sow_itsm_common`, `sn_sow_on_call`, `sn_on_call_onboard`, `sn_sow_problem`, `sn_sow_req`.

ITSM and ITOM workspace applications must be on matching versions (ITSM → ITOM): 1.1 → 21.0; 1.2 → 21.1; 1.3 → 21.2, 21.5, 21.6; 2.0 → 22.0; 2.1 → 22.1+; 3.1 → 23; 4 → 24; 5.0 → 24.2; 5.1.0 → 25.3; 6.1.1 → 26.1; 7.0 → 26.3.

Terms: *universal request* = parent record grouping the primary tickets of one user issue; *primary ticket* = the incident or catalog task under it; *service desk group* = assignment group whose members get the tier 1 landing page.

## Related products in the same guide

| Product | Summary |
|---|---|
| **Simplified IT Service Management** | AI-first packaging: guided and conversational setup with AI agents that configure the instance, an employee experience (Employee Center, *Employee Slate*) and a simplified fulfiller workspace with AI summaries and next steps. Apps `sn_itsm_adv_cont`, `sn_ai_itsm_cont`, change admin `sn_itsm_chg_admin` |
| **ITSM Mobile Agent** | mobile app content (`sn_itsm_mobile_agt`) for agents: My Work and My Team applets, incidents, on-call schedule, major incidents, push notifications |
| **Walk-up Experience** | plugin `com.snc.walkup`: walk-up locations and queues (`wu_location_queue`), reasons (`wu_reason`), appointments (`wu_appointment`), kiosks, badge check-in, stockrooms; online check-in; roles `sn_walkup.walkup_admin`, `walkup_manager`, `walkup_technician`, `walkup_login` |

## Related

- [[Incident Management Overview and Lifecycle]] · [[Major Incident Management]] · [[CAB Workbench]] · [[On-Call Scheduling]]
