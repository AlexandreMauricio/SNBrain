---
type: how-to
tags: [how-to, ui-policy, forms-lists]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Form administration", topics "Create a UI policy" and "Example: creating a UI policy" (pp. 790-794), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Create a UI policy

**Goal:** make fields mandatory, read-only or hidden on a form when a condition is true.
**Prerequisites:** role `ui_policy_admin`.
**Navigation:** All > System UI > UI Policies

## Steps

1. Open **All > System UI > UI Policies** and select **New**.
2. Set **Table** and **Short description**.
3. Build the **Conditions**.
4. Decide **Reverse if false** and **On load**. In the Advanced view also **Order**, **Global** / **View**, **Inherit**.
5. Save with the form context menu (**Save**), so the **UI Policy Actions** related list appears.
6. In that list select **New**: choose the **Field name** and set **Mandatory**, **Visible**, **Read only**. Submit. Repeat per field.
7. For scripts, tick **Run scripts** and fill **Execute if true** / **Execute if false**.

## Result / how to check it worked

Open a record of the table and change the field in the condition: the fields react at once.

## Example

On Incident, when **Incident state is Resolved** (Reverse if false and On load ticked):

| Field | Mandatory | Visible | Read only |
|---|---|---|---|
| Close notes | True | Leave alone | Leave alone |
| Opened by | Leave alone | False | Leave alone |
| Priority, Severity, Urgency | Leave alone | Leave alone | True |

## Tables / fields involved

- the table's form fields named in the actions

## Other ways to do this

[[UI Policy or Client Script]]

## Gotchas

- Conditions are rechecked only on manual field changes, not on changes from UI actions or the list editor.
- A child table's policy runs before an inherited parent policy regardless of order.
- More in [[UI Policies]].
