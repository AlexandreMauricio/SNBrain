---
type: concept
tags: [concept, api, integrations, security, roles, script]
status: documented
source: ServiceNow Brazil docs, API implementation and reference > Web services > Inbound > SOAP web service (overview, Scripted services intro, Direct services extended parameters and namespace, Long-running, Retrieve a large number of records), Outbound > SOAP (overview, connectivity, security intro, scripting), read 2026-10-30. Scripted service steps, direct API functions, WS-Security profiles and properties, AttachmentCreator, Hierarchical messages, client examples (Java, .NET, Perl, Python) listed, not read in detail. https://www.servicenow.com/docs/r/api-reference/web-services/c_SOAPWebService.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# SOAP Web Services

**In one line:** the older XML interface: every table publishes a WSDL for inbound calls, and SOAP Messages call out to others. Use it when the other side requires it; otherwise see [[REST API Fundamentals]].

From the Brazil docs; not tested.

## Inbound

Three kinds:

- **Direct:** `https://<instance>.service-now.com/incident.do?WSDL`.
- **Import set:** through a staging table and transform map.
- **Scripted:** custom JavaScript, server side. Use the other two where possible.

**Roles** (with table access):

| Role | Can |
|---|---|
| `soap` | all |
| `soap_query`, `soap_create`, `soap_update`, `soap_delete`, `soap_query_update` | that operation |
| `soap_ecc` | `ecc_queue` |
| `soap_script` | scripted services |
| `import_admin`, `import_transformer` | `sys_import_set_row` |

Processor ACLs require `soap_query` for WSDL and XSD requests. `glide.basicauth.required` forces an Authorization header. WS-Security 1.1 (X.509 and Username tokens) is available; `glide.processor.debug.SOAPProcessor` logs envelopes.

**Direct parameters** on `get`, `getKeys`, `getRecords`, with two underscores: `__encoded_query`, `__order_by`, `__order_by_desc`, `__exclude_columns`, `__limit`, `__first_row`, `__last_row` (exclusive), `__use_view`. `glide.wsdl.definition.use_unique_namespace` true gives each table its own namespace.

**Limits:** one request returns at most **250 records** by default; page with first and last row, filter first, or sync data to a local store (scheduled export, or `incident_list.do?CSV`).

**Long-running:** past `glide.soap.request_processing_timeout` a client gets a 307 redirect only if `glide.soapprocessor.allow_long_running_threads` is true, the URL has `redirectSupported=true`, it keeps cookies, and `glide.soap.max_redirects` is not exceeded; else **408**. Hosted socket timeout is 300 s. No CORS for SOAP. Decoding is always UTF-8.

## Outbound

**System Web Services > Outbound > SOAP Message**; function records, **Preview script usage**. Server side, namespace `sn_ws`, same shape as [[Outbound REST Messages]]:

```javascript
var sm = new sn_ws.SOAPMessageV2('Example Service', 'ExampleFunction');
sm.setStringParameter('id', 'EX001');
sm.setHttpTimeout(10000);
var response = sm.execute();
var body = response.haveError() ? response.getErrorMessage() : response.getBody();
```

- `executeAsync()` does not wait; `setMIDServer()` uses a MID Server. **Async goes through the ECC queue but uses a MID Server only if configured.**
- Reach an internal endpoint by firewall rule, MID Server or VPN.
- Security: basic, WS-Security (signing), mutual authentication.
- Parse with `XMLDocument`, `gs.getXMLText()`, `gs.getXMLNodeList()`.
- Timeouts: `glide.soap.outbound.ecc_response.timeout`.

## Example

Integration user *Example SOAP User* with `soap_query` and `itil`, reading `incident.do?WSDL`, `getRecords` with `__encoded_query` `active=true` and `__limit` 100.

## Related

- [[REST API Fundamentals]] · [[Outbound REST Messages]] · [[Import Sets - Data Sources, Staging Tables and Cleanup]] · [[JSONv2, RSS and ODBC Interfaces]]
