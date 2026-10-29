---
type: concept
tags: [concept, cmdb, schema, data-integrity]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CSDM (60 topics, 2,713 cleaned lines, read in full through the docs site API 2026-10-29) - landing page, Explore (products that benefit, data domains, Foundation, Ideation and Strategy, Design and Planning, Build and Integration, Service Delivery, Service Consumption, Manage Portfolio), Implement (Foundation, Crawl, Walk, Run, Fly stages; dynamic CI groups by service type), Navigate, Apply CSDM guidelines (product views list only; the product pages live in other guides), Reference (terms, mapping to CMDB tables, CI relationships, resources). https://www.servicenow.com/docs/r/servicenow-platform/common-service-data-model-csdm/csdm-landing-page.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# CSDM Overview and Data Domains

**In one line:** the Common Service Data Model (CSDM) is ServiceNow's prescribed data model for the CMDB: which class table each kind of thing goes in (business application, service instance, technology management service, offering...) and which relationships connect them, so every product reads the same data the same way.

From the Brazil docs (CSDM version 5 naming). Everything here is `documented`, not tested. Life cycle values are in [[CSDM Life Cycle Stages and Synchronization]] and [[CSDM Life Cycle Values Reference]]; the scoring dashboard in [[CMDB and CSDM Data Foundations Dashboards]].

## Principles (summarised)

Keep concepts simple and avoid duplicate sources; design for reporting; use only the relationships the model prescribes; share base-system tables across products instead of building custom ones; use agreed definitions; integrate external data with the prescribed technologies (IRE-based, see [[Identification and Reconciliation Engine (IRE) Overview]]); govern the data, because data without process has little value.

## Data domains

Every box of the model is a CMDB class table except Catalog Item; every line is a CI relationship.

| Domain | What lives there | Operational? (selectable on incident, problem, change) |
|---|---|---|
| **Foundation** | referential data: company, business unit, department, location, groups, users, product models, contracts, business processes, value streams, CMDB groups, SBOMs, life cycle values | not CIs (mostly); not used in relationships |
| **Ideation & Strategy** | Planning Item (`sn_align_core_planning_item`), Product Idea (`sn_align_core_product_idea`); Strategic Portfolio Management | no |
| **Design & Planning** | Business Capability (`cmdb_ci_business_capability`), Business Application (`cmdb_ci_business_app`), Information Object (`cmdb_ci_information_object`); used by APM | no |
| **Build & Integration** | Agile Development Component (`cmdb_ci_sdlc_component`, CMDB schema 1.33+), AI System Digital Asset; used by DevOps | no |
| **Service Delivery** | Technology management service (`cmdb_ci_service_technical`), Technology management offering (`service_offering`), Dynamic CI group (`cmdb_ci_query_based_service`), Service instance (`cmdb_ci_service_auto` and children), applications (`cmdb_ci_appl`), infrastructure CIs, API and AI function/application CIs | **yes** |
| **Service Consumption** | Business service (`cmdb_ci_service_business`), Business service offering (`service_offering`), catalogs (`sc_catalog`) and catalog items, service portfolio | **yes** (services and offerings) |
| **Manage Portfolio** | a layer over all domains: the service owner's view across business applications and their deployed instances | - |

## Service types

| Service type (label since CSDM 5) | Table | Service Classification | Rules |
|---|---|---|---|
| **Business service** | `cmdb_ci_service_business` (extends `cmdb_ci_service`) | Business Service | consumer- or seller-focused, published to business users, **one level only** (no hierarchy), used for impact and change approvals |
| **Technology management service** (was Technical service) | `cmdb_ci_service_technical` | Technical Service | provider-focused, published to service owners, one level only, used for impact and change approvals |
| **Service instance** (was Application service) | `cmdb_ci_service_auto` | Application Service | a deployed application stack; one per environment and region; logical CI using the logical life cycle |
| Business / Technology management **offering** | `service_offering` | Business or Technical Service | stratifies a service by location, environment, price, availability, support group (incident), approval group (change), packaging (commitments). Every operational service should have **at least one offering** |

Business services used to live only in `cmdb_ci_service`; the docs say both tables "operate identically" for now and business services may later all move to `cmdb_ci_service_business`. Both services connect to `spm_service_portfolio` through `spm_taxonomy_node` ([[Service Portfolio Management]]).

**Service instance tables by creation method** (all extend `cmdb_ci_service_auto`):

