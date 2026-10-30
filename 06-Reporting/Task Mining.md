---
type: concept
tags: [concept, reporting, security, roles, schema, release-specific]
status: documented
source: ServiceNow Brazil docs, Platform Analytics guide > Task Mining (Explore, Workspace, analyses intro, data model, integrations, Install, agent parameters, anonymization, notifications, retention, agent install, Portable agent, data requests, Reference: components, key terms, data collected, agent limits, configuration records), read 2026-10-30. Categorization rule details, macOS and Windows install steps, project form fields and improvement actions listed, not read in detail. https://www.servicenow.com/docs/r/now-intelligence/task-mining/task-mining.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Task Mining

**In one line:** **Task Mining** puts a desktop agent on workstations to log what employees do across applications, then shows time per activity and application, to find inefficiencies and automation candidates.

From the Brazil docs; not tested. Where [[Process Mining]] reads record history, this reads desktop activity. **It monitors staff, so check works council, privacy and legal rules first** (our note, not the docs).

Store application **Task Mining Core** (`sn_tm_core`), installed with entitlements; open **Workspaces > Task Mining Workspace** (Projects, Data, Application categorization, Configuration).

## Workflow

1. Admin configures notifications, retention, filters.
2. Analyst or power user creates a project, or submits a **Data Request** from Employee Center to build a data pool.
3. **Every manager** of each workstation user approves (**Self-service > My Approvals**); a rejection needs a reason. Extending dates needs a new request.
4. Agent installed; the user gives consent.
5. Analyst runs a mining job; power user categorizes activities; mining runs again.
6. Analyses shared.

**Analyses:** **Task activity** (time and frequency in a scoped task), **Overall activity** (all categorized applications), **Task timeline** (step sequence). Task timeline feeds Automation Center: **Take action > Request automation improvement**, with Generate details through Otto for Platform and the User Task Step Summarization skill.

## Data and privacy

Collected: login name, domain, IP, workstation name; timestamps and activities; screen names; GUI objects and displayed text, **possibly sensitive such as client names**; audit data from `sys_audit`. **Password fields are not collected.** Data goes encrypted to a multi-tenant processing server, then to the instance.

Protections: manager approval and user consent; excluded applications; **event filters** (exclude or replace) and masking; **private mode** on the agent; restricted user tables; automatic deletion; project anonymization.

Users must sign in to the workstation with the same credentials as in ServiceNow.

**Anonymization:** minimum level default LOGIN NAME; others INITIALS, ANONYMIZED CODE. Replacement value default BLOCKLISTED.

**Retention:** user data 30 days (only unassigned records), closed projects 10 days, DataMart 10 days from last opening.

## Agent

Windows and macOS. Windows supports concurrent users on RDP, VDI and virtual apps; macOS one at a time. The installer needs the **Task Mining Agent Install** group (`itil`, `sn_tm_core.service_user`, `agent_client_collector_admin`) and local admin rights. The **Portable Windows agent** is for proofs of concept only: run `PortableLauncher.exe`, register with instance URL and key, logs in `Bin\log`.

**Not captured:** drag and drop, trackpad scrolling; tab navigation is unreliable in some browser applications; agent UI events and duplicates need manual filtering.

Configuration records can be changed, **never added**; change only **Value**, in scope Task Mining core.

| Record | Default |
|---|---|
| Agent config update frequency | 30 s |
| Agent default status | standard |
| Maximum value length | 1024 |
| Private mode allowed | true |
| Disabled collectors | options SAP, Java, Excel |
| Aggregation date range interval | 7 days |
| Categories excluded from dashboard | Off, Break |
| Length of license period | 180 days |
| Off activity threshold | 7200 s |
| Max treemap categories displayed | 99 |

Empty notification text means that notification does not show; empty private texts remove private timeout features.

## Roles and tables

| Role | Can |
|---|---|
| `sn_tm_core.admin` | everything; contains power user |
| `sn_tm_core.power_user` | configuration and settings; contains analyst |
| `sn_tm_core.analyst` | create and share projects, request data; contains `canvas_user`, `workspace_user` |

Tables use `sn_tm_core_*`: `sn_tm_core_project`, `sn_tm_core_user`, `sn_tm_core_user_data`, `sn_tm_core_project_user_data`, `sn_tm_core_event_filter`, `sn_tm_core_task_definition`, `sn_tm_core_task_instance`, `sn_tm_core_application_category`, `sn_tm_core_configuration`, `sn_tm_core_project_user_anonymization`.

## Example

On a test instance, submit a Data Request *Example Request* for *Test User*, approve as their manager, add *Test User* to *Example Project*, then run a mining job.

## Related

- [[Process Mining]] · [[Platform Analytics Experience Overview]]
