---
type: how-to
tags: [how-to, fields, scripting, glide-api]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Field administration", topics "Specify a default field value" and "Default field value examples" (pp. 808-810), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Set a default field value

**Goal:** have a field filled automatically on new records, with a constant or a computed value.
**Prerequisites:** role `personalize_dictionary`.
**Navigation:** right-click the field label on a form, Configure Dictionary

## Steps

1. Right-click the field's label and select **Configure Dictionary**.
2. Enter the value in **Default value**:
   - a constant, or
   - `javascript:` followed by a script that produces the value.
3. **Update**.

For date and time fields, prefer **Use dynamic default** with a dynamic filter option over a hard-coded value.

## Result / how to check it worked

Open a new record: the field shows the default. The default is also applied on submit if the field is still empty.

## Example

| Want | Default value |
|---|---|
| A choice field starting at a given choice | the choice **value** (e.g. `4`), not its label |
| A group reference by name | `javascript:GetIDValue('sys_user_group', 'Example Group');` |
| Assign to the current user if they have a role | `javascript:if (gs.hasRole("itil")) current.assigned_to = gs.getUserID();` |
| A duration | `javascript:current.duration_field.setDisplayValue('3 04:30:14');` |

To see the scripts ServiceNow ships: **System Definition > Dictionary**, filter **Default value starts with javascript**.

## Tables / fields involved

- [[sys_dictionary]]: **Default value**, **Use dynamic default**, **Dynamic filter value**

## Gotchas

- The default must be the stored value, of the right type (an integer field takes `2`, not `two`).
- A hard-coded date-time breaks if the system date format changes.
- For a different default on a child table, use a dictionary override ([[Dictionary Overrides]]).
