---
type: concept
tags: [concept, data-management, platform, schema]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Data Management", topic "Applying database rotation techniques" (pp. 644-648), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Database rotation: table rotation and table extension

**In one line:** very high-volume, insert-mostly tables are split into several physical tables (shards) by creation date; rotation reuses the oldest shard, extension keeps adding new ones.

## The techniques

| Technique | How it works | Base tables using it |
|---|---|---|
| **Table rotation** | a fixed number of tables, each written for a set duration; after the last, the first is overwritten | `syslog`, `sys_querystat`, `ecc_queue`, `ecc_event`, `cmdb_metric`, `sysevent` |
| **Table extension** | a new shard is started each period and none is reused, so nothing is deleted | `sys_email` |
| **Table sharding** | records grouped in a single table by document ID | (not detailed in the guide) |

Both use `sys_created_on` to decide which shard a record belongs to.

## Consequences for queries

- A query with a **created-date range** hits only the shards for that range.
- A query without one (e.g. filtering on updated date only) becomes a **union over all shards** and can be very slow. Always include a created-date window when querying these tables.
- **You cannot dot-walk to a rotated table.**
- Database views cannot use rotated tables ([[Database Views]]); table cleaner rules are not supported on them ([[Table Cleaner]]).

## Setting it up

**All > System Definition > Table Rotations**, **New**:

- **Name** (the table), **Type** = Rotation or Extension, **Duration** (days and hours per shard), and for rotation **Rotations** (number of tables) and **Clean base rotation**.
- **Deleting a rotation deletes the extra tables and all their data.**

Who may apply it:

- Custom `u_` tables: at your own discretion.
- Scoped `x_` tables: only after consulting ServiceNow or the application's developer.
- Base `sys_` tables: through Support.
- Not for `sys_import` tables or tables extending Task. Suitable only for sequentially written or insert-only tables.

Plugins: **Database Rotations** (`com.snc.db.rotation`), active on new instances. The guide says not to activate **Database Rotations Default Tables** (`com.snc.db.rotation_default_tables`) yourself.

## Related

- [[Data Management Overview]]