| Method | Table |
|---|---|
| Top-down Service Mapping, or manual entry in the *Create a Service Instance* form | Mapped Application Service `cmdb_ci_service_discovered` |
| Dynamic CI Group (query-based) | `cmdb_ci_query_based_service` |
| Tags | see variants below |
| Dynamic Service (follows `cmdb_rel_ci`) | Calculated Application Service `cmdb_ci_service_calculated` (from the Service instances chapter) |

Details, methods and roles: [[Service Instances (Application Services)]].

New service instance subclasses in CSDM 5: Data (`cmdb_ci_data_service_instance`), Network (`cmdb_ci_network_service_instance`), Operational Process (`cmdb_ci_operational_process_service_instance`), Connection (`cmdb_ci_connection_service_instance`), Facility (`cmdb_ci_facility_service_instance`). Application services still exist and are still created with the application service wizard.

## Prescribed relationships

| From | Relationship (parent::child) | To |
|---|---|---|
| Business capability | Provided By::Provides | Business application; Business service |
| Business application | Uses::Used By | Information object |
| Business application | Contains::Contained By | Agile development component (optional) |
| Business application | **Consumes::Consumed By** or **Uses::Used By** (see variants) | Service instance (application service only) |
| Agile development component | Contains::Contained By | Service instance (optional) |
| Service instance | Depends on::Used by, Sends Data To | Service instance |
| Service instance | Depends on::Used by | Application |
| Application | Runs on::Runs | Infrastructure CIs |
| Technology management offering | Contains::Contained by | Service instance; Dynamic CI group |
| Business service offering | Depends on::Used by | Service instance |
| Technology management service → offering, Business service → offering, Service portfolio → Business service | reference attributes, not relationships | |

Dynamic CI group members are listed in a related list, not as relationships. Relationships created by Discovery and Service Mapping are the standard for infrastructure; if you map by hand, copy what Discovery would have produced ([[CI Relationships]]).

## Key distinctions

- **Application (`cmdb_ci_appl`) is not the application inventory.** It holds discovered running code on one host; Discovery maintains it, do not fill it by hand. The portfolio belongs in Business Application. One application can serve several service instances and vice versa.
- **Business application** is manually maintained (form or import with a transform map), spans environments and regions, and should be related to every service instance it runs as (for example one production instance per store).
- **Business capability** hierarchy: up to **six levels** (1.0 parent, 2.0 to 6.0 below); use the **Update Capability Level and HierarchyID** related link after changes; only leaf capabilities can be deleted; no circular parents.
- **Information object** records the kinds of data an application uses (PII, PCI DSS, HIPAA). The Fly-stage information portfolio also counts Data Domain (`sn_apm_data_domain`), Database Instance (`cmdb_ci_db_instance`) and Database Catalog (`cmdb_ci_db_catalog`).
- **Dynamic CI group** ([[CMDB Groups]]): CIs from a CMDB group query; cannot contain other groups; a CI may be in many groups. Two uses with different impact behaviour:
  - under a **technology management service**: up to 10,000 similar but unrelated CIs (servers of one OS, network gear per site) managed together; no impact analysis expected;
  - as a **service instance**: members depend on each other, any member down means the whole group is impacted; service associations needed.
  - In Change Management a business rule can fill Affected CIs from a dynamic CI group (patching use).
  - A CI associated through a dynamic CI group should belong to only **one** technology management service or offering, otherwise SLAs, support groups and commitments conflict.
- **Product models** (`cmdb_model` and children: application, software, contract, facility, hardware, consumable, service models) are not CIs; CIs point to them through **Model ID** (`model_id`). Logical CIs are not discovered, so give them models with [[Auto-Generate Product Models for Logical CIs]].
- **Location** (`cmn_location`) gained **Source**, **Location type** (Region, County, State/Province, City, Site, Building/Structure, Floor, Room), **Managed by group**, duplicate/primary validation flags, and life cycle fields.
- **Company** (`core_company`): legal entities, flags Customer, Manufacturer, Vendor; internal hierarchy by legal entity, not by business unit. **Business unit** (`business_unit`) references its company; **Department** (`cmn_department`) is finer.

## Implementation stages

Stages build on each other; the [[CMDB and CSDM Data Foundations Dashboards]] CSDM dashboard has one tab per stage.

