---
type: concept
tags: [concept, automation, integrations, admin]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > ServiceNow AI Platform Additional Capabilities > Classic Orchestration (187 topics: introduction, applications, domain separation, activation, plugin list, Orchestration Runtime, activities list, deprecated activities, reactivate a deprecated activity, SOAP Message activity, probes used by Orchestration, PowerShell activities, AD automation example, activity packs AD, Azure AD, Exchange, F5, Infoblox, PowerShell with protocols and troubleshooting, Probe, SCCM, SFTP, SSH, global activities, MID Servers for Orchestration, capabilities, default MID Server, PowerShell properties, Orchestration Usage dashboard), read 2026-10-29; per-activity input and output tables skimmed. https://www.servicenow.com/docs/r/servicenow-platform/orchestration/r-orchestration.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Classic Orchestration Overview and Activity Packs

**In one line:** **Classic Orchestration** (`com.snc.runbook_automation`, separate subscription) extends the **Classic Workflow** engine to act outside the instance: its activities send **probes** through a **MID Server** (or call web services directly) to Active Directory, Exchange, Windows and Linux hosts, load balancers, IPAM and so on, grouped into **activity packs**.

From the Brazil docs; not tested. This is the legacy, workflow-based product; new automation is built with Workflow Studio (Flow Designer) and Integration Hub spokes. It sits on [[Classic Workflow Overview]]; activity building is in [[Orchestration Activity Designer and Databus]]; ROI and software distribution in [[Orchestration ROI and Client Software Distribution]].

## What Orchestration adds to workflows

- Ready-made activities in **activity packs** (Workflow Editor **Packs** and **Custom** tabs).
- The **Activity Designer** for reusable custom activities from templates, and packs built as scoped applications.
- The **databus**: activity outputs reusable as inputs to later activities.
- Calls straight to web services, or through a MID Server to systems behind the firewall.

## Activation and plugins

Requested through Now Support (separate subscription). Domain separation: **Standard** ([[Domain Separation Support Levels by Application]]).

| Plugin | ID |
|---|---|
| Orchestration | `com.snc.runbook_automation` |
| Orchestration Runtime (run workflows with Orchestration activities) | `com.snc.runbook_automation.runtime` |
| Activity packs | `com.snc.orchestration.ad`, `.azure.ad`, `.exchange`, `.f5`, `.infoblox`, `.powershell`, `.probe`, `.sftp`, `.ssh`, `.sccm_mgnt` |
| Asset Lease Management, Client Software Distribution | `com.snc.orchestration.asset_lease_management`, `com.snc.orchestration.client_sf_distribution` |
| ROI, ROI Premium | `com.snc.runbook_automation.roi`, `com.snc.runbook_automation.roi_premium` |

## How an activity runs

The activity writes an **output** record to the **ECC Queue** (`ecc_queue`); the chosen MID Server picks it up and runs the matching probe on the target; the result comes back as an **input** record; a sensor in the activity reads it and the workflow moves on (workflow event `probe_complete`, see [[Classic Workflow Administration and Troubleshooting]]).

