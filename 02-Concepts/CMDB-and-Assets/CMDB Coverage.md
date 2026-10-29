---
type: concept
tags: [concept, cmdb, discovery, data-integrity]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB Coverage (12 topics, 286 cleaned lines, read in full through the docs site API 2026-10-29) - landing, Explore, Configure, Use (discovery schedules, IPAM connectors, CMDB tables), Reference (initialization, scheduled jobs, properties, domain separation). https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/cmdb-coverage-explore.html
sn-release: Brazil
verified:
updated: 2026-10-29
---

# CMDB Coverage

**In one line:** a store app that measures how complete Discovery is by matching IP addresses from the IPAM system (allocated IPs) with discovered CIs, and by finding IPAM subnets that no discovery schedule covers.

From the Brazil docs. The page lists supported versions as Zurich and Australia even in the Brazil edition (?). Further guidance: KB2817579. **Domain separation: not supported.**

## What it shows (**CMDB Coverage Dashboard**)

| Area | Content |
|---|---|
| Infrastructure coverage | % of allocated IPs tied to a CI; coverage and gap counts |
| IP-to-CI association | allocated IPs with a single match, multiple matches, no match |
| Network coverage | operational managed networks, operational subnets, allocated IPs imported from IPAM |
| Discovery schedule gap | allocated IPs not in any active discovery schedule, and their % (needs Discovery, `com.snc.discovery`) |

Also free, reserved and allocated counts per subnet.

## Setup

Requires the CMDB CI Class Models app ([[CMDB CI Class Models App]], installed automatically) and **SGC Central** (`sn_sgc_central`, [[CMDB Workspace Insights and SGC Central]]). Role `sn_cmdb_admin` to configure, `sn_cmdb_user` to view.

1. Open **Service Graph Workspace > Management tools > CMDB Coverage Dashboard**, or CMDB Workspace > Quick links.
2. *Configure an IPAM connector*: configure an IPAM Service Graph Connector in SGC Central, or tick **Already configured or set up through another source**.
3. *Initialize CMDB Coverage* > **Begin initialization** (progress shown; time depends on data volume).

Afterwards, from the dashboard: **Discovery schedule gap > Create discovery schedule** (opens Discovery Admin Workspace), **Settings > Configure IPAM SGC**, **Settings > Review CMDB tables** (which CI tables supply IP addresses).

## How it works

| Job (`sysauto_script`) | Role |
|---|---|
| *PopulateBinaryTable* | one-time: converts existing IPv4 addresses to binary (IPv6 kept as is) into `sn_cmdb_ip_cov_binary_ip_address` |
| *InitializeAllocatedIPTable* | one-time: sets `ci_match_status` on Allocated IP Address (`cmdb_ci_allocated_ip_address`) and creates relationships from those records to the matching CIs; tracked in `sn_cmdb_ip_cov_init_tracker` |
| *ProcessStagingTable* | processes later changes: a DB listener (not polling) watches the tables listed in `sn_cmdb_ip_cov_ci_config`, writes new or changed IPs to `sn_cmdb_ip_cov_ip_staging` and pushes them on |
| *SubnetUsageCount* | daily: free, allocated and reserved per subnet |
| *Find missing IPAM ips in discovery* | compares IPAM networks, subnets and IPs with discovery ranges and schedules; gaps go to `sn_cmdb_ip_cov_discovery_schedule_gap` |

`ci_match_status`: `none` (discovery gap), `single`, `multiple`, `not_evaluated`. Business rule *Validate IP Coverage CI Config* checks that table configuration records only change the IP address field.

**Unconfirmed variant:** the docs write the relationship table as `cmdb_ci_rel`; elsewhere the CMDB relationship table is `cmdb_rel_ci` ([[CI Relationships]]). Both kept until checked in `sys_db_object` on an instance.

## Properties

| Property | Default | Note |
|---|---|---|
| `db_listener_enabled` | true | do not change; false stops the DB listener |
| `table_extension_enabled` | true | do not change; also analyse child tables of the configured tables |
| `sn_cmdb_ip_cov.log_associated_missing_ip` | false (create it, in the CMDB Coverage scope) | true fills `sn_cmdb_ip_cov_m2m_discovery_schedule_gap` (gaps to allocated IPs) |

## Related

- [[CMDB and CSDM Data Foundations Dashboards]] · [[CMDB Health]] · [[Populating the CMDB]] · [[CMDB Workspace]]
