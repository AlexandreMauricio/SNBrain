---
type: troubleshooting
tags: [troubleshooting, service-catalog, client-script, ui-policy, access-control]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog > Debugging Service Catalog, topics "Debugging Service Catalog", "Debug actions on catalog item variables", "Debug user criteria of a catalog item", "Debug UI customizations for a Service Catalog page", "Debug performance diagnostics of a catalog item", "Debug a Service Catalog variable", "Item diagnostic report", "Run the Item Diagnostic Results report", https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/debugging-service-catalog.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Debugging Service Catalog items

**Symptom:** a catalog item misbehaves: a user cannot see it, a variable is hidden, mandatory or filled unexpectedly, the page is slow, or a customised catalog page broke after an upgrade.
**Cause:** usually user criteria, an interaction of catalog client scripts, UI policies and data lookups, heavy lookup variables, or customised UI macros.
**Fix:** use the matching built-in tool below, then fix the record it points at.

## Which tool

| Problem | Tool | How |
|---|---|---|
| "I can't see the item" | **User Criteria Diagnostics** (catalog_manager, catalog_admin, admin) | **Catalog Administration > User Criteria Diagnostics**: user + item > **Diagnose**. Tree of catalogs, categories and the item with **User Match** per criterion (Available for / Not available for). Access needs at least one Available For match and no Not Available For match. ACLs are not checked. Scripted criteria using `gs.getUserID()` evaluate as you, not as the chosen user: rewrite them with `user_id` |
| variables change unexpectedly | **Variable Action Logger** (admin, catalog_admin, or the catalog's manager / editor) | **Catalog Administration > Enable Variable Action Logger** (property `glide.sc.log.variable_actions`), **Try It** on the item, right-click the header > **Show Variable Action Logger**. Chronological actions grouped by UI policy, client script and data lookup, numbered 1.2.1 for chained actions; search, filter, export CSV. Client-side only, nothing stored |
| one variable misbehaves | **Variable Watcher** (admin, catalog_admin) | settings > **Developer** > enable **JavaScript Log and Field Watcher**; on the Try It page right-click a variable label > **Watch Variable**. Shows type, roles, reference qualifier, attributes and its action log; one variable at a time |
| item slow to load | **Variable SQL Debugger** (admin, catalog_admin) | **Catalog Variables > Enable Variable SQL Debugger**, Try It, more options > **Show Variable SQL Debugger**: per variable processing time, SQL count, SQL time and the statements. Not for containers. Stays on even after Session Debug > Disable All; turn off with **Disable Variable SQL Debugger** |
| catalog page broken after upgrade | **Debug UI Customization** (admin, catalog_admin) | **Catalog Administration > Debug UI Customization**, open the catalog page: panel lists the page's UI macros with state **Unchanged** (green), **Skipped** (red, customised and skipped by the upgrade: resolve it), **Customized** (orange, changed after the upgrade: can revert), **New** (blue, yours; its top element needs `data-sn-macro-sys-id="${jvar_macro_sys_id}"`). Hover highlights the macro on the page |
| general health of an item | **Item Diagnostic** related link, or report **[Catalog] Item Diagnostics Results** (**Catalog Administration > Request Reports**; job runs every weekend) | score 0 = clean; weighted rules below |

## Item diagnostic rules

| Rule | Flags |
|---|---|
| `checkUserCriteriaUsage` | entitlements instead of user criteria |
| `checkBalancedContainers` | container start without matching end |
| `checkDuplicateVariables` | two variables with the same name on the item or its sets (high weight) |
| `checkDOMManipulation` | DOM access in catalog client scripts (breaks on upgrade) |
| `checkLookupVariableRowCount` | lookup variables on large tables |
| `checkAJAX` | any AJAX in catalog client scripts (low weight; must be asynchronous) |
| `checkSelectBoxUnique` | select boxes with unique-values only |
| `checkOrderGuideRuleBaseCount` | order guides with many active rules |
| `checkFormatterVariablesUsage` | Macro, Macro with label, UI Page variables (limit channels) |

## Quick checks before the tools

- Variable has a **Name**? Unnamed variables are invisible to scripts, policies and audit.
- Same name on a table field and a variable on RITM or task forms? Use `variables.<name>` in `g_form`.
- Mandatory wins over hidden and read-only: a mandatory empty variable cannot be hidden ([[Catalog Client Scripts, UI Policies and Variable Editors]]).
- Category hidden although the item is visible? Categories need an active item below them and their own criteria ([[User Criteria and Catalog Access]]).
- After changing roles or scripted criteria, log out and in (session cache).
- Catalog data lookups: see [[Data Lookup Rule Not Working]].

## Related

- [[Catalog Variables and Variable Types]] · [[Skipped Records in Upgrades]]
