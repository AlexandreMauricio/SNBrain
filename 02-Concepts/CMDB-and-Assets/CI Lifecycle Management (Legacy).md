---
type: concept
tags: [concept, cmdb, scripting, assets]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > CMDB CI Lifecycle Management (legacy) (10 topics, 490 cleaned lines, read in full through the docs site API 2026-10-29) - overview, get started, lifecycle management APIs, components, activate the job, CI action, compatible actions, not-allowed action, state priority, not-allowed transition. The API sample is the docs one with comments added; not run. https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/cmdb-ci-lifecycle-mgmt.html
sn-release: Brazil
verified:
updated: 2026-10-29
---

# CI Lifecycle Management (Legacy)

**In one line:** a rules-plus-API layer (in `com.snc.cmdb`) through which automations set a CI's **operational state** and attach **CI actions** (e.g. Patching), with rules saying which actions and state transitions are not allowed; marked **legacy**, with [[CMDB Data Manager]] as the fuller replacement for bulk life cycle operations.

From the Brazil docs.

## Concepts

| Term | Meaning |
|---|---|
| Operational state | a value of `operational_status` on `cmdb_ci` (e.g. Operational, Repair in Progress, Retired); edit the choice list in the dictionary to add states |
| State priority | several requestors may set different states at once; the CI gets the one with the **highest priority (lowest number)**. Give every state a priority |
| CI action | a named activity on a CI (Patching, Provisioning, CreateTask...) |
| Compatible CI actions | pairs that may be active together; **by default no two actions are compatible** |
| Not allowed CI action | action X forbidden for CI type Y in state Z; by default everything is allowed |
| Not allowed operational transition | for CI type Y, moving from state A to B is forbidden; by default all transitions are allowed |
| Requestor | a workflow (its context id) or a registered operator (`registerOperator`), identified by a GUID |
| Lease | how long a requestor's CI action stays valid |

Restrictions are enforced **only through the APIs**: a blocked call fails, logs an error, and may create a task.

## Built-in integrations

- **Incident and Problem**: the shipped action *CreateTask* is not allowed for *Retired* CIs, and is used as the reference qualifier of **Configuration item** on incident and problem, so retired CIs are not offered.
- **Asset Management**: **Operational status** and **Status** / **Hardware status** stay in step around *Retired*: setting either to Retired sets the other; leaving Retired on operational status sets status to *Installed*; leaving Retired on status sets operational status to *Non-Operational* (review these by hand). Status in turn syncs with the asset's **State** (mapping of asset state and substate to hardware status is in the asset management docs, no vault note yet).
- Service Mapping ignores hosts whose operational status is not 1 (Operational) or whose install status is 100 (Absent) (KB0647574).

## Setup (**All > Configuration > CI Lifecycle Management**)

1. Activate the scheduled job **CI Lifecycle Management - Restore Internal State Management Tables** (inactive by default). It deactivates or removes records of invalid requestors, opens **Renew Lease Tasks** for expired leases, and after the grace period (`glide.cmdb.statemgmt.max_lease_expired_days`, 15) deactivates the action and closes the task.
2. **CI Actions** > New (Name, Description).
3. **Compatible CI Actions** (Action, Compatible Action). The docs give the menu as *Configuration > Compatible CI Actions*.
4. **Not Allowed CI Actions** (Not Allowed Action, CI Type (Configuration Item = all), Operational State).
5. **Not Allowed Operational Transitions** (CI Type, Operational State = from, Not Allowed Transition = to).
6. **Operational State Priority** per state.
7. Monitor: **CMDB CI Actions**, **View Internal Operational States**, **View CI State Registered Users**, **Renew Lease Tasks**, **State Management Logs**.

## API (`SNC.StateManagementScriptableApi`, server side, global)

| Group | Methods |
|---|---|
| Registration | `registerOperator()`, `unregisterOperator(requestorId)`, `isValidRequestor(requestorId)`, `isLeaseExpired(requestorId, ciSysId, ciActionName)`, `extendCIActionLease(requestorId, ciSysId, ciActionName, leaseTime)` |
| Operational state | `setBulkCIOperationalState(requestorId, sysIdList, opsLabel, opsStateListOld)`, `getOperationalState(ciSysId)` |
| CI actions | `addBulkCIAction(requestorId, sysIdList, ciActionName, ciActionListOld, leaseTime)`, `removeBulkCIAction(requestorId, sysIdList, ciActionName)`, `getCIActions(ciSysId)` |
| Rule checks | `isNotAllowedAction(ciType, opsLabel, actionName)`, `isNotAllowedOpsTransition(ciType, opsLabel, transitionOpsLabel)`, `isCompatibleCIAction(actionName, otherActionName)` |

Bulk calls are capped by `glide.cmdb.statemgmt.max_bulk_count` (1000). Workflows can use their context as requestor id without registering. Unregister when done.

```javascript
// Background script or script include (server side, global scope)
var out = SNC.StateManagementScriptableApi.registerOperator();
var requestorId = new JSON().decode(out).requestorId;   // JSON() as in the docs sample; JSON.parse(out) may also work (?)
var sysIds = '<ci_sys_id_1>,<ci_sys_id_2>';            // format of the list is not stated in the docs (?)
gs.print(SNC.StateManagementScriptableApi.setBulkCIOperationalState(requestorId, sysIds, 'Repair in Progress'));
gs.print(SNC.StateManagementScriptableApi.addBulkCIAction(requestorId, sysIds, 'Patching'));
SNC.StateManagementScriptableApi.unregisterOperator(requestorId);
```

## Tables and jobs

`statemgmt_register_users`, `statemgmt_ci_actions`, `statemgmt_cmdb_actions` (actions per CI and requestor), `statemgmt_compat_actions`, `statemgmt_not_allow_actions`, `statemgmt_ops_state` (states per requestor), `statemgmt_renew_lease_task`, `statemgmt_ops_state_pri`, `statemgmt_not_allow_ops`. Records in the internal tables cannot be added by hand.

Other jobs installed: *Update life cycle from legacy* (status fields to **Life cycle stage** / **Life cycle status**) and *Update legacy from CSDM* (the reverse).

## Related

- [[CMDB Data Manager]] · [[CMDB Overview and Class Hierarchy]] · [[Proposed Changes to CIs]]
