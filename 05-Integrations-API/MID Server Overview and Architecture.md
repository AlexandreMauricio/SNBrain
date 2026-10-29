---
type: concept
tags: [concept, integrations, discovery, import-sets]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage instance data sources > MID Server (landing, Exploring MID Server, Configuring MID Server, MID Server reference intro, MID Server system requirements, MID Server ECC Queue, MID Server dashboard, MID Server heartbeat, Pause the MID Server, Manually start/stop/restart, Set the JVM memory size, Install multiple MID Servers), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/mid-server/mid-server-landing.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# MID Server Overview and Architecture

**In one line:** the **Management, Instrumentation, and Discovery (MID) Server** is a Java application (Windows service or Linux daemon) installed inside your network that does work the instance cannot reach directly (scanning, running commands, JDBC, LDAP, file imports) and sends the results back over outbound HTTPS.

From the Brazil docs; not tested. Notes in this family: [[Install a MID Server]] · [[MID Server Selection, Capabilities and Clusters]] · [[MID Server Security and Encryption]] · [[MID Server Extensions, Profiles and Containers]] · [[MID Server Upgrades]] · [[MID Server Reference - Requirements, Properties and Parameters]] · [[MID Server Troubleshooting]].

## Who uses it

Discovery, Orchestration, Service Mapping, Event Management, Metric Intelligence, Cloud Management, IntegrationHub (spokes with "MID" connections), Cloud Cost Management, Agent Client Collector, import sets from internal data sources ([[Import Sets - Data Sources, Staging Tables and Cleanup]]), export sets ([[Export Sets]]), and integrations such as SCCM, LANDesk, SCOM, MIIS. Most Service Graph Connectors use it ([[Service Graph Connectors Overview]]).

## How work flows: the ECC queue

The **External Communication Channel** queue (`ecc_queue`; **ECC > Queue**, **Discovery > Output and Artifacts > ECC Queue**) is the mailbox between instance and MID Server.

1. The instance writes an **output** record (Agent = `mid.server.<name>`, **Topic** = probe or command, e.g. `SSHCommand`, `Horizontal Pattern`, `Command`, `SystemCommand`; **Name** = the actual command; **Source** = target IP; **Payload** XML with `<parameters>`).
2. The MID Server holds a persistent **AMB** (Asynchronous Message Bus) connection on channel `/mid/server/<mid_sys_id>`; a new output triggers an immediate poll. It also polls every `mid.poll.time` (40 s default; 5 s via `mid.poll.time.standard` when busy). `mid.disable_amb = true` turns AMB off (fixed polling).
3. The MID Server marks the record Processing, runs it with a thread, and writes an **input** record with the result (`<results>`); **Response to** links input to output. Related links **Run again**, **Go to CMDB item**, **Go to Sensor**.
4. You can send a command by hand: new ECC record, Agent = the MID Server, Topic `Command`, Queue `output`, the command in Name (120 chars) or in the payload. Plugin `com.glideapp.ecc_retry_policy` adds retry policies.

Queues inside the MID Server: **interactive** (system commands, heartbeat), **expedited**, **standard** (most probes); thread limits in [[MID Server Selection, Capabilities and Clusters]].

## Status and heartbeat

- The instance sends a **Heartbeat** probe every 5 minutes (scheduled job, interval editable); no answer = **Down**. Events: `mid_server.up`, `mid_server.down`, `mid_server.paused`, `mid_server.upgrading` (use for notifications; MID Server Down notification exists by default).
- Statuses: Up, Down, Paused, Upgrading, Upgrade Failed, Draining / Drained / Drain Failed, Degraded (selection order in the selection note).
- **Pause MID** / **Resume MID** (`agent_admin`, validated MID Servers only): stops pulling new ECC work and sending results, finishes what it already has; heartbeat continues; Discovery may still assign work to Paused MID Servers (ranked lower); vCenter and SNMP collectors keep running unless stopped; an upgrade ends the pause.
- ZIP installs: `start`, `stop`, `restart` `.bat` / `.sh` in the agent folder.

## Records on the instance

| Record | Table |
|---|---|
| MID Server | `ecc_agent` (`MID Server > Servers`, also `Discovery > MID Servers`) |
| Status metrics | `ecc_agent_status`, `ecc_agent_scalar_metric`, `ecc_agent_memory_metric` |
| Issues | `ecc_agent_issue` |
| Configuration parameters (from `config.xml`) | `ecc_agent_config` |
| Properties | `ecc_agent_property` |
| Capabilities, clusters, IP ranges | `ecc_agent_capability`, `ecc_agent_cluster`, IP range records |
| Synced files | `ecc_agent_sync_file`: `ecc_agent_jar`, `ecc_agent_mib`, `ecc_agent_script_file` |

On the host: `agent/config.xml` (instance URL, user, name, parameters), `agent/conf/wrapper-override.conf` (service name, JVM memory, Java options), `agent/logs/agent0.log.0` (newest; `.9` oldest), `wrapper.log`.

## Dashboard

**MID Server > Dashboard** (`agent_admin` or `admin`; also in Discovery Admin Workspace 1.3.1+): Overview (status, validation, pending upgrades and jobs, by capability), Performance (CPU, memory, life-cycle events), Custom performance. The status gauge shows host, status, validated, max memory %, mean CPU %, pending and processing jobs, **Version** (red = different release, yellow = same family other version, green = same, grey = unknown) and **User** (red = no `mid_server` role or different from `mid.instance.username`).

## Sizing in short

Standard products (Discovery, Event Management, integrations, Orchestration, Service Mapping) can share a MID Server; Cloud Management and Operational Intelligence want dedicated hosts. Minimum CPU quoted: quad core 2 GHz+ for one MID Server with 25 threads. JVM default 1 GB (`wrapper.java.maxmemory`). Details and the CPU case studies: [[MID Server Reference - Requirements, Properties and Parameters]].

## Related

- [[Connections, Credentials and Aliases]] · [[Integration Options and Interfaces Overview]] · [[Domain Separation Overview]]
