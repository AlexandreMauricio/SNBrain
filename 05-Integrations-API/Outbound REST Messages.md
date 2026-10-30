---
type: concept
tags: [concept, api, integrations, scripting, script]
status: documented
source: ServiceNow Brazil docs, API implementation and reference > Web services > Outbound > REST (elements, Create a message, HTTP method, Test, header, MID Server, special characters, variables, scripting, examples), Logging, Mutual authentication, read 2026-10-30. Outbound REST authentication sub-pages (OAuth, credentials) listed, not read; see the linked notes. https://www.servicenow.com/docs/r/api-reference/web-services/c_OutboundRESTWebService.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Outbound REST Messages

**In one line:** the instance calling someone else's REST API, through a saved **REST Message** record or `sn_ws.RESTMessageV2` in a script.

From the Brazil docs; not tested. Prefer REST steps in flows for new low-code work where they fit (general knowledge; see [[Workflow Studio Overview]]). Multipart Content-Type is **not supported** in RestMessage: use the REST step.

## Records

**System Web Services > REST Message** (also written **Outbound > REST Message**: unconfirmed path), `web_service_admin`.

| Element | Notes |
|---|---|
| Endpoint | may use `${variable}` |
| Authentication | basic or OAuth 2.0, profile record; inherited by methods, which may override. See [[Connections, Credentials and Aliases]], [[OAuth 2.0 Outbound - The Instance as OAuth Client]] |
| HTTP headers | a method's header beats the message's |
| HTTP methods | body on PUT, POST, PATCH; **Use MID Server** |

Saving creates a GET method (one page says several default methods). **Later changes to the message do not flow to methods.** Methods have **Test** (results in Test Runs), **Auto-generate variables**, and **Preview script usage**. Encode special characters: `user%7Ctitle`, else *Invalid uri*.

Variables: `${name}` in Endpoint, header and query values, and Content for POST and PUT.

## Scripting

Server side (business rule, script include, and so on), global or scoped; namespace `sn_ws`.

```javascript
var sm = new sn_ws.RESTMessageV2('Example Message', 'Default GET');
sm.setStringParameter('id', 'EX001');            // escaped
sm.setStringParameterNoEscape('xml_data', '<a/>');
sm.setHttpTimeout(10000);                        // ms
var response = sm.execute();
var body = response.haveError() ? response.getErrorMessage() : response.getBody();
var status = response.getStatusCode();
```

Wrap in `try`/`catch`: a missing message or a scope problem throws. Keep credentials on a record, not in code. The docs samples use `setBasicAuth()`.

**No record:** `new sn_ws.RESTMessageV2()` then `setHttpMethod()`, `setEndpoint()`, `setRequestBody()`.

**Through a MID Server:** `setMIDServer('<MID name>')` with `executeAsync()`; always asynchronous, via the ECC queue. Rather than `waitForResponse(60)`, handle the response in a separate business rule. Mutual authentication does not work through a MID Server. See [[MID Server Overview and Architecture]] and KB0694711.

**Timeouts on `executeAsync`:** `glide.http.outbound.max_timeout` 30 s with `glide.http.outbound.max_timeout.enabled` true. For longer, set that false and use `glide.rest.outbound.ecc_response.timeout`. Otherwise five minutes.

## Logging

**System Logs > Outbound HTTP Requests**, read only. Log level via **Set log level**, **System Web Services > HTTP Log Levels**, or `setLogLevel()`.

| Property (add it) | Default |
|---|---|
| `glide.outbound_http.db.log` | true |
| `glide.outbound_http.content.max_limit` | 100, max 1000 characters |
| `glide.outbound_http.text.content_types` | none extra |
| `glide.outbound_http_log.override`, `.override.level` | false, `basic` (`elevated`, `all`); troubleshooting only |

## Mutual authentication

**System Security > Protocol Profiles**: name such as `mauth`, port, client certificate (Java Key Store or PKCS12). Then **Use mutual authentication** and **Protocol profile** on the message; the URL scheme becomes `mauth://`. REST mutual auth works with basic authentication only.

## Example

REST Message *Example Weather*, endpoint `https://api.example.com/v1/weather/${city}`, GET method; called from a script include with `setStringParameter('city', 'Example City')`.

## Related

- [[REST API Fundamentals]] · [[SOAP Web Services]] · [[API Usage Monitoring and Connection Pooling]]
