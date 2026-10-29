---
type: concept
tags: [concept, integrations, cmdb, import-sets]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > IntegrationHub ETL (overview, Create an ETL transform map with its guided-setup tasks and transform types, Add before and after scripts, Duplicate an ETL transform map; about 1,600 cleaned lines, read in full through the docs site API 2026-10-29). https://www.servicenow.com/docs/r/servicenow-platform/integration-hub-etl/integrationhub-etl.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# IntegrationHub ETL

**In one line:** a Store app (plugin `sn_int_studio`, menu **All > Configuration > IntegrationHub ETL**, role `cmdb_inst_admin`) with a guided setup that builds an **ETL transform map**: import set data in, transforms applied, columns mapped to CMDB classes (or IRE-supported non-CMDB tables), relationships added, test run with rollback, then a schedule. Processing goes import set → Robust Transform Engine (RTE) → IRE.

From the Brazil docs; not tested. Steps: [[Create an ETL Transform Map in IntegrationHub ETL]]. Underlying engine: [[Robust Import Set Transformers and ETL Definitions]]. Transform list: [[RTE Operations and Integration Commons Transforms Reference]]. Monitoring: CMDB Integrations Dashboard in [[Integration Commons for CMDB]].

## Why use it instead of classic transform maps

Every row goes through IRE automatically (identification, reconciliation, no duplicates; [[Identification and Reconciliation Engine (IRE) Overview]]); guided UI; a test run on sample data with rollback before scheduling. Classic transform maps ([[Transform Maps, Field Maps and Coalesce]]) have no simple way to apply IRE.

## Terms

| Term | Meaning |
|---|---|
| **CMDB application** | the source product (e.g. *SCCM 2019*), with a **Name** and a **Discovery Source**; set the discovery source up before building the map |
| **Data source** | one source feed / endpoint (e.g. computer identity, disks, applications) |
| **ETL transform map** | the output; **one per data source**, so one CMDB application can have several maps |
| Source data / transform / transformed data | raw columns, operations on them, and the resulting columns |

## Behaviour worth knowing

- **Non-CMDB tables** (since Brazil): only those IRE supports. For them class association is optional (when configured for IRE), relationships do not apply, and association is by reference field.
- **Required mapped fields** always present: **Source Native Key** (IRE errors if empty; used for identity, references, relationships, speed) and **Source Recency Timestamp** (older values ignored; empty = now). Properties `glide.identification_engine.skip_updating_last_scan_if_older` and `glide.identification_engine.ire_message_listener_skip_updating_last_scan_to_now` tune how it updates **Last scan** in `sys_object_source`.
- To set an attribute empty, map the string `<EMPTY_STRING>` (the docs print it with a stray invisible character between Y and _; exact string unconfirmed).
- **Conditional class**: route rows to classes by values or by plugin state (e.g. name contains Windows → Windows Server, Linux → Linux Server, else Server).
- **Associated class**: a non-CMDB target (e.g. Software Instance `cmdb_software_instance`) is tied to a CMDB class through **Related Entry** (`cmdb_related_entry`), e.g. Software Package `cmdb_ci_spkg`. Required when the table is not configured for IRE; optional when it is. (The Brazil page still contains an internal editor's note saying "you must" should read "you can" for IRE-configured tables: a documentation discrepancy.)
- **Deactivating** a class mapping keeps its configuration but skips it at run time, and may auto-deactivate dependants: lookup rules and relationships of that class; associated non-CMDB classes; classes with a single dependent relationship on it (only when all their parents are off); all mappings inside a deactivated conditional class (conditions stay in effect).
- **Nested JSON**: the data source must use **Data in single column**. Field names start with a letter or `_`, only letters, digits, `_`; not `temp` or `object`; a level is always an array or always an object. All mappings to one class must come from one branch (use Copy to move parent values down); transforms may reference parent objects, not siblings; no relationships between siblings.
- **Read-only mode**: a map with no sample import set (or a connector with no incoming data) opens read-only — useful for studying a Store connector's map.
- **Preview size**: `sn_int_studio.preview.size` (100, hard maximum 10,000) or **Preview Size Override** per map (v3.2+); **Load Complete Schema** builds the nested structure from all data rather than the sample.
- **Validation** on open: create `sn_int_studio.validation.enabled` = true; reports missing source/target fields, missing import set columns (their RTE metadata is deleted), missing IRE lookup rules.
- Logs: RTE and IRE messages always shown, including INFO, whatever the import log properties say ([[Import Set Properties Reference]]).
- Since v3.2 the landing page groups maps by CMDB application.
- Data source must be in the same application scope as the session.

## Before and after scripts

Per data source of a CMDB application: **CMDB Integration Studio Application** form > **CMDB Integration Studio Application Data Sources** > tick **Execute Before Script** / **Execute After Script** and write the script below the shipped comments. They run server side around IRE with access to its input and output payloads; the supported operations are described only in those comments (not read).

## Related

- [[Integration Commons for CMDB]] · [[Populating the CMDB]] · [[Import Sets - Data Sources, Staging Tables and Cleanup]] · [[Scheduled and Concurrent Imports]] · [[IRE Identification Rules]]
