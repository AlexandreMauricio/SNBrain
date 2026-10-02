---
type: concept
tags: [concept, data-integrity, fields, cmdb, roles]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Field administration", topic "Field normalization and transformation" (pp. 819-846), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Field normalization and transformation

**In one line:** normalization replaces the many variants of a value with one **normal value** (Xeon L3350, Intel Xeon... become Xeon); transformation rewrites raw input by rules (trim, change case, round, replace).

## Setup

- Plugin **Field Normalization** (`com.snc.field_normalization`). Application **Field Normalization**.
- Roles: `normalizer` (manage; contains `normalization_tester`), `normalization_tester` (create test records).
- **Not supported with domain separation.**
- Field types enabled by default (**Administration > Normalization Field Types**):

| Field type | Normalize | Transform |
|---|---|---|
| String, URL | yes | yes |
| Decimal, Float, Integer, Numeric | no | yes |

Do not enable types that store a sys_id (reference, field name, table name): normalize the display field on the **target** table instead (e.g. **Name** on Company `core_company`).

## Normalization

A **normalization record** (**Configurations > Normalizations**) names the table and field. Its **normal values** each have:

- **Aliases**: known variants, picked from the collected **Pending Values**. Use for a short list. Processed first.
- **Rules**: conditions (`contains`, `matches pattern`, `matches regex`) for many variants. Processed after aliases, in **Order**, stopping at the first true one. **Make alias** turns a matched pending value into an alias.

Options on the record: **Mode** (Off, Test, Active), **Normalize query** (queries using a raw value return the normal value), **Coalesce each normal**, **Raw field** (a custom field that keeps the original input).

- Scripts that insert or update through GlideRecord are normalized automatically.
- **Coalesce**: for a referenced table full of duplicates (many spellings of one company), references are redirected to the record chosen in **Coalesce to** and **the duplicate records are deleted**. Permanent: a rollback restores the records but not the references. Filter conditions that mention the old names are not fixed.

## Transformation

A **transformation record** (**Configurations > Transformations**) names table and field and has ordered **transforms**. Each has parameters, a condition, **Order**, **Final** (stop here if the condition is true) and **Case sensitive**.

| Category | Definitions |
|---|---|
| Text | Left, Right, Substring, Delete, Insert, Prefix, Suffix, Replace, Change Case (Upper, Lower, Proper, Formal), Trim, Constant |
| Numeric | Round (interval plus mode: half up, half down, half to even, up, down, toward zero and others), Limit, Constant |

- **Positions**: positive counts from the left, negative from the right, and `/regex/...` computes the position from a regular expression.
- Replace with a regex: Find `/regex/.*\\(.*)`, Replace with `$1` turns `domain\machine` into `machine`.
- **Pattern matching** (conditions only, operator *matches pattern*): `*` any characters, `?` one character.
- A transformation on a parent table applies to its children (Computer covers workstations and servers).
- Custom definitions: **Administration > Transform Definitions**, with variables and a script `function(variables, value, parameters) { ... return newValue; }`.

## Test mode and data jobs

- Records start in **Test** mode: only records created or updated by a `normalization_tester` are changed, and data jobs cannot be started. Transformations also have a **Test transforms** related link to try a raw value.
- Changes to existing data happen only when you **start the data job** (record in **Active** mode): Alias application, Rule application, Normal value change, Coalesce to normal, Transform application. Pending value collection runs by itself.
- Completed jobs can be **rolled back** (**Data Jobs > All**, **Rollback**).
- With the plugin active, new records are normalized on insert.

## Gotchas

- The user who runs a transform onto a Date/Time target must have the date format `yyyy-MM-dd`.
- The normalization icon on a field opens the record for `normalizer` users and a help page for others (preference *Restrict decorations to roles*).

## Related

- [[Field Administration]] · [[Data Policies]]
