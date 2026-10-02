---
type: concept
tags: [concept, portal, automation, assets, ai, admin]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Digital End-User Experience" > "Digital End-user Experience Self-service" (pp. 2109-2135: overview, configuration, issue configurations, categories, device actions, access and approval, using Device health check from Employee Center, Desktop Assistant and Virtual Agent, reference forms, shipped issue configurations, execution states, diagnosis checks, health calculation), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# DEX Self-Service and Device Actions

**In one line:** DEX Self-service gives employees a **Device health check** (Good, Average or Poor per category) with suggested fixes, plus **device actions** they can run even when nothing is wrong.

Installed with Digital End-User Experience ([[Digital End-User Experience Overview and Architecture]]) but **inactive until issue configurations are enabled**. The fixes are [[Proactive Engagement]] resolutions.

## Where employees reach it

| Source | How | Role |
|---|---|---|
| Employee Center | **Technology Services > Hardware** or **Software** > select a device (widget), or **Quick links > Device health check** (under **Help center** with Employee Center Pro) | none |
| Desktop Assistant | home page card **Device health check** ([[DEX Desktop Assistant]]; latest client needed) | `sn_dex_desktop.user` |
| ServiceNow Otto for ITSM Virtual Agent | type something like "check my device health", or **Show my options > Check Device Health**; a phrase about one subcategory (battery health) goes straight to that resolution | none |

Page tabs: **Diagnose** (categories with their rating; open an Average or Poor one for issues and resolutions) and **Device actions** (**Start now** for the device, or **Select item** > application > **Confirm**). Resolutions are a remedial action button, self-help instructions, or a link. After a fix: **Yes** / **No** feedback; **No** or a failure offers the fallback, typically **Open an IT ticket** (an incident; its number is shown as a link).

- A remedial action triggered in the last 24 hours (from either tab) is greyed out until 24 hours have passed; device actions are limited to once a calendar day per device.
- Action status shown: Completed, No action history, In-progress, Failed.
- The page is unavailable when no DEX-monitored device is assigned to the user, the device is offline, or it is online without recent data.
- In Virtual Agent: consent is asked when configured; long-running actions notify on completion and the conversation resumes with a summary; with several resolutions tried the fallback is always "create an incident", with one it is whatever the resolution defines.

## Configuration (role `sn_dex.admin`)

1. **Activate the resolutions**: **All > Proactive Engagement > Issue Registries** > record > **Active**.
2. **Enable issue configurations**: **All > Digital Experience Self-Service > Issue Configurations** > record > **Enabled in EC self-service** (Employee Center and Desktop Assistant) and / or **Enabled in DEX Now Assist topic** (Virtual Agent). Both default to false. Check the issue registry in **Resolution** is active.
3. **Customise or create** issue configurations (form below).
4. **Categories**: **Digital Experience Self-Service > Device Health Categories**: **Title**, **Parent** (makes it a subcategory), **Order**, **Active**.
5. **Device actions**: **Digital Experience Self-Service > Device Actions**.

A guided setup exists for the above.

### Issue configuration form

| Field | Meaning |
|---|---|
| **Title** | name |
| **Action Applicability** | Diagnose, Device actions (then no evaluation fields), or Both |
| **Category**, **Subcategory** | device health classification |
| **Type** | device or application |
| **Device OS** | Windows, macOS, or both |
| **User applicability** (`user_applicability`) | End user, Service desk agent (agent workspace only), or both |
| **Enabled in DEX ServiceNow Otto topic** (`va_enabled`) | available in Virtual Agent |
| **Enabled in EC Self-service** (`ec_enabled`) | available in Employee Center |
| **Evaluation metric** | one or more metric definitions ([[Digital Experience Score]]) |
| **Evaluation criteria** | metric configuration id and threshold value |
| **Issue Description** | text shown to the employee |
| **Resolution** | issue registry code from Proactive Engagement |

### Shipped categories and issue configurations (all disabled)

