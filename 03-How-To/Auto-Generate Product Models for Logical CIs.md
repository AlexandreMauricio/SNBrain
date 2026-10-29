---
type: how-to
tags: [how-to, cmdb, assets]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CSDM > Reference > Foundation tab on the dashboard > Auto-generate product models for logical CIs (read 2026-10-29). https://www.servicenow.com/docs/r/servicenow-platform/common-service-data-model-csdm/csdm-auto-create-prod-model-for-ci.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Auto-Generate Product Models for Logical CIs

**Goal:** give every logical CSDM CI (offerings, services, service instances, business applications) a product model in **Model ID** (`model_id`), since Discovery never sets one for them.
**Prerequisites:** role `admin`. The job runs with the access rules of the admin who runs it.
**Navigation:** **Configuration > CI Class Manager**; **System Scheduler > Scheduled Jobs > Scheduled Jobs** > *CSDM Product Model Assignment*.

## Steps

1. For each supported class (Service Offering, Technology Management Service, Service Instance, Business Service, Business Application): **CI Class Manager** > **Open Hierarchy** > class > **Basic Info** > set **Default Product Model** (the name used when the CI lacks the name or version needed).
2. Open the scheduled job **CSDM Product Model Assignment** > **Execute Now**. It calls the script `CSDMModelUtil` (record type not stated; probably a script include, unconfirmed).
3. For each CI with no model, the script creates an application, service or software model named after the CI (service instances get the business application version appended, e.g. *Example App Service - version: 2.1*), or reuses an identical existing model, and writes it into **Model ID**.
4. Review under **Product Catalog > Product Models > Application Models / Service Models / Software Models**.
5. Run again whenever new logical CIs appear.

## Result / how to check it worked

CSDM Data Foundations dashboard, Foundation tab: *Named Product Models without Product Owners* now counts the new models (give them owners). CIs of the five classes have **Model ID** filled.

## Example

Service instance *Example Payroll - Prod* has no model. Set Default Product Model *Example Default Service Model* on the Service Instance class, run the job, then open the CI and check Model ID points to a new software model *Example Payroll - Prod - version: <n>*.

## Tables / fields involved

- `cmdb_model` children (`cmdb_application_product_model`, `cmdb_service_product_model`, `cmdb_software_product_model`), [[cmdb_ci]] **Model ID** (`model_id`), `service_offering`, `cmdb_ci_service_technical`, `cmdb_ci_service_auto`, `cmdb_ci_service_business`, `cmdb_ci_business_app`.

## Gotchas

- CIs with **identical names** (a data error per the docs) may end up sharing or conflicting models: check the results.
- Users who can read the modified CIs can see the new models.
- See [[Models, Model Categories and the Product Catalog]] for models in general.
