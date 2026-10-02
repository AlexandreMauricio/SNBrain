---
type: concept
tags: [concept, workspace, assets, reporting, incident, ai]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Digital End-User Experience" (pp. 1883-1903: Application and Device Health pages, insights, bulk remediation, Metrics analyzer, MCM, Teams and Zoom call quality, proactive resolution strategies, AI capabilities; pp. 1915-1916 and 1932-1964: landing cards, insights report fields, application pages, devices list, device details pages), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# DEX Workspace Pages, Insights and Device Investigation

**In one line:** where DEX data is looked at in Service Operations Workspace: insights reports across the estate, application pages, the device list and the many tabs of a device's details, plus the ways to act on what is found.

Setup: [[DEX Monitoring Configuration, Alert Rules and Remedial Actions]]. Overview: [[Digital End-User Experience Overview and Architecture]].

## Landing page

Cards: **Active alerts**, **Impacted devices** (from device and application alerts), **Active devices** (last 5 minutes; trend of 2 hours), **Devices** world map (drill into regions, then to the Devices page).

## Insights

Insights icon. Reports:

| Report | Columns |
|---|---|
| Battery health | device, user, OS, **Battery health** (Good, Moderate, Poor, Unknown), **Battery condition** (OS-specific values such as OK, Degraded, Service; macOS Normal, Service Needed, Permanent Failure, Check Battery), full charge capacity (mWh), percent of designed capacity, cycle count, serial number, last refresh |
| Event monitoring | user, event name, event count, OS type, log level |
| File management (Windows) | file name, category, device count (select to list the devices) |
| System compliance | user, **Compliance rating (%)** (compliant applications and policy metrics ÷ total monitored), noncompliant applications (monitored but not running on the device), noncompliant policy metrics, alert, OS, location |
| System performance | CPU, memory and disk usage (%), I/O read and write (kbps), over 7 or 14 days |
| System time | boot time, up time, time since provisioning, last boot timestamp |
| Windows registry | key path, device count where the reported value differs from the expected one ("No value (check the configuration)" when the path is incomplete or absent) |

**Custom report** (roles `sn_dex.admin`, `sn_dex.engineer`): device or application, *Latest* or *Point in time*, metric + operator + value, filters Department, Device List, Operating System; **View results**, **Export**, **Save** (up to 10 saved reports).

**Bulk remediation from Insights**: filter by operating system (mandatory except on the Windows-only pages; optionally by remedial action, operator and timeframe to see whether an action already ran), select devices, **View remedial actions**, **Run action** (at most 1,000 devices), review skipped devices, **Submit**. The playbook shows progress; **View List** per device; the **Failed** tab groups errors as Business (invalid input, unsupported or unavailable resource; only these offer **Retry action**), Configuration (for example sudo not configured), Technical, Others. All executions: DEX Administration > **Remedial action executions**.

## Applications

List: **Name**, **Type** (Web or Installed), **Alerts** (Open, Reopen or Flapping, source DEX), **Impacted devices**, **Incidents**; sorted by impacted users.

| Page | Web application | Installed application |
|---|---|---|
| Overview | active devices, alerts, incidents, current impacted devices, alerts and incidents of the last 7 days, average MTTR | the same plus **Application versions** (devices per version) |
| Performance (2 hours, 24 hours or 30 days) | started sessions, average session duration, page views; average response time, page load time, DNS lookup, failed and successful web requests, availability | crashes and freezes (total and by version; crashes come from Windows application crash event 1000), CPU, memory, I/O read and write; filter by location or version |
| Devices | Active (refreshed every 5 minutes, at most 1,000) and Impacted devices: last logged-in user and location, app last accessed, alerts | also **All devices** (devices where the app was used on Windows or is installed on macOS; refreshed every 24 hours; one row per version; tables `dex_device`, `dex_application_version`) |
| Trends (11 months) | alert trend, MTTR, average page load and response time, failed web requests, total usage | |
| Extra | page-level metrics in the Metrics analyzer | **Client health** for MCM; **Call quality** for Teams; **Zoom rooms** for Zoom |

**Metrics analyzer** (**Open in Metrics Analyzer** on a device or application): up to five metrics in one time series; filter by page name, location, OS (applications only) or date range.

### MCM client health

Needs MCM added and Advanced monitoring set. Shows devices with the client not installed, not running, or not checked in 24 hours; counts for unassigned site codes, more than one client crash, log level not 1, provisioning mode on, unhealthy client status, pending management point updates; MCM versions; devices where an inventory action (discovery data, file collection, hardware inventory, software inventory) did not run in 24 hours. Per device, **Advanced app metrics** lists the client's site code, cache sizes, version, health, management points, log settings, inventory cycles and scheduled tasks.

### Call quality

