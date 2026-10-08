---
type: reference
tags: [reference, flows, automation, roles, access-control, ai, data-management, admin]
status: documented
source: ServiceNow Australia Build workflows PDF, "Configuring Playbooks" (pp. 30-55: activation per product and the tables each plugin unlocks, AI skills, default LLM, admin modules, roles, content filtering, archiving process contexts, data definitions, accessibility) and "Building Playbooks" (pp. 142-171: AI generation from text, image and knowledge article, recommendations, activity preview, summarization, playbooks as MCP tools, translations), read in full 2026-10-08
sn-release: Australia
verified:
updated: 2026-10-08
---

# Playbooks Administration, Roles and Access

**What it is:** licensing, roles, content filtering, housekeeping and the AI and MCP options around playbooks ([[Playbooks Overview and Components]]).

## Which tables a playbook may trigger from

Playbooks ship with the platform, but a trigger table must be covered by a subscription: the application's own tables, custom tables extending them, or custom tables the subscription authorises. If the tables are not offered, request the matching plugin (**All Available Applications > Request plugin**).

| Plugin | Unlocks |
|---|---|
| Process Automation Designer for App Engine (`com.glide.pad.license`) | custom tables you create, plus a long platform list: users, groups and roles, locations, companies, departments, the CMDB base and relationship tables, outages, knowledge, assessments, Advanced Work Assignment, on-call rotas, Interaction (`interaction`), Ticket (`ticket`), Universal Request, private tasks, ATF, portal tables |
| Playbooks for Customer Service Management (`com.sn_csm_playbook`) | Case, Account, Contact, Consumer, Interaction and other customer service tables; **Incident**, **Problem**, **Change Request** and **Request** only together with the Customer Service with Service Management / Request Management plugins |
| Playbooks for Field Service Management (`com.sn_fsm_playbook`) | work orders, work order tasks and related tables |

A table belonging to another product's playbook plugin cannot be used without that plugin. The guide does not name the plugin that covers ITSM tables on their own (`?`); ITSM playbooks exist in Service Operations Workspace ([[Investigation Framework, CI Actions and Remedial Actions]]).

Recommended Store updates: Playbooks, Playbook Experience, Process Automation Content, Process Automation Demo Experience.

## Roles

| Role | Can | Contains |
|---|---|---|
| `playbook.admin` | everything: trigger and activity definitions, playbooks, shared experience tables | `pd_author`, `pd_content_author`, `pd_trigger_author`, `pd_operator`, `pd_cancel` (the diagram also lists `pd_restarter` and `pd_shared.admin`) |
| `pd_author` | create, activate, edit, delete playbooks; view all activity definitions | `playbook.write`, `playbook.activity_def_read`, `pd_shared.user` (and `playbook.designer_access`, `sn_workflow_studio.workflow_studio_read`, `sn_diagram_builder.db_read` per the diagram) |
| `pd_content_author` | create, edit, delete activity and trigger definitions | `pd_trigger_author`, `pd_shared.user`, `playbook.activity_def_read` |
| `pd_trigger_author` | trigger definitions | |
| `pd_operator` | read process and activity executions and logs | |
| `pd_cancel` | cancel running playbooks without admin or write access to the record (for example an agent manager) | |
| `pd_restarter` | restart active playbooks | |
| `playbook.write` | build playbooks, subject to content filtering | `pd_shared.user` |
| `playbook.designer_access` | open playbooks read-only, subject to content filtering | `pd_shared.user` |
| `playbook.activity_def_read` | see all activity definitions that have no Required Roles | |
| `pd_shared.user` / `pd_shared.admin` | read / edit Experience activity types (`sys_pd_activity`) and their properties (`sys_pd_activity_type_prop`) | |

The guide writes some roles two ways (`playbook.admin` and `playbook_admin`; `pd_author` and `playbook_author`): check `sys_user_role`. Access can also be given through **delegated development** (an application plus the playbook developer permission).

## Content filtering

Limits which activity definitions an author sees.

- **Content definition** (**Process Automation > Flow Administration > Content Definitions**): **Name**, **Application**, **Table** (for example `sys_pd_activity_definition`), **Conditions**, **Resource Tags**.
- **Content filtering rule** (**... > Content Filtering Rules**): **Name**, **User Role**, **Delegated Development Permission**, **Active**, **Application**, **Resource Definition**.

Shipped: definition *Playbooks - All Activity Definitions* with two rules giving `delegated_developer` and `playbook.activity_def_read` access to everything. To restrict someone to a subset, give them `playbook.write` (not `pd_author`) plus a rule for a narrower definition. **Required Roles** on an activity definition overrides filtering. A playbook containing an activity the user cannot access, or a process definition they cannot write, opens read-only.

