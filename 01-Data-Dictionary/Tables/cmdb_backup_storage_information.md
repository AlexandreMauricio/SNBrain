---
type: table
tags: [table, cmdb, schema, choice-list, reference-field]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > "Backing up CMDB data" (https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/cmdb-backup-storage-info-table.html), read through the docs site API 2026-10-09. Column names as printed on the page
sn-release: Brazil
verified:
updated: 2026-10-09
---

# cmdb_backup_storage_information

**Label:** Backup Store Information
**Extends:** not a CI class. A *related table*: it references a CI ([[CMDB Overview and Class Hierarchy]])
**Comes with:** the Store application the docs call `app-cmdb-content`
**Purpose:** backup status of a CI of any kind (hardware, cloud, container): whether backup is configured, when it last ran, which service does it. Despite the docs title, this is not about backing up the CMDB itself.

## Columns

| Label | Name | Type | Notes |
|---|---|---|---|
| Backup Configuration Status | `backup_config_status` | string (choice) | see values |
| Last Successful Backup | `last_successful_backup` | date/time | start or end of the attempt, as the platform reports it; if unclear, the start |
| Last Backup Attempt | `last_backup_attempt` | date/time | last attempt, successful or not. Equal to the previous field after a success |
| Execution Mode | `backup_execution_mode` | string (choice) | see values |
| Backup Source | `backup_source_configuration_item` | reference to a CI | the CI being backed up. **Cascade delete**: deleting the CI deletes its rows here |
| Backup Source ID | `backup_source_id` | string (1024) | the CI's identifier in the backup service (host id, vCenter id, instance id, database id) |
| Backup Service | `backup_service_configuration_item` | reference to a CI | the CSDM technical service hosting the backup system |
| Recovery Point Objective | `recovery_point_objective` | duration | acceptable time between backups, so acceptable data loss |
| | `managed_by`, `managed_by_group` | | copied from the CI |
| | `sys_domain`, `sys_domain_path` | | copied from the CI |

The page prints the two reference column names with a stray space (`backup_source_ configuration_item`); written here without it. Confirm in `sys_dictionary`.

## Choice values

As listed in the Brazil docs.

- **Backup Configuration Status:** Backup Disabled (False, the default: not configured for regular backup), Backup Enabled (True: policies exist in the backup system), Unknown, Not Applicable, Planned, Not Planned.
- **Execution Mode:** Manual (run as needed), Automatic (run periodically), Unknown.

## Loading it through IRE

Define a related entry in `cmdb_related_entry` for the CI class, with **Backup Source ID** as criterion attribute and **Backup Source** as the referenced field ([[IRE Identification Rules]]). Then send the row in the `related` block of the CI's payload (server side, global scope, background script or integration):

```javascript
var payload = { items: [ {
    className: 'cmdb_ci_hardware',
    sys_object_source_info: { source_name: 'ServiceNow', source_native_key: 'example-key-01' },
    values: { name: 'example-host-01' },
    lookup: [],
    related: [ { className: 'cmdb_backup_storage_information',
                 values: { backup_source_id: 'example-backup-id-01', last_successful_backup: '2026-01-01 02:00:00' } } ]
} ] };
var output = SNC.IdentificationEngineScriptableApi.createOrUpdateCI('ServiceNow', new JSON().encode(payload));
gs.print(output);
```

The docs sample uses value keys (`backup_policy`, `last_backup`, `backup_id`) that do not match the column names in its own column table; the snippet above uses the column names. Untested.

## Related

- [[Identification and Reconciliation Engine (IRE) Overview]] · [[cmdb_ci]]
