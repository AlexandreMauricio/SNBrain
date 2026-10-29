---
type: how-to
tags: [how-to, integrations, discovery, admin, security]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage instance data sources > MID Server > Configuring MID Server > Prepare network connections, Installing the MID Server, Create the MID Server user and grant the role, Download the MID Server files, Install a MID Server on Linux, Install a MID Server on Windows (guided, silent, manual ZIP, service credentials, existing JRE, uninstall), Validate the MID Server, Test MID Server connectivity, Install multiple MID Servers on a single system, Use MID Server guided setup, read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/mid-server/mid-server-installation.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Install a MID Server

**Goal:** get one MID Server running on a Windows or Linux host, connected to the instance and **validated**. Background: [[MID Server Overview and Architecture]]; next steps: [[MID Server Selection, Capabilities and Clusters]].

From the Brazil docs; not tested. Roles: `admin` (several pages also accept `mid_server`; validation needs `agent_admin` or `admin`).

## 1. Prepare the network

- Outbound **TCP 443** from the host to `<instance>.service-now.com`; **no inbound** connection is needed. A failing `telnet <instance>.service-now.com 443` points to a proxy or firewall rule.
- Access to `install.service-now.com` (443, or 80 for HTTP) for downloads and auto-upgrades; the docs list allow-list IPs 149.96.5.98 and 149.96.6.98, which can change. Property `mid.install_server.base_uri` (changed by a `maint` user) points MID Servers to another download host for closed networks.
- Firewalls and proxies must let OCSP calls to DigiCert through (certificate revocation checks).
- Inside the network: SSH 22 (UNIX), WMI on 135 plus dynamic DCOM ports (Windows, run as a domain user with local admin on targets), PowerShell 3.0-5.1 on the host for Windows automation, SNMP 161 (v1, 2c, 3; add the MID IP to device ACLs), WBEM 5988/5989. Put a MID Server inside a DMZ to reach DMZ devices.
- Windows hosts: require **SMB signing** on the client and servers, strong passwords, a unique account per host (credential spray protection).
- On the instance: **System Web Services > Scripted Web Services > Scripted SOAP Services** must have GetMIDInfo, InstanceInfo, MIDAssignedPackages, MIDFieldForFileProvider, MIDFileSyncSnapshot, MIDServerCheck, MIDServerFileProvider active; the **InstanceInfo** public page (`sys_public.list`) must be active.

## 2. Create the MID Server user

**User Administration > Users > New**: user ID (goes into `mid.instance.username`), name, password (goes into `mid.instance.password`; escape XML special characters such as `&amp;` in `config.xml`). Add role **`mid_server`** (the network page also mentions `import_admin`). Prefer one user per MID Server, especially with basic auth: several MID Servers Up with the same user raise an issue record. Test by logging in to the instance from the host with that user.

Business rules block: elevated privileges on `mid_server`, and `mid_server` together with `security_admin` on one user ([[Non-Interactive Users]], [[Base System Roles]]).

## 3. Download

**All > ITOM Infra Services Workspace > MID Servers > MID downloads**, or **MID Server > Downloads**. Use 64-bit. MSI/RPM installs are blocked on CentOS 7, Windows Server 2008/2008 R2, Windows 8 and 10 (ZIP still works, Windows 10 unsupported). Optionally verify signatures (`openssl dgst -sha256 -verify` for RPM, `gpg --import` + `dpkg-sig --verify` for DEB, `jarsigner` for packages).

## 4a. Install on Linux

- Root needed to install; the service then runs as a non-root user. Default location `/opt/servicenow/mid`. Bundled Java 21.0.7 (minimum JRE 17.0.10). 64-bit hosts need the 32-bit glibc (2.17).
- `sudo rpm -ivh --nodeps <package>.rpm` (optionally `--prefix=<dir>`) or `sudo dpkg -i <package>.deb`, then `./installer.sh` in the agent folder: instance URL, MID user and password, MID name, optional proxy (`mid.proxy.use_proxy`, `.host`, `.port`, `.username`, `.password`), and for the daemon `app_name`, `app_long_name`, `run_as_user`.
- Silent: `./installer.sh -silent -INSTANCE_URL ... -MUTUAL_AUTH N -MID_USERNAME ... -MID_PASSWORD ... -USE_PROXY N -MID_NAME ... -APP_NAME ... -APP_LONG_NAME ... -NON_ROOT_USER ... -CERTIFICATE_REVOCATION Y` (with `-CERTIFICATE_PATH` for mutual auth, `-PROXY_*` for a proxy). Running `installer.sh` again reconfigures and deletes the old configuration.
- ZIP installs: `bin/mid.sh stop`, `bin/mid.sh remove`, edit `mid.shconf_override` (`APP_NAME`, `APP_LONG_NAME`, `RUN_AS_USER`, `GROUP_NAME`, `PROMPT_BEFORE_OWNERSHIP_CHANGE`), then `bin/mid.sh install` as root. Uninstall with `uninstall.sh`.

