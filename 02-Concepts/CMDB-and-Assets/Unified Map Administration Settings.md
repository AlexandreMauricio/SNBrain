---
type: reference
tags: [reference, cmdb, workspace, admin]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > Unified Map > Administer (12 topics, read in full through the docs site API 2026-10-29) - Configuring Unified Map admin settings, shared presets, node count, levels, endpoint de-dupe, life cycle filter, related items, Attributes panel, references, class profiles, browsers, how settings are stored. https://www.servicenow.com/docs/r/servicenow-platform/unified-map/administer-unified-map.html
sn-release: Brazil
verified:
updated: 2026-10-29
---

# Unified Map Administration Settings

**In one line:** the instance-wide settings for [[Unified Map]] live in a *configuration identifier* of the CMDB Workspace UX application; each setting is a row in a workspace table, edited by `sn_cmdb_admin` with the application scope set to **CMDB Workspace**.

From the Brazil docs.

## Configuration identifiers

- **Configuration identifier** (`sn_cmdb_ws_config_identifier`): a named set of properties and table rows for one UX application instance. The base system ships one called **Default**. Its form shows every setting in related lists.
- For your own settings, change the defaults and save under a new name; anything the custom identifier does not set falls back to Default.
- Settings for one UX application (for example the CMDB Unified Map page) do not affect other copies of the Unified Map template.
- Background: [[CMDB Workspace Reference - Properties, Roles, Jobs and Tables]].

## Properties (`sn_cmdb_ws_config_property`)

Rows have **Config identifier**, **Name**, **Value**, **UX application**.

| Name | Default | Meaning |
|---|---|---|
| `unifiedmap.map_search.max_nodes` | 250 (from the user pages) | nodes loaded when a map opens; higher is slower |
| `unifiedmap.map_search_filter.default_levels` | 3 | starting levels |
| `unifiedmap.map_search_filter.max_levels` | 25 (per the CMDB Workspace reference) | maximum levels |
| `unifiedmap.map_search_filter.endpoint_deduplication_fields` | `sourceId,targetId,_label,endpoints` | collapse duplicate edges between the same CIs into one; normally left alone |
| `unifiedmap.map_search_filter.map_edge_animations` | `{"safari": false, "chrome": true, "edge": true, "firefox": true, "others": true}` | map animations per browser; Safari is off because nodes with many connections perform badly. Off disables **all** map animations in that browser |
| `unifiedmap.service_map.exclude_classes` | eight service-instance classes | see [[Unified Map]] |

Naming discrepancy: the CMDB Workspace chapter lists the levels settings as `sn_cmdb_ws.unifiedmap.map_search_filter.default_levels` / `max_levels` (system properties); this chapter has them as rows without the prefix in the workspace config table. Possibly the same setting shown two ways (?). Also, the docs' levels page repeats the max-nodes field description by copy error.

## Table-driven settings

| Setting | Table | Fields |
|---|---|---|
| Which life cycle stages appear | Operational life cycle modes (`sn_cmdb_ws_operational_lifecycle_for_unified_map`) | record **CMDB Workspace Unified Map View**; unlock **Life cycle** list and pick stages. Default: Operational or empty only |
| Related item categories (panel, timeline, badges) | Node Map Related Item (`sn_cmdb_ws_node_map_related_item`) | **Name**, **Table**, **Order**, **Active**, **Reference field** (usually Configuration Item); *Related fields and conditions*: **Number field**, **Title field**, **Fields**, **Sort fields**, **Footer field**, **Conditions**; *Badge and timeline*: **icon**, **highlight field**, **Date field**, **End date field** |
| Extended attributes in the Attributes panel | Table Attributes (`sn_cmdb_ws_node_map_table_attributes`) | **Config identifier**, **CMDB Class Name**, **Display attributes**, **UX application**, **Active**, **Follow hierarchy** (also collect parent classes' attributes up to the first parent with it cleared; cleared = only this class's list) |
| Reference connections (dashed lines) | Node Map References (`sn_cmdb_ws_node_map_reference`) | **CI class** (referencing), **Referenced CI class**, **Reference field**, **Show Reverse**, **Active**. Example: a server showing its file systems |
| Class profiles (layers shown per home-node class) | Node Map Profiles (`sn_cmdb_ws_node_map_profiles`) | **Config identifier**, **Layers** (Application, Service instance, Business, Infrastructure), **CMDB CI class**, **Orientation** (vertical or force), **UX application**, **Active**. Applied only when no preset is in use. Preconfigured for e.g. `cmdb_ci_service_discovered` |

## Shared presets

Role `sn_cmdb_config_admin`. On a map: set filters > **Manage presets** > **Create shared preset** > name > **Save**. Stored in the *Unified map shared presets* related list of the configuration identifier, and per workspace only. A shared preset can be included in a node map profile; its layer settings then override the class profile. Update or delete through the same menu (*Update shared preset*, *Delete shared preset*).

## Related

- [[Unified Map]] · [[CMDB Workspace Reference - Properties, Roles, Jobs and Tables]] · [[CMDB Workspace]]