| Category | Subcategory | Issue configuration | OS | Metric | Resolution |
|---|---|---|---|---|---|
| Device performance | Computer last restart | Computer restart pending | both | Device up time | self-help: reboot |
| | Disk space | Low disk space | Windows | Disk usage | remedial action: Windows Disk Cleanup |
| | | Low disk space | macOS | Disk usage | self-help instructions |
| | Battery health | Poor device battery health | both | Battery health | catalog request for battery replacement |
| Application performance | MS Teams / Outlook / Zoom application stability | application crash (one per application and OS) | Windows | Application crashes | self-help instructions |
| | | | macOS | Application crashes | remedial action: reinstall the application |
| Network health (listed as *Network stability* in the table) | Wifi signal strength | Poor WiFi signal | macOS / Windows | Wifi RSSI / Wifi signal strength | self-help: move closer or use a cable |
| | VPN connectivity | VPN disconnected | both | Device VPN status | self-help: reconnect Zscaler |

Shipped device actions: **Reinstall application** (Teams, Outlook, Zoom; one page says macOS, another macOS and Windows) and **Clear disk space** (Windows).

## Device actions

A device action = the user-facing record (**DEX Self-service issue config**, **Quick action label**, **Application**, **Active**) + an issue configuration + its resolution. If the issue configuration or resolution is missing the action shows but is inactive.

An issue configuration can be picked for a device action only if it is not already used by another action, is enabled for end users, is linked to a remedial action resolution, and does not use a silent or otherwise unsupported engagement type.

Roles: `sn_dex.admin` manages; `sn_dex_self_serv.user` views and triggers. Availability: Employee Center on by default; Virtual Agent off by default per issue configuration; Desktop Assistant once the client is set up.

**Custom action:** create the issue configuration → enable it → create the remedial action ([[DEX Monitoring Configuration, Alert Rules and Remedial Actions]]) → create the device action → test from Employee Center.

**Sensitive actions** (ending processes, uninstalling, heavy resource use): expose the remedial action as a catalog item so an approval step and record exist.

**Account:** actions run as the ACC service account (the configured account on Windows, `_servicenow` on macOS, which needs the sudoers file: [[DEX Agent Deployment and Connectivity]]). A wrong account name on macOS makes checks and actions appear to run without completing.

### Execution states

| State | Code | Meaning |
|---|---|---|
| Running | 602 | executing, or queued for an offline device |
| Declined | 605 | the user declined the confirmation |
| Closed successful | 606 | done |
| Closed unsuccessful | 607 | ran but the remediation failed: see the linked task |

Offline devices: the action is queued and retried on reconnect, valid until the end of the calendar day; the user is notified when it runs. Queued actions are processed in batches of 200 with 10 seconds between batches.

### Diagnosis

| Symptom | Check |
|---|---|
| Not in Employee Center | `ec_enabled` true, `user_applicability` End user, Device OS matches |
| Not in Virtual Agent | `va_enabled` true (off by default) |
| Issue configuration not selectable | the four eligibility conditions above |
| Runs but fails | execution record for user and device, then its task |
| Completes with no visible result on macOS | sudoers permissions for `_servicenow` |
| Battery replacement repeats | the battery replacement resolution record has a specific configuration requirement (not detailed in the guide) |
| Triggers unexpectedly or never | **metric source** on the metric definition does not match the evaluation method |

## How the rating is calculated

Each evaluation metric is Good, Average or Poor per its metric definition. Indicator weights: Good 1, Average 2, Poor 5.

- Subcategory indicator = sum of the weights of its metrics ÷ number of metrics.
- Category indicator = sum of the subcategory weights ÷ number of subcategories.
- Ranges: Good 1 to 1.67, Average 1.67 to 2.33, Poor 2.33 to 5.

## Example

Category *Example Performance* with three subcategories rated Poor, Good, Good: (5 + 1 + 1) ÷ 3 = 2.33 → the category shows **Poor**.

Custom device action *Reconnect Example VPN*: issue configuration with **Action Applicability** = Device actions, **Type** = Device, **Device OS** = Windows, **User applicability** = End user, **Enabled in EC Self-service** checked, **Resolution** = the issue registry code of a remedial action that reconnects the VPN; then a device action pointing at it with **Quick action label** = Reconnect Example VPN, **Active**.

## Related

- [[Proactive Engagement]] · [[DEX Incident Investigation for Service Desk Agents]] · [[Digital Experience Score]] · [[DEX Reference]]
