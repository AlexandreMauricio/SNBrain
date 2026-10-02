---
type: concept
tags: [concept, workspace, incident, cmdb, integrations, admin]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Service Operations Workspace for ITSM", topics on the Investigation Framework (Agent Client Collector / Microsoft Endpoint Configuration Manager for Investigation, metric definitions, CI actions, Remedial Actions Framework), "Remedial actions using Playbook", "Incident Management in Service Operations Workspace reference" (components installed, features of the Investigation tab) (pp. 3372-3393, 3506-3521), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Investigation Framework, CI actions and remedial actions

**In one line:** the **Investigate** tab of an incident in Service Operations Workspace shows live metrics of the affected device (CI) and lets the agent run fixes on it; three frameworks sit behind it: metric definitions (read), CI actions (write) and remedial actions (what the agent is offered).

## Providers

| Provider | Application | Notes |
|---|---|---|
| Agent Client Collector (ACC) for Investigation | `sn_acc_adapter` (ITSM Pro) | queries run by the agent on the endpoint (osquery check definitions) |
| Microsoft Endpoint Configuration Manager (MECM) for Investigation | `sn_mecm_adapter`, with spoke `sn_ms_epcfgmgr_spk` | runs PowerShell scripts and CMPivot queries through MECM |

Admin role `sn_cimaf.sn_cimaf_admin`; remedial actions `sn_reacf.sn_remedial_action_admin`.

### MECM specifics

- Scripts are created **and approved** in MECM (msinfo32 file create / check / fetch, dsregcmd, get processes, restart service, end process). Each script's GUID goes in **Action input** of the matching record: read configurations in `sn_mecm_adapter_config`, write actions in `sn_mecm_action_config`. In the MECM console PowerShell: `Get-CMScript -ScriptName '<name>' | Select ScriptGuid` (read-only).
- CMPivot entities needed: Disk (size, free space), Memory (total physical), OS (free physical memory, last boot time), Processor (load percentage), Services, LogonSession, LoggedOnUser, InstalledSoftware. Verify in the MECM console: **Assets and Compliance > Devices**, select an **Active** device, **Start CMPivot**. If an entity is missing, extend the hardware inventory.
- Property `sn_mecm_adapter.request_query_delay` (10000 ms).

## Metric definitions (what is read)

**Metrics and CI Actions Framework > Administration > Metric Definitions**. Shipped: Asset usage, Installed Applications, Logged-in users, Running processes, Services, System Information (dsregcmd), System Information (msinfo32), System overview.

