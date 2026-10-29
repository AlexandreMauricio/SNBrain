---
type: concept
tags: [concept, data-management, platform, release-specific]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Data Management", topics "Live Archive with RaptorDB Professional V2" and "Install Live Archive" (pp. 596-601), read 2026-10-01; ServiceNow Brazil docs, Platform Capabilities guide > Additional capabilities > RaptorDB Professional (Live Archive, Live tables and archive tables, Requirements for querying archive data, Archive data query examples, Archive table schemas, Archive table names), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/live-tables-and-archive-tables.html
sn-release: Australia, Brazil
verified:
updated: 2026-10-29
---

# Live Archive with RaptorDB Professional

**In one line:** Live Archive (formerly Data Archiving) moves archived records and attachments out of the primary database into object storage, in compressed columnar form, while they stay queryable like normal tables.

## How it works

- Extends the normal archive rule framework: existing [[System Archive and Archive Rules|archive rules]] keep working unchanged, but the archive tables live in object storage.
- An **S3 facade** sits between RaptorDB and object storage (authentication, routing, resilience). Two endpoints are created, one per datacenter of the pair, so archives stay reachable if one datacenter is down.
- Same security as live data: ACLs, roles and row-level security apply. Encrypted at rest and in transit.
- The primary database may not shrink at once, but its growth slows and queries touch less data.
- Console figures for object storage refresh daily, show compressed sizes, and appear only once an archive table passes 512 MB or 2 million rows.

## Requirements

- Entitlement to RaptorDB Professional V2, release Australia or later, RaptorDB Professional 35.1 or later.
- Plugin **Live Archive** (`com.glide.db.columnar.archive`), installed from **All > Application Manager**.

## Installation notes

- Archive rule processing is **paused during the migration** of existing archives to columnar object storage; plan around time-sensitive archiving. No downtime otherwise.
- Duration depends on archive volume.
- Check afterwards: `sys_service_endpoint_list.do`, two `s3_facade` endpoints, both active; and an **Object Storage** tile in the Data Management Console (up to 24 hours).

## Archive tables (Brazil docs)

Archive tables are named `ar_` + the live table (`ar_incident`, `ar_change_request`, `ar_sn_customerservice_case`) and exist only after an archive rule has run once. They differ from live tables:

| Live table | Archive table |
|---|---|
| row-oriented | columnar (about 50% compression; reads only the columns asked for) |
| reference = sys_id | display value at archive time (sys_id only with **Retain References** on the archive rule) |
| choice = integer code (incident State 6) | display label (*Resolved*) |
| journal fields in `sys_journal_field` | serialized into the archive row |
| booleans | text `true` / `false` (on `ar_problem`) |
| relationships (e.g. related incidents on a problem) | not kept; join through `problem_id` on the incident side, if both are archived in the same window |
| editable | immutable; restore to change |

- Access: the live table's ACLs apply (rights on `incident` cover `ar_incident`); no separate ACLs.
- Good for column aggregations, date-range and low-cardinality filters, trends; poor for `SELECT *` on few rows and for joins to live tables on sys_id.
- Combining live and archive data (through Live Connect, [[RaptorDB Standard and Professional and Live Connect]]): `UNION ALL` with the live side wrapped in `DV(field)` so codes and sys_ids become display values; same-type fields (`opened_at`, `closed_at`, `resolve_time`) need no conversion. Without that, sorting and filtering give wrong results.
- Check columns at `sys_dictionary.list` (Name = the archive table) or with `SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'ar_incident'` through Live Connect.

## Related

- [[Data Management Overview]] · [[RaptorDB Standard and Professional and Live Connect]] · [[Create an Archive Rule]]
