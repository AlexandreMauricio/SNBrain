---
type: concept
tags: [concept, assets, cmdb, automation, scripting, admin, integrations]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Digital End-User Experience" (pp. 1804-1838: application monitoring, page-level monitoring, metric and event alert rules, metric collection and agent policies, offline monitoring, remedial actions including custom PowerShell actions, event monitoring, registry, file and compliance setup; pp. 1855-1876: Microsoft 365 and Zoom, alerts and alert grouping, converting an application source, user mapping, device location), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# DEX Monitoring Configuration, Alert Rules and Remedial Actions

**In one line:** what a DEX administrator configures after the agents are out: which applications and pages are monitored, which rules raise alerts, which metrics the agent policies collect, and which remedial actions can be run on devices.

**Where:** **Workspaces > Service Operations Workspace > DEX Administration** icon (role `sn_dex.admin`). Overview: [[Digital End-User Experience Overview and Architecture]]. Agents: [[DEX Agent Deployment and Connectivity]].

## Application monitoring

Card **Application management > Configure applications**. A shipped list of applications exists, all switched off.

- **New > Installed app** or **New > Web app**, fill the form, turn the monitoring toggle on, **Save**. Bulk: select rows > **Actions > Turn on metrics monitoring** / **Turn off metrics monitoring** / **Delete selected applications**.
- **Advanced monitoring** only for Microsoft Configuration Manager (MCM), Microsoft Teams and Zoom (call quality).
- A logo is added through **Add/Edit image** on an existing application.
- **Page-level monitoring** (web applications; needs the browser extension; roles admin, `sn_dex.admin`): on the application, **Configure** under *Enable page-level monitoring* > **New**: **Page Name**, **Domain**, **Application**, **Pattern Type** (Exact or Wildcard: `*` for one path segment, `**` for any depth), **Page Path**, **Full URL** (computed), **Metric Monitoring** (on by default). Results appear in the Metrics analyzer.
- **Convert a Visibility Content application to DEX**: list `sn_acc_vis_content_application`, record with **Source** = `sn_acc_vis_content` and a **Service** filled > **Convert to DEX app**. Irreversible; the application then counts toward the 200 limit.

### Call quality integrations (installed with DEX)

| Product | Setup |
|---|---|
| DEX for Microsoft 365 (Teams) | Azure **App registrations > New registration**; note client id and tenant id; add a client secret; Microsoft Graph **application** permissions `User.Read.All` and `CallRecords.Read.All`; **Grant admin consent**. Then **Flow Designer > Integrations > Connections**, alias *DEX for Microsoft 365* > **View Details > Configure**: URL `https://graph.microsoft.com`, API version `v1.0`, token URL `https://login.microsoftonline.com/<tenant-ID>/oauth2/v2.0/token`, `<CLIENT_ID>`, `<CLIENT_SECRET>` > **Configure and Get OAuth Token** |
| DEX for Zoom | Zoom Marketplace **Develop > Build App > General App**, admin-managed; redirect URL and allow list `https://<instance>.service-now.com/oauth_redirect.do`; scopes `report:read:user:admin`, `dashboard:read:list_meeting_participants_qos:admin`, `dashboard:read:meeting_participant_qos:admin`, `dashboard:read:list_zoomrooms:admin`, `dashboard:read:issues_zoomroom:admin`, `user:read:user:admin`. Then **Workflow Studio** connections, *DEX for Zoom* > **Configure**: URL `https://api.zoom.us`, client id and secret, redirect URL > **Configure and Get OAuth Token** |

Then enable monitoring on the application with the matching advanced option.

## Alert rules

Card **Alert rules > Configure > Create new rule**. At most 50 active metric rules.

### Metric rule

