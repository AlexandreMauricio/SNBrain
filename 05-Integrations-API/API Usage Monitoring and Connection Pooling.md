---
type: reference
tags: [reference, api, integrations, instance-admin, roles]
status: documented
source: ServiceNow Brazil docs, API implementation and reference > Web services > Additional integration resources > Manage connection pooling, Analyze REST and SOAP API usage, Monitor inbound API integration usage, Registered integrations, Domain separation and web services, read 2026-10-30. https://www.servicenow.com/docs/r/api-reference/web-services/c_APIAnalytics.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# API Usage Monitoring and Connection Pooling

**In one line:** where to see who calls the instance's APIs and how much, and what limits outbound connections.

From the Brazil docs; not tested. Compare [[API Insights]] for CMDB. Domain separation for web services: Standard, with exceptions.

## REST and SOAP API analytics

Tracks inbound only, **not outbound**. **System Web Services > Analytics Usage Overview** (`api_analytics_read`, `web_service_admin`, `admin`): Usage Overview, by API, by Requestor.

**System Web Services > Inclusion List**: **API name** as namespace and ID (`now/table`), **Collect API stats**, **Collect API requestor stats**. New APIs get a record automatically. SOAP has one shared record. Internal UI and mobile APIs are excluded.

Not logged: 401, and invalid API names. Daily stats kept 33 days, monthly 13 months; tables `sys_api_stats`, `sys_api_stats_requestor`, `sys_api_stats_requestor_monthly`.

| Property | Default |
|---|---|
| `com.glide.api.stats.enabled` | true |
| `com.glide.api.stats.daily_ limit` (space in the docs: unconfirmed) | 20000 per node |
| `com.glide.api.stats.persist_interval` | 60 s (30 to 120) |
| `com.glide.api.stats.max_bytes_nursery_size` | 3145728 |
| `glide.api.stats.debug` | false |

## Inbound API Integration Usage dashboard

**System Web Services > Inbound API Integration Usage dashboard > Usage dashboard** (`inbound_integration_metering_admin`): **Transactions**, **Data Egress**, **Usage by Domain** (only when domain separated). It relates to Workflow Data Fabric usage.

**Registered integrations** (`oauth_admin`, `web_service_admin`): register Basic Auth users with a provider and integration name, so they show up by name. OAuth names come from the OAuth entity.

## Connection pooling

Applies to outbound calls and to MID Server and ODBC connections. Not browsers or custom clients. Changes take effect at once.

| Property | Default |
|---|---|
| `glide.http.connection_mgr.max_connections` | 20, instance wide |
| `glide.http.connection_mgr.max_connections_per_host` | 4 |
| `glide.http.use_connection_mgr` | true |

At the limit, a script may wait for a connection. Review with many outbound integrations.

## Related

- [[REST API Fundamentals]] · [[Outbound REST Messages]] · [[Non-Interactive Users]]
