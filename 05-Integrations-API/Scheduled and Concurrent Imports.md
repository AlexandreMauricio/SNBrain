---
type: concept
tags: [concept, import-sets, automation, domain-separation]
status: documented
source: ServiceNow docs, Brazil, Workflow Data Fabric > Imports > Import sets, topics "Concurrent imports", "Schedule a data import", "Scheduled data import scripting options", "Monitor scheduled data import executions", "Monitor concurrent import sets", "Monitor concurrent import set jobs", "Import sets properties", https://www.servicenow.com/docs/r/integrate-applications/system-import-sets/t_ScheduleADataImport.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Scheduled and concurrent imports

**In one line:** a **Scheduled Data Import** (`scheduled_import_set`, name from general knowledge) runs a data source and its transform on a schedule, optionally after a parent import and optionally split into several import sets transformed in parallel ("concurrent").

## Scheduled Data Import form

**System Import Sets > Administration > Scheduled Imports > New**. Roles import_scheduler, import_admin or admin. **import_scheduler is effectively admin** (its scripts run with admin rights).

| Field | Meaning |
|---|---|
| **Data source** | remote sources refresh first; the transform map or robust transformer comes from the data source |
| **Run as** | user whose rights the job uses; empty = **guest** user (per the docs) |
| **Use connection** / **Connection** | connection alias (or a child alias); the chosen sys_id is in `gs.getSession().getClientData('connection_credential_alias_override')` for scripts |
| **Run**, **Day**, **Time**, **Repeat interval**, **Starting** | schedule; do not start several imports at the same time |
| **Parent** (Run = *After Parent Runs*) | chained (hierarchical) imports; `glide.scheduled_import.stop_on_error` stops children when the parent fails |
| **Conditional** / **Condition** | script that must return true |
| **Concurrent Import**, **Partition Method** (*Round Robin*, *Custom Script* with a **Partition Script** returning a key, *Custom size* with **Partition Size**) | see below |
| **Execute pre-import script** / **Prescript**, **Execute post-import script** / **Post script** | variables `cancel`, `import_set`, `data_source` ([[Transform Scripts and Script Variables]]); with concurrency the post script runs after the last transformer job |

**Execute Now** runs it at once. Stop a long one: **System Import Sets > Advanced > Progress**, open the progress worker, **Cancel job**. **Executions** shows execution contexts.

## Concurrent imports

- Load once into staging, then split into up to `glide.scheduled_import.max.concurrent.import_sets` import sets (default 10; e.g. 2 nodes = 4 sets, 10 nodes = 10 sets).
- Every node runs two **Import Set Transformer** jobs per minute that pick sets from the **Concurrent Import Set Jobs** queue.
- No guaranteed order. Rows with the same partition key (custom script) go to the same set and stay in order. Children of a concurrent parent start after its last transformer job.
- Insert duplicates are avoided by a write lock on the target when a set inserts (mutex properties `com.glide.concurrent_import_set_insert_mutex_spin_wait`, `..._expiration`, `com.glide.concurrent_import_set_mutex_fast_lock`).
- Use only for big loads, after tuning indexes and scripts: it adds processing and monitoring overhead.
- Domain separation: add `sys_domain` to the scheduled import table; loading and transform run in that domain.

Tables: `sys_concurrent_import_set` (Concurrent Import Set: related sets, jobs, transform histories; **Reprocess**, **Continue**), `sys_concurrent_import_set_job` (type Regular, Reprocessing, Resuming; state Pending, Running, Completed, Error), `sys_execution_context` and `sys_execution_plan` (hierarchy). Monitor via **System Import Sets > Concurrent Import Set Jobs** and **Administration > Execution Contexts** (role import_admin).

## Related

- [[Import Sets - Data Sources, Staging Tables and Cleanup]] · [[Import Set Performance and Errors]] · [[Scheduled Jobs]] · [[Connections, Credentials and Aliases]]
