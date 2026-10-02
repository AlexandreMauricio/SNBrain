---
type: concept
tags: [concept, assets, cmdb, service-catalog]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Asset Management common applications > Product Catalog" (pp. 485-510), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Models, model categories and the product catalog

**In one line:** a **model** (`cmdb_model`) describes a kind of thing; its **model category** decides which CI class and which asset class are created for it; publishing a model makes it an orderable **product catalog item** in the service catalog.

Menu **Product Catalog**. Roles `model_manager` (models), `category_manager` (plus model categories); `catalog_admin` publishes.

## Model categories: the asset-CI link

**Product Catalog > Product Model > Model Categories.** Each row pairs a **CI class** with an **Asset class** (Asset, Hardware, Software License, Consumable):

- A CI created in a class whose model category has an asset class gets an asset automatically, linked to it; an asset created in such a category gets a CI.
- Consumable and Software License categories have no CI class.
- **CI class** must be set at creation; **Asset class** can be added later but never changed. Setting it on an existing category creates assets for all its CIs.
- Options: **Allow pre-allocation**, **Allow in bundle**, **Allow as main** (need an asset class), **Enforce CI verification** (no automatic asset; the CI gets **Requires verification** with UI actions **Create Asset** / **Merge CI**; **Create Assets** on the category processes the backlog), **Product model class** (Application, Consumable, Contract, Facility, Hardware, Service, Software).
- The base system has a category for every CI class; create one for each custom `cmdb_ci` class.
- A model can be in several categories and a category has many models.

## Models

**Product Catalog > Product Model** (All, Hardware, Software, Consumable, Application, Bundled Models).

| Field | Notes |
|---|---|
| **Model categories** | glide list (not reportable) |
| **Asset tracking strategy** | *Leave to Category*, *Create Consumable Asset*, *Don't create assets* (overrides the category) |
| **Acquisition method** | Buy, Lease, Both |
| **Cost**, **Depreciation**, **Salvage value**, **Expenditure type** (Capex / Opex) | |
| **Model number**, **Barcode**, **Status** (In Production, Retired, Sold) | |

Hardware models (`cmdb_hardware_product_model`) add physical attributes and the related lists **Compatibles** and **Substitutes** (directional; used by transfer orders, not by procurement sourcing).

**Bundled models**: a model made of components (**Model Components**, one **Is main component**). *Abstract* = category Bundle used as a container; *concrete* = created under Bundled Models with a fixed main asset. Assigning the bundle assigns every child asset; children's state and assignment become read-only. Bundles cannot be pre-allocated; software collections are suites, not bundles.

A model can be deleted only when no asset or CI uses it. Models are **not** captured in update sets: export and import the model XML before importing a catalog item's update set.

## Catalog items

| Table | Label | Extends |
|---|---|---|
| `pc_product_cat_item` | Product Catalog Item | `sc_cat_item` |
| `pc_hardware_cat_item` | Hardware Catalog | product catalog item |
| `pc_software_cat_item` | Software Catalog | product catalog item |
| `pc_vendor_cat_item` | Vendor Catalog Item | |

Cardinality: one model ↔ one product catalog item; one product catalog item ↔ many vendor catalog items; a vendor catalog item belongs to one product catalog item.

- On a model: **Publish to Hardware Catalog** / **Publish to Software Catalog** / **Publish to product catalog** (bundles), choosing a category. Property `glide.model.catalog_item_currency`: false = session currency, true = model currency.
- Vendor items (**Catalog Definition > Vendor Items**): **Vendor**, **Product model**, **Vendor price**, **List price**, **Out of stock**; **Publish** (kept in sync with the model: name, descriptions, price, cost, vendor, specs, model number...) or **Link** (not synced) to a catalog item.
- Product catalog items must be **Activated** separately to appear in the catalog.

## Related

- [[Asset Management Common Applications]] · [[Request Management Data Model and Process]]
