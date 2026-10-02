---
type: reference
tags: [reference, roles, access-control, users]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Managing roles", topics "Base system roles", "Special administrative roles", "System roles" (pp. 367-437), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Base system roles

Roles present on every instance without extra plugins. Navigation: **All > User Administration > Roles** (table `sys_user_role`). Concepts: [[Role Management]], [[Users, Groups and Roles Overview]]. Grouped and paraphrased; "contains" lists the roles a role includes.

Roles cannot be renamed. Base roles can be deactivated but not modified. The guide repeats: **avoid granting admin when a narrower role exists.**

## Core

| Role | What it allows | Notes |
|---|---|---|
| `admin` | everything: overrides ACLs and passes all role checks | contains catalog, import, personalize_dictionary, sp_admin and many more. For sensitive areas (e.g. HR) create a custom admin role instead |
| `itil` | the technician role: open, update, close incidents, problems, changes; read CMDB. **Only itil users can have tasks assigned by default** | contains `cmdb_read`, `template_editor`, `view_changer`, `snc_platform_rest_api_access`, `sn_incident_write`, `sn_problem_write`, `sn_change_write`, `sn_request_write`, `email_composer`, `agent_workspace_user` and others |
| `itil_admin` | team leads: delete incidents, problems, changes (needs `itil` too). Full control of the CMDB (includes `sn_cmdb_admin` permissions) | contains `assessment_admin`, `cmdb_read` |
| `user_admin` | administer users, groups, locations, skills, companies | contains `skill_admin`, `territory_admin` |
| `approver_user` | act on approvals routed to them; plus requester capabilities | has a fee: check entitlement |
| `approval_admin` | view or modify approvals not assigned to them | needs a fulfiller licence |
| `impersonator` | impersonate users, **not admins** | |
| `user` | no functionality, grants nothing; users with it **count as licensed fulfillers** | |
| `public` | no login required for features with this role | |
| `nobody` | nobody has access, **not even admin or maint**; beats admin override on ACLs. Use only in ACLs, never assign to users; can be irreversible on system functions | |
| `maint` | reserved for ServiceNow; cannot be assigned or impersonated | |
| `snc_read_only` | restricts a user to read-only everywhere | see [[Role Management]] |

## Delegated administration ("special administrative roles")

Grant one administrative right without full admin.

| Role | Create, modify, delete |
|---|---|
| `assignment_rule_admin` | assignment rules |
| `business_rule_admin` | business rules |
| `client_script_admin` | client scripts |
| `ui_policy_admin` | UI policies |
| `ui_action_admin` | UI actions |
| `script_include_admin` | script includes |
| `ui_macro_admin`, `ui_page_admin`, `ui_script_admin` | UI macros, UI pages, UI scripts |
| `form_admin` | forms, sections and section elements |
| `script_fix_admin` | fix scripts (create and manage, **not run**) |
| `report_admin` | all reports and report objects |
| `data_policy_admin` | data policies |

## Personalize roles

`personalize` contains all of: `personalize_form`, `personalize_list`, `personalize_control` (list controls), `personalize_dictionary` (dictionary entries and labels), `personalize_choices`, `personalize_styles`, `personalize_responses`, and `personalize_rules` (which itself contains `business_rule_admin`, `client_script_admin`, `ui_policy_admin`, `ui_action_admin`). `personalize_ui` = form + list.

## Catalog, knowledge, reporting

| Role | Allows |
|---|---|
| `catalog` | read and some write on catalog requests, tasks, items |
| `catalog_admin` | manage the Service Catalog (contains `catalog`, `user_criteria_admin`, `catalog_builder_editor`, `catalog_template_editor`, `catalog_lookup_admin`) |
| `catalog_manager`, `catalog_editor` | manage or edit items in their categories |
| `knowledge`, `knowledge_admin` | write and review articles; manage knowledge bases |
| `report_user` | create and view reports shared with them |
| `report_group`, `report_global` | manage group-shared or global reports |
| `report_publisher`, `report_scheduler` | publish (public link); schedule emailing |
| `survey_admin`, `survey_creator`, `survey_reader` | surveys |

## CMDB and assets

| Role | Allows |
|---|---|
| `cmdb_read` | read any CMDB table (in `admin` and `itil`) |
| `sn_cmdb_user`, `sn_cmdb_editor`, `sn_cmdb_admin` | CMDB Workspace: read-only; create, edit, delete records; full access including policies |
| `cmdb_ms_user`, `cmdb_ms_editor`, `cmdb_ms_admin` | multi-source CMDB queries |
| `cmdb_dedup_admin` | de-duplication tasks |
| `ecmdb_admin` | Enterprise CMDB administration |
| `asset` | manage hardware and software assets (contains `inventory_user`, `contract_manager`, `category_manager`, `cmdb_read`) |
| `inventory_admin`, `inventory_user` | stockrooms and stock |
| `model_manager`, `category_manager`, `contract_manager` | models, model categories, contracts |

## Integration and data

| Role | Allows | Notes |
|---|---|---|
| `snc_platform_rest_api_access` | Table, Import Set, Aggregate and Attachment REST APIs | contained in `itil` |
| `soap` | query, create, update, delete on all tables and run scripts | contains `soap_create`, `soap_delete`, `soap_query`, `soap_update`, `soap_script`, `soap_ecc` |
| `soap_query`, `soap_create`, `soap_update`, `soap_delete`, `soap_query_update`, `soap_ecc`, `soap_script` | the individual SOAP operations | |
| `mid_server` | access for MID Server user accounts (contains `soap`) | |
| `import_admin` | everything about import sets (contains loader, transformer, scheduler) | |
| `import_scheduler` | schedule imports | **equivalent to admin**: can run scripts with admin privileges |
| `import_set_loader`, `import_transformer` | load import sets; manage transform maps and run transforms | |

## Other

| Role | Allows |
|---|---|
| `template_editor`, `template_editor_group`, `template_editor_global`, `template_scheduler` | personal, group, global templates; schedule template record creation |
| `filter_group`, `filter_global`, `filter_admin` | group filters, global filters, all filters (`sys_filter`) |
| `list_updater` | **Update Entire List** and **Update Selected** on lists |
| `task_editor` | edit protected task fields |
| `view_changer` | switch views |
| `image_admin` | images (`db_image`) |
| `timecard_user`, `timecard_approver`, `timecard_admin` | time cards |
| `workflow_creator`, `workflow_publisher`, `workflow_admin` | legacy graphical workflows |
| `text_search_admin`, `ts_admin`, `ais_admin`, `search_application_admin` | global text search groups, Zing, AI Search, search configuration |
| `agent_admin` | the built-in agent and MID Server scripts |
| `release_admin` | release history |
| `incident_manager`, `major_incident_manager`, `communication_manager` | incident properties and major incident roles |
| `data_classification_admin`, `data_classification_auditor` | Data Classification |
| `business_process_user`, `business_process_manager`, `business_process_admin` | business processes (granted through GRC roles) |
| `data_mgt_tools_admin` | data management tools ([[Data Management Overview]]) |

Applications add their own roles (CSM, HR, GRC, ITOM and so on); the guide only links to those lists.

## Related

- [[Role Management]] · [[Users, Groups and Roles Overview]]
