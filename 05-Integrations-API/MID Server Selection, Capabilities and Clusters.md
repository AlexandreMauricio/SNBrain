---
type: concept
tags: [concept, integrations, discovery, domain-separation, admin]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage instance data sources > MID Server > Configuring MID Servers (MID Server selection, Configure a default MID Server for each application, Configure an IP address range, Override the MID Server selection filter, IP range auto-assignment, File permission enforcement for Windows MID Servers, Map an IP address to a DNS name, Configure MID Server capabilities, Configure a MID Server cluster, Set MID Server thread use, Install and uninstall Nmap, WinRM trusted host, MID Server domain separation, Synchronize a JAR file), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/mid-server/c_MIDServerSelector.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# MID Server Selection, Capabilities and Clusters

How an application picks a MID Server, and the records that steer it. From the Brazil docs; not tested. Overview: [[MID Server Overview and Architecture]]; install: [[Install a MID Server]]. Restart the MID Server after configuration changes.

## The three criteria

| Criterion | Records (**MID Server > ...**) | Notes |
|---|---|---|
| **Application** | Applications | Discovery, Orchestration, Service Mapping, Event Management, Operational Intelligence, Cloud Management, or **ALL**; the **Included in application ALL** column decides what ALL covers (e.g. leave out Service Mapping when it has dedicated MID Servers) |
| **IP range** | IP Ranges (`Include` / `Exclude`) | single IP, range or CIDR, decimal or hex (`10.11.144.0/24`, `0x0A0B9000/24`); **ALL** IP range = allowed, not necessarily reachable. Excludes are ignored on a MID Server set to ALL |
| **Capability** | Capabilities (`ecc_agent_capability`) | base set: All, Ansible, AWS, Azure, Chef, Google, IBM, JDBC, NetApp, Nmap, OpenStack, PowerShell, RCA, Resolve DNS, REST, SNMP, SOAP, SSH, VMware, WMI; custom ones allowed (name + value). Orchestration needs at least one capability per MID Server |

Discovery and Service Mapping also use **behaviors** (port probe types), but not for auto-selection or defaults.

Per application: Discovery = application + schedule IP ranges (behaviors ignored); Orchestration = application + target IP + activity capability; Service Mapping = application + endpoint IP + a Service Mapping capability; Event Management = application + connector instance IP; Cloud Management = Cloud Management capability (IP usually ALL).

### Capability values

Blank value = any device for that protocol; a value = exact match; `*` = matches any non-blank requested value. Matching order: exact value match → wildcard → MID Servers with capability **ALL**. A requested capability name missing from `ecc_agent_capability` throws `BadArgumentException` (no fall back to ALL). **Resolve DNS** uses a script (**MID Server > Capability Value Tests**): value `example.com` matches any host ending in `.example.com`; blank matches all. **Nmap** is added only by installing Nmap (or by a `maint` user on self-hosted).

## Selection modes

- **Auto-select**: filters in order status → application → IP range → capability; first step that finds a candidate wins: suitable Up → default Up → suitable Upgrading/Paused → default Upgrading/Paused → suitable Upgrade Failed, Draining, Drained, Drain Failed or Down → default. Steps below the application's minimum status are skipped (many allow Up or Degraded).
- **Specific MID Server**: always that one; if it is Down or not validated, nothing runs (no reassignment).
- **Specific cluster**: picks within the cluster by the same status levels; load balance = random, failover = best order (0 = best).
- **Default MID Server** (**MID Server > Applications > [app] > Default MID Server**, `agent_admin` or `admin`): used only when auto-select finds nothing; needs no criteria; the ALL default is the fallback for the app default. Event Management uses property `mid.server.connector_default` instead.
- **MID Selector Override** (**MID Server > Mid Selector Override**, `admin`; meant for Cloud Management and Cloud Discovery): one override script per filter type (Status, App, Capability, IP), or **Override selector** that replaces all. Script signature `filter(candidateMIDList, defaultSelectedMIDList, midSelectorContext, requestedParameters)` returns the chosen list. Base example: **Override by capability**.
- Service Mapping has a **MID Server selection test** to preview the choice for a target.
- With domain separation, schedules only offer MID Servers in the configuring user's domain.

## IP range auto-assignment

