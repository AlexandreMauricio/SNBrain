---
type: concept
tags: [concept, instance-admin, platform]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Platform performance" and "System Diagnostics" (pp. 2794-2838), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Monitoring and troubleshooting instance performance

**In one line:** where to look when the instance is slow: the transaction log, the response-time clock, the slow pattern logs under **System Diagnostics > Stats**, and the index suggestion engine.

## Where time goes

| Tool | Path | Tells you |
|---|---|---|
| Transaction log | **System Logs > Transactions** (`syslog_transaction`) | per transaction: user, URL, response time, SQL time and count, business rule time and count, network time, output length. Average a column with **Configure > List Calculations** |
| Response time indicator | clock icon at the bottom of forms and lists | total, network, server, browser split. Off with `glide.ui.response_time` = false. Not shown on the first transaction of a session |
| Slow Queries | **System Diagnostics > Stats > Slow Queries** (`sys_query_pattern`) | similar queries aggregated (same table and where-fields), listed when total time exceeds 5 s. Example SQL, stack trace (`table.sys_id:line`), URL, count, average. **Explain Plan** shows the database plan |
| Slow Scripts | same menu (`sys_script_pattern`) | which business rule, script include etc. costs the most |
| Slow Transactions | same menu (`sys_transaction_pattern`) | server and client averages per URL pattern |
| Slow Events, Slow Mutex Locks, Slow Interactions | same menu | event handlers, lock contention |
| Transaction call chain | from a transaction or slow transaction record: **Record call chain of next occurrence** | the ordered scripts run by that URL next time it occurs, with depth and duration. Review under **System Diagnostics > Transaction Call Chain** |
| Client transaction timings | plugin | browser versus network versus server |
| Connection test | UI page `connection_test.do` (add a module with link type URL) | speed between your machine and the instance |

Reading patterns: everything slow for a short window = an unusual load then (big report, job). One transaction always slow = a query problem, typically sorting or grouping a large table on an unindexed field.

## Common causes and fixes

| Cause | Fix |
|---|---|
| Sorting/filtering a big table on an unindexed field | index (below) |
| Query fetching too much | narrow the query, paginate |
| Cache flush in business hours | avoid during core hours: changing **system properties**, **dictionary entries**, committing **update sets**, changing translations, and `cache.do` |
| Runaway script or export | quotas: [[Transaction Quotas, Application Quotas and Operational Toggles]] |
| Nothing found | contact support (may be infrastructure) |

## Index Suggestion Engine (ISE)

Plugin `com.glide.index_suggestion`, active by default, MySQL only.

1. Slow Queries > open a record > **Suggest Index** (may first ask for fresh metrics or to run the *Collect Column Stats* job).
2. Review under **System Diagnostics > Index Suggestions > To review**: **Export** (XML, import in sub-production with **Import Suggestions**), **Ignore**, or **Schedule Creation** (now or later; large tables can take an hour or more).
3. A 14-day evaluation follows (state *Evaluating Effectiveness*), checked hourly. **Test Performance** gives an immediate with/without comparison.
4. End states: Created, Dropped, Ignored, Accepted (kept against advice), Superseded. If the ISE says *Drop Suggested* (unused or degrading), **Schedule Drop**.

Table: `sys_index_suggestion`.

## Other notes

- Import set transforms process records in blocks of 100, which helps most with many reference or choice columns and least with complex or unkeyed coalesce.
- Browsers should accept compressed responses (default).
- Usage dashboards: **Self-Service > Dashboards > Usage Overview** and **ServiceNow Store Usage Overview** (roles admin, `usage_admin`).
- Stats patterns are cached before being stored; a cache flush loses the unsaved ones.

## Related

- [[System Events and Scheduled Jobs Dashboards]] · [[Instance Scan]]
