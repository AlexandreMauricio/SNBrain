---
type: concept
tags: [concept, platform, schema, reporting, fields, glide-api]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration" (pp. 483, 485, 582-584) and "Field administration", topic "Function field" (pp. 903-911), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Function fields

**In one line:** a function field stores nothing; it shows the result of a database function (concatenation, length, arithmetic, date difference) computed by the database when the record is read.

## How it works

- Created as a dictionary entry with **Function field** ticked and a **Function definition** ([[Dictionary Entry Form]]). No database column exists for it.
- Definition format: `glidefunction:` + operation + parameters. Constants in single quotes. Field parameters can dot-walk (`cmdb_ci.name`).
- Usable like any field: forms, lists, filters, condition builder, reports.
- **Irreversible**: once saved, it cannot become a normal field, nor the reverse.
- Can be created on a table or on a [[Database Views|database view]]. On a view, columns need the view's variable prefix: `glidefunction:concat(mi_definition.name,' ',mi_value)`.
- In scripts, the same functions are built with `GlideDBFunctionBuilder` and applied with `GlideRecord.addFunction()`.

## Function field or something else

| Compared with | Difference |
|---|---|
| Calculated field | a calculated value is **stored** and can be stale; a function field is computed on retrieval and always current |
| Business rule | use a function field when the logic is a simple transformation of existing fields; nothing to store or maintain |
| Script-side string handling | the database does the work, not the application node |

## Operations

| Operation | Does | Returns |
|---|---|---|
| `concat(a, 'x', b, ...)` | joins fields and constants | text |
| `length(field)` | number of characters | whole number |
| `substring(field, 'start', 'length')` | part of a string | text |
| `position('x', field[, 'from'])` | position of the first occurrence, 0 if absent | whole number |
| `coalesce(a, b, c)` | first non-empty value | text |
| `add`, `subtract`, `multiply`, `divide` | arithmetic on two numbers or fields (numbers in quotes) | number |
| `greatest(...)`, `least(...)` | highest or lowest; also for dates and strings | number |
| `datediff(end, start)` | difference between two date/times | duration |
| `dayofweek(date, '1' or '2')` | day number; `'1'` week starts Sunday, `'2'` Monday. Uses UTC dates | whole number |
| `distance_sphere(...)` | metres between two geo points or longitude and latitude pairs | decimal |
| `get_latitude`, `get_longitude`, `to_geopoint` | convert between geo point and coordinates | float, geo point |

Examples: `glidefunction:datediff(closed_at, sys_created_on)`, `glidefunction:coalesce(closed_at, resolved_at, sys_updated_on)`, `glidefunction:divide(distance_sphere(location1, '-0.189937', '51.473584'), '1000')`.

## Limits

- **A function field must not reference another function field**: it errors.
- Cannot be audited, indexed or encrypted. For performance, index the fields the function uses (ideally a composite index).
- The dictionary type must be compatible with the function's return type, or exceptions occur.
- Function field names must be unique.
- Function fields created in the Reporting UI do not support dot-walking.
- Security is evaluated on the fields used and on the result.

## How to create one

1. **All > System Definition > Dictionary**, **New**, tick **Function field**.
2. Set **Table**, **Type**, **Column label**, **Max length**, **Function definition**. Submit. Role `personalize_dictionary` or admin.
3. Add the field to a list or form. Test in sub-production first.

## Reading the result

- `Invalid function`: invalid definition, string-type field.
- Empty value: invalid definition, other types.

## Related

- [[Create a Database View]] · [[sys_dictionary]] · [[Field Types Reference]]
