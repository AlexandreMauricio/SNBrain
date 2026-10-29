---
type: reference
tags: [reference, integrations, cmdb, discovery]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > Observability - New Relic (about 380 cleaned lines, read 2026-10-29) - overview with data mapping, Configure using SGC Central, Configure using guided setup (start), Targeted CMDB classes (class list). https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/sgc-cmdb-integration-new-relic.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for Observability - New Relic

**In one line:** Store app `sn_newrelic_integ` that pulls New Relic hosts, disks, networks, applications and application services through the **NerdGraph** (GraphQL) API into the CMDB, and sets up New Relic alert workflows that send events to ServiceNow.

From the Brazil docs (New Relic last tested July 2025; Xanadu, Yokohama, Zurich); not tested. General: [[Service Graph Connectors Overview]].

## Setting up

SGC Central (connector 1.3.0+; install `sn_observability` first if you want events; prerequisites `admin`, setup `sn_cmdb_int_util.sgc_admin` or `admin`):
1. **Create and test connection**: name, base URL, **API key** (or tenant code), **Account ID**.
2. **Configure Observability** → Continue: New Relic creates the **destination, channel and workflow** that send alerts for all CIs.
3. Schedule the parent **SG-New Relic Hosts**.
4. Optional: alerts for CIs not in the CMDB: **Settings > New Relic system properties** > `sn_newrelic_integ.alerts_for_unmatched_ci.enabled` = true.

Classic guided setup (**All > Service Graph Connectors > New Relic > Setup**, being deprecated): edit the default **NewRelicConnectionAlias** in Workflow Studio; connection URL fixed to `https://api.newrelic.com/graphql`. Do not migrate data from an older connector version.

## Data and classes

| Data source | Staging table |
|---|---|
| SG-New Relic Hosts | `sn_newrelic_integ_hosts` |
| SG-New Relic Disks | `sn_newrelic_integ_disks` |
| SG_New Relic Networks (underscore as printed) | `sn_newrelic_integ_networks` |
| SG-New Relic Applications | `sn_newrelic_integ_sg_new_relic_applications` |
| SG-New Relic Application Services | `sn_newrelic_integ_application_services` |

Targets: Server, Disk, Network Adapter, IP Address, Application (`cmdb_ci_appl`), **Calculated Application Service** (`cmdb_ci_service_calculated`), **Running Process** (`cmdb_running_process`, in the overview list only), software (Software Installation with SAM; Software + Software Instance without).

## Related

- [[Service Graph Connectors Overview]] · [[Service Graph Connector for Observability - Datadog]] · [[Service Graph Connector for Observability - Dynatrace]]
