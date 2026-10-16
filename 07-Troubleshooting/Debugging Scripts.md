---
type: troubleshooting
tags: [troubleshooting, scripting, business-rule, client-script, javascript]
status: documented
source: ServiceNow docs, Brazil, API implementation and reference > Scripting > Debug scripts, topics "Debugging scripts", "Script Debugger and Session Log", "Access the Script Debugger", "Script Debugger user interface", "Script Tracer and debugging scripts", "Script Debugger status", "Transaction details", "Script Debugger step-through and console controls", "Evaluate expressions in runtime using Console", "Set or remove breakpoints", "Set or remove logpoints", "Script Debugger multiple developer support", "Script Debugger impersonation support", "Script Debugger Scripts - Background support", "Domain separation and Script Debugger", "Debugging sessions", "Debugging applications", "Debugging business rules", "Debugging classifications", "JS Code Coverage Debug utility", "JavaScript debug window", "Watching fields", "Writing to the debug log", https://www.servicenow.com/docs/r/api-reference/scripts/script-debug-overview.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Debugging scripts

**Symptom:** a business rule, script include, UI action or client script does not do what you expect, sets the wrong value, or a field changes and you do not know why.
**Cause:** anything from a condition that is never true to another rule or engine overwriting the value.
**Fix:** pick the tool by where the code runs, narrow it down, then step through it.

## Which tool

| Need | Tool | Where | Role |
|---|---|---|---|
| step through server code | **Script Debugger** | **System Diagnostics > Script Debugger**, Studio **File > Launch Script Debugger**, or the debugger icon in the syntax editor | script_debugger or admin |
| server logs of my session | **Session Log** tab | in the Script Debugger | log_debugger |
| which lines ran | **JS Code Coverage Debug** | plugin `com.glide.js.coverage`; **JS Code Coverage Debug > Enable Coverage**, reproduce, **Disable Coverage**, **Coverage Data** | js_coverage_debugger or admin |
| which scripts changed a record | **Script Tracer** | search "Script Tracer" in the navigator | admin |
| messages on the page | **Session Debug** | **System Diagnostics > Session Debug** (Debug Business Rule (Details), Debug Security, Debug Scopes, Debug Log, Debug UI Policies, Enable All...) | none for logs |
| browser code | **JavaScript Log**, **Field Watcher**, browser dev tools | gear icon > **Developer** > *JavaScript Log and Field Watcher* (Core UI; not in Next Experience) | admin (field watcher also impersonator) |

## Script Debugger

- Pauses **interactive** server transactions only (business rules, script includes, script actions, UI actions where `gs.isInteractive()` is true), not scheduled jobs. Code runs interpreted while it is on; scripts in **strict mode** cannot be debugged.
- **Breakpoints** (click the gutter in the syntax editor; right-click for conditional ones) and **logpoints** (right-click > Add logpoint; needs `glide.debug.log_point` = true; GSLog format; output in Session Log). One or the other per line. Breakpoints belong to the person who set them.
- Controls: Start F2, Stop Shift+F2, Resume F9, Step over Option+F9, Step into Option+F10 (acts as step over without read access), Step out Option+F11. Panels: breakpoints, call stack, transaction details (URL, parameters, session, node, query count), local and closure variables, **Console** (evaluate expressions while paused; no `this`, no `gs.info()` output, objects show as strings; up and down arrows recall statements, `glide.debugger.console.cached_stmt_limit` default 20, max 100).
- Statuses: WAITING_FOR_FIRST_BREAKPOINT, EXECUTION_PAUSED, WAITING_FOR_BREAKPOINT, OFF. Finished debug transactions log with the prefix `DEBUGGED`.
- Several developers debug independently; admins can impersonate a user who has script_debugger and read access to the script. Scripts - Background code cannot hold breakpoints, but the objects it triggers can. Domain separation support: Basic.
- Concurrency: default number of semaphores / 4 debug transactions (`glide.debugger.config.max_node_concurrency`, max semaphores - 2). Admins see sessions at `xmlstats.do` and stop all at `debugger_reset.do`.
- Session Log: 100 transactions and 10,000 messages by default (`glide.debugger.log.transaction.count`, `glide.debugger.log_messages_limit` user preferences); `glide.debugger.log.ui` = *Page* (logs also under forms and lists) or *Session* (only in the tab).

## Script Tracer

**Start Tracer**, run the UI transaction, read tabs **State** (old and new values; errors with line numbers), **Script** (changed lines), **Transaction**; **Debug Script** opens the debugger, **View File** the record. Filters by file type and table. Up to 1,000 lines per trace (`glide.debug.trace.trace_line_limit`); **Clear trace** before the next.

## Field watcher and client log

- Right-click a field label > **Watch - <field>** (form fields only, one at a time, not on password or encrypted fields, only inside the UI frame). Logs default values, ACL and dictionary access changes, data policies, reference qualifier queries, UI policy state changes, dependent choices, and value changes by assignment rules, engines, business rules, client scripts, UI actions and users. Orange = server, blue = client. Hidden field: as security_admin run `gs.getSession().setWatchField('<column>')` in Scripts - Background.
- `jslog('text')` in client scripts writes to the JavaScript Log, which also times each client script. `glide.ui.ui_policy_debug` logs UI policy evaluation (`GlideFieldPolicy: ...`).

## Classic approach for business rules (from the docs)

1. Find the right table in the dictionary (fields may live on a parent such as [[task]]).
2. Print values: `gs.addInfoMessage('rec.next: ' + gr.next())` shows whether a query found anything (note this consumes the first row).
3. Turn on **Debug Business Rule (Details)** to see which conditions passed and what each rule set.
4. Break the script into pieces and test each in Scripts - Background.

Other switches: **Debug Scopes** shows `> Entering scope [x_app]` / `<` lines when scripts change application scope (not for global); `glide.discovery.debug.ci_identification` = true logs Discovery classifier evaluation.

## Related

- [[Business Rules]] · [[Client Scripts]] · [[Debugging Service Catalog Items]] · [[Order of Execution for Rules, Engines and Notifications]] · [[Impersonation]]
