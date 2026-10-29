---
type: reference
tags: [reference, integrations, cmdb, discovery]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > Observability - Dynatrace SaaS (about 470 cleaned lines, read 2026-10-29) - overview, Configure using SGC Central, Migrate to Dynatrace SaaS, Data mapping, Target CMDB classes (class list), Properties. https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/sgc-integration-dynatrace-saas.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for Observability - Dynatrace SaaS

**In one line:** Store app `sn_dynatrace_saas` for the **third-generation Dynatrace SaaS** platform (DQL-based APIs, Grail, Smartscape) that imports hosts, processes, services and frontends into the CMDB with service-to-service topology, and retires CIs Dynatrace no longer reports.

From the Brazil docs (Yokohama Patch 11, Zurich Patch 4, Australia); SGC Central only; not tested. For Dynatrace Managed or legacy SaaS use [[Service Graph Connector for Observability - Dynatrace]]. General: [[Service Graph Connectors Overview]].

## Setting up

SGC Central (prerequisites `admin`, setup `sn_cmdb_int_util.sgc_admin` or `admin`) > **Dynatrace SaaS**:
1. **Create and test connection**: name, host (`<tenant>.apps.dynatrace.com`), **Platform Token** (not prefixed with `Bearer`; permissions `storage:entities:read` and `storage:smartscape:read`).
2. **Set configuration properties**: service-to-service relationships, append tenant ID to calculated service names (unique names across several tenants), API batch size.
3. **Configure import schedule** (activate).
4. If replacing a classic connection: deactivate the classic scheduled imports, pick the classic connection, and configure the migration cleanup (below).
5. **Confirm connection creation**.

## Migrating from the classic Dynatrace connector

Copy the **sys_id of the classic connection alias** (**All > Service Graph Connectors > Dynatrace Observability > Connections**, open the connection, open the alias, **Copy sys_id**) into the SaaS connection property **`dynatrace_classic_connection_alias_sys_id`**. The scheduled import **SGO-Dynatrace Classic Migration Cleanup** then runs **once** at its next execution, soft-retires Process (Application) CIs owned only by the classic connector, and deactivates itself. Leave the property empty to skip the cleanup.

## Data and classes

| Data source | Staging table | Targets |
|---|---|---|
| SGO-Dynatrace SaaS Host | `sn_dynatrace_saas_sgo_dynatrace_saas_host` | by OS: Linux, Windows, AIX, Solaris Server, otherwise Computer; IP Address, Serial Number, Key Value, software (Software Installation with SAM, Software + Software Instance without) |
| SGO-Dynatrace SaaS Processes | `..._saas_processes` | Application (`cmdb_ci_appl`) classified through ADM and the **Process Classification** rules ([[Integration Commons for CMDB]] ADM adapter) |
| SGO-Dynatrace SaaS Service | `..._saas_service` | Calculated Application Service (`cmdb_ci_service_calculated`) |
| SGO-Dynatrace SaaS Frontend | `..._saas_frontend` | Calculated Application Service |
| SGO-Dynatrace Classic Migration Cleanup | `sn_dynatrace_saas_sgo_dynatrace_classic_migration_cleanup` | one-off cleanup of classic Application CIs |
| SGO-Dynatrace SaaS CI Retirement | `..._ci_retirement` | soft-retires stale CIs |

## Properties

| Property | Default | Meaning |
|---|---|---|
| `data_fetch_flow_action_timeout_ms` | 600000 (10 min) | timeout of the *Fetch Dynatrace SaaS Data* action |
| `initial_dynatrace_data_fetch_days` | 7 | days fetched on the first run or when `last_run_datetime` is empty |
| `service_to_service_relationships_enabled` | true | upstream / downstream relationships between service CIs |
| `append_tenant_id_to_service_name` | false | tenant ID in calculated service names |
| `dynatrace_api_batch_size` | 50 | records per API call |
| `dynatrace_classic_connection_alias_sys_id` | empty | see migration |
| `segment_id` | empty | import only one Dynatrace segment (one ID only) |
| `ci_retirement_threshold_days` | (value cut off) | days unseen before a CI's operational status is set to retired |
| `sn_dynatrace_saas.createUnmatchedApplicationCIs` (system) | | import unmatched running processes as Application CIs |

## Related

- [[Service Graph Connector for Observability - Dynatrace]] · [[Service Instances (Application Services)]] · [[Service Graph Connectors Overview]]
