---
type: concept
tags: [concept, platform, update-sets, admin, schema, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Planning your application > Team Development (read 2026-10-08 through the docs site): Versions, Version record navigation, Versions transferring, Version records, Merge tool, Compare to the current version, Revert a change, Suppress versions, Versions and local changes, Limitations on updating records. https://www.servicenow.com/docs/r/application-development/team-development/c_Versions.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Update Versions and the Merge Tool

**In one line:** every change to a customizable record (anything update sets track) writes a row in **Update Versions** (`sys_update_version`), so any older state can be compared with the current one, merged, or restored.

From the Brazil docs. Used by update sets, upgrades ([[Upgrades - Process, Upgrade Center and Upgrade Console]]) and [[Team Development]].

## Version record

A new version is written whenever a user changes the record or its application file. A *baseline* version (the object as shipped by the latest upgrade) exists only for objects a user has modified, and is refreshed at each upgrade.

| Field | Meaning |
|---|---|
| **Name** | identifier that ties together the versions of one record |
| **Record name** | name of the customized record |
| **Source** | how it arrived: System Upgrade (baseline), Update Set (created or committed here), Pull History (Team Development) |
| **State** | Current (loaded now) · Previous (was loaded once) · History (never loaded here, kept for history, for example pulled from a parent) |
| **Application** | the record's application, if any |
| **Payload** | the record's data at that version |
| **Reverted from** (list) | the older version this one copies |
| **Instance Name**, **Instance ID** (add to the form) | name and URL of the instance where the version was created |

How versions travel: committing an update set adds the version of each update; a Team Development pull adds all versions not yet pulled, a push adds only the current one, loading from a peer adds the selected ones.

## Getting to the versions

- Form or list layout: **Configure > Form Layout** / **List Layout** > related link *Show Versions*.
- Tables with the `update_synch` attribute: related list **Versions** (already on business rules, UI actions, client scripts).
- Anything else: form header > **Show Application File** > related list *Related Record Versions*.
- From a version: *Show Related Record*, *Show Application File*.

## Compare, merge, revert

- **Compare to Current** (right-click a version, or the related link on the version form) opens the merge tool: field-by-field differences; **>** copies a value into the current record, scripts and text can be edited in place; **Save Merge**. Or **Revert to Selected Version**. In a Team Development collision the buttons are *Use Pulled Version* / *Use Local Version*; from upgrade history the only choice is *Revert to Base System*.
- **Revert to this version** (right-click an older version): the current version becomes Previous and a copy of the chosen one becomes Current. A warning appears when a schema change would lose data. Only the most recent baseline can be reverted to.

### What cannot be merged

Whole-record choice only (take one side): `sys_choice`, `sys_choice_set`, `sys_ui_form`, `sys_ui_list`, `sys_ui_related_list`, `sys_ui_section`, `wf_workflow`, `wf_workflow_version`.

Field types with no per-field merge: auto_increment, auto_number, breakdown_element, catalog_preview, collection, color_display, composite_field, compressed, counter, currency, data_array, data_object, data_structure, date, datetime, days_of_week, document_id, due_date, email, external_names, field_list, float, glide_action_list, glide_precise_time, glide_var, image, index_name, int, integer_time, ip_address, journal, journal_input, journal_list, long, mask_code, metric_absolute, metric_counter, metric_derive, metric_gauge, mid_config, month_of_year, multi_small, name_values, nl_task_int1, order_index, password, percent_complete, ph_number, phone_number, phone_number_e164, price, reference_name, related_tags, reminder_field_name, repeat_count, repeat_type, replication_payload, schedule_date_time, short_field_name, short_table_name, slushbucket, source_id, source_name, source_table, string_boolean, sys_class_name, sysrule_field_name, table, text, time, timer, translated, tree_code, tree_path, user_image, user_input, variables, version, video, week_of_month, wide_text, wms_job, workflow.

## Properties

| Property | Effect |
|---|---|
| `glide.update.suppress_update_version` | comma-separated tables that write no versions (default `sys_user,sys_import_set_row`). Adding tables can break Team Development and makes compare and revert impossible for them |
| `glide.ui.javascript_editor` = false | makes script fields and the side-by-side script comparison usable with a screen reader |
| `mergetool.bg.left.highlight`, `mergetool.bg.right.highlight` | cell colours where the two versions differ |
| `mergetool.bg.left`, `mergetool.bg.right` | cell colours where they are equal |

## Related

- [[Team Development]] · [[Upgrades - Process, Upgrade Center and Upgrade Console]] · [[Dictionary Attributes Reference]]
