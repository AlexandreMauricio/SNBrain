---
type: concept
tags: [concept, cmdb, schema, forms-lists, domain-separation, access-control]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > "CI relationships in the CMDB" with its topics "Suggested class relationships", "Relationship governance rules", "CI relations formatter" (domain separation, relationship filter, exclusion list, legacy formatter), "CI relationship editor", "Legacy CI relationship builder", "Relation qualifier", "CI relationship security" (https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/c_CIRelationships.html and the pages under it), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# CI Relationships

**In one line:** a relationship is one row in **CI Relationship** ([[cmdb_rel_ci]]) made of a parent CI, a child CI and a relationship type; relationships are what turn the CMDB from an asset list into something that can answer "what is affected".

Example: in *Server1 Managed by Server2*, Server1 is the child, Server2 the parent, *Managed by* the type. A CI can also be related to a user or a group.

Sources: Discovery and Service Mapping create many automatically, imports bring some, and people add or edit them by hand (relationship editor, or Unified Map in CMDB Workspace).

## Dependent and non-dependent relationships

| Kind | Used for | Tracking | Deleting |
|---|---|---|---|
| Dependent (for example *Tomcat Runs on Hardware*) | identification of dependent CIs by the Identification and Reconciliation Engine (IRE) | not tracked per source | **do not delete directly**: the dependent CI loses what identifies it |
| Non-dependent | impact and context only | discovery source and last scan time in **Relationship Sources** (`sys_rel_source`) | can be deleted when no longer needed; its `sys_rel_source` rows go with it |

- `sys_rel_source` is **not populated by default**, to spare IRE the load. Property `glide.identification_engine.populate_sys_rel_source` turns it on.
- With it on, a source can decide a relationship is safe to delete: no other source reports it and it has not been updated for a given time.

See [[CI Classes, Dependency and Principal Class]] for dependent classes.

## Key relationship types

Written parent descriptor / child descriptor.

| Parent | Child | Use |
|---|---|---|
| Runs on | Runs | software to the hardware or VM hosting it (Tomcat runs on a Linux server) |
| Hosted on | Hosts | an element and its host (cloud resource to logical datacenter, Kubernetes workload to cluster) |
| Contains | Contained by | containment; the child usually has one parent (Tomcat to its WAR, VMware datacenter contains network) |
| Owns | Owned by | usually containment; the child usually has one parent |
| Depends on | Used by | a problem or change on the child may impact the parent |
| Connects to | Connected by | network connections (workstation to switch, switch to switch) |
| Members | Member of | clusters (ESXi server is a member of a vCenter cluster) |
| Manages | Managed by | one CI manages others (vCenter manages a vCenter datacenter) |
| Defines resources for | Gets resources from | resource pool and ESX server |
| Applicative Flow To, Implement End Point To, Use End Point To | ...From | **Service Mapping endpoints only** (internal to the service model); not offered between ordinary CIs and not shown in the formatter |

## Suggested relationships

**Suggested Relationship** (`cmdb_rel_type_suggest`) lists which relationship types make sense for a class, so the editor can propose "a database *runs on* a server" and not "a rack *runs on* a server".

- Manage: **Configuration > Relationships > Suggested Relationships**, or [[CI Class Manager]] > class > **Suggested Relationships** > **New** (pick **Relationship** and **Target Class**). Read: `sn_cmdb_editor` or `itil`; write: `sn_cmdb_admin` or `itil_admin`.
- Form fields: **Base class**, **Relationship**, **Dependent class**. The same base class and relationship can appear several times with different targets.
- **Inherited down the class tree:** for a Linux server the editor collects suggestions whose base class is `cmdb_ci_linux_server`, `cmdb_ci_server`, `cmdb_ci_computer`, `cmdb_ci_hardware` or `cmdb_ci`.
- ITOM Visibility discovery patterns add suggestions too.
- Deleting a suggestion narrows the editor's choices; it does not touch relationships created by Discovery.

## Relationship governance rules

The set of rules that say which relationship type and direction are valid between two classes, so different applications do not model the same thing in different ways. A relationship is valid if it matches **any** of them:

