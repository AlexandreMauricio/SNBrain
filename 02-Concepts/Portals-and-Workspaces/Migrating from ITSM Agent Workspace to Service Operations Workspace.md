---
type: reference
tags: [reference, workspace, admin, schema]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Service Operations Workspace for ITSM", topic "Migration from ITSM Agent Workspace to Service Operations Workspace for ITSM" and its subtopics (pp. 3231-3280), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Migrating from ITSM Agent Workspace to Service Operations Workspace

**What it is:** a migration utility (application `sn_sow_migration`) copies Agent Workspace customisations into Service Operations Workspace (SOW). This note records what it moves and, more usefully, **which table holds each kind of workspace configuration** on both sides.

## Running it

Run in a **non-production** instance and carry the result to production in an update set.

1. Install *Migration Utility for Service Operations Workspace*.
2. Custom ITSM tables: add them to property `sn_sow_migration.itsm_aw_migration_tables`.
3. Create a basic auth configuration (`sys_auth_profile_basic`) with the credentials of the **logged-in admin** (the utility calls the Table API as that user). Create it before the update set.
4. Create and select an update set; set the application scope to *Service Operations Workspace Core*.
5. **Service Operations Workspace Admin Center > Overview > Initial Setup > Migrate from ITSM Agent Workspace to SOW**: test the configuration, **Start migration**, choose features per process, **Confirm the migration**. A partial run can be resumed with **Continue migration**.
6. **View migration details** and the system log for failed items; do the post-migration checks below.

Requests are stored in `sn_sow_migration_aw_migration_request`. "Completed" does not mean every import set succeeded.

## What is migrated and where it lives

| Feature | Agent Workspace table | SOW (UX) table | How it works / what to check |
|---|---|---|---|
| UI actions and their grouping | `sys_ui_action`, `sys_aw_form_uiaction_layout`, `sys_aw_form_uiaction_group` | `sys_ux_form_action`, `sys_ux_form_action_layout`, `sys_ux_form_action_layout_group`, `sys_ux_form_action_layout_item`, `sys_ux_m2m_action_layout_item` | Actions are grouped only if a layout record exists for the table. To reorder: open the layout for the table, **Unify action** if not unified (`use_layout_items_only`), then set the order in **UX Form Action Layout Items** |
| Ribbons | `sys_aw_ribbon_setting` | `sys_ux_ribbon_config`, mapping `sys_ux_ribbon_config_setting` | Total ribbon width per table must be ≤ 12; if the sum exceeds 12 the **existing SOW ribbons are disabled** in favour of the migrated ones |
| Views and view rules | `sysrule_view_workspace` | `sys_ux_view_rules_configuration`, mapping `sys_ux_m2m_workspace_view_rule_ux_view_rule_config` | A fallback rule (view `workspace`, order 99999999) is created per table. UI policies and client scripts tied to the view then work in SOW. Preconfigured SOW view rules may be turned off |
| New-record menu | `sys_aw_new_menu_item` | UX page property `chrome_tab` (`sys_ux_page_property`), JSON key `newTabMenu` | One JSON object per table (label, `routeInfo` with route `record`, table and sysId `-1`, `condition.tableDescription.canCreate`) |
| Highlighted values | `sys_highlighted_value`, `sys_highlighted_value_condition` | mapping `sys_ux_m2m_highlighted_value_config` | With several records for one table and field, the condition with the lowest order wins |
| List, related-list and field declarative actions | `sys_declarative_action_assignment` (model List / Related List / Field, workspace Agent Workspace) | same table, linked to action configuration *SOW Actions* through `sys_ux_m2m_action_assignment_action_config` | Failed ones are redone by hand: **Insert and Stay**, clear **Workspace** and **View**, tick **Experience Restricted**, add *SOW Actions*. Client actions become *UXF Client Action*. `ITEM_SELECTED` and `PREVIEW_RECORD` do not work in SOW: use a `CREATE_NEW_RECORD` payload in `sys_declarative_action_payload_definition`. Multiple Record Associator and interceptor actions also need add-on event mappings (`sys_ux_addon_event_mapping`). Duplicates appear if view rules were not migrated |
| Interceptor record type selectors | `aw_record_type_selector` | `sn_sow_interceptor_record_type_selector` | The standard change entry is migrated inactive |
| List categories and lists | `sys_aw_list_category`, `sys_aw_list`, `sys_aw_list_attribute` | `sys_ux_list_category`, `sys_ux_list`, applicability `sys_ux_applicability_m2m_list` | Existing SOW categories are updated, missing ones created (configuration *Default - SOW*, view `sow`), none deleted. Column layout comes from `sys_ui_list` / `sys_ui_list_element`. Group-based applicability needs `glide.ux.user_criteria_enabled` |
| Form headers | `sys_aw_form_header` | `sys_ux_header_config`, mapping `sys_ux_m2m_workspace_header_ux_header_config` | The header with the lowest order applies; the utility lowers the order so the Agent Workspace header wins |
| Global search | `sys_aw_master_config`, `sys_search_source`, `m2m_search_context_config_search_source` | `sys_search_context_config`; page properties `globalSearchDataConfigId`, `global_search_configurations` | Only when the search engine is Zing. Compare in `sow_search_config.list` |
| Agent Assist (contextual search) | declarative action with component `now-agent-assist`, attribute `cxsTableConfig` → `cxs_table_config` | `sys_ux_screen` record *Agent Assist SNC*, field **Macroponent Configuration** (table → `cxs_table_config` sys_id) | With several configurations on one table the most recently updated wins; it overwrites what SOW had |

## Related

- [[Service Operations Workspace for ITSM]] · [[Service Operations Workspace Access and Landing Page]] · [[Contextual Search]]
