---
type: how-to
tags: [how-to, reporting, schema]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration", topics "Joining tables using database views", "Example left join", "Specify a field to return", "Relabel a column", "Test the database view", "Using disjunctions in complex queries" (pp. 574-585), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Create a database view

**Goal:** join tables into one view to report on fields from all of them.
**Prerequisites:** role admin. The tables (and the plugins that create them) must exist.
**Navigation:** All > System Definition > Database Views

## Steps

1. **Create the view.** Select **New**, give a **Name** (as for a table: lowercase, underscores), **Label**, **Plural** and a description. Submit.
2. **Add the first table.** In the **View Tables** related list select **New**: choose the **Table**, a **Variable prefix** (mandatory, **lowercase only**), an **Order** (tables join left to right by ascending order) and leave **Where clause** blank.
3. **Add each further table** the same way, with a **Where clause** that joins it to an earlier table. Write fields as `prefix_fieldname`, e.g. `mi_id = inc_sys_id`.
4. **Left join** (optional): configure the View Table form to add the **Left join** check box. When ticked, rows of the left-hand tables are returned even if this table has no match.
5. **Restrict fields** (optional): on a view table, add rows in **View Fields**. With none, all fields are returned; with any, only those. **Always include the fields used in the where clause**, or the join fails.
6. **Relabel clashing columns** (optional): **System Definition > Language File**, **New**, **Table** = the view name, **Element** = `prefix_fieldname`, plus **Label** and **Plural**.
7. **Test** with the **Try It** related link.

## Where clause rules

- Operators: `=`, `!=`, `<`, `<=`, `>`, `>=`, `&&`, `||`. **No LIKE or CONTAINS.**
- Join on sys_id with `=` so lists, reports and queries work on the full data set.
- **AND is evaluated before OR.** Put parentheses around OR groups: `(priority = 1 || priority = 2) && state = 6`. Without them, `priority = 1 || priority = 2 && state = 6` returns every priority 1 record regardless of state.

## Result / how to check it worked

**Try It** shows a list of the joined rows. If the link is missing, a table the view needs does not exist (plugin not active). If the view shows wrongly after restricting fields, a where-clause field is missing from View Fields.

## Example

Catalog tasks with whichever parent they have (the guide's left-join example):

| Table | Prefix | Order | Where clause | Left join |
|---|---|---|---|---|
| Catalog Task (`sc_task`) | `cat` | 100 | (blank) | |
| Requested Item (`sc_req_item`) | `item` | 200 | `cat_parent=item_sys_id` | true |
| Request (`sc_request`) | `req` | 300 | `cat_parent=req_sys_id` | true |
| User (`sys_user`) | `user` | 400 | `cat_opened_by=user_sys_id` | false |

Every catalog task comes back even with no parent, with the item or request columns blank where they do not apply. Because User is not a left join, a task whose **Opened by** has no matching user is dropped. Making both parent joins non-left returns nothing, since no task has both kinds of parent.

## Tables / fields involved

- `sys_db_view`: the view, with View Tables and View Fields related lists
- [[sys_documentation]]: relabelled columns

## Gotchas

- Not possible on tables in table rotation.
- Uppercase in a variable prefix can stop the view showing in a list.
- A [[Function Fields|function field]] created directly on a view must use the prefixes: `glidefunction:length(inc2_description)`.

## Related

- [[Database Views]]
