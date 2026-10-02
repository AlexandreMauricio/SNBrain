---
type: reference
tags: [reference, assets, roles, security, automation, admin]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Digital End-User Experience" > "Digital End-User Experience reference" (pp. 1912-1932 and 1964-2012: installed roles and tables, browser extension permissions, remedial actions, network experience and access pages, administration cards, application forms, metric rule and agent policy lists, Metrics analyzer, event form and shipped event configurations, non-persistent VDI parameters, metrics collected on macOS and Windows, Zoom metrics, Content Playbook policies; pp. 2013-2035: check definitions for macOS and Windows; pp. 2046-2053: properties and custom reporting tables), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# DEX Reference

**What it is:** lookup material for Digital End-User Experience: tables, shipped remedial actions, what the agent collects and how often, shipped policies and event configurations.

Concepts: [[Digital End-User Experience Overview and Architecture]] · [[DEX Monitoring Configuration, Alert Rules and Remedial Actions]] · [[DEX Workspace Pages, Insights and Device Investigation]].

## Tables

| Table | Holds |
|---|---|
| DEX Application (`dex_application`) | applications configured for monitoring; extends `sn_acc_vis_content_application` |
| Metric Rules (`dex_metric_rules`) | metric rules |
| Alert Metadata (`dex_alert_metadata`) | data about incoming events from metric rules |
| Alert Impacted Users (`dex_alert_impacted_users`) | users or devices impacted for a rule |
| Alert Locations (`dex_alert_location`) | locations impacted for a rule |
| Action App Config (`dex_action_app_config`) | applications that support the clear app cache action |
| CI Device Configuration (`dex_ci_device_config`) | device configuration including the logged-in user |
| `dex_device`, `dex_application_version` | devices and application versions used by the application pages |
| `dex_remedial_action_configuration`, `dex_remedial_action_execution`, `dex_remedial_action_execution_m2m` | remedial action setup and runs |
| `dex_jamf_policy_table` (name as printed) | predefined Jamf actions: **Action name** (format `<action> <application> <version>`), **Active**, **Application**, **Policy ID** |

The reference section lists `sn_dex.admin` as containing `report_admin`, `sn_dex.user`, `sn_dex.engineer`, `sn_cmdb_editor`, and `sn_dex.user` as containing `cmdb_read`, `dependency_views`, `mbplus_reader`, `sam_user`, `sn_cmdb_editor`, `sn_incident_read`, `sn_sow.sow_home`, `sn_sow.sow_list`, `sn_sow.sow_user`. This differs from the overview pages of the same guide (see the overview note): check `sys_user_role_contains` on the instance.

## Browser extension permissions

| Permission | Why |
|---|---|
| Storage | hold collected metrics locally between collection intervals |
| Active Tab, Tabs | know which tab is active and when a monitored application's tab opens or closes |
| Alarms | collect on a schedule rather than continuously |
| Web Request | count successful and failed requests of monitored applications (availability) |
| Declarative Net Request (with host access) | adjust Origin and Content-Type headers on calls to the extension's own reporting service only |
| Host permission | read tab URLs to recognise monitored applications and time their use |

It reads standard browser performance timings only: no page content, form data, cookies or credentials. Broad URL visibility is needed because monitored applications are only recognised at run time; data is recorded only for those and reported only to your instance. Web usage data travels extension → ACC → shared services → instance.

## Application form

| Field | Meaning |
|---|---|
| **Select an application service** | reference to Service (`cmdb_ci_service`) |
| **What domains should be monitored?** | web applications: one or more domains |
| **What processes should be monitored?** | installed applications: Windows primary process (`process.exe`) and secondary processes, macOS primary and secondary, **Web Endpoint Connection** (domains used to measure latency for cloud-connected installed applications) |
| **Enable page-level monitoring** | web: **Configure** after saving |
| **Monitoring** | *Compliance* (is the application running on devices) and *Metrics* (performance) |
| **Advanced monitoring** | MCM, Teams, Zoom |
| **Enable usage tracking (optional): SAM product** | web: reference to `samp_sw_product` when Software Asset Management (`com.snc.samp`) is installed |
| **Upload a logo** | on edit |

