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
