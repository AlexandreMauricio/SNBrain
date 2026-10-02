---
type: concept
tags: [concept, choice-list, fields, roles, scripting]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Field administration", topic "Choice list field type" (pp. 890-898), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Choice lists

**In one line:** a choice field offers a fixed set of options; each option has a **label** that users see and a **value** that is stored and that scripts must use.

## How it works

- One choice can be selected at a time (no one-to-many).
- Choices are rows of Choice (`sys_choice`); each field that has a choice list has one record in Choice Set (`sys_choice_set`), which is what update sets carry, so all choices of a field travel together.
- Values: at most 40 characters; numeric values between -999 and 999.
- The dictionary **Choice** setting decides the form: dropdown with `-- None --`, dropdown without it (a default value is then required), or Suggestion.
- Any field type (integer, string, even reference) can be given a choice list: set **Choice** on its dictionary entry, save, **Create Choice List**. Existing distinct values become choices. A reference with too many records reverts to a normal reference.

## Labels versus values in scripts

`current.incident_state == "active"` is wrong: the choice labelled Active has the value `2`. Find values with **Show Choice List** on the field label.

**`-- None --`** has no `sys_choice` record and evaluates differently by context:

| Context | Value of None |
|---|---|
| Client side (client scripts) | `""` (empty string) |
| Server side (business rules) | `"0"` (the string zero) |

Coded state values and the business rules that depend on them: [[State Fields and Task State Values]].

## Who can edit choices

- Role `personalize_choices` (must be granted explicitly for **Show Choice List**; **Configure Choices** also works through an ACL).
- For one field only: an ACL granting the `personalize_choices` operation on that field. To *create* choices for the field, that ACL is required.
- **Do not add choices in the Show Choice List list. Use Configure Choices.**

## Common tasks

| Task | How |
|---|---|
| Add, remove, reorder options | field label, **Configure Choices** (for a dependent list, first select the controlling value on the form) |
| Reuse another field's choices | dictionary entry: **Choice table** and **Choice field**. The field then ignores its own list |
| Remove `-- None --` | dictionary **Choice** = *Dropdown without -- None --*, and set a default. On a dependent field None stays |
| Relabel `-- None --` | add a choice with **Value** `NULL_OVERRIDE` and the new label (a `javascript:` label is allowed) |
| Delete all choices of a field | `sys_choice_set.list`, delete the record for that table and element. On a list already in use, deactivate options instead |
| Add a search box to a long list | dictionary attribute `is_searchable_choice=true` |
| Add options at runtime | `g_form.addOption(...)` |

- Inactive or invalid stored values show in blue; the UI property *Display missing choice list entries* controls this.
- Changing choice options can break business rules that test specific values.

## Related

- [[Configure Choice List Options]] · [[Make a Field Dependent on Another Field]] · [[Field Types Reference]]
