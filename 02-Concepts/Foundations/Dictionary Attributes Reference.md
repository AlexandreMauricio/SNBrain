---
type: reference
tags: [reference, platform, schema, reference-field]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration" (pp. 492-510), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Dictionary attributes reference

Dictionary attributes change how a table or field behaves everywhere. Set them on the dictionary record ([[Dictionary Entry Form]]): **Advanced view**, **Attributes** field, or **New** in the Attributes related list.

## Rules for writing attributes

- Comma-separated, **no spaces** after the comma.
- True/false attributes: `attribute` or `attribute=true` for true; absent or `attribute=false` for false.
- **Never remove a base-system attribute to turn it off**: upgrades restore it. Set it to `=false` instead (e.g. `knowledge_search=false`).
- On a child table, a [[Dictionary Overrides|dictionary override]] of attributes replaces the parent's attributes entirely, so repeat the ones you still want.

## Reference fields

| Attribute | Value | Effect |
|---|---|---|
| `ref_auto_completer` | client class name | which auto-completer builds the suggestion list: `AJAXReferenceCompleter` (default, display value only), `AJAXTableCompleter` (rows with the display value plus `ref_ac_columns`), `AJAXReferenceChoice` (list of up to 25, falls back to the table completer above that). Can be set on a table to affect all its reference fields |
| `ref_ac_columns` | field names separated by `;` | extra columns shown in the auto-complete list |
| `ref_ac_columns_search` | true/false | auto-complete also matches on the `ref_ac_columns` fields, not just the display value |
| `ref_ac_display_value` | true/false | hides the display value column so only `ref_ac_columns` are matched. Needs `AJAXTableCompleter`. Does not work with catalog item variables |
| `ref_ac_order_by` | field name | orders the auto-complete list |
| `ref_sequence` | fields separated by `^` | orders the list of referenced records (ascending, like ORDER BY) |
| `ref_qual_elements` | fields separated by `;` | fields sent to the server so the reference qualifier can be re-evaluated |
| `ref_contributions` | UI macro names separated by `;` | UI macros rendered next to the field |
| `ref_decoration_disabled` | true/false | hides the reference icon |
| `tree_picker` | true/false | shows hierarchical referenced tables (e.g. locations) as a tree. Not in mobile apps |
| `long_label` / `short_label` | true/false | per-field override of the property `glide.short.labels` (e.g. "Caller Email" versus "Email") |
| `target_form` | form name | alternative form when the table is opened from a reference pop-up |
| `slushbucket_ref_no_expand` | true/false | stops users expanding the field in a slushbucket |

## Glide list fields

| Attribute | Effect |
|---|---|
| `no_add_me` | hides the **Add Me** icon (e.g. on Watch list) |
| `no_email` | removes the email box on a list of users |
| `no_multiple` | hides the select-multiple icons |
| `no_view` | hides the view-selected-item icon |
| `maintain_order` | shows up/down buttons to order the selected items |
| `start_locked` | `false` shows the field unlocked by default |
| `field_list_selector` | lets the user pick a field from the dependent table |

## Table-level behaviour