## 4b. Install on Windows

- Prereqs: PowerShell 3.0-5.1; **Application Experience Lookup Service** (`AeLookupSvc`) enabled (built into the OS from Server 2022); **File and Printer Sharing** enabled for the MSI.
- **MSI** (run as administrator): Authentication Type **Basic** or **Mutual** (certificate; no user/password), instance URL, MID user and password, **Certificate Revocation** (on by default; the test checks OCSP port 80), proxy (must use basic auth), **Test**; then MID Server name (cannot start with `mid.server`), **Service Account Name** (not Local System, not an admin; needs **Log on as a service**; gMSA accounts allowed by typing them), optional manual service name (default `snc_mid_<name>` and display `ServiceNow MID Server_<name>`), folder, **Start MID Server after installation**.
- Service account also needs **Increase a process working set**; change it later in the Windows Services console (Log On tab).
- **Silent**: `SilentInstall.ps1` from the KB article with `-MSI_FILE_NAME`, `-INSTALL_LOCATION`, `-INSTANCE_URL`, `-MID_USERNAME`, `-MID_PASSWORD`, `-MID_NAME`, `-SERVICE_ACCOUNT_NAME`, `-SERVICE_ACCOUNT_PASSWORD`, switches `-START_MID`, `-USE_PROXY`, `-MANUAL_SERVICE_NAME`, `-MUTUAL_AUTH`; `SilentUninstall.ps1 -MID_NAME ...`.
- **ZIP**: extract to e.g. `ServiceNow\<MID name>`, edit `agent\config.xml` (`url`, `mid.instance.username`, `mid.instance.password`, `name`, proxy), set `wrapper.name` / `wrapper.displayname` (and `wrapper.ntservice.account`, password prompt, permissions for a non-admin account) in `conf\wrapper-override.conf`, run `start.bat`. Uninstall: `stop.bat`, then `bin\UninstallMID-NT.bat`.
- Existing JRE (either OS): `wrapper.java.command=<java executable>` in `agent/conf/wrapper-override.conf`; you then own JRE upgrades.
- The MSI page states "a minimum of 36 GB of RAM" for MID Server installations; check against [[MID Server Reference - Requirements, Properties and Parameters]] (unconfirmed, looks unusually high).

## 5. Check and validate

1. Service running (Windows Services: Started; Linux: `agent/logs/agent0.log.0.lck` present); read `agent0.log.0` after every restart.
2. **MID Server > Servers** (or **Discovery > MID Servers**): **Status = Up**.
3. Open the record, related link **Validate** (`agent_admin` or `admin`). If no capabilities, applications or IP ranges exist, **Set Initial Selection Criteria** offers **Allow ALL capabilities / applications / IP ranges** (Cancel still validates). Validated goes Validating → Yes. Stuck: check status Up, connectivity, firewall/proxy, `agent0.log`.
4. **Invalidate** a suspected compromised MID Server: it clears memory, restarts and makes a new key pair (see [[MID Server Security and Encryption]]).

Alternative: **All > Guided Setup > ITOM Guided Setup > MID Server** (create user, download and install, validate); must be finished before other ITOM guided setups.

## Several MID Servers

- One folder and one unique service name per MID Server on a host; only **one daemon per Linux host** (Tanuki wrapper limit).
- Reasons for more: ACL'd devices, DMZ, separate probe types, load (JDBC, file exports, scripts, file reads), high availability, one per LAN rather than across slow WAN links. Do not run external integrations on MID Servers used for Discovery or Orchestration. With domain separation, place MID Servers at the **lowest domain** level.

## Example

| Item | Value |
|---|---|
| MID user | `example.mid.user` with role `mid_server` |
| MID Server name | `EXAMPLE-MID-WIN-01` |
| Host | a Windows Server 2022 VM in the Example Data Centre LAN |
| Service account | `EXAMPLEDOMAIN\svc_example_mid` (Log on as a service, not admin) |
| Install | MSI, Basic auth, certificate revocation on, no proxy, start after install |
| Validate | Validate, Allow ALL applications on, capabilities and IP ranges set later |

## Related

- [[MID Server Overview and Architecture]] · [[MID Server Selection, Capabilities and Clusters]] · [[MID Server Security and Encryption]] · [[MID Server Troubleshooting]] · [[Connections, Credentials and Aliases]]