List columns: metrics monitoring, compliance monitoring, type, domains, Windows / macOS process.

Metric rules list: name, type (SaaS/web, installed, device), application (N/A for device), alert severities, status, action, updated. Shipped metric rules are **inactive** at install; deleting them is permanent. Agent policies list: name, hierarchy (Parent, Child, None), active, publish status, interval, cron expressions, updated. Metrics analyzer date ranges: last 2, 8 or 24 hours, 7 days, and for applications 30 days or a year, or custom.

## Event monitoring

Form (Event Log Monitoring Config): **Name**, **OS Type**, **Query Type** (Contains or Regex), **Active**, **Event message** (optional on Windows, required on macOS), **Log level** (Debug, Error, Fault, Info, Warning), macOS **Category**, **Process**, **Subsystem** (all optional; they improve accuracy), Windows **Event ID(s)** and **Log Source** (both required).

Shipped and active (count toward the 25 per OS):

| Windows | Event ID | Log |
|---|---|---|
| Resource exhaustion / low memory | 2004 | System |
| Windows Update installation failure | 20 | Setup |
| Wi-Fi WLAN connection failed | 8001 | System |
| VPN connection failure | 20227 | System |
| Application crashes | 1000 | Application |
| Windows Defender threat detected | 1116 | Microsoft-Windows-Windows Defender/Operational |
| Device driver load failure | 219 | System |
| Failed login attempt | 4625 | Security |
| Unexpected system shutdown | 41 | System |
| USB device connected | 2003 | System |
| MSI installer failure | 1024 | Application |

macOS (9): VPN disconnected, Software installation failed, Software update failed, USB storage mounted, Login failed, Wi-Fi disconnected, USB device connected, Kernel panics, Application crash (matched by process, subsystem and a message substring or regex).

## Shipped remedial actions

Privileges: Windows mostly needs the agent running as Local System; macOS needs the sudo rules.

| Action | Inputs | OS |
|---|---|---|
| Add a registry key / Modify a registry key value | `registry_path`, `registry_data`, `registry_type` | Windows |
| Clear application cache | `app_name`, `auto_close`, `process_name`, `cache_path` | Windows, macOS |
| Clear browser cache | `browsers` | Windows |
| Clear DNS cache | | Windows, macOS |
| Clear Google Chrome browsing data | remove web data (true / false) | Windows, macOS |
| Clear Recycle Bin | | Windows, macOS |
| Configure device power scheme | `power_mode` (Low Power, Automatic, High Power) | macOS |
| Modify device battery power plan | `power_mode` | Windows |
| Delete a file | `file_name_or_path` | Windows |
| Map network drive / Delete network drive | `action` (MAP or DELETE), `drive_letter`, `network_path` | Windows |
| Disable startup program | `startup_programs` | Windows |
| Disk cleanup for low disk space | | Windows (dump files, Windows Temp, temporary internet files, log files, WER report queue), macOS (caches older than 7 days, Xcode derived data, Homebrew cache, `/tmp` older than 3 days) |
| Elevate temporary admin access | `user_name` (Windows) or `user_id` email (macOS), `duration` 1, 2, 4 or 8 hours | Windows, macOS |
| End process | `process_name` or `pid` | Windows, macOS |
| Kill zombie / orphan processes | `app_name` | Windows, macOS |
| Execute Jamf policy | `policy_id` or a predefined action | macOS |
| Modify USB storage access | `access` (Read, Write, Execute), `value` (Allow, Deny) | Windows |
| Remediate Zscaler connectivity | | Windows, macOS |
| Repair corrupt Outlook files | | Windows (SCANPST; reliable up to about 2 GB, poor beyond 20 GB) |
| Reset Google Chrome browser settings | | Windows, macOS |
| Reset network adapter | | Windows, macOS |
| Restart Audio Services | `service_name` (AudioEndpointBuilder, Audiosrv) | Windows |
| Restart Microsoft OneDrive | | Windows, macOS |
| Restart Microsoft Outlook | `process_name`, `app_name` | Windows |
| Restart service | `service_name` | Windows, macOS |
| Uninstall an application | `app_name` (from a configured list) | Windows |

