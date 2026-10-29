---
type: reference
tags: [reference, integrations, cmdb, discovery]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > Observability-AppDynamics (about 400 cleaned lines, read 2026-10-29) - overview, Configure using SGC Central, Configure using guided setup, Target CMDB classes (class list). https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/cmdb-integration-appdynamics.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for Observability - AppDynamics

**In one line:** Store app that pulls servers, applications, tiers and their relationships from an AppDynamics controller over REST into the CMDB (building **calculated application services**) and can push AppDynamics health alerts to the instance as events.

From the Brazil docs (AppDynamics 20.3; Xanadu, Yokohama, Zurich); not tested. General: [[Service Graph Connectors Overview]].

## Requirements

AppDynamics: **Server Visibility** active for the account, and a user or API client with the needed privileges. ServiceNow: ITOM units, `com.snc.itom.discovery.license` (activate), `com.snc.itom.license`, Integration Commons, CMDB CI Class Models, Datastream Action; **Observability Commons for CMDB** (`sn_observability`) **installed before the connector** if you want events. Role `sn_cmdb_int_util.sgc_admin` or `admin`. Do not migrate data from an older connector version.

## Setting up the connection

**Single instance**: you edit the default connection (**AppDynamicsConnectionAlias**).

SGC Central (connector 1.4.0+):
1. **Configure and test connection**: name, controller base URL, OAuth client ID and secret, optional MID Server.
2. Optional **Enable real-time event integration**: creates an **HTTP request template** in AppDynamics so health-rule alerts flow to ServiceNow as events (several API calls start the ingestion service).
3. **Configure duplicate detection rules**: activate the rules so only new or changed rows reach the CMDB; list volatile fields in **Ignore Fields**. For a full import, deactivate the rule and run the scheduled job **Clean AppDynamics Duplicate Row Hashes**.
4. Schedule the parent **SG-AppDynamics Servers and Applications**.

Classic guided setup (being deprecated): **Basic Auth** (host name, user, password) or **OAuth client credentials** (connection URL, client ID, secret) on the same alias, test, then **Push HTTP Request Template** for events.

## Data and classes

Data sources: **SG-AppDynamics Application Services**, **Servers and Applications**, **Server Tags**, **Tier to Tier Relationship**. Targets: Server, Application (`cmdb_ci_appl`), **Calculated Application Service** (`cmdb_ci_service_calculated`, see [[Service Instances (Application Services)]]), IP Address, Network Adapter, Key Value (tags), and **AppDynamics Extension** (`sn_sg_appd_extension`).

## Related

- [[Service Graph Connectors Overview]] · [[Service Graph Connector for Observability - Dynatrace]] · [[Service Instances (Application Services)]]
