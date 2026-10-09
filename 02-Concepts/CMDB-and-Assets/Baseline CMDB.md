---
type: concept
tags: [concept, cmdb, change, release-specific]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > "Baseline CMDB" (https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/c_BaselineCMDB.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# Baseline CMDB

**In one line:** a baseline is a snapshot of CIs (attributes plus first-level relationships) that later changes are compared against, shown on the CI form as **Baseline differences**.

**Status:** from Brazil, Baseline CMDB is being prepared for deprecation: hidden and not activated on new instances, still supported. The docs point to Unified Map for the current experience. Best practices: KB0829681.

## What it does

- Several baselines can exist; changes are tracked per baseline.
- A baseline captures each CI's attributes and its **first-level** relationships. Changes to the CI or to its directly related CIs are shown.
- **CIs created after the baseline are not added to it.**
- The same feature area lets a CI be associated with a change or task and changes to it be *proposed*, applied only once the change is complete.

## Create a baseline

Roles: `ecmdb_admin`, plus `sn_cmdb_editor` or `itil`.

1. **All > Configuration > Baselines > Baselines** > **New**.
2. **Name** it. **Table** defaults to `cmdb_ci` (every CI). Optionally choose another table or **Conditions**, for example Database with *Location is* a given site.
3. **Submit**. It is built in the background and an email is sent when it finishes.

## See the differences

Role `sn_cmdb_editor` or `itil`. Add the field **CMDB Baseline diff** (label **Baseline differences**) to the CI form, open a CI and pick the baseline in the choice list. Works only for `cmdb_ci` and its child tables. Changes to related CIs show as *Basic attribute changes*.

## Properties

| Property | Default | Notes |
|---|---|---|
| `com.cmdb.baseline.max_changes` | 100 | maximum changes and relationships shown in the diff. **Configuration > CMDB Properties > Baseline Properties** (role `sn_cmdb_admin` or `admin`) |
| `com.cmdb.baseline.entry.attachment` | false | not in the base system: add it to `sys_properties`. Set true, then run the fix script **CMDB Baseline convert XML to attachment** once, to load large diffs without memory problems. When false the diff uses the legacy method, which can fail on large data |

## Related

- [[CI Relationships]] · [[CMDB Overview and Class Hierarchy]]
