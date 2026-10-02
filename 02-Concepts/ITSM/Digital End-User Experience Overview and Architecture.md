---
type: concept
tags: [concept, assets, cmdb, security, roles, workspace, instance-admin]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Digital End-User Experience" (pp. 1776-1787: overview, users and roles, benefits, architecture, data security, isolation, retention, subscription and capacity limits, DEX or SAM, configuration sequence, system requirements, guided setup; and pp. 1883-1887: Application and Device Health pages), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Digital End-User Experience Overview and Architecture

**In one line:** Digital End-User Experience (DEX) puts an agent on employee laptops and virtual desktops, collects device, application and network metrics, shows them in Service Operations Workspace, raises alerts, and lets IT (or the employee) run fixes on the device.

## Parts

| Part | Does |
|---|---|
| **Application and Device Health** (plugin `sn_dex`) | collects and tracks experience data and performance metrics; pages in Service Operations Workspace |
| **DEX Content Playbook** | shipped policies, check definitions and remedial / diagnostic actions per operating system |
| **Desktop Assistant** (`sn_dex_desktop`) | desktop client: requests, device health, network test, notifications, Virtual Agent |
| **DEX Self-service** | widget in Desktop Assistant and Employee Center, and Virtual Agent: see device issues, apply suggested fixes |
| **Digital Experience Score** | dashboard combining device metrics, user sentiment and service desk experience |
| **Proactive Engagement** (`sn_pren`) | detects experience issues and prompts the employee to self-solve |

Detail notes: [[DEX Agent Deployment and Connectivity]] · [[DEX Monitoring Configuration, Alert Rules and Remedial Actions]] · [[DEX Desktop Assistant]] · [[DEX Workspace Pages, Insights and Device Investigation]] · [[Proactive Engagement]] · [[DEX Self-Service and Device Actions]] · [[Digital Experience Score]] · [[DEX Incident Investigation for Service Desk Agents]] · [[DEX Reference]].

## Roles

| Role | For | Contains |
|---|---|---|
| `sn_dex.admin` | access, monitored applications, onboarding, troubleshooting | `sn_dex.user`, `sn_dex.engineer`, `agent_client_collector_admin`, `report_admin` |
| `sn_dex.engineer` | running remedial actions | `sn_dex.user` |
| `sn_dex.user` | using DEX | `dependency_views`, `agent_client_collector_user`, `sow_incident_read`, `mbplus_reader`, `sam_user`, `evt_mgmt_user` |
| `sn_dex.service_desk_user` | L1 / L2 agents opening device details from an incident and running the actions allowed to them | |
| `sn_dex_desktop.admin` | configuring Desktop Assistant | |
| `sn_dex_desktop.user` | using Desktop Assistant | |

## Architecture

- DEX agents talk to **ServiceNow shared services** (multi-tenant cloud services, reached through the ITOM Cloud Services gateway), **without a MID Server**. The shared services authenticate agents, buffer messages, do stream processing into the instance and a time-series store, and carry policy updates and on-demand checks back to the agents.
- On the endpoint: **Agent Client Collector (ACC)** (collects metrics according to policy and runs remedial actions), the **DEX browser extension** (page load time, network jitter and other web application metrics, relayed through ACC), and **Desktop Assistant**.
- Registration: ACC registers on the instance over HTTPS and downloads certificates; it then opens a bi-directional **gRPC** channel to the shared services secured with **mTLS**. Raw metrics go to the shared services and are processed before reaching the instance; some configuration metrics and heartbeats go straight to the instance over REST.
- Isolation: the client certificate carries the instance name, which keeps each customer's data in its own topic (Hermes Messaging Service and Stream Connect). Certificate: ECDSA, 256-bit, NIST P-256.
- Installing DEX enables **mTLS on the instance**: older integrations with legacy security products may break and must be updated for TLS / mTLS. **SSL inspection is not supported** for DEX traffic.

### Security of actions

| Measure | What |
|---|---|
| Allowlist | shipped with the agent: only listed commands can run |
| Plugin signing | scripts are packaged in plugins that can be certificate-signed |
| Role-based access | actions are tied to roles and user criteria (advanced to engineers, basic to the service desk) |
| Audit | every run is recorded in Remedial Action Executions (`sn_reacf_remedial_action_execution`; the guide prints `ssn_reacf_...`) |

### Retention and limits

| Item | Value |
|---|---|
| Raw device metrics on the instance | at most 7 days (collected at 5-minute intervals); aggregated roll-ups longer |
| Hermes buffer | 36 hours |
| Monitored applications | 200 active per instance (property `sn_dex.max_monitored_apps`); 40 active per user per week |
| Active metric rules | 50 per instance |
| Events to monitor | 25 per operating system type |
| Offline monitoring | 24 million data points per day across all devices |
| Desktop Assistant | 75,000 devices per instance |
| Agent CPU | about 1% on average; set the ACC CPU protection threshold to 20% for DEX |

Storage is MetricBase; the collection and retention policies cannot be changed.

### Subscription

Counted in subscription units per computer where any DEX feature is active (duplicates across features removed). Ratio: **1 SU = 4 end-user computing devices**.

## DEX or SAM for application monitoring

Both use ACC. DEX: performance **and** usage, up to 200 applications. Software Asset Management: usage only (metering), scales beyond 200. DEX can feed metering data to SAM for licence reclamation.

## Requirements

Vancouver Patch 6 or later. ACC Framework 3.4.1 or 3.5.1. Browser extension: Chrome 114+, Edge 96+. Windows 10 Enterprise, Windows 11 Professional / Enterprise / Surface on ARM64; macOS Monterey, Ventura, Sonoma, Sequoia.

## Setup sequence

1. Install DEX (`sn_dex`; admin; Application and Device Health is included).
2. Install ACC and the browser extension on a test machine (convert a MID-based ACC to MID-less; on Windows run ACC as Local System for full playbook data).
3. Deploy to employees (Intune, Jamf).
4. Onboard applications for monitoring.
5. Explore the workspace pages.
6. Set up Desktop Assistant.
7. Configure Proactive Engagement, Self-service and the Digital Experience Score.

**Guided setup** cards under the DEX Administration icon: agent deployment on Windows, on macOS, browser extension, Desktop Assistant deployment, Self-service configuration.

## Where it shows up

**Workspaces > Service Operations Workspace**: landing page (active alerts, impacted devices, active devices, device world map; last two hours), **Insights**, **Applications**, **Devices**, device details, **DEX Administration** (needs `sn_dex.admin`). For service desk agents the device health page opens from an incident (classic UI) or from the **Investigate** tab in SOW: see [[Investigation Framework, CI Actions and Remedial Actions]].

## Related

- [[Service Operations Workspace for ITSM]] · [[ITSM Application Suite Overview]]
