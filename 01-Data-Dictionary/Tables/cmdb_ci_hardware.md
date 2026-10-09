---
type: table
tags: [table, cmdb, schema]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > Explore > CMDB schema model, topic "Hardware [cmdb_ci_hardware] class" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/explore-cmdb.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# cmdb_ci_hardware

**Label:** Hardware
**Extends:** [[cmdb_ci]]
**Extended by:** [[cmdb_ci_computer]] (and through it [[cmdb_ci_server]]), Network Gear (`cmdb_ci_netgear`) and other hardware classes
**Purpose:** base class for hardware CIs.

## Own columns

The docs print these three as names. Everything else is inherited from [[cmdb_ci]].

| Name | Notes |
|---|---|
| `hardware_status` | status such as In Maintenance or Retired; used to synchronise status to the asset record |
| `hardware_substatus` | second-level status; the choices offered depend on `hardware_status` |
| `default_gateway` | gateway the computer connects through |

## Related tables

| Table | Label | Relation |
|---|---|---|
| `cmdb_serial_number` | Serial Number | many per hardware CI; has a type (system, uuid, chassis, bios, baseboard) and the value |
| `cmdb_ci_network_adapter` | Network Adapter | one per adapter, linked to the hardware CI |
| `cmdb_ci_ip_address` | IP Address | one per address, linked to the adapter and the hardware CI |
| `cmdb_software_instance` | (software instance) | software installed on the CI; `cmdb_sam_sw_install` instead when a Software Asset Management plugin is installed |

How to fill these, and the identification rule shared by Hardware, Computer and Server, are in [[CMDB Modelling Guidelines for Hardware, Virtual Machines and Cloud]].
