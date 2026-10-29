---
type: meta
tags: [meta]
status: documented
source: own
updated: 2026-10-01
---

# Index: Integrations-API

REST and SOAP APIs, import sets and transform maps, IntegrationHub, MID Server, auth, payloads.

<!-- One line per note: [[Note Name]] - short description -->
- [[Integration Options and Interfaces Overview]]: techniques, SCCM, Google Maps, CTI, JDBC and Syslog probes, integration sessions
- [[Collaboration Services (Slack, Teams and Zoom on Tasks)]] - Slack channels and slash commands on tasks, importing messages, Slack in communication plans
- [[ITSM MCP Server]] - MCP server for external AI clients: activation, OAuth, tool list per role
- [[DevOps Azure DevOps Integration]] - organization or project, PAT scopes and OAuth, extension tasks, release gates, reruns and change reuse, parallel stages, work item mapping, artifacts
- [[DevOps GitHub Integration]] - tool URL rules, basic / OAuth / GitHub App JWT, Actions secrets and custom actions, deployment gates, limits
- [[DevOps GitLab Integration]] - webhooks, Docker CLI or manual jobs for change control, merge requests, bulk commits
- [[DevOps Jenkins Integration]] - plugin configuration, Jenkinsfile commands, snDevOpsChange parameters, nested and parallel stages
- [[DevOps Planning, Code, Artifact and Deployment Tool Integrations]] - Jira, Rally, Agile Development 2.0, Bitbucket, JFrog and AppTrust, Argo CD, Harness
- [[DevOps Quality, Security and Other Tool Integrations]] - SonarQube, Veracode, Checkmarx, Split, user-created integrations, inbound event errors, test types
- [[DevOps Custom Tool Integrations, Test and Attachment APIs]] - endpoints and token auth, standard payloads, subflow contracts, record transformers, test and attachment APIs, credential expiry
- [[DevOps Docker Image and sndevopscli]] - environment variables and CLI commands for GitLab, GitHub Actions and Harness pipelines
- [[DevOps Config Pipeline Integration]] - Azure DevOps tasks, Jenkins snDevOpsConfig actions and GitHub actions to upload, validate, publish and export config data
- [[Spoke Generator]] - build a custom spoke from OpenAPI, Postman, pasted API docs (AI) or by hand; roles, limits (documented)
- [[ServiceNow CLI]] - snc command-line client: install, profiles, record commands, custom commands mapped to REST endpoints, ui-component extension, CMDB application service commands (documented, Brazil)
- [[Inbound API Authentication and API Access Policies]] - basic auth restriction, API keys and HMAC, access policies and their priority, REST auth scopes, processor policies, external authorization servers for the MCP Server (documented, Brazil)
- [[LDAP Integration]] - authentication, refresh, listener, on-demand login, connection options, records, transform map rules and LDAPUtils, deactivating disabled users (documented, Brazil)
- [[OAuth 2.0 Inbound - The Instance as OAuth Provider]] - endpoints, grant types, Machine Identity Console and Application Registry, CIMD, tokens, properties
- [[OAuth 2.0 Outbound - The Instance as OAuth Client]] - third-party provider records, JWT bearer, Private Key JWT, Workload Identity Federation (Azure, Google Cloud), OAuth client and JWT script APIs
- [[Connections, Credentials and Aliases]] - connection, credential and alias model, tables and roles, order and affinity, Discovery credential aliases, scope protection, authentication algorithms
- [[Credential Types Reference]] - every credential type with its fields; SSH sudo commands and Windows account requirements
- [[External Credential Storage and CyberArk]] - credential resolvers, MID Server parameters, Credential ID formats, OAuth client secret in a vault
- [[Connection and Credential Configuration Templates]] - one-dialog setup for spokes: default data, dynamic schema, post-processing and pre-edit scripts, OAuth through a MID Server
- [[Log Export Service (LES)]] - streaming instance logs through Hermes (Kafka) to external analytics: sources, topics, Kafka and MID Server consumers, backfill runs, properties, roles
- [[SCIM Provider - Provisioning Users and Groups into the Instance]] - SCIM 2.0 endpoints, authentication profiles, schemas, extension schema and ETL mapping, scripts for unmapped attributes, source definitions (Brazil)
- [[SCIM Client - Provisioning from the Instance to Other Systems]] - REST message, SCIM provider record, resource and attribute mappings, SCIM2Client, logs, troubleshooting (Brazil)
- [[Import Sets - Data Sources, Staging Tables and Cleanup]] - data source types and formats, staging tables, standard imp_ tables, cleanup, roles (Brazil)
- [[Transform Maps, Field Maps and Coalesce]] - map options, field maps, reference matching, choice actions, coalesce variants and indexing (Brazil)
- [[Transform Scripts and Script Variables]] - onStart to onComplete events, source/target/ignore/error variables, examples (Brazil)
- [[Robust Import Set Transformers and ETL Definitions]] - ETL entities, coercion, RTE operations, nested JSON, IRE settings, run details (Brazil)
- [[Scheduled and Concurrent Imports]] - scheduled import form, chained imports, partitions, concurrent jobs and monitoring (Brazil)
- [[Web Service Import Sets and Direct File Posting]] - SOAP import set tables, sync and async modes, responses, sys_import.do posting (Brazil)
- [[Import Set Properties Reference]] - loading, CSV and Excel, concurrency, web service, JDBC, logging properties (Brazil)
- [[Integration Commons for CMDB]] - sn_cmdb_int_util: CMDB Integrations Dashboard, connection framework, deleted-record removal, partition size, ADM adapter, quick start tests (Brazil)
- [[RTE Operations and Integration Commons Transforms Reference]] - RTE operation types and CMDB cleansing and class-derivation templates (Brazil)
- [[IntegrationHub ETL]] - sn_int_studio guided ETL transform maps through RTE and IRE: terms, required fields, conditional and associated classes, deactivation, nested JSON, before/after scripts (Brazil)
- [[Service Graph Connectors Overview]] - what SGCs are, roles, connector list, patterns vs connectors, domain separation, SGC Central vs guided setup, Support Tools (Brazil)
- [[Service Graph Connectors Catalog]] - one line per connector with links to the per-connector notes (Brazil)
- [[Service Graph Connector for AWS]] - AWS Config, SSM deep discovery, EKS, optimized deletion, tuning properties (Brazil)
- [[Service Graph Connector for GCP]] - service account and JKS certificate, deep discovery patch jobs, soft and hard deletion (Brazil)
- [[Service Graph Connector for Microsoft Azure]] - OAuth app, hardware and software connections, delta sync, parallel loading (Brazil)
- [[Service Graph Connector for Wiz]] - multi-cloud inventory via Wiz API, project filters, single instance (Brazil)
- [[Service Graph Connector for Microsoft Intune]] - Graph API, regular and advanced data sources, primary user, multi-tenant (Brazil)
- [[Service Graph Connector for Microsoft SCCM]] - JDBC through MID Server, integrated auth, air gap, software editions, upgrades (Brazil)
- [[Service Graph Connector for Jamf]] - auth types, Classic or Pro API, delta sync, software usage (Brazil)
- [[Service Graph Connector for Google Chromebooks]] - ChromeOS devices from Google Admin console, JKS certificate (Brazil)
- [[Service Graph Connector for Tanium]] - Tanium Asset view, token auth, servers, applications, usage (Brazil)
- [[Service Graph Connector for Tanium Atlas]] - Tanium Atlas data sources and properties (Brazil)
- [[Service Graph Connector for Tanium Atlas Endpoints]] - endpoint-only Tanium connector, service account token, additional sensors (Brazil)
- [[Service Graph Connectors for Workspace ONE UEM (VMware and Omnissa)]] - VMware and Omnissa connectors for Workspace ONE UEM (Brazil)
- [[Service Graph Connector for Active Directory]] - AD computer objects over LDAP into the CMDB, guided setup (Brazil)
- [[Service Graph Connector for Akamai API Security]] - discovered APIs into API Component, tag properties, full and delta loads (Brazil)
- [[Service Graph Connector for Microsoft Defender for Endpoint]] - List machines API, OAuth, related details table, upgrade to 1.2.0 (Brazil)
- [[Service Graph Connector for Netskope]] - Netskope Client inventory, guided setup (Brazil)
- [[Service Graph Connector for Qualys]] - two Qualys APIs, class mapping rules, guided setup, classes (Brazil)
- [[Service Graph Connector for Rapid7]] - InsightVM assets, guided setup, classes (Brazil)
- [[Service Graph Connector for SentinelOne]] - agents, cloud context, page size property (Brazil)
- [[Service Graph Connector for Splunk]] - forwarder hosts and the ServiceNow add-on for Splunk (Brazil)
- [[Service Graph Connector for Trellix]] - Trellix devices, SGC Central and guided setup (Brazil)
- [[Service Graph Connector for Infoblox]] - IPAM import, IPAM tasks, parallel loading, 1.5.0 soft deletion and table cleanup jobs (Brazil)
- [[Service Graph Connector for BlueCat]] - IPAM import from BlueCat, properties (Brazil)
- [[Service Graph Connector for Nautobot]] - servers and IPAM from Nautobot (Brazil)
- [[Service Graph Connector for NetBrain]] - network devices and switches from NetBrain (Brazil)
- [[Service Graph Connector for ExtraHop]] - deprecated ServiceNow-hosted ExtraHop connector (Brazil, outdated)
- [[Service Graph Connector for Confluent]] - Confluent and Kafka classes (Brazil)
- [[Service Graph Connector for Observability - AppDynamics]] - AppDynamics CIs and events, duplicate detection (Brazil)
- [[Service Graph Connector for Observability - Datadog]] - Datadog hosts and services, webhooks and monitors (Brazil)
- [[Service Graph Connector for Observability - Dynatrace]] - Dynatrace Classic connector, events, Grail, properties (Brazil)
- [[Service Graph Connector for Observability - Dynatrace SaaS]] - third-generation Dynatrace SaaS, migration from classic (Brazil)
- [[Service Graph Connector for Observability - New Relic]] - New Relic NerdGraph import and alerts (Brazil)
- [[Service Graph Connector for OpenTelemetry]] - Cloud Observability topology, inferred services (Brazil, being deprecated)
- [[Service Graph Connector for SolarWinds]] - Orion inventory, air gap, data sources (Brazil)
- [[API Service Graph Connectors]] - eight API gateway and management connectors, common API data model, authentication per connector (Brazil)
- [[SGC Central Application]] - sn_sgc_central: install, collection jobs, explore connectors, playbooks, connections, diagnosis, tables (Brazil)
- [[MID Server Overview and Architecture]] - what the MID Server does, ECC queue and AMB, heartbeat, statuses, pause, records, dashboard (documented, Brazil)
- [[MID Server Selection, Capabilities and Clusters]] - applications, IP ranges, capabilities, auto-select order, defaults, override, clusters, threads, Nmap, domain separation (documented, Brazil)
- [[MID Server Security and Encryption]] - config.xml encryption, DPAPI and CyberArk, certificate check policies, trust store, key store and mutual auth, Azure Key Vault, audit log, FIPS, governance (documented, Brazil)
- [[MID Server Extensions, Profiles and Containers]] - vCenter and SNMP trap collectors, resource reservation, profiles, containerized MID Servers, IPv6 (documented, Brazil)
- [[MID Server Upgrades]] - automatic and manual upgrade, pre-upgrade check, states, upgrade history, pinning (documented, Brazil)
- [[MID Server Reference - Requirements, Properties and Parameters]] - supported OS and Java, sizing, properties, parameters, priority, file cleaner, privileged commands, MIDSystem (documented, Brazil)
