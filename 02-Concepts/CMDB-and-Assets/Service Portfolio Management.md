---
type: concept
tags: [concept, cmdb, sla, service-catalog]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Service Portfolio Management" (pp. 3704-3760) and "Service Builder" (pp. 3126-3136), read in full 2026-10-02; form-level detail is in the companion note Re-checked against the Brazil ITSM docs (final chapters), read 2026-10-30.
sn-release: Australia, Brazil
verified:
updated: 2026-10-30
---

# Service Portfolio Management

**In one line:** services (`cmdb_ci_service` and children) are organised in portfolios through a taxonomy of nodes; each service has one or more **service offerings** (`service_offering`) whose **commitments** (availability, SLA, and so on) and **subscriptions** say what level is promised to whom.

Plugins: Core `com.snc.service_portfolio_core` (adds `service_offering`), Foundation `com.snc.service_portfolio`, SLA commitments `com.snc.service_portfolio.sla_commitment`, sample taxonomy `com.snc.spm.content`. Menu **Service Portfolio Management**.

## Tables

| Table | Label / use |
|---|---|
| `cmdb_ci_service` | Service (parent) |
| `cmdb_ci_service_business` | Business Service |
| `cmdb_ci_service_technical` | **Technology Management Service** since Australia (was Technical Service; CSDM 5) |
| `cmdb_ci_service_auto` / `cmdb_ci_service_discovered` | application service (service instance) |
| `service_offering` | Service Offering (extends `cmdb_ci_service`) |
| `spm_service_portfolio`, `spm_taxonomy_node` | portfolio and its nodes (`spm_taxonomy_layer_definition` only in the legacy structure) |
| `service_commitment`, `service_offering_commitment` | commitments and their link to offerings |
| `service_availability` | calculated availability records |
| `service_subscribe_company`, `_department`, `_location`, `_sys_user`, `_sys_user_grp` | who is subscribed to an offering |
| `service_scope`, `service_in_scope`, `service_out_scope` | scope statements |
| `cmdb_rel_team` | several support teams per offering |
| `sc_cat_item_service`, `sc_cat_item_subscribe_mtom` | catalog representation |

**Convert services in bulk** moves records from `cmdb_ci_service` to the business or technology-management child table.

Brazil additions, tables installed with **Service Portfolio Management Premium**: Metric Definition (`spm_metric_definition`, metrics for the application), Portfolio Metric (`spm_portfolio_metric`), SPM Node Weight (`spm_node_weight`, a node's weight against its sibling nodes). Also Service Availability (`service_availability`, calculated availability of a service; open with `service_availability.list`). Sample content plugin: `com.snc.service_portfolio.demo_data`.

## Lifecycle fields

Classic **Phase | Status** maps to CSDM **Life Cycle Stage | Stage Status** (with `com.snc.cmdb.csdm.activation`):

| Phase / Status | CSDM stage / status |
|---|---|
| Pipeline: Requirements, Definition, Analysis, Approved | Ideation / Under evaluation |
| Pipeline: Chartered | Design / Chartered |
| Catalog: Design, Development | Design / Design |
| Catalog: Build/Test/Release | Deploy / Test |
| Catalog: Operational | Operational / In-use |
| Catalog: Retiring | Operational / Pending Retirement |
| Retired: Retired / Obsolete | End of life / Retired / Obsolete |

A service cannot enter the Catalog phase without a portfolio, a taxonomy node and at least one offering, and cannot go back from Catalog to Pipeline.

## Commitments

On a service offering, related list **Service Commitments > New**: **Type**:

| Type | Effect |
|---|---|
| Availability | availability records are generated (a year back, then daily job) and reduced by outages logged against the offering |
| Maintenance Window | needs **Schedule** |
| SLA | results calculated from SLA definitions (**Service Offering SLAs > SLA Results**; `service_offering_sla`) |
| Response Time, Delivery, Other, Recovery time objective, Recovery point objective | informational only |

Availability calculator v2: property `com.snc.availability.v2` (records created at the start of each period and updated as outages change). Time zone: global, or per commitment with `spm.availability.commitment.tz` (**Administration > Availability calculation settings**). Outages are logged with **Log outages**; see [[Task Outages]].

## Portfolio structure

New instances use the **standard** structure (nodes only, any depth; KPI groups in Digital Portfolio Management). Instances from before Utah can opt in once, irreversibly (`standard_portfolio_construct.turn_on`); the legacy structure uses layers, weights and performance scores. **Auto-create service offerings** on a portfolio creates `<service name> Offering1...` for each new service.

## Roles

`portfolio_admin`, `portfolio_editor` (own portfolios), `portfolio_viewer`, `service_admin`, `service_author` (create, edit own), `service_editor` (edit owned or delegated), `service_viewer`.

## Service Builder

Store application `sn_service_builder`: a guided experience to define a business or technology management service and its offerings (tabs Details, Team, Service Performance, Manage Offerings with Details / Team / Operations / Financials / Performance, Review and Submit). States Draft → Awaiting approval → Published; auto-approved by default, customisable as a subflow. Editing checks out a draft while the published version stays active.

Brazil: installing Service Builder from the Store also installs plugin `com.snc.service_builder`, and it uses the same role set as Service Portfolio Management. Recorded next to the store application name `sn_service_builder` above as unconfirmed variants.

Domain separation: Basic with exceptions.

## Related

- [[Service Offerings, Commitments and Availability]] · [[SLA Definitions and Task SLAs]] · [[Incident Management Overview and Lifecycle]] (Service and Service offering on tasks)
- [[CSDM Overview and Data Domains]] (where services, offerings and service instances sit in the CSDM)
