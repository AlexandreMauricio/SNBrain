---
type: concept
tags: [concept, change, admin]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Change Management", topics "Change model management", "Change Models properties", "Change templates", "Enhanced change data model", "Create a Change model" and subtopics, "Change template management flows", "Change model attributes" (pp. 545-550, 597-609, 653-654), read 2026-10-02 Re-checked against the Brazil ITSM docs (Change Management chapter, 220 topics, https://www.servicenow.com/docs/r/it-service-management/change-management/change-lockdown.html and siblings), 2026-10-29: Brazil additions marked in the body.
sn-release: Australia, Brazil
verified:
updated: 2026-10-29
---

# Change models and change templates

**In one line:** a change model defines the states, transitions and transition conditions a change request follows; a change template, attached to a model, pre-fills and locks fields for a common change.

## Shipped models

| Family | Models |
|---|---|
| ITIL mode 1 | Normal, Standard, Emergency |
| Federated / mode 2 | DevOps, Cloud Infrastructure, Unauthorized, App (skips assessment), Low Risk, Patching |

## Building a model

**Change > Administration > Change Models** (role `change_manager`).

| Part | Fields |
|---|---|
| Model | **Name**, **Default Change Model**, **Active**, **Available in 'Create New'**, **Color**, **Implementation states** (also where Mass CI Update applies) |
| Security tab | **Advanced Security** adds **Available For / Not Available For / Can Write** user criteria lists (**Change > Models > User Criteria**); **Read Roles**, **Write Roles** |
| Preset Management | **Apply record preset**: field values that become read-only on changes of this model |
| Template Management | **Who can propose Templates** (anyone who can modify / read the model), **Template approval users / groups** |
| Model States | **State**, **Initial State** |
| Model State Transitions (under each state) | **From**, **To**, **Automatic Transition** (also stops manual selection of State) |
| Transition Conditions | **Requires**: *Mandatory Fields*, *Transition Condition* (condition builder or script returning true), or a predefined **condition type** |

State attributes: `allow_ci_modification` (CIs may be edited in that state) and `allow_implementation` (replaces the Implementation states field).

### Brazil additions (Brazil ITSM docs, not in the Australia PDF)

- **Change model attributes** (**Change > Models > Change Model Attributes**): Label, Name (underscores, used by scripts), Description, Application, Table (`change_request` or a child). Assigned per state in the state's **Attributes** list (Edit; clear **Active** to stop applying). An attribute does nothing until scripts check it. Shipped: *Allow CI Modification*, *Allow Implementation*, and further ones used by features: *Allow Conflict Detection* ([[Change Lockdown]]) and *Allow Child Change Creation* ([[Scaled Change (Primary and Child Changes)]]). If no state in a model has *Allow CI Modification*, the old behaviour applies (CI editable only in the initial state).
- Attribute API (server side, global): `new ChangeRequest(gr).getStateAttributes()`, `.hasStateAttribute(name)`, `.modelContainsAttribute(name)`, `.isInitialState()`, `.getInitialState()`, `new ChangeModel(model).hasStateAttribute(state, name)`. Client side: `g_scratchpad.change_model` on the change form (`containsAttribute`, `hasStateAttribute`, `field`, `initial_state`). Shipped pair client script and business rule *Change model: Read only CI* show the pattern.
- **State field policies** (related list on each model state): one field per policy, **Mandatory** and / or **Read only**, Application, Active. Enforced on the form and on the server (scripts and APIs too); messages list the missing or locked fields. Read only blocks only fields read only in both the old and the new state; preset values at creation are allowed; a field both mandatory and read only and empty can be filled once. Making a field mandatory adds a managed transition condition *State Field Policy Managed* (type Mandatory Fields) on every transition into that state, kept in sync automatically: do not edit it. Effective rules = policies of the current and target state + Mandatory Fields transition conditions + template field policies. Copied with the model. Base policies come from `com.snc.change_management.change_model.foundation` (e.g. Assignment group, CI, Short description, Description, planned dates, Close code and notes in given states).
- **ITIL change process** field on the model: Standard, Normal, Emergency or None. `ChangeRequest` API `newNormal()`, `newStandard()`, `newEmergency()` use the active model designated for that process (one per domain; you need write access to the model currently holding it), else the default model.
- Role `change_model_script_admin` (not elevated, inherited by no role): needed to edit the script field of transition conditions (**Requires** = Transition Script) and of **Change Model Condition Types** (Condition type = Script); others see it read only.

Transitions only fire when something **evaluates the model**: flow action **Evaluate Change Model**, a business rule (example: *Change Registration: Auto State Change*), or event `change_model.evaluate` with the change sys_id as parameter.

## Properties (`sys_properties`, search `*change_model`)

| Property | Effect |
|---|---|
| `com.snc.change_management.change_model.hide` | hide models (only with type compatibility on) |
| `com.snc.change_management.change_model.type_compatibility` | true = both type-based and model-based changes can be created; false (default) = model only. A type without a matching model is marked Legacy |
| `com.snc.change_management.change_model.manage_workflow` | let the ChangeRequest API cancel the default workflow context on type/state changes |
| `com.snc.change_management.change_model.default_read_roles` | roles that can read model records |

## Change templates

**Change > Models > Change Templates** or the **Change Templates** tab on a model.

1. Name, model, **Active**; save → state **Draft**.
2. **Change Request Template**: fields and default values.
3. **Template Field Policies**: per field **Mandatory** or **Read only**.
4. Optional **Change Task Template** children; categories (parent/child, **Order**).
5. **Publish** → **Proposed** (not editable). No approvers configured → **Published** immediately.

| State | Meaning |
|---|---|
| Draft | editable |
| Proposed | awaiting approval; rejected → Draft |
| Published | usable if Active |
| Pending Retirement | **Retire** requested; rejected → Published |
| Retired | not usable |

Changing a published template: **Copy** (new Draft with **Previous template**), or **Copy and retire** (the original retires when the copy is published). Flows: *STTRM Template Publish Approval*, *STTRM Template Retire Approval*. **Change Template Metrics** tab shows usage.

This template model is independent of, and optional beside, the older [[Standard Change Catalog]] proposals.

## Related

- [[Change Management Overview and Lifecycle]] · [[State Models and State Transitions]]
