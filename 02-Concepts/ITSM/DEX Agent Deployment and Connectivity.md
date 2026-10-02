---
type: concept
tags: [concept, assets, integrations, security, instance-admin, admin]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Digital End-User Experience" (pp. 1787-1804: installing DEX and ACC, registration key, connectivity tests, Windows and macOS installation, sudoers, browser extension, Intune and Jamf bulk deployment; pp. 1832-1835: non-persistent VDI; pp. 1876-1882: proxy, switching instance, MID-less configuration, sudo banner), read in full 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# DEX Agent Deployment and Connectivity

**In one line:** getting the Agent Client Collector (ACC) and the DEX browser extension onto Windows and macOS devices in MID-less mode, proving connectivity, and the special cases (proxy, virtual desktops, moving an agent to another instance).

Overview: [[Digital End-User Experience Overview and Architecture]].

## Before installing

1. Install DEX (`sn_dex`) and the ITOM Cloud Services plugin (`sn_itom_cloud_svc`); the instance must be onboarded to ITOM Cloud Services.
2. **Registration key** (role `sn_dex.admin`): **Agent Client Collector > Deployment > Agent Registration Key > New** (**Name**, optional **Ownership Group** that is emailed when keys are cleaned up). Valid 90 days (property `sn_agent.registration_key_validity.days`). Treat the key as a secret.
3. Gateway by region: `itomcnc-prod-gateway.amer.sncapps.service-now.com:443`, `...emea...`, `...apac...`.

## Install parameters (both platforms)

| Parameter | Meaning |
|---|---|
| `CONNECT_WITHOUT_MID="true"` | MID-less install (without it the MID Server websocket install is used) |
| `ACC_CNC="<gateway>"` | the public gateway endpoint |
| `REGISTRATION_KEY="<key>"` | active registration key |
| `INSTANCE_URL="https://<instance>.service-now.com"` | instance to register with |
| `ACC_ALLOW_LIST=0` | disables the command allowlist: temporary measure only |
| `ACC_VALIDATE_SIG=0` | disables installer signature validation: only with non-standard validation tools |
| `LOCALUSERNAME="SYSTEM"` | Windows: run as Local System (used for Intune and for virtual desktops) |

- **Windows**: `msiexec /i <msi> /quiet /qn /norestart` plus the parameters. The service runs as a created ServiceNow user with *Performance Monitor*, *Log on as a service* and *Debug program*. To collect all DEX metrics restart the service as one of: that user plus Remote Desktop Users, **Local System** (needed for the complete playbook data), or a managed account in the groups Remote Desktop Users, Performance Monitor Users, ServiceNow users and Administrators.
- **macOS** (root): the parameters as environment variables in front of `bash -c "$(curl -L https://<instance>/api/sn_agent/agents/install_agent)"`. Then create the sudoers drop-in file.

### macOS sudoers drop-in

`visudo -f /etc/sudoers.d/_servicenow`: a command alias `SN_ALLOWED` listing the binaries the agent may run with sudo (`powermetrics`, `mdls`, `log`, `kill`, `defaults`, `jamf`, `rm`, `ls`, `pgrep`, `find`, `pmset`, `open`, the Zscaler CLI, and the scripts under `.../agent-client-collector/cache/acc-dex-modules/bin/scripts/sudo/` such as `app_freeze.sh`, `restart_service.sh`, `clear_google_chrome_browsing_data.sh`, `elevate_temporary_admin.sh`), a `NOPASSWD: SETENV:` rule for user `_servicenow` covering `osqueryi` and the alias, and `Defaults:_servicenow !requiretty`. Then `visudo -c -f` to validate, `chown root:wheel`, `chmod 440`, check `#includedir /etc/sudoers.d` exists, and `sudo -u _servicenow sudo -l` to list what is allowed. Take the exact file from the product documentation.

**Sudo banner**: the device page flags missing sudo permissions. Property `sn_dex.sudo_banner_excluded_fields` (comma-separated) lists commands not to flag, for example `jamf` when Jamf is not used. It changes the banner only, not the device. Two entries apply to Windows: *Agent User* and *IsLocalSystem*.

## Connectivity tests

| Test | How | Pass when |
|---|---|---|
| Instance | `curl --verbose -L https://<instance>/api/sn_agent/agents/install_agent -o install_script.sh` (add `--proxy <host>:<port>` if needed; role `agent_client_collector_admin`) | the file equals the `install_script` record in Agent scripts (`sn_agent_script`) |
| Shared services | copy `cnc_chain.crt` and `priv_key.pem` from the agent's `cert/cnc` folder; find attachment `acc-dex-common.tar.gz` in `sys_attachment` (sys_id and hash); `curl --verbose --output acc-dex-common.tar.gz --cert cnc_chain.crt --key priv_key.pem https://<gateway>/content/v1/assets/<attachment_sys_id>/<hash>` | Content-Length equals **Size bytes** of the attachment |

Windows needs a recent curl (mTLS support) on the PATH for the session.

