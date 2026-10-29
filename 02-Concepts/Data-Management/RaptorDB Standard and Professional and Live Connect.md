---
type: concept
tags: [concept, data-management, platform, integrations]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > ServiceNow AI Platform Additional Capabilities > RaptorDB Professional (12 topics: landing, Explore, RaptorDB Professional, RaptorDB Standard and RaptorDB Professional, Live Connect, Live Archive and its archive-table pages), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/raptordb.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# RaptorDB Standard and Professional and Live Connect

**In one line:** **RaptorDB** is the ServiceNow database (PostgreSQL with ServiceNow optimisations); **Standard** is tuned for transactions, **Professional** adds analytics on the same engine (HTAP: column-store index, parallel queries) and is the tier required for **Live Archive** and **Live Connect** (read-only SQL from ODBC and JDBC tools).

From the Brazil docs; not tested. The roll-out of either tier is not tied to the upgrade; it depends on entitlement (ask the account team). Professional is available from Australia.

## Tiers

| Capability | Standard | Professional |
|---|---|---|
| Optimised for platform workloads | yes | yes |
| Column-store index and parallel query processing ([[Create or Drop a Table Index]]) | no | yes |
| Shared and replicated instance topologies, self-hosted | (listed under Professional) | yes |
| Live Connect, Live Archive, **Data Snapshots** (PA) | no | yes |

Benefits claimed for Professional: analytics on operational data without export, faster queries on large tables, smaller primary storage (leaner backups, faster clones), archived records queryable without restore.

## Live Connect

Formerly the **SQL API** plugin. Read-only SQL over ServiceNow tables from SQL and BI tools through ODBC and JDBC drivers, querying data in place (no replication or sync). By default only `SELECT`. Needs RaptorDB Professional, the Live Connect plugin, and access configured per user account (a service account); the platform administrator configures ACLs and checks access before analysts use it. The configuration and syntax page (*Access your ServiceNow data using Live Connect*) was not part of this chapter.

Live-plus-archive reporting pattern (Live Connect, PostgreSQL-style SQL; read only):

```sql
SELECT date_trunc('month', opened_at) AS month, priority, assignment_group, COUNT(*)
FROM (
  SELECT opened_at, DV(priority) AS priority, DV(assignment_group) AS assignment_group FROM incident
  UNION ALL
  SELECT opened_at, priority, assignment_group FROM ar_incident
) AS history
WHERE opened_at >= CAST(NOW() AS DATE) - INTERVAL '36 months'
GROUP BY 1, 2, 3;
```

`DV()` returns the display value on the live side so it matches the archive's stored labels; details in [[Live Archive with RaptorDB Professional]].

## Example

Analyst account *Example BI Reader* connects a reporting tool through the ODBC driver and builds a three-year trend of change requests from `change_request` plus `ar_change_request`.

## Related

- [[Data Management Overview]] · [[System Archive and Archive Rules]] · [[Instance Clone Overview]]
