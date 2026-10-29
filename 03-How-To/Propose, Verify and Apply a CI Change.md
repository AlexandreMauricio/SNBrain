---
type: how-to
tags: [how-to, cmdb, change]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > CMDB > Managing proposed changes (procedures View, Add, Apply, Verify, Create a verification rule), read through the docs site API 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/configuration-management-database-cmdb/c_ProposedChanges.html
sn-release: Brazil
verified:
updated: 2026-10-29
---

# Propose, Verify and Apply a CI Change

**Goal:** record the CI field and relationship changes a change request will make, check them, and apply them only after approval.
**Prerequisites:** role `sn_cmdb_editor` or `itil` (`personalize_form` for step 1; `asset`, `sn_cmdb_editor` or `itil` for a verification rule).
**Navigation:** All > Change > Open; All > Configuration > Change Verification > Proposed Change Verification Rules

Background: [[Proposed Changes to CIs]].

## Steps

1. **Once per class form:** open a CI, right-click the header > **Configure > Form Layout**, move **CMDB Scheduled Changes** to *Selected*, **Save**.
2. *(Optional)* Create a verification rule: **New**, set **Rule name**, **Table name**, **Filter condition**, **Active**, and a **Rule script** returning true or false. **Submit**.
3. Open the change request. In **Affected CIs**, click **Edit** to add the CI if it is missing.
4. Right-click the CI > **Proposed Change**. Enter the new field values and click **Save Proposed Change** (not *Update* or *Delete*: those change the CI at once).
5. For a relationship: click **+** under *Related Items*, add or remove the relationship, **Save Proposed Change**, confirm.
6. *(Optional)* On the change request click **Verify Proposed Changes** and read the message; details in the **Proposed Change Verification Log** related link.
7. When your process allows (normally after approval), click **Apply Proposed Changes**. Reload the form if the values do not appear.

## Result / how to check it worked

Before step 7 the CI still shows its old values, and the *Scheduled changes* area lists the proposal. After step 7 the CI has the new values and *Scheduled changes* says "No scheduled changes found".

## Example

Change request *Upgrade Example Server* has the affected CI *example-app-01*. Propose **Operating System** = *Example OS 2* and a new *Runs on::Runs* relationship to *example-host-02*, save. A rule *Example OS check* on Server checks the proposed OS. **Verify Proposed Changes** passes. After approval, **Apply Proposed Changes** updates the CI and adds the relationship.

## Tables / fields involved

- Affected CIs (`task_ci`) on [[change_request]]; the CI class table (for example `cmdb_ci_server`); CI Relationship (`cmdb_rel_ci`)

## Gotchas

- A failed verification does **not** block applying.
- A proposed change cannot be deleted.
- Not for user or group relationships.
