---
type: troubleshooting
tags: [troubleshooting, import-sets, data-management]
status: documented
source: ServiceNow docs, Brazil, Workflow Data Fabric > Imports > Import sets, topics "Troubleshoot import set performance", "Import run history", "Viewing the import log", "Import run details", "Import sets maximum row size", "Import sets key concepts", https://www.servicenow.com/docs/r/integrate-applications/system-import-sets/c_TroubleshootImportSetPerformance.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Import set performance and errors

**Symptom:** an import is slow, slows the whole instance, creates duplicates, skips rows or ends with errors.
**Cause:** usually the transform setup (business rules, scripts, unindexed coalesce), the size or overlap of imports, or bad source data.
**Fix:** find the cause below, then confirm in the run history.

## Slow imports

| Cause | Sign | Fix |
|---|---|---|
| **Run business rules** on during a bulk load | long transform, instance slow, notifications sent | untick it on the transform map for that load; do heavy logic once in onComplete |
| Heavy transform scripts (GlideRecord queries per row, big loops) | transform time high | use built-in options (coalesce, choice action) instead of lookups |
| Re-importing unchanged data | huge Total with huge Skipped (**System Import Sets > Progress**) | JDBC: **Use last run datetime**; files: send only new or changed rows |
| Coalesce on unindexed fields | transform time much larger than load time | coalesce on a unique indexed field; **Index Coalesce Fields** (one composite index) |
| Several big imports at once, especially into the same table | high IO wait, contention | stagger schedules |
| Staging tables never cleaned | imports stop as tables fill | make sure **Import Set Deleter** is active (7 days) |
| One huge import set | very long job | split; guideline under 100,000 rows per set (10 x 100,000 beats 1 x 1,000,000) |
| Many reference fields | database slows during transform | **Use Secondary Storage for References** with choice action ignore or reject |
| Very large loads | | concurrent import ([[Scheduled and Concurrent Imports]]) after the fixes above |

## Rows not as expected

- **Duplicates**: no coalesce, coalesce on non-unique values (only the first match updates), case differences (coalesce is case-insensitive by default), empty coalesce values (never match unless **Coalesce empty fields**), or web service inserts without serialisation (`glide.import_set_insert_serialized.<table>`).
- **Skipped**: identical data, missing coalesce values, or rows over **8,126 bytes** (listed in the import log). *Ignored* means a script set `ignore`.
- **New users, groups or categories appear**: field maps with **Choice action** *create* and reference values that did not match (foreign record insert). Set the **Referenced value field name** to the right column, or ignore / reject.
- **Truncated text**: staging column length guessed from samples; `com.glide.loader.verify_target_field_size`.
- **Fields missing from XML imports**: not in the first 10 nodes (`glide.db.impex.XMLLoader.max.scan_nodes`).
- **Dates off by four years** (XLS 1904 date system), **wrong times** (importer's time zone differs from the data), **TRUE/FALSE all false** (`glide.transform.boolean.casesensitive`), **big numbers in scientific notation** (`glide.import.excel.enhanced_number_conversions`).
- **Encrypted fields stay empty**: imports run as System and cannot write them.

## Where to look

- Import set > **Import Set Runs**, **Import Set Rows** (error, comment, target), **Import Log**; **System Import Sets > Advanced > Import Log**, **Progress**, **Transform History**.
- Row error codes (`sys_import_set_row_error`): 100 reference rejected, 200 choice rejected, 300 list reference rejected, 800 invalid target record or field, 900 transform script error.
- More logging: `com.glide.import_set.importlog_level`, `glide.importlog.log_to_table`, `glide.import.debug`, SFTP / SCP debug ([[Import Set Properties Reference]]); robust transformers: **Verbose**.

## Related

- [[Transform Maps, Field Maps and Coalesce]] · [[Import Sets - Data Sources, Staging Tables and Cleanup]] · [[Monitoring and Troubleshooting Instance Performance]]