1. **Select the CI**: Device, SaaS / web application, or Installed application (pick the application). **Applicable for Non-persistent VDIs** (then only Location can be used as filter). Optional filters: Device, Department, Location, OS, User, Version (installed apps), or condition sets on any column of Computer (`cmdb_ci_computer`) or User (`sys_user`). A column used as a filter becomes an *enriched* field synced to devices; a newly used one can take up to 24 hours to sync; up to 15 non-default enriched fields.
2. Type: **Static** (evaluates real-time data against thresholds, on the server) or **Zscore (running average)** (deviation from the device's own 7-day mean, evaluated on the endpoint; default bounds 5 to -5; alerts on sampled values only).
3. **Criteria**: **Alert severity** and thresholds per metric (several severities possible); optional threshold on the number of impacted users; *Alert when* either all sampled values, or the average of sampled values, in a period breach; optional *Clear the alert when*.
4. **Alert action** (optional; needs Proactive Engagement `sn_pren`): **Add resolution** (proactive resolution content, then engagement settings).
5. **Name** and **Active** (active by default) > **Finish**.

### Event rule

**Create new rule > Event rule**: OS type, VDI switch, filters on Device or User; severity, thresholds and period; clear condition; name and status.

Edit, activate / deactivate (step *Name the rule*) or delete from the list. Deleting is permanent. Changes to an alert action or proactive resolution are saved even if the rule is closed without saving.

## Alerts

Events with **Source** = DEX and **Type** = DEX Metric Rules in Event (`em_event`) become alerts in Alert (`em_alert`) with **Metric name** *DEX App Metric* or *DEX Device Metric* and the application or device as **Configuration item**.

In the workspace an alert has tabs **Overview** (summary, impact with impacted devices and users, cause), **Details** (metric, history), **Related records** (services, CIs, impacted devices and users, repeated alerts, remedial action history; needs `sn_sow_em` 26.3.1) and **Remediate issue on devices** (devices grouped by OS and status; one selected = single-device actions, several = bulk actions). An incident created from the alert shows the DEX data on its origin card (needs `com.snc.uib.sow_incident` 7.1.0+).

**Grouping**: alert correlation rule *DEX Metric Correlation Rule* (**Event Management > Rules > Alert Correlation Rules**) groups alerts of the same metric rule, whatever the CI: the first is primary, later ones secondary; closing the primary closes the group. Property `sn_dex.alert.correlation_rule.device.period` is the window in seconds (for example 300); alerts of the rule arriving within it join the group, later ones start a new group. Turn grouping off with value 0 or by deactivating the rule.

## Metric collection (agent policies)

Card **Agent policies > Manage policies**. A policy = the CIs it applies to + the checks that run on them. Metric families: Windows and macOS device and application performance.

- **Frequency**: open the policy > **Edit in Sandbox** > check instance > **Override interval (sec)** > **Update** > **Return to Policy** > **Republish**.
- **Different metrics for some devices**: **Create Child** on a policy (inherits it), rename, add a filter on **Monitored CIs**, save; on the check instance open **Check Parameter** > *metrics* and edit; **Publish** (status Draft → Ready to publish → Queued → Published).
- **New policy**: name; **Monitored CIs** (manual calculation, CI type by filter, by script, or by CMDB group); **Checks** (move from Available to Selected; filter by check group); optional proxy; **Scheduling** (interval in seconds, or cron expression in the device's time zone; an interval on the check definition wins); credentials; **Save** then **Publish**.
- **Offline monitoring**: scheduled job *DEX Data Loss Handler* (installed inactive; hourly once active) resends OpenTelemetry metrics collected while a device was disconnected. Only for agents currently active.

## Remedial actions

Run from a device page (single device) or from an alert (single or bulk). Bulk needs *Available for bulk remediation* on the action.

**Create** (DEX Administration > *Create Remedial Actions* > **Create new**): *Create net new action* or *Map to an existing remedial action* (same action for another OS); name, description, **roles** that may run it (`sn_dex.engineer`, `sn_dex.service_desk_user`), **origin** (device health page or alert), bulk flag, operating system, base **Check Definition** (its parameters are then listed).

| Table | Holds |
|---|---|
| `dex_remedial_action_configuration` | `os` (macOS, Windows, all), `source` (alert, configuration_item), `playbook_type` (generic, tailored), `check_definition`, `is_bulk_action`, `active` |
| `dex_remedial_action_execution` | `state`, `device_list`, `source_record_table`, `source_record_id` |
| `dex_remedial_action_execution_m2m` | links the UI execution to the actual execution record |

**End a process** (roles `sn_dex.engineer`, `sn_dex.admin`): device > **Running processes** > Action library > *End process* > **Start** > confirm *I received approval to trigger this action* > enter the **Process ID**. The device's **Playbook** panel shows current and past actions from all sources (device Action library, incident Action library, Self-service, Proactive Engagement) with **View Playbook**, **Cancel** (only for actions started from the device page) and a **History** tab.

### Custom PowerShell action (Windows)

1. **Plugin package**: a root folder (for example `acc-dex-custom`) with `bin` (the `.ps1` script and a Ruby `.rb` wrapper that runs it through the `acc-f-commons` command runner, checks success and prints a result JSON with `status`, `type`, `metric_type` = `remedial_action`, `keys`, `data`, `message`) and `allowlist` (a JSON allowlist naming the Ruby script). Archive as `<root folder name>.tar.gz`.
2. **Sign**: `openssl req -nodes -x509 -sha256 -newkey rsa:2048 -keyout sign.key -out sign.crt -days 365 ...`; `openssl dgst -sha256 -sign sign.key -out sign.txt.sha256 <plugin>.tar.gz`; verify with the extracted public key; Base64-encode the signature to `sign.txt.sha256_encode64.sig`; tar the plugin and the signature together. Put `sign.crt` in the agent's `cert` folder on the devices (by hand, Jamf or Intune) and in the OS trust store.
3. **Upload** the signed plugin (Agent Client Collector plugins).
4. **Check definition** (**Agent Client Collector > Configurations > Check Definitions > New**): **Name**, **Check type**, **Command** = the `.rb` file name, *When to send the check results*, **Plugins** = `acc-f-commons` and the custom plugin.
5. **Test check** (related link) against one agent; confirm the plugin folder was downloaded and the action ran.

Runs on the endpoint under the agent's account; scope is the ACC plugin, not an instance script.

## Event monitoring

System events (Windows Event Log ids; macOS log lines matched by a regular expression) complement metrics. Card **Event log monitoring > Configure > New** (name, event id or regex, description, OS). Up to 25 per OS, including the shipped ones that are active by default.

## Registry, files, compliance

| Card | Setup |
|---|---|
| Windows registry management | **Add registry keys**: full key path and one expected primitive value (max 1024 characters each); up to 20 keys |
| File management | **Add files**: `.exe` file name (max 256 characters) and category (Application, Malicious, Security, Development tools, System, Others, Installers, Potentially Unwanted Programs); up to 20 files; data appears after the next policy run |
| System compliance | choose compliance policy values (**Turn on monitoring**), the applications and the metric rules that make up the compliance report |

## Users and locations

- **Device user ↔ ServiceNow user**: by default the device user id is matched to **User ID** (`user_name`). Property `sn_dex.dex_user_ref_mapping` (scope DEX Application and Device Health) takes JSON `{"prefix": "", "device_user_id_column": "<column>", "suffix": "@example.com"}`.
- **Device location**: property `sn_dex.location_determination`:

| Value | Logic |
|---|---|
| `geoIP_determined_location` (default) | GeoIP of the network connection; nothing to configure for the map |
| `default_gateway_determined_location` | default gateway matched to a switch in `cmdb_ci_ip_switch`; that switch's location |
| `device_user_assigned_location` | location of the computer CI, else of its owner |

If nothing matches the device is *Remote*, shown as "Remote, Country" or "Remote, State, Country" (property `sn_dex.remote_location_config`: `country` or `include_state`). For the map with the two non-default options, the location records need standard state and country codes (matching `sys_report_map_source_mapping`) and latitude / longitude.

## Related

- [[DEX Agent Deployment and Connectivity]] · [[DEX Workspace Pages, Insights and Device Investigation]] · [[DEX Reference]] · [[Investigation Framework, CI Actions and Remedial Actions]]
