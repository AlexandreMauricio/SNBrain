---
type: troubleshooting
tags: [troubleshooting, portal, scripting, javascript, release-specific]
status: documented
source: ServiceNow Brazil docs, ServiceNow AI Platform user interface > Service Portal > Developing custom widgets > Widget troubleshooting guide and Widget diagnostics (6 topics), read 2026-11-06 through the docs site API (map 7xQNQY92V5DYmBMD7wXg9g). KB0744521 and KB0634588 are linked but not read.
sn-release: Brazil
verified:
verified-by:
observed-in:
updated: 2026-11-06
---

# Service Portal widget misbehaves or loads slowly

**Symptom:** a portal page or widget shows nothing, wrong data, *You are either not authorized or record is not valid*, breaks after an upgrade, or loads slowly.
**Cause:** usually access (ACLs, user criteria), a customised or outdated clone, a removed Angular Provider, or a widget moving too much data.
**Fix:**

1. **Reduce complexity:** set **Active** false on unrelated widgets (`sp_widget`) to isolate the one at fault; inactive widgets are hidden and their scripts do not run.
2. **Check access:** open the same records in the platform UI as that user, check user criteria, use the ACL debugger ([[Access Control Lists (ACLs)]]). For a catalog widget error above, check the item is not hidden from Service Portal.
3. **Check Angular Providers:** removing a base widget's default providers breaks it (for example `scToggleData`, `scBindHtmlCompile` on *SC Catalog Item*).
4. **Run Widget diagnostics** (below) and fix by priority: **customized** base widgets first (not supported in upgrades; revert them), then **new** widgets (compare the latest change), then **cloned** ones (a clone taken before an upgrade misses the base fixes: clone again and reapply), base widgets last (remove and re-add with no options, or try another page).
5. **Slowness:** decide whether it is portal or platform-wide; whole portal slow points to scripted header menu items or large theme fonts and images, one page to a widget (browser console network timings). Warnings in **Log** (`syslog`) about large JSON objects mean a widget sends too much data. Guidelines: [[Service Portal Widget Development]].

## How to confirm the cause

**Widget context menu:** Ctrl + right-click a widget for configuration options and to print the scope and its data to the console. **Show Widget Customizations** colours each widget:

| Colour | Level |
|---|---|
| green | base (may have instance options) |
| yellow | cloned |
| blue | new |
| red | customized base (code, option schema, dependencies, ng-templates or providers changed) |

The **information icon** on a widget opens Widget diagnostics (`admin` or `sp_admin`): *Open widget in platform* (read-only; for customized widgets only when a dependency, provider or ng-template changed), *Compare with previous version* (customized widgets changed directly), *Compare with base widget* (cloned or customized; a clone of a clone is compared with the base), and links to the related **Widget Dependencies** (`sp_dependency`, first level only), **Angular Providers** (`sp_angular_provider`) and **Angular ng-templates** (`sp_ng_template`), with *Compare* for modified base providers and templates. Left side is previous or base, right side current. Limits: view only (fix in the platform), switching portal page turns it off, colour-only coding, deleted dependencies are not tracked.

**Debugging output:**

| Method | Where | Output |
|---|---|---|
| `console.log()` | server and client | browser console |
| `$sp.log()` | server | **Service Portal Log Entries** (`sp_log`) when the user has `sp_admin` or `admin` |
| `gs.log()`, `gs.warn()`, `gs.error()` | server | `syslog` (heavy `gs.log` use costs performance) |
| `gs.addInfoMessage()`, `gs.addErrorMessage()` | server | message at the top of the page |
| `spUtil.addInfoMessage()`, `addErrorMessage()`, `addTrivialMessage()` | client | message in the page (trivial ones fade) |
| `debugger` | client | breakpoint in the browser dev tools |
| `{{data \| json}}` | HTML template | the data object printed on the page |

**Variant to check:** the troubleshooting page sends `$sp.log()` to `sp_log`; the option schema page's example comments that it logs to the browser console. Both recorded until tested.

**Scope from the console:** inspect the widget, select the element with the `widget` attribute, then:

```javascript
// Browser console, on the portal page (client; debugging only)
var scopeRef = angular.element($0).scope();
scopeRef.data.example_field = 'Example value';
scopeRef.$apply();            // apply the change to the page
scopeRef.exampleFunction();   // run a controller function
scopeRef.server.refresh();    // rerun the server script
```

## Related

- [[Service Portal Widgets]] · [[Service Portal Widget Development]] · [[Service Portal Overview and Configuration]]
