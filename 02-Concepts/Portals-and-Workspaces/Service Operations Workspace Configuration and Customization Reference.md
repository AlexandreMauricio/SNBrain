---
type: reference
tags: [reference, workspace, admin, incident, forms-lists, integrations]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Service Operations Workspace for ITSM", topics "Configuring Service Operations Workspace for ITSM to improve your experience" (redirection, navigation, inbox, alerts, list page, record pages, Standard Record Page, Agent Assist, cross-experience routes, Teams, interaction management, chat session tabs, voice interaction page, Notify, CTI) and "Customizing Service Operations Workspace for ITSM to align with your requirements" (landing page copy, incident Overview / Investigation / playbook / record information variants, SLA display, inline editing, Investigate tab, collection rules) (pp. 3414-3478), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Service Operations Workspace: configuration and customization reference

**What it is:** a lookup of the optional settings for Service Operations Workspace (SOW): where each lives (property, UX page property, table, view, script include) and what it changes. Essential setup is in [[Service Operations Workspace Access and Landing Page]] and [[Service Operations Workspace Admin Center and Process Setup]].

Upgrades skip objects that were customised, so duplicate shipped variants instead of editing them.

## Navigation and redirection

| Setting | Where | Notes |
|---|---|---|
| Classic module links open SOW | Admin Center > **Initial setup > SOW vs Classic UI16 redirection**; role `sn_exp_redirect.sn_redirect_config_admin` | *Global* (everyone) or *Custom* (per application and user group: Incident, On-Call Schedule, Problem, Major Incident, Change, Incident Alert, Request, Walk-up). Property `sn_sow_itsm_admin.experience_redirection_enabled.sow` = true redirects everyone regardless of the custom conditions |
| Module must support it | module **Link type** = URL, **Argument** = `sn_exp_redirect_redirect_handler.do?coreui=<classic URL>&uib=<workspace URL>&type=app_module&product=<id>` | the `coreui` and `uib` values must be URL-encoded (`?` = `%3F`, `=` = `%3D`, `&` = `%26`, space = `%20`), or the redirect fails because parameters are split at `&` |
| Order of side navigation modules | UI Builder > experience *Service Operations Workspace* > **Settings > Side navigation** | drag |
| Landing path | UX App Configuration *Service Operations Workspace*, field **Landing Path** | `home` or `list` |
| Copy of the landing page | UI Builder > Home > *Service desk landing page SNC* > **Duplicate variant** | created in the current scope; needed for any visual change |

## Inbox, chat, voice

| Setting | Where |
|---|---|
| Chat inbox | plugins Advanced Work Assignment (`com.glide.awa`) and Agent Chat (`com.glide.interaction.awa`); configure the Agent Chat queue. Agent status starts Offline |
| Auto-accept chats | **Advanced Work Assignment > Settings > Assignment Rules > Chat - Most Capacity**, related list *Auto-assign handling*: **Enable auto-assign work items**, **Display options** (Inbox card / Inbox card and workspace tab) |
| Interaction settings | Admin Center > **Interaction Management**: days of requester history shown (max 7), **Hide inbox when work item is accepted**, **Close Interaction when linked Incident is resolved** |
| Requester related records | EVAM view configuration *SOW Related Tasks* must have a lower order than *My Requests - Requested item predicate* |
| Chat session tabs | same card: toggle plus timers. Inactive chat tab with unread messages is purple, turns yellow at the warning timer (30 s) and red at the critical timer (guide gives both 1 min and 2 min as the default); unread counter; max 10 tabs; grey dot = unsaved changes. After a manual transfer the receiving agent starts clean; after an automatic transfer all messages count as unread. With Agent Whisper only the owning agent gets the timers |
| Voice interaction page | page variant *ITSM voice interaction record page* (inactive by default, order -2000; conditions: table `interaction`, type phone, interaction controls enabled). Needs Interaction Controls Component (`com.app_interaction_control`) and **OpenFrame > Configurations**: **Enable interaction controls**, **User Group**, provider **URL**. Left panel: call controls, customer history, optional live call transcript |
| Call from contact card | plugins `com.snc.notify`, `com.snc.cti`, `com.sn_openframe`; property `sn_sow.default_call_from_contact_page` = CTI; agent role `sn_openframe_user` |
| Conference provider | Admin Center > **Notify > Notify Configurations > Configure your provider preferences** (role `notify_admin`): provider selector with **Order**, **Source table**, **Condition**, **Catch-all**, **Manual selection**, plus *Provider Selector Choices* (conference provider or Notify group holding the numbers) |
| Notify properties | same place: Notify for task tables, public instance name (behind a reverse proxy), Notify numbers for Incident Communications, On-Call and Major Incident, max SMS length 1600 |
| Teams calls | **Notify > Microsoft Teams Guided Setup** (pre-published or self-configured apps) |
| Presence refresh | property `sn_sow_collab.user_presence_refresh_duration`; the larger of this and the channel's own value (`sn_tcm_collab_hook.teams.presence_status_cache_invalidate_duration`) wins |
| Teams import card fields | extension point `sn_tcm_collab_hook.MSTeamsTaskInfoCardHandler`, one implementation per task table |