| Record | Fields |
|---|---|
| Metric definition | **Name**, **Active**, **CI Class**, **Description**, **Schema** (structure in which returned values are stored) |
| Adapter Configuration (related list) | **Provider**, **Order** (only the first applicable one is used), **Duplicate request time limit (seconds)**, **Query Action** + **Query Flow/script**, **Transform Action** + **Transform Flow/script** (empty = the provider's default flow) |
| Provider Specific Adapter Configuration | ACC: **Check Definition**, **Query/Command**. MECM: **Action Input**, **Flow Action** (read), **Output Flow Action** (look up the response) |
| Adapter Applicability Rule | **CI Class**, **Allow matching CI class extension**, **CI conditions** |

A new metric appears on the tab only after its sys_id is added to the script `sn_sow.SOWInvestigateConfig` (labels, units and thresholds are set there too).

## CI actions (what can be done)

**Metrics and CI Actions Framework > Administration > Actions**.

| Record | Fields |
|---|---|
| Action | **Name**, **CI Class** (for example Computer `cmdb_ci_computer`), **Active**, **Description** |
| Action Role; User Criteria Action Inclusion / Exclusion | who may run it |
| Action Configuration | **Provider**, **CI Class**, **Allow matching CI Class extension**, **CI Condition**, **Action Type** (flow or script), **Action execution flow**, **Order**, **Duplicate request time limit (seconds)** |
| Action Configuration Step | **Sequence**; ACC: **Check definition**, **Command**; MECM: **Flow Action**, **Output Flow Action**; **Validate** + **Validation script**, **Run** (Once / Poll with **Polling count** and **Polling interval**) |
| Action Parameter | **Type** (integer, reference + table, choice list...), **Label**, **Mandatory**, **Active**, **Default value**, **Choices** |

## Remedial Actions Framework (what the agent is offered)

**Remedial Actions Framework > Administration**.

| Record | Fields |
|---|---|
| Remedial Action | **Name**, **Action** (table + record; the table must be one listed in the type's **Applicability**), **Type** (CI action, standard change...), **Active**, **Target Table**, **Match Target Extensions**, **Target Conditions**; related lists: parameters (**Consider for concurrency check**, default value falls back to the CI action's), roles, user criteria inclusions / exclusions |
| Remedial Action Type | **Name**, **Applicability** (action tables), **Processor** (script include implementing the scripted extension point `RemedialActionProvider`; server-side), **Allow concurrent execution** (duplicates are also allowed if no parameter is considered for the concurrency check) |
| Remedial Action Origin | applications allowed to use the framework |

A new type needs its own implementation of `RemedialActionProvider`, and the Investigate UI must be configured to show the new actions.

## What the agent sees (Investigate tab)

- Shown only when an adapter is installed and the CI is a computer or server with ACC or MECM on it (Windows, macOS, Linux). The agent picks any affected CI or a CI assigned to the caller.
- **Initial metrics** (primary CI only): from 30 minutes before to 30 minutes after the incident was created; window in property `sn_sow.initial_metric_fetch_window`. **Recent metrics** (default), refreshed with **Get latest metrics** or when the CI changes (collection rules, see [[Service Operations Workspace Configuration and Customization Reference]]).
- Cards: Overview (from CMDB), System information (msinfo32; dsregcmd for Entra-joined state, ACC only), Asset utilization (memory, disk, CPU: yellow at ≥ 80, red at ≥ 95; uptime), Top processes by CPU / memory (red at ≥ 90), Services, Logged in users, Installed applications. **View History**: scatter plots over a chosen range; click a point for a snapshot.
- **Device health** link opens Digital End-User Experience (DEX) when the CI is an endpoint with the DEX agent (separate entitlement).
- Which dashboard is shown per CI is decided by table `sn_sow_investigate_ci_ux_rule` (Investigate CI Experience Rules: user criteria, CI conditions, order, match extensions): default view, DEX view (`cmdb_ci_computer` supported by DEX) or Service Observability view (`cmdb_ci_service` with a data mapping; vendor metrics).

### Remedial actions and the playbook

- Shipped: **End process** (from the top-processes cards) and **Restart service** (from the Services card).
- **Device** CI: two steps, the user must approve first, then the action runs on the endpoint. **Server** CI: a **standard change** is created first and the action runs through it.
- Each action becomes a playbook in the side panel (**Current**: New / In Progress; **History**: Completed, Canceled, Failed). **Cancel action** is possible until the CI action is in progress or the server change reaches Implement.
- No concurrent or duplicate action on the same CI unless the type allows it.

## Roles and tables

| Role | Gives |
|---|---|
| `sn_cimaf.sn_cimaf_read` (in itil; contains `cmdb_read`) | read metrics, action requests and outputs |
| `sn_cimaf.sn_cimaf_admin` (contains read, `flow_operator`) | configure metrics and CI actions |
| `sn_cimaf.sn_cimaf_execution_admin` | elevated, added on top of admin |
| `sn_invest_fwk.sn_investigate_admin` | Investigation Framework modules |
| `sn_reacf.sn_remedial_action_read` (in itil) / `_admin` / `_execution_admin` | run / configure / correct the state of remedial action executions |

| Table | Content |
|---|---|
| `sn_cimaf_provider` | providers |
| `sn_cimaf_metric_definition`, `sn_cimaf_adapter_config`, `sn_cimaf_provider_specific_adapter_config`, `sn_cimaf_adapter_applicability_rule` | metric definition and its adapter records |
| `sn_cimaf_collection_rule`, `sn_cimaf_collection_rule_metric_asscn` | collection rules |
| `sn_cimaf_metric` | fetched metrics (definition, CI, timestamp, payload) |
| `sn_cimaf_action`, `sn_cimaf_action_role`, `sn_cimaf_action_user_criteria_mtom` / `_no_mtom`, `sn_cimaf_action_config`, `sn_cimaf_provider_specific_action_config` (steps), `sn_cimaf_action_parameter` | CI action definitions; an exclusion beats roles and inclusions |
| `sn_cimaf_action_request`, `sn_cimaf_action_output` | executions and their output |
| `sn_acc_adapter_config`, `sn_acc_action_config`; `sn_mecm_adapter_config`, `sn_mecm_action_config` | provider-specific records |
| `sn_reacf_remedial_action`, `_parameter`, `sn_reacf_remedial_role`, `sn_reacf_remedial_user_criteria_mtom` / `_no_mtom`, `sn_reacf_remedial_action_type`, `sn_reacf_remedial_action_origin` | remedial action definitions |
| `sn_reacf_remedial_action_execution` | read-only execution log |

Applications: Metrics and CI Actions Framework (`sn_cimaf`), Investigation Framework (`sn_invest_fwk`), Remedial Actions Framework (`com.snc.sn_reacf`).

## Related

- [[Service Operations Workspace for ITSM]] · [[Service Operations Workspace Admin Center and Process Setup]] · [[incident]]
