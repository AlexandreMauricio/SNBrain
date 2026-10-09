---
type: reference
tags: [reference, cmdb, data-integrity, instance-admin, schema]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB Identification and Reconciliation (IRE) > Reference, topics "Properties for Identification and Reconciliation" and "Components installed with Identification and Reconciliation" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/c_CMDBIdentifyandReconcile.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# IRE Properties and Tables Reference

**What it is:** system properties and tables of the [[Identification and Reconciliation Engine (IRE) Overview|Identification and Reconciliation Engine]] (part of plugin `com.snc.cmdb`).
**Where:** properties marked *page* are on **Configuration > CMDB Properties > Identification/Reconciliation Properties**; the rest must be **added to `sys_properties`** to be changed.
**Roles:** `sn_cmdb_admin` or `admin`.

## Properties

### Identification and duplicates

| Property | Default | Effect |
|---|---|---|
| `glide.required.attribute.enabled` (page) | true | required attributes may not be null |
| `glide.identification_engine.skip_duplicates` (page) | true | with few duplicates, update the oldest and mark the rest `duplicate_of`; false = fail with an error ([[Duplicate CI Detection in IRE]]) |
| `glide.identification_engine.skip_duplicates.threshold` (page) | 5 | above this many duplicates, behave as if the previous one were false |
| `glide.identification_engine.lookup_match.create_duplicate_task_ci.enabled` | false | raise a de-duplication task when one lookup value points at several CIs |
| `glide.identification_engine.non_dependency_relation.duplicate_detection` | false | detect duplicate non-dependent relationships inside a payload |
| `glide.identification_engine.skip_sys_object_source_matching` | false | true = identification rules take priority over the source key lookup when the payload has criterion attributes. The source key is still used when it is the only thing available |
| `glide.identification_engine.enable_identifier_optional_condition` | false | enable conditions on regular identifier entries; **activates all the shipped ones** ([[IRE Identification Rules]]) |
| `glide.identification_engine.dynamic_ire_enabled` | false (true on new instances from Zurich Patch 11) | [[Dynamic IRE]] instead of Static |
| `glide.identification_engine.dynamic_ire.auto_compare` | true | compare Dynamic and Static output (with `...auto_compare.sampling.enabled`) |
| `glide.identification_engine.platform_domain_separation_enabled` | false | true = parent domains see child domains during IRE; false = strict, own domain only |

### Reclassification

See [[CI Reclassification During IRE Processing]].

| Property | Default |
|---|---|
| `glide.class.upgrade.enabled`, `glide.class.downgrade.enabled`, `glide.class.switch.enabled` (page) | true |
| `glide.identification_engine.update_without_upgrade_enabled`, `...update_without_downgrade_enabled`, `...update_without_switch_enabled` | false |
| `glide.identification_engine.reclassification_restriction_rules_enabled` | true |

### Reconciliation

| Property | Default | Effect |
|---|---|---|
| `glide.reconciliation.override.null` (page) | true | a lower-priority source may fill an empty field |
| `glide.identification_engine.enable_reconciliation_filter_before_update` | false | true = evaluate a reconciliation rule's filter before the payload changes values |

### Timestamps

| Property | Default | Effect |
|---|---|---|
| `glide.identification_engine.skip_updating_source_last_discovered_if_older` | true | ignore a payload `last_discovered` older than the CI's (so `last_discovered` and `discovery_source` are not set from it) |
| `glide.identification_engine.ire_message_listener_skip_updating_source_last_discovered_to_now` | false | fallback when the Robust Import Set Transformer does not pass its own option |
| `glide.identification_engine.skip_updating_last_scan_if_older` | true | ignore a `source_recency_timestamp` older than `last_scan` in `sys_object_source` |
| `glide.identification_engine.ire_message_listener_skip_updating_last_scan_to_now` | false | fallback as above, for `last_scan` |
| `glide.identification_engine.batch_update_last_discovered` | true | batch the `last_discovered` updates. **Set false if business rules on `last_discovered` must fire** on IRE calls |
| `glide.identification_engine.batch_update_last_discovered.use_execute_lazy` | true | deferred batched writes. False = synchronous, for race conditions between discovery and aggressive CI deletion |

### Performance and logging

