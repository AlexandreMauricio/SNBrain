---
type: concept
tags: [concept, instance-admin, update-sets]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Upgrade Center", topics "Process the skipped records list", "Revert a customization", "Resolve a skipped update", "Create a skipped record rule", "Default skipped rules" (pp. 2866-2900), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Skipped records in upgrades

**In one line:** when you change a base record, the platform notes it in **Customer Updates** (`sys_update_xml`); an upgrade then **skips** that record instead of overwriting it, and lists it for you to decide.

## Why a record is skipped

- A current version of the record exists in `sys_update_xml` → it is "customised" → the upgrade does not apply its new version.
- Not skipped if only excluded fields changed.
- Customised records that the vendor did **not** change in this release need no action (list *Customization Unchanged*).

## Dispositions (what the upgrade did)

Inserted, Updated, Deleted, **Skipped**, **Reverted** (you took the base version), Unchanged, Table not found, Skipped Manual Merge, Skipped Apply Once, Skipped Error (for example the record exists in another scope), Not Latest. In a preview the same values are prefixed *Predicted*.

## Priority

| Priority | File types |
|---|---|
| 1 | UI pages, UI macros and similar |
| 2 | business rules, ACLs and similar (scripts) |
| 3 | reports and similar |
| 4 | form sections, related lists, choice sets |
| 5 | everything else |

Start with 1 and 2: that is where behaviour breaks.

## Your options per record

| Action | How | Resolution status |
|---|---|---|
| Keep your version | set the status | Reviewed and Retained |
| Merge | **Resolve Conflicts**: base on the left, yours on the right, move fields or script blocks across, **Save Merge** | Reviewed and Merged |
| Take the new base version | **Revert to Base System** (undo with **Reapply Changes**) | Reviewed and Reverted; disposition Reverted |
| Looked, nothing to do | set the status | Reviewed |
| Later | leave | Not Reviewed |

Any status other than Not Reviewed moves the record from *Skipped Changes to Review* to *Skipped Changes Reviewed*. Reverts and merges create customer updates, so they travel in an **update set**. The upgrade detail records themselves (comments, resolutions) do **not** travel: export them if you need them.

## Skipped record rules

**Upgrade Center > Administration > Skipped Record Rules Editor**. A rule has **Conditions** (on not-yet-reviewed skipped records), **Order**, and an **Action**:

- Keep My Modifications (Always Retain)
- Revert and Keep Inactive
- Assign Skipped Records to User
- Assign Tags to Skipped Records

Rules run automatically during the upgrade (their effect is predicted in Upgrade Preview) or on demand (**Run Now**, or **Run skipped Record Rules** on the latest upgrade history). Not usable together with an Upgrade Plan.

Default rules since Xanadu auto-retain skips on configuration tables, so they need no review: `sys_ui_section`, `sys_ui_form`, `sys_ui_form_section`, `sys_ui_related_list`, `sys_ui_list`, `sys_choice`, `sys_choice_set`, `sysevent_email_action`, `sys_report`, `pa_dashboards`, `wf_workflow` (and `wf_workflow_version`).

## Practical consequences

- Every base record you edit is a future skipped record and a missed fix. Prefer adding (new business rule, UI policy, override) over editing base records.
- After reverting or merging, test.
- When reviewing in a scope, be in that application scope, or the update set ends up with mixed scopes.

## Related

- [[Upgrades - Process, Upgrade Center and Upgrade Console]] · [[Process the Skipped Records List after an Upgrade]] · [[Dictionary Overrides]]
