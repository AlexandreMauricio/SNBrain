---
type: table
tags: [table, cmdb, schema]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > Explore > CMDB schema model, topic "Computer [cmdb_ci_computer] class" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/explore-cmdb.html), read through the docs site API 2026-10-09. Labels only; column names are not printed and are marked ?
sn-release: Brazil
verified:
updated: 2026-10-09
---

# cmdb_ci_computer

**Label:** Computer
**Extends:** [[cmdb_ci_hardware]]
**Extended by:** [[cmdb_ci_server]], Personal Computer (`cmdb_ci_pc_hardware`)
**Purpose:** hardware CIs that are computers, physical or virtual.

## Own columns

| Label | Name | Notes |
|---|---|---|
| Operating System | `?` | name of the operating system |
| OS Version | `?` | |
| OS Service Pack | `?` | |
| OS Address Width (bits) | `?` | 32, 64 |
| OS Domain | `?` | no description given |
| CPU name, CPU type | `?` | |
| CPU count | `?` | number of CPUs |
| CPU core count | `?` | cores per CPU |
| CPU core thread | `?` | threads per core |
| CPU speed (MHz) | `?` | |
| CPU manufacturer | `?` | reference to Company (`core_company`) |
| RAM (MB) | `?` | |
| Disk space (GB) | `?` | |
| Chassis type, Form factor | `?` | |
| Object ID | `?` | for example the virtual machine ID tied to the computer |
| IsVirtual | `?` | true when the computer runs on a virtual machine instance |
| CD_ROM, CD Speed, Floppy | `?` | legacy drive details |

## Notes

- **Physical and virtual machines share this class.** There is no separate "virtual computer" class: set **IsVirtual** to true and add a Virtual Machine Instance (`cmdb_ci_vm_instance`) record related to it. Details in [[CMDB Modelling Guidelines for Hardware, Virtual Machines and Cloud]].
- Identification rule: the same one as Hardware and Server (same note).
