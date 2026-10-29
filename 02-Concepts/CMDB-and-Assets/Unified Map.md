---
type: concept
tags: [concept, cmdb, workspace]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > Unified Map (32 topics, 1,281 cleaned lines, read in full through the docs site API 2026-10-29) - Explore, Use, Controlling contents and appearance, filters and user presets, Overview, Attributes, Service instances, cmdb_ci relationships, Related items, timeline, Changes, Editing maps and its four procedures. https://www.servicenow.com/docs/r/servicenow-platform/unified-map/cmdb-workspace-unified-map.html
sn-release: Brazil
verified:
updated: 2026-10-29
---

# Unified Map

**In one line:** the graphical map of CIs and their connections in CMDB Workspace and Service Graph Workspace, centred on a *home node*; it merges parts of Dependency Views and the Service Mapping map, shows incidents, problems and changes on a timeline, and has an editor for creating and deleting relationships.

From the Brazil docs. Admin settings: [[Unified Map Administration Settings]]. Editing steps: [[Edit CI Relationships in Unified Map]]. Older map: [[Dependency Views]].

## Opening it

- **All > CMDB Workspace > Unified Map**, or **All > Service Graph Workspace > Unified Map**; Quick Links in [[CMDB Workspace]]; *Use Unified Map* in Service Graph Workspace's recommended tools.
- **Open Map** on a CI form ([[CI Form in CMDB Workspace]]), with that CI as home node.
- Activation: CMDB Workspace store app set up, and property `sn_sm_scoped_app.sa.unified_map.enabled` on (which also opens it from the Service Mapping workspace).

## Reading the map

| Element | Meaning |
|---|---|
| Solid line | relationship (`cmdb_rel_ci`, [[CI Relationships]]); the arrowhead points at the dependent node |
| Dashed line | reference (two CIs linked by a reference field, not a relationship) |
| Badge on a line | number of relationships between the two CIs in that direction |
| Badge on a group CI | members of a service instance or dynamic CI group; select to expand |
| Pulsing thick border | the home node |

Lines show relationships and references, **not data flow**.

## Controls

- **Home node** search, or right-click a node > *Set as home node*.
- **Levels**: default 3. Ignored when the home node is a mapped application service (`cmdb_ci_service_discovered`): all levels show.
- **Filters**: layer, CI class, relationship type, discovery source, location, ownership. Only attributes of elements on the map are offered; others appear under *Unused filter attributes*. Filtered items can be shown dimmed. The home node can never be filtered out. A dot on the filter icon means filters are active. **Reset filter** returns to the home CI's defaults.
- **Presets**: save filter settings as a personal **user preset**; admins publish **shared presets**. Precedence when a map opens: user preset > shared preset > shared preset in a profile > class profile (layers only).
- **Layouts**: *vertical* (upstream above, downstream below; default for service instances) or *force* (clustered round the home node).
- Toolbox: zoom, align to home, fit to map, mini-map navigator, **Export map** to PDF.
- **Up to 250 nodes** by default (members of collapsed groups count); the rest are truncated.
- Only CIs whose **Life cycle stage** is Operational or empty appear, in the map and in its search; **Open Map** is missing on other CIs. An admin can widen this.

## Side panels

| Panel | Shows |
|---|---|
| **Overview** | home node and type; counts of CIs, CI types, connections, connection types, discovery sources; map time. Not affected by filters or zoom |
| **Attributes** | base attributes (fixed) and per-class extended attributes (admin-configured); for a group CI, a card per member; for a line, a card per relationship. Highlighted value conditions apply. Card actions: *View CI details*, *Open in new map*, *Set CI as home* |
| **Service instances** | Service Mapping data for the selected CI's service instances (needs Service Mapping) |
| **Related items** | incidents, problems, changes and other categories, grouped, with counts; users choose categories through the panel's preferences |
| **Changes** | the CI's history (life cycle stage, operational state...); flag a change as important, filter by post type, field change, flagged, filter set; search |

Without Service Mapping only service instances populated by CMDB methods appear. Relationships of some service instance classes (Dynamic CI Group, Connection, Data, Facility, Network Service Instance, Network Function, Operational Process Service Instance, OT System Service) are listed in the property `unifiedmap.service_map.exclude_classes` (the docs say these classes *display* relationships, despite the property's name: unclear).

## Timeline

- The map starts at "now". Dragging the **map time** marker redraws the map as it was then (by node creation date) and marks related items at or before that time.
- Span from six months back to six months ahead; items outside it still appear in the Related items panel.
- Markers can be added, replaced or cleared; a badge counts several items on one date. Select empty space to see items for all CIs.

## Roles

| Need | Roles |
|---|---|
| View maps | `sn_cmdb_user`, `sn_cmdb_editor` or `sn_cmdb_admin` |
| Maps with operational service instances | `app_service_user` plus `sm_user` or `sm_admin` |
| Also non-operational service instances | `app_service_admin` plus `sm_user` or `sm_admin` |
| Related items | `itil` |
| Map editor | `sn_cmdb_editor` or `sn_cmdb_admin` |

## Map editor in short

Edits relationships in the CMDB; nothing is written until **Save**. Removing a CI from the map deletes its relationship records but never the CI record. Not supported: editing service instances, creating or deleting CI records, endpoint CIs, deleting reference or endpoint connections, changing the applicative flow relationship type. Details: [[Edit CI Relationships in Unified Map]].

## Related

- [[Unified Map Administration Settings]] · [[Edit CI Relationships in Unified Map]] · [[CMDB Workspace]] · [[CI Relationships]] · [[CI Form in CMDB Workspace]] · [[Dependency Views]]
