---
type: how-to
tags: [how-to, data-integrity, fields]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Field administration", topic "Create a data policy" (pp. 848-850), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Create a data policy

**Goal:** make a field mandatory or read-only for every way data can reach a table, not only the form.
**Prerequisites:** role admin (or `data_policy_admin`).
**Navigation:** All > System Policy > Rules > Data Policies (or Configure > Data Policies from a form header)

## Steps

1. Open **System Policy > Rules > Data Policies** and select **New**.
2. Choose the **Table** and the options: **Inherit**, **Reverse if false**, **Apply to import sets**, **Apply to SOAP**, **Use as UI Policy on client**.
3. Build the **Conditions**.
4. Save from the header context menu, so **Data Policy Rules** appears.
5. In that list select **New**: choose **Field name** and set **Mandatory** and **Read Only**. Submit.
6. Repeat step 5 for other fields.

## Result / how to check it worked

Try to break the rule through an import or the Table API: the operation is rejected with an error. On the form, the field shows as mandatory if **Use as UI Policy on client** is ticked.

## Example

On Problem: condition **Problem state is Closed/Resolved**, rule **Close notes** Mandatory = True, with **Apply to import sets** ticked. A web service update that closes a problem without close notes fails.

## Tables / fields involved

- `sys_data_policy2`, `sys_data_policy_rule`

## Other ways to do this

[[UI Policy or Data Policy]]

## Gotchas

- Always enforced on UI submit, whatever the options.
- Cannot hide a field.
- On tables of another scope, mandatory cannot be set.
- Background: [[Data Policies]].
