---
type: concept
tags: [concept, integrations, data-management, roles, update-sets]
status: documented
source: ServiceNow Brazil docs, Workflow Data Fabric > Data Products (Explore, Data interfaces, navigation, Configure, Prerequisites, Managing data interfaces, Managing data products, Move to production, Review access requests), read at overview depth 2026-10-30. Wizard steps and use case detail not read in full. https://www.servicenow.com/docs/r/integrate-applications/data-products.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Data Products and Data Interfaces

**In one line:** a **data interface** is a stable schema over one or more source tables, and a **data product** packages interfaces with metadata and access control, so consumers query without knowing the source.

From the Brazil docs; not tested. Application `sn_data_product` (installs [[Data Catalog and Metadata Collectors|Data Catalog]]). Authoring: **All > Workflow Data Fabric > Data Workbench**.

## Data interfaces

Over a ServiceNow table or a Data Fabric table on an external system through a [[Zero Copy Connectors|Zero Copy Connector]], without moving data.

| Method | Use |
|---|---|
| **Single table** | a chosen set of columns |
| **JOIN** | INNER JOIN on a shared key; only matches return |
| **UNION** | rows from compatible schemas |

The method cannot change once the target table is created. **Unique name** is locked after publishing. Editing a published interface does **not notify consumers**.

## Lifecycle

Build > Package > Secure > Publish > Discover > Access > Consume. **Draft** is hidden; **Published** appears in the catalog after the collector runs. **Edit** returns a product to draft.

**Access:** the product has a **parent role** containing each interface's **reader role**; consumers get the parent. Security Administrators validate it.

**To production:** a local update set in the same scope, with connectors configured in production; build in subproduction first.

## Roles

`df_data_steward` (interfaces), `data_product_admin` (products), `data_product_user` (read). Interface pages also list `delegated_developer` and `delegatedadmin`.

## Example

Interface *Example Member Bookings*, JOIN of two Snowflake tables on *member_id*, packaged in product *Example Loyalty Data*, role *Example Loyalty Reader*.

## Related

- [[Workflow Data Fabric and Connect Hub]] · [[Data Catalog and Metadata Collectors]] · [[Zero Copy Connectors]]
