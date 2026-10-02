---
type: how-to
tags: [how-to, fields, choice-list, reference-field]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Field administration", topic "Make a field dependent" (pp. 810-811), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Make a field dependent on another field

**Goal:** limit the values offered by a choice or reference field according to the value of another field on the same table.
**Prerequisites:** role `personalize_dictionary` or admin.
**Navigation:** right-click the field label on a form, Configure Dictionary

## Steps

1. Open a form of the table and right-click the label of the field that should depend on another.
2. Select **Configure Dictionary**.
3. On the **Dependent field** tab, tick **Use dependent field** and choose the field it depends on.
4. **Update**.

## Result / how to check it worked

On the form, changing the controlling field changes the options of the dependent one.

## Example

On Incident, **Subcategory** depends on **Category**: the category chosen decides which subcategories are listed.

## Tables / fields involved

- [[sys_dictionary]]: **Dependent on field**
- the choice records of the dependent field, each tied to a value of the controlling field

## Other ways to do this

If the dependency does not behave as expected (for example a many-to-many relationship between the two fields), use a **reference qualifier** on the dependent field instead ([[Dictionary Entry Form]]).

## Gotchas

- A field cannot depend on a derived (dot-walked) field.
- For a dependency between reference fields like Assignment group and Assigned to, the controlling field's name needs `_group` in it to get the expected behaviour (the guide points to KB0998861).
- Can be overridden per child table with a dictionary override.
