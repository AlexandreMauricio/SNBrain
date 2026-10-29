---
type: concept
tags: [concept, scripting, admin]
status: documented
source: ServiceNow docs, Brazil, API implementation and reference > Scripting > Write server-side scripts, topics "Background scripts", "Script processors", "Schedule pages", plus Classic Business rules > "Installation settings", https://www.servicenow.com/docs/r/api-reference/scripts/c_ScriptsBackground.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Background scripts, script processors and schedule pages

**In one line:** three older server-side script entry points: **Scripts - Background** to run ad hoc code as admin, **processors** (deprecated custom URL endpoints) and **schedule pages** (custom calendar or timeline pages).

## Scripts - Background

**System Definition > Scripts - Background** (admin; elevated roles may be needed for some calls). Options:

| Option | Effect |
|---|---|
| scope selector | run in a chosen application scope |
| **Record for rollback?** (on by default) | creates a rollback context; the **Script execution and recovery available here** link opens **Script Execution History** to roll back |
| **Execute in sandbox?** | sandbox rules: no insert, update or delete; useful to test guarded-script rewrites ([[Script Sandbox and Guarded Script]]) |
| **Execute as scriptlet?** | gives access to global scope and all server-side objects; without it the script runs in global scope without them (as worded by the docs) |
| **Cancel after 4 hours** (on by default) | stops long runs |

Results and errors show at the top of the page. **Do not run free-form scripts on production** (data loss); kill a runaway with **View and kill active transaction**. Breakpoints cannot be set in the background script itself, only in the script includes, business rules or script actions it triggers ([[Debugging Scripts]]). See also [[Rollback and Delete Recovery]].

## Script processors (deprecated)

- Custom processors (**System Definition > Processors**) are deprecated: build **Scripted REST APIs** instead. Existing ones keep working.
- Fields: **Name**, **Type** (*script*; never *java*), **Active**, **CSRF protect**, **Parameters**, **Path** (`https://<instance>.service-now.com/<path>.do`), **Script** (IIFE with `g_request`, `g_response`, `g_processor`, `g_target`), **Protection policy**.
- Use processor-specific parameter names; a generic name like `id`, `sys_id` or `table` hijacks other pages (a processor with an `id` parameter breaks Service Portal).
- Secure them with `canRead()` / `canWrite()` checks against the table and **CSRF protect**.

## Schedule pages

**System Scheduler > Schedules > Schedule Pages**: **Name**, **Schedule type** (opened with `sysparm_page_schedule_type` or `sysparm_page_sys_id`, e.g. `/show_schedule_page.do?sysparm_type=gantt_chart&sysparm_timeline_task_id=<sys_id>`), **View Type** *Calendars* or *Timelines*, **Init function name**, **HTML** (Jelly) and **Server AJAX processor** (calendars), **Client script**. Timelines use a script include extending `AbstractTimelineSchedulePage` whose `getItems` returns TimelineItem objects. Used by Project Management, Maintenance Schedules, Group On-Call Rotation, Field Service.

## Installation settings (legacy access functions)

Global business rules with special names compute access just before display: `<table>CanRead()`, `CanWrite()`, `CanCreate()`, `CanDelete()` for records and `<table>_<field>CanWrite()` for fields; return true / false, or nothing to fall back to role-based permissions; `current` is available. Example from the docs: `sys_dictionary_nameCanWrite()` returns false unless `current.isNewRecord()`. ACLs are the normal mechanism today ([[Access Control Lists (ACLs)]]).

## Related

- [[Scripting Overview - Script Types and Where They Run]] · [[Business Rules]]
