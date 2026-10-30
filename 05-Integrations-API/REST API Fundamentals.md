---
type: concept
tags: [concept, api, integrations, security, access-control, encoded-query]
status: documented
source: ServiceNow Brazil docs, API implementation and reference > Web services > REST APIs (overview, Explore a table, OpenAPI export, Inbound rate limiting, Debug, session debug header, CORS requirements, Define a CORS rule, Enable OAuth, response codes), REST API reference > Table API (query parameters only), Aggregate, Attachment, Batch and Import Set API opening pages, read 2026-10-30. REST API Explorer tutorial pages and per-endpoint request and response samples listed, not read in detail. https://www.servicenow.com/docs/r/api-reference/rest-api-explorer/c_RESTAPI.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# REST API Fundamentals

**In one line:** how to call the instance from outside: URI format, headers, `sysparm_` parameters, dot-walking, security, CORS and rate limits. Everything else about auth lives in [[Inbound API Authentication and API Access Policies]].

From the Brazil docs; not tested.

## Calling an API

`https://<instance>.service-now.com/api/now/v2/table/incident`: the version is optional, and without it you get the latest.

- **Methods:** GET, POST, PUT, PATCH, DELETE, HEAD (HEAD returns no body).
- **Headers:** `Accept` on every call; `Content-Type` too on POST, PUT, PATCH and DELETE, otherwise **400**. Usually `application/json` or `application/xml`.
- **Multiple records** in POST, PUT or PATCH: only the first is processed.
- **Database views** are read-only.
- `X-http-method-override` overrides the method.
- **Clearing a field:** send an empty value (not for choice fields).
- **Currency** is converted to the user's locale on read, not on write.
- Inbound calls are in **Transaction logs** (`syslog_transaction`, `type=rest`).

## Parameters

| Parameter | Meaning | Default |
|---|---|---|
| `sysparm_query` | encoded query; supports `ORDERBY`, `ORDERBYDESC` | |
| `sysparm_fields` | fields to return; dot-walking allowed | all |
| `sysparm_limit` | page size. **Applied before ACLs**, so a page can come back empty even though you can read later records | 10000 |
| `sysparm_offset` | start index; add the limit for each page | 0 |
| `sysparm_display_value` | `true`, `false`, `all`; display values can be slower | false |
| `sysparm_input_display_value` | treat input as display values. **Required to set an encrypted field**; dates use the user's time zone instead of GMT | false |
| `sysparm_exclude_reference_link` | drop links on reference fields | false |
| `sysparm_no_count` | skip the `select count(*)` | false |
| `sysparm_view` | `desktop`, `mobile`, `both`; `sysparm_fields` wins | |
| `sysparm_query_no_domain` | include other domains; admin or `query_no_domain_table_api` | false |
| `sysparm_suppress_pagination_header` | no pagination headers | false |

Column names, operators and values are case-sensitive. An invalid part of a query is **ignored**, so a typo can return more rows. `glide.invalid_query.returns_no_rows` = true returns none, but it affects lists and `GlideRecord` too.

**Dot-walking:** `sysparm_query=company.stock_symbol=NYX` and `sysparm_fields=user.name,role.name`. Not in the Import Set API.

## Main APIs

| API | Path | Note |
|---|---|---|
| Table | `/api/now/table/{tableName}` | CRUD |
| Attachment | `/api/now/attachment` | `/file`, `/upload`, `/{sys_id}/file`; one file per call; `com.glide.attachment.max_size` default 1024 MB. No single role adds attachments |
| Aggregate | `/api/now/stats/{tableName}` | counts, sums and averages |
| Batch | | several calls in one; item limits 5 MB in (`glide.rest.batch.max.inputSize`, max 10) and 10 MB out (`glide.rest.batch.max.outputSize`); not for parallel work |
| Import Set | `/api/now/import/{stagingTableName}` | synchronous transforms; `/insertMultiple`; [[Import Sets - Data Sources, Staging Tables and Cleanup]] |

Tools: **System Web Services > REST API Explorer** (`rest_api_explorer`; **it acts on real data**), table form > **Configure > Table > Explore REST API**, and export to **OpenAPI** YAML or JSON (`web_service_admin`, `rest_api_explorer` or `admin`).

## Security

Calls run as the authenticated user under normal ACLs; hidden fields are left out.

- **REST API ACLs** can cover an API or an endpoint. The Table, Aggregate, Import Set and Attachment API ACLs ship **deactivated**; do not rename REST API ACLs.
- **All tables are reachable** unless **Allow access to this table via web services** is cleared. **Can read**, **Can create** and similar settings do **not** apply to web services.
- `sys_public` opens a table without authentication. Not advised.
- **MFA** is not required for Basic Auth by default from Yokohama. With MFA a bad token gives 401 with header `X-MFA_TOKEN: invalid`.
- OAuth: plugin `com.snc.platform.security.oauth.is.active`, **System OAuth > Application Registry**, POST to `oauth_token.do`; see [[OAuth 2.0 Inbound - The Instance as OAuth Provider]]. [[Register an OAuth Client for Inbound REST Calls]] has the steps.

| Code | Meaning |
|---|---|
| 200, 201, 204 | success, created, no body |
| 400 | wrong URI, headers or unknown failure |
| 401 | not authenticated |
| 403 | denied: ACL, business rule or data policy |
| 404 | not found, **also an ACL** |
| 405, 406, 415 | method, `Accept` or body format not supported |
| 429 | rate limited |
| 500, 502, 503 | server side |

## CORS

**System Web Services > REST > CORS Rules** (`cors_rule_admin`, `web_service_admin`, `admin`). REST only, not SOAP. No rule means no cross-origin call. `glide.rest.cors.enabled` true by default.

Domain starts `http://` or `https://`; one wildcard right after the scheme, as in `https://*.example.com`; IP addresses must be complete. `*` alone is invalid. **Exact matches win**, then the closest. **Access-Control-Allow-Credentials** forbids a wildcard domain. **Max age** 0 means preflight on every call.

## Rate limits

**System Web Services > REST > Rate Limit Rules** (`sys_rate_limit_rules`, `rate_limit_admin`): per hour, by API, version, resource and table, for one user, a role or everyone.

- Single user beats role, role beats all users.
- A user matching several role rules gets the **lowest** limit.
- Counts commit every 30 seconds, so a rule may lag.
- Denied calls get **429** and `Retry-After`. Headers: `X-RateLimit-Limit`, `X-RateLimit-Reset`, `X-RateLimit-Rule`.
- Editing the limit resets the count. Violations clear biweekly.

## Debugging

`glide.rest.debug` true logs all inbound processing, including the body, so set it back. Header `X-WantSessionDebugMessages: true` returns session debug logs in the response, once session debugging is on.

## Example

```bash
curl -H "Accept: application/json" -u "<USER>:<PASSWORD>" "https://<instance>.service-now.com/api/now/table/incident?sysparm_query=active=true^ORDERBYnumber&sysparm_fields=number,caller_id.name&sysparm_limit=50&sysparm_offset=0"
```

## Related

- [[Scripted REST APIs]] · [[Outbound REST Messages]] · [[SOAP Web Services]] · [[API Usage Monitoring and Connection Pooling]] · [[Non-Interactive Users]] · [[Integration Options and Interfaces Overview]]
