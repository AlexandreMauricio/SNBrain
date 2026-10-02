---
type: concept
tags: [concept, data-integrity, fields, incident, automation]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Field administration", topic "Data lookup and record matching support" (pp. 851-856), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Data lookup and record matching

**In one line:** a data lookup sets one or more fields on a record from a row of a lookup table whose **matcher** fields equal the record's values; the classic case is Priority from Impact and Urgency.

## How it works

- A **lookup (matcher) table** holds rows of matcher values and setter values. It must extend Data Lookup Matcher Rules (`dl_matcher`). Each row must be unique.
- A **data lookup definition** (**System Policy > Rules > Data Lookup Definitions**) ties a **source table** to a matcher table, with:
  - **Matcher Field Definitions**: source field paired with matcher table field. **Exact lookup match** ticked means empty only matches empty; cleared means an **empty matcher value is a wildcard**.
  - **Setter Field Definitions**: matcher table field copied into a source field. **Always replace** overwrites an existing value; cleared, a filled field is left alone.
  - **Run on form change**, **Run on insert**, **Run on update**.

Shipped example, Priority Data Lookup (`dl_u_priority`):

| Impact | Urgency | Priority |
|---|---|---|
| 1 - High | 1 - High | 1 - Critical |
| 1 - High | 2 - Medium | 2 - High |
| 1 - High | 3 - Low | 3 - Moderate |
| 2 - Medium | 1 - High | 2 - High |
| 2 - Medium | 2 - Medium | 3 - Moderate |
| 2 - Medium | 3 - Low | 4 - Low |
| 3 - Low | 1 - High | 3 - Moderate |
| 3 - Low | 2 - Medium | 4 - Low |
| 3 - Low | 3 - Low | 5 - Planning |

## Rules and limits

- **Definitions are not inherited by child tables.** A definition on Task does not act on Incident.
- Does not work with Journal fields.
- **Run on form change** reacts to a user or an onChange client script changing a field, not to changes made by other data lookup rules.
- Plugin Data Lookup and Record Matching Support (`com.glide.data_lookup`). **Activating it manually replaces the `calculatePriority` business rule with the priority lookup and removes related scripts without carrying over custom logic**; recreate any customisation afterwards.
- Runs as an engine between the low-order and high-order before business rules ([[Order of Execution for Rules, Engines and Notifications]]).

## Related

- [[Create a Custom Data Lookup]] · [[Data Lookup Rule Not Working]] · [[Assignment Rules and Data Lookup Rules]]
