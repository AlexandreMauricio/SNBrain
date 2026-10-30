---
type: concept
tags: [concept, integrations, data-management, roles, ai]
status: documented
source: ServiceNow Brazil docs, Workflow Data Fabric > Data Catalog (Explore, Configure, metadata collector overviews and deployment models, running, finding, governing, Otto enrichment, glossary, Reference), read at overview depth 2026-10-30. Per-collector setup steps, harvested object tables and prerequisites (71 topics) listed, not read in detail. https://www.servicenow.com/docs/r/integrate-applications/data-catalog.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Data Catalog and Metadata Collectors

**In one line:** the **Data Catalog** is a searchable inventory of data assets across systems: metadata collectors harvest technical metadata, Data Stewards add business context, and consumers evaluate and request access.

From the Brazil docs; not tested. Application `sn_dcg_app`. **AI Search must be enabled.** Open from **Workflow Data Fabric Home**.

**Data asset:** a table, column, view, dashboard, report, database or schema. It holds metadata, not the data itself.

## Metadata collectors

Read-only harvesters, created in Connect Hub (`connection_admin`). States start at **Not configured**, then **Configured** and onward.

**Deployment** (**Use MID server** toggle): a [[MID Server Overview and Architecture|MID Server]] you host for on-premises or private sources, or ServiceNow-managed cloud.

**Sources:** Amazon Redshift, Amazon S3, Azure Data Factory, BigQuery, Databricks, dbt Cloud, Fivetran, Microsoft Fabric, SQL Server, MongoDB, MySQL, Oracle, PostgreSQL, Power BI, SAP HANA, Salesforce, ServiceNow, Snowflake, Tableau, Teradata.

**Runs:** manual or scheduled; runtime logs by severity; email to owner and subscribers under *Collector Run Notification*.

**Vault classification:** with a [[ServiceNow Vault and Otto for Vault|Vault]] entitlement, classify harvested columns on Snowflake, Redshift, Databricks, Oracle, PostgreSQL, Teradata, MySQL, SQL Server, SAP HANA.

## Governing

Stewards add **glossary terms**, **tags**, hierarchical **domains**, and descriptions. Glossary bulk upload is XLSX, within one instance only.

**Otto enrichment:** bulk, asynchronous; nothing changes until a steward publishes. Setup: add `DCGEnrichLauncher` to Global scope; set `bulk_enrich.default_dashboard_sys_id`.

Access requests exist **only for data products and interfaces**. They go to the **Data Catalog approvers** group (needs `approval_user`, `dcg_catalog_readable`); one approval grants the role. Approve at **Self-Service > My Approvals**.

## Roles and properties

| Role | Can | Contains |
|---|---|---|
| `connection_admin` | collectors; **cannot edit assets** per its description, yet inherits the steward role: unconfirmed | `df_data_steward`, `external_app_install_admin`, `agent_admin`, `wdf_operator`, `credential_admin`, `web_service_admin`, `sn_nowassist_wdf.creator_admin` |
| `df_data_steward` | assets, glossary, tags, domains | `sn_nowassist_wdf.creator_admin`, `wdf_consumer` |
| `wdf_consumer` | read, lineage | `sn_nowassist_wdf.creator_admin` |

| Property | Default |
|---|---|
| `sn_dcg_app.dcg.enrichment.batch_size` | 50 |
| `sn_dcg_app.dcg.enrichment.max_lanes` | 10; change only between jobs |
| `sn_dcg_app.dcg.enrichment.deadline_ms` | 270000 |
| `sn_dcg_core.dq.purge_retention_days` | 7 (1 to 90) |

## Example

Collector *Example PostgreSQL Collector* on a MID Server, scheduled daily; glossary term *Example Customer* linked to the harvested table.

## Related

- [[Data Products and Data Interfaces]] · [[Workflow Data Fabric and Connect Hub]]
