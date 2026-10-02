---
type: concept
tags: [concept, platform]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Getting started on the ServiceNow AI Platform" and "How the ServiceNow AI Platform works" (pp. 7-11), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# ServiceNow AI Platform overview

**In one line:** every ServiceNow product (ITSM, CSM, HR, security, custom apps) runs on one platform with one database and data model, so tables, workflows, security and reporting are shared across all of them.

## What the guide says about the architecture

- **Multi-instance**: each customer gets its own instances (own application and database), not one shared multi-tenant application. A customer usually has several: production plus sub-production (dev, test).
- **Single data model**: all applications store data in tables of the same database (see [[Tables, Records and Table Relationships]]). That is why an incident can reference a CI, a user and an SLA without integration.
- **Regular releases**, named by family (this guide: Australia), with upgrade tooling: [[Upgrades - Process, Upgrade Center and Upgrade Console]].

## Platform areas named in the overview

| Area | Where it shows up |
|---|---|
| Administration | Admin Center, Otto for Setup: [[Admin Center, Store and Application Manager]] |
| Localization | languages, currencies, translation services |
| Store / ecosystem | ServiceNow Store applications and partner apps |
| Subscription Management | licence visibility: [[Subscription Management]] |
| Integration | Workflow Data Fabric, MID Server, import/export, email |
| AI | Now Assist, AI Agents, agentic workflows, AI Control Tower |
| Security and identity | encryption, roles and ACLs, SSO/SAML/OAuth/MFA |
| Workflow | Workflow Studio flows, Playbooks |
| Development | server-side JavaScript, App Engine Studio, Integration Hub, Build Agent |
| Knowledge | Knowledge Management |
| Analytics | Platform Analytics dashboards, Usage Insights, Process Mining |
| Mobile | native iOS and Android apps |

## Experimentation framework and Feature Preview Program

- **Experimentation framework**: ServiceNow A/B tests features and collects aggregated usage metrics. See **Experimentation Framework > All Experiments**; **Opt Out** per experiment, or **Disable Experimentation Framework** for all. Role admin.
- **Feature Preview Program** (**All > Feature Preview Program**): pre-release features offered to agreed customers, activated one by one with a consent step. They activate **on the instance where you do it, including production**. Deactivating disables the feature but leaves its artifacts behind.

## Related

- [[Plugins]] · [[System Properties]]
