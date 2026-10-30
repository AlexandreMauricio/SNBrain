---
type: concept
tags: [concept, discovery, cmdb, roles, schema, release-specific]
status: documented
source: ServiceNow Brazil docs, IT Operations Management > ITOM Visibility > Discovery (320 topics; Exploring Discovery, process flows, Discovery Admin Workspace, Configuring outline, schedule form), read at overview depth 2026-10-30. Cloud, container, probe-by-probe and pattern pages (360 patterns), and the 87 Discovery properties not read. https://www.servicenow.com/docs/r/it-operations-management/discovery/discovery-schedule-form.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Discovery Overview

**In one line:** scans the network through a MID Server, works out what each device and application is, and creates or updates configuration items in the CMDB.

From the Brazil docs; not tested. Needs an ITOM Visibility subscription. Runs through a MID Server: see [[MID Server Overview and Architecture]]. CIs pass through [[Identification and Reconciliation Engine (IRE) Overview]].

## Horizontal and top-down

| | Horizontal | Top-down |
|---|---|---|
| Done by | Discovery | [[Service Mapping Overview]] |
| Finds | devices and applications on the network | CIs in a business service |
| Relationships | direct, such as *runs on* | by service |

Usually horizontal runs first, then top-down.

## The four phases

The instance puts each probe in the External Communication Channel (ECC) queue; the MID Server collects it, runs it, and returns the result.

1. **Scanning:** the **Shazzam** probe and port probes test common ports (WMI, HTTP, SSH, SNMP). Port 22 suggests UNIX or Linux.
2. **Classification:** one classification probe per device finds details such as the OS, which sets the CI class.
3. **Identification:** the classifier chooses the probes. CI identifiers decide whether to update a CI or create one.
4. **Exploration:** further probes collect more detail.

**Probes** collect and **sensors** parse. With **patterns**, the last two phases run a pattern's operations instead: a **Horizontal Pattern probe** calls it, and probes and sensors are not used.

## Schedules

**Discover** type on `discovery_schedule`:

| Type | Finds |
|---|---|
| Configuration items | devices, matched and updated in the CMDB |
| IP addresses | active IPs, **without credentials** |
| Networks | routers and switches, to fill IP networks |
| Service | services for Service Mapping |
| Cloud application | cloud resources for chosen patterns |
| Cloud resources | resources of a supported provider |

Started by a schedule, **Discover now**, or **Quick Discovery**. Ranges in `discovery_schedule_range`; use range sets and the Global Excludes List.

## Administration

- **Role:** `discovery_admin` for configuration, including MID Servers and credentials.
- **Discovery Admin Workspace** (**Workspaces > Discovery Admin Workspace**): Home, Schedules, Diagnostics, Content 360, Insights, Tuning, Settings. Features depend on the workspace version.
- **ITOM Configuration Console**, Guided Setup and Quick Start are the setup paths; Guided Setup is being phased out generally, see [[Adoption Services, Boards and Legacy UI Tools]].
- **Pattern Diagnostic agentic workflow** helps with pattern failures.
- Tables: `discovery_classy`, `discovery_classy_proc`, `discovery_classy_windows`, `discovery_classy_snmp`, `discovery_classy_http`, `discovery_port_probe`, `cmdb_ip_service`, `sa_pattern`.

Also covered in the guide: SNMP, Microsoft JEA, SCCM together with Discovery, VMware, IPAM, domain separation.

## Example

Create schedule *Example Office Scan*, type Configuration items, on MID Server *Example MID*, range *Example Range 10.0.0.0/24*, with a Windows credential. Run **Discover now** and check a new computer CI.

## Related

- [[Service Mapping Overview]] · [[MID Server Selection, Capabilities and Clusters]] · [[Credential Types Reference]] · [[Identification and Reconciliation Engine (IRE) Overview]] · [[Dynamic IRE]]
