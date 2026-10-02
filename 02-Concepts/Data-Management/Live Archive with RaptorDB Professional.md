---
type: concept
tags: [concept, data-management, platform, release-specific]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Data Management", topics "Live Archive with RaptorDB Professional V2" and "Install Live Archive" (pp. 596-601), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
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

## Related

- [[Data Management Overview]]
