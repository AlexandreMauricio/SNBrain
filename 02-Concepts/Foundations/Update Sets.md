---
type: concept
tags: [concept, platform, update-sets, instance-admin, admin, schema, data-integrity, release-specific]
status: documented
source: ServiceNow docs, Brazil, Building applications > Deploying applications > System update sets (whole section, 1,147 cleaned lines, read in full 2026-10-08 through the docs site) - Exploring, Configuring (application installation tracking, overwrite customizations during an upgrade, merge, source instance, save as XML and load from XML, transfers, update set picker access), Working with update sets (create and select, picker, view customizations, navigation between records, compare local update sets, collision resolution and coalesce strategies, preview, preview records and problems, commit, retrieve, back out, mark complete), Batched update sets (create, preview, commit, reorganize), Reference (default update set, customizations tracked, planning guidelines, properties, deleting update sets). https://www.servicenow.com/docs/r/application-development/system-update-sets/system-update-sets.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Update Sets

**In one line:** an update set (`sys_update_set`) is a named group of configuration changes, each stored as a **customer update** (`sys_update_xml`), that is completed on one instance, then retrieved, previewed and committed on the next, so customizations travel from development to test to production as a unit.

From the Brazil docs. Step by step: [[Move an Update Set between Instances]]. Automated transport: [[ReleaseOps]]. The version history behind each customer update: [[Update Versions and the Merge Tool]].

## What is and is not captured

