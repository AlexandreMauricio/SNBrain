---
type: concept
tags: [concept, data-integrity, fields, api, import-sets, ui-policy]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Field administration", topic "Data policy" (pp. 847-851), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Data policies

**In one line:** a data policy makes fields mandatory or read-only for **all** data entering the system (forms, imports, web services, scripts), where a UI policy only covers the browser form.

## How it works

- A data policy has conditions and **Data Policy Rules**; each rule names a field and sets **Read Only** and **Mandatory** to True, False or Leave alone.
- Data that breaks the policy is rejected with an error.
- Applied by default to **all GlideRecord operations**, including Scripted REST APIs and the REST Table API.
- You can opt out for: SOAP web service targets, import sets, and the client-side UI policy.
- **A data policy is always enforced when a record is submitted from the UI.** This cannot be changed.
- It cannot hide fields; keep a UI policy for visibility.

## Fields

| Field | Notes |
|---|---|
| **Table** | tables and views in the policy's scope |
| **Inherit** | also apply to tables that extend it (a Task policy then covers Incident, Problem, Change) |
| **Reverse if false** | undo the action when the conditions become false |
| **Apply to import sets** | includes web service import sets |
| **Apply to SOAP** | SOAP web services (not scripted SOAP; no effect on REST) |
| **Use as UI Policy on client** | also enforce in the browser through the UI policy engine, so users see it before saving |
| **Active**, **Short description**, **Description**, **Application** | |

## Converting

- **UI policy to data policy**: related link **Convert this to Data Policy** (role `ui_policy_admin`). Eligible only if **Run scripts** is off, **Global** is on, and no action sets **Visible**. The UI policy is deactivated; tick **Use as UI Policy on client** to keep the form behaviour.
- **Data policy to UI policy**: **Convert this to UI Policy**. The data policy is deactivated and enforcement drops to the form only. You gain the Visible option.

## Where it lives in the data

- `sys_data_policy2` (Data Policy), `sys_data_policy_rule` (Data Policy Rule)
- Module **System Policy > Rules > Data Policies**; also **Configure > Data Policies** from a form header or list.
- Roles: admin to edit; `data_policy_admin` to maintain policies.

## Limits

- For a table in another scope, rules can only target fields in the policy's scope and cannot make a field mandatory.
- Several rules on one field are possible but not recommended.
- Debug: **System Diagnostics > Session Debug > Debug Data Policies**.

## Related

- [[UI Policies]] · [[UI Policy or Data Policy]] · [[Create a Data Policy]] · [[Field Administration]]
