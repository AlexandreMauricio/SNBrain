---
type: concept
tags: [concept, integrations, roles, data-management, release-specific]
status: documented
source: ServiceNow Brazil docs, Workflow Data Fabric > Zero Copy Connector for ERP (overview, Exploring: models, content packs, remote and extraction tables, ERP systems; Configuring: requirements start, Roles; Using overview) and ERP Semantic Mining (overview, Explore, Configure, Roles, Use, Reference), read at overview depth 2026-10-30. Connection setup per system and method, extraction, flows and remaining reference pages (about 130 topics) listed, not read in detail. https://www.servicenow.com/docs/r/integrate-applications/create-integrations-applications.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Zero Copy Connector for ERP

**In one line:** read, update and create ERP data from the instance through **models**, so apps and flows use SAP or similar systems without building each integration by hand.

From the Brazil docs; not tested. Scoped application, previously named **ERP Data Hub** and **ERP Canvas**. Related but separate from [[Zero Copy Connectors]].

Supported: SAP ECC, SAP S/4HANA, SAP S/4HANA Cloud, SuccessFactors, Workday, Oracle E-Business Suite.

## Connections

An **ERP system** record holds where and how to connect, through a connection and credential alias; several per instance, licence permitting, each pinged for health. The docs say basic authentication, while the OData section has an OAuth authorization code page and SAP has SNC: unconfirmed variants, probably per method.

- **MID Server:** not needed for cloud solutions such as S/4HANA Cloud or SuccessFactors. Otherwise it needs `sn_erp_integration.erp_mid_server` on the `mid_user` account.
- **SAP JCo:** records `SAP Jco Dll` (Windows, `sapjco3.dll`) and `SAP Jco so` (Linux, `libsapjco3.so`) under **All > MID Server > JAR Files**. The MID Server restarts several times.
- SAP account needs `S_RFC` activity 16 on function modules such as `RFCPING`, `RFC_READ_TABLE`, `RFC_METADATA_GET`.

## Models

A model defines tables, fields, operations and joins for one ERP system, with at most **one read, one update and one create** operation. Each operation uses a method: table read, BAPI, RFC, OData, IDoc or REST. Fields left out of the mapping never reach the instance tables.

- **ERP models** follow the ERP structure.
- **Platform models** map to existing ServiceNow tables.
- **Content packs** (Store): Enterprise Data Foundation, Quote to Cash, Source to Settle, Hire to Retire. Clone a model into your own scope.

Models feed Workflow Studio flows, playbooks, ServiceNow Studio, Table Builder, UI Builder and Workspace Builder.

## Getting the data

| | Remote table | Extraction table |
|---|---|---|
| When | on request, live | scheduled, such as daily |
| Volume | small, lookups | large, reporting |
| Storage | memory only, see [[Remote Tables]] | temporary transform table, then a Glide table through import sets |

The docs say the product **does not replicate data** into the platform, yet extraction tables store it persistently on the instance. Treat the claim as true for remote tables only until tested.

## Roles

Always assign with the scope.

| Role | Can |
|---|---|
| `sn_erp_integration.erp_admin` | application setup; contains `erp_user` |
| `sn_erp_integration.erp_user` | read all remote tables; the only role needed to read in production |
| `sn_erp_integration.etl_user` | trigger the ETL process |
| `sn_erp_integration.erp_ai_user` | generative AI, see [[Zero Copy Connectors]] |
| `sn_erp_integration.erp_data_pill` | tables needed for Financial Services Remote Tables requests |
| `sn_erp_integration.erp_mid_server` | MID Server sends attachments back |

Data model roles follow `sn_erp_integration.sap_<area>_user`: `company_code`, `country`, `currency`, `customer_invoice`, `distribution_channel`, `division`, `language`, `material_stock`, `purchase_document`, `purchasing_organization`, `sales_customer`, `sales_delivery`, `sales_document`, `sales_organization`, `sales_revenue_recognition`, `table_metadata`, `transport`, `vendor_invoice`, `vendor`.

## ERP Semantic Mining

Formerly **ERP Customization Mining**. Scans ERP custom code for **replatforming** candidates and scores them; high potential means existing tables already match. Needs this connector with connections and models first; good candidates tend to be small.

**From Zurich it is being prepared for future deprecation:** hidden and not activated on new instances, still supported.

Domain separation unsupported. Roles `sn_erp_mining.erp_admin`, `sn_erp_mining.erp_user`. Table `sn_erp_mining_app_candidate`.

## Example

Model *Example Vendor* connects to *Example ERP System*: a BAPI read, OData update and BAPI create. Remote table *Example Vendor Lookup* gives live status; extraction table *Example Open Orders* loads daily for reporting.

## Related

- [[Zero Copy Connectors]] · [[Remote Tables]] · [[Scheduled and Concurrent Imports]] · [[Workflow Data Fabric and Connect Hub]]