## Monitoring modules

Today's Executions, Active Processes, 30+ Day Processes, Activity Definitions, Asset Configuration, Trigger Definitions, Data Definitions.

## Archiving process contexts

Archiving compresses a finished execution's detail records into one read-only JSON on the Process Execution (`sys_pd_context`): element mappings (`sys_element_mapping`), context logs (`sys_pd_context_logs`), variable values (`sys_variable_value`), activity contexts (`sys_pd_activity_context`), stage contexts (`sys_pd_lane_context`). **It cannot be undone**; agents still see history such as who an activity was assigned to.

| Aspect | Detail |
|---|---|
| Automatic | executions Complete, Skipped or Cancelled whose playbook has not been edited for 14 days |
| Change the wait | property `sn_pa_designer.data_retention_policy` (days; 0 = at once). Edit only **Value** |
| Turn off | property `sn_pa_designer.enableDataRetentionFeatures` = false |
| Manual (needed for Error) | `sys_pd_context.list` > select rows > **Archive Process Contexts**. Large sets go in hourly batches |
| View | add the **Archive** field to the process execution form layout |

Flow contexts (`sys_flow_context`) are deleted two weeks after completion on their own schedule. Related: [[System Archive and Archive Rules]], [[Table Cleaner]].

## Data definitions

Named sets of variables collected during one run and stored in `sys_flow_data` rather than on a record (**Process Automation Administration > Data Definitions**, table `sys_flow_data_definition`; variables with **Type**, **Label**, **Column name**, **Max Length**, default value, choices). Only for data needed later in the same run and never reported on. They fed the *Collect user data* activity, which the Questionnaire activity replaced in 26.1.

## AI for authors

Needs ServiceNow Otto for Creator (`sn_now_creator`); turn skills on under **Admin > AI Admin Hub > AI Skills > Creator** (role admin).

| Skill | Does |
|---|---|
| Playbook generation, Playbook generation with images | **New > Playbook > Create with AI**: name, scope (fixed once a preview exists), instructions and optionally one image (JPG, PNG, WEBP up to 10 MB); execution type and parent table; **Generate playbook preview**, **Regenerate preview**, **Save and edit playbook**. Unknown steps become placeholder activities. It knows the names of active actions, subflows, flows and activity definitions on the instance (refreshed hourly). Separate subscription |
| Playbook generation with KB | the same from a knowledge article the user can read; the article outranks typed instructions; up to 13,000 characters; articles that are not a step-by-step process are refused |
| Playbook recommendations | one to five suggestions for a placeholder activity, from its label and description; only ServiceNow-shipped definitions, flows and actions. Hide per playbook with the *Show recommendations* preference |
| Playbook summarization | **More actions > Summarize**: Standard, Short or Elaborate; refine by instruction; **Set as description**; warns when the playbook changed since (**Refresh**) |

Default model for generation: `sys_one_extend_capability.list` > *Playbook Generation* > tab *OneExtend Definition Configs* > set **Default** true on one row and false on the other (the guide names the Now LLM and an OpenAI model; the latter not in APAC).

**Preview an activity** (`playbook.admin`): hover the card > **Edit UI Layout**. The preview renders design-time values; parts fed by automation outputs are simply absent. Unresolvable record pills accept **sample data** for the preview only.

## Playbooks as MCP tools

A playbook can be exposed as a tool in an MCP server (**All > MCP Server Console > Tools > Create tool > Playbook**: playbook, label, a specific description the client uses to decide when to call it, active, server; roles `sn_mcp_server.tools_admin`, `sn_mcp_server.admin`). Compare [[ITSM MCP Server]].

Compatibility: every stage and activity starts immediately (no delays); only Create Record Form, Record Form, Questionnaire, Send Email, Knowledge, Instruction and Decisions; every referenced subflow or action marked **Execution Type: MCP-compatible**; only primitive form fields (no references, rich text, attachments or custom types).

## Translations

From app version 27.1. Activate the playbook, open it in `sys_pd_process_definition.list` > tab **Translated Messages**: one UI message per playbook label, stage label, activity label and description, and HTML or string layout property. Set **Language** and **Message**. Automation inputs (email text, record values) are not translated.

## Accessibility

**User menu > Preferences > Accessibility > Show all buttons without the need to hover** makes the diagram's edit and delete buttons always visible.

## Related

- [[Playbooks Overview and Components]] · [[Playbook Activities, Decisions and Variants]] · [[Workflow Studio Overview]]
