---
type: reference
tags: [reference, integrations, cmdb]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors and API Service Graph Connectors (connector pages read 2026-10-29). https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/cmdb-sgc-available.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connectors Catalog

**In one line:** one line per Service Graph Connector documented in the Brazil Platform Capabilities guide, linking to its note. Concepts and roles: [[Service Graph Connectors Overview]].

## Public cloud

- [[Service Graph Connector for AWS]] - AWS Config (+ aggregator), SSM deep discovery, EKS through bastion hosts; IAM user and CloudFormation scripts
- [[Service Graph Connector for GCP]] - service account + JKS certificate, organisation or projects scope, OS Config patch jobs for deep discovery
- [[Service Graph Connector for Microsoft Azure]] - OAuth app, hardware connection plus optional Log Analytics software connection, delta sync via Resource Graph
- [[Service Graph Connector for Wiz]] - multi-cloud inventory from Wiz, single instance, project filters

## Endpoint and asset management

- [[Service Graph Connector for Microsoft Intune]] - Microsoft Graph app permissions; regular or advanced (report-based, paid Professional Pack) data sources; primary or enrolled user
- [[Service Graph Connector for Microsoft SCCM]] - JDBC to the SCCM SQL database through a MID Server, integrated auth, air gap with PowerShell export, software editions, Asset Intelligence
- [[Service Graph Connector for Jamf]] - basic, bearer or OAuth; Classic or Jamf Pro API; delta sync; software usage and removal
- [[Service Graph Connector for Google Chromebooks]] - Google Admin console ChromeOS devices; JKS certificate; guided setup only
- [[Service Graph Connector for Tanium]] - Tanium Asset custom view; basic or token auth; includes servers, applications and usage
- [[Service Graph Connector for Tanium Atlas]] - Tanium Atlas data, SGC Central only, Zurich Patch 4 onward
- [[Service Graph Connector for Tanium Atlas Endpoints]] - user-facing endpoints only (no servers); token bound to a service account; additional sensors
- [[Service Graph Connectors for Workspace ONE UEM (VMware and Omnissa)]] - older VMware connector (guided setup, API key) and newer Omnissa connector (SGC Central)
- [[Service Graph Connector for Active Directory]] - AD computer objects over LDAP, inactive threshold (not the user import)

## Security

- [[Service Graph Connector for Microsoft Defender for Endpoint]] - List machines API, OAuth app, machines moved from Server to Computer in 1.2.0
- [[Service Graph Connector for Qualys]] - Global Asset API (CSAM) or Asset Management and Tagging API, class mapping rule tables
- [[Service Graph Connector for Rapid7]] - InsightVM assets as unclassed hardware, API key
- [[Service Graph Connector for SentinelOne]] - Get Agents API, endpoints, servers and cloud context
- [[Service Graph Connector for Netskope]] - Netskope Client inventory, API key
- [[Service Graph Connector for Splunk]] - forwarder hosts, optional ServiceNow add-on in Splunk for extended asset data
- [[Service Graph Connector for Trellix]] - Trellix devices as servers with disks, file systems, software
- [[Service Graph Connector for Akamai API Security]] - discovered APIs into API Component for API Insights
