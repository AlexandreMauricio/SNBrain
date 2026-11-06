---
type: reference
tags: [reference, api, integrations, import-sets, release-specific]
status: documented
source: ServiceNow Brazil docs, API implementation and reference > REST API reference (map ooCZhg2g6YDYvKp3oBwAxA, node keRK4IL_S4WbT0HjSHbo2A) - Table API, Attachment API, Aggregate API, Batch API, Import Set API, Email API, User Role Inheritance API, Script Debugger API, Knowledge Management REST API pages, read 2026-11-06 through the docs site API. Response samples and cURL listings skimmed, not copied.
sn-release: Brazil
verified:
verified-by:
observed-in:
updated: 2026-11-06
---

# Core Platform REST APIs - Table, Attachment, Aggregate, Batch, Import Set and Others

**In one line:** the inbound REST APIs a developer reaches for first, endpoint by endpoint: **Table** (CRUD on any table), **Attachment** (files), **Aggregate** (counts and statistics), **Batch** (several calls in one), **Import Set** (load through a staging table and a transform), plus **Email**, **User Role Inheritance**, **Script Debugger** and **Knowledge**.

From the Brazil REST API reference; not tested. URI rules, headers, the shared `sysparm_` parameters, ACLs, CORS and rate limits are in [[REST API Fundamentals]]; this note only adds what each API does differently. Every endpoint also has a versioned form `/api/now/{api_version}/...` (versions listed in the REST API Explorer).

## Table API (`/api/now/table/{tableName}`)

| Method | Path | Notes |
|---|---|---|
| GET | `/table/{tableName}` | list; `sysparm_query`, `sysparm_fields`, `sysparm_limit`, `sysparm_offset`, `sysparm_display_value`, `sysparm_exclude_reference_link`, `sysparm_view`, `sysparm_suppress_pagination_header`, `sysparm_no_count`, `sysparm_query_category`, `sysparm_query_no_domain` |
| GET | `/table/{tableName}/{sys_id}` | one record |
| POST | `/table/{tableName}` | inserts **one** record per call (use Batch or Import Set for many) |
| PUT, PATCH | `/table/{tableName}/{sys_id}` | update; `sysparm_input_display_value` |
| DELETE | `/table/{tableName}/{sys_id}` | delete one record |

- `sysparm_input_display_value=true` sets fields by display value; the docs say it must be true to write **encrypted fields**.
- `sysparm_query_no_domain=true` queries across domains; needs `admin` or the `query_no_domain_table_api` role.
- `sysparm_query_category`: "name of the category to use for queries"; what the categories are is not explained on the page (meaning unconfirmed).

## Attachment API (`/api/now/attachment`)

| Method | Path | Notes |
|---|---|---|
| GET | `/attachment` | metadata list; `sysparm_query`, `sysparm_limit`, `sysparm_offset` |
| GET | `/attachment/{sys_id}` | metadata of one file |
| GET | `/attachment/{sys_id}/file` | the binary content |
| POST | `/attachment/file` | binary body; query `table_name`, `table_sys_id`, `file_name`, optional `encryption_context`, `creation_time` |
| POST | `/attachment/upload` | `multipart/form-data`; no query parameters; table name and record sys_id go in the form body, and the file must be the **last** part |
| PATCH | `/attachment/{sys_id}` | rename (`file_name`) |
| DELETE | `/attachment/{sys_id}` | delete the file |
| GET, POST, PUT, DELETE | `/attachment/{sys_id}/attributes[/{attribute_key}]` | key and value attributes on an attachment |

Accepts any Content-Type; one file per call; size limit `com.glide.attachment.max_size` (1024 MB default). **No single role** grants adding attachments: the record's ACLs and the attachment ACLs decide. Files live in `sys_attachment` and `sys_attachment_doc` (table names general knowledge).

## Aggregate API (`/api/now/stats/{tableName}`)

GET only. Parameters: `sysparm_count` (true), `sysparm_avg_fields`, `sysparm_min_fields`, `sysparm_max_fields`, `sysparm_sum_fields` (comma lists), `sysparm_group_by`, `sysparm_having` (`<aggregate>^<field>^<operator>^<value>`, for example `count^priority^>^5`), `sysparm_order_by` (an aggregate or a group-by field), `sysparm_query`, `sysparm_display_value`. **Pass `sysparm_count` or at least one aggregate field**, or no aggregation is done. Server-side equivalent: [[GlideAggregate and GlideQuery API Reference]].

## Batch API (`POST /api/now/batch`)