## What the agent collects

Check definitions are named `os.win.check-...` and `os.mac.check-...`. Typical intervals: 5 minutes for performance gauges, 10 or 30 minutes for network measurements, 1,440 minutes (daily) for inventory snapshots.

| Family | Every 5 minutes | Daily (or on demand) |
|---|---|---|
| Application | CPU usage, RAM usage, I/O read and write, is running, uptime, last access time, crashes, freezes (Windows: Event Log 1000, WER 1001 and Application Hang 1002; only applications that report through Windows Error Reporting), Zscaler service status (Windows) | version, is installed, last updated, listening ports, MCM / SCCM client data; Windows network per domain: latency, packet loss, jitter (10 minutes) and hop-by-hop route (30 minutes) |
| Device | CPU usage and user time, memory details, disk usage and available, disk I/O and queue counters, crashes, battery charge, energy and power consumption (not on virtual machines), Wi-Fi rates and signal (Windows) or RSSI (macOS), GPU usage and VRAM (Windows) | device, CPU, OS, BIOS, battery, disk and hard drive details, firewall, antivirus and antimalware, BitLocker, blue screens in 30 days and cause, stability index, power plan, pending updates, logged-in users, user profiles, admin users, network details and connection profiles (VPN inference; 30 minutes), peripherals, executables list, registry keys, system compliance, reboot details, device events, last access time, OS age |

macOS sources: osquery tables, `top`, `vm_stat`, `powermetrics`, `mdls`, `system_profiler`; application last-access data only covers 7 days (log retention). Windows sources: performance counters (`typeperf`), Event Log, `netsh wlan`, `tracert` for the route.

### Content Playbook policies

| Policy | Check instances (frequency) |
|---|---|
| DEX Mac Apps Metrics | `os.mac.check-app-historical` (5 minutes → MetricBase) |
| DEX Mac Device Metrics | `...system-metrics-latest` (24 hours → instance), `...system-metrics-historical` (5 minutes; `vpn_details` every 30), `...process-data` (24 hours), `...sys-compliance-historical` (5 minutes) and `-latest` (24 hours), `...energy-consum-historical` (5 minutes; skipped if the previous run is still going) |
| DEX Windows Apps Metrics | `os.win.check-app-historical` (5 minutes), `os.win.check-app-sccm-latest` (24 hours) |
| DEX Windows Apps Domain Network Monitoring Metrics | `...app-dom-network-historical` and `...web-app-dom-net-historical` (10 minutes), `...app-dom-network-latest` (30 minutes: route). Needs ACC 4.2+ and browser extension 2.5.0+; no path-level URLs |
| DEX Windows Device Metrics | `...system-metrics-latest` (24 hours), `...system-metrics-historical` (5 minutes; connection profiles every 30), `...process-data`, `...sys-compliance-*`, `...system-executables-latest`, `...system-registry-latest` (24 hours) |
| DEX Get online Windows / macOS user on change | `...system-custom-query-on-chan` (60 seconds) |
| DEX Get device configuration on change | `os.all.check.internal.get-device-configu` (60 seconds) |
| Persistent VDI variants | the same Windows policies for persistent virtual desktops |

"Historical" = kept in MetricBase for 7 days; "latest" = most recent value on the instance. Several Windows parameters (`uptime`, `energy_consumption`, `bitlocker_details`, `last_access_time`, `pending_updates`, `user_profiles`) are only collected when ACC runs as Local System. After upgrading the playbook plugin, unexpected policy update problems are covered by KB1586917.

