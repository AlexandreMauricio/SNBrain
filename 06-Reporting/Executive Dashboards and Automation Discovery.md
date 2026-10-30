---
type: reference
tags: [reference, reporting, roles, release-specific]
status: documented
source: ServiceNow Brazil docs, Platform Analytics guide > Executive dashboard overview, CIO Dashboard install page, role lines of the install pages; Automation Discovery main page, read 2026-10-30. Tabs, pillars, data visualization and role pages of each dashboard listed, not read in detail. https://www.servicenow.com/docs/r/now-intelligence/executive-dashboard-overview.html and https://www.servicenow.com/docs/r/now-intelligence/automation-discovery.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Executive Dashboards and Automation Discovery

Two small sections of the Platform Analytics guide. From the Brazil docs; not tested.

## Executive dashboards

Store applications giving a C-suite overview on [[Platform Analytics Dashboards]]. **Free to install, but the contents need professional entitlements** in the underlying products, plus their indicators and data; otherwise they show nothing relevant. Duplicate before customizing.

| Dashboard | Covers | Admin role (with `admin`, `platform_analytics_admin`) |
|---|---|---|
| CIO | IT performance against priorities | `cio_dashboard_admin` |
| CISO | security operations | `sn_ciso_dashboard.admin` |
| CPRO | procurement | `sn_cpro_dashboard.admin` |
| CRO | governance, risk, compliance | `sn_cro_dashboard.admin` |
| GC | legal services, contracts | `sn_lsd_dashboard.gc_dashboard_admin` |
| CHRO | people leadership | `chro_dashboard_admin` |
| CFO | financial operations | not read |
| CDO | digital properties | `cdo_dashboard_admin` |
| CCO | customer support | `sn_cco_dashboard.cco_dashboard_admin` |

**CIO requirements:** ITSM, ITOM, ITAM, SecOps and SPM professional entitlements. Plugins include `com.snc.pa.itsm_dashboards`, `com.snc.pa.sla`, `com.snc.pa.change`, `com.snc.pa.request`, `com.snc.pa.cmdb`, `com.snc.pa.premium.sam`, `com.snc.pa.pmo_dashboards`, `com.snc.pa.self_service_analytics`; applications `sn_sir_analytics`, `sn_vul_analytics`, `sn_compliance`, `sn_ppm_imd`.

## Automation Discovery

**Deprecated: announced in Zurich; from Brazil no longer deployed, enhanced or supported** (KB0867184). Existing deployments keep working; new ones cannot start.

It analysed records against a taxonomy of over 180 opportunities, grouped them, clustered the rest, and estimated deflections and time savings (records times MTTR). Opportunities could feed Virtual Agent Topic Recommendations. Needed `nlu_admin` or `nlu_user`. Languages for the ITSM taxonomy: English, Spanish, French, German, Japanese; Predictive AIOps: English.

## Related

- [[Platform Analytics Dashboards]] · [[Platform Analytics Experience Overview]] · [[Benchmarks]]
