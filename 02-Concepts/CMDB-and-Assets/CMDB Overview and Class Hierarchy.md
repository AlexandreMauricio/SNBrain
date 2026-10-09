---
type: concept
tags: [concept, cmdb, schema, roles]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Configuration Management > CMDB > Explore - "Overview of CMDB", "CMDB hierarchy", "CMDB tables descriptions", "Service tables", "CMDB schema model" (https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/explore-cmdb.html and the pages under it), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# CMDB Overview and Class Hierarchy

**In one line:** the Configuration Management Database (CMDB) is a tree of class tables under **Base Configuration Item** (`cmdb`) and **Configuration Item** (`cmdb_ci`) holding one record per configuration item (CI), plus **CI Relationship** (`cmdb_rel_ci`) records that say how CIs depend on each other.

## What a CI is

A CI is anything in the environment worth tracking and controlling: physical (a computer, a router), logical (a database instance) or conceptual (a requisition service). Each CI has attributes, changes made against it, and relationships to other CIs. The relationship data is what makes impact analysis possible: which services and people are hit when a disk array or router fails.

## The three core tables

| Label | Name | Role |
|---|---|---|
| Base Configuration Item | `cmdb` | root of the hierarchy; classes that descend from it but not from `cmdb_ci` are **non-IT CIs**. Uses the *table per partition* extension model ([[Table Extension and Extension Models]]) |
| Configuration Item | `cmdb_ci` | extends `cmdb`; the common attributes of every IT CI. See [[cmdb_ci]] |
| CI Relationship | `cmdb_rel_ci` | every relationship between two CIs. See [[cmdb_rel_ci]] and [[CI Relationships]] |

- Classes branch wherever a set of CIs needs an attribute its parent does not have: Configuration Item > Hardware (`cmdb_ci_hardware`) > Computer (`cmdb_ci_computer`) > Server (`cmdb_ci_server`) > UNIX Server (`cmdb_ci_unix_server`), and so on. See [[cmdb_ci_hardware]], [[cmdb_ci_computer]], [[cmdb_ci_server]].
- The base system ships hundreds of class tables. The docs page "CMDB tables descriptions" lists them all (name, label, one-line description); it is not copied here. Typical name prefixes: `cmdb_ci_appl_*` applications, `cmdb_ci_app_server_*` application servers, `cmdb_ci_db_*` databases, `cmdb_ci_lb_*` load balancers, `cmdb_ci_*_server` operating-system server classes, `cmdb_ci_vcenter_*` / `cmdb_ci_hyper_v_*` / `cmdb_ci_kvm_*` virtualization, `cmdb_ci_san_*` / `cmdb_ci_storage_*` storage.
- A custom class is added by extending a table already in the hierarchy. Classes are managed in **CI Class Manager** (**Configuration > CI Class Manager**): attributes, identification rules, health settings, CI list per class.
- All CIs in one list: type `cmdb_ci_list.do` in the filter navigator.
- Schema map of any class: **System Definition > Tables & Columns** > select the table > **Schema Map**.
- **CIs that do not extend `cmdb_ci` are not shown in Dependency Views maps or in CI relation formatters.**

## Key class categories

The docs suggest these as the usual candidates for *Principal Class* (the classes whose health you watch first): servers (physical and virtual), databases, core network devices (routers, switches, firewalls, load balancers; core before access switches), application servers, storage.

## Related tables (CMDB data outside the hierarchy)

Some tables do not extend `cmdb_ci` but hold CMDB data because a column references a CI, for example **Serial Number** (`cmdb_serial_number`). They are registered in **Related Entries** (`cmdb_related_entry`).

- Deleting a CI can leave orphan rows in a related table. A CMDB Data Manager policy of type *Delete CMDB Related Entry* cascade-deletes them.

## Service tables

Services are CIs too: child tables of **Service** (`cmdb_ci_service`) hold business, technical and application services. See [[cmdb_ci_service]] and [[Service Portfolio Management]].

- **Service Configuration Item Association** (`svc_ci_assoc`) binds an application service to each CI that is part of it. Columns (labels from the docs, names not printed): **Configuration Item Id** (reference to `cmdb_ci`) and **Service Id** (reference to `cmdb_ci_service`).

## Environment tracking

**Used for** on Server (`cmdb_ci_server`) records which environment the CI supports (development, test, production and so on), so a CI can be followed through its life cycle.

## Extended CMDB plugins

The base CMDB covers hardware and general CIs. Specialised classes come from separate plugins:

| Plugin | ID |
|---|---|
| CMDB Mainframe | `com.snc.cmdb.mainframe` |
| CMDB Radio Category | `com.snc.cmdb.radio.category` |
| CMDB Telecom Category | `com.snc.cmdb.telecom.category` |
| CMDB Test Equipment | `com.snc.cmdb.test.equipment` |

More class families come from the Store app described in [[CMDB CI Class Models App]].

## Roles

| Need | Role |
|---|---|
| Read CMDB tables directly | `cmdb_read` |
| Open the **Configuration** application menu | `sn_cmdb_editor`, `sn_cmdb_admin`, `asset`, `itil` or `itil_admin` |
| View CMDB records in the UI | `sn_cmdb_editor` or `itil` is usually enough |
| Access `cmdb_ci` | `sn_cmdb_admin`, `sn_cmdb_editor`, `asset`, `admin` or `itil` |

Updating and administering usually needs more; each feature states its own role.

## Gotchas

- **Do not use the Translated Text field type for CMDB attributes.** CMDB values change and grow constantly, so translated fields slow features such as CMDB Health and need manual upkeep. Translated Text suits static data ([[Field Types Reference]]).
- **Do not change the dictionary definition of base `cmdb_ci` attributes** (for example turning **Location** from a reference into a list): features built on the CMDB may stop working.

## How the CMDB connects to other applications

- Asset Management and Software Asset Management link assets, stock, manufacturers and vendors to CIs ([[Models, Model Categories and the Product Catalog]], [[Asset Management Common Applications]]). The CMDB itself is focused on operation, assets on finance and ownership.
- Contract Management holds leases, warranties, service contracts and licences ([[Contract Management]]).
- Ways of filling the CMDB named by the docs: Discovery and its patterns, Service Graph Connectors and the IntegrationHub ETL wizard, manual entry.

## Related

- [[CMDB Modelling Guidelines for Hardware, Virtual Machines and Cloud]] · [[CMDB CI Class Models App]] · [[cmdb_ci]] · [[Tables, Records and Table Relationships]]
