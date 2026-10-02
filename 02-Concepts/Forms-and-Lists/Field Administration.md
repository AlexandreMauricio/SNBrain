---
type: concept
tags: [concept, fields, schema, forms-lists, roles]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Field administration" (pp. 800-813), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Field administration

**In one line:** a field is a column of a table shown as a form field and a list column; most of its behaviour (label, type, length, default, mandatory, unique, dependency) is set on its dictionary entry.

## Rules and limits

- **Editing a field on a child table that is defined on the parent changes it on the parent and every other child.** Use a [[Dictionary Overrides|dictionary override]] for per-table behaviour.
- Custom fields get the prefix `u_`. Leading digits in the label are replaced by it.
- Use only supported field types for custom fields; some types (e.g. User Input) are internal.
- **To change a field's data type**: create a new column of the new type, copy the data with a background script, and relabel the old column. Do not convert in place.
- Database limits: at most 1,000 columns per table (the real number depends on the database); row size at most 65,535 bytes; **no more than 10 medium-length or longer String fields per table**, otherwise saves can fail with `Row size too large (> 8126)`.
- Field Name and Table Name field types depend on each other; a Field Name field always has a value (`sys_id` by default) and cannot be None.
- Kanji characters in column identifiers are not supported.

## Common settings and who can change them

| Setting | How | Role | Notes |
|---|---|---|---|
| Add a field | form menu, **Configure > Form Layout**, **Create new field** | admin | [[Add or Delete a Field]] |
| Label, hint, help | right-click the label, **Configure Label** | `personalize_dictionary` | label up to 80 characters, 30 or fewer recommended. No HTML in labels or hints. **URL** makes the label a link |
| Mandatory | dictionary **Mandatory** | `personalize_dictionary` | see below |
| Default value | dictionary **Default value** | `personalize_dictionary` | [[Set a Default Field Value]] |
| String length | dictionary **Max length** | `personalize_dictionary` | a change that would truncate data is cancelled |
| Unique | dictionary **Unique** (add to the form) | `personalize_dictionary` | only if no duplicates exist. If a non-unique index exists, drop it and create a unique one in Tables & Columns |
| Dependent | dictionary **Dependent field** | `personalize_dictionary` or admin | [[Make a Field Dependent on Another Field]] |
| Style | right-click the label, **Configure Styles** | `personalize_styles` or admin | [[Define a Field Style]] |
| Delete | dictionary, **Delete Column** | admin | custom fields only; removing from forms and lists is preferred |

## Mandatory fields: what the dictionary flag does and does not do

- Mandatory is **global**: everywhere the field appears on a form.
- **It is not enforced for web services or background scripts.** Use a [[Data Policies|data policy]] for that.
- No effect on True/False fields (false counts as a value).
- A field pre-filled by default or script shows no mandatory indicator until emptied.
- A mandatory reference field can be saved empty if its parent field is also blank.
- Mandatory only on a child table: dictionary override with **Override mandatory**.

## Derived field labels

A dot-walked field on a form (the caller's email on an incident) is labelled short ("Email") or long ("Caller Email") by the property `glide.short.labels` (default true = short), under **System Properties > System**.

## Highlighted values (workspaces)

**Workspace Experience > Administration > Highlighted Values**: pick a table and field, then add **Highlighted Value Conditions** (condition, **Status** colour, **Show Icon**, **Value Override** text, **Order**). The condition can be on a different field from the one highlighted. Not for Reference, URL or Document ID fields. To switch it off for one filtered list: `sys_aw_list.list`, tick **Ignore Highlight in List**.

## Related

- [[Dictionary Entry Form]] · [[Record Numbering]] · [[Data Policies]] · [[Data Lookup and Record Matching]] · [[Field Normalization and Transformation]]
