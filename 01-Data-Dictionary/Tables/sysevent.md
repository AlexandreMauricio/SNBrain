---
type: table
tags: [table, automation, schema]
status: documented
source: ServiceNow Australia Platform Administration PDF, "System Events", topics "System Events" and "Event logs" (pp. 2727-2737), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# sysevent

**Label:** Event
**Extends:** none (rotated table: rows move between shards)
**Purpose:** the event log and queue. One row per fired event.

## Fields

| Label | Name | Type | Notes |
|---|---|---|---|
| Name | `name` | string | registered event name |
| Parm1 | `parm1` | string | free parameter |
| Parm2 | `parm2` | string | free parameter |
| Table | `table` | table name | table of the record the event is about |
| Instance | `instance` | string | sys_id of that record |
| State | `state` | string | ready, processed, error, transferred |
| Queue | `queue` | string | processor queue; empty = default |
| Processed | `processed` | date/time | when processing started |
| Processing time | `?` | integer | milliseconds |
| URI | `?` | string | HTTP query that generated the event |
| User ID | `user_id` | string | user who caused it, if any |
| Created | `sys_created_on` | date/time | |

## Related tables

- `sysevent_register`: event registry
- `sysevent_script_action`: script actions
- `sysevent_email_action`: notifications

## Used in

- [[Events and the Event Queue]] · [[Create and Register an Event]]
