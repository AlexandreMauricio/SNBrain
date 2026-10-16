---
type: concept
tags: [concept, scripting, javascript, glide-api]
status: documented
source: ServiceNow docs, Brazil, API implementation and reference > Scripting, topics "Scripting on the ServiceNow AI Platform", "Exploring scripting", "Available script types", "Execution order of scripts and engines", "Script evaluation of fields by data type", "Scripting alert, info, and error messages", "Glide platform stack", "Writing server-side scripts", "Server-side scripts", "Writing client-side scripts", https://www.servicenow.com/docs/r/api-reference/scripts/scripting-landing.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Scripting overview: script types and where they run

**In one line:** platform JavaScript runs either on the **server** (Rhino-based engine, Glide server APIs, can touch the database) or in the **browser** (client APIs such as `g_form`, cannot touch the database directly); the first question for any script record is which side it runs on and in which scope.

## Global versus scoped

- **Scoped application**: use the scoped APIs. They have fewer methods than the global ones and global-only APIs cannot be called. See [[Application Scope and Namespace Identifiers]].
- **Global**: the special scope for pre-scoping apps and things every global app should see; global APIs.
- A third place: scripts that run on the MID Server.
- Scripts cannot use reserved words as names.

## Script types

| Script record | Runs on | Notes |
|---|---|---|
| Access control (ACL) | server | role, condition or script decides access ([[Access Control Lists (ACLs)]]) |
| Ajax: client part / server part | client / server | GlideAjax in the browser calls a script include on the server ([[Script Includes and GlideAjax]]) |
| Business rule | server (script and condition) | on display, insert, update, delete, query; before, after, async ([[Business Rules]]) |
| Catalog UI policy | conditions server, Execute if true/false client | [[Catalog Client Scripts, UI Policies and Variable Editors]] |
| Client script | client | onLoad, onChange (also on load), onSubmit, onCellEdit ([[Client Scripts]]) |
| Script action | server | runs when an event fires; often calls a script include ([[Events and the Event Queue]]) |
| Script include | server | functions or classes run only when called; reusable or complex logic belongs here |
| Transform map scripts | server | imports |
| UI action | client if **Client** is ticked (onClick plus Script), else server; condition always server | buttons, links, context menu items, list choices |
| UI context menu | onShow and action scripts client, dynamic actions and conditions server | |
| UI macro | server (Jelly), may output client script | [[UI Scripts, UI Pages, UI Macros and Jelly]] |
| UI page | Jelly server side, client script in the browser, processing script server side | |
| UI policy | conditions server, scripts client | prefer over client scripts ([[UI Policies]]) |
| UI properties | server, rendered on client | no scripts |
| UI script | client | reusable client code; "not recommended for use" per the type table |
| Validation script | client | format checks per field type |
| Workflow activities | server | legacy Workflow Editor |

Order of everything around a database write: [[Order of Execution for Rules, Engines and Notifications]] (the Brazil page gives the same list as the Australia one).

## What a field returns in a script

| Field type | Value in script |
|---|---|
| String, URL | the string |
| Decimal | number with up to two decimals |
| Integer | number |
| True/False | true or false |
| Date | `yyyy-mm-dd` |
| Date/Time | `yyyy-mm-dd hh:mm:ss` |
| Duration | a date: 1970-01-01 00:00:00 plus the duration (system time zone) |
| Choice | the stored **value** as a string, e.g. "2" |
| Journal | all entries as one string |
| Reference | the sys_id |
| Image | path of the image |
| Glide List | comma-separated sys_ids |

## Messages to the user or the log

| Where | Call | Effect |
|---|---|---|
| server | `current.<field>.setError('...')` | red message under the field |
| server | `gs.addInfoMessage('...')`, `gs.addErrorMessage('...')` | blue / red banner at the top |
| server | `gs.print('...')` | node text log only, not `syslog` |
| server | `gs.log('...')` | database log and file; heavy use slows the instance |
| client | `g_form.showFieldMsg('field', 'text', 'error' / 'info' / 'warning')`, `g_form.hideFieldMsg('field', clearAll)` | message under the field; the form scrolls to it (`glide.ui.scroll_to_message_field`) |
| client | `alert()`, `confirm()` | browser pop-ups; `alert` not usable in ATF; `showErrorBox()` is legacy |

Banner font sizes: `css.outputmsg.info.text.font-size`, `css.outputmsg.error.text.font-size` (default 11pt).

## Writing server scripts

Wrap one-context scripts (transform scripts and the like) in an immediately invoked function expression so variables do not leak into other scripts, parameters can be passed in and the function name shows in stack traces:

```javascript
// Pattern for single-context server scripts
(function exampleTransform(source) {
    function helper(value) { return value.trim(); } // visible only inside
    var cleaned = helper(source);
})('value');
```

Logic used from several places goes into a script include instead.

## The Glide stack

GlideServlet (the only servlet: requests, page rendering, merging data with forms) > Jelly for UI rendering > Mozilla Rhino as the ECMAScript engine for business rules and other scripts > persistence layer (JDBC to the database, also LDAP and files). Browser side: AngularJS, HTML, CSS, JavaScript.

## Related

- [[JavaScript Engine and JavaScript Modes]] · [[Script Sandbox and Guarded Script]] · [[GlideRecord Queries, GlideRecordSecure and Server Utilities]] · [[Debugging Scripts]] · [[JavaScript Syntax Editor]]