Probes shipped (**Orchestration > Definition > Probes**, stored in `discovery_probes`): run a local command on the MID Server, resolve an FQDN to an IP (parallel, uses the MID host's DNS cache and hosts file), secure file copy through the MID Server, find active devices, generic SNMP, SOAP request, SSH command, long-running SSH command, generic VMware (runs a MID Server script include), and PowerShell (script in a parameter ending `.ps1`; variables `$computer` and `$cred` from the Credentials table).

## Activity packs

| Pack | Does | Notes |
|---|---|---|
| Active Directory | create, update, remove objects; add or remove group members; enable, disable, unlock; reset or change password; query; is account locked | rewritten as scoped in Geneva; uses ADSI, not WMI or WinRM |
| Azure AD | add or remove group member, assign or remove Office 365 licence, create, delete, get user, reset password | no legacy versions |
| Exchange | address lists (create, delete, get, move, set, update) and mailboxes (create, delete, disable, enable, get, set) | WinRM to Exchange; multivalued properties passable |
| F5 Network Management | pools, pool members, virtual servers, profiles | |
| Infoblox DDI | DHCP reservations, DNS A and CNAME records, IPAM register, reserve, list, delete, networks | needs a **Basic Auth** credential whose **sys_id** goes into the `restCredentials` input; workflows *Infoblox Reserve/Register IP in IPAM* and *Infoblox Release IPAM Reservations*; Infoblox user needs read or read/write privileges |
| PowerShell | Join Domain, Install Windows App (MSI), Uninstall Windows App, Change Service State, Restart Windows Server | PowerShell on a Windows MID Server; WMI (TCP 135) and WinRM |
| Probe | probe-based information queries | built with the probe template |
| SCCM | add to or remove from device and user collections, is in collection, get applications, deployments, collections | used by Client Software Distribution |
| SFTP File Transfer | copy (also between servers), create directory, list, remove, rename, set attributes | |
| SSH | Secure Copy, Files Compare, File Read, File Write, File Copy, File Replace String, Reset Linux User Password | |
| Global | activities in the global scope, e.g. Server Alive (SSH check) | |

Other applications (Security Incident Response, Cloud Management, Release Automation) ship their own packs. Packs appear in the **Packs** tab grouped by vendor, scope and category; a custom pack shows only once one of its activities is published.

## Deprecated core activities

Pre-Geneva activities built on **Activity Definitions** (Run Probe, SOAP Request, Run PowerShell, the old AD, Exchange and PowerShell ones) still run in existing workflows but are hidden for new ones; replace them with designer templates. To reactivate one anyway (discouraged; no databus or input testing): **Workflow > Administration > Activity Definitions**, remove the filter `Category != deprecated`, open the definition, **What to Display** tab, change **Category** to any other value (`workflow_admin`, `admin`). The **SOAP Message** activity calls an Outbound SOAP Message (`sys_soap_message`) function, with variables as `name1=value1, name2=value2` (escape commas and equals with a backslash), optionally through a named MID Server.

## MID Servers for Orchestration

A MID Server needs the **Orchestration** (or **ALL**) application, and at least one **capability**. Selection filters: status > application > IP range > capabilities (exact value, then wildcard, then the special capability **ALL**); details in [[MID Server Selection, Capabilities and Clusters]]. If none matches, the **default MID Server** is used: field on the Orchestration application record or property *Default MID Server to use for Orchestration Activities* (**Orchestration > MID Server Properties**); the two stay in sync.

| Property | Default | Meaning |
|---|---|---|
| `mid.server.rba_powershell_v2` | true | PowerShell probe v2: detailed credential success or failure, payload and context logging; false = legacy probe (to be deprecated); Orchestration only, not Discovery |
| `mid.property.powershell.log_info` | false | show debug statements from PowerShell scripts in the workflow context, test-input response and ECC payload; per MID Server (empty = all) |

PowerShell troubleshooting: an *authentication failure* appears both for bad permissions and for unreachable hosts; test the same action by hand as that account (AD Users and Computers, or `New-Mailbox` in the Exchange Management Shell). Exit code 1 = connected but the command failed; 3 = tried the MID service account and failed (it is tried last when the target is not the MID host). *RPC server unavailable*: WinRM not configured, firewall on TCP 135 or the WinRM ports, or Kerberos double-hop. MID files: `PSScript.ps1` and `credential.psm1` (credential tests; WMI test when no `credType` is passed). See [[Credentials Fail in Discovery or Orchestration]].

## Usage dashboard

**Orchestration > Operations & Troubleshooting > Orchestration Usage Dashboard**: tabs *Licensable Usage* and *Orchestration Usage*; transaction count over 12 months and year to date (with HR and Security Operations counts), 365-day running averages of server and client nodes orchestrated, transactions by month.

## Roles

`orchestration_manager` (ROI), `activity_admin`, `activity_creator`, `workflow_admin`, `workflow_creator`, `web_service_admin` (REST and SOAP templates); see [[Classic Workflow Overview]].

## Unconfirmed variants

- Usage dashboard: *365 day Running Average of Server* is described as `cmdb_ci_computer` minus `cmdb_ci_server` (client nodes) and *of Client* as `cmdb_ci_server`, i.e. the descriptions look swapped.
- Ports for WinRM are cut off in the source (HTTP/HTTPS and TCP ...).

## Example

Workflow *Example Disable Leaver* on `sc_req_item`: **Disable AD User Account** with the user's login name, then **Remove User License Azure AD**, run through a MID Server with the Orchestration application and capability PowerShell in the office IP range.

## Related

- [[Classic Workflow Activities Reference]] · [[MID Server Overview and Architecture]] · [[Connections, Credentials and Aliases]] · [[Credential Types Reference]]
