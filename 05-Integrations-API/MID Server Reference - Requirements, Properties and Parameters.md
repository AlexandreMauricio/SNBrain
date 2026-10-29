---
type: reference
tags: [reference, integrations, discovery, admin]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage instance data sources > MID Server > MID Server reference (MID Server system requirements, MID Server properties, Create a MID Server property, MID Server parameters, Configuration Parameter settings and priority, File Cleaner, protected records and reserved characters, privileged commands, MIDSystem methods, Set the JVM memory size), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/mid-server/mid-server-reference-information.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# MID Server Reference - Requirements, Properties and Parameters

Lookup lists for [[MID Server Overview and Architecture]]. From the Brazil docs; not tested. Parameters are long; only the ones most often needed are listed, see the docs page for all.

## System requirements

| Item | Value |
|---|---|
| Windows | Server 2012, 2016, 2019, 2022, 2025 (needed for Windows discovery, Service Mapping on Windows, Orchestration on Windows); .NET Framework 4.5+; PowerShell 3.0-5.1 (add column **Host PowerShell Version** to `ecc_agent` to find old ones) |
| Linux | Red Hat 6+, Ubuntu 14.04+, CentOS 9+ (64-bit); glibc 2.17 and the 32-bit glibc on 64-bit hosts (`yum install glibc.i686`) |
| Blocked for MSI/RPM | CentOS 7, Windows Server 2008 / 2008 R2, Windows 8, Windows 10 (ZIP still possible, Windows 10 unsupported) |
| Java | bundled 21.0.7; minimum 17.0.10; Tanuki Java Service Wrapper 3.5.40 |
| JVM memory | 1 GB default (`wrapper.java.maxmemory` in `wrapper-override.conf`, or a profile) |
| CPU | quad core 2 GHz+ for one MID Server with 25 threads (Windows 2012 R2 example) |
| Network | `<instance>.service-now.com` 443, `install.service-now.com`, OCSP responders over **HTTP** (e.g. `http://ocsp.digicert.com`) |

The Windows install page also says installations need "a minimum of 36 GB of RAM"; this page gives no RAM minimum (unconfirmed).

CPU notes: 90-100% bursts during Discovery are by design. In internal tests, raising threads from 25 to 50 added no CPU pressure but 100 did; a dedicated host averaged 48% CPU versus 77% / 97% when shared with moderate / heavy apps; doubling CPUs from 4 to 8 lowered the average (48% → 28%) but not the peaks. Watch processor queue length (bottleneck above 2× cores) or load average.

## Settings priority

The priority page: **configuration parameter** (MID-specific) > **MID property for that MID Server** > **global MID property**. The parameters page and the property-creation page instead say parameters have *lower* precedence than properties and that properties override parameters: unconfirmed which is true. Do not create duplicate properties or "global configuration parameters" (unsupported). Restart the MID Server after changes. Never edit `agent/properties/glide.properties` (overwritten by upgrades).

## MID Server properties (MID Server > Properties, `ecc_agent_property`; blank MID Server = all)

| Property | Default | Purpose |
|---|---|---|
| `concurrent.dist.download` | 2 | concurrent auto-upgrades (of 4 instance semaphores) |
| `mid.discovery.max_payload_size` | 5,000,000 | max Discovery result string; negative = unlimited |
| `mid.discovery.max_pattern_payload_size` | 50,000,000 | pattern payloads |
| `mid.discovery.max_ci_count_per_page` / `max_related_count_per_page` / `max_relation_count_per_page` | 500 / 100 / 10,000 | payload paging |
| `mid.eccq.max_payload_size` | 20,000,000 | any ECC input; oversize copies go to `ECCSender\output_oversize` |
| `mid.discovery.file_transfer_protocol` | SCP | or SFTP |
| `mid.discovery.multiprobe.skip_others_on_error` | true | stop multiprobe members after a failure |
| `mid.install_server.base_uri` | `https://install.service-now.com` | download host (maint only) |
| `mid.property.jdbc_operations` | select, update, insert, delete, show, create, describe, begin, if, end, not, exists | allowed JDBC verbs |
| `mid.property.ssh.use_snc` | | SNC SSH vs J2SSH |
| `mid.servicewatch.max_concurrent_connections` | 7 | per host per MID Server |
| `mid.shazzam.threads` / `mid.shazzam.max_scanners_per_thread` / `shazzam.chunk_size` | 5 / 100 / ? | port scan tuning |
| `mid.ssh.algorithms.kex` / `.host_key` / `.cipher` / `.mac` | | SSH algorithm order ([[MID Server Security and Encryption]]) |
| `mid.keystore.max_backups` / `max_live_backups` / `backup_overwrite_timespan` | 3 / ? / 60 s | key store backups |
| `mid.log.command_audit.enable` | false | command audit log |
| `mid.probe.wait.resources` | | resource reservation |
| `mid.powershell.target_base_dir` | `admin$\temp` | WMI discovery temp share |
| `mid.http_classy.allow_credentials_over_http` | | risky; prefer HTTPS |
| `mid.use_net_tools` | | net-tools vs iproute2 on Linux |
| `mid.aws.sts.assume_role.credential_ttl_minutes` | 60 | Cloud Discovery credential cache |