Discovery Quick Start can assign discovered subnets to MID Servers that are Up, validated and can reach them. Needs read-only SNMP on routers (route tables `1.3.6.1.2.1.4.21` and `1.3.6.1.2.1.4.24.4` OIDs). Results: **MID Server > Automation Status Sets** (`automation_status_set`; related lists Subnets Discovered, IP Range Assignments). Manual ranges are kept and appended; an ALL designation is overwritten. Do not customise `ip_address_collection`.

Orchestration needs IP-to-DNS mappings for hosts in ranges (create **DNS Name** `cmdb_ci_dns_name` records with an IP; `localhost` is not mapped to 127.0.0.1 automatically), otherwise it falls back to the default MID Server.

## Clusters

**MID Server > Clusters** (`ecc_agent_cluster`): type **Load Balance** or **Failover**, members in **Includes MID Servers** (same applications, IP ranges and capabilities). Business rule **MID Server Cluster Management** handles reassignment; event `mid_server.cluster.down` fires when no failover member can take over (use it for a notification).

- Failover members take Processing or Ready ECC jobs from the failed one; a MID Server can be in both cluster types.
- **Not for** LDAP, export sets or JDBC data sources (a failover restarts the ECC task from the beginning, causing duplicates): use dedicated MID Servers.
- `Command` and `SystemCommand` ECC topics are not redirected inside clusters.
- If a MID Server fails during a Shazzam probe with auto-select, Discovery stops (no failover).
- A schedule can name one cluster; clusters cannot be chained.
- Other types: **distributed** clusters (Operational Intelligence only) and **Smart Workload Manager** (jobs assigned by real load and speed).

## Threads

`config.xml` (or connection parameters): `threads.max` (standard pool, default 25, up to 200; PowerShell-heavy Windows Discovery may saturate at about 50; Windows runs out of file handles first), `threads.expedited.max`, `threads.interactive.max` (system commands, heartbeats; rarely changed). More threads need more Java memory ("Out of memory" in the log).

## Credential-less Discovery (Nmap)

Windows MID Servers only (Windows 2012 / 2016 listed), Up, validated, local admin for the install. **Enable Credential-less Discovery** related link (`agent_admin`) installs Nmap (and Npcap) from `install.service-now.com`; success adds the **Nmap** capability and an Nmap version; failure logs to **MID Server Issue** (`ecc_agent_issue`). **Disable Credential-less Discovery** removes Nmap (not Npcap). The install path must not contain `( ) { } [ ]`. Self-hosted without download access: get the version from `mid.nmap.version`, download, run `agent\scripts\PowerShell\NmapInstallation.ps1` with the npcap version (`mid.nmap.npcap.version`) and safe scripts (`mid.nmap.safe.scripts`); a `maint` user adds the capability. Service Mapping ignores the Nmap capability (selects by IP), so install Nmap on every MID Server for those ranges. Do not Nmap-scan AWS (provider policy). Plugin **Discovery - IP Based** (`com.snc.discovery.ip_based`).

## Other settings

- **WinRM**: on each Discovery / Service Mapping MID Server, `winrm s winrm/config/client '@{TrustedHosts="*"}'` or a host list (role `mid_admin` per the page).
- **Windows file permissions** (since Orlando): the agent folder is limited to local admins, SYSTEM, CREATOR OWNER and the service user; extend with `mid.windows_host.file_permissions.allow_list` (names or SIDs, domain accounts as SIDs). Roll back with `icacls <agent> /restore <agent>/etc/fileperm.aclsave`. Install as admin, add the non-admin user, restart, then switch the service account.
- **JAR files**: **MID Server > JAR Files** (`ecc_agent_jar`), attach the JAR; all MID Servers restart to sync it.

## Domain separation

The MID user's domain (in `config.xml`) decides which records the MID Server can read and write. Domain-specific versions are possible for synchronized files (`ecc_agent_sync_file`): MIB files (`ecc_agent_mib`), JAR files (`ecc_agent_jar`), script files (`ecc_agent_script_files`). Changing domain: stop, delete the `ecc_agent` record, put a user from the new domain in `config.xml`, restart. **Multi-domain MID Server**: plugin `com.glide.domain.msp_extensions.installer`, property `glide.ecc.enable_multidomain_mid = true`, then create the MID Server in global; it only tries credentials of the domains requested by ECC inputs. Setting the property back to false makes it write everything to global. See [[Domain Separation Overview]].

## Related

- [[MID Server Overview and Architecture]] · [[Install a MID Server]] · [[MID Server Reference - Requirements, Properties and Parameters]] · [[Connections, Credentials and Aliases]]
