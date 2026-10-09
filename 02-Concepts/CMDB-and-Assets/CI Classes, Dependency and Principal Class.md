---
type: concept
tags: [concept, cmdb, schema, forms-lists, admin]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > "CMDB classifications and class dependency" with its topics "CMDB record types", "Related Lists of CI components", "Teams related list", "Principal Class", "Update Principal Class filter" (https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/c_CMDBClassifications.html and the pages under it), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# CI Classes, Dependency and Principal Class

**In one line:** a CI *class* is a table in the CMDB hierarchy; each class is either **independent** (its CIs stand alone) or **dependent** (its CIs only make sense attached to another CI), and a few classes can be flagged **Principal Class** so lists, health and governance focus on them. Background in [[CMDB Overview and Class Hierarchy]].

## Terms

- **CI class**: the actual table name. **CI type**: the friendly name (computer, router, printer).
- **Relation type**: a named relationship, defined from both ends, written `Parent descriptor::Child descriptor`: *Powers::Is Powered By*, *In Rack::Rack contains*. A relationship can be between a CI and another CI, a user or a group.

## Independent and dependent classes

| Kind | Meaning | Examples |
|---|---|---|
| Independent | the CI has its own identity | Linux Server |
| Dependent | the CI exists meaningfully only through a relationship to another CI | Network Adapter (needs its hardware), Application (needs the server it is hosted on) |

- Identification (the Identification and Reconciliation Engine, IRE) relies heavily on this.
- See which kind a class is: its **Identification Rule** page in [[CI Class Manager]]. Dependency is set up there with *dependent relationship rules* (hosting and containment).
- What happens to dependent CIs when their parent is retired, archived or deleted: [[Dependent CI Management and Cascade Cleanup]].

## Related lists of components on a CI form

Related lists show what the CI contains: disk drives, network adapters, routing rules, serial numbers.

- Discovery fills them, and **by default they show only components found in the last scan**. Components still in the CMDB but not found are treated as absent and hidden.
- Default filters: for components that are CIs, **Status != Absent**; for components that are not CIs (serial numbers, rules), **Absent = false**.

Icons next to related items flag active incidents, problems and changes, planned and recently completed changes, and planned, active and recently completed outages; in tree view another icon means a downstream CI has one of those. The window is **five calendar days back and seven forward**.

## Teams related list

Associates groups with a service CI by *group type*. Table **`cmdb_rel_team`**, column `group_type`.

- Appears on forms of Service ([[cmdb_ci_service]]) and its descendants, for example Service Instance (`cmdb_ci_service_auto`). Not on the form by default: form context menu > **Configure > Related Lists** > move **Teams** to Selected.
- Base group types match the CI fields **Approval Group**, **Change Group**, **Managed by Group**, **Support Group**.
- **Two-way sync:** changing one of those fields updates (or creates) the matching Teams row, and changing **User group** on a Teams row updates the field. **Deleting a Teams row does not clear the field.**
- One group can be marked **primary**; an incident created for that CI is assigned to it. Only one group type can be primary at a time.
- Useful with many data sources and with IntegrationHub ETL.
- Add a custom group type (role `sn_cmdb_admin`, `itil_admin`, `asset` or `cmdb_admin`): open the Teams list > column options for **Group type** > dictionary entry > **Choices** > add a row (for example *Datacenter Group*).

## Principal Class

A flag on a class marking it as one of the classes that matter most for operations (change, incident, problem) and for data health. Stored on **CMDB Class Information** (`cmdb_class_info`).

- **Not inherited:** it applies to that class only, never to child classes.
- The **Principal Class filter** is empty in the base system.
- Choosing: stable, well-understood classes with direct business impact; core infrastructure when in doubt; agree with infrastructure, application and security teams; review periodically. Typical candidates are listed in [[CMDB Overview and Class Hierarchy]]. Guidance article: KB2707240.

Where the filter is used:

- CI lists and dashboards: list controls menu > **Filters > Principal Class** (for example on `cmdb_ci.list`, or in **Add Affected CIs** on a change request).
- CMDB 360 dashboard (Discovery sources card) in CMDB Workspace and Service Graph Workspace.
- CMDB success advisor: its recommendations and KPIs are computed over principal classes. Model categories added for Hardware Asset Management are marked principal automatically.
- ServiceNow Otto for CMDB has an agent that suggests principal classes.
- **CI lookup on task forms:** property `com.snc.task.principal_class_filter` is a comma-separated list of task tables whose **Configuration item** (`cmdb_ci`) lookup offers only CIs of principal classes. Default: `incident, incident_task, problem, problem_task, change_request, change_task`.

Set or clear it (roles `sn_cmdb_admin` or `itil_admin`, plus `personalize_dictionary`): **Configuration > CI Class Manager** > **Hierarchy** > select the class > **Class Info > Basic Info** > **Principal Class** > **Save**.

## Gotchas

- Once any class is principal, the CI picker on incidents, problems and changes hides CIs of every other class (property above). Check the list of principal classes if users report missing CIs.

## Related

- [[CI Class Manager]] · [[Create a CI Class]] · [[Reclassify a CI]]
