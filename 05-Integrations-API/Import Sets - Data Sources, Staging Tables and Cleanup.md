---
type: concept
tags: [concept, import-sets, integrations]
status: documented
source: ServiceNow docs, Brazil, Workflow Data Fabric > Imports > Import sets, topics "Imports", "Import sets", "Import sets key concepts", "Data sources", "File type data sources", "Processing custom CSV files", "JSON file import examples", "FTP data source extended properties", "JDBC type data source", "LDAP type data source", "Data Stream (Integration Hub) data source", "Custom (Load by Script) type data source", "Create a data source" and its six children, "Data source fields", "Standard import set tables", "Import sets maximum row size", "Importing date/time values", "Review the import set", "Delete import sets", "Delete import set tables", https://www.servicenow.com/docs/r/integrate-applications/system-import-sets/import-sets-landing-page.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Import sets: data sources, staging tables and cleanup

**In one line:** an import loads external data through a **data source** (`sys_data_source`) into a **staging table** (an import set table extending `sys_import_set_row`), then a **transform map** or **robust transformer** writes it into real tables; the staging rows are cleaned up after 7 days.

## The pieces

| Piece | Table / where | Role |
|---|---|---|
| Data source | `sys_data_source`, **System Import Sets > Administration > Data Sources** | where the data comes from and how to read it |
| Import set table (staging) | a table extending Import Set Row `sys_import_set_row`, e.g. `u_example_users` or `imp_user` | raw rows; columns created automatically from the data |
| Import set | `sys_import_set` | one load run (number, state, mode, table name) |
| Transform map / field maps | `sys_transform_map` | how staging columns become target fields: [[Transform Maps, Field Maps and Coalesce]] |
| Robust import set transformer | ETL alternative: [[Robust Import Set Transformers and ETL Definitions]] | wins over a transform map on the same data source |
| Logs, runs, row errors | Import Log, Import Set Runs, `sys_import_set_row_error` | see [[Import Set Performance and Errors]] |

Other ways in that the Imports chapter lists: **Integration Hub - Import** (guided wizard), the **Import Set API** (REST, synchronous transform, mirrors SOAP), **Easy import** ([[Easy Import]]), web service import sets ([[Web Service Import Sets and Direct File Posting]]), inbound email actions.

**Imports run as user System**: they cannot write to encrypted fields. Rows identical to existing data are skipped. Do not load huge single sets (guideline under 100,000 rows per import set).

## Staging table rules

- Columns are generated from the first rows: never add columns by hand (breaks cleanup). Add the column to the source and **Test Load 20 Records** or **Load All Records** again.
- Column types may differ from the source (currency arrives as string until mapped).
- Field length: up to 20 sampled records decide length (40 if all empty); longer data is truncated unless `com.glide.loader.verify_target_field_size` = true (column grows by 100). Rows sampled for columns: `com.glide.loader.max_scan_rows` (JDBC, XLS, CSV, XML; not JSON, XLSX). `glide.import_set_row.dynamically_add_fields` = false stops imports adding columns (an alter on a huge staging table can cause an outage).
- One database row holds at most **8,126 bytes**; larger rows are skipped and logged.

## File formats

| Format | Notes |
|---|---|
| CSV | RFC 4180; no double quotes inside fields; first row = header. Charset in the data source **Properties** (`charset=utf-8`) or `glide.import.csv.charset` (UTF-8, WINDOWS-1252). Other delimiter: add **CSV delimiter** to the form (e.g. `|`) |
| Excel | XLSX preferred (only standard, not "Strict Open XML"); XLS must use the **1900 date system** (1904 shifts dates by 4 years); upper-case TRUE/FALSE import as false unless `glide.transform.boolean.casesensitive` = false; **Sheet number**, **Header row** |
| XML | **Xpath for each row**, absolute (`/export/asset`, not `//asset`, never the root); **Expand node children** makes `userInfo/lastName` columns; only the first 10 nodes are sampled for fields (`glide.db.impex.XMLLoader.max.scan_nodes`, -1 = all, slower) |
| JSON | RFC 4627; **Path for each row** repeats the array name: `/incidents/incidents`, `/problems/data/data`, nested `/problems/problems/data/data`, top-level array `//`; no predicates or axes; **Discard Arrays** cleared keeps child arrays as JSON values; arrays of non-objects cannot be rows ("Path should always refer JSON Objects") |
| Data in single column | JSON or XML record kept whole in a column called `data` (used by ETL nested mappings) |
| Custom (Parse by Script) | script `(function(line, lineNumber, result) {...})` calling `result.addRow(map)` per row; `setSkip(true)` drops the line |