- **Teams** (application > Call quality): choose a user with a valid email and a range of at most 48 hours within the last 30 days. Summary: call quality (Good, Poor, Unclassified), call types, calls over time, network experience, and averages of jitter, packet loss rate, round-trip time, audio degradation, video frame loss, bandwidth estimate. Session breakdown by connection type, media type, codecs, OS. Data comes from Microsoft.
- **Zoom** (device > Advanced app metrics > Zoom call quality): users assigned or logged in within 15 days. Cards All, Bad, Poor, Fair, Good calls; filters device type, version, network type, location; summary (quality, issues, jitter, latency, packet loss) and breakdowns (audio, video, screenshare quality, version, OS, location, connection, device type). A rejoin counts as a new call; webinars and breakout rooms are excluded. **Zoom rooms** on the application lists rooms with issue counts.

## Devices

List tabs **All devices** and **Devices by ACC status**: **Device**, **Assigned to**, last logged-in name and user id (refreshed every 25 minutes; "-" when not a ServiceNow user), **Matches assigned to**, **Status** (Up, Down, Unknown), **Host data collection**, last logged-in location, **Alerts**, **Incidents**. **View agents table** opens the agent list.

### Device details

| Section | Content |
|---|---|
| Device health: overview | device info (type, name, model, OS and version, RAM, location, CPU id); **Computer details** (Windows: asset tag, FQDN, domain, serial numbers of BIOS, system, baseboard, chassis); memory modules; CPU; **Stability** (battery health, firewall, anti-virus, uptime, stability index, last blue screen and cause, last access, power plan); BIOS; **Boot time** with an **Investigate** button for the Otto skill; device events timeline of 24 hours (system events such as installs, logins, reboots; alerts, changes and incidents in real time); pending system updates |
| Operating system, System compliance, Alerts, Incidents | as named |
| Security (Windows) | BitLocker per volume: protection status, volume status, encryption percentage and method, key protectors |
| Battery, Hardware | battery metrics; hard drives, partitions, peripheral devices |
| File management, Windows registry | monitored files; registry key lookup (any full path) and monitored keys with expected and reported value |
| Applications, Running processes | applications on the device; CPU, idle CPU, memory; per process CPU %, CPU time, memory, PID, PPID, service |
| Application performance | installed: top 10 by memory and CPU, and per application CPU, memory, I/O, crashes (range within 7 days); web: response time, DNS lookup, page load, failed requests, availability |
| Device metrics | Memory (usage, virtual memory, pages per second, page file), CPU (usage, user application share), Disk (usage, I/O, queue length, disk time), GPU (usage, VRAM), Battery, Energy |
| Network experience | connection details (Wi-Fi, wired, VPN), app connection stability (latency, packet loss, jitter; Windows), app connection path, live application hops |

The contextual side panel has the **Action library** (roles `sn_dex.user`, `sn_dex.admin`, `sn_dex.engineer`, or `sn_dex.service_desk_user` with itil) and the **Playbook** of running and past actions.

Usage of these pages is logged in the *DEX ADH UI log* table: source id (alert or incident that led there), user persona, application or device id, user.

## Ways to resolve

| Strategy | Detect | Remediate |
|---|---|---|
| Real time, metric-based | metric rules on data collected every 5, 10 or 15 minutes → event → alert | action defined in the rule, or bulk action from the alert |
| Real time, auto-correction scripts | check definitions in policies, at a set frequency | the script detects and corrects on the endpoint, even offline (reconnect VPN or Wi-Fi, restart a service) |
| Not real time | insights reports, dashboards, your own scheduled jobs over aggregated tables (a battery replacement job ships as demo data) | bulk remediation from a report, custom flows, scheduled jobs |

Alert mechanics: one alert per device for device rules, one per application and rule for application rules (later evaluations update the same `dex_alert_metadata` record); impacted users and devices in `dex_alert_impacted_users`. A resolution on the rule creates an experience issue per impacted user (`sn_pren_experience_issue`). Action types: remedial action (CI action, catalog item, flow, Virtual Agent topic), create incident, self-help instructions, URL. Modes: silent, notify and engage (asks consent, then asks for confirmation), notify only; fallback when there is no answer or it did not help: nothing, create an incident, or live agent. The alert closes itself when no device remains impacted. The guide gives two spellings and defaults for the grouping window property (`...device.period` and `...device_period`; "default one hour" here).

## AI

Needs Otto for ITSM (`sn_itsm_gen_ai`). The **DEX issue diagnosis and resolution** agentic workflow uses a *DEX diagnosis AI agent* and a *DEX resolution plan AI agent* to find the root cause of device incidents and propose a plan the agent runs from the workspace. Skills: *Investigating Zoom call issues* and *Investigating boot time issues* (Windows). The non-AI route from an incident is [[DEX Incident Investigation for Service Desk Agents]]; the agents are listed in [[Otto for ITSM Agentic Workflows and AI Agents Reference]]. Employee-facing fixes: [[Proactive Engagement]], [[DEX Self-Service and Device Actions]]; scoring: [[Digital Experience Score]].

## Related

- [[Service Operations Workspace for ITSM]] · [[Investigation Framework, CI Actions and Remedial Actions]] · [[DEX Reference]]
