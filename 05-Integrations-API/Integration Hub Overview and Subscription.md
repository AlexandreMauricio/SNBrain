---
type: concept
tags: [concept, integrations, flows, roles, domain-separation, release-specific]
status: documented
source: ServiceNow Brazil docs, Workflow Data Fabric > Integration Hub (Explore, Configure, Request, usage and subscription, plugins, Usage Dashboard, Manage connections, mTLS with a MID Server, Reference, Import, Conditional and event-driven inbound integration, Integration steps), read at overview depth 2026-10-30. Spoke pages (530 topics), Spoke Generator and step form fields listed, not read. https://www.servicenow.com/docs/r/integrate-applications/create-integrations-applications.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Integration Hub Overview and Subscription

**In one line:** the paid layer on Workflow Studio that lets flows reach outside the instance: protocol steps (REST, SOAP, JDBC, PowerShell, SSH), spokes, inbound webhooks, large data streams, and integration through a MID Server.

From the Brazil docs; not tested. Part of [[Workflow Data Fabric and Connect Hub|Workflow Data Fabric]]. Without it, [[Workflow Studio Overview|Workflow Studio]] stays inside the instance: base actions and steps, including the Script step. It can be previewed on a Personal Development Instance.

- **Outbound:** a flow calls a third-party API. Spokes package these calls as reusable actions; build your own with Spoke Generator.
- **Inbound:** a webhook from a third party starts a flow. See [[Saved Triggers and External Event Sources]].

## Subscription

Integration Hub plugins have a separate subscription and are activated by ServiceNow personnel, generally within a few days of asking the account manager.

| Pack | Plugin |
|---|---|
| Starter | `com.glide.hub.integrations` |
| Standard | `com.glide.hub.integrations.standard` |
| Professional | `com.glide.hub.integrations.professional` |
| Enterprise | `com.glide.hub.integrations.enterprise` |

The page text names only Starter, Professional and Enterprise as the main subscriptions, yet lists a Standard installer too: unconfirmed variant. Which feature sits in which pack is on the legal schedule, not read.

- **Subscription notifications** warn when you use a spoke, protocol or feature outside your subscription; they do not block you, but unlicensed features "may be unavailable" in production.
- Spokes need an Integration Hub subscription or a product that includes them, and may consume transactions.

## Usage Dashboard

**All > IntegrationHub > IntegrationHub Usage** (v3.0.0). Roles: `admin`, flow designer, `action_designer`, `usage_admin` or `flow_operator`.

- **Transactions** tab: Overview, Spokes, Protocols and Features. Count is the sum of Integration Hub, External Content Connectors and Orchestration; **Tx per Caller Scope** shows which application made the calls.
- **Data Egress** tab: volume by API protocol and export.

## Connections

Base model: [[Connections, Credentials and Aliases]].

- **Several connections to one provider** (for example two Jira environments). Override for one flow: **More actions > Configure connections** (`flow_designer` or `admin`).
- **Connections dashboard:** **All > Process Automation > Flow Designer > Connections** tab (`connection_admin` or `admin`). **Add Connection** appears only if the alias has a configuration template; templates arrived in Orlando, so older aliases may lack them.
- **Moving an alias does not move its connection.** After transfer or promotion it is unconfigured and must be set up again; flows need no change.
- **Personal Authentication dashboard:** see [[Personal OAuth Authentication and Web Embeddables Sessions]]. Sections My Integrations and Integrations I can use; Revoke, Renew.
- **mTLS through a MID Server:** a **MID Protocol Profile** holds the credential and certificate on the instance, in a configuration file or in an external vault (`admin` or `action_designer`). See [[MID Server Extensions, Profiles and Containers]].

## Integration steps

Fields are in [[Flow Action Steps Reference]]. Steps on record data run on the instance; steps reaching your network run on a MID Server, to which the instance hands the process plan.

| Step | Note |
|---|---|
| REST, SOAP | REST can import an OpenAPI specification from a URL or by pasting |
| OpenAPI/Postman | builds a REST integration from a specification or Postman collection |
| JDBC, PowerShell, SSH | MID Server only |
| JSON Builder, JSON parser, XML parser | no script needed |
| Payload Builder | deprecated for JSON, replaced by JSON Builder |

The docs also say "Only Flow Designer admin and Connection admin can execute flows using Integration Hub": meaning unconfirmed.

## Integration Hub - Import

**All > IntegrationHub > IntegrationHub - Import** (`admin` or `ih_import`); also reachable from App Engine Studio. A guided import: data source (Excel, CSV or a [[Data Stream Actions|Data Stream action]], dynamic outputs allowed, dynamic inputs not), **Map to target**, **Schedule imports** (time, interval, after a parent import, or now). Needs `com.glide.hub.action_type.datastream`.

Transform Settings: Batch Size default 10, Verbose default false, Copy Empty Fields, scripts before or after. Stored in `sn_ihub_integration_instance` per [[Metadata File Types and Primary Tables]]. Underlying model: [[Import Sets - Data Sources, Staging Tables and Cleanup]].

## Domain separation

Standard, with exceptions (the page marks it `Standard*`). Stream Connect: Standard. Compare [[Domain Separation Support Levels by Application]].

## Example

A `connection_admin` adds *Example Ticketing Test* and *Example Ticketing Prod* under one alias. Flow *Example Sync Issues* uses the alias, and its REST step calls the external API. On promotion, the connection is configured again in production.

## Related

- [[Stream Connect for Apache Kafka]] · [[Remote Process Sync]] · [[Data Stream Actions]] · [[Flow Spokes Shipped with the Platform]] · [[Custom Actions, Dynamic Inputs and Error Evaluation]]
