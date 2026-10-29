---
type: concept
tags: [concept, integrations, discovery, cmdb, admin]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage instance data sources > MID Server > Configuring MID Servers > vCenter event collector, SNMP trap collector extension, MID Server Resource Reservation, MID Server profiles (configuration data, create, configure, sync), Containerized MID Server (build Docker image, deployment and auto-configuration, deployment request, autoscaling), Configure a MID Server for IPv6, read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/mid-server/containerized-mid.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# MID Server Extensions, Profiles and Containers

Optional MID Server features beyond the basic install. From the Brazil docs; not tested. Basics: [[MID Server Overview and Architecture]].

## Extensions (MID Server > Extensions)

Both extensions have related links **Start**, **Stop**, **Restart**, **Test** (does not affect a running one) and **Update parameters** (tests, then reconnects), a **Status** (Started, Stopped, Offline, Error) and **Execute on** = specific MID Server or cluster.

### vCenter event collector

Listens to vCenter events so the CMDB follows VM changes without rerunning full vCenter Discovery (role `agent_admin` or `admin`; MID Server must reach vCenter and vCenter must already be discovered). **MID Server > Extensions > vCenter Event Collectors > New**: name, vCenter IP or host, MID Server or cluster; save, adjust the **vCenter Event** related list, **Start** (it tries the VMware credentials until one connects).

- Each event becomes a system event `automation.vcenter` (parm1 = vCenter event, parm2 = JSON payload), handled by the script action **Discovery: Process vCenter events** (do not edit; write your own script action for unsupported events).
- Only updates VMs already in the CMDB, except "...CreatedEvent"-style events (created, cloned, deployed, discovered, registered, reconfigured), which run a quick Discovery to create the CI.
- Event families: VM power and migration (power on/off, DRS, HA isolation, suspend, relocate, vMotion, removed, host removed → stale), identity (rename, UUIDs, MAC → NIC probe), cluster, datastore, port group, resource pool, distributed switch, datacenter. Upgraded instances may lack newer default events: add them manually.
- Keeps processing while the MID Server is paused (status may still say Started). Domain separation: inherits the MID Server's domain; no multi-domain MID Server.

### SNMP trap collector

**MID Server > Extensions > MID SNMP Trap Listener** (`admin`): name, **UDP port** (1024+ recommended; lower ports need admin rights), assignment group, specific MID Server (recommended, because devices send traps to one IP). Traps go to Event Management (if inactive, the instance ignores them, as far as the truncated text shows). Usually one collector per network to avoid duplicates; one per VLAN if needed. Devices must be configured to send traps to the MID Server.

## Resource reservation (advanced)

Lets probes and patterns wait in a **waiting queue** until named resources (counts) are free, e.g. to cap PowerShell sessions in total and per host, or throttle Discovery against fragile targets. Only configure it for an identified problem.

- Enable with MID Server property `mid.probe.wait.resources = true` (restart).
- **Discovery Definition > Limited Resources > Simple Value** (`mid_limited_resource_value`), also **expanding** (`mid_limited_resource_expanding`, e.g. `"{mid.windows.management_protocol}" == "WinRM" ? 1 : 0`) and **scripted** (`mid_limited_resource_script`), all extending `mid_limited_resource`. `{param}` in the name makes per-target resources, e.g. `ssh{source}`.
- Tabs **Used by Topic / probes / patterns** (each with Invert); heartbeats and queue messages never count.
- **Limited Resources > MID Resources** (`mid_resource`, copied to `ecc_agent_property`): available count (can be `{property}`), MID Server (empty = all), **Order** (lower order = grabbed first; give per-host resources the lower order).
- Check with **Get resource state** on the MID Server record, or the `resource_wait` attribute (ms) in ECC input payloads.

## MID Server profiles

A named set of settings pushed to many MID Servers without touching hosts. Introduced in San Diego for containers; **from Zurich for all MID Servers**. Role `agent_admin`. **MID Server > Profiles and Deployments > MID Server Profiles** (`mid_server_profile`).