## Check definitions

Agent Client Collector check definitions shipped by DEX (**Agent Client Collector > Configurations > Check Definitions**). They run on the endpoint under the agent account. Some return data that may count as personal information.

**Application checks** take `--appName`, `--appSysId` (sys_id of the application), `--primaryProcess` (pipe-separated list; the first process that exists on the device wins, for example `teams.exe|msteams.exe`) and `--secondaryProcesses` (pipe-separated).

| Area | macOS (`os.mac.check-app-...`) | Windows (`os.win.check-app-...`) |
|---|---|---|
| Resources | `cpu-usage`, `memory-usage`, `io-usage-read`, `io-usage-write`, `listening-ports` | `cpu-usage`, `memory-usage`, `incoming-network-bytes`, `outgoing-network-bytes` (extra `sleep_time`) |
| State | `is-running`, `uptime`, `is-installed`, `version` ("unversioned" when none), `last-updated`, `last-access-time` | `uptime`, `last-updated`, `last-access-time` |
| Stability | `crashes`, `freezes` (last 5 minutes) | `crashes` (Windows Error Reporting event 1000), `os.win.check.app.freezes` (events 1001 or 1002) |
| Network | `domain-network-latency` (`--domain`) | `domain-network-details` (latency, packet loss, jitter by ICMP), `domain-network-route-details` |
| Other | `zscaler-service-status` | `zscaler-service-status`, `os.win.check-app-sccm` |

Most need the application running; on macOS version, is-installed, last-access-time and last-updated do not, on Windows crashes and last-access-time do not. Last access time is empty when the application was not run in 7 days (Windows also when the process path changed, for example after an update). On Windows the 7 days come from the registry value `UserSettingsLifetimeMs` (REG_DWORD, milliseconds) under `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\BAM`.

**Device checks** (`os.<mac|win>.check-system-...`): `cpu-usage`, `cpu-details`, `memory-usage`, `last-access-time`, `uptime`, `time` (UTC, UNIX timestamp), `device-crashes`, `device-events`, `disk-usage`, `disk-io-usage-read` / `-write`, `os-details`, `logged-in-users`, `network-details`, `battery-details`, `battery-charge-percentage`, `firewall-enabled`, `admin-users`, `reboot-details`, `os-setup-details` (approximate OS age), `compliance-details`, `energy-consumption`, `power-consumption`, `custom-query-on-change`, device-configuration-on-change.

| Only macOS | Only Windows |
|---|---|
| `device-details`, `disk-details`, `net-bytes-incoming` / `-outgoing`, `session-details`, `pending-updates`, `vpn-details` | `power-plan`, `bsod`, `antimalware-details`, `network-adapter-details`, `network-connection-profiles` (network type, used to infer VPN), `windows-registry`, `memory-details`, `bios-details`, `executables`, `boot-details`, `gpu-usage-details` |

Notes:

- **Compliance score** = (compliant applications + compliant metric values) ÷ (total applications and metric values − failed ones) × 100. An application is compliant when every primary process is running; a metric when its value equals the expected one.
- macOS device crashes = kernel panics in the logs of the last five minutes. Windows device crashes use system events 41 and 1001; `bsod` uses 1001.
- Windows **boot time** is captured only on a full boot (Event ID 100), not on resume, restore or remote / virtual machine starts. Reboot details can be wrong when a reboot was interrupted.
- macOS **energy consumption** needs `/usr/bin/powermetrics` in the sudo rules, takes about five minutes (it measures the next five), and does not work when the agent runs under Rosetta on Apple Silicon. Windows energy consumption is the sum of the last five minutes in mWh and needs energy sensors (no virtual machines); power consumption only on physical machines.
- Battery checks do not apply to virtual machines or desktops; capacity above design capacity is shown as 100%.
- Windows last access time works on locked and unlocked devices; its first run reports an error because there is no earlier data.

