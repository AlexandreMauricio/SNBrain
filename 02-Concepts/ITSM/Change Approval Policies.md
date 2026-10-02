---
type: concept
tags: [concept, change, flows, workflow]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Change Management", topics "Change approval policies", "Approval with e-Signature for change requests", "Creating change approval policies" and subtopics (pp. 552-554, 684-695), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Change approval policies

**In one line:** a policy is a decision table evaluated against a change request; each matching decision applies an **approval definition** that creates (or auto-answers) user or group approvals.

## Parts

| Part | Where | Content |
|---|---|---|
| Approval definition | **Change > Change Policy > Approval Definitions** | **Approval action**: *Approve* / *Reject* (creates an already-answered approval for **User**), *Add a user approval*, *Add a group approval*. **Mandatory** = the policy waits for it. **Approver source**: *Approval Definition* (fixed user/group) or *Change Request* (a reference field on the change). **Wait for** (groups): *First response*, *All responses*, *Percentage of users* |
| Policy | **Change > Change Policy > Change Approval Policies** | **Execution**: *First decision that matches* (by **Order**) or *Run all decisions that match* |
| Policy inputs | tab on the policy | default `change_request` (reference); the normal policy also has `manager_approved` (true/false) |
| Decisions | tab on the policy | conditions on the inputs + **Answer** = an approval definition |

With the Decision Builder plugin the same policy is edited as a decision table.

## Using a policy

- **Flow**: action **Apply Change Approval Policy** (ITSM spoke): **Policy**, **Change Request**, **Due Date** (None, or auto Approve / Reject / Cancel at the due date). It wraps *Ask For Approval* and never asks the same user twice.
- **Legacy workflow**: activity **Change Approval Policy** (only on `change_request` workflows) with **Policy Input** script and **Finish condition**; results Approved, Rejected, Canceled, Skipped (no decision matched), Finished. Use one per workflow stage instead of Approval - User / Group activities.

## Example

Decision: `Change request.State is Assess AND Change request.Risk is Low` → definition *Auto-approve* (action Approve). Decision: `Risk is High` → definition *CAB approval* (group approval, all responses, mandatory).

## Gotchas

- The same approval definition is applied only once even if several decisions return it.
- Percentage: empty or ≤ 0 means first response, ≥ 100 means all; rounded to the nearest integer.
- e-Signature approvals (platform plugin) work with flows, workflows and policies on Change Request and Standard Change Proposal.

## Related

- [[Change Management Overview and Lifecycle]] · [[CAB Workbench]]
