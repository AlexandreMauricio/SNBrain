---
type: table
tags: [table, cmdb, schema, choice-list]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > Explore > CMDB hierarchy, topic "Service tables" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/explore-cmdb.html), read through the docs site API 2026-10-09. Labels only; column names are not printed and are marked ?
sn-release: Brazil
verified:
updated: 2026-10-09
---

# cmdb_ci_service

**Label:** Service
**Extends:** [[cmdb_ci]]
**Extended by:** the service classes (business, technical and application services, service offerings). See [[Service Portfolio Management]] and [[Service Offerings, Commitments and Availability]].
**Purpose:** services as CIs.

## Key columns

| Label | Name | Type | Notes |
|---|---|---|---|
| Business criticality | `?` | choice | importance to the business; input for disaster recovery planning |
| Service classification | `?` | choice | the kind of service |
| Used for | `?` | choice | how the service is used; the same list is reused by **Used for** on [[cmdb_ci_server]] |
| SLA | `?` | reference to Agreement (`sla`) | |
| Users supported | `?` | reference to Group ([[sys_user_group]]) | |
| Version | `?` | | free for your own versioning |

## Choice values

Default options as listed in the Brazil docs (stored values not printed; choices can differ per instance).

- **Business criticality:** 1 - most critical, 2 - somewhat critical, 3 - less critical, 4 - not critical.
- **Service classification:** Application Service, Technical Service, Service Offering, Shared Service, Billable Service (a service that is billed or cost managed).
- **Used for:** Production, Staging, QA, Test, Development, Demonstration, Training, Disaster Recovery.

## Related tables

| Table | Label | Relation |
|---|---|---|
| `svc_ci_assoc` | Service Configuration Item Association | one row per CI that is part of an application service: **Configuration Item Id** (reference to `cmdb_ci`), **Service Id** (reference to `cmdb_ci_service`) |