## Alerts and lists

| Setting | Where |
|---|---|
| Alert auto-dismiss | UI Builder (bundle 28.1+) > experience settings > **Configure alerts**: per status (Critical, High, Moderate, Warning off by default; Info, Positive, Low on with 3 s), **Show time label**, **Expand alert content by default**. Otherwise edit UX page property `alert_auto_dismiss_config` |
| List counts | UX page property `fuzzyCount` (JSON): `{"default":-1}` exact count; `{"default":20}` shows "20+"; `{"default":20,"incident":10}` per table. Applies to lists, related lists and record associator lists |
| Inline list editing | property `glide.lists.inline_editing_enabled` = true (needed for asset actions on Affected CIs with Hardware Asset Management Professional) |
| Personal lists | **List > My Lists > Add new list** (from existing or own); one owner, shareable |

## Record pages

| Setting | Where |
|---|---|
| Fields on the form | open the record in the classic UI, switch **View** to *Service Operations Workspace* (saved record) or *Service Operations Workspace New Record*, then **Configure > Form Layout** / **Related Lists** |
| Incident Overview sections | view *SOW-Incident-Overview* (only fields also present in the *Service Operations Workspace* view) |
| Assign / Resolve dialogs | views *SOW Assign Modal* (incident, change) and *SOW Incident Resolve Modal*; only fields in the workspace view; client scripts and UI policies apply; no field decorators |
| Tab order | `sys_ux_app_route`, field **Order**. *Record Details Tab* is shared by every record page in several workspaces; the incident *Overview* route (app configuration SOW, parent macroponent *Record Page Tabs*) is specific |
| Activity stream tags | UX page property `activityStreamProps`: colour, icon, labels, tables. Collapsible tiles: `enableExpandableActivityStreamTiles` |
| Experts on-call panel | scripted extension point `sn_sow_on_call.ExpertsOnCallTabConfig` (implementation for incident shipped): `getTableName`, `getRecommendedFieldWatchList` (for example assignment group and CI), `getRecommendedGroups(recordGr, fieldWatchList)`, `isExpertOnCallTabSupported`. Server-side script includes |
| Hide the page side panel on a tab | UX page property `hideContextualSidebar` (JSON of table + tab pairs); the user group Schedule tab is hidden by default |
| SLA timers on incident | script include `SOWIncidentInfo`, function `getSLAConfig`: list of SLA timer configuration sys_ids with labels (Incident Response, Incident Resolution); the timer configurations need mappings |
| Share a record page with another workspace | table `sys_ux_interoperable_route` (UX cross-experience route): page, target workspace, optional usage condition such as `table=incident` |

### Standard Record Page (SRP)

The record page of SOW (UI Builder > *Service Operations Workspace* > Record > **SRP Record**; before version 4.0 it was *Record SNC*). **Presets** are the pre-wired mappings that come with a component; **controllers** hold the page logic and stay referenced by copies. ServiceNow does not support customised incident record pages.

- Tabs come from page collections: *SOW - Record tabs left* (before Details), *SOW - Record tabs middle* (after Details), *SOW - Sidebar tabs top* (side panel). Related list and repeater tabs are fixed.
- To change a shipped tab (incident Overview *Incident Overview SNC*, *SOW Investigate SNC*, *Playbook SNC*, *Record Information SNC*): **Duplicate variant**. If the duplicate dialog reports a Conditions error, empty the original variant's **Screen Condition** (keep a copy), duplicate, then paste it back. Give the copy a lower **Order** (lowest active order = default) and optional variant conditions.
- Screen conditions can be scripted (**Scripted Condition**, **Script**, **Parameter Mapping**).
- Agent Assist tab: variant *Agent Assist SNC* in *SOW Sidebar tabs top*; table list in **Screen Condition**, table → `cxs_table_config` sys_id in **Macroponent Configuration**.
- Modals: *Modal Container (Viewport)* > page collection *Record Page Modals* (all experiences) or *SOW Record Page Modals*.
- Declarative actions are wired in `sys_ux_addon_event_mapping` (**Source Component**, **Source Declarative Action**, **Controller**, **Target Event**, **Target Payload Mapping**); mappings with an empty **Parent Macroponent** use the controllers.

## Investigate tab

- Display: copy functions from script include `sn_sow.SOWInvestigateConfigSNC` into `sn_sow.SOWInvestigateConfig` (which metrics, thresholds, labels, units, card rows and columns, remedial action labels); data shaping in `sn_acc_adapter.AccTransformUtils` or `sn_mecm_adapter.MecmTransformUtils`. Role `script_include_admin`.
- **Collection rules** (**Metrics and CI Actions Framework > Administration > Collection Rules**): **Source table** (Incident), **CI field** (Configuration item), **Table conditions**, **CI class**, **CI conditions**, **Allow matching CI extensions**; related list *Collection Rule Metric Associations* names the metric definitions fetched automatically. A rule fires only when **Configuration item** changes on the incident.
- See [[Investigation Framework, CI Actions and Remedial Actions]].

## Related

- [[Service Operations Workspace for ITSM]] · [[Migrating from ITSM Agent Workspace to Service Operations Workspace]]
