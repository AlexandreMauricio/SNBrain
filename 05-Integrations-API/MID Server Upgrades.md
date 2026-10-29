---
type: concept
tags: [concept, integrations, instance-admin, release-specific]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage instance data sources > MID Server > MID Server reference > MID Server upgrades, MID Server pre-upgrade check, Pinning a MID Server to a specific version, Trigger MID Server upgrade, MID Server Upgrade History, Add SSL certificates (trust store migration), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/mid-server/c_UpgradeAndTestMIDServer.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# MID Server Upgrades

How MID Servers follow the instance version. From the Brazil docs; not tested. Problems: [[MID Server Troubleshooting]].

## When and how

- Any MID Server whose version differs from the instance must upgrade. **Automatic**: when the instance upgrades it sends an `autoUpgrade` system command; also each MID Server checks hourly (timing based on its own start). **Manual**: related link **Upgrade MID** on the MID record (`agent_admin` or `admin`; MID Server Up and validated, or in Upgrade Failed).
- MID Servers many releases behind may need a fresh install instead (do not uninstall the old one until the new one is validated).
- Requirements: access to `install.service-now.com` (self-hosted without it: import packages manually, KB0760123), OCSP reachable, 64-bit OS, Windows **Application Experience** service on, no blocking antivirus (KB0870329, e.g. CiscoAMP listed), Linux services installed under Madrid or earlier get reinstalled during upgrade.

## Steps the MID Server runs

1. **Pre-upgrade check** (AutoUpgrade monitor, hourly until it passes; parameter `mid.upgrade.run_precheck`, default true, can be set false per MID Server or globally as an `ecc_agent_property` with blank MID Server). Mandatory tests: free disk (the test list says 2 GB; the disk-space section says `mid.upgrade.min_disk_space_gb`, default **4 GB**: unconfirmed which threshold applies), download access, signature of a sample file, permission to extract to `agent/work/upgrade_temp`, copy, read and delete, not 32-bit, glibc ≥ 2.17 on Linux. Windows alert tests (do not block): blocker services, Application Experience, service running as LocalSystem or an admin, PowerShell checks. Failures go to `ecc_agent_issue` and block. A **DiskSpaceCheckMonitor** also warns below `mid.disk_space_check.low_space_warning_threshold_gb` every `mid.disk_space_check.interval` hours (0 disables either check).
2. **Download** packages to `agent/package/incoming`; verify each digital signature (manual check: `jarsigner -verify -verbose -certs -strict <zip>`).
3. **Extract** to `agent/work/upgrade_temp` (since Rome; `mid.upgrade.use_os_temp_folder = true` reverts to the OS temp folder).
4. **Replace**: the MID Server starts **ServiceNow AI Platform Distribution Upgrade** and stops; it replaces only changed files in `bin`, `lib`, `jre` (since Rome) and restarts the MID Server, which cleans the temp folders.

Logs: `agent.log` ("Performing pre-upgrade validation tests", "Downloading package...", "Stopping MID server. Bootstrapping upgrade"), then `glide-dist-upgrade.log` in the temp extract folder, `agent/logs/dist-upgrade.log` and `wrapper.log`. An `agent/conf/upgrade-wrapper-override.conf` can tune the upgrade wrapper (debug, timeouts).

## States

- **Upgrading**: behaves like Paused; cannot resume or restart.
- **Upgrade Failed**: failure in pre-check, download or extract on a **major** release upgrade. On a patch-level upgrade the MID Server keeps running the old version and stays Up. Failure during file replacement leaves the MID Server **Down**.
- **MID Server > Upgrade History** (`ecc_agent_upgrade_history`: old and new versions, counts) with stages in `ecc_agent_upgrade_history_stage` (Pending Upgrades, Complete Upgrade Details; messages with paths and errors). Pinned MID Servers get a stage row without a history.

## Pinning (not recommended)

| Setting | Scope | Notes |
|---|---|---|
| `mid.buildstamp` (system property, hidden) | all | the target version, format `mm-dd-yyyy-hhmm` plus release; resets on instance restart or upgrade; do not change |
| `mid.version.override` (system property, add it) | all | pins and disables auto-upgrade; survives restarts, **cleared by an instance upgrade** |
| `mid.pinned.version` (config parameter) | one MID Server | `<version>-mm-dd-yyyy`; beats the properties; checked every 20 minutes and at restart; not cleared by upgrades |

Different MID and instance versions can cause outages.

## Trust store during upgrades

The bundled JRE trust store is replaced; the MID Server migrates certificates according to `mid.truststore.migration.strategy` (`migrate_delta` default, `migrate_non_ca`, `do_not_migrate`) and keeps backups. Since Quebec, self-signed certificates migrated in JRE updates get the alias prefix `snc_`. An external trust store avoids this ([[MID Server Security and Encryption]]).

## Containerized MID Servers

Auto-upgrade works but rebuilding the image is recommended ([[MID Server Extensions, Profiles and Containers]]).

## Related

- [[MID Server Troubleshooting]] · [[MID Server Overview and Architecture]] · [[Upgrades - Process, Upgrade Center and Upgrade Console]]