- Body: `batch_request_id` and `rest_requests[]`, each with `id`, `method`, `url` (relative, such as `/api/now/table/incident?sysparm_limit=1`), `headers[]` (name and value), `body` (Base64), `exclude_response_headers`. Response: `serviced_requests[]` and `unserviced_requests[]`.
- Any API on the instance can be included; ACLs apply per item. Formats can be mixed (XML for one item, JSON for another).
- Limits: each request item 5 MB (`glide.rest.batch.max.inputSize`, up to 10 MB); each response item 10 MB (`glide.rest.batch.max.outputSize`, or the `X-BATCHREQUEST-MAX-OUTPUT-SIZE` header, never above the property). Hitting a limit cancels the transaction. Response streaming buffering can be turned off with `glide.rest.serialize.disable_response_stream_buffering`.
- Same performance as separate calls minus the round trips; **not** for parallel processing; long items can exceed the transaction time limit.

## Import Set API (`/api/now/import/{stagingTableName}`)

| Method | Path | Notes |
|---|---|---|
| POST | `/import/{stagingTableName}` | inserts one row and runs the transform **synchronously**; response per row: `transform_map`, `table`, `display_name`, `display_value`, `record_link`, `status` (for example *inserted*), `sys_id` |
| POST | `/import/{stagingTableName}/insertMultiple` | many rows in one call; transform **asynchronous** by default (make it synchronous with a record in **Rest Insert Multiples** `sys_rest_insert_multiple`); body either matches the JSON data source file or the staging columns (default); query `multi_import_set_id` (`sys_multi_import_set`) and `run_after` (order sequential imports) |
| GET | `/import/{stagingTableName}/{sys_id}` | the transform result of an earlier row |

- Works with transform maps or **Robust Transform Engine** (RTE) configurations ([[Robust Import Set Transformers and ETL Definitions]]).
- Accepts only **string** name and value pairs; other data types are stored oddly (nested JSON `:` becomes `=`).
- Staging tables may be reachable through `sys_public`, but ACLs still apply. A hardening setting covers this endpoint (`com.glide.import_set_api.insert_multiple_optimize`, [[Hardening Settings - Access Control]]).
- Request timeout 60 s ([[Transaction Quotas, Application Quotas and Operational Toggles]]).

## Smaller platform APIs

| API | Endpoints | Notes |
|---|---|---|
| **Email** | GET `/api/now/email/{id}` (`sysparm_fields`); POST `/api/now/email` (`to`, `cc`, `bcc` arrays, `subject`, `text`, `html`, `importance`, `headers`, `table_name`, `table_record_id`) | sending needs `email_api_send`; read and write access to [[sys_email]] also needed |
| **User Role Inheritance** | GET `/api/global/user_role_inheritance?user_sysid=<sys_id>` | returns the roles a user has, granted directly or inherited from roles or groups; plugin `com.glide.role_management.inh_count.rest_api` (active by default since Jakarta) |
| **Script Debugger** | GET `/api/now/js/debugpoints/script/{tableName}/{sysId}/{fieldName}` and related calls | list, add, update or remove **breakpoints and logpoints** on a script field (`fetchAll`, `debugpointType`, `lineNumber`, `evaluationString`) |
| **Knowledge** (`sn_km_api`) | GET `/api/sn_km_api/knowledge/articles` (`query`, `filter`, `fields`, `kb`, `language`, `limit`, `offset`); `/articles/featured`, `/articles/most_viewed`, `/articles/{id}` (KB number or sys_id; `search_id` only when `id` is a KB number), `/articles/{article_sys_id}/attachments/{attachment_sys_id}` | search and read articles as a user would; see [[Knowledge Management Overview]] |

## Example

Count active incidents per priority, keeping only priorities with more than five:

```bash
curl -H "Accept: application/json" -u "<USER>:<PASSWORD>" "https://<instance>.service-now.com/api/now/stats/incident?sysparm_query=active=true&sysparm_count=true&sysparm_group_by=priority&sysparm_having=count^priority^>^5"
```

Attach a file to a record of *Example Table*:

```bash
curl -X POST -u "<USER>:<PASSWORD>" -H "Content-Type: text/plain" --data-binary @example.txt "https://<instance>.service-now.com/api/now/attachment/file?table_name=u_example_table&table_sys_id=<RECORD_SYS_ID>&file_name=example.txt"
```

## Related

- [[REST API Fundamentals]] · [[Scripted REST APIs]] · [[Import Sets - Data Sources, Staging Tables and Cleanup]] · [[Transform Maps, Field Maps and Coalesce]] · [[Inbound API Authentication and API Access Policies]] · [[CMDB REST APIs - Instance, Meta, IRE and Data Ingestion]] · [[Service Catalog and Change Management REST APIs]] · [[CICD REST APIs]]
