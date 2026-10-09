---
type: concept
tags: [concept, cmdb, schema, discovery, data-integrity]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB Identification and Reconciliation (IRE) > Configure, topics "CMDB dependent relationship rules" and "Create dependent relationship rules" (class rule, containment rule collection, hosting rule collection) (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/c_CMDBIdentifyandReconcile.html), read through the docs site API 2026-10-09
sn-release: Brazil
verified:
updated: 2026-10-09
---

# CMDB Dependent Relationship Rules - Hosting and Containment

**In one line:** hosting and containment rules declare which class may run on, or be contained by, which other class. [[Identification and Reconciliation Engine (IRE) Overview|IRE]] uses them to identify dependent CIs in the right order, and Service Mapping uses them to build service maps.

Dependent classes: [[CI Classes, Dependency and Principal Class]]. Which rules exist in a base system depends on the active plugins.

## The three rule kinds

| Kind | Table | Says | Shape |
|---|---|---|---|
| **Hosting** | `cmdb_metadata_hosting` (CMDB Metadata Hosting Rules) | what a CI runs on: *Application Runs on::Runs Hardware* | flat, one level, always involves a resource (physical or virtual hardware). Creating a rule also creates its reverse |
| **Containment** | `cmdb_metadata_containment` | the configuration hierarchy: *Tomcat Contains::Contained by WAR file* | chained into a group under a top-level (root) class; logical CIs such as software on a server |
| **Reference** | `cmdb_metadata_reference` | valid referencing pairs: *Virtual Machine Provisioned From::Provisioned Image* | flat, used mostly by Cloud Management; both classes can live alone. **Not part of identification** |

- A CI hostable on several resources (Windows, Linux) has one hosting rule per resource; during identification the pair examined must satisfy at least one.
- The same relationship type can appear in a hosting rule and in a containment rule; context decides which it is.
- **Endpoints** are special containment rules marking where data flows in (inbound) or out (outbound) of the service definition. Nothing can be added under an endpoint.

Model example: Tomcat *Runs on* Hardware (hosting); Tomcat *Contains* Configuration File and Tomcat *Contains* WAR (containment); WAR has inbound and outbound JDBC endpoints.

## Constraints

- A class that is a **child in a containment rule** (and its children) cannot be the root of another containment group, and cannot be in any hosting rule.
- A class that is the **root of a containment group** cannot be a child in a hosting rule (nothing can be "hosted on Tomcat" if Tomcat has containment rules).
- A class that is a **child in a hosting rule** cannot be in any containment rule.
- A class that is a **parent in a hosting rule** cannot be a child in a containment rule.
- Hosting rules cannot loop (Tomcat runs on VMware runs on Tomcat).

The Metadata Editor only offers choices that respect these.

## Where to manage

| Tool | Path | For | Roles |
|---|---|---|---|
| CI Class Manager | class > **Dependent Relationships** > **Add dependency** | one basic rule for a class | read `sn_cmdb_editor`, `itil`; write `sn_cmdb_admin`, `itil_admin` |
| Metadata Editor | **Configuration > Identification/Reconciliation > Metadata Editor** | groups of rules, endpoints | `sn_cmdb_admin` or `admin` |

The two are synchronised.

**In CI Class Manager** (the class must have a dependent identification rule): **Rule Type** (hosting or containment), **This Class**, **Relationship**, **Target Class** (parent or child according to the relationship) > **Save**. **Reset to derived** deletes the rules added on this class, leaving only inherited ones.

**Containment group in the Metadata Editor:** tab **Containment Rules** > **Add New Rule** (a new root) or the green **+** on an existing rule (a child): **Configuration Item Type**, **Relationship Type**, **Reverse Relationship Direction**, **Always include in Service Model** (show CIs of this class on the service map whenever their container is on it) > **Create**. Endpoint: blue **+** on a child rule > **Endpoint Type**, **Inbound or Outbound**.

**Hosting rules:** tab **Hosting Rules** > **Add New Rule** or green **+**: **Configuration Item Type**, **Relationship Type**, **Reverse Relationship Direction** > **Create**.

## Related

- [[CI Relationships]] (relationship governance) · [[IRE Identification Rules]] · [[CMDB CI Class Models App]]
