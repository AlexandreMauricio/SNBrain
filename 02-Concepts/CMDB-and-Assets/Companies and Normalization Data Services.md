---
type: concept
tags: [concept, cmdb, assets, users, data-integrity, release-specific]
status: documented
source: ServiceNow Australia Platform Administration PDF, "User administration", topics "Add a new company", "Normalization data services", "Add a department" (pp. 355-363), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Companies and Normalization Data Services

**In one line:** Company (`core_company`) records categorise users, groups and assets as vendors, manufacturers or customers; the Normalization Data Services plugin replaces the many spellings of a company name with one normalized name, using mappings downloaded from ServiceNow.

## Companies and departments

- **User Administration > Companies** (role `user_admin` or admin). Fields: Name, Phone, **Manufacturer**, **Vendor**, stock symbol and price, address, Notes. Latitude and Longitude (add to the form) are filled by the business rule `get_lat_long`; deactivate it to keep manual values.
- **User Administration > Departments** (`cmn_department`): name, ID, description, company, department head, primary contact.

## Normalization Data Services

- Plugin `com.glide.data_services_canonicalization.client`. **Not for on-premise instances** (needs an internet connection to download mappings). Role `nds_admin`.
- Vocabulary: **normalized name** = the standard name; **discovered name** = a variant.
- Tables: Normalized Company Names (`cds_client_name`) and Normalized Mappings (`cds_client_mapping`), e.g. "Dell", "DELL", "Dell (UK)" all map to "Dell Inc.".
- Unlike [[Field Normalization and Transformation|field normalization]], no mappings need building by hand, though your own can be added.
- It adds a **unique hash on `core_company`**: only one company record per name (per domain on domain-separated instances). Discovery relies on this.

Guided setup (**Normalization Data Services > Guided Setup**): activate the plugin, download the normalized data, update reference qualifiers so company reference fields only offer normalized names, activate the properties, then normalize the CMDB, CMDB model and Software Asset Management tables.

Properties on the normalization properties form: use the Normalized field in all company reference qualifiers; normalize manufacturer names on CI insert and update outside Discovery; let Discovery use the service; enable or disable the process; *Normalize existing canonical core_company records*.

## Gotchas

- **Editing a field whose value is a normalized name changes it for every discovered name mapped to it**, wherever you edit it. The preferred place to change a name is **Normalized name** in Normalized Mappings; **Promote discovered name** swaps a variant in as the standard.
- Duplicate names in tables extending `core_company` (e.g. Customer Account, `customer_account`): `glide.cmdb.canonical.use_base_core_company_only` = true restricts the uniqueness check to the base table. On by default from Australia; on upgrades from Zurich or earlier, run the script include `ClearNonCoreCompanyExtensionsFix` first, add the property, then re-normalize.

## Related

- [[Users, Groups and Roles Overview]] · [[Field Normalization and Transformation]]
