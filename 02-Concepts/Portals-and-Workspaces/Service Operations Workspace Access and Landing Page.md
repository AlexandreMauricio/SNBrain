---
type: concept
tags: [concept, workspace, roles, admin]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Service Operations Workspace for ITSM", topics "Exploring Service Operations Workspace for ITSM", "Access...", "user interface", "landing page", "Getting started with Service Operations Workspace for ITSM" (roles, users, theme, access controls, landing pages, audiences, redirection, landing page configurations), "Record page configurations", "Contextual side panel configurations" (pp. 3217-3228, 3280-3324), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Service Operations Workspace access and landing page

**In one line:** who gets into Service Operations Workspace (SOW), which landing page they see, whether they are sent there at login, and how the landing page and record pages are configured.

## Roles

Install the ITSM Roles plugin (`com.snc.itsm.roles`) first: without it the granular roles do not inherit workspace access.

| Role | Gives |
|---|---|
| `sn_sow.sow_user` | entry to SOW. Contained in itil; users with only custom or granular roles need it explicitly |
| `sn_sow.sow_home` / `sn_sow.sow_list` | landing page / list pages (both contain `sow_user`) |
| itil | all SOW pages |
| `sn_incident_read` / `_write`, `sn_problem_read` / `_write`, `sn_change_read` / `_write`, `sn_request_read` / `_write` | the record pages of that process, plus home and lists |
| `awa_agent` | the inbox (chat) |
| `sn_sow.it_agent_dashboard_user` | IT Agent Dashboard |
| `oc_read` | on-call pages; `rota_admin` for managing them |
| `sn_sow_itsm_admin.sow_admin_user` | Admin Center, incident configuration only |
| `sn_sow_admin.sow_admin_center_user` | Admin Center for change managers (contained in `change_manager`) |
| admin | everything, including Admin Center |

If a user with an inheriting role cannot get in: check the plugin, that the role is really assigned (directly or by group), and that no custom ACL blocks the pages.

## Tier 1 and tier 2

- **Tier 1** = itil user who belongs to a **service desk group**; **tier 2** = itil user who does not.
- Each landing page variant is tied to **audiences**; the audience with the lowest order that the user matches decides the page.

| Audience (base) | Role | Extra criterion | Page |
|---|---|---|---|
| SOW Common Audience | admin | | tier 1 |
| SOW Service Desk Audience Granular | `sn_incident_write` | group listed in user criteria *Service Desk Group Inclusion* | tier 1 |
| SOW Service Desk Audience | itil | same | tier 1 |
| SOW Tier 2/3 landing page Audience | itil | | tier 2 |

To add service desk groups: set `glide.ux.user_criteria_enabled` = true, then edit the **Groups** of the audience's user criteria (**Now Experience Framework > Building Blocks > Audiences**). New audiences are attached in UI Builder: experience *Service Operations Workspace* > *Home Landing Page* > variant > **Edit all audiences** (scope *Incident management for Service Operations Workspace*).

## Redirection at login

- Table `sys_homepage_destination_rule`, record **SOW Landing Page**: tick **Active** to send non-admin users to SOW (**Admin Center > Initial setup > Landing page redirection**). Clear it, then clear the cache (`<instance>.service-now.com/cache.do`), to stop it.
- Limit it to some groups: user criteria **ITIL non-admin** > **Groups**.
- Related properties: `glide.login.home`, `glide.next_experience.user_selected_landing_page_enabled` (users may choose their own landing page), `glide.ux.user_criteria_enabled`.

## Landing page content

| Section | Notes | Configure |
|---|---|---|
| Header | greeting and shift text ("You are on-call until..."); banner image `sow_banner.svg` (700 × 160) in `db_image` | script include `SOWServiceDeskAgentShift` (extends the read-only `...SNC`; server-side); UX page property `auto_expand_now_alert_message`; user preference `sow.incident.landing_page_header_collapsed` = false restores a closed banner |
| Overview ("donuts") | tier 1: incidents assigned, incident SLAs, unassigned incidents, catalog tasks; tier 2: incidents, problems, changes, tasks; "your work" / "your team" modes; delegated tasks | **Admin Center > Configure the landing page > Donut configurations**: override `getVisualizationConfig` in `SowIncidentLandingPageUtils` (tier 1) or `SOWLandingPageTier2Utils` (tier 2). Each donut: `id`, `tableName`, `myWorkQuery`, `myTeamQuery`, `groupByField`, `header`, `evamId`, `roles` (empty = everyone). `fetchTitle` / `getLabelMaps` give the list titles. Alternatively show a Platform Analytics dashboard (not both) |
| Donut colours | by the group-by field | **Reports > Administration > Chart Colors** (for example Name `incident`, Element `state`); SLA donut: **Report Ranges** (`task_sla`, `time_left`) |
| Announcements | outages, banner announcements, incidents | EVAM definition *SOW - Announcements*: add data sources; custom banners through `sn_sow.banner_announcements_config_id` |
| Upcoming | today's and tomorrow's tasks, shifts, time off | scripted extension point `sn_sow.UpcomingLinkProvider`: an implementation returns route items (a `simplelist` or `record` route with an encoded query) |
| Quick links, My performance, My active learning, Explore key features | the middle two need Workforce Optimization | toggles on the Landing Page form |
| New-tab menu ("+") | interaction and incident by default | UX page property `chrome_tab`, JSON `newTabMenu` (see [[Migrating from ITSM Agent Workspace to Service Operations Workspace]]) |

The useful encoded-query fragments in the shipped donuts: `assigned_toDYNAMIC90d1921e5f510100a9ad2572f2b477fe` (Me) and `assignment_groupDYNAMICd6435e965f510100a9ad2572f2b47744` (One of my groups).

## Other parts of the workspace

- **Lists**: per-process lists; **My Lists** for personal copies.
- **Inbox**: chat interactions for agents in the Agent Chat queue; status Available / Away; auto-assignment through the *Chat - Most Capacity* assignment rule, otherwise accept or reject.
- **Record view**: buttons at the bottom switch *Record only*, *Activity stream only*, *Split view* (resizable panes).
- **Guided tours** (help icon) and **guided setup** (**Adoption Services > Guided Setup**).
- Theme: store app Theme Builder (`sn_theme_builder`); Polaris cannot be copied, so create and apply a theme (instance-wide).

## Record page configuration

**Admin Center > Configurations**:

- **Incident Management > Incident record**: Overview tab (visibility for tier 1 by user criteria; sections Summary, Impact, Cause, Resolution), Details tab (record and new-record layouts, in form builder), response templates (role `sn_templated_snip.template_snippet_reader`), incident properties.
- **Change Management > Change record**: overview containers and section fields ([[Change Management Plugins, Tables and Workspace Configuration]]).
- **Contextual side panel**: UI Builder > *SRP Record* > Body > Resizable panes > right > Tab sidebar > *SOW - sidebar tabs top*; each tab is a UX screen whose **Screen Condition** (for example `controller.sowrecordctrl.table=incident^OR...`) decides the tables it shows on. Agent Assist: screen *Agent assist SNC*, **Macroponent Configuration** maps table → `cxs_table_config` sys_id (admin must be in the global domain).
- Experts on-call recommendations: script include `OnCallUtilsSow.getRecommendedGroups` (assignment group, the CI's support group, the service's support group).

## Related

- [[Service Operations Workspace for ITSM]] · [[ITSM Granular Roles]] · [[On-Call Scheduling]]
