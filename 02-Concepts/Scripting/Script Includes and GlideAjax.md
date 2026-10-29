---
type: concept
tags: [concept, scripting, script-include, client-script, glide-api, security]
status: documented
source: ServiceNow docs, Brazil, API implementation and reference > Scripting, topics "Script includes", "AJAX scripts", "General guidelines for client script design and processing", https://www.servicenow.com/docs/r/api-reference/scripts/c_ScriptIncludes.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Script includes and GlideAjax

**In one line:** a script include (`sys_script_include`) is a named server-side class or function that runs only when another script calls it; marked **Glide AJAX enabled** and extending `AbstractAjaxProcessor`, it can also be called from the browser with **GlideAjax**.

## The form

**System Definition > Script Includes**.

| Field | Meaning |
|---|---|
| **Name** | must equal the class name (and `type`), or the function name for a classless include |
| **API Name** | `scope.Name`, used from other scopes |
| **Glide AJAX enabled** (was *Client callable*) | callable from client scripts, list and report filters, reference qualifiers, URLs; needs an ACL; adds the **Access Controls** related list. Ticking it pops up a role picker that creates the ACL (`glide.script.ccsi.enable_acl_create_ux` = false turns the picker off) |
| **Mobile callable** | callable from mobile client scripts |
| **Sandbox enabled** | callable from the script sandbox (filters, conditions). Tick only if needed ([[Script Sandbox and Guarded Script]]) |
| **Accessible from** | *All application scopes* or *This application scope only* |
| **Active**, **Description**, **Script**, **Package** | |
| **Protection policy** | None, Read-only, Protected (code hidden and encrypted in memory for downloaded apps) |
| **Versions** | compare and revert |

Prefer script includes to global business rules: they load only when called.

## Shape

```javascript
// Script include "ExampleUtils" (server-side; global or scoped)
var ExampleUtils = Class.create();
ExampleUtils.prototype = {
    initialize: function() {},
    myFunction: function() { /* code */ },
    type: 'ExampleUtils'
};
// Caller: new ExampleUtils().myFunction();
```

## GlideAjax (client calls server)

Rules: the include extends `AbstractAjaxProcessor` and is Glide AJAX enabled; the client passes `sysparm_name` (the method) and its own parameters, all starting with `sysparm_` (avoid `sysparm_name`, `sysparm_function`, `sysparm_value`, `sysparm_type` for your own data); methods starting with `_` are private; do not override `initialize` or other parent methods.

```javascript
// Script include "ExampleAjax", Glide AJAX enabled (server-side, global scope)
var ExampleAjax = Class.create();
ExampleAjax.prototype = Object.extendsObject(AbstractAjaxProcessor, {
    getGroupMatch: function() {
        var ci = new GlideRecordSecure('cmdb_ci');
        if (ci.get(this.getParameter('sysparm_ci')))
            return ci.getValue('support_group') == this.getParameter('sysparm_ag') ? 'match' : 'no match';
        return 'no match';
    },
    type: 'ExampleAjax'
});
```

```javascript
// onChange client script on cmdb_ci (browser)
function onChange(control, oldValue, newValue, isLoading, isTemplate) {
    if (isLoading || !newValue || newValue == oldValue) return;
    var ga = new GlideAjax('ExampleAjax');
    ga.addParam('sysparm_name', 'getGroupMatch');
    ga.addParam('sysparm_ci', newValue);
    ga.addParam('sysparm_ag', g_form.getValue('assignment_group'));
    ga.getXML(function(response) {
        var answer = response.responseXML.documentElement.getAttribute('answer');
        g_form.addInfoMessage(answer);
    });
}
```

- `getXML(callback)` is asynchronous: use it. `getXMLWait()` blocks the session, is unavailable in scoped apps and on mobile. Never use `AJAXEvaluateSynchronously`.
- Several values: build XML nodes with `this.newItem('name')` and `setAttribute()`, read them with `responseXML.getElementsByTagName()`.
- Helper `AjaxClientHelper.getDisplay` returns a record's display value.
- The docs pages still say "select the **Client callable** check box" in the GlideAjax steps; the form now calls it **Glide AJAX enabled**.

## Privacy and security of Glide AJAX enabled includes

- **Private**: not callable by guests on public pages. **Public**: callable by anyone who builds the right HTTP request; risky if it returns data.
- All at once: property `glide.script.ccsi.ispublic` (false = all private; see hardening setting "require authentication by default for client-callable script includes"). Per include: `isPublic: function() { return false; }` wins over the property.
- Public by default because public UI pages need them: `GlideSystemAjax`, `SysMessageAjax`, `KnowledgeMessagingAjax`, `KnowledgeAjax`, `PasswordResetAjax`.
- On save the platform recommends an ACL (unless public) and **GlideRecordSecure** instead of GlideRecord; turn the messages off with `glide.script.ccsi.customer_scoped.security_msgs_enabled` = false.

## Choosing how the client gets server data

| Method | When |
|---|---|
| `g_scratchpad` filled by a **display** business rule | data known before the form loads; sent once with the form; fastest |
| asynchronous GlideAjax | data that depends on what the user does |
| `g_form.getReference()` or client GlideRecord | discouraged: fetch whole records; on mobile only with a callback |

Also: pass the display value to `g_form.setValue('ref_field', sys_id, displayValue)` to avoid an extra round trip.

## Discovery helpers

`GlideRecordUtil`: `getCIGR(sys_id)` (CI in its real class), `getGR(base_table, sys_id)`, `getFields(gr)`, `populateFromGR(obj, gr, ignore)`, `mergeToGR(obj, gr, ignore)`, `getTables(table)` (hierarchy). `DiscoveryException` extends `AutomationException` extends `GenericException` (message, cause). discovery_admin can write script includes.

## Related

- [[Client Scripts]] · [[Business Rules]] (display rules, g_scratchpad) · [[Scripting Overview - Script Types and Where They Run]] · [[Access Control Lists (ACLs)]]
