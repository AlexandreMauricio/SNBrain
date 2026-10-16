---
type: concept
tags: [concept, import-sets, integrations, reference-field]
status: documented
source: ServiceNow docs, Brazil, Workflow Data Fabric > Imports > Import sets, topics "Transform maps", "Create a transform map", "Mapping options", "Create a field map", "Field map script variables", "Updating records using coalesce", "Run an import", https://www.servicenow.com/docs/r/integrate-applications/system-import-sets/c_CreatingNewTransformMaps.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Transform maps, field maps and coalesce

**In one line:** a transform map (`sys_transform_map`) copies each staging row into one **target table** through **field maps**; **coalesce** fields decide whether a row updates an existing record or inserts a new one.

## Transform map form

**System Import Sets > Create Transform Map** (or **Transform Maps**). Roles import_transformer, import_admin or admin.

| Field | Meaning |
|---|---|
| **Name**, **Active**, **Application**, **Order** | lower order runs first when several maps apply |
| **Source table** | a table extending `sys_import_set_row` in the current scope |
| **Target table** | in scope, global, or a table granting write access to other scopes |
| **Run business rules** | on: business rules, workflows, approval engines, auditing and field normalization run on the target; off = `setWorkflow(false)` (faster, no notifications) |
| **Enforce mandatory fields** | No / Only Mapped Fields / All Fields |
| **Copy empty fields** | empty source values overwrite target values |
| **Create new record on empty coalesce fields** | insert instead of ignoring when all coalesce fields are empty |
| **Use Secondary Storage for References** | look up references on a secondary database (plugin `com.glide.secondary_db_pools` + category `import_reference_resoultion` [sic]); set **Choice action** to ignore or reject; data slightly stale |
| **Run script** + **Script** | explicit transform script, runs with the field maps |

Several maps can run on one import set, in the order chosen; each creates its own set of staging row entries.

## Field maps

Related list **Field Maps** (or **Mapping Assist** for drag and drop; **Auto map matching fields** when names already match; one source field can feed several targets).

| Field | Meaning |
|---|---|
| **Source field** or **Use source script** | script sets `answer` (variables `source`, `target`, `map`, `log`, `action` (only when not coalescing)) |
| **Target field** | |
| **Choice action** (reference or choice targets) | **create** missing choice or record, **ignore** the value, **reject** the whole row |
| **Referenced value field name** | which column of the referenced table matches the incoming value (default: display value, e.g. `name` for users; set `user_name` for user IDs). No match = a new referenced record ("foreign record insert") unless the choice action says otherwise |
| **Date format** | source format such as `MM-dd-yyyy`; use `HH:mm:ss` for 24-hour time (12-hour formats turn 12:00-23:59 into 00:00-11:59) |
| **Coalesce**, **Coalesce empty fields**, **Coalesce case sensitive** | see below |

Mapping a reference field checks that each sys_id exists (slow with many references); an onBefore `target.field = source.u_field;` skips the check when validation is not needed. Auto-mapping can map things you do not want (encrypted passwords).

Durations are stored in milliseconds: in the map script `target.duration = gs.dateDiff(source.u_start.getDisplayValue(), source.u_end.getDisplayValue(), false);` or `target.duration.setDateNumericValue(source.u_seconds * 1000);`.

Binary or BLOB columns from JDBC arrive as `sys_attachment` records (the staging column holds the attachment sys_id); an **onAfter** script re-points the attachment (`table_name`, `table_sys_id = target.sys_id`, `content_type`).

## Coalesce

| Setup | Effect |
|---|---|
| none | every row inserts |
| one field | update the record whose field equals the source value |
| several fields | update only when **all** match; one matching and one not = insert |
| conditional | a source script on the target's **sys_id** field map returns the sys_id to update (or -1) |
| updates only | coalesce plus onBefore `if (action == 'insert') ignore = true;` |

- Coalesce on unique values only: with several matches only the first record is updated.
- Default lookup is **case-insensitive**; **Coalesce case sensitive** makes a different case insert a new record.
- Empty values never match unless **Coalesce empty fields**.
- Index the coalesce fields: related link **Index Coalesce Fields** creates one **composite** index over all of them (set Coalesce on every field first). Unindexed coalesce on big tables slows transforms and loads the database.
- Rows with coalesce values are processed serially to avoid duplicates; concurrent imports take a write lock on insert.

```javascript
// Field map source script on the sys_id target field (server-side, global): match by email OR user name
var gr = new GlideRecord('sys_user');
var qc = gr.addQuery('email', source.u_email);
qc.addOrCondition('user_name', source.u_name);
gr.query();
answer = gr.next() ? gr.getUniqueValue() : -1;
```

## Running

**Transform** on the map (or **Run Import** / Load Data wizard). The first load creates the staging table and a module under System Import Sets. Then check **Import Set Runs** (inserts, updates, ignored, skipped, errors) and rows.

## Related

- [[Transform Scripts and Script Variables]] · [[Import Sets - Data Sources, Staging Tables and Cleanup]] · [[Import Data with an Import Set]] · [[Robust Import Set Transformers and ETL Definitions]]
