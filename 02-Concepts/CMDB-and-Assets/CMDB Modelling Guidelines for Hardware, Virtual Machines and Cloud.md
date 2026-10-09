---
type: concept
tags: [concept, cmdb, schema, discovery, data-integrity]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > Explore > CMDB schema model, topics "Hardware [cmdb_ci_hardware] class", "Computer [cmdb_ci_computer] class", "Server [cmdb_ci_server] class", "VMware vCenter Object [cmdb_ci_vcenter_object] class", "Cloud class" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/explore-cmdb.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# CMDB Modelling Guidelines for Hardware, Virtual Machines and Cloud

**In one line:** where serial numbers, network adapters, IP addresses, installed software, virtual machines and cloud resources belong in the CMDB, and which attributes the base identification rules match on. Follow these when loading CIs by import or integration, otherwise identification creates duplicates.

Applies to [[cmdb_ci_hardware]], [[cmdb_ci_computer]] and [[cmdb_ci_server]].

## Serial numbers

Identification looks for a serial number in two places: the **Serial number** attribute of the CI and the **Serial Number** (`cmdb_serial_number`) table, which holds many serial numbers per hardware CI, each with a type and a value.

- **System** serial number: store it in both the CI attribute and the Serial Number table.
- Any other type: store it **only** in the Serial Number table.

| Type | Meaning |
|---|---|
| `system` | product identification (the serial number of the machine) |
| `uuid` | universally unique identifier of the product (128 bit) |
| `chassis` | manufacturer's number of the enclosure (SMBIOS System Enclosure) |
| `bios` | serial number assigned to the BIOS |
| `baseboard` | manufacturer's number of the motherboard |

## Network adapters and IP addresses

- One **Network Adapter** (`cmdb_ci_network_adapter`) record per adapter. **Name** = device name (`eth0`). **MAC Address** in lower case hexadecimal, colon separated, zero padded: `f8:f2:1e:00:d4:66`.
- One **IP Address** (`cmdb_ci_ip_address`) record per address. Put the address in both **IP Address** and **Name** (so Name is never empty). IPv4 as dotted decimal, IPv6 as lower case hexadecimal with colons; anything else is invalid and should be cleansed to null. The docs also say to set **Netmask** "to the IP address" (wording as printed; meaning unconfirmed).
- Both get an **Owned By::Owns** relationship in `cmdb_rel_ci` to the hardware CI, and a reference to it through their Configuration Item field. The IP address also references its network adapter, and the address is stored on the adapter too so the base identification rules work.
- **Do not store MAC or IP addresses on the Server record itself.**

## Installed software

- **Software** (`cmdb_ci_spkg`) is the generic package. `cmdb_software_instance` is one installation: **Installed on** references the server, **Product Name** references the package.
- With Software Asset Management Foundation (`com.snc.sams`) or Software Asset Management (`com.snc.software_asset_management`) installed, use **Software Installation** (`cmdb_sam_sw_install`) instead ([[Software Asset Management Foundation Plugin]]).

## Identification rule for Hardware, Computer and Server

The three classes share one base rule. Identifier entries in priority order:

1. Lookup in the Serial Number table (`cmdb_serial_number`).
2. The **Serial number** attribute on the CI.
3. **Name** (the host name). Used when no serial number is supplied, or as fallback when the serial number finds nothing.
4. MAC address and IP address in the Network Adapter table. Not to be relied on alone.

If only a MAC or IP address is known, use the MAC address as the CI name so the CI is not created with an empty name.

## Virtual machines

Physical and virtual machines use the same Computer and Server classes. For a virtual one:

1. Set **IsVirtual** to true on the Computer or Server CI (the *guest*).
2. Create a **Virtual Machine Instance** (`cmdb_ci_vm_instance`) record, identified by its BIOS UUID.
3. Relate the two (the docs name a *Hosted_On* relationship here).

VMware (classes such as `cmdb_ci_vcenter_cluster`, `cmdb_ci_vcenter_datacenter`, `cmdb_ci_vmware_instance`):

| From | Relationship | To |
|---|---|---|
| Guest (server CI) | Instantiates::Instantiated by | VMware instance (`cmdb_ci_vmware_instance`) |
| Guest | Virtualizes::Virtualized by | ESXi server |
| Guest | Has registered::Registered on | ESXi server |

- Guest: identified as a Server. Most operating systems report the BIOS UUID as the serial number, so **a cloned BIOS UUID breaks identification**.
- VM instance: identified by the instance MoRef ID.
- ESX server: a bare-metal Server with IsVirtual false.

## Cloud resources

- Cloud virtual machines (Amazon EC2, Azure compute) extend Virtual Machine Instance and come from the cloud inventory. The guest operating system is a separate Server CI (IsVirtual true) with a **Runs on::Runs** relationship to the cloud instance, matched on UUID / object ID.
- **Cloud Service Account** (`cmdb_ci_cloud_service_account`) is the class for AWS, GCP and Azure accounts (it replaces per-vendor tables such as `cmdb_ci_aws_account`).
- Regions are **Logical Datacenter** (`cmdb_ci_logical_datacenter`) records, extended by AWS Datacenter (`cmdb_ci_aws_datacenter`), Azure Datacenter (`cmdb_ci_azure_datacenter`), Google Datacenter (`cmdb_ci_google_datacenter`); compute, storage and network resources are related to them with **Hosts::Hosted on**.

Identification chain for a cloud resource:

| Class | Identifier entries | Depends on |
|---|---|---|
| Cloud resource | Object ID (the vendor's resource ID, unique per region) | its logical datacenter |
| Logical datacenter | Object ID, Region | its cloud service account |
| Cloud service account | Object ID, Account ID (usually the useful one) | |

## Related

- [[CMDB Overview and Class Hierarchy]] · [[cmdb_ci]]
