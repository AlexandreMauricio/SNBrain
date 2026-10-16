---
type: concept
tags: [concept, data-management, integrations, automation]
status: documented
source: ServiceNow docs, Brazil, Workflow Data Fabric > Exports, topics "Exports", "Export sets", "Create an export set", "Create an export set from a list", "Create an export definition", "Create an export target", "Export set supported file types", "Schedule an export", "Export set history", "Cancel an export set", "Export Set properties", "Parallel exports", https://www.servicenow.com/docs/r/integrate-applications/system-export-sets/c_ExportSets.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Export sets

**In one line:** an export set pushes the records chosen by an **export definition** to a file on a **MID Server** (the **export target**), once or on a schedule, optionally only the changes since the last run.

## Parts

| Record | Module (**System Export Sets**) | Holds |
|---|---|---|
| **Export definition** | Export Definition | table, fields, optional filter |
| **Export target** | Export Targets | MID Server (Validated = Yes, Status = Up; not in a MID cluster) and a path relative to the MID directory (the MID service account must be able to write there) |
| **Export set** (`sys_export_set`) | Create Export Set, or list header > **Export > Export Set** | name, **File name**, **Format** (CSV, XML, Excel, JSON), **Append timestamp**, definition, target. Definition and target can be created on the fly from a table or MID path |
| **Scheduled export** | Administration > Scheduled Exports | when to run it |
| **Export history** | per run | state, times, delta flag, ECC queue record (admin), attached file, log |

Roles: `export_set_admin`, `export_set_scheduler` (schedules). Attachments are never exported: use the REST Attachment API or an outbound REST message.

## Scheduled exports

Fields: **Export set**, **Run as** (needs read access to the data), **Run**, **Day**, **Time**, **Repeat interval**, **Conditional** / **Condition**, **Execute pre-export script** / **Pre script**, **Execute post-export script** / **Post script**, **Parallel export**, **Execute Now**.

- **Delta exports**: **Enable delta exports** + **Delta on or after** *Updated* (new and changed) or *Created* (new only); **Last export scheduled run** is maintained automatically (blank = everything). Not possible for database views (no system date fields) and not when the definition already filters on `sys_created_on` / `sys_updated_on` (the record will not save).
- Scripts: `cancel = true` (pre-script; also cancels child export sets), `export_set` (`name`, `sys_id`, `state`, `table_name`).
- `glide.scheduled_export.stop_on_parent_error`: skip children when the parent fails.

## Parallel exports

For 50,000 rows or more (`glide.scheduled_export.min_rows_for_parallel_export`; below it a normal export runs): chunks = nodes x scale factor (default 1, minimum 2; e.g. 2 nodes = 4 sets). Each node runs two **Export Set Processor** jobs per minute. Records: Parallel Export Set (`PESO...`), one Parallel Export Set Job per chunk (`PESJ...`), one history and file per chunk, saved under `{MID}/agent/export/parallel/{path}/` as `PESO0100001_incident__20251204001638_1.xlsx` style names. The page also says the number of sets goes "up to" the min-rows property (default 10), which looks like a copy error from concurrent imports.

## History states

Exporting, MID Server Processing, Completed, Completed with errors, Cancel requested, Cancelled. A running export set can be cancelled from its history.

## Formatting properties (export sets)

`glide.excel.local_based_currency` (currency in the instance locale), `glide.export.excel.duration.readable_string` (durations as days, hours, minutes instead of seconds), `glide.export.xlsx.zip64_mode`. Other export limits and display-value properties: [[Export Limits and Properties]].

## Related

- [[Exporting Data]] · [[Export Data with a URL]] · [[Create a Scheduled Export Set]]
