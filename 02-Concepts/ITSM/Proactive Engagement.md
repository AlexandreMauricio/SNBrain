---
type: concept
tags: [concept, automation, notifications, incident, assets, admin]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Digital End-User Experience" > "Proactive Engagement" (pp. 2083-2109: overview, setup, resolutions with DEX, email channel, user criteria, employee and agent experience, shipped solutions, throttling properties, alert closure, workbench, roles and tables, resolution types, input parameters, engagement settings, limitations, use cases), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Proactive Engagement

**In one line:** Proactive Engagement (`sn_pren`) takes an issue that a DEX metric rule detected on an employee's device, tells the employee, and with their consent fixes it or guides them, falling back to an incident or a live agent when that does not work.

It ships inside the Digital End-User Experience bundle ([[Digital End-User Experience Overview and Architecture]]). The same resolutions are reused on demand by [[DEX Self-Service and Device Actions]].

## Flow

1. A metric rule ([[DEX Monitoring Configuration, Alert Rules and Remedial Actions]]) breaches its threshold → alert → the rule's **alert action** fires.
2. An **Experience Issue** (`sn_pren_experience_issue`) is created per impacted user: the source of truth for the engagement (user, state, end reason, fallback result).
3. The employee is notified on the configured channel and can accept or ignore.
4. On consent the resolution runs (or is shown), through Virtual Agent.
5. The employee confirms whether it helped; if yes, feedback is requested.
6. If the resolution failed or the employee says it is unresolved, the **fallback** runs: create an incident, or route to a live agent.

**Agent side:** the fallback incident carries an *interaction summary* (resolution run and its outcome) in **Work notes** (`work_notes`), and the experience issue is recorded as the incident's origin.

## Setup

Prerequisites: Glide Virtual Agent (`com.glide.cs.chatbot`), the Remedial actions framework plugin (for the remedial action resolution type), valid entitlements. Install the application from the Store (role admin). The guide gives the application id as `com.snc.proactive_engagement` in the install steps and `com.snc.self_remediation_framework` in the reference section: check the instance.

| Setting | Purpose |
|---|---|
| Property `com.glide.cs.notification_newuser_webclient` = true, and notifications enabled for all users on the live agent setup record | Virtual Agent notifications become visible |
| Property `sn_pren.continue_engagement_if_user_is_in_active_VA_conversation` | when enabled, no new conversation is started while one is active; the experience issue is closed as `close_skipped` and retried after 72 hours if the issue persists |

### Add a resolution to a metric rule

DEX Administration > **Metric rules** > create or edit a rule (CI selection, alert criteria), then in the alert action step **Add resolution**: choose the resolution type and its details, **Continue to Engagement Settings**, fill them, **Add Resolution**, then name and activate the rule. Adding an alert action needs `sn_pren.engagement_admin`. Every time the rule's criteria are met the resolution is triggered, subject to throttling.

### Resolution types

| Type | What the employee gets |
|---|---|
| Remedial action | an action run on the device with consent: a device action, an existing Virtual Agent topic, or a catalog item to fill in ([[Investigation Framework, CI Actions and Remedial Actions]]) |
| Create incident | an incident with the detected details, for an agent to resolve |
| Self-help instructions | steps to follow |
| URL | a link, for example to a knowledge article |

**Input parameters**: when the chosen remedial action has inputs they are listed; a static value can be typed, or **Advanced settings** set per parameter to fetch the value from a table at run time. Supported formats: text, boolean (no advanced option), choice. Stored in `remedial_action_parameters` on the resolution (`sn_pren_resolution`). Example, *Clear application cache*: App name, Process name, Cache path. Parameters are configured in the metric rule's alert action only, not in the workbench or the classic UI. The guide also lists as a limitation that actions needing run-time parameters cannot be used: read it as "values must be resolvable without asking the user".

### Engagement settings

| Field | Options |
|---|---|
| **User engagement** | Engage user; Silent execution (remedial action); Notification only (self-help instructions and URL) |
| **Engagement channel** | Virtual Agent |
| **Notification channel** (Notification only) | Virtual Agent, Desktop Assistant ([[DEX Desktop Assistant]]), Email Notification |
| **User Notification message** | free text, for example a question offering help with low disk space |
| **Resolution needs consent** | Yes / No (remedial action and create incident only) |
| **User consent message** | free text explaining what will be done |
| **Choose email notification** | the email notification record, shown only for the email channel; shipped one: *Proactive engagement notification* |
| **Issue reference name** | short name of the issue used when talking to the user (also usable in the email subject) |
| **Fallback when self-remediation is not successful** | Create incident, or Route to live agent |

Channels offered in the wizard are those marked **Active** in `sn_pren_channel_configuration` (and whose plugin is installed). Email exists only for self-help instructions and URL; the experience issue is set to closed complete as soon as the mail is sent. One early page says only Virtual Agent is supported for notifications; later pages describe all three.

### User criteria

