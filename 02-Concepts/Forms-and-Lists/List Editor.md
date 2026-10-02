---
type: concept
tags: [concept, forms-lists, access-control, client-script, ui-policy, security]
status: documented
source: ServiceNow Australia Platform Administration PDF, "List administration", topic "List editor administration" (pp. 1007-1013), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# List editor

**In one line:** the list editor lets users change field values by editing cells in a list, without opening the form, and therefore bypasses some form-side controls.

## What it does and does not enforce

| Control | List v2 | List v3 |
|---|---|---|
| ACLs (write and `list_edit`) | enforced | enforced |
| UI policies | **not enforced** | enforced |
| Mandatory dictionary attribute | | enforced |
| Client scripts | **not enforced** | **not enforced** |

If client scripts or UI policies protect fields on the form, either disable list editing for the table or enforce the rule server-side with a business rule, data policy or ACL.

**Task state fields from child tables cannot be edited from a Task list** (`incident_state`, `problem_state`, `phase_state`, `request_state`): edit them from the child table's list or form.

## Switching it on and off

| Level | How |
|---|---|
| Whole instance | `glide.ui.list_edit` (*Enable list editing*), on by default |
| Field types (List v2 only) | `glide.ui.list_edit_ignore_types`. Not editable by default: conditions, currency, document_id, field_list, html, user_image, glide_list, price, template_value, glide_time, user_roles, video, array |
| One list | list control **List edit type**: Save immediately, Save data by rows, Disable list editing; **List edit insert row** ([[List Configuration and List Controls]]) |
| One user | preferences `list_edit_enable` (default true) and `list_edit_double` (double-click, default true) |

## The list_edit ACL operation

`list_edit` is a security operation checked **in addition to write**. To edit a cell, the user needs write and list_edit on the field, on its dependent fields, and on fields that depend on it. Create rules under **System Security > Access Controls**.

| Goal | ACL (type record, operation list_edit) |
|---|---|
| Nobody edits Incident from a list | name `incident`, **Admin overrides** cleared, script `answer = false;` |
| Only admins edit Short description from a list | name `incident.short_description`, **Admin overrides** ticked, script `answer = false;` |
| No list edits on software incidents | name `incident`, script `answer = (current.category != 'software');` |
| No list edits on critical incidents | name `incident`, condition **Priority is not 1 - Critical** |

## Related

- [[List Configuration and List Controls]] · [[UI Policies]] · [[Data Policies]]