Paths: Windows `C:\ProgramData\ServiceNow\agent-client-collector\` (`config\acc.yml`, `config\cert\cnc`, `cache`, `log\acc.log`); macOS `/Library/Application Support/servicenow/agent-client-collector/` (`acc.yml`, `cert/cnc`, `cache`, `log/acc.log`), service `/Library/LaunchDaemons/com.sn.acc.plist`.

## Browser extension

Chrome Web Store or Edge Add-ons; it needs permission to read and change data on all sites. Enabled by default once installed.

## Bulk deployment

| Target | Tool | Outline |
|---|---|---|
| ACC on Windows | Microsoft Intune | download the MSI and copy the single-line command (**Agent Client Collector > Deployment > Agent Downloads**); **Apps > Windows > Create > Line-of-business app** (or Win32 app); paste the arguments from `/quiet` onwards with `LOCALUSERNAME="SYSTEM"`; assign groups. Monitor in Intune, in `acc.log`, or in Services |
| ACC on macOS | Jamf Pro | upload the installer package; build a second package containing an edited `acc.yml` (`connect-without-mid: true`, instance URL, registration key, `verify-plugin-signature: false`) with `pkgbuild` to the agent folder; a post-install script that writes the sudoers file, sets `acc.yml` to 644 and reloads the launch daemon; a policy with both packages (action Install) and the script (priority After) |
| Extension on Windows | Intune | **Devices > Configuration > Create > Settings catalog**: *Configure the list of force-installed apps and extensions* for Chrome and for Edge, with extension id and update URL |
| Extension on macOS | Jamf | configuration profile, preference domain `com.google.chrome`, a property list with `ExtensionSettings` > the extension id > `installation_mode` = `force_installed`, `update_url`, `toolbar_pin`; verify under `/Library/Managed Preferences` or `chrome://extensions` |

Agents are listed under **Agent Client Collector > Agents**.

## Proxy

Needed when the endpoint must go through an internal proxy to reach the ServiceNow cloud. Check first: ports and firewall rules to the ITOM gateway, SSL interception or NAC that may block it, DNS, and that the proxy supports WebSockets.

- ACC later than 4.3.0: in `acc.yml` set `https-proxy: "http://<proxy host>:<port>"`. Credentials can be put in the `HTTPS_PROXY` environment variable; `NO_PROXY` lists hosts to bypass.
- Diagnose with `nslookup`, `ping`, `nc -zv <gateway> 443`, `curl -i https://install.service-now.com/` (Windows: `servicenow-net-check.ps1`).
- Test mTLS through the proxy: build `cacert.pem` with `openssl s_client -showcerts -connect <gateway>:443`, then `curl -v --proxy http://<proxy>:<port> --cacert cacert.pem --cert cnc_chain.crt --key priv_key.pem ... https://<gateway>/content/v1/assets/<sys_id>/<hash>`.

## Changing an existing agent

**MID-less by command**: `acc gateway ics -b <gateway gRPC URL> -i <instance URL> -r <registration key>` (`-y` for a non-default `acc.yml`), then restart the agent. The command checks that a connection can be made, not that each value is right.

**Convert MID-based to MID-less** (roles `agent_admin`, `agent_client_collector_admin`): stop the service; in `acc.yml` set `backend-url` to the gateway, `connect-without-mid: true`, `instance-url`, `insecure-skip-tls-verify: false`, `registration-key`, and comment out `api-key`; delete `cnc_chain.crt` and `priv_key.pem`; delete `assets.db`, `queue.db` and the subfolders of `cache` **but keep `agent_now_id`**; start the service.

**Switch to another instance**: same edits; delete the certificates and the whole `cache` folder; if the device was registered on the new instance before, find it by serial number in Agent Client Collectors (`sn_agent_cmdb_ci_agent`), copy **Agent ID**, and delete the matching rows in Agent Registrations (`sn_agent_agent_registration`); start the service.

macOS stop / start: `sudo launchctl unload -w /Library/LaunchDaemons/com.sn.acc.plist` and `load -w`.

## Non-persistent virtual desktops (VDI)

VMware only; no multi-user sessions; Application and Device Health 3.2.3+. On first start a desktop registers and its certificate is backed up to persistent storage; the logon script restores it in later sessions and the logoff script pushes remaining metrics before the session ends.

On the reference device for the golden image:

1. Install ACC MID-less with `LOCALUSERNAME="SYSTEM"`; stop the service; in `acc.yml` add `persistence_type: non_persistent`; start; wait for host data and policies; check the `cache` folder is populated.
2. Install the browser extension.
3. **Clean up before sealing** (otherwise every clone shares one identity and cannot register): stop the service and set its startup type to Manual; delete `cnc_chain` and `private_key` under `config\cert\cnc`; delete `agent_now_id` in `cache`; empty `databases` and `log`; in `acc.yml` remove the `agent-key-id` line, re-add the registration key and set `disable-asset: true`.
4. Put the shipped logon script in the VDI tool's session-start (post-synchronisation) hook and the logoff script in the session-end hook, adapting their authentication to the persistent storage; the storage must be readable and writable from all desktops in the pool.

Metric rules and event rules have an **Applicable for Non-persistent VDIs** switch.

## Related

- [[Digital End-User Experience Overview and Architecture]] · [[DEX Monitoring Configuration, Alert Rules and Remedial Actions]] · [[DEX Reference]]
