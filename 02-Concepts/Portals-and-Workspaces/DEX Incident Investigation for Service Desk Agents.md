---
type: concept
tags: [concept, workspace, incident, automation, assets]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Digital End-User Experience" > "DEX for service desk agents" (pp. 2135-2144: incident investigation with DEX, device health checklist, top processes by CPU and memory, suggested resolutions, Action library, Playbook, automatic work notes), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# DEX Incident Investigation for Service Desk Agents

**In one line:** when an incident's configuration item is a DEX-monitored device, the incident's **Investigation** tab in Service Operations Workspace shows device health, top processes and suggested resolutions the agent can run without leaving the record.

Available from Zurich; needs Service Operations Workspace for ITSM 8.2 or later ([[Service Operations Workspace for ITSM]], [[Investigation Framework, CI Actions and Remedial Actions]]). Roles to execute: `sn_dex.service_desk_user`, `sn_dex.engineer`. The AI alternative is the *DEX issue diagnosis and resolution* agentic workflow ([[Otto for ITSM Agentic Workflows and AI Agents Reference]]).

## Device health

Categories rated Good, Average or Poor: **Device performance**, **Network stability**, **Security status**, **Application performance**.

**Device health checklist**: **Show** = Latest available data (default), Last 24 hours, Last 7 days, or a custom range within 7 days. Basic metrics by default; **Show additional metrics** adds the ones whose metric definition has visibility *Advanced* ([[Digital Experience Score]]). Refresh icon for the latest data. **View detailed device health** opens the device details page ([[DEX Workspace Pages, Insights and Device Investigation]]).

- *Device metrics*: last access, memory, logged-in users, last blue screen and cause; CPU, disk and memory usage, uptime, crashes, reboot duration; Wi-Fi RSSI and transmit rate; firewall and antivirus status.
- *Application metrics* (pick the application): type, status, usage time, version, last access; CPU and memory, crashes and freezes, average page load and response times.

## Top processes by CPU and memory

A graph of snapshots; each snapshot holds the top 10 processes by CPU and by memory (name, value, latest PID) and their combined averages. Offline periods show zero or no points.

| Timeframe | Data |
|---|---|
| At incident creation (default) | every 30 minutes for the six hours before creation; nothing for incidents older than seven days |
| Last 6 hours | every 30 minutes; Refresh captures one on demand (device online only) |
| Custom | 30-minute snapshots for a **Day** and **Slot** within seven days |
| Last 12 hours / 24 hours / 2 days / 7 days | aggregated hourly / every 2 hours / every 4 hours / every 24 hours |

- Average CPU % = sum of the top 10 CPU percentages ÷ 10.
- Average memory % = ((memory used by the top 10 ÷ device memory) × 100) ÷ 10.
- In aggregated ranges the point is the mean of the snapshot averages; a process appearing in several snapshots is merged into one row with combined usage, so fewer than 10 rows may show. A range needs the device to have been connected long enough to fill its aggregation interval.

## Suggested resolutions

Cards: resolution name, category, issue and description, impacted metrics, source, last attempt, status.

| Type | Agent action | Completed state |
|---|---|---|
| Self-help instruction | **View self-help instructions**, then **Mark as completed** | Completed |
| Catalog request | **Create catalog request** | Item requested, Request completed |
| Help resource | **View help resource**, then **Mark as completed** | Completed |
| Remedial action | **Run action** (several: tick them and **Run selected actions**) | Completed, Action failed |

When a remedial action needs end-user approval the progress bar stops at *Awaiting user approval*: get the approval from the user, open the **Playbook** icon > device > action card > *User approval check* > tick > **Submit**. The **Completed** tab lists only actions run from Suggested resolutions.

**Action library** (contextual side panel): any available remedial action > **Run action**.

**Playbooks panel**: actions from Suggested resolutions, the incident's Action library and [[Proactive Engagement]]. Current = New or In Progress (**View Playbook**, **Cancel**; cancel only for those started from this incident); **History** = Completed, Canceled, Failed.

## Automatic work notes

When **Configuration item** (`cmdb_ci`), **Service** (`business_service`) or **Service offering** (`service_offering`) on an incident is set at creation or changed to something DEX monitors (a device with a DEX agent connected; a monitored application, service or offering), a work note is added saying so, with a link into DEX. Wording differs for "is" (new incident) and "has been updated to" (change), and for device versus application CIs. Independent of the Investigation tab.

## Related

- [[DEX Self-Service and Device Actions]] · [[DEX Monitoring Configuration, Alert Rules and Remedial Actions]] · [[DEX Reference]]
