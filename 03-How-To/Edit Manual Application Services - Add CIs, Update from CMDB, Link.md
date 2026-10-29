---
type: how-to
tags: [how-to, cmdb, discovery]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Service instances > Manually add CIs, Manually update an application service with changes from the CMDB, Link application services (read 2026-10-29). https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/manually-add-ci-to-business-service.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Edit Manual Application Services - Add CIs, Update from CMDB, Link

**Goal:** keep a manually created (or discovered) service instance complete: add CIs from the map, pull in CMDB changes, and link other services as contained services.
**Prerequisites:** `app_service_admin` or `service_mapping_admin` (update from CMDB: `app_service_admin`). The CIs exist in the CMDB with a CI type. Tag-based and dynamic services **cannot** be edited from the map.
**Navigation:** **All > CSDM > Manage Technology Management Services > Service Instance** > service > **View Map** > **Edit**.

## Steps

**Add a CI**
1. On the map, right-click the CI to connect to > **Add a CI**.
2. **CI Type** (only allowed classes) and **CI Name** > **Submit**. The connection uses `sa.it_service.manual_ci_rel_type` (default Depends on::Used by). A child application added under its parent application sits inside the parent's inclusion box (+).
3. Optional with Service Mapping: right-click the new CI > **Manually add a connection**, fill the entry point attributes > **Submit**; Service Mapping tries to discover it (warning icon if not). Missing menu option = your user is not in the service's domain.
4. When a pattern later discovers the CI (**Run discovery**, two connectors appear), right-click > **Remove manually added CI**.

**Update from the CMDB** (manual services only; no automatic mechanism exists)
1. Open the service > **Advanced** > **Advanced Configurations** > **Additional Info** > related link **Update with changes from CMDB**.
2. **Up to** = levels > **OK**. A higher number adds missing CIs; a lower number never removes CIs.

**Link a service** (contained service)
1. **Service Mapping > Application Services** > **View map** > **Edit**.
2. Right-click the CI that calls the other service > **Add A CI** > **CI Type** = Tag-Based Application Service, Mapped Application Service, Calculated Application Service or Dynamic CI Group > **CI Name** = the service > **Submit**.

## Result / how to check it worked

The CI or contained-service icon appears on the map. The containing (dependent) service shows the contained service's discovery errors in Edit mode and its alerts in Event Management.

## Example

Service *Example Online Store*: add CI *EXAMPLE-MQ-01* (class Application) under its web listener; then link service *Example Customer Portal* under the store's load balancer. Check both appear and that removing the link removes it everywhere it was added.

## Tables / fields involved

- `cmdb_ci_service_discovered`, [[cmdb_rel_ci]], `sa_m2m_service_entry_point`, `svc_manual_ci_exclusions_inclusions`.

## Gotchas

- **Changes spread "by analogy":** adding a CI (or a contained service) to a CI that other services share also adds it to those services; removing it removes it from all of them.
- Only real CMDB CIs can be connected, not clusters or boundaries drawn on the map.
- Update from CMDB stops at `sa.service.max_ci_service_population` (1,000 connections) and does not expand under classes in `sa.service.population.stop_expansion_under_ci_classes`.
- Domain separation: only CIs in the service's domain (same child domain) are added.
