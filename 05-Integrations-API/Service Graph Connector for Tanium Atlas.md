---
type: reference
tags: [reference, integrations, cmdb, assets]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > Tanium Atlas (about 400 cleaned lines, read 2026-10-29) - overview, Configure using SGC Central, Data mapping, Targeted CMDB classes, Properties, Accessing connection details. https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/sgc-integration-tanium-atlas.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for Tanium Atlas

**In one line:** Store app `sn_tanium_atlas` that imports what **Tanium Atlas** discovers (computers, handheld devices, VMs, disks, file systems, network adapters, IPs, software and usage) into the CMDB, configured only through SGC Central.

From the Brazil docs (supported **Zurich Patch 4, Australia, Brazil**); not tested. Siblings: [[Service Graph Connector for Tanium]] (Asset-view based, includes servers) and [[Service Graph Connector for Tanium Atlas Endpoints]] (user-facing endpoints only). The page does not say how Atlas and Atlas Endpoints should be chosen between.

## Setting up the connection

SGC Central > **Create connection** > Tanium Atlas: **Create and test connection** (form fields not listed on the page) → **Set configuration properties** → **Configure import schedule** (activate) → **Confirm connection creation**. Connections: **All > Service Graph Connectors > Tanium Atlas > Connections**.

## Data sources

All write to staging table `sg_tanium_atlas_hardware_software` (name without an app prefix, as printed) except where noted: **SG-Tanium-Atlas Hardware-Software**, **Hardware Delta**, **Identity-Network**, **Installed Applications**, **Additional Sensors**, **Usage**, and **Remove Software** (`sn_cmdb_int_util_remove_record`).

Targets: Computer, Handheld Computing Device, Virtual Machine Instance (`cmdb_ci_vm_instance`, object ID), File System (mount point, sizes, free space), Disk (serial, interface, size, storage type), Network Adapter (MAC, MAC manufacturer, DHCP), IP Address, Software (`cmdb_ci_spkg`). Computer attributes include CPU details, DNS and OS domain, serial number, OS version and service pack; computers have a **Runs on::Runs** relationship (to the VM instance, presumably). The class labels on the page carry odd prefixes such as "Software 1 - Computer" and "IP Address 2 - Handheld Computing Device": they look like ETL map class names, meaning unconfirmed.

## Properties

| Property | Kind | Default | Meaning |
|---|---|---|---|
| `rest_action_limit` | connection | 50 | page size per REST call |
| `max_retry_count` | connection | 3 | REST retries |
| `sn_tanium_atlas.buffer_days_from_last_scan_for_hardware` | system | 0 | days a software stays active after the last scan of its hardware |
| `sn_tanium_atlas.exclude_serial_number_for_certain_os` | system (type string) | true | do not set serial numbers for AIX and Solaris |

## Related

- [[Service Graph Connector for Tanium]] · [[Service Graph Connector for Tanium Atlas Endpoints]] · [[Service Graph Connectors Overview]]
