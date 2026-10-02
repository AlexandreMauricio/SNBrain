---
type: concept
tags: [concept, platform, schema, task]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration" (pp. 472, 512-514), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Dictionary overrides

**In one line:** a dictionary override lets a field behave differently on a child table than on the parent that defines it, without touching the parent or the other children.

## How it works

Example from the guide: **Priority** on Task (`task`) defaults to 4; an override makes it default to 5 on Incident (`incident`) only.

What can be overridden:

| Override check box | Effect on the child table |
|---|---|
| **Override reference qualifier** | different filter on a reference field |
| **Override dependent** | different field to depend on |
| **Override attributes** | replaces the [[Dictionary Attributes Reference|attributes]]. **The parent's attributes are ignored**, so repeat any that should still apply |
| **Override default value** | different default |
| **Override calculation** | different calculation |
| **Override mandatory** | mandatory or not |
| **Override read only** | read-only or not |
| **Override display value** | use this field as the display value of the child table. Example: Story (`rm_story`) shows the short description instead of the number. Only fields that exist on the task table can be used this way |

- Only for tables that support extension.
- **Overrides are inherited.** An override on `cmdb_ci_hardware` also applies to `cmdb_ci_computer`; add another override there to get a different value.
- In a scoped application, create the override while working in that scope, and only child tables in that scope can be selected.

## How to create one

1. **All > System Definition > Dictionary**, open the field's record on the **parent** table.
2. In the **Dictionary Overrides** related list, select **New**.
3. Set **Table** to the child table, tick the override check boxes needed and fill the fields that appear.
4. **Submit**. Role: admin.

## Related

- [[Dictionary Entry Form]] · [[Table Extension and Extension Models]] · [[task]]
