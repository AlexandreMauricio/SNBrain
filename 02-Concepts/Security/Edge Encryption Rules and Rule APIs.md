---
type: concept
tags: [concept, security, scripting, javascript, integrations, api, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Encryption > Edge Encryption (chapter read in full 2026-10-08) - Define a custom encryption rule, Inspect the client request, Create an encryption rule, Encryption rule conditions, Encryption rule actions, Encryption rule objects and APIs, request, POST and URL parameter APIs, XML APIs (XMLContent, XMLElementIterator, XMLElement), JSON APIs (JsonNode, JsonNodeIterator), print, Prohibited keywords. https://www.servicenow.com/docs/r/platform-security/edge-encryption/c_EncryptionRules.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Edge Encryption Rules and Rule APIs

**In one line:** an encryption rule is a small JavaScript script that runs **on the Edge Encryption proxy**, not on the instance: its condition recognises a kind of HTTP request and its action tells the proxy which values in that request belong to which table and field, so the proxy can encrypt the ones that are configured for encryption.

From the Brazil docs. Context: [[Edge Encryption Overview]], [[Edge Encryption Configuration - Keys, Jobs, Patterns and Integrations]]. Edge Encryption is being deprecated.

## Where it runs and what it may use

- Runs in the proxy's script engine in the customer network. **ECMAScript 3 only.**
- No Glide APIs, no script includes, no business rules, no `current`, no scoped or allow-list APIs. The only global is `request`.
- Forbidden keywords (the proxy validates before saving): `new`, `this`, `throw`, `eval`, `Object`, `prototype`, `RegExp`, `Error`, `Java`, `javax`, `javafx`, `JavaImporter`, `Packages`, `load`, `loadWithNewGlobal`, `getClass`, `getPrototypeOf`, `setPrototypeOf`, `__proto__`, `__parent__`, `__DIR__`, `__FILE__`, `__LINE__`.
- Stored on the instance in `sys_encryption_rule`, signed, and synchronised to every proxy.

## When a custom rule is needed

Shipped rules already cover list edits, form saves, direct web services and the REST API, so applications built from standard forms and lists need none. Write one for anything that posts its own payload: scripted processors, scripted web services, scripted REST APIs, custom UI or Ajax scripts, record producers with scripted mappings.

## Anatomy

**Edge Encryption Configuration > Rules > Create New** (role `security_admin`, logged in through the proxy): **Name**, **Request Type** (HTTP Post, Get, Put, Patch, Delete), **Condition**, **Action**, **Order**, **Active**.

- Conditions are evaluated in ascending order; the **first** that returns true runs its action and **no other rule runs** for that request (attachment requests are not evaluated by rules).
- So conditions should be as specific as possible, and unavoidable generic rules get a high order.
- Cheap exclusions first; heavy content checks in a condition add latency to every request.
- Prefer several small rules (per table, per record producer) over one rule full of branches: fewer blocks validate and run faster, at the price of maintenance.
- The body is parsed as a stream: read it **in a single pass**.
- First find out what the request looks like: browser developer tools, or a protocol analyser for third-party callers. Note method, path, URL parameters, POST parameters, body format.

## The request object

| Member | Gives |
|---|---|
| `request.path`, `request.requestMethod`, `request.contentType` | URL path, method, Content-Type header |
| `request.urlParams.<name>`, `request.postParams.<name>` | parameters, each a *ParameterValue* |
| `request.getAsJsonContent()` | the body as a *JsonNode* (body must be JSON) |
| `request.getAsXmlContent()` | the body as *XMLContent* (body must be XML) |
| `request.xmlContains(path)` | true if the path exists in the XML body |

Methods shared by ParameterValue, JsonNode and XMLElement:

| Method | Tells the proxy |
|---|---|
| `valueFor(tableName, fieldName)` | "this value is destined for that field": the proxy encrypts it **if** the field has an encryption configuration, and otherwise leaves it |
| `encodedQueryFor(tableName)` | "this value is an encoded query on that table": the proxy encrypts the values of encrypted fields inside the query so that it matches stored cipher text |

| Type | Other methods |
|---|---|
| ParameterValue | `toString()`, `getAsJsonContent()`, `getAsXmlContent()` |
| JsonNode | `getIterator(path)` (root node only), `iterator()` (children), `getName()`, `getAsString()`, `getAsString(propertyName)` |
| XMLContent | `getIterator()`, `getIterator(path)` |
| XMLElement | `getIterator(path)`, `getIteratorOverAllChildren()`, `getName()`, `getAttributeValue(name)` |
| Iterators | `hasNext()`, `next()` (always call `hasNext()` first) |
| `print(message)` | action scripts only: writes to `logs/wrapper_<date>.log` on the proxy |

Paths are XPath-like, for example `data/records/description`.

## Example

Runs on the Edge Encryption proxy (rule condition and action; not instance-side code). A custom endpoint `/example_intake.do` receives JSON whose `items` array holds objects named after the columns of `u_example_request`, except that `summary` belongs in `short_description`.

```javascript
// Condition: cheap checks only
function ExampleIntakeCondition(request) {
    if (request.requestMethod != 'POST') return false;
    if (request.path.indexOf('/example_intake.do') == -1) return false;
    return request.contentType.indexOf('json') > -1;
}

// Action: one pass over the body
function ExampleIntakeAction(request) {
    var tableName = 'u_example_request';
    var items = request.getAsJsonContent().getIterator('items');
    while (items.hasNext()) {
        var fields = items.next().iterator();
        while (fields.hasNext()) {
            var field = fields.next();
            if (field.getName() == 'summary')
                field.valueFor(tableName, 'short_description');
            else
                field.valueFor(tableName, field.getName());
        }
    }
}
```

(Written from the documented API, not run. The docs' own samples contain slips, such as `request.urlParam` for `request.urlParams` and an undefined variable, so test any rule on a non-production proxy.)

## Troubleshooting

An exception in a condition or action is reported in the proxy log. With timing logging switched on, each request line names the rule executed and its duration ([[Edge Encryption Proxy Properties Reference]]).

## Related

- [[Edge Encryption Overview]] · [[Edge Encryption Configuration - Keys, Jobs, Patterns and Integrations]] · [[Edge Encryption Proxy Properties Reference]]
