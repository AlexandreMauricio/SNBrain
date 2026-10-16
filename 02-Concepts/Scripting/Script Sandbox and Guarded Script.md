---
type: concept
tags: [concept, scripting, security, release-specific]
status: documented
source: ServiceNow docs, Brazil, API implementation and reference > Scripting > Write server-side scripts > Sandbox environment, topics "Script sandbox environment", "Guarded script evaluator", "Reviewing scripts incompatible with guarded script", "JavaScript APIs supported by guarded script", "Script sandbox evaluator", plus "Script includes" and "Background scripts", https://www.servicenow.com/docs/r/api-reference/scripts/script-sandbox-environment.html, read 2026-10-16. Further reading named by the docs: KB2944435 "Server-Side Sandbox Runtime Replacement" (not read)
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Script sandbox and guarded script

**In one line:** scripts that arrive **from the client** (a `javascript:` filter in a URL, a reference qualifier or condition evaluated on request, the AJAXEvaluate API) run in a restricted **sandbox**; in Brazil the sandbox's first evaluator, **guarded script**, only accepts a single simple expression or function call, so logic must live in sandbox-enabled script includes.

## The sandbox

- Trusted server scripts (business rules, script includes...) run normally. Untrusted, client-generated scripts run in the sandbox.
- Inside it: only business rules marked **Client callable** and script includes marked **Sandbox enabled** can be called; no insert, update or delete (`current.update()` is ignored); some APIs are blocked.
- Since Xanadu, script includes marked **Glide AJAX enabled** (the old *Client callable*) are **not** reachable from the sandbox; only **Sandbox enabled** ones are. Upgrades to Brazil from Washington DC or earlier tick Sandbox enabled on every client-callable script include automatically.
- Script includes themselves and client-side scripts are never sandboxed.

## Two evaluators

| | Guarded script evaluator | Script sandbox evaluator |
|---|---|---|
| Accepts | one simple expression or function call, allowed APIs only | most JavaScript, minus restricted methods |
| Used for | untrusted scripts without an exemption | exempted scripts, and authenticated scripts while guarded script is in phase 1 |

### Guarded script syntax

Allowed: literals (number, string, boolean, null, undefined), operators such as `+ - < !== && instanceof typeof`, ternary, array literals, dot property access, `a[0]` with a constant, calls to **Sandbox enabled** script includes, and a safe list of APIs (read-only GlideSystem helpers such as `gs.beginningOfLast30Days()`, `gs.daysAgo()`, `gs.getUserID()`, `gs.hasRole()`, `gs.getMessage()`, `gs.nowDateTime()`, GlideUser getters such as `getMyGroups()` or `getManagerID()`, and others in the docs table). Not allowed: `var`, functions, `=`, `if`, loops, several statements.

```javascript
// Rejected (variable and if statement) in a reference qualifier or filter:
javascript:var ret='customer=true'; if (current.relationship_type.to == 'partner') ret = 'partner=true'; ret + '^sys_id!=' + current.from_company;

// Accepted: move the logic to a script include with Sandbox enabled ticked
javascript:new ExampleAccountUtils().getAccountFilter(current);
```

### Enforcement

| Traffic | Default |
|---|---|
| Guest (not logged in, e.g. public pages) | enforced on every instance: incompatible scripts rejected and logged |
| Authenticated, **new** instance | phase 3 at once |
| Authenticated, **upgraded cloud** instance | phases advance automatically every 14 days |
| Authenticated, **upgraded on-premise** instance | phase 1 until an admin advances it |

Phases: **1 Detection** (everything runs; incompatible *syntax* recorded; at the end syntax offenders get automatic exemptions), **2 Syntax enforcement** (bad syntax rejected; bad *API* use recorded; at the end API offenders get automatic exemptions), **3 Full enforcement** (both rejected; new exemptions only by hand).

Properties: `com.glide.script.sandbox.ks.watchdog.phase` (1, 2, 3; do not edit by hand), `...phase.duration.days` (default 14; -1 pauses), `...auto.advance` (true in cloud, false on-premise), `...enabled` (true; false sends everything to the sandbox evaluator; never in production). Move phases from Scripts - Background with `new GlideGuardedScript().resetToPhase1()`, `.advanceToPhase2()`, `.advanceToPhase3()` (they create the exemptions).

### Remediation

**System Diagnostics > Guarded Script > Incompatible Guarded Scripts** (roles guarded_script_admin or admin): one row per normalised script and authentication type, with occurrence count, page title, scope, stack trace and any exemption. Rejections also log `KittyScript validation failed for <script name> ...` in **System Log > Errors**. For each row either move the logic into a Sandbox enabled script include and call it in one expression (test with **Execute in sandbox?** in Scripts - Background), or **Add Exemption** (routes it to the sandbox evaluator; weaker security; exemptions are **not** captured in update sets: export and import them). Infrequent scripts (quarterly, yearly) are only detected when they run, so test them before phase 3.

## Sandbox evaluator restrictions

Blocked methods include GlideRecord / ScopedGlideRecord writes (`insert`, `update`, `deleteRecord`, `updateMultiple`, `deleteMultiple`; GlideRecord also `getRowCount`), GlideSystem messages, properties, events, redirects and logging (`addInfoMessage`, `getProperty`, `setProperty`, `eventQueue`, `log`, `setRedirect`...). The page also lists many GlideDateTime, GlideDate, GlideTime and GlideSchedule methods as restricted (surprising for read-only date methods; recorded as given). `glide.security.sandbox_no_logging` = false re-allows `gs.log`, `logError`, `logWarning`.

## Related

- [[Script Includes and GlideAjax]] · [[JavaScript Engine and JavaScript Modes]] · [[Hardening Settings - API, Architecture, Communications and Configuration]] · [[Background Scripts, Script Processors and Schedule Pages]]
