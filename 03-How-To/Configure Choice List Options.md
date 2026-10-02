---
type: how-to
tags: [how-to, choice-list, fields]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Field administration", topics "Define an option for a choice list", "Reuse a choice list", "Remove the None option", "Change the None display value" (pp. 894-896), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Configure choice list options

**Goal:** change the options of a choice field, reuse another field's list, or change how None appears.
**Prerequisites:** role `personalize_choices` (and `personalize_dictionary` for dictionary changes).
**Navigation:** right-click the field label on a form

## Steps: add, remove or reorder options

1. Open a form with the field. If the list depends on another field, first select the controlling value (e.g. **Category** = Hardware before editing **Subcategory**).
2. Right-click the field label, **Configure Choices**.
3. Use the slushbucket to add, remove, reorder or create items.
4. **Save**.

## Steps: reuse another field's choices

1. Right-click the label of the field that should reuse the list, **Configure Dictionary**.
2. Set **Choice table** to the table of the source field and **Choice field** to that field.
3. **Update**.

## Steps: remove None

1. **Configure Dictionary** on the field.
2. Set **Choice** to *Dropdown without -- None -- (must specify a default value)* and fill **Default value**.

## Steps: relabel None

1. Right-click the label, **Show Choice List**, **New**.
2. Leave **Element** as filled in, set **Language**, enter the **Label**, and set **Value** to `NULL_OVERRIDE`. Leave Sequence, Dependent value and Hint empty.
3. Submit.

## Result / how to check it worked

Reload the form and open the dropdown.

## Example

On a custom table, the field *Example Region* reuses the choices of *Example Region* on another table through Choice table and Choice field; adding a choice on the source shows on both.

## Tables / fields involved

- `sys_choice`: one row per option (Table, Element, Language, Label, Value, Sequence, Dependent value, Inactive)
- `sys_choice_set`: one record per field with a choice list

## Gotchas

- Without `NULL_OVERRIDE` as the value, the new label appears **in addition to** `-- None --`.
- Use the stored **value** in scripts and default values, not the label.
- Business rules may depend on specific values, especially state fields ([[State Fields and Task State Values]]).
- Background: [[Choice Lists]].
