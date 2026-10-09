---
type: how-to
tags: [how-to, cmdb, schema, data-integrity]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB classifications and class dependency, topic "Reclassify a CI" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/c_CMDBClassifications.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# Reclassify a CI

**Goal:** move a CI to another class by changing its **Class** attribute.
**Roles:** whatever is needed to update the CI: `sn_cmdb_editor`, `asset` or `itil`.

## What happens

The CI keeps its `sys_id` ([[Sys ID]]). A record with that sys_id is inserted in the new class table, with the new class's set of attributes.

| Kind | Meaning | Example | Data |
|---|---|---|---|
| Upgrade | to a child class (more attributes) | `cmdb_ci_computer` to `cmdb_ci_server` | nothing lost |
| Downgrade | to a parent class | `cmdb_ci_server` to `cmdb_ci_computer` | **attributes that exist only on the old class are lost, with their values** |
| Switch | to a class on another branch | `cmdb_ci_linux_server` to `cmdb_ci_win_server` | a downgrade followed by an upgrade, so the same loss |

## Steps

1. Show the CI in a list (for a server, `cmdb_ci_server.list` in the filter navigator).
2. Add the **Class** column to the list if it is missing (personalize the list).
3. Double-click the **Class** cell, pick the new class, confirm with the green check mark.

## Example

`Example Server 01` was loaded as Computer. In `cmdb_ci_computer.list`, change **Class** from Computer to Linux Server: an upgrade, so OS, CPU and RAM values stay and the server-only fields (Classification, Used for) become available.

## Gotchas

- **Avoid downgrades and switches: they lose data.**
- **Identification can reclassify automatically** (on by default), which can cause the same loss without anyone touching the CI. The properties controlling it belong to IRE reclassification settings.

## Related

- [[CI Classes, Dependency and Principal Class]] · [[CI Class Manager]] · [[cmdb_ci_computer]] · [[cmdb_ci_server]]
