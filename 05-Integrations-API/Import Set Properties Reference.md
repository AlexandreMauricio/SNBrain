---
type: reference
tags: [reference, import-sets, instance-admin]
status: documented
source: ServiceNow docs, Brazil, Workflow Data Fabric > Imports > Import sets, topic "Import sets properties", plus properties named in "File type data sources", "Create a File type data source", "Custom (Load by Script) type data source", "Web service import set mode", "Creating an import set web service", "Map with transformation event scripts", https://www.servicenow.com/docs/r/integrate-applications/system-import-sets/r_ImportSetsProperties.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Import set properties reference

Most of these are not present by default: add them in **System Properties** (`sys_properties`). Concepts: [[Import Sets - Data Sources, Staging Tables and Cleanup]]. Grouped and paraphrased; defaults only where the docs give them.

## Staging tables and loading

| Property | Effect |
|---|---|
| `glide.import_set.preserve.leading.spaces` | keep non-breaking leading spaces from Excel cells (trailing spaces always removed) |
| `glide.import_set_row.dynamically_add_fields` | false = imports cannot add staging columns (avoids alter-table outages; add the column by hand and reimport) |
| `com.glide.loader.verify_target_field_size` | true = staging columns grow by 100 to fit data (default false: 20 sampled rows, 40 if empty, longer data truncated) |
| `com.glide.loader.max_scan_rows` | rows sampled to build columns (JDBC, XLS, CSV, XML) |
| `glide.db.impex.XMLLoader.max.scan_nodes` | XML nodes sampled for columns (default 10; -1 all) |
| `glide.import_set_load_usebatch`, `glide.import_set_load_batch_size` | batch loading; override the data source fields (default size 1000) |
| `glide.ds.file.http.variable_replacement` | allow `${property}` in HTTP/S file paths |
| `glide.impex.transformer.empty_value_nil` | true keeps empty strings (test with `nil()` / `hasValue()` in onBefore); false turns them into `NULL` |
| `glide.transform.boolean.casesensitive` | false = upper-case TRUE/FALSE from Excel transform correctly |

## CSV and Excel

| Property | Effect |
|---|---|
| `glide.import.csv.charset` | UTF-8 or WINDOWS-1252 |
| `com.glide.csv.loader.ignore_non_parseable_lines`, `com.glide.csv.loader.max_errors_allowed` | skip bad CSV lines instead of failing at the first one, up to a maximum |
| `glide.excel.multiplier` (XLS, default 8), `glide.xlsx.multiplier` (XLSX, default 10; do not change) | memory = multiplier x file size, capped by `glide.excel.max_memory_percent` |
| `glide.excel.use_disk_backed_strings_table`, `glide.excel.in_memory_strings_table_size_mb` | XLSX string data on disk versus memory |
| `glide.import.excel.enhanced_number_conversions` | true keeps numbers above 10 million exact (otherwise scientific notation); recommended true |
| `glide.xlsx.import.debug` | XLSX debug log |

## Scheduled and concurrent

| Property | Effect |
|---|---|
| `glide.scheduled_import.stop_on_error` | stop child imports when the parent errors |
| `glide.scheduled_import.max.concurrent.import_sets` | import sets per concurrent import (default 10) |
| `com.glide.concurrent_import_set_insert_mutex_spin_wait`, `..._insert_mutex_expiration`, `com.glide.concurrent_import_set_mutex_fast_lock` | insert lock behaviour |
| `com.glide.system_parallel_job_inactive_time_minutes` (600), `..._max_retry_count` (2), `..._auto_retry` | parallel loading jobs of Custom (Load by Script) sources |

## Web service import sets

| Property | Effect |
|---|---|
| `com.glide.ws_import_set.column_resize`, `com.glide.ws_import_set.column_resize.max_row_count` (max 500,000) | column growth for web service staging tables |
| `glide.import_set_insert_serialized.<table>`, `glide.soap.import_set_insert_serialized.<table>`, `glide.import_set_insert_serialized_when_no_coalesce` | serialised inserts versus speed |
| `glide.processor.debug.SOAPProcessor` | log incoming SOAP requests |

## JDBC

`glide.jdbcprobeloader.retry`, `glide.jdbcprobeloader.retry_millis`: retries and wait for JDBC probe results.

## Logging and debug

| Property | Effect |
|---|---|
| `com.glide.import_set.importlog_level` | INFO, WARNING or ERROR (INFO in dev, WARNING/ERROR in production) |
| `glide.importlog.log_to_table` | write info-level messages (including `log.info` from transform scripts) to the import log table (IntegrationHub ETL always does) |
| `glide.import.debug` | debug log for all imports |
| `glide.import.sftp.debug`, `glide.import.scp.debug` | log the whole SSH session |

## Easy import

`glide.import_template.row_limit` (10,000 rows in a template), `glide.easy_import.run_business_rules` (true), `glide.import_template.field_types_to_ignore`, `glide.easy_import.reference_query_limit`: see [[Easy Import]].

## Related

- [[System Properties]] · [[Import Set Performance and Errors]]
