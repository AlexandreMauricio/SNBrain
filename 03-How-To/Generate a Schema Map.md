---
type: how-to
tags: [how-to, platform, schema]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration", topic "Viewing table references and extensions" (pp. 517-519), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Generate a schema map

**Goal:** see, in one diagram, which tables a table extends, is extended by, references and is referenced by.
**Prerequisites:** role admin.
**Navigation:** All > System Definition > Tables & Columns

## Steps

1. Open **All > System Definition > Tables & Columns**.
2. Select a table in the **Table Names** pane.
3. Select **Schema map**. It opens in a new tab. (From a table record, the related link **Show Schema Map** does the same.)

## Result / how to check it worked

The chosen table is yellow in the centre, related tables around it, each with a coloured bar:

| Relationship | Colour |
|---|---|
| Referenced by | red |
| Referencing | orange |
| Extended by | green |
| Extending | blue |

- Check boxes at the top show or hide each relationship type.
- Hover a connector line for the details of the relationship.
- Expand **Columns** (+) on a node to list fields; reference fields show the target table in red. Inherited columns are listed in reverse derivation order.
- Right-click a node header: **Focus on this table** (redraws around it, with a breadcrumb back), **Go to list**, **Go to dictionary**.
- The table selector in the corner lists the tables, scrolls to one, and hides or shows nodes (eye icon).
- Print from the browser.

## Example

Open the schema map for Server (`cmdb_ci_server`): it shows the chain Computer, Hardware, Configuration Item in blue (extending) and lists their columns under the Server node.

## Tables / fields involved

- [[sys_db_object]], [[sys_dictionary]]

## Gotchas

- Relationships are drawn as single lines, so this is not an entity relationship diagram.
