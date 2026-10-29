---
type: how-to
tags: [how-to, integrations, cmdb, import-sets]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > IntegrationHub ETL > Create an ETL transform map (Import source data, Preview and prepare data, Map data columns, Add relationships, Preview mapping results, Provide integration schedule), Duplicate an ETL transform map (read 2026-10-29). https://www.servicenow.com/docs/r/servicenow-platform/integration-hub-etl/create-etl-transform-map.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Create an ETL Transform Map in IntegrationHub ETL

**Goal:** load a third-party feed into CMDB classes through IRE with a guided ETL transform map.
**Prerequisites:** role `cmdb_inst_admin`; IntegrationHub ETL installed; an import set **data source** in your current application scope with at least one loaded import set; a discovery source for the CMDB application. Build on a sub-production instance first.
**Navigation:** **All > Configuration > IntegrationHub ETL** > **Create new** (or open an existing map; **Duplicate** to copy one).

Concepts: [[IntegrationHub ETL]].

## Steps

1. **Import Source Data and Provide Basic Details**: **CMDB Application** (or **Add new** with **Discovery Source**), **Name**, **Description**, **Data Source**, **Sample Import Set** (or **Auto-pull a new import set**), optional **Preview Size Override** and **Load Complete Schema** > **Mark as Complete**.
2. **Preview and Prepare Data**: review sample rows; per column use **New Transform** (pick a type, input column, output column name, **Apply**; transforms can chain), **Set Fixed Value Column**, **Table Lookup** (lookup table, matching column pairs, output columns), **Ignore in Mapping**, **Delete This and Downstream Columns**. For nested data, open **Show data structure** and drill into a level before transforming it > **Mark as Complete**.
3. **Select CMDB Classes to Map Source Data**: **Add Class** or **Add Conditional Class** (If / Else if / Else on values or plugins); for non-CMDB targets **Add Associated Class**. **Set Up Mapping**: drag columns onto attributes (all required attributes, plus Source Native Key and Source Recency Timestamp); **Add Attribute** for more, including IRE settings; map and filter lookup rules (e.g. *Serial Number Lookup 1*). Use the **Activate/Deactivate Mapping** toggles as needed > **Mark as Complete**.
4. **Add Relationships**: **Add Relationship** (Parent, Child, Relationship Type) or **Add Conditional Relationship**. Dependent relationships fill the type automatically; otherwise suggested relationships come first (CSDM-compliant ones from ITOM Visibility) > **Mark as Complete**.
5. **Test and Rollback Integration Results**: **Run Integration**; check class tabs, **Relationships**, **Error/Activity/Warning Log** (IRE grouped by category and class, RTE under *Other*; **Verbose** toggle), **Incomplete Payloads**, **Partial Payloads**. **Edit Mapping** / **Edit Relationships** roll the test back. **Mark as Complete** > **Retain Data** or **Perform Rollback**.
6. **Set Import Schedule** > **Set Schedules** > new **Scheduled Data Import** ([[Scheduled and Concurrent Imports]]) > **Mark as Complete**.

**Duplicate instead of building**: **Duplicate** > **Duplicate from**, CMDB application, **Name**, **Data Source** (must already exist, have the identical schema — same columns and labels — and not be used by another map) > **Create Duplicate**; step 1 is then complete.

## Result / how to check it worked

Test run shows CIs created in the expected classes with no partial or incomplete payloads; after the schedule runs, the CMDB Integrations Dashboard ([[Integration Commons for CMDB]]) shows the runs, and **Source** (`sys_object_source`) has rows for the discovery source.

## Example

CMDB application *Example Asset Tool* (discovery source *ExampleAssetTool*), data source *Example Asset Tool - Computers* (REST, JSON). Transforms: Uppercase Trim on `hostname`, Cleanse Serial Number on `serial`, Cleanse Hardware Model on `vendor` + `model` then Split. Conditional class: `os` contains *Windows* → Windows Server, contains *Linux* → Linux Server, else Computer. Map `id` → Source Native Key, `last_seen` → Source Recency Timestamp. Test with 100 rows, roll back, fix, test again, retain, then schedule daily.

## Tables / fields involved

- `sys_data_source`, the import set table, `scheduled_import_set`, `sys_object_source`, `cmdb_related_entry`, target classes under [[cmdb_ci]]; RTE entity and operation tables (`sys_rte_eb_*`).

## Gotchas

- Changing the data source of an existing map can remove columns and their transforms; validation asks before applying.
- Changing a target class can delete mappings (an *Affected mappings* dialog lists them, only for CMDB→CMDB or non-CMDB→non-CMDB changes).
- A non-CMDB class stays deactivated until an active associated class is added.
- Ignore in Mapping lasts only for the session.
- Sample preview is capped at 10,000 rows whatever the property says.