**All > Proactive Engagement > User Criteria Settings** (role `sn_pren.engagement_admin`): **User Criteria**, **Order**, **Type** (Inclusion or Exclusion; exclusion wins), **Active**. Applied to the whole framework, not per use case.

## Throttling

An alert action fires only when the rule was not triggered for that user within the freeze period and the number of impacted users stays under the limit.

| Property | Default | Meaning |
|---|---|---|
| `sn_pren.resolution_freeze_period` | 72 (hours) | per user and metric rule; 0 disables |
| `sn_pren.device_resolution.user_limit_per_throttling_window` | 100 | users for a device resolution within the window |
| `sn_pren.device_resolution.throttling_window_duration` | 8-hour window | the description says the value is in minutes: check the stored value |
| `sn_pren.application_resolution.user_limit_per_throttling_window` | 100 | users for an application resolution |
| `sn_pren.application_resolution.throttling_window_duration` | one-hour window | as above |

**Alert closure:** device alerts close once the impacted users resolved their issue; application alerts are not closed by Proactive Engagement.

## Shipped solutions

*Check system disk usage for Windows* and *Check system disk usage for Mac*: metric rules with self-help instructions. They are inactive: DEX Administration > **Metric rules** > rule > step **Name the rule** > **Active**.

Use cases described (build them from metric rules):

| Issue | Detect | Resolve |
|---|---|---|
| Low disk space, Windows | disk usage over threshold | remedial action Windows disk cleanup (internet cache, memory dumps, temporary files, error reporting) |
| Low disk space, macOS | same | self-help instructions |
| Poor battery health | battery health Poor (flow) | catalog request for a replacement, with consent |
| Pending reboot | uptime over threshold | notification to reboot |
| VPN (Zscaler) disconnected | Zscaler disabled | self-help instructions to reconnect |
| Application freeze (Zoom, Chrome, Teams, Outlook) | freezes over threshold | clear app cache and restart the app |
| Application crash on macOS (Teams, Outlook, Zoom) | repeated crashes | *Execute Jamf policy* with the policy id to reinstall or update, or self-help instructions |
| Poor Wi-Fi | RSSI (macOS) or signal strength (Windows) poor for a long time | tell the user to move closer to the router |
| Device crash | repeated crashes | self-help: update OS and drivers, remove unneeded applications |

## Workbench

**Proactive Engagement workbench** in Service Operations Workspace (needs the workspace user role): all solutions on the instance, **deployed** (engagement settings configured; only these trigger) or **not deployed**. Resolutions created from metric rules are deployed as *original*; choose a custom resolution on a deployed record to make it *custom*.

When the provider updates a solution: **Review update** compares it with the customised one, then **Auto update** (drops the custom resolution; status Up to date), **Manual update** (status Manual update pending until **Solution updated** is selected) or **Ignore update**. States: Update available, Up to date, Update ignored, Pending manual update. **Update provider data** refreshes the list.

## Roles

| Role | For |
|---|---|
| `sn_pren.engagement_admin` | deploys issue registry templates, configures engagement settings, channels and fallback, creates custom resolutions and notifications (contains `sn_pren.issue_registry_write`, `sn_pren.experience_issue_read`) |
| `sn_pren.solution_provider` | creates issue registry templates, resolutions and resolution prompts (contains `sn_pren.issue_registry_template_write`) |
| `sn_pren.issue_registry_template_write` | create, read, edit, delete issue registry templates, resolutions, notification content |
| `sn_pren.issue_registry_write` | the same plus issue registries |
| `sn_pren.experience_issue_read` | read experience issues (the table in the guide is garbled here: confirm in `sys_user_role_contains`) |

## Tables

| Table | Holds |
|---|---|
| Proactive engagement provider (`sn_pren_provider`) | solution provider name and code (only ServiceNow today) |
| Issue Registry Templates (`sn_pren_issue_registry_template`) | every issue that could be offered for self-solving, with its resolution, engagement and description; **Unique Issue Code** = provider code + issue code |
| Issue Registries (`sn_pren_issue_registry`) | templates the customer deployed, with their settings (custom resolution or notification, engagement, channel, fallback, template parity). A template alone does nothing until deployed; **Active** on the registry switches it on |
| Resolutions (`sn_pren_resolution`) | what runs: self-help steps, URL, remedial action reference, or incident creation |
| Notification content (`sn_pren_notification_content`) | notification prompt and consent prompt |
| Experience Issues (`sn_pren_experience_issue`) | one per engagement |
| Experience issue alert (`sn_pren_experience_issue_m2m_alert`) | alert ↔ experience issue, with count of throttled users and throttling reason |
| `sn_pren_channel_configuration` | notification channels and whether each is active |

## Related

- [[DEX Self-Service and Device Actions]] · [[DEX Incident Investigation for Service Desk Agents]] · [[DEX Reference]] · [[ITSM Virtual Agent Topics and Setup]]
