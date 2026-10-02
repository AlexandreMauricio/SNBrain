---
type: reference
tags: [reference, platform, schema, reference-field, choice-list]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration" (pp. 482-489), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Dictionary Entry form

Navigation: **All > System Definition > Dictionary** (table [[sys_dictionary]]), or right-click a field label on a form and choose **Configure Dictionary** (or **Show <field name>**). Entries with **Type = Collection** describe the table itself. Some fields only show in the **Advanced view** (related link). Role: admin. Grouped and paraphrased.

## Main fields

| Field | Notes |
|---|---|
| **Table** | table the element belongs to (only tables allowed by scope protection are listed) |
| **Type** | field type, or Collection for a table. Only change between types that map to the same physical type (e.g. Choice and String) to keep data |
| **Active** | inactive fields are removed from forms and from the condition builder, but stay in admin-configured lists until the layout is changed, still work in existing reports, and are still readable and writable by GlideRecord scripts and the API |
| **Function field** / **Function definition** | a field showing the result of a database function. Definition starts with `glidefunction:`, e.g. `glidefunction:concat(short_description, ' ', caller_id.name)`. Parameters can dot-walk. Cannot be turned back into a normal field after saving |
| **Read only** | legacy check box; selected and greyed out when a **Read only option** is set or the field was read-only before Australia |
| **Read only option** | see [[Read-Only Field Options]] |
| **Audit** | tables only: turns auditing on |
| **Text index** | tables only: whether searches index the table's text |
| **Column label** | label on forms and lists; also updates the language file for the current language |
| **Column name** | generated from the label: `u_` prefix in global, scope prefix for a field added to another scope's table, no prefix inside its own scoped app. Lowercase letters, digits and underscores only; double underscores are collapsed. **Cannot be changed after creation** |
| **Max length** | strings only. Under 255 = single-line box, 255 or more = multi-line. Mapped to the nearest physical type, so 50 becomes VARCHAR(100) and 1000 becomes MEDIUMTEXT. Only shorten a field that holds no data |
| **Mandatory** | must have a value to save. Can be overridden on child tables |
| **Display** | marks the one field used as the record's display value in reference fields and form titles. Number is the display value on all task tables. Does not affect form or list layout |
| **Attributes** (Advanced) | see [[Dictionary Attributes Reference]] |

## Default value

| Field | Notes |
|---|---|
| **Default value** | must match the field type (an integer field takes `2`, not `two`) |
| **Use dynamic default** / **Dynamic filter value** (Advanced) | default produced by a dynamic filter option |

## Reference specification

| Field | Notes |
|---|---|
| **Reference** | makes the field a reference to that table. **Typing a name that matches no table creates a new table on save** (and a module, if the current table has one) |
| **Use reference qualifier** (Advanced) | Simple (condition builder), Dynamic (dynamic filter option) or Advanced (encoded query string or JavaScript) |
| **Reference qual condition** / **Dynamic ref qual** / **Reference qual** | the qualifier for each mode. Filters the records the field offers |
| **Reference key** (Advanced) | a field other than `sys_id` used as the unique identifier |
| **Reference cascade rule** (Advanced) | what happens to this record when the referenced record is deleted: **Clear** (default), **Delete** (delete the referencing records), **Restrict** (block the delete), **None** |
| **Reference floats** (Advanced) | enables the **Edit** button on related lists for one-to-many relationships |
| **Dynamic creation** / **Dynamic creation script** (Advanced) | typing a value with no match creates a record on the referenced table, using the script |

## Dependent field and choice list

| Field | Notes |
|---|---|
| **Dependent on field** (Advanced) | field this one depends on. Can be overridden on child tables |
| **Choice** | none, dropdown without `-- None --`, dropdown with `-- None --`, or Suggestion |
| **Choice table** / **Choice field** (Advanced) | reuse the choices of another choice field (e.g. Incident + Priority), kept in sync |

## Calculated value (Advanced)

| Field | Notes |
|---|---|
| **Calculated** | value is computed. Sorting, filtering and grouping use the value stored at the last update |
| **Calculation Type** | Script or Formula |
| **Calculation** | the script (can use `current`, return true/false, set an `answer` variable, or set a field directly) or formula. Calculated fields show as read-only on forms and cannot be edited inline in lists |

Calculated fields are populated **before any business rule runs**, even before-rules, and again after before-rules if needed ([[Order of Execution for Rules, Engines and Notifications]]).

## Other fields

| Field | Notes |
|---|---|
| **Class** | the table this one extends (its own name if it extends nothing) |
| **Size class** | set by a scheduled job; marks large tables so less memory is held per row |
| **Spell check** | on or off for the field |
| **Unique** | values must be unique. Enabling it on a table that already has differing values **causes data loss** |
| **Defaultsort** | obsolete |

Related lists: Access Controls, Choices, Dictionary Overrides, Attributes, Labels.

## Related

- [[Dictionary Overrides]] · [[Tables, Records and Table Relationships]] · [[Create a Table]]