| Property | Default | Effect |
|---|---|---|
| `glide.identification_engine.partial_payload_items_max_size` | 1000 | items per partial payload before it is split |
| `glide.identification_engine.partial_items_process_limit` | 2000 | partial items fetched per IRE call; beyond it only those matching complete items in the payload |
| `glide.identification_engine.partial_items_process_absolute_limit` | 5000 | hard stop for fetching partial payloads |
| `glide.cache.size.service_cache` | 20 (MB) | cache for inbound and outbound relations; cannot be disabled |
| `glide.identification_engine.independent_items_local_cache_count` | 100000 | 0 = no local cache for independent CIs (slower) |
| `glide.identification_engine.dependent_items_local_cache_count` | 10000 | set both this and the next to 0 on memory problems |
| `glide.identification_engine.related_items_local_cache_count` | 15000 | |
| `glide.identification_engine.granular_insert_locking` | true | several granular insert locks; false = one global lock, if the granular ones cause performance problems |
| `glide.identification_engine.mutex_expiration_time` | 15 minutes | raise on LOCK_TIMEOUT errors ([[IRE Error Messages]]) |
| `glide.identification_logs.max_run_ids` (page) | 1000 | runs listed in Identification Logs |
| `glide.cmdb.logger.source.identification_engine` | | log level for IRE outside simulation: info, warn, error, debug, debugVerbose. **High levels produce a lot of data**: keep the level and duration minimal (KB0750382) |
| `glide.discovery.identification.log_level` | | Discovery property for identification run logs: Info, Warn, Error, Debug, DebugVerbose, DebugObnoxious |

## Tables

| Name | Label | Holds |
|---|---|---|
| `cmdb_identifier` | Identifier | the identification rule of each class |
| `cmdb_identifier_entry` | Identifier Entry | prioritised entries of a rule |
| `cmdb_related_entry` | Related Entries | related entries; also lists the related (non-hierarchy) tables |
| `cmdb_ie_active_config` | Identification Inclusion Rules | inclusion rules |
| `cmdb_reconciliation_definition` | Reconciliation Definition | static reconciliation rules |
| `cmdb_dynamic_reconciliation_definition` | Dynamic Reconciliation Definitions | dynamic rules |
| `cmdb_datasource_precedence` | Datasource Precedence | source priorities (domain aware) |
| `cmdb_datasource_staleness` | Data Source Staleness Definition | data refresh rules (effective duration per source) |
| `cmdb_datasource_last_update` | Data Source History | last source to update each attribute |
| `cmdb_ire_data_source_rule` | IRE Data Source Rule | sources barred from inserting a class |
| `cmdb_ire_reclassification_restriction` | (Reclassification Restrictions) | blocked class changes |
| `cmdb_dynamic_ire_skip_class` | Dynamic IRE skipped classes | classes kept on Static IRE |
| `cmdb_ire_output_comparison_item` | CMDB IRE Output Comparison Items | Dynamic versus Static differences |
| `cmdb_ire_partial_payloads`, `cmdb_ire_partial_payloads_index` | CMDB IRE Partial Payloads (Index) | parked partial items and their identifier keys; purged after 90 days |
| `cmdb_ire_incomplete_payloads` | CMDB IRE Incomplete Payloads | unprocessable items, for logging. Table rotation: one day, seven rotations ([[Database Rotation - Table Rotation and Table Extension]]) |
| `cmdb_ire_output_aggregate_stats` | IRE Output Aggregate Stats | per run and CI type, counts of inserted, updated and partial items. Filled when the Robust Transform Engine (RTE) calls IRE |
| `cmdb_ire_output_target_item` | IRE Output Target Items | target class and sys_id per import set row within a run. Filled only when RTE passes `ire_output_detailed_stats` |
| `reconcile_duplicate_task` | Remediate Duplicate Task | de-duplication tasks. **Generated only; do not add by hand** |
| `duplicate_audit_result` | Duplicate Audit Result | the CIs of each de-duplication task. Generated only |
| `cmdb_duplicate_lookup_related_allowed_class` | CMDB Deduplication Task Lookup or Related item allowed classes | lookup and related tables that get de-duplication tasks |
| `reclassification_task` | Reclassification Task | class changes that were not allowed |
| `sys_object_source` | Source | source name + native key per CI, with `last_scan` |
| `cmdb_metadata_hosting`, `cmdb_metadata_containment`, `cmdb_metadata_reference` | CMDB Metadata ... Rules | [[CMDB Dependent Relationship Rules - Hosting and Containment]] |
| `cmdb_ie_context`, `cmdb_ie_run`, `cmdb_ie_log` | Identification Engine Context / Run / Log | internal to identification simulation: payload and API used, each run and its output, its log lines |

## Role

`cmdb_payload_admin`: given automatically to holders of `cmdb_admin`; internal use only.

## Related

- [[IRE Reconciliation, Data Refresh and Data Source Rules]] · [[Simulate an IRE Payload with Identification Simulation]]
