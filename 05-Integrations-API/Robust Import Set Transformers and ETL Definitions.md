---
type: concept
tags: [concept, import-sets, integrations, cmdb]
status: documented
source: ServiceNow docs, Brazil, Workflow Data Fabric > Imports > Import sets > Robust Import Set Transformers, topics "Robust Import Set Transformers", "Create a robust import set transformer", "Robust import set transformer properties", "Create robust transform definitions", "Extract Transform Load (ETL) definition overview", "Temporary entity model", "ETL Definition quick start guide", "Create Extract Transform Load (ETL) definitions" and children, "Define Robust Transform Engine operations", "Import run details", https://www.servicenow.com/docs/r/integrate-applications/system-import-sets/robust-import-set-transformers.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Robust import set transformers and ETL definitions

**In one line:** a robust import set transformer reads staging rows once, transforms them through an **ETL definition** run by the Robust Transform Engine (RTE), and loads them into **one or more** target tables in batches; it is the alternative to one transform map per target table.

## Versus transform maps

| | Transform map | Robust transformer |
|---|---|---|
| Targets | one per map (three tables = three maps = three reads) | many from one read |
| Stages | transform and write together | extract to an intermediate structure, transform, load |
| Processing | row by row | batches |
| Nested JSON / XML | limited | entities with `[*]` array paths (since Paris) |
| CMDB | via scripts | can use a CMDB / IRE definition and IRE settings |
| Precedence | | wins if the data source has both |

The docs call transform maps the "legacy method" on the run-details page.

## Building one

1. **System Import Sets > Administration > ETL Definitions** (role `import_transformer`): create the definition.
2. **Entities**: an **input entity** (the staging rows; table None; one field per column or, for single-column data, per JSON key path) and **target entities** (one per target table; fields for columns plus temporary fields). Optional **temp entity** as a middle step so operations live in one place.
3. **Entity fields**: name, column or path, **Coalesce** (unique key; reference fields can coalesce), reference path for references (e.g. `computer.id`; several fields for a multi-column unique key), **Coercion action** when the referenced record is missing: create it, ignore (save empty), or reject.
4. **RTE entity operations** (tab **RTE Entity Operations**): transform values, e.g. concatenate type and version into one field via temp fields. One operation per entry.
5. **RTE entity mappings**: input (or temp) entity to each target entity; optional **conditional script** to map only some rows (e.g. only rows whose type is *member*).
6. **System Import Sets > Administration > Robust Import Set Transformers > New**: **Name**, **Source table**, **Robust transform engine** (the ETL or CMDB definition, via **Robust Transform Definitions**), **Properties**, **Active**, **Batch size** (start around 100), **Verbose** (detailed transform logs and target-row tracking).

Nested data: input fields like `emails[*].address`, target entity path `email[*]` produce several target rows from one source record.

## CMDB (IRE) settings

Properties on the transformer (payload level; item-level settings in IntegrationHub ETL win): `ire.input.items.settings.updateWithoutDowngrade`, `...updateWithoutUpgrade`, `...updateWithoutSwitch`, `ire.input.items.classDowngrade`, `...classUpgrade`, `...classSwitch` (all default false), and system property `ire.skip_sys_object_source_matching` (true: identification rules take priority over `sys_object_source` lookup, useful when identifying attributes change while the source native key does not). IRE (Identification and Reconciliation Engine) itself is not yet documented in this vault (CMDB is on the reading list).

## Run details

On the import set: **Import Set Runs** (state Cancelled, Cancel requested, Complete, Complete with errors, Did not complete, Running; totals: for robust transformers processed + ignored + skipped + errors; inserts, updates; which map or transformer ran), **Import Set Rows** (row number from 0, state, error, comment, target record for transform maps), **Import Log**. With **Verbose**, each row shows **Transform Target Rows** (Inserted, Updated, Error, target record). *Ignored* = your script said so; *Skipped* = the system skipped it.

## Related

- [[Transform Maps, Field Maps and Coalesce]] · [[Import Sets - Data Sources, Staging Tables and Cleanup]] · [[SCIM Provider - Provisioning Users and Groups into the Instance]] (uses ETL mapping for extension schemas)
