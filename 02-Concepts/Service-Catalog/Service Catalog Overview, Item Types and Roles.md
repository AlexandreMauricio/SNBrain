---
type: concept
tags: [concept, service-catalog, request, roles]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog, topics "Service Catalog", "Exploring Service Catalog", "Types of catalog items", "Service Catalog items", "Service Catalog for managers and end users", "Service Catalog request screens", "Service Catalog terms and roles", "Service Catalog scoping", "Tables provided with multiple service catalogs", "Set up a service catalog", "Service Catalog customization", "Customization vs configuration", "Installed with Service Catalog", https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/service-catalog.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# Service Catalog overview, item types and roles

**In one line:** the Service Catalog is the self-service shop of the platform: catalogs hold categories, categories hold items, and ordering an item starts a request that a fulfilment process works through.

## Building blocks

| Thing | Table | Notes |
|---|---|---|
| **Catalog** | `sc_catalog` | one or more per instance (IT, HR, Facilities...). Read access is an ACL on `sc_catalog`. See [[Catalogs, Categories and the Catalog Home Page]] |
| **Category** | `sc_category` | groups items; can have a parent category |
| **Catalog item** | `sc_cat_item` and its extensions | anything orderable on its own (a laptop yes, its screen no). See [[sc_cat_item]] |
| **Variable** (question) | `item_option_new` | the questions on the item form. See [[Catalog Variables and Variable Types]] |
| **Variable set** | `item_option_new_set` (name from general knowledge, not from this chapter) | reusable group of variables. See [[Variable Sets and Multi-Row Variable Sets]] |
| Item to catalog / category links | `sc_cat_item_catalog`, `sc_cat_item_category` | an item can sit in several catalogs and categories |
| Catalog to site / portal page | `sc_catalog_site`, `sc_catalog_view_mtom` | CMS-era links, see the home page note |

Ordering creates a Request (`sc_request`), one Requested Item (`sc_req_item`) per item line and Catalog Tasks (`sc_task`): see [[Request Management Data Model and Process]].

## Item types (class names)

| Type | Class | What it does |
|---|---|---|
| Standard catalog item | `sc_cat_item` | a good or service; produces a RITM |
| Record producer | `sc_cat_item_producer` | creates a record in another table (incident, HR case...) instead of a RITM. See [[Record Producers]] |
| Order guide | `sc_cat_item_guide` | one form that orders several items as one request. See [[Order Guides]] |
| Content item | `sc_cat_item_content` | gives information (KB article, HTML block, external URL), orders nothing |
| Wizard launcher | `sc_cat_item_wizard` | starts a wizard. See [[Service Catalog Wizards]] |
| Service (subscribe) | `sc_cat_item_service`, `sc_cat_item_subscribe` (service offering) | appear in the default property lists and in [[Service Catalog and CSDM]] |
| Product model items | `pc_hardware_cat_item`, `pc_software_cat_item` | created when models are published from the Product Catalog |

Order guides, record producers and wizard launchers are by default **not** added to the cart, have no **Try It** action and cannot be added to an existing request. Those defaults live in properties listing class names (`glide.sc.item.cannot_add_to_request`, `glide.sc.item.cannot_try_it`, `glide.sc.item.not_normal_cart_item`): see [[Service Catalog Properties Reference]].

## Roles

| Role | Can do |
|---|---|
| `admin` | everything, including scripting (UI macros, business rules) |
| `catalog_admin` | manage catalogs, categories, items, variables, user criteria; not admin-only scripting |
| `catalog_manager` | edit **their** catalog (one manager per catalog), its categories and items; assign editors and a new manager |
| `catalog_editor` | edit **their** catalog, categories and items; assign other editors, not the manager |
| `catalog_builder_editor` | build items in [[Catalog Builder]] from templates they can use |
| `catalog_builder_developer` | contains `catalog_builder_editor`; adds client scripts, variable attributes, advanced and dynamic reference qualifiers, scripted defaults and availability in Catalog Builder, and can build without a template (`glide.sc.builder.allow_create_from_scratch`, default true) |
| `catalog_lookup_admin`, `catalog_lookup_manager` | catalog data lookup definitions (admin: create/edit; manager: read) |
| `catalog_view_masked` | fulfiller who may reveal masked variable values in the variable editor |
| `wizard_admin` | build catalog wizards |

Managers and editors are set per catalog on the catalog record (**Manager**, **Editors**). See also [[Base System Roles]] (says `catalog_admin` contains `catalog`, `user_criteria_admin`, `catalog_builder_editor`, `catalog_template_editor`, `catalog_lookup_admin`).

Older terms still used on forms: **Execution plan** (formerly delivery plan), **execution plan task**, **fulfillment group** (a group of type `catalog` with roles `catalog` and `itil`). See [[Catalog Fulfilment - Flows, Workflows and Execution Plans]].

## Scope rules

- A catalog can hold categories from other scopes; a category must be in the same scope as its parent category.
- An item can use categories and variable sets from other scopes.
- Variables, catalog UI policies, catalog client scripts and catalog data lookups must be in the **same scope as the item or variable set** they belong to.
- An order guide rule base can include items from other scopes.
- A record producer must be in the same scope as its target table (or the table must allow create from other scopes).

## Do not touch

No updates, directly or by business rule, on the internal tables `sc_item_option` (Options), `sc_item_option_mtom` (Variable Ownership), `question_answer` (Question Answer), `sc_item_produced_record` (Item Produced Record), `sc_multi_row_question_answer` (Multi Row Question Answer).

## Customisation versus configuration

The chapter repeats the general guidance: configure first, customise only to extend the original purpose of an app, own any code you add, document and test it (ATF), use scoped apps for new work, and expect customised records to be skipped at upgrade. See [[Skipped Records in Upgrades]] and [[Update Sets]].

## Installed with the plugin

Script include `DemoSCCreateItem` (demonstrates the scoped Service Catalog API).

## Release notes

- Several pages still refer to Classic Mobile (deprecated 2022), CMS (use Service Portal instead) and "Fuji" (user criteria introduction). Kept in [[Catalogs, Categories and the Catalog Home Page]] for upgraded instances.

## Related

- [[Request Management Data Model and Process]] · [[Service Catalog Properties Reference]] · [[Catalog Item, Record Producer and Order Guide Forms]] · [[User Criteria and Catalog Access]] · [[Domain Separation in Service Catalog]]
