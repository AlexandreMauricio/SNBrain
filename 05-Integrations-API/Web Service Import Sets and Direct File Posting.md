---
type: concept
tags: [concept, import-sets, api, integrations]
status: documented
source: ServiceNow docs, Brazil, Workflow Data Fabric > Imports > Import sets, topics "Web service import sets", "Creating an import set web service", "Web service import set mode", "Inserting multiple records using insertMultiple", "Web service import sets security requirements", "Post CSV or Excel files directly to an import set", "Posting a CSV file - Perl and Java examples", "Imports", https://www.servicenow.com/docs/r/integrate-applications/system-import-sets/c_WebServiceImportSets.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Web service import sets and direct file posting

**In one line:** an import set table can be exposed as a web service so external systems insert rows that are transformed at once (synchronous) or later (asynchronous); files can also be posted straight into an import set through `sys_import.do`.

## Web service import sets (SOAP)

- Create: **System Web Services > Inbound > Create New**: **Name** = staging table name, **Label**, fields (all `xsd:string`), optional **Create transform map** to a target table. Later fields are added on the table itself.
- WSDL: `https://<instance>.service-now.com/<import_set_table>.do?WSDL` (e.g. `imp_notification.do?WSDL`). The standard tables `imp_notification`, `imp_computer`, `imp_user`, `imp_location` are already published.
- The REST equivalent is the **Import Set API** (`/api/now/import/<table>`, general knowledge for the path), which transforms synchronously and mirrors the SOAP interface.
- Security: basic authentication, ACLs of the target table apply; with high security settings the user may need the `soap` role. See [[Inbound API Authentication and API Access Policies]].
- Debug: create `glide.processor.debug.SOAPProcessor` = true to log every SOAP request (turn off afterwards).

### Modes

| Mode | State | Behaviour |
|---|---|---|
| Synchronous (default) | Loading | each insert is transformed immediately; set closed (Processed) at midnight, next insert opens a new one |
| Synchronous | Loaded | next insert creates a new synchronous set |
| Asynchronous | Loading | rows stay Pending; transform later (manual or scheduled) after setting Loaded |
| Asynchronous | Loaded | loading finished; ready to transform |

- With coalesce fields rows are transformed one at a time; without, concurrently (`glide.import_set_insert_serialized_when_no_coalesce`). Per table: `glide.import_set_insert_serialized.<table>` (true prevents duplicate inserts; false faster, may duplicate; wins over the older `glide.soap.import_set_insert_serialized.<table>`).
- `insertMultiple` (plugin **Insert Multiple Web Service**; new WSDL needed) inserts many records in one call; asynchronous if business rule **Insert multiple asynchronous mode** is active.
- Column growth for web service staging tables: `com.glide.ws_import_set.column_resize` and `...column_resize.max_row_count` (max 500,000 rows).

### Response

`sys_id`, `table` (staging table when asynchronous), `display_name`, `display_value`, `status` (`inserted`, `updated`, `ignored`, `skipped` (missing coalesce values), `error`), optional `status_message` (the row's **Comment**) and `error_message`. Transform scripts can set `status_message`, `error_message` and add elements through `response.<name> = value` ([[Transform Scripts and Script Variables]]).

## Posting a file

- `POST https://<instance>.service-now.com/sys_import.do?sysparm_import_set_tablename=<existing staging table>&sysparm_transform_after_load=true` with the CSV or Excel file as a **multipart** attachment. Role `import_set_loader`. The staging table must already exist (create it with a manual load first). `sysparm_transform_after_load=true` transforms right away if a map exists.
- The docs give Perl (LWP) and Java (Apache HttpClient) samples with basic authentication; the Java one is "not for production".

## Related

- [[Import Sets - Data Sources, Staging Tables and Cleanup]] · [[Integration Options and Interfaces Overview]] · [[Import Set Properties Reference]]
