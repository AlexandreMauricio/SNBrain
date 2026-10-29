---
type: how-to
tags: [how-to, cmdb, data-management]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Service instances > Convert business services to application services (bulk and individual), Convert legacy manual services to dynamic application services (read 2026-10-29). https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/convert-bus-to-app-svc-intro.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Convert Business or Manual Services to Application Services

**Goal:** turn legacy services in **Service** (`cmdb_ci_service`) or **Manual Service** (`cmdb_ci_service_manual`, from Event Management) into application services, to align with CSDM and get maps, change history and health monitoring.
**Prerequisites:** `app_service_admin` (individual and manual-to-dynamic); bulk also allows `ecmdb_admin`, `sn_cmdb_admin`, `itil_admin`. Review the service first: relevant relations only, **fewer than 5,000 CI relations**.
**Navigation:** **All > Configuration > Services** (bulk), **All > Configuration > Business Services** (individual), **All > Configuration > Application Services > Application Services** (manual to dynamic).

**Irreversible.** A converted service cannot go back to a business service or legacy manual service (a dynamic application service can be turned into a manual one).

## Steps

**Bulk (business services)**
1. **Configuration > Services**, select the services (typically up to 100 per run; never put one service in two runs).
2. **Actions on selected rows** > **Bulk Convert Application Services**.
3. Form: Name (pre-filled *Application Service Conversion: <time stamp>*), **Select configuration items**, **Levels**, **Update service when CMDB updates** (ticked = dynamic type) > **Start Conversion**.
4. Track in the **Bulk Convert Services Entries** section or `cmdb_convert_bulk_services.list`.

**One business service**
1. **Configuration > Business Services** > open it > **Convert to Application Service**.
2. **Up to** = levels of related CIs (max **eight**); tick **Update service when CMDB updates** for dynamic > **OK**.

**Legacy manual service to dynamic**
1. **Configuration > Application Services > Application Services**, list view set to **Default view**.
2. Open the manual service > related link **Convert to Dynamic Service**. Three levels of related items by default.

## Result / how to check it worked

The record changes class to `cmdb_ci_service_calculated` (all three conversions per the docs; the overview page instead says business services become the manual type in `cmdb_ci_service_discovered` — unconfirmed which applies, perhaps depending on the dynamic check box). Attributes (name, owner, operational status) are kept; population method shows **Converted Business Service**. Open the map: if it does not draw, the service is too large — remove irrelevant relations in the CMDB or convert with fewer levels.

Optional check in Change: on a change request add an affected CI, **Refresh Impacted Services**, and see the dynamic service under **Impacted Services/CIs**.

## Example

Business service *Example Intranet* with 40 relations: convert individually, Up to 3, Update service when CMDB updates ticked. Then add a relationship from one of its servers to a new database CI *EXAMPLE-DB-02* and confirm the database appears in the service.

## Tables / fields involved

- `cmdb_ci_service`, `cmdb_ci_service_manual`, `cmdb_ci_service_calculated`, `cmdb_ci_service_discovered`, `cmdb_convert_bulk_services`, `svc_manual_ci_exclusions_inclusions`, [[cmdb_rel_ci]].

## Gotchas

- Excluded classes (NAT, Endpoint, Qualifier, Application cluster) and connections from them are dropped.
- Converted services are manual, so Discovery does not run on them until you add entry points discoverable by Service Mapping.
- Domain separation: only CIs in the service's (child) domain are added.
- Dynamic services cannot be edited from the map: a removed CI comes back on recalculation; change the relationships instead.
- Manual-service conversion and update-from-CMDB stop at `sa.service.max_ci_service_population` (1,000) connections.