**File retrieval methods**: Attachment, SFTP (recommended), FTP (clear text), FTPS variants (not recommended: firewall support dropped), HTTP, HTTPS (also instance-to-instance), SCP (password authentication only; key pairs unsupported). File path can use `${system.property}` (for HTTP/S needs `glide.ds.file.http.variable_replacement`); HTTP/S paths are URL-encoded automatically. FTP properties in **Properties**: `connection.timeout` (10,000 ms), `remove_file` (true!), `rename_file` (`<name>.imported`). **Zipped** for compressed files.

## Other data source types

| Type | Notes |
|---|---|
| **JDBC** | MySQL 3306, SQL Server 1433, Oracle 1521 (Oracle DATE becomes Date/Time); directly (VPN) or through a **MID Server** (JDBC from the MID is unencrypted: limit the DB user's rights). **Query** all rows or **Specific SQL** (every selected column needs a name). **Use last run datetime** + **Last run database field** for delta loads. **Use integrated authentication** (Windows MID service account for SQL Server). Sybase, DB2 or other drivers: add a **Format** choice (value = driver class), upload the JAR in **MID Server > JAR Files** (role agent_admin), restart the MID. **Import Connection Alias** (`Import Connection Alias` module) holds reusable JDBC connection details |
| **LDAP** | created by the LDAP integration from an OU definition; servers without paging are "nibbled" in ranges of the OU's **Query** field. See [[LDAP Integration]] |
| **OIDC** | data from OpenID Connect |
| **REST (Integration Hub)** | a published **Data Source Request** action (inputs Limit, Offset, Last Success Import Time, Import Start Time; optional script step) plus **Support pagination**, **Limit**, **Offset**; format JSON, XML or Custom; roles import_admin and action_designer |
| **Data Stream (Integration Hub)** | a Data Stream action (paginated or over 10 MB; needs a subscription in production); complex data flattened or kept as JSON |
| **Custom (Load by Script)** | **Data Loader** script with `import_set_table` (`addColumn`, `addJSONColumn`, `addXMLColumn`, `insert(map)`, `getMaximumRows()` = 20 on test load), `data_source`, `import_log`, `last_success_import_time`, `partition_info`. **Enable parallel loading** + **Parallel loading script** (`parallel_job_loader.add(partitionInfo)`) needs a concurrent scheduled import with Partition Method *Custom size*. Jobs in `sys_parallel_job`, processed from event queue `impex_parallel_job_queue`; stuck 600 minutes = back to Pending (`com.glide.system_parallel_job_inactive_time_minutes`), 2 tries before Error (`...max_retry_count`, `...auto_retry`) |

All types: **Use Batch Import** / **Batch Size** (default 1000; properties `glide.import_set_load_usebatch` and `glide.import_set_load_batch_size` win over the form).

## Standard import set tables

| Table | Target | Coalesce | Notes |
|---|---|---|---|
| `imp_notification` | [[incident]] | `uuid` to `correlation_id` | alarms from monitoring tools; `message` to short description, `severity`, `state`, `source` to CI, unknown categories or groups are **created** |
| `imp_computer` | `cmdb_ci_computer` or server classes by `operating_system` | `serial_number` | CPU, RAM, disk fields |
| `imp_user` | [[sys_user]] | `email` | `user_name` = `first_name.last_name` if no `user_id` |
| `imp_location` | `cmn_location` | name, street, city, state, zip | |

They also serve as SOAP web services (`imp_notification.do?WSDL`).

## Date and time

The importing user's **Time zone** must match the time zone of the values in the file; use Date/Time target fields; map formats in the field map ([[Transform Maps, Field Maps and Coalesce]]).

## Cleanup

- Scheduled job **Import Set Deleter** (**System Import Sets > Import Set Tables > Scheduled Cleanup**) runs daily at midnight and deletes import sets older than **7 days** with their rows. If it was inactive, make sure staging tables total under 5 million rows before activating it (otherwise delete first, with Support).
- **Import Set Tables > Cleanup**: drop chosen staging tables (optionally their transform maps) or keep the structure and delete only the data.

## Roles

`import_admin` (data sources, monitoring), `import_transformer` (transform maps, ETL), `import_scheduler` (scheduled imports: **equivalent to admin**, it can run scripts as admin), `import_set_loader` (post files to `sys_import.do`), admin.

## Related

- [[Import Data with an Import Set]] · [[Scheduled and Concurrent Imports]] · [[Import Set Properties Reference]] · [[Integration Options and Interfaces Overview]] · [[Transform Scripts and Script Variables]]
