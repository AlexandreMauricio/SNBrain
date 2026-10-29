---
type: table
tags: [table, cmdb, schema]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > Explore > CMDB schema model, topic "Server [cmdb_ci_server] class" (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/explore-cmdb.html), read through the docs site API 2026-10-09. Labels only; column names are not printed and are marked ?
sn-release: Brazil
verified:
updated: 2026-10-09
---

# cmdb_ci_server

**Label:** Server
**Extends:** [[cmdb_ci_computer]]
**Purpose:** computers that act as servers, physical or virtual (**IsVirtual** on the parent class).

## Own columns

| Label | Name | Notes |
|---|---|---|
| Classification | `?` | production, development, disaster recovery, UAT and so on |
| Firewall status | `?` | internet or intranet facing |
| Host name | `?` | **do not use it for the host name: store the host name in Name** |
| Used for | `?` | environment the server supports (production, staging, QA...). Uses the **Used for** choice list of Service ([[cmdb_ci_service]]) |
| Disaster backup | `?` | reference to another `cmdb_ci_server`: this server's backup |

**Do not store the MAC address or IP address on the server record.** They belong in Network Adapter (`cmdb_ci_network_adapter`) and IP Address (`cmdb_ci_ip_address`): see [[CMDB Modelling Guidelines for Hardware, Virtual Machines and Cloud]].

## Extended by

These child classes add no columns of their own.

| Name | Label |
|---|---|
| `cmdb_ci_win_server` | Windows Server |
| `cmdb_ci_linux_server` | Linux Server |
| `cmdb_ci_unix_server` | Unix Server |
| `cmdb_ci_solaris_server` | Solaris Server |
| `cmdb_ci_hpux_server` | HPUX Server |
| `cmdb_ci_osx_server` | OS/X Server |
| `cmdb_ci_netware_server` | Netware Server |
| `cmdb_ci_ibm_zos_server` | IBM zOS Server |
| `cmdb_ci_mainframe` | IBM Mainframe |
| `cmdb_ci_virtualization_server` | Virtualization Server (abstract base of Hyper-V Server `cmdb_ci_hyper_v_server` and ESX Server `cmdb_ci_esx_server`) |
| `cmdb_ci_server_hardware` | Server Hardware |
| `cmdb_ci_chassis_server` | Server Chassis |
| `cmdb_ci_tape_server` | Server Tape Unit |
| `cmdb_ci_storage_node_element` | Storage Node Element |
| `cmdb_ci_datapower_server` | Data Power Hosting Server |
| `cmdb_ci_net_app_server` | Network Appliance Hardware |
| `cmdb_ci_lb` | Load Balancer (generic) |
| `cmdb_ci_lb_network` | Network Load Balancer |
| `cmdb_ci_lb_a10`, `cmdb_ci_lb_ace`, `cmdb_ci_lb_alteon`, `cmdb_ci_lb_cisco_csm`, `cmdb_ci_lb_cisco_css`, `cmdb_ci_lb_cisco_gss`, `cmdb_ci_lb_netscaler` | vendor load balancers |

The docs page spells some of these differently (unconfirmed variants) (`cmdb_ci_Unix_Server`, `cmdb_ci_lb_netsclaer`); the lowercase forms above follow the "CMDB tables descriptions" page. Confirm in `sys_db_object` before relying on one.
