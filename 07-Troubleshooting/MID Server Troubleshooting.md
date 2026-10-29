---
type: troubleshooting
tags: [troubleshooting, integrations, discovery, admin]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage instance data sources > MID Server > MID Server reference > Resolving MID Server issues (active issues, fails to start, post-cloning credential issues, resource threshold alerts, user connectivity issues, interpreting user debugging output, Upgrade History), MID Server ECC Queue (security considerations), MID Server dashboard, Validate the MID Server, read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/mid-server/r_MIDServerTroubleshooting.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# MID Server Troubleshooting

From the Brazil docs; not tested. Background: [[MID Server Overview and Architecture]]; upgrades: [[MID Server Upgrades]].

## First checks

1. Host: service running (Windows Services, name from `wrapper-override.conf`), `agent/logs/agent0.log.0.lck` present; read `agent0.log.0` and `wrapper.log` (or `wrapper.txt`) for WARNING / SEVERE.
2. Instance: **MID Server > Servers** status, **MID Server > Server Issues** (`ecc_agent_issue`), **MID Server > Dashboard**.
3. Connectivity: `telnet <instance>.service-now.com 443`, proxy, OCSP to DigiCert ([[Install a MID Server]]).
4. From the instance without host access: related link **Grab MID logs, files and thread dump** (ECC records Topic SystemCommand, Source grabLog), **MID Statistics** (`queue.stats` topic). The **MID Server Down** notification is on by default.
5. Deep JVM analysis: **Start JFR Recording**, **Stop JFR Recording**, **Write JFR File** related links (Java Flight Recorder; files cleaned after 24 hours, `mid.jfr.data.clean.interval`).

## MID Server Issue table

`ecc_agent_issue` (**MID Server > Server Issues**, also a related list on the MID record): states New → Acknowledged → Resolved; **Count** and **Last detected** grow on repeats; records not updated for 30 days are deleted. Sources include `InstanceClone`, `MIDUserConnectivity`, `CpuMIDResourceThresholdBreach`, `MemoryMIDResourceThresholdBreach`, `DiskSpaceCheck`, pre-upgrade test failures, unsupported JRE.

## Common situations

| Symptom | Cause / fix |
|---|---|
| New MID Server will not start or shuts down | another non-Down MID Server has the same name (it retries 12 times, then logs an issue and stops; delete or resolve the issue record afterwards); or, on upgraded Windows MID Servers, several services point to the same folder: `sc.exe delete <service>`, fix `wrapper.name` / `wrapper.displayname`, restart |
| Validated stuck on Validating | service not Up, no connectivity, firewall or proxy blocking the ECC queue; check `agent0.log`, invalidate and validate again |
| MID Servers Down after a clone | `ecc_agent` is not cloned but `sys_user` is, so MID user passwords differ. Clean-up script **Bad MID Server credentials after clone** schedules jobs `BadMIDCredentialAfterClone-1` (15 min) and `-2` (75 min) that log Down MID Servers with source `InstanceClone`; business rule **Check for bad MID credential after clone** resolves them when they come Up. Fix the password in `config.xml` or on the user. See [[Instance Clone Overview]] |
| "User cannot be authenticated or is missing the proper roles" | job **MIDUserConnectivity** (every 4 hours) writes issues: authentication failure (event `login.failed`), authorization failure (event `login.authorization.failed`, parm2 lists missing roles; checked by the `MIDServerCheck` SOAP service, which needs `soap_script`, otherwise only "cannot be detected"), no login attempts (network), and users with `mid_server` that are not MID users (remove the role). The MID user is read from **MID Server Configuration Parameters** (`ecc_agent_config`, read-only, filled from `config.xml`) |
| Version icon red on the dashboard | MID Server and instance on different releases; check `mid.version.override` / `mid.pinned.version`. An incompatible MID Server may not show Down although it does nothing |
| User icon red on the dashboard | user lacks `mid_server` or does not match `mid.instance.username` |
| High CPU | normal during Discovery (90-100% bursts); worry if long and frequent: one MID Server per host, no other apps, monitor processor queue length (Windows) or load average (Linux), not CPU alone |

Retesting connectivity issues faster: in **Scripts - Background** (server-side, global), run `MIDUserConnectivity(0).checkConnectivity(5 * 60 * 1000);` (copy from the scheduled job, do not edit the job). `MIDUserConnectivity(1)` gives a summary debug in the system log, `(2)` a detailed one (user and MID Server map).

## Resource threshold alerts

Off by default: system properties `mid.threshold.resource.breach.enable.cpu.alerts` and `mid.threshold.resource.breach.enable.memory.alerts` = true. Every 10 minutes each MID Server posts metrics to `ecc_agent_scalar_metric` (CPU mean) and `ecc_agent_memory_metric` (`max_used_pct`); business rules **Update cpu mean on MID Server Status** and **Update max memory on MID Server Status** call `MIDResourceThresholdBreach` and update `ecc_agent_status`. Breach → event `mid.threshold.resource.breach` (use for notifications) and an issue. Settings (system property for all, or same-named config parameter per MID Server): `mid.threshold.mean_cpu.percent` (95), `mid.threshold.mean_cpu.aggregate_interval_span` (3 × 10 min), `mid.threshold.mean_max_memory.percent` (95), `mid.threshold.mean_max_memory.aggregate_interval_span`. Fixes: more JVM memory, more MID Servers or clusters, smaller IP ranges or import chunks, a dedicated or bigger host.

## ECC queue hardening (security advisories in the docs)

- The MID Server has no full JavaScript sandbox; credential access protection (signed MID scripts only) runs in audit mode by default. Harden the host: containers, seccomp / AppArmor, restricted outbound network.
- HTTP probes can be abused for server-side request forgery: allow-list outbound destinations at host or network level.
- WMI Runner command injection: restrict WMI namespace permissions, group policy, host firewall.
- The **ECC firewall** (`boot-config.yaml`) accepts unmatched messages by default unless **Code Signing** is on: review rules, consider Code Signing ([[Code Signing and the Circle of Trust]]).

## Related

- [[MID Server Upgrades]] · [[MID Server Overview and Architecture]] · [[Install a MID Server]] · [[MID Server Security and Encryption]]
