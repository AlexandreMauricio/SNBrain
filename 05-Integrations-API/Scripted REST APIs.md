---
type: concept
tags: [concept, api, integrations, scripting, access-control]
status: documented
source: ServiceNow Brazil docs, API implementation and reference > Web services > REST APIs > Scripted REST APIs (overview, Create, ACL pages, path-based ACLs, versioning, content types, maximum request size, good practices, script sample start), read 2026-10-30. Header, schema and query parameter steps, auto-generate, and streaming examples listed, not read in detail. https://www.servicenow.com/docs/r/api-reference/rest-api-explorer/c_CustomWebServices.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Scripted REST APIs

**In one line:** build your own REST endpoints on the instance, each resource running a server-side script, when the Table API does not fit.

From the Brazil docs; not tested. Create at **System Web Services > Scripted REST APIs** (`web_service_admin`; that role is not needed to call the API).

`https://<instance>/api/<name_space>/<version>/<api_id>/<relative_path>`

- **Namespace:** the scope name such as `x_company_appname` in a scoped application; the value of `glide.appcreator.company.code` in global.
- **Version:** optional.
- **API ID:** from the name.
- **Relative path:** such as `/{id}`.

**Parts:** service, resources (method, script, overrides), query parameters, headers, schemas (OpenAPI 3.0.1), versions.

## The script

Server side, in a resource record, in the API's scope.

```javascript
(function process(/*RESTAPIRequest*/ request, /*RESTAPIResponse*/ response) {
    var id = request.pathParams.id;
    var filter = request.queryParams.filter;
    var token = request.getHeader('X-Example');
    return { id: id, filter: filter };
})(request, response);
```

- Body: `request.body.data`, `dataString`, `nextEntry()`, `hasNext()`, or `dataStream`.
- Non JSON or XML bodies: **use only `dataStream`**, or you get a 500.
- Binary responses: `response.getStreamWriter()`.
- Form-encoded values merge into `request.queryParams`.
- **Error objects** return a standard error; the status code is in the header, not the body.

**Use `GlideRecordSecure`** in scripts so ACLs apply to the caller.

## Security

| Goal | Requires authentication | Requires ACL authorization | ACLs |
|---|---|---|---|
| public | false | any | any |
| authentication only | true | false | any |
| API default ACLs | true | true | none on the resource; set on the API |
| resource ACLs | true | true | set on the resource, override the API |

- ACLs must be type `REST_Endpoint`. **Any one** selected ACL is enough.
- Resources inherit from the API.
- Table ACLs still apply to data.
- Control the auth method with [[Inbound API Authentication and API Access Policies|API access policies]].

**Path-based ACLs** (`sys_security_acl`, type REST Endpoint, HTTP method, full **Resource path**; `security_admin` or `admin`): add security without changing the API, for example read-only ones. Evaluated on **every** request, unlike ACLs on the resource which need **Requires authentication**. All applicable ACLs must pass. See them on **REST resource ACLs** or **View Resource ACLs** in the Explorer.

**Unconfirmed wording:** the page lists *Path-based ACLs do override operation-referenced ACLs* under the heading *No Overriding*, and says they work alongside them.

## Versions and formats

- **Enable versioning** related link; **Add new version** can copy resources. With no default, callers must name a version; if none is marked, the latest is used.
- Default formats `application/json`, `application/xml`, `text/xml`, set at API or resource. Unsupported: **406** or **415**. Wildcards `%` and `*`.

| Property (add it) | Default |
|---|---|
| `glide.rest.scripted.max_inbound_content_length_mb` | 10 |
| `glide.rest.scripted.max_inbound_gzip_content_length_mb` | 1 |
| `glide.rest.max_content_length` | 10, maximum 25; caps both |

Over the limit gives **400**. Not applied to `dataStream`.

## Good practices

GET never changes data; POST creates; PUT and PATCH update; DELETE destroys. Version before breaking changes. Return meaningful codes and messages. Stricter ACLs for changes than for reads. Test with [[Automated Test Framework Overview|ATF]] inbound REST steps or Postman.

## Example

Service *Example Status API*, API ID `example_status`, resource GET `/{id}`, reading a record with `GlideRecordSecure`, ACL *Example REST Read* of type `REST_Endpoint`.

## Related

- [[REST API Fundamentals]] · [[Outbound REST Messages]] · [[Scripting Overview - Script Types and Where They Run]]
