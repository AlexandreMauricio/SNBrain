---
type: table
tags: [table, schema, service-catalog]
status: documented
source: ServiceNow docs, Brazil, Platform Capabilities > Service Catalog > Reference, topics "Create a service catalog variable", "Lookup select box" (Question [item_option_new] fields table), "Catalog Wizard form", https://www.servicenow.com/docs/r/servicenow-platform/service-catalog/lookup-select-box.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# item_option_new

**Label:** Variable (the docs also call the table Question)
**What it stores:** one row per catalog variable (question), on a catalog item, record producer, order guide or variable set.
**Extends:** ? (not stated)
**Extended by:** ? (not stated)
**Scope:** global

## Key columns

| Label | Name | Type | Reference / choice | Meaning | Confidence |
|---|---|---|---|---|---|
| Lookup source | `lookup_source` | choice | Table (default), Choices | where lookup select box / lookup multiple choice values come from; Choices = `sys_choice` | documented |
| Choices depend on | `lookup_dependent_question` | reference | `item_option_new` | filter choices by another question's value (only with Choices) | documented |
| Type, Question, Name, Order, Mandatory, Read only, Hidden, Active, Global, Catalog item, Variable set, Map to field, Field, Default value, Help text, Instructions, Tooltip, Example text, Variable width, Variable attributes, Reference, Reference qual, Lookup from table, Lookup value field, Lookup label field(s), Lookup price field, Read roles, Write roles, Create roles, Visible Elsewhere / on Bundles / on Guides / on Summaries, Unique, Hide on grid, Disable initial slot fill, Remove from Conversational Interfaces | ? | | | see [[Catalog Variables and Variable Types]] | labels documented, names unconfirmed |

## Relations

- Belongs to a [[sc_cat_item]] or a variable set.
- Choices: Question Choices related list (table `question_choice` from general knowledge, unconfirmed).
- Answers: `sc_item_option` + `sc_item_option_mtom` (catalog items), `question_answer` (record producers), `sc_multi_row_question_answer` (MRVS rows). Internal tables: no business rules.

## Useful queries

```text
cat_item=<item sys_id>^active=true^ORDERBYorder
```

The column `cat_item` is general knowledge, not from the docs; check it in the dictionary before relying on it.

## Gotchas

- Variables without a **Name** are not scriptable, not usable in UI policy conditions and not audited.
- Two variables with the same name on one item (directly or through sets) collide.

## Related

- [[Catalog Variables and Variable Types]] · [[Variable Sets and Multi-Row Variable Sets]] · [[Scripting with Catalog Variables]]