- Captured: **configuration** in tables whose dictionary has the `update_synch` attribute (**System Definition > Dictionary**, filter *Attributes contains update_synch*). For example a catalog item, its variables and their choices.
- Not captured: task and process **data** (requests, catalog tasks, incidents, users' records). Move data with import sets, web services or XML export ([[Exporting Data]]).
- **Never add `update_synch` to a table yourself**: it can create duplicate update records on core tables and severe performance problems; a default rule blocks it.
- One customer update per customized object: a later change to the same object in the same update set replaces the earlier one.
- Each application scope has its own update sets; an update set holds changes of one scope only.

| Special case | Behaviour |
|---|---|
| Workflows, form sections, lists, related lists, choice lists, dictionary entries, field labels | handled by **special handlers**: several tables packaged as one update. Form section, list, related list, choice list and label handlers **delete and reinsert** records on commit, which can break anything referencing those rows |
| Choice lists | new and changed choices are separate updates; a choice added only for an extended table does not touch the parent table's choices. Large choice lists make commits very slow |
| Dictionary | table removal is **not** tracked (delete the table on the target by hand). A type change that would lose data is skipped on the target and logged. A **column deletion is applied and its data is lost** (a warning lists such deletions); preview does not detect type mismatches |
| Homepages and content pages | not captured; add them by unloading them to the current update set. Homepages are deprecated in favour of dashboards |
| Application installs | **Add app install to current update set** on a `sys_store_app` or `v_plugin` record puts the installation instruction in a global update set |

## States and the default set

| State | Meaning |
|---|---|
| In progress | tracks changes; shown in the picker |
| Complete | ready to be retrieved; nothing more is tracked. **Do not reopen**: make a second update set and commit both in order |
| Ignore | finished or abandoned, and not to be transferred. Set committed copies on production to Ignore so they are not picked up again after a clone |

Other fields: **Name**, **Release date**, **Application**, **Description**, **Parent** (batching).

**Default update set:** one per scope (`Default` for global). It catches changes made while no other set is selected; never change, delete, move or back it out. If a default set is marked Complete or Ignore the system creates a new one (old name plus the next number). Changing application scope switches the current update set to that scope's default unless another is chosen.

## The transfer path

Development > test > production, always the same path, never the same update set from two sources. With two instances: build and test on staging, then production.

| Way | Notes |
|---|---|
| Update source | on the **target**: **System Update Sets > Update Sources** > the source instance's URL and an admin account on it > **Retrieve Completed Update Sets**. If IP address access control is on at the source, allow the target's application node addresses first |
| XML file | **Export to XML** on a Complete set (or a retrieved one in state Loaded); on the target **Retrieved Update Sets > Import Update Set from XML** (elevate to `security_admin`). For instances without connectivity, or to avoid sharing admin credentials, or as a backup |
| ReleaseOps | [[ReleaseOps]] |

Older release to newer release works; **newer to older, or between different Store application versions, risks errors and data loss**. The update source page also says the remote instance must be on the same release family.

Update sets or the application repository, not both, for a scoped application: mixing them gives skipped changes and commit errors. Once an application is installed from the repository, keep using the repository.

## Preview

Retrieved sets are previewed automatically (`glide.update_set.auto_preview`, default true). Each update gets a **preview record**: **Disposition** (Insert, Update, Delete, Collision), **File differences**, **Proposed action** (Commit, the default even when a newer local version exists, or Skip). Problems must all be resolved before commit:

| Problem | Meaning | Options |
|---|---|---|
| Missing object | the object or something it references does not exist here | bring it in another update set or create it locally; *Find missing field / record / update* search the source |
| Collision | the incoming change is **older** than the local change to the same object | **Accept remote update** or **Skip remote update**; *Compare with local* |
| Uncommitted update | the same object is in another retrieved set not yet committed | commit that one first, or move the update |
| Table to be deleted has data | dropping the table drops its rows irrecoverably | skip |
| Application scope validation issue | scoped update set, application not on the target, not in the set, not in the Store | transfer only to instances that have the application |
| Conflict within a single batch | two sets of one batch change the same object | **Compare Collisions**, accept one |

### How collisions are detected

By comparing **Name** and **Updated** of the customer updates: same name, different date. Most records are named `<table>_<sys_id>`, so two identical records created separately on two instances have different names and **do not collide**: they become duplicates. Tables with a **coalesce strategy** are matched on columns instead, and references to them are rewritten to the target's sys_id on retrieval:

| Table | Coalescing columns |
|---|---|
| `sys_db_object`, `sys_properties`, `sys_user_role`, `sys_user_group`, `sys_ui_view`, `sys_wizard`, `sys_notification_category`, `dynamic_namespace`, `ua_table_licensing_config` | `name` |
| `sys_dictionary`, `sys_choice_set`, `sys_df_data_dictionary`, `atf_input_variable`, `atf_output_variable` | `name`, `element` |
| `sys_documentation` | `name`, `element`, `language` |
| `sys_ui_form` | `name`, `view`, `sys_domain` |
| `sys_ui_section` | `name`, `view`, `caption`, `sys_domain` |
| `sys_ui_list` | `name`, `view`, `sys_domain`, `element`, `relationship`, `parent` |
| `sys_ui_related_list` | `name`, `view`, `related_list`, `sys_domain` |
| `sys_ui_message` | `key`, `language`, `code` |
| `sys_translated` | `name`, `element`, `value`, `language` |
| `sys_translated_text` | `tablename`, `fieldname`, `documentkey`, `language` |
| `sys_scope_table_access`, `sys_scope_script_access` | `source_scope`, `target_scope`, `table_name` or `script_name` |
| `sys_index` | `logical_table_name`, `col_name_string` |
| `sys_collection` | `collection`, `name`, `join_field` |
| `sys_module` (`path`), `sys_package` (`source`), `sys_package_dependency_m2m` (`dependency`, `sys_package`), `sys_script_validator` (`internal_type`, `ui_type`), `sys_report_chart_color` (`name`, `element`, `value`), `sys_analytics_bucket` (`sys_scope`, `bucket_document_id`, `bucket_table_name`), `dp_data_pattern` (`source_sys_id`), `dynamic_attribute` and `dynamic_category` (`namespaced_name`), `dynamic_category_member` (`category`, `attribute`), `dynamic_choice_override` (`choice`, `category`, `attribute`) | |
| `sys_attachment` | custom matching |

So: **create records once and move them** (update set or XML) rather than recreating them per instance; for other tables a unique index prevents duplicates. Groups and roles coalesce on name, which is why a group created by hand on two instances still matches.

## Commit, back out, delete

- **Commit Update Set** applies the updates marked Commit and creates a local copy of the update set. A warning lists updates containing deletes. Afterwards read the **commit log** (**System Update Sets > Update Log**) for *unsafe edit* warnings and failed records.
- **Back Out** (on the local copy; needs a **Release date**): reverses record and dictionary changes and adds delete updates to the current set; can lose data. Problems are newer changes to the same objects: *Decide to Keep Current* or *Decide to Use Previous*. The update set and its records are then deleted; the retrieved copy can be previewed and committed again (expect collisions). In a batch, the children are backed out too. If backing out is risky, undo with a new update set instead.
- **Deleting**: only an update set that is not current and has no `sys_update_xml` rows. Deleting customer updates does **not** undo the change, loses who made it, and makes the next upgrade overwrite the customization.
- **Replace on upgrade** (a field on the customer update, added to the form by configuration; reach the record with *Show Latest Update*): tick it to let the next upgrade replace a temporary customization ([[Skipped Records in Upgrades]]).

## Batches

An update set with a **Parent** belongs to a batch; the top one is the **batch base** (list columns *Parent*, *Batch Base*). Preview and commit are done on the base only (**Preview Update Set Batch**, **Preview Problems for Batch**, **Run Preview Again for Batch**, **Commit All Update Sets**); a child cannot be previewed or committed alone (clear its parent to take it out). The system orders the changes by when they were made. Adding an in-progress set to a complete batch makes the batch in progress. Before a clone set only the **parent** to Ignore.

**Merge Update Sets** (older alternative; same application only): the most recent change per object moves into a new set, judged by the record's **Updated** field, not the `sys_updated_on` in the payload; then empty or delete the originals. The docs recommend batching instead.

## Working habits from the docs

- One update set per small or medium task; large ones with schema changes are slow and conflict-prone.
- Naming convention, with the ticket and a sequence: `PRB0010005 - Example fix`, `PRB0010005.2 - Example fix`.
- Same version on both instances; commit outside business hours.
- A change captured in the wrong set: switch to the right set, make a trivial change to the same record and save, undo it and save again. **Do not edit the Update set field of a customer update.**
- **Compare Update Sets** (list action on Local Update Sets) builds a collision report; resolve by opening and deleting the unwanted customer update (this removes the record of the change, not the change).

## Properties and access

| Property | Meaning |
|---|---|
| `glide.update_set.auto_preview` | preview retrieved sets automatically (default true) |
| `glide.ui.update_set_picker.role` | a role that may use the update set picker besides admin (create the property; the role also needs read access to `sys_update_set`). The properties page lists it as true/false, which contradicts the procedure |

Roles named: `admin` throughout; `teamdev_user` may retrieve; `update_set_admin` appears in the ReleaseOps pages. The picker is in the application scope menu of Unified Navigation.

## Related

- [[Move an Update Set between Instances]] · [[ReleaseOps]] · [[Update Versions and the Merge Tool]] · [[Skipped Records in Upgrades]] · [[Instance Clone Overview]] · [[Application Scope and Namespace Identifiers]] · [[Application Development Good Practices - Plan, Build, Validate, Deploy]] · [[Sys ID]]
