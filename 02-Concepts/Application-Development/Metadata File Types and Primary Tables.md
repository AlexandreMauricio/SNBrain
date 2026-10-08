---
type: reference
tags: [reference, platform, schema, glossary, scripting, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Developing your application > ServiceNow Studio > Reference (read 2026-10-08 through the docs site): ServiceNow Studio Navigator panel taxonomy, Metadata record categories in the ServiceNow Studio Navigator, ServiceNow Studio supported file types using code search. https://www.servicenow.com/docs/r/application-development/servicenow-studio-classic/servicenow-studio-file-navigator-taxonomy.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Metadata File Types and Primary Tables

**What it is:** a label-to-table lookup for application files ("metadata"): every type in the ServiceNow Studio Navigator with the table that stores it and the tool that edits it. All of these tables extend Application File (`sys_metadata`); any other extension of it also shows up in the Navigator.

From the Brazil docs. Use with [[ServiceNow Studio Overview, Access and Navigation]] (typing `<table>.list` in Studio search opens the list). "Classic" below = the ordinary form (the docs say UI16).

## AI

| File type | Table | Edited in |
|---|---|---|
| Agentic Workflow | `sn_aia_usecase` | AI Agent Studio |
| AI Agent | `sn_aia_agent` | AI Agent Studio |
| Skill | `sn_nowassist_skill_config` | classic |

## Automation

| File type | Table | Edited in |
|---|---|---|
| Action; Data stream | `sys_hub_action_type_definition` | Workflow Studio |
| Flow; Subflow | `sys_hub_flow` | Workflow Studio |
| Trigger (saved) | `sys_hub_trigger_template` | Workflow Studio |
| External trigger | `sys_ih_external_trigger_definition` | classic |
| Decision table | `sys_decision` | Workflow Studio |
| Playbook | `sys_pd_process_definition` | Workflow Studio |
| Activity definition | `sys_pd_activity_definition` | classic |
| Connection and Credential Alias | `sys_alias` | classic |
| Notification | `sysevent_email_action` | classic |
| Email Template | `sysevent_email_template` | classic |

## Schedules

| File type | Table |
|---|---|
| Schedule | `cmn_schedule` |
| Blackout Schedule | `cmn_schedule_blackout` |
| Maintenance Schedule | `cmn_schedule_maintenance` |
| Relative Duration | `cmn_relative_duration` |
| Risk Conditions | `risk_conditions` |

## Data

| File type | Table | Edited in |
|---|---|---|
| Table | `sys_db_object` | Table Builder |
| Table Column | `sys_dictionary` | classic |
| Form | `sys_ui_form` | Form Builder |
| Form section | `sys_ui_section` | Form Builder |
| Many to Many Definition | `sys_m2m` | classic |
| Relationship | `sys_relationship` | classic |

## Client development

| File type | Table |
|---|---|
| Client Script | `sys_script_client` |
| UI Policy | `sys_ui_policy` |
| UI Script | `sys_ui_script` |
| Data Lookup Definitions | `dl_definition` |
| Assignment Data Lookup | `dl_u_assignment` |
| Priority Data Lookup | `dl_u_priority` |
| Client Extension Point / Instance | `sys_client_extension_point` / `sys_client_extension_instance` |
| UI Extension Point / Instance | `sys_ui_extension_point` / `sys_ui_extension_instance` |

## Server development

| File type | Table |
|---|---|
| Business Rule | `sys_script` |
| Script Include | `sys_script_include` |
| UI Action | `sys_ui_action` |
| Fix Script | `sys_script_fix` |
| Scheduled Script Execution | `sysauto_script` |
| Script Action | `sysevent_script_action` |
| Event Registration | `sysevent_register` |
| Data Policy | `sys_data_policy2` |
| Extension Point / Instance | `sys_extension_point` / `sys_extension_instance` |

## Security

| File type | Table |
|---|---|
| Access Control | `sys_security_acl` |
| Role | `sys_user_role` |
| Public Pages | `sys_public` |

## Properties

| File type | Table |
|---|---|
| System Property | `sys_properties` |
| System Property Category | `sys_properties_category` |
| Message | `sys_ui_message` |

## Integrations

| File type | Table | Direction |
|---|---|---|
| Data Import (Integration Hub - Import) | `sn_ihub_integration_instance` | in |
| Data Source | `sys_data_source` | in |
| Scheduled Data Import | `scheduled_import_set`; also `scheduled_data_import` | in |
| Table Transform Map | `sys_transform_map` | in |
| Scripted REST API | `sys_ws_definition` | in |
| Scripted Web Service | `sys_web_service` | in |
| REST Message | `sys_rest_message` | out |
| SOAP Message | `sys_soap_message` | out |
| Export Definition / Set / Target | `sys_export_definition` / `sys_export_set` / `sys_export_target` | out |
| Scheduled Data Export | `scheduled_data_export` | out |

## MID Server

| File type | Table |
|---|---|
| MID Server Application | `ecc_agent_application` |
| Capability Value Test | `ecc_agent_capability_value_test` |
| IP Range | `ecc_agent_ip_range` |
| Property | `ecc_agent_property` |
| Script File | `ecc_agent_script_file` |
| Script Include | `ecc_agent_script_include` |

## User interface

| File type | Table | Edited in |
|---|---|---|
| Application menu (the docs label it "Application Module") | `sys_app_application` | classic |
| Module | `sys_app_module` | classic |
| List | `sys_ui_list` | classic |
| List Control | `sys_ui_list_control` | classic |
| Related List | `sys_ui_related_list` | classic |
| Context Menu | `sys_ui_context_menu` | classic |
| View Rule | `sysrule_view` | classic |
| Style | `sys_ui_style` | classic |
| Theme | `sys_ui_theme` | classic |
| Template | `sys_template` | classic |
| UI Page | `sys_ui_page` | Fluent source |
| Catalog | `sc_catalog` | Catalog Builder |
| Catalog Item | `sc_cat_item` | classic |
| Record Producer | `sc_cat_item_producer` | Catalog Builder |
| Workspace; Portal (Next Experience) | `sys_ux_page_registry` | Workspace Builder; UI Builder |
| Service Portal | `sp_portal` | Service Portal |
| Assessment Metric | `asmt_metric` | Survey Designer |
| Embedded Help; Qualifier | `sys_embedded_help_content`; `sys_embedded_help_qualifier` | classic |
| Guided Tour | `sys_embedded_tour_guide` | classic |
| Map Page; Schedule Page; Timeline Page | `cmn_map_page`; `cmn_schedule_page`; `cmn_timeline_page` | classic |

## UI Builder

| File type | Table |
|---|---|
| Experiences | `sys_ux_page_registry` |
| Components | `sys_ux_macroponent` |
| Controllers (data and UI controllers) | `sys_ux_controller` |
| Page collections | `sys_ux_extension_point` |
| UI interactions | `sys_ui_interaction` |

## Content

| File type | Table |
|---|---|
| Images | `db_image` |
| Audio | `db_audio` |
| Static / Dynamic / Detailed content; iFrames | `content_block_static` / `content_block_programmatic` / `content_block_detail`; `content_block_iframe` |

## Mobile

| File type | Table | Edited in |
|---|---|---|
| Mobile app config | `sys_sg_native_client` | Mobile App Builder |
| Launcher screen | `sys_sg_applet_launcher` | Mobile App Builder |
| List / Record / Input form screen | `sys_sg_list_screen` / `sys_sg_form_screen` / `sys_sg_parameter_screen` | Mobile App Builder |
| Calendar / Chart / Map / Custom Map / Mobile web screen | `sys_sg_calendar_screen` / `sys_sg_chart_screen` / `sys_sg_map_screen` / `sys_sg_custom_map_screen` / `sys_sg_browser_screen` | Mobile App Builder |
| Function | `sys_sg_button` | Mobile App Builder |
| Analytics preview | `sys_sg_chart` | Mobile App Builder |
| Card; Card template | `sys_sg_view_config`; `sys_sg_view_template` | Mobile Card Builder |

## Reporting and NLU

| File type | Table |
|---|---|
| Report | `sys_report` |
| Scheduled Email of Report | `sysauto_report` |
| Dashboard | `pa_dashboards` (Dashboard Builder) |
| Metric Definition | `metric_definition` |
| Range | `sys_report_range` |
| Chart Colors; Color Definition | `sys_report_chart_color`; `sys_report_color` |
| NLU Model | `sys_nlu_model` |

## Tables searched by Studio code search

The default code search group covers: `sys_security_acl`, `sys_script`, `sys_script_client`, `sysevent_email_template`, `sysevent_in_email_action`, `cmn_map_page`, `sys_transform_map`, `sysevent_email_action`, `sys_processor`, `sys_relationship`, `sysauto_script`, `sysevent_script_action`, `sys_script_include`, `sys_ui_action`, `sys_ui_macro`, `sys_ui_page`, `sys_ui_policy`, `sys_ui_script`, `sys_ui_style`, `sp_widget`. An admin can define another code search group with more tables; only tables extending `sys_metadata` qualify. The page lists schedule items (`sys_trigger`) in the table yet states in a note that they are not searchable.

## Related

- [[ServiceNow Studio Overview, Access and Navigation]] · [[ServiceNow Studio Source Control, Fluent Apps and Deployment]] · [[Tables, Records and Table Relationships]] · [[Business Rules]]
