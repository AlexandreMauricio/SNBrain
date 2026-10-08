---
type: reference
tags: [reference, domain-separation, platform, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Domain separation for service providers > Application support for domain separation, and Recommended practices > Domain separation levels of support (read in full 2026-10-08 through the docs site). The docs table is regrouped by level; industry applications are summarised. https://www.servicenow.com/docs/r/platform-security/domain-separated-apps.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Domain Separation Support Levels by Application

**What this is:** how far each application goes in a domain-separated instance, as listed for the Brazil release.
**Where:** docs only; on an instance, **Domain Separated Tables** shows which tables carry a domain ([[Domain Separation Administration]]).
**Role required:** none

Concepts: [[Domain Separation Overview]].

## The levels

| Level | Also called | Means |
|---|---|---|
| **No support** | | a domain field may exist on tables, but no logic manages it: not domain-separated |
| **Basic** | customer data management | data lands in the right domain; UI, caches, reporting and roll-ups respect domains at run time; the instance owner can make the application work across tenants. Example: a tenant sees the provider's chat reply |
| **Standard** | customer process management | Basic, plus the provider can create or change processes per tenant. Example: closing comments mandatory for one tenant only |
| **Enhanced** | customer self-managed configuration | Standard, plus tenants themselves change business logic through fail-safe, UI-based settings. Example: a tenant edits its own priority matrix |
| **`*` (effective domain)** | | the stated level is reached without the domain framework, by configuration. Example: before New York, Service Catalog reached Standard through user criteria |

## Selected applications

| Level | Applications |
|---|---|
| **Enhanced** | Hardware Asset Management, Software Asset Management, Performance Analytics, Data Classification, Advanced Approval for Sales Management |
| **Standard** | Incident Management, Problem Management, Request Management, Service Catalog, Product Catalog, Incident Communications Management, On-Call Scheduling, Facilities Service Management, Knowledge Management, Notifications, CMDB, Discovery, Cloud Discovery, Credentials and Connections, Contextual Search, Assessments, Advanced Work Assignment, Agent Chat, Sidebar, Password Reset, Workspace, UI Builder, Decision Builder, Enterprise Asset Management, Security Incident Response, Vulnerability Response, Threat Intelligence, Configuration Compliance, Service Bridge, Proactive Service Experience Workflows |
| **Standard\*** | Flow Designer, Integration Hub, Workflow, Orchestration, Web Services, Automated Test Framework, Procurement, Planned Maintenance |
| **Basic** | Change Management, Service Level Management, Asset Management, Coaching, Continual Improvement Management, Digital Product Release, Task outage, Walk-up Experience, Workforce Optimization (ITSM, HR, CSM), ServiceNow Otto for ITSM, Customer Service Management, Field Service Management, Universal Request, Universal Task, Legal Service Delivery, Contract Management Pro, Event Management, Service Mapping, Agent Client Collector, Health Log Analytics, Metric Intelligence, Cloud Provisioning and Governance, Tag Governance, Reporting, Dashboards, Process Optimization, Usage Insights, Mobile, Schedules, Visual Task Boards, Dependency Views, Dynamic Translation, Edge Encryption, Cloud Encryption with Key Management, MetricBase, Script debugger, Process Automation Designer, Proactive Triggers, Table Builder, Next Experience UI Builder, Automation Center, RPA Hub, Now Assist AI Agents, Model Context Protocol Client, ServiceNow Voice, Hermes Messaging Service, Demand Management, Application Portfolio Management, Investment Funding, Goal Framework, Alignment Planner Workspace, the GRC family (Policy and Compliance, Audit, Advanced Risk, Business Continuity, Privacy, Third-party risk ...), Operational Technology applications, most industry applications (financial services, healthcare, manufacturing, public sector, telecommunications) |
| **Basic\*** | HR Service Delivery, Release Management, Service Portfolio Management, Site Reliability Operations, Agile Development, Project Portfolio Management, SAFe, Test Management, Subscription Management, Survey Management, Time Card, Data Certification, Data Management, ODBC Driver, AI Control Tower |
| **No support** | Service Portal, Content Management System, App Engine Studio, ServiceNow Studio, App Engine Management Center, Delegated Development, Application Management, Guided Setup, DevOps Change Velocity, DevOps Config, Benchmarks, Expense Line, Digital End-User Experience, Financial Management, Cost Management, Cloud Insights, Field Normalization, Field Encryption, Encryption, Code Signing, Data Privacy, ServiceNow Vault, Document Services, Managed Documents, Remote Tables, Instance Data Replication, Search Suggestions, State Flows, Task Intelligence, Localization Framework and Workspace, Theme Builder, Transaction and Session Management, Impact, Communities, Health and Safety, Procurement Service Management, Moveworks, Structured Problem Analysis, Workflow Data Fabric Hub |
| Other wording | AI Search and Now Assist in AI Search: searches respect the domain restrictions of the indexed records. Integrations with third-party applications, Natural Language Understanding: Basic + Standard |

## Discrepancies in the docs

The table lists several products twice with different levels:

| Product | Levels given |
|---|---|
| Virtual Agent | Basic and Standard |
| Predictive Intelligence | Standard and Basic + Standard |
| Service Graph Connectors | No support and Standard\* |
| Vendor Management Workspace | No support and Basic |
| Contract Management | No support (ITSM list) while Contract Management Pro is Basic |
| Regulatory Change Management, ESG Management, Now Assist for TPRM and IRM, External Content Connectors | "No support\*" (an asterisk on *no support* is not explained) |

Check the application's own "Domain separation and ..." page before relying on a level; several vault notes record what their source page said (for example [[Change Management Overview and Lifecycle]], [[Problem Management Overview and Lifecycle]], [[On-Call Scheduling]]).

## Related

- [[Domain Separation Overview]] · [[Domain Separation Administration]] · [[Domain Separation Recommended Practices]]