**Diagnostic checks** (`os.<mac|win>.check-...`): `app-process-ids` (`--process_name`; parent and child PIDs), `process-cpu`, `process-memory`, `process-disk` (macOS also `process-data`), `services-data` (`service_type` = user, system or all), macOS `traceroute` (`--url`, `--max_hops` default 65, `--timeout` default 5) and `ping-test` (`--url`), Windows `rssi-value` (not on virtual machines).

**Remedial checks** (`os.<mac|win>.action-...`), the base of the shipped remedial actions above:

| Both | macOS only | Windows only |
|---|---|---|
| `kill-process` (`--pid` or `--process_name`; PID wins; Windows takes a comma-separated list), `restart-service`, `clear-app-cache` (`auto_close`, `process_name`, `app_name`, `cache_path`), `zscaler-zpa-reconnect`, `restart-one-drive`, `clear-google-chrome-browsing-data` (`remove_web_data`), `purge-recycle-bin`, `reset-google-chrome-settings` (also removes extensions, all profiles), `elevate-temporary-admin` (`duration`, `user_id`), `kill-zombie-orphan-process` (app name; returns the killed PIDs) | `execute-jamf-policy` (policy id, or a predefined action from the Jamf policy table so agents need not know ids; the Jamf client must be on the device), `toggle-power-mode` (Automatic, High power, Low power) | `flush-dns-cache`, `clear-browser-cache` (`auto_close`, `browsers`: Chrome, Firefox, Edge), `network-drive` (`action` MAP or DELETE, `drive_letter`, `network_path`), `restart-application`, `removable-usb-storage-access` (`access` deny_read / deny_write / deny_execute, `value`; needs a restart; no effect when Group Policy or an endpoint tool already controls it), `uninstall-application`, `disk-cleanup`, `windows-registry-action`, `delete-file` (permanent; needs a file extension), `toggle-power-plan` (Balanced, High performance, Power saver), `fix-classic-outlook-data-files` (SCANPST) |

`cache_path` is supported for Zoom, Outlook and Teams and is given relative to the user folder (for example `AppData\Roaming\Zoom\data`).

**Non-persistent VDI policies** use `os.win.check-system-metrics-historical` (5 minutes: memory details, I/O read and write, CPU usage), `os.win.check-system-metrics-latest` (24 hours), the application historical check (CPU, memory, uptime, last access, crashes, is running, freezes) and `os.win.check-app-sccm-latest`.

## Properties

Admin role. Application *Application and Device Health* unless noted.

| Property | Default | Meaning |
|---|---|---|
| `sn_dex.alert.correlation_rule.device.period` | 300 | seconds for grouping similar device alerts by message key; 0 disables |
| `sn_dex.alert.delete_delay_period` | 15 | minutes before a closed alert tied to `dex_alert_metadata` is deleted |
| `sn_dex.dex_user_ref_mapping` | JSON | maps the device user id to a custom user column, with prefix and suffix |
| `sn_dex.enable_dex_action_playbook` | true | shows the playbook on the device details page |
| `sn_dex.extension.push_metrics_interval` | 300 | seconds between pushes from the browser extension to the agent |
| `sn_dex.extension.session_timeout` | 240 | minutes after which an open tab session times out (by last access); 0 turns it off |
| `sn_dex.network_performance_metrics_duration` | 7200 | seconds of network performance metrics |
| `sn_dex.set_location` | true | DEX creates a `dex_location` record when no valid location is found |
| `sn_dex.administration_tab_doc_link` | URL | documentation link on the administration card |
| `sn_dex_content.enable.content.log` (DEX Content Playbook) | false | store check execution details in `dex_content_log` |
| `sn_dex_desktop.app_version` / `.app_snapshot_version` (Desktop Assistant) | 2.5.0 / 2.0.0 | client version numbers (snapshot is for development) |
| `sn_dex_desktop.enable_notification` | false | whether notifications are sent (the notification pages call it `sn_dex_desktop.enable_push_notification`) |
| `sn_dex_desktop.mac_min_version` / `.win_min_version` | 2.6.0 | minimum compatible client |
| `sn_dex_desktop.sn_desktop_assistant.notification_time_to_live` | 7 | days a notification stays valid (maximum 7) |
| `sn_dex_desktop.va_portal_param` | esc | portal used for the Virtual Agent integration |

