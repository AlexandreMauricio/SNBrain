---
type: concept
tags: [concept, integrations, scripting, api, domain-separation]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage instance data sources > Remote tables (Remote tables, Activate the remote tables plugin, Create a remote table, Create script definitions, Examples 1-5, Create a flow definition, Define a flow logic, Debugging remote table script definitions, Domain separation and remote tables), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/remote-tables/remote-tables.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Remote Tables

**In one line:** a table defined on the instance whose rows are not stored but fetched on demand from another system (REST, SOAP, another instance) by a server-side script or a flow, held in memory (optionally cached), and usable in lists, forms, GlideRecord and GlideAggregate like a normal table; optionally editable back to the source.

From the Brazil docs; not tested. Step by step: [[Create a Remote Table]]. The table record side is in [[sys_db_object]] (**Remote table** flag).

## Pieces

| Piece | Where | Notes |
|---|---|---|
| Plugin **Remote Tables** (`com.glide.script.vtable`) | admin activates | also activates **Transformation Service** (`com.glide.transform`); includes demo data. External (non-ServiceNow) sources need an **Integration Hub** subscription |
| **Remote table** | **System Definition > Remote Tables > Tables** (or the normal Tables form with **Remote Table** ticked); role `delegated_developer` or `admin` | name prefix `u_st_` in global, `<scope>_st_` in an app; **cannot extend** or be extended; columns, controls and application access as usual; `sys_id` acts as the external key (string, max 32 characters) |
| **Definition** (script or flow) | **System Definition > Remote Tables > Definition** | one **active** definition per table (inactive ones allowed); role `delegated_developer` with scripting allowed, or `admin` |

## Definition options (Advanced)

- **Cache TTL** in seconds (0 = no cache, max 3600).
- **Cache Isolation Level**: **Cache per user** (default) or **System Shared Cache**.
- **Enhanced Capacity**: more than the default **1,000 rows** (slower; not with Editable).
- **Editable**: adds Insert, Update and Delete scripts (`v_record`). Concurrent updates: last call wins.
- Or **Flow**: pick a flow instead of a script (Script section hides). Flow logic: trigger linked to the remote table, action **Create Remote Table Record** with the **Query ID** pill (mandatory), optional conditions on the **Query Parameter** pill (e.g. Utilities > Get Item from Name/Values with the column name as key), optional Log.

## Script APIs (server-side, scoped or global)

- Query: `(function executeQuery(v_table, v_query) {...})` runs every time a list or form needs the data. `v_table.addRow({...})` (keys = column names; `sys_id` required and unique, enforced on editable tables). `v_query.getEncodedQuery()`, `getCondition(field)`, `getParameter(field)` (equality only), `isGet()` / `getSysId()` (for `GlideRecord.get`), `isTextSearch()` / `getTextSearch()`, `getFirstRowWanted()` / `getLastRowWanted()` (not with caching), `setLastErrorMessage(msg)` (shown under the list, read via `GlideRecord.getLastErrorMessage()`).
- Insert / Delete: `(function executeInsert(v_record) {...})`, `executeDelete(v_record)`; Update: `executeUpdate(v_record, v_changed_fields)`. `v_record.<field>`, `v_record.setLastErrorMessage()`.
- Typical body: `sn_ws.RESTMessageV2` call, then `sn_tfrm.TransformerRuleList().fromJSON().addRule('<column>', '$.json.path')`, `sn_tfrm.TransformerDefinition(ruleList, '$.result')`, `new sn_tfrm.Transformer(def, body)`, loop `transform()` / `getRow()` → `addRow`. Map `sys_id` to an element of the external data so forms work.

## Behaviour to know

- Rows live in memory while the list or form is open (or for the cache TTL), then are fetched again.
- After the script adds rows, the platform **post-filters and sorts** them with the user's query. Push frequent, selective conditions into the external call (`getParameter`, `isGet`) and leave post-filtering for small result sets.
- Remote tables versus Integration Hub: remote tables for temporary, cached viewing of external data; Integration Hub / Workflow Studio for real imports, transformations and custom integrations.
- Uses: weather by user location, CRM customer data in CSM, HCM (Workday, SuccessFactors) data in HR.
- Debug: property `glide.script.vtable.log.debug = true` shows `[RemoteTable]` lines (query, rows loaded, aggregate rows) and `gs.debug()` output in the session debugger; set it back to false afterwards. Logs may be on another application node.
- Domain separation: **No support** for the table itself (no `sys_domain` logic); a definition script can use DomainSupport APIs to filter rows per domain.

## Related

- [[Create a Remote Table]] · [[sys_db_object]] · [[Integration Options and Interfaces Overview]] · [[Domain Separation Support Levels by Application]]
