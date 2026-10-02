---
type: how-to
tags: [how-to, data-management, encoded-query, api]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Exporting data", topics "Export directly from a URL", "Call URL export programmatically", "Break up a large export" (pp. 656-661), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Export data with a URL

**Goal:** export a filtered set of records by building a URL, from a browser, a script or an external program.
**Prerequisites:** no role beyond read access. Direct URL access uses basic authentication, and only fields the authenticated user can read are returned. You need the table and column **names**.
**Navigation:** `https://<instance>.service-now.com/<table>_list.do?<FORMAT>&...`

## Steps

1. Start with the instance and the table list: `https://<instance>.service-now.com/incident_list.do`
2. Add the processor: `?CSV`, `?XLS`, `?XLSX`, `?JSON` or `?XML`.
3. Filter with `sysparm_query=<column><operator><value>`: `&sysparm_query=priority=1`
4. Sort with `sysparm_orderby=<column>` (one column only). For several, put them in the query: `sysparm_query=ORDERBYassigned_to^ORDERBYpriority`
5. Choose the fields:
   - `sysparm_view=<view name>`: the fields of that view (`ess` is the Self Service view).
   - `sysparm_fields=sys_id,number`: exactly these fields.
   - `sysparm_default_export_fields=all`: every field, including sys_id.
6. Optionally control values and headers with `sysparm_display_value` and `sysparm_export_column_header_label` ([[Export Limits and Properties]]).

## Result / how to check it worked

The browser downloads the file. From a program, request the URL with basic authentication and write the response stream to a file (the guide shows this in C#).

## Example

```text
https://<instance>.service-now.com/incident_list.do?CSV&sysparm_query=priority=1&sysparm_orderby=assigned_to&sysparm_fields=number,short_description,assigned_to
```

All priority 1 incidents as CSV, sorted by assignee, three columns.

## Splitting a large export

When the row count exceeds the export limit (10,000 by default):

1. Export the first block sorted by sys_id: `...?XML&sysparm_orderby=sys_id&sysparm_record_count=10000`
2. Find the sys_id of the next record (row 10,001). The guide's trick: a database view on the table with the sys_id column, opened with **Try it** and sorted by sys_id.
3. Export the next block from that sys_id on: `...?XML&sysparm_query=sys_id%3E%3D<sys_id>&sysparm_orderby=sys_id&sysparm_record_count=10000`
4. Repeat until done. `%3E` is `>` and `%3D` is `=` (percent encoding).

## Tables / fields involved

- any table, addressed as `<table>_list.do` (or `<table>.do` for a form)

## Gotchas

- Without a view, CSV and Excel use the default list view; XML exports all fields.
- `sysparm_default_export_fields` has no effect on XML unless `sysparm_view` names a non-default view.
- The URL XML processor leaves out attachments and journal fields (Work notes, Additional comments). Use the list **Export > XML** for those.
- Never put real credentials in notes or scripts stored in the vault; use placeholders.

## Related

- [[Exporting Data]]