| Table | Holds |
|---|---|
| `mid_profile_config` | `config.xml` parameters |
| `mid_profile_wrapper_config` | wrapper parameters → `wrapper-profile-sync.conf` (e.g. `wrapper.java.maxmemory` = 4096) |
| `mid_profile_property` | MID Server properties |
| `mid_profile_application_m2m`, `mid_profile_capability_m2m`, `mid_profile_ip_range_m2m`, `mid_profile_cluster_m2m` | assignments |

Create from scratch, **Duplicate**, or **Create MID Profile** from a MID Server record. Assign via the profile's **MID Servers** tab or the MID Server's **Profile ID**, then **Sync to MID Servers** (sync strategy, optionally wrapper-override settings plus auto restart; the host needs 2 GB RAM above the JVM max) and **Compare with MID Servers**. Cluster assignment from a profile fails if the MID Server has no capabilities.

## Containerized MID Server

Docker image of the MID Server for Kubernetes or OpenShift (Docker Swarm also shown), built from **recipes** on the download page. Limits: AlmaLinux 64-bit hosts, Docker 20.10.4+; images only for the current release (Rome or later files); Nmap and CyberArk not supported; Orchestration and IntegrationHub not certified; some features deprecated in Washington DC.

- Build: `docker build <recipe dir> --tag <tag>` (default tag in `.env` `DOCKER_TAG`); build args `MID_INSTALLATION_URL`, `MID_INSTALLATION_FILE` (local file in `asset/`), `MID_SIGNATURE_VERIFICATION` (default true), `USER_ID` / `GROUP_ID` (default 1001; non-admin user).
- Run: `docker run --env-file <file> <tag>` with `MID_INSTANCE_URL`, `MID_INSTANCE_USERNAME`, `MID_INSTANCE_PASSWORD`, `MID_SERVER_NAME`, `MID_PROXY_*`, `MID_SECRETS_FILE`, `MID_MUTUAL_AUTH_PEM_FILE`. Pass passwords and certificates as **Docker or Kubernetes secrets** (`mid-secrets.properties`, default `/run/secrets/...`), not env vars; a PEM file enables mutual auth and auto-validation.
- **Deployment requests** (**MID Deployment Requests**; Kubernetes only): profile, image registry path and tag, MID names (or generated), namespace, service account (needs RBAC to create, delete, list), secret names and paths, labels; **Export to YAML file**, then `kubectl apply -f <file>`. A new MID record gets container ID, profile ID and deployment name; business rule **Auto-Configure MID from profile** applies the profile. Requests older than 365 days are deleted.
- **Autoscaling**: StatefulSet with a persistent volume claim (keeps `config.xml` and metadata), Horizontal Pod Autoscaler v1 or v2 on CPU and memory.
- Container ID column distinguishes container MID Servers (empty for normal ones). Job **Purge Orphaned Containerized MID Servers** removes ones Down longer than `max_retention_days` (30), warning `warn_days` (7) before.
- Auto-upgrade works (`mid.container.autoupgrade.enabled`, default true, read-only, settable through a profile), but rebuilding the image and re-applying YAML is recommended. Healthcheck every 5 minutes; no heartbeat for 30 minutes = failure; 3 failures = unhealthy.

## IPv6

A pure IPv6 MID Server needs nothing. On a dual-stack host it defaults to IPv4: set `wrapper.java.additional.109=-Djava.net.preferIPv6Addresses=true` in `agent/conf/wrapper-override.conf` (page writes `wrapper.override.conf`), restart, and set `mid.prefer_ipv6_addresses = true` so the `ecc_agent` record shows IPv6. Discovery over IPv6: Windows only via **WinRM**, UNIX only via **SNC SSH** (J2SSH / Maverick run but results not guaranteed). Tables `ecc_agent`, `ecc_agent_router`, `ecc_agent_ip_address`, `ecc_agent_command_audit_log` hold both families since Tokyo.

## Related

- [[MID Server Overview and Architecture]] · [[MID Server Selection, Capabilities and Clusters]] · [[Install a MID Server]]