- **Dependent relationship rules** (hosting and containment), used for identification. CI Class Manager > **Dependent Relationships**.
- **Suggested relationships** (above).
- **Reference rules**, used mostly by Cloud Management.
- **Built-in**: `cmdb_ci_endpoint` Applicative Flow To `cmdb_ci_endpoint`; `cmdb_ci_endpoint` Implement End Point To `cmdb_ci`; `cmdb_ci` Use End Point To `cmdb_ci_endpoint`.

Behaviour: rules are inherited by child classes (a rule for `cmdb_ci_appl` Runs on `cmdb_ci_hardware` validates a .NET application on a Windows server); no duplicate rules; **not domain separated**; several relationship types between the same two classes are allowed.

Report: the Relationship Health Dashboard has *Relationships not compliant with all relationship rules*.

## Relation qualifier

A CI of class **Qualifier** (`cmdb_ci_qualifier`) that annotates a relationship, for example that it was discovered from traffic. It sits between the two CIs, so the relationship becomes **two rows** in `cmdb_rel_ci`: parent to qualifier, qualifier to child. Several qualifiers form a chain; only one chain per relationship type between two CIs. Qualifier chains are hidden in the formatter.

## CI relations formatter (Related Items on the CI form)

Shows the CI's related CIs with a toolbar: **+** (open the relationship editor), **Show dependency views**, search, and settings (kept per user across sessions):

| Setting | Options |
|---|---|
| Layout | **Flat** (default, grouped by type) or **Tree** (hierarchy; no other settings apply) |
| Split / Merge | **Merge** (default, upstream and downstream together) or **Split** |
| Max level | levels up and down in flat view, default 3 |
| Relationship type | default all |
| CMDB view | a relationship filter (below) |

Icons flag incidents, problems, open / planned / recently closed changes and outages.

- **Only CIs extending `cmdb_ci` appear.** An endpoint that is child in one relationship and parent in another is hidden, so *CI1 > endpoint > CI2* shows as *CI1 > CI2*.
- **Relationship filter** (role `ecmdb_admin`): **Configuration > Relationships > Relationship Filters** > name > save > **Configuration Types > Edit** > choose the tables. Then pick it under *Filter Relations by CMDB View*: only CIs of those tables and their children show.
- **Exclusion list** (write: `sn_cmdb_admin` or `itil_admin`): **Configuration > Relationships > Relationship Type Exclusion List** > **New**: the relationship no longer appears in the formatter.
- A legacy formatter (flat and tree icons only) is used on browsers that cannot run the current one.

Performance properties:

| Property | Default | Effect |
|---|---|---|
| `glide.ui.max_relations` | 1000 | maximum related CIs shown; beyond it a message appears and flat layout falls back to tree |
| `glide.ui.max_relation_levels` | 5 | maximum levels in flat view |
| `glide.ecmdb.find_relationship_issues` | true | show the icon linking to open issues |

## Relationship editor

Opened with **+** in Related Items. **From Brazil it is being prepared for deprecation** (hidden and not activated on new instances, still supported); Unified Map is the replacement. Steps in [[Create or Delete a CI Relationship]].

## Domain separation

- `cmdb_rel_ci`, CI Relationship Type (`cmdb_rel_type`) and `cmdb_rel_type_suggest` are **not** domain separated; CIs are.
- Formatter: a relationship shows only if the user's domain can see **both** CIs. All relationship types are offered as filters.
- Editor: the CI picker shows only CIs visible in the domain, but the relationship list shows all relationships of the base CI, and all suggested types.

## Security

Securing relationships needs access controls on `cmdb_rel_ci` **and** an ACL for the operation `edit_ci_relations` on the `*` table. (An older `editCIRelations` definition is converted on upgrade.)

Viewing relationships in the editor depends on the Table API ACL: if it is active, users also need `snc_platform_rest_api_access` ([[Inbound API Authentication and API Access Policies]]).

## Related

- [[CMDB Overview and Class Hierarchy]] · [[Create a CI Relation Rollup]] · [[Baseline CMDB]]