Proactive Engagement and DEX Score properties: [[Proactive Engagement]], [[Digital Experience Score]].

## Tables for custom reports

| Table | Refresh | Data |
|---|---|---|
| `dex_device_metrics_daily_avg` | daily | per device averages: battery health, CPU, disk usage and read rate, memory, energy, I/O read and write, Wi-Fi RSSI, receive and transmit rate |
| `dex_score_device_adh_metric_each_agent_weekly` / `_monthly` | weekly / monthly | the same, aggregated |
| `dex_installed_app_metrics_daily_avg` | daily | installed application performance |
| `dex_score_installed_application_adh_metric_each_agent_weekly` / `_monthly` | weekly / monthly | crashes, usage, CPU, memory |
| `dex_web_app_metrics_daily_avg`, `dex_score_web_application_adh_metric_each_agent_weekly` / `_monthly` | daily / weekly / monthly | usage, DNS lookup, failed web requests, page load, response time |
| `dex_ci_device_system_compliance` | daily | compliance rating, noncompliant applications and policy metrics |
| `dex_ci_device_battery_health` | ? | battery health, design and full charge capacity, condition, serial, status, chemistry, cycle count, design voltage |
| `dex_ci_device_system_time_report` | ? | uptime, boot time, last reboot, device age |
| `dex_ci_device_pending_update`, `dex_ci_device_user_profile`, `dex_ci_device_logged_in_user_activity`, `dex_ci_device_metrics` | daily | pending OS updates; Windows user profiles; logged-in users; memory, stability, antivirus, firewall, uptime, power plan |
| `sn_reacf_remedial_action_execution` | on run | remedial action, parent record, target device, state, origin application |
| `sn_pren_experience_issue` | on engagement | experience issue, issue registry, state, end reason, fallback result, origin (Self-service, Desktop Assistant, device actions, Otto, Proactive Engagement, service desk agent) |

## Zoom metrics

Call quality uses the Mean Opinion Score from latency, jitter and packet loss, per channel (audio, video, screen share, in and out); the worst channel sets the call's rating: Good (4.0 to 5.0), Fair (3.0 to under 4.0), Poor (2.0 to under 3.0), Bad (1.0 to under 2.0), Unclassified (no data). Call issues: unstable video, reconnection problems, poor screenshare quality, unstable audio, high CPU usage. The Details page lists per call: meeting and call id, join and leave time, issues, device type, health, overall / audio / video / screenshare quality, connection type, average latency, packet loss, jitter, bitrate, resolutions, frame rate, Zoom CPU usage, location, OS, version, microphone, speaker, camera and screenshare flags.

## Non-persistent VDI files

Scripts (from ServiceNow Customer Support), recommended in `C:\DEXScripts\`: `logon_script.ps1` (restores the certificate) called by `logon_script.cmd` at session start; `logoff_script.ps1` (pushes remaining metrics) called by `logoff_script.cmd` at session end. `acc.yml`: `persistence_type: non_persistent`, `disable-asset: true`, `agent-key-id` removed. Procedure: [[DEX Agent Deployment and Connectivity]].

## Related

- [[Digital End-User Experience Overview and Architecture]] · [[DEX Agent Deployment and Connectivity]] · [[DEX Desktop Assistant]] · [[Proactive Engagement]] · [[DEX Self-Service and Device Actions]] · [[Digital Experience Score]] · [[DEX Incident Investigation for Service Desk Agents]]