| Stage | Tables worked on | Gives you |
|---|---|---|
| **Foundation** | business process, contract, product models, CMDB groups, SBOM, location hierarchy, groups, users, company, business unit, department, life cycle tables | clean referential data for reporting |
| **Crawl** | Business Application, Agile Development Component, Service Instance (Mapped Application Service), Application (discovered), servers | minimum CMDB for incident and change, ready for APM, DevOps, Service Mapping entry points, TLM risk |
| **Walk** | Technology management service, technology management offering, dynamic CI groups | support and approval groups synchronised to CIs from the offering ([[Synchronize Support and Managed By Groups for CIs]]), request catalog for technology offerings, ready for ITOM and Service Portfolio Management |
| **Run** | business service portfolio (`service_portfolio`, not a CMDB table), business service, business service offering, request catalog | business impact on incidents and changes, offering subscribers (**Subscribe by** by user, company, location, department, group), DPM service views |
| **Fly** | business capability, information object (may come earlier) | APM rationalisation, catalog items related to offerings |

## Migrating existing data into CSDM tables

Role `admin`. Customised or non-conforming tables keep working but products get less benefit.

1. Back up: export the data with all attributes.
2. Map attributes to the target base table; rationalise custom attributes (**Preferred** / **Keep** / **Refactor** / **Do Not Need**).
3. Find dependencies (reports, business rules, scripts, references) with the community fix script *Migrating into CSDM identifying table dependencies*; it only lists, it moves nothing.
4. Move CIs to the new class (moving a CI's class keeps its related tasks; attributes outside the new hierarchy are **lost**). Start with a few CIs.
5. Fix reports, rules, scripts and references; reload attribute data from the backup; validate.

## Roles named in the model

Enterprise architect / application owner (business applications), portfolio manager / service owner (services, offerings, SLAs, catalog items), service desk and incident / change managers (use the data), application service admins and technical SMEs (underlying technology), CMDB manager and CI analysts (accuracy, certification).

## Menus

**All > CSDM**: Data Foundations Dashboard, Getting Started, **Service Instance Settings** (attributes and relationships required when creating a service instance), **Service instances Dashboard** (was Application Services dashboard before Australia), **Life Cycle Mapping**, Design, Service Delivery, Sell and Consume, Technical Service Offering, group synchronisation.

## Unconfirmed variants (record, do not resolve without a test)

| Topic | Variants in the Brazil docs | Where |
|---|---|---|
| Tag-based service instance table | `cmdb_ci_service_by_tags` / `cmdb_ci_service_tags` | Service Delivery domain page, same page's methods table; the Service instances chapter uses `cmdb_ci_service_by_tags` throughout |
| Business application table | `cmdb_ci_business_app` (most pages) / `cmdb_ci_business_application` (life cycle inheritance text) / "not `cmdb_ci_app`" (mapping page) | several |
| Business application to service instance relationship | Consumes::Consumed By (domain pages, Crawl dashboard metric *App service to business app not Consumed by*) / Uses::Used By ("CSDM v5 implements", CI relationships page, which keeps Consumes for Enterprise Architecture Workspace TLM/TRM timelines) | |
| Which service instances a business application may relate to | "ultimately an Application Service table and not any other type of Service Instance" | Design & Planning, CI relationships |
| Business application's domain | Design & Planning (domain page) / "Service Consumption domain" (Build & Integration page) | |
| Dynamic CI group / Event Management table | `cmdb_ci_query_based_service` / `cmdb_query_based_services` (Walk stage) | |
| CMDB group table | `cmdb_group` (Foundation domain, [[CMDB Groups]]) / `cmdb_ci_query_based_service` (Foundation stage page) | |
| Product model table | `cmdb_model` / "Product model [`model_id`] table" (Foundation stage; `model_id` is the CI field) | |
| Service offering table seen from the catalog | `service_offering` (CSDM) / `sc_cat_item_subscribe` ([[Service Catalog and CSDM]]) | |

## Product views

The docs list CSDM product views (how each product uses the model) for Change, CSM, DPM, Enterprise Architecture, HR Service Delivery, Incident, Install Base Management, ITOM AIOps, ITOM Visibility, Operational Technology, Problem, RPA Hub, Service Catalog ([[Service Catalog and CSDM]]), Service Portfolio Management and Vulnerability Response. These pages sit in their product guides, not in this chapter.

## Related

- [[CMDB Overview and Class Hierarchy]] · [[cmdb_ci_service]] · [[Service Offerings, Commitments and Availability]] · [[Service Portfolio Management]] · [[Digital Portfolio Management]] · [[CMDB Groups]] · [[Models, Model Categories and the Product Catalog]] · [[CSDM Life Cycle Stages and Synchronization]]
