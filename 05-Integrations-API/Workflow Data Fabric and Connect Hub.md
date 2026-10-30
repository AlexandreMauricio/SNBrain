---
type: concept
tags: [concept, integrations, ai, roles, release-specific]
status: documented
source: ServiceNow Brazil docs, Workflow Data Fabric > Workflow Data Fabric Home (Explore, Configure, Otto for WDF, Connect overview, external systems, connectors, MCP connectors through custom connector start), Workflow Data Fabric Credits, read 2026-10-30. Remaining MCP pages, key terms and roles tables read only in the Data Catalog copy. https://www.servicenow.com/docs/r/integrate-applications/create-integrations-applications.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Workflow Data Fabric and Connect Hub

**In one line:** **Workflow Data Fabric** (WDF) is the guide and product family for connecting enterprise data where it lives, governing it, and using it in workflows, analytics and AI. **Connect Hub** is its workspace for external systems, connectors and connections.

From the Brazil docs; not tested. The family: [[Data Catalog and Metadata Collectors]], [[Data Products and Data Interfaces]], Automation Center, Integration Hub, RPA Hub, Zero Copy Connectors, Reverse Tunnel; also [[Import Sets - Data Sources, Staging Tables and Cleanup|Imports]], [[Exporting Data|Exports]], [[Classic Orchestration Overview and Activity Packs|Classic Orchestration]].

Open **All > Workflow Data Fabric > Workflow Data Fabric Home**.

## Install

| App | ID |
|---|---|
| Connect Hub (brings the next two) | `sn_wdf_connect_hub` |
| WDF Unified Hub | `sn_wdf_unified_hub` |
| Otto for WDF | `sn_nowassist_wdf` |
| Zero Copy Connectors | `sn_data_fabric_zcc`, `sn_data_fabric` |
| WDF Credits (WDF Tokenization) | `sn_wdf_token` |

Connect Hub v2.4.0 is stated as the latest.

## People

| Persona | Does | Role |
|---|---|---|
| Connection Admin | connections, credentials, collectors, grants Stewards access | `connection_admin` (also seen `connection-admin`, `df_connection_admin`: unconfirmed) |
| Data Steward | owns data products and interfaces | `df_data_steward` |
| WDF Builder | connectors, spokes, MCP servers | `wdf_builder` |
| WDF Operator | workflows consuming data interfaces | `wdf_operator` |
| WDF Consumer | discovers, requests access | `wdf_consumer` |

## Connectors and connections

- **Connector:** reusable component for one external application: actions, triggers, mapping. Types: Spoke, Zero Copy Connector, MCP, custom.
- **Connection:** one configured target with credentials and URL.
- **One connector, many connections**, such as dev, staging and production.
- **External system:** groups them; over 200 third parties listed. Create custom ones under **External Systems**. A connector must be **mapped to a system** before use (**Connectors > Map System**).

Compare the older model in [[Connections, Credentials and Aliases]].

## MCP connectors

Let AI agents use tools on external **Model Context Protocol** servers (`wdf_builder` or `admin`; custom connector page says `sn_mcp_client.admin`: unconfirmed). **Connect Hub > Create > Model Context Protocol.**

- **MCP Registry:** private catalogue of approved servers; *Certified by ServiceNow* label.
- **Dynamic client registration:** OAuth 2.1 approved at the provider, no client ID or secret.
- **Manual client registration:** client ID and secret from an OAuth app; callback `https://<instance>.service-now.com/oauth_redirect.do`. Label *Manual setup may be required*.
- **Custom connector:** your endpoint, with OAuth 2.1 (recommended), API key or basic. Scoped to the instance.

Compare [[ITSM MCP Server]], where the instance is the server.

## Otto for WDF

Search on the home page: recommends reuse or a new connection, through the **oneExtend LLM** skill. Optional: *ServiceNow Product Documentation* connector, and the Flow generation skill. Tables `sn_wdf_quicklink`, `sn_wdf_search_results_route_config`.

## Credits

**WDF Credits** measure usage under one meter: transactions (API calls, assets, records), data volume, runtime. See KB2276348 and KB2239792. Usage dashboard in the app.

## Related

- [[Integration Options and Interfaces Overview]] · [[API Usage Monitoring and Connection Pooling]] · [[Remote Tables]]
