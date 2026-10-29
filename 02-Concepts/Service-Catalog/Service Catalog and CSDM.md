---
type: concept
tags: [concept, service-catalog, cmdb]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog > Configuring, topics "Service Catalog and CSDM", "Service Catalog and CSDM tables", "Service Catalog use case", "Service Catalog considerations", https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/request-cat-use-case-product-view.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Service Catalog and CSDM

**In one line:** in the Common Service Data Model the catalog is the **Sell/Consume** layer: each catalog item should hang off one **service offering**, and product models published from the Product Catalog become catalog items.

## Tables

- Managed by the catalog: business services in Sell/Consume (technical services seen from Event Management in Operate); hardware and software model items `pc_hardware_cat_item`, `pc_software_cat_item` feeding asset management.
- Used by the catalog: CI tables (`cmdb_ci*`), Service Offering (`sc_cat_item_subscribe`, per this page), Application Service (`cmdb_ci_service_discovered`), Product Model tables (`cmdb_model`).
- Old item-to-CMDB access links (`sc_cat_item_user_mtom`, `_group_`, `_dept_`, `_location_`, `_company_` and their `_no_mtom` partners) are no longer supported: use user criteria.

## Request catalog versus Product catalog

- **Request Catalog**: orderable business and technical products, services and offerings.
- **Product Catalog**: model information (a model = a version or configuration of an asset). Models published there are published to the Service Catalog automatically; a model sold by several vendors can appear more than once. See [[Models, Model Categories and the Product Catalog]].

## Who benefits

Service Portfolio Management (items tied to offerings, maintained by service owners: [[Service Portfolio Management]]), Hardware and Software Asset Management (ordering and tracking assets), HR and CSM (their record producers shown in portal, mobile and Virtual Agent). Digital Portfolio Management navigates services, offerings and items with CSDM roll-ups ([[Digital Portfolio Management]]).

## Considerations

Catalog item tabs map to the model: Item Details, Process Engine, Picture, Pricing, Portal Settings. Catalog types can mirror the types of products and services offered; product catalogs can be split per product type.

## Related

- [[Service Offerings, Commitments and Availability]] · [[Service Catalog Overview, Item Types and Roles]]