| Attribute | Effect |
|---|---|
| `extensions_only` | the table should only hold records of its child tables (Task has it) |
| `update_synch` | changes to the table are captured in update sets. **Administrators cannot modify this** |
| `update_exempt` (field) | the field can change without the record being skipped in upgrades. **Active** on tracked tables is treated this way by default |
| `synch_attachments` | like `update_synch` but also writes attachments to update sets |
| `no_update` | no `sys_mod_count`, `sys_updated_by`, `sys_updated_on` columns are created (high-volume tables such as `syslog`, `sys_audit`) |
| `no_attachment` | hides the paperclip on the form |
| `no_attachments` | skips the attachment check on delete (high-activity tables with no attachments) |
| `attachment_index` | attachments are indexed for search |
| `use_document_viewer` / `document_viewer_audit` (`view`, `download`, `all`) | open attachments in the viewer; audit viewing and downloading |
| `email_client` | adds the envelope icon that opens the email client |
| `no_audit` (field) | field is not audited even if the table is |
| `no_audit_delete` | no `sys_audit_delete` record on delete |
| `exclude_from_rollback` | table and descendants are not recorded for rollback |
| `exclude_auto_recovery` | no automatic recovery of draft records |
| `global_visibility` | visible in every domain despite a `sys_domain` value |
| `no_separation` | table does not take part in domain separation |
| `hasLabels`, `hasListeners`, `hasWorkflow` | marks the table as a target of labels, listeners, or workflow events (the first is normally set automatically) |
| `use_workflow` | use a workflow instead of delivery plans |
| `disable_execute_now` | hides **Execute Now** on tables derived from `sys_auto` |
| `enforce_dot_walk_cross_scope_access` | enforces cross-scope restrictions on dot-walking, per table (set on the Collection entry) |
| `image` | image used when a module uses this table |
| `ref_list_label` | title for the list banner |
| `detail_row` | field shown as a detail row under each list record (child table's value wins) |
| `track_record_for_unauthenticated_user` | record tracking for Web Embeddables |

## Database and performance

| Attribute | Effect |
|---|---|
| `largeTable` / `smallTable` | force the table to be treated as large or small. Otherwise `glide.db.large.threshold` (default 5,000) decides |
| `onlineAlter` | schema changes without locking writes (MySQL), at the cost of more resources |
| `allowHugeAlter` | allows adding a column to a table over 100 million rows |
| `iterativeDelete` | forces row-by-row deletes instead of bulk |
| `nibble_size` (default 250), `nibble_sleep`, `no_optimize` | table cleaner batch size, pause between batches, and skipping compaction |
| `glide.db.oracle.ps.query` | `false` disables Oracle prepared queries on the table |

## Text search

| Attribute | Effect |
|---|---|
| `no_text_index` | excludes a field or child table from the text index |
| `ts_weight` | relative weight of matches in this field |
| `text_index_filter_junk` | `false` disables the Zing junk filter (reindex afterwards; larger index) |
| `text_index_translations` | reindex when translations are added (overridden by `glide.i18n.force_index`) |
| `i18n_locale_text_match` | case- and accent-sensitive text search on the column. Cannot be combined with the next one |
| `i18n_session_language_sortable` | sort by the session language instead of the English alphabet |
| `knowledge_search` / `knowledge_custom` | book icon that searches the knowledge base from a string field; custom search function |

## Field display and input

| Attribute | Effect |
|---|---|
| `format` | `glide_duration` shows milliseconds as a duration (`ddd hh:mm:ss`); `none` removes number formatting (2,500 becomes 2500). Display only |
| `scale` | decimal places on a Decimal field (default 2). Max length must grow with it (e.g. scale 4 needs max length above 15) |
| `no_truncate` | list shows the whole multi-line text instead of the default 40 characters |
| `default_rows` | default rows of a multi-line text field |
| `ro_collapsible` | adds a +/- toggle to a multi-line field |
| `html_sanitize` / `html_sanitize_config` | HTML sanitisation on or off (on by default); custom sanitiser configuration |
| `strip_html_in_pdf` | strips HTML tags when exporting to PDF |
| `field_decorations` | UI macros rendered with the field |
| `isOrder` | default sort field for lists (overridden by `ORDERBY` in the URL or user preference) |
| `ignore_filter_on_new` | new records do not take values from the list filter |
| `user_preference` | user preference replaces the default value |
| `allow_null` | lets a field-name field be `None` |
| `vertical_layout` | radio buttons stacked vertically |
| `json_view` | icon that shows the JSON behind the field |
| `barcode`, `current_location` | mobile: scan a barcode into a string field; fill with GPS location |
| `display_image` | show `user_image` fields as an image (user initials if missing on `sys_user`) |
| `readable` | conditions field shown as readable text in lists, not the encoded query |
| `show_condition_count` | condition count preview on a conditions field |
| `omit_sys_original` | price and currency fields skip the original value in calculations |
| `ip_data_control` | how IP values are normalised: `none`, `canonical`, `expanded`, `canonicalize_when_possible` (default) |

## Task and SLA

| Attribute | Effect |
|---|---|
| `close_states` | on a task **State** field: inactive state values separated by `;`, used by `TaskStateUtil` |
| `default_close_state`, `default_work_state` | default close and working state values for `TaskStateUtil` |
| `sla_basis` / `sla_closure` | on a date field: tables for which the field is the SLA start, or the SLA end |
| `approval_user` | on an integer field: names the field holding the approvers; the integer is the approval sequence (all of sequence 100 before 200) |
| `timeDimension` | OLAP time dimension (OLAP is deprecated) |
| `live_feed` | toggle between Live Feed and the activity formatter |
| `target_field` / `target_threshold_colors` | colour thresholds on percent-complete fields, e.g. `target_threshold_colors=0:tomato;50:khaki;90:lightgreen` |

## Field-name, table-name and other special field types

| Attribute | Effect |
|---|---|
| `table`, `types`, `reference_types`, `allow_references` | on a field-name field: which table's fields to list, limited to which types, and whether to show a dot-walk tree |
| `base_table`, `skip_root`, `allow_public`, `text_search_only`, `tableChoicesScript` | on a table-name field: restrict to tables derived from a base table, drop the base table itself, list all scopes, list only text-searchable tables, or get the list from a script include |
| `show_all_tables` | document ID fields may pick records from system tables |
| `mode_toggler`, `include_container_types`, `model_class`, `model_field`, `order`, `script`, `staticDependent`, `remoteDependent`, `icons`, `listen`, `pop-up_processor`, `calendar_elements`, `collection_interval`, `repeat_type_field`, `time_zone_field`, `critical`, `no_auto_map`, `saver_exempt` | specialised or internal; see the guide pages for each |

## Related

- [[Dictionary Entry Form]] · [[Dictionary Overrides]] · [[sys_dictionary]]
