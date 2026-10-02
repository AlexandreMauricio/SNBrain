---
type: concept
tags: [concept, change, admin]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Change Management", topics "Change model management", "Change Models properties", "Change templates", "Enhanced change data model", "Create a Change model" and subtopics, "Change template management flows", "Change model attributes" (pp. 545-550, 597-609, 653-654), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
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