Also AWS SSM discovery properties (`mid.discovery.aws_ssm.*`), certificate-import retries, `mid.sa.ssh.allowable_failures`, `mid.sa.windows.allowable_failures`, Horizontal Discovery log sizes.

## Common configuration parameters (config.xml or the MID record's Configuration Parameters list)

| Parameter | Purpose |
|---|---|
| `url`, `name`, `mid_sys_id` (do not edit), `mid.instance.username`, `mid.instance.password` | required |
| `mid.proxy.use_proxy`, `.host`, `.port`, `.username`, `.password`; `mid.upgrade.use_proxy` | proxy |
| `mid.poll.time`, `mid.disable_amb` | ECC polling |
| `threads.max` (25), `threads.expedited.max`, `threads.interactive.max` | thread pools |
| `mid.log.level` (info, warn, error, debug) | logging |
| `mid.windows.management_protocol` (WMI default, or WinRM), `mid.windows.probe_timeout` | Windows |
| `mid.ssh_connections_per_host` (7 SNC, 3 legacy), `mid.ssh.*` timeouts | SSH |
| `mid.powershell_api.session_pool.max_size`, `.target.max_size`, `mid.powershell_api.winrm.*`, `mid.powershell.jea.endpoint` | PowerShell / WinRM / JEA |
| `mid.instance.skip_basic_auth` | try cookies first |
| `mid.pinned.version` | pin one MID Server |
| `mid.windows_host.file_permissions.allow_list` / `.enforce` | Windows folder ACLs |
| `mid.file_cleaner.disabled` | stop the File Cleaner |
| `glide.mid.max.sender.queue.size` | cap the local outbound queue |

## File Cleaner

Runs at start and every 24 hours; deletes files not accessed for 30 days in `agent\export` (export sets: move files away quickly), `agent\work\monitors\ECCSender\output_error`, `...\output_oversize`, and JFR dumps in `agent\logs`. Disable with `mid.file_cleaner.disabled = true`.

## Protected records and XML characters

Cannot be changed or deleted: public page **InstanceInfo** (`sys_public`) and scripted web services InstanceInfo, GetMIDInfo, MIDAssignedPackages, MIDFieldForFileProvider, MIDFileSyncSnapshot, MIDServerCheck, MIDServerFileProvider (`sys_web_service`). In `config.xml` encode `"` `&` `'` `<` `>` as `&quot;` `&amp;` `&apos;` `&lt;` `&gt;`.

## Privileged commands

**MID Server > Privileged Command** (`privileged_command`): `sudo` (needs `sudo -S -p`, `sudo -l`), `pbrun`, `pfexec`, `dzdo`; one per host for Discovery; order per MID Server (Advanced view, Privileged Command related list, lowest order first, default 100). Do not delete the base ones. Only `pbrun` can be a profile (`pbrun -u <profile>`, edit the existing record). Per-command sudo needs `!requiretty` and NOPASSWD entries (better target logs); otherwise the whole script is run with sudo (`must_sudo`).

## MIDSystem (`ms.`) methods in MID Server scripts

`ms.log(message)`, `ms.getConfigParameter(name)`, `ms.include(scriptInclude)` (MID Server script include), `ms.getName()`, `ms.getSysID()`, `ms.toJavaScript(object)`. These run on the MID Server (Rhino), not on the instance.

## Related

- [[MID Server Overview and Architecture]] · [[Install a MID Server]] · [[MID Server Troubleshooting]] · [[MID Server Upgrades]]
