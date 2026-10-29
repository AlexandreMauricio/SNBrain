---
type: concept
tags: [concept, cmdb, scripting, admin]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > Dependency Views (27 topics, 1,393 cleaned lines, read in full through the docs site API 2026-10-29) - landing, supported browsers, domain separation, map, menus and controls, cluster nodes, virtual grouping, Use (7 procedures), Administer (indicators, icons, predefined filters and default, map related items, menu actions and their parameters, dependency types), Properties, Components. https://www.servicenow.com/docs/r/servicenow-platform/dependency-views/c_BusinesssServiceManagementMaps.html
sn-release: Brazil
verified:
updated: 2026-10-29
---

# Dependency Views

**In one line:** the classic CI map (formerly "Next Gen BSM", plugin `com.snc.ng_bsm`) that draws a root CI with its upstream and downstream relationships, shows open tasks on each node, and lets you add or delete relationships; **from Brazil it is being prepared for deprecation** in favour of [[Unified Map]].

From the Brazil docs. Deprecation: hidden and not activated on new instances, still supported (KB05484748). The same applies to the classic relationship editor ([[CI Relationships]]).

## The map

- Opened with the map icon next to a CI reference (on a CI or on a task's **Configuration item**), or **All > Dependency Views > View Map** / **View Map in New Tab** / **Saved Views**.
- One **root CI** (pulsing frame); 3 levels up and down by default. Clusters (`cmdb_ci_cluster`) start collapsed.
- Only classes extending `cmdb_ci` appear (also true of CI relation formatters).
- With Service Mapping, the map also shows service map connections, and CIs of a service sit under the service node.
- ACLs are enforced: CIs the user may not read are hidden with their relationships.
- Not for tablets or mobile; no image export from Internet Explorer.
- **Domain separation: basic support only.** `cmdb_ci` is domain separated, `cmdb_rel_ci` is not; relate CIs in the same domain. Tenants see their domain and global CIs.

### Layouts and controls

Vertical (default), Horizontal, Radial, Force (around the root), Group (by CI type); **Details** lists problems, changes, related services (and events and alerts with Event Management; double-click a service to open it in the Event Management dashboard).

Menus by right-click:

| Where | Options |
|---|---|
| Background | Run Layout, Fit To Screen, Reset Filters |
| Node | View Form, View Map (make it root), View Related Tasks, View Affected CIs (only when opened from a task), View Related Outages, **Add Relationship** (drag a green line to another CI, pick the type), Expand / Collapse, Run Layout From Here, **Load More** (one more level past Max Levels) |
| Relationship line | View Relationship Form, Modify Relationship, **Delete Relationship** (asks to confirm) |

View menu: **Save View**, **Load View**, **Last View**, **Export Image** (PNG).

### Virtual grouping

When more CIs of the same type sit at one level than `glide.bsm.too_many_children` (10), they collapse into a **virtual group** node with a count, linked by virtual links. A virtual group is not a CI and cannot have tasks. No grouping is applied directly below a virtual group, nor at a level reached with Load More. Predefined filters are not applied to virtual groups until they are expanded.

### Map settings (filter panel)

Save / load custom settings (listed under **Dependency Views > Saved Settings**), **Predefined Filters**, **Dependency Type**, **Max Levels**, filter by depth, CI type, location, manufacturer, **audit failure** (hides CIs failing the CMDB Health staleness test), relationship types, **Map Indicators**, Remove Filtered Items (off = greyed), Run Layout Automatically, Fit to Screen Automatically.

## Roles

`dependency_views` is the minimum to open a map (menu, URL or script); the map page also names `itil` and `ecmdb_admin` as able to do everything. Indicators, icons and menu actions: `ecmdb_admin` or `sn_cmdb_admin` / `admin` (pages differ). Properties, dependency types, saved-view deletion, export: `sn_cmdb_admin` or `admin`, though some procedure pages say "none" (inconsistent in the docs).

## Administration (**All > Dependency Views**)

| Module | What it does |
|---|---|
| **Map Indicators** (`bsm_indicator`) | icons on nodes for related records. Shipped: open incident, open alert, unplanned and planned current outage or open problem, current/planned/recent change. Fields: **Table**, **Name**, **Order** (lowest wins), **Icon**, **CMDB CI field**, **Start field** (timeline position in Insights Explorer), **Description field**, **Description** (hover text), **Conditions**, **Active in Service Map**, **Active Dependencies** (must be on for Dependency Views), **Active in Metrics**, **Label**, **Tooltip Label**, **Tooltip Info**. The *Affected CIs* indicator shows on every affected CI of an active task, until the task closes |
| **Map Icons** (`ngbsm_icon`) | icon per CI type (**CI Type**, **Icon**, **URL** like `/<image>.svg`; default images under `/images/app.ngbsm/`). The class icon itself is set in [[CI Class Manager]] > Basic Info > Icon |
| **Predefined Filters** (`map_view` with `map_view_ci_type`, `map_filters`, `map_view_rel_type`, `map_viewroles`) | **Name**, **Roles**; configuration types (classes), CI filters (attribute conditions), relationship types. A CI shows only if it matches at least one entry of each kind that has entries. Role `ecmdb_admin` |
| Default predefined filter | user preference `ecmdb.ciview` (String) = sys_id of the filter; User empty and **System** ticked for everyone. Then *Default* in map settings applies it |
| **Map Related Items** (`ngbsm_related_item`) | show CIs linked by a **reference field** rather than a relationship: **Configuration item** (base class), **Related item** (class), **Related field**, **Active**. Shipped: Disk, Network Adapter, Database related to Computer and Server |
| **Map Menu Actions** (`ngbsm_context_menu`) | **Name**, **Active**, **Condition** and **Script** (both run **client side in the browser**, without server APIs), **Item** (Canvas, Node, Relationship), **Order**, **Type** (option or separator). To change a shipped action: open it, *Insert and Stay*, rename and edit the copy, deactivate the original (keeps upgrades clean) |
| **Dependency Types** (`ngbsm_script`) | server-side script (per the template) that reshapes the map in real time. Shipped: Default (no processing), Show All Relationships (qualifiers, end points, entry points; inactive by default). With Service Mapping: Application to Network Devices, Network Device to Applications, Physical Network Connections, Flow Dependencies (from `sa_flow_server_comm`, NetFlow data) |

Menu action variables: `item.label`, `item.ci_type`, `item.name`, `item.location`, `item.manufacturer_name`, `item.id`, `item.is_selected`, `item.level`, `item.locationId`, `item.locationName`, `item.manufaturerId` (spelt so in the docs), `item.is_collapsed`, `item.is_cluster`; in scripts also `item.source`, `item.target` (the relationship's two ends), `item.location_name`, `item.manufacturer_id`. The docs spell some of these two ways; check in the instance.

```javascript
// Map menu action (client side, in the browser). Item = Node.
// Condition:  !item.is_collapsed && item.ci_type == 'cmdb_ci_server'
// Script: open the CI's list of open incidents in a new tab
window.open('/incident_list.do?sysparm_query=active=true^cmdb_ci=' + item.id);
```
(My example, built from the documented variables; not run.)

## Properties (**Dependency Views > Map Properties**)

| Property | Default | Meaning |
|---|---|---|
| `glide.bsm.max_nodes` | 1000 | nodes retrieved; more are not shown |
| `glide.bsm.max_levels` | 3 | initial depth (1 to 49) |
| `glide.bsm.too_many_children` | 10 | same-type nodes per level before virtual grouping |
| `glide.bsm.show_virtual_node_children` | No | show the map below virtual groups |
| `glide.bsm.max_num_rels` | 100 | relations retrieved per node |
| `glide.ngbsm.filters_remove_filtered_items` | Yes | remove filtered items (No = dim) |
| `glide.ngbsm.filters_run_layout_automatically` | Yes | re-layout on filter change |
| `glide.ngbsm.filters_fit_to_screen_automatically` | No | fit on filter change |
| `glide.ngbsm.performance_allow_curves` | Yes | curved lines (No may help performance) |
| `glide.ngbsm.notification_display_time` | 5000 | ms a notification stays |
| `glide.ngbsm.search_ci_limit` / `search_rel_type_limit` | 10 / 5 | search results |
| `glide.ngbsm.show_class_labels` | Yes | class label above CI label |
| `glide.ngbsm.truncate_long_labels` | No (the text calls truncation the default: contradictory) | one-line labels |
| `glide.bsm.layout_horizontal_spacing_x` / `_y` | 200 / 100 | px in horizontal layout |
| `glide.bsm.layout_vertical_spacing_x` / `_y` | 125 / 125 | px in vertical layout |

Other tables: `ngbsm_ci_icons`, `ngbsm_ci_type_icon`, `ngbsm_view` (saved views), `ngbsm_filter` (saved filters), `bsm_edge_color` (line colour by relationship type), `bsm_graph`, `bsm_action`.

## Related

- [[Unified Map]] · [[CI Relationships]] · [[CI Class Manager]] · [[CMDB Overview and Class Hierarchy]]
