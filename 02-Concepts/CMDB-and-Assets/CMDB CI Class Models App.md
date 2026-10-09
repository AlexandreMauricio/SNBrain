---
type: reference
tags: [reference, cmdb, schema, discovery, integrations]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > Explore > CMDB schema model, topic "CMDB CI class models" and its child topics, one per technology (under https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/explore-cmdb.html), read through the docs site API 2026-10-09. The parent topic and the "Class extensions for integrations" topic were read in full; the per-technology class and column lists were only skimmed and are not transcribed
sn-release: Brazil
verified:
updated: 2026-10-09
---

# CMDB CI Class Models App

**In one line:** a ServiceNow Store app that adds class models on top of the base CMDB hierarchy (classes, descriptions, identification rules, identifier entries, dependent relationships) so that Discovery, Service Mapping and integrations have somewhere to put technology-specific CIs. The added classes behave like base classes. See [[CMDB Overview and Class Hierarchy]].

## Where it writes

| Table | Label | Holds |
|---|---|---|
| `cmdb_class_info` | CMDB Class Information | class descriptions |
| `cmdb_identifier` | Identifier | identification rules |
| `cmdb_identifier_entry` | Identifier Entry | identifier entries |
| `cmdb_metadata_hosting` | CMDB Metadata Hosting Rules | dependent relationships |
| `cmdb_duplicate_lookup_related_allowed_class` | CMDB De-duplication Task Lookup or Related item allowed classes | classes allowed in duplicate detection during lookup-based identification |

It can also change the label of a base class.

## Technology families covered

Each has its own docs topic listing classes, columns and, for some, relationships and related non-CMDB tables. Open the docs when a specific class is needed.

| Family | Matching discovery pattern named by the docs |
|---|---|
| API (classes such as `cmdb_ci_api`), plus "Unmatched API" | |
| Avi load balancer | Avi Vantage load balancer discovery |
| BYOL model of RDS for Oracle | |
| Cassandra | Apache Cassandra database discovery |
| DNS resource records (`cmdb_ci_dns_resource_record`, `cmdb_ci_dns_zone_a_record`, `cmdb_ci_dns_zone_aaaa_record`, `cmdb_ci_dns_zone_cname_record`, `cmdb_ci_dns_zone_alias_record`, `cmdb_ci_dns_domain_info`) | |
| Firewall | |
| IBM Hardware Management Console (HMC) | IBM Virtualization and Hardware Management Console discovery |
| Internet of Things (IoT) | none |
| Kong | |
| Kubernetes | |
| Network Intrusion Detection System (NIDS) | |
| Network Inventory (telecommunications) | |
| Nutanix | Nutanix Acropolis discovery |
| OpenStack | OpenStack resource discovery |
| Operational Technology (OT), including the OT device network connection model and a list of deprecated classes | |
| Red Hat Virtualization (RHV) | Red Hat Virtualization discovery |
| Transport Layer Security (TLS) certificates | procedures from the Certificate Inventory and Management Store app |
| VMware NSX load balancer | VMware NSX Advanced load balancer discovery |

## Class extensions for third-party integrations

Classes and rules the app adds or updates to close gaps met by integration tools. Each also gets a Related Entries (`cmdb_related_entry`) row pointing to `cmdb_key_value` through the field `configuration_item`.

| Class | Name | Extends | Rules |
|---|---|---|---|
| Postgresql Schema | `cmdb_ci_postgresql_schema` | `cmdb_ci_db_catalog` | dependent, identified by `name`; contained by `cmdb_ci_db_postgresql_instance` |
| Information Object | `cmdb_ci_information_object` | `cmdb_ci` | independent, identified by `name` |
| Oracle Catalog | `cmdb_ci_db_ora_catalog` | `cmdb_ci_db_catalog` | related entry only |
| MySQL Catalog | `cmdb_ci_db_mysql_catalog` | `cmdb_ci_db_catalog` | dependent, `name`; contained by `cmdb_ci_db_mysql_instance` |
| MS SQL Database | `cmdb_ci_db_mssql_database` | `cmdb_ci_db_instance` | related entry only |
| Sybase Catalog | `cmdb_ci_db_syb_catalog` | `cmdb_ci_db_catalog` | dependent, `name`; contained by `cmdb_ci_db_syb_instance` |
| DB2 Database (formerly DB2 Catalog) | `cmdb_ci_db_db2_catalog` | `cmdb_ci_db_catalog` | dependent, `name`; contained by `cmdb_ci_db_db2_instance` |

## Check the installation

**Configuration > CI Class Manager** > **Hierarchy**: the added classes (for example the Nutanix ones) appear in the CI Classes list; select one to see its details, identification rule, identifier entries and dependent relationships.

## Gotchas

- **Uninstalling the app can compromise the CMDB** and cause unexpected behaviour.
- Release notes for the app list every class model per version (ServiceNow Store version history).

## Related

- [[CMDB Modelling Guidelines for Hardware, Virtual Machines and Cloud]] · [[cmdb_ci]]
