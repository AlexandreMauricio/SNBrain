---
type: concept
tags: [concept, automation, roles, release-specific]
status: documented
source: ServiceNow Brazil docs, Workflow Data Fabric > RPA Hub > Unattended Robot (all 12 topics) and Attended Robot (all 10 topics), read 2026-10-30. Pages linked from these but held in RPA Hub (robot form, bot process form, Embedded Task Automation, high density robots in RPA Hub) not read. https://www.servicenow.com/docs/r/integrate-applications/rpa-runtime-landing-page.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# RPA Unattended and Attended Robots

**In one line:** the two Windows agents that run [[RPA Hub]] automations: Unattended runs alone on a schedule, by API or manually; Attended runs beside a person who starts it.

From the Brazil docs; not tested. Install both from the `.msi` files downloaded from RPA Hub (`admin`). Guided Setup: **All > Robotic Process Automation > Administration > Guided Setup**.

| | Unattended Robot | Attended Robot |
|---|---|---|
| Mapped to | one machine (standard robot) | one user |
| Started by | schedule, API (**Start Process** subflow) or manually | a person, or a ServiceNow form |
| Run role | `sn_rpa_fdn.rpa_robot`, `snc_internal` | `sn_rpa_fdn.rpa_assisted_user`, `snc_internal` |
| Connect | Instance URL, then mTLS or Basic | **Connection Manager**, then login and **Allow** |

**Triggered By** on the process job shows how a run started.

## Before a run

- Bot process life cycle stage **Published**, robot life cycle stage **In-Use**.
- A package, a bot process with **Process Type** set, and licences.
- Unattended: credential group, assigned robot, process robot credential.
- Attended: an assigned user or group. If `sn_rpa_fdn.allow_rda_robot_auto_assignment` is true, the robot record is created at run time when a licence is free; if false, it must exist.

The docs tie `snc_internal` to FIPS-enabled instances, and the Unattended page's note says *Attended Robot*: unconfirmed which robots it applies to.

## Unattended setup

- Persistent, always-on machine or VM; no sleep through Citrix; VDI idle timeout off.
- `glide.cometd.websocket.enabled` = true on the instance, and websockets enabled on the client.
- Default folder `%ProgramFiles%\ServiceNow\Unattended Robot`, per machine.
- Basic authentication shows a warning icon in the taskbar. mTLS needs a client authentication certificate; see [[RPA Hub]].
- Setup role: `sn_rpa_fdn.rpa_release_manager` or `sn_rpa_fdn.rpa_admin`; connection: `sn_rpa_fdn.rpa_robot`.

**Unattended Robot Login Agent** unlocks or logs in to the machine. It handles login screens only and **does not support MFA**. It clears a legal notice if `sn_rpa_fdn.bypass_legal_notice` is selected; otherwise turn the notice off by AD policy.

### High density robots

Several automations at once on one Windows Server, one per Windows user session, through Remote Desktop Services.

1. Install **Remote Desktop Session Host** (needs a valid licence) and restart.
2. In Local Group Policy, disable *Always prompt for password upon connection*, enable *Require user authentication for remote connections by using Network Level Authentication*.
3. Put the robot Windows users in **Remote Desktop Users**.
4. Enable the option on the robot in RPA Hub, install Unattended Robot, add user profiles.

Limits: not part of a robot pool; the interface takes one user at a time; reconnect after changing robot type. A run for a user already connected by RDP takes over that session. Process names may differ between server and development, so check them on the target.

## Attended behaviour

- **Embedded Task Automation** starts an attended process from a form. The install registers the URL schema `snrdaforms` (from Washington DC); OAuth redirects to it, and the callback starts the robot. Such processes do not appear in the robot's own list.
- Same user re-run: no restart. Different user, same instance: reconnects without closing. Different instance: relaunches.
- **A new automation version or RPA Hub version takes effect only after closing the robot.**
- **Desktop In Desktop** runs in a separate bot session so the person can keep working (**Enable Desktop In Desktop** on the bot process). **End Desktop In Desktop On Complete** closes it; otherwise the robot stays Busy until the person closes it.
- Stop cancels the process job; Close also logs out.
- Known problems: Zscaler loses the main session's connection under Desktop In Desktop; Windows Credential Guard may prompt for credentials (KB2030392).
- Adding a profile while Design Studio is open: restart Design Studio, or its Connection Manager overwrites the entry.

## Requirements

| | Unattended standard, min / recommended | Attended, min / recommended |
|---|---|---|
| CPU | 2 cores 1.8 GHz / 4 cores 2.4 GHz | 1 vCPU / 4 vCPU |
| RAM | 4 GB / 8 GB | 4 GB / 8 GB |
| Disk free | 50 GB / 100 GB | 20 GB / 50 GB |
| OS | Windows 10, 11, Server 2016, 2019, 2022 | Windows 10, 11, Server 2016, 2019 |

- All: .NET 4.7.1 or later, DPI scaling off. Attended: Edge WebView2 Runtime.
- High density: multiply by the number of runtimes; **Windows Server 2022** only. The example gives 12 GB for three users, described as "4 cores per runtime"; recorded as written.
- Desktop In Desktop: 8 GB minimum, 16 GB recommended; the page lists Windows 10, Server 2016 and 2019.

## Example

*Example Robot 01* on Windows Server runs *Example Invoice Bot* nightly under service account *Example Robot User*. An agent starts *Example Address Check* from a button on a form, in Desktop In Desktop, and keeps working.

## Related

- [[RPA Hub]] · [[Automation Center]]
