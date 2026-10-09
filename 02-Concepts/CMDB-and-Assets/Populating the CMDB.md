---
type: concept
tags: [concept, cmdb, discovery, import-sets, integrations]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > "Populating the CMDB" (https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/c_OptionsToPopulateCMDB.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# Populating the CMDB

**In one line:** the ways CIs get into [[cmdb_ci]] and its child tables, and what each costs in data quality.

| Way | What it is | Goes through IRE? |
|---|---|---|
| **Discovery** (ITOM Visibility) | scans the network with probes, sensors and patterns; creates CIs, running software, TCP connections and the relationships between them | yes |
| **Service Graph Connectors** | Store apps with ready-made integrations for common third-party sources | yes |
| **IntegrationHub ETL** | guided wizard: import source data, transform, map to classes and attributes, preview, schedule. Produces ETL transform maps | yes |
| **Import sets** | files (XML, Excel, CSV) or other sources transformed into the target class, on demand or scheduled | **only if the transform map calls it**: [[Apply IRE to an Import Set]]. Otherwise identical rows create duplicate CIs |
| **Existing discovery tools** (SCCM and similar) | mapped in through web services or connectors | depends on the method |
| **CMDB instance API** | REST API that creates or updates CIs | yes (docs: "CMDB instance API"; details not on this page) |
| **Manual, with IRE** | Create CI in CMDB Workspace | yes: [[Create a CI Manually in CMDB Workspace]] |
| **Manual, classic form** | **CI Class Manager** > class > **CI List** > **New**; or `<table>.list` (for example `cmdb_ci_linux_server.list`) > **New** | **no** |

- Relationships can be imported too: an import set targeting [[cmdb_rel_ci]] with parent, child and type.
- The role needed for manual creation depends on the class table.
- Class reference and modelling rules: [[CMDB Overview and Class Hierarchy]], [[CMDB Modelling Guidelines for Hardware, Virtual Machines and Cloud]], [[CMDB CI Class Models App]].

## Related

- [[Identification and Reconciliation Engine (IRE) Overview]] · [[Integration Options and Interfaces Overview]]
