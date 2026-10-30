---
type: concept
tags: [concept, integrations, data-management, roles, ai, release-specific]
status: documented
source: ServiceNow Brazil docs, Workflow Data Fabric > Zero Copy Connectors (Explore, Configure, connections and data fabric tables overviews, Access real-time data, Reference), Otto for Zero Copy Connector overview, Reverse Tunnel (Explore, Configure, relay properties), read at overview depth 2026-10-30. Per-connector setup pages (66 topics) listed, BigQuery read as a sample. https://www.servicenow.com/docs/r/integrate-applications/zero-copy-connectors.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Zero Copy Connectors

**In one line:** query external warehouses and databases live from the instance, without copying data, through **data fabric tables** that look like normal tables in lists, forms and `GlideRecord`.

From the Brazil docs; not tested. Compare [[Remote Tables]] (scripted) and [[Import Sets - Data Sources, Staging Tables and Cleanup|import sets]] (copied). Domain separation: **no support**. Not supported on demo instances.

## Apps

- **Zero Copy Connector Hub** (`sn_data_fabric`): free; local instance connector only.
- **Zero Copy Connectors** (`sn_data_fabric_zcc`): separate subscription, requested through Now Support, activated by ServiceNow.
- **Data Fabric REST Connectors**: adds API-based connectors, tagged REST. Most connectors use JDBC.

## Connections

**All > Zero Copy Connector Hub** (or **Admin >** the same): Available connectors, Established connections, Data fabric tables. Also reachable through [[Workflow Data Fabric and Connect Hub|Connect Hub]].

- **Primary connectors:** built and supported by ServiceNow: Databricks, Google BigQuery, Snowflake, Redshift, Oracle and others; compatibility varies by release and patch.
- **Community connectors:** open source, certified for baseline only; **no ServiceNow support**.
- Status: Connected, Deactivated, Needs configuration.
- **Access:** the connection admin adds a custom role on the connection; it then inherits `df_data_steward`.
- **Private networks:** IP allowlist, Private Link style connectivity, or Reverse Tunnel.

Read-only. BigQuery page lists pushdown of sort, limit, filter, group by, and aggregates. Unsupported source types cannot be mapped.

## Data fabric tables

Definition on the instance, data at the source, with normal ACLs, in a scope. Connect to an external source or a local table. Change the connection needs the steward role on both. Deploy through an update set; a connection admin then links the connection on the target.

An application can ship a **physical table and a data fabric twin**, so the admin chooses how to fill it.

## Roles

| Role | Can |
|---|---|
| `df_connection_admin` | connections, and tables as a steward does |
| `df_data_steward` | tables, usually through a custom role |
| table create or delete | also `delegated_developer` with `sn_dd_<scope>_tablesforms` or `sn_dd_<scope>_delegatedadmin` |

## Reverse Tunnel

Reaches private or on-premises sources **without inbound firewall ports**.

- **Private relay** in your network, placed like a MID Server, connects out to the **gateway**, which routes traffic without decrypting it.
- Certificates are issued and renewed by ServiceNow.
- Settings: `sn_zc_tunnel_relay_prop` or `config.yaml`. `max-streams` 10000, `reconnect-initial-delay` 1000 ms, `reconnect-max-delay` 60000 ms, `config-poll-interval` 30000 ms, `cert-reissue-window` 30 days, `glide.kmf.issuing.reverse_tunnel_relay.validity_ms` 365 days.

## Otto for Zero Copy Connector

For ERP: skill ERP data discovery, agentic workflow Explore ERP models, OData Service Recommender agent; role `sn_erp_integration.erp_ai_user`.

## Example

`df_connection_admin` creates *Example Warehouse Connection* to Snowflake and adds role *Example Data Steward*; that user creates data fabric table *Example Orders* mapped to the source table.

## Related

- [[Zero Copy Connector for ERP]] · [[Data Products and Data Interfaces]] · [[Workflow Data Fabric and Connect Hub]] · [[Remote Tables]]
