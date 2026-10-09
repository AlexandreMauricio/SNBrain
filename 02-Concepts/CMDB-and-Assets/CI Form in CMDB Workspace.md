---
type: concept
tags: [concept, cmdb, workspace, forms-lists]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB Workspace, topic "Manage CI details using CI Form" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/cmdb-workspace.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# CI Form in CMDB Workspace

**In one line:** the page a CI opens in throughout [[CMDB Workspace]] (and other workspaces that embed it): all details of one CI in sections, with edits passed through identification and reconciliation (IRE) so they cannot quietly create a duplicate.

- On by default: property `sn_cmdb_ws.explore_ci.record.enabled`.
- CMDB Admin and Editor view and edit; CMDB User views.
- Header actions: Otto **CI Summarization** skill (if set up) and **Open map** (Unified Map; not for a non-operational CI).

## The Explore CI view

The layout is the form view **Explore CI** (in `sys_ui_view`). Predefined for many classes and **inherited by child classes that have none of their own**.

- **... > Configure attributes** opens Form Builder for the Summary and Attributes sections (role `personalize_form`).
- **... > Configure resources** edits the related lists shown under Resources (role `personalize_list`).

## Sections

| Section | Content | Notes |
|---|---|---|
| **Summary** | the first section of the Explore CI view: Created, ownership (Managed by), Discovery source, Operational status | **Important attributes** tile = the section of that name, if defined (Operating System, Serial number) |
| **Attributes** | every other section of the view; **All** lists every attribute; mandatory marked `*` | editing needs `sn_cmdb_editor` |
| **Tags** | key/value pairs in **Key Values** (`cmdb_key_value`): cloud tags filled by Discovery and Service Graph Connectors | **Manage** to add, change, delete (`sn_cmdb_editor`). Not the platform Tags column |
| **Resources** | the related lists of the view: File Systems (`cmdb_ci_file_system`), Software Installed (`cmdb_ci_spkg`), Network Adapters (`cmdb_ci_network_adapter`)... | **Manage** (many-to-many lists), **New**, **Delete** according to access to each table |
| **Activity** | pie charts of open incidents, changes and problems (role `itil`), and CI history | charts configured in `sn_cmdb_ws_explore_ci_related_item_config` (role `sn_cmdb_ws.config_editor`); each user can hide charts |
| **Relationships** | totals, duplicate and stale relationships; tree or flat view | **Edit relationships** opens Unified Map on this CI, 1 level, vertical (`sn_cmdb_editor`; not for non-operational CIs) |
| **Services and Offerings** | counts of service instances, business service offerings, technology management offerings and services the CI supports | |
| **Health** | latest CMDB Health results (completeness, correctness, compliance, relationships) and attestation state | needs CMDB Health set up and its jobs running |
| **CMDB 360** | per attribute, the CMDB value and the values each discovery source reported | only when CMDB 360 is enabled |

## Behaviour when saving

- If the class has IRE rules, the update goes through IRE. A detected duplicate, or a dependent CI without a valid parent relationship, pauses the update and offers ways out.
- **Reconciliation rules can block some attributes and let others through**, so an update may be applied only in part.
- No IRE rules for the class: the CI is updated directly.
- **Discovery source** becomes *Manual via IRE* unless you set another value.

## New items under Resources

- If the related table is a CI class with an identification rule (and not excluded), **New** opens the Create CI flow with the parent pre-filled as the dependent-upon CI ([[Create a CI Manually in CMDB Workspace]]). The reference or relationship back to the current CI is created for you.
- Without an identification rule: a plain list view.
- Some resources (CI IPs, others with scripted relationships) have no **New**.
- Use **Refresh List** to see the new row.

## Highlighted attributes

Colour highlights come from **Highlighted Values** (`sys_highlighted_value`, rows whose table starts with `cmdb_ci`): **All > Workspace Experience > Administration > Highlighted Values**. Example: `operational_status` green when *Operational*, red otherwise.

## Gotchas

- For a Service Instance (`cmdb_ci_service_auto`) or a derived class, relationships are edited in Service Mapping (if installed) or Unified Map, not here.

## Related

- [[CI Relationships]] · [[cmdb_ci]] · [[CMDB Workspace Reference - Properties, Roles, Jobs and Tables]]
