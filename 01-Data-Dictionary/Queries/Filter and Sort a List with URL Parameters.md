---
type: query
tags: [query, encoded-query, forms-lists]
status: documented
source: ServiceNow Australia Platform Administration PDF, "List administration" (pp. 1006-1007, 1014-1015) and "Exporting data" (pp. 656-661), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Filter and sort a list with URL parameters

**Purpose:** open (or export) a list of any table already filtered and sorted, from a URL or from a module's **Arguments** field.
**Kind:** encoded query in URL parameters
**Where to run:** browser address bar, a module of link type *List of Records* (Arguments), or an export URL
**Read-only:** yes
**Scope:** any

```text
https://<instance>.service-now.com/incident_list.do?sysparm_query=active=true^ORDERBYcategory^ORDERBYDESCsys_created_on&sysparm_view=ess
```

## Parameters

| Parameter | Effect |
|---|---|
| `sysparm_query=<encoded query>` | the filter. `^` is AND, `^OR` is OR |
| `ORDERBY<field>` / `ORDERBYDESC<field>` inside the query | sort by one or several fields, in sequence |
| `sysparm_order=<field>` and `sysparm_order_direction=asc` or `desc` | sort by one field; in a module it overrides the user's remembered sort |
| `sysparm_orderby=<field>` | sort for URL exports (one field) |
| `sysparm_fixed_query=<encoded query>` | a filter the user **cannot remove** through breadcrumbs or the filter. Example: `&sysparm_fixed_query=active=true` on the module *Incident > Open* |
| `sysparm_view=<view>` | which list or form view |
| `sysparm_fields=<f1>,<f2>` | columns, for exports |
| `sysparm_record_count=<n>` | number of rows, for exports |

## Notes

- To sort a module by several fields, remove the condition from the module's **Filter** and put everything in **Arguments**: `active=true^ORDERBYcategory^ORDERBYsubcategory`.
- With a fixed query, delete the equivalent condition from the module filter first, then add the argument.
- In a URL, `>` is `%3E` and `=` inside a value is `%3D`.
- Queries on rotated tables should include a created-date range ([[Database Rotation - Table Rotation and Table Extension]]).

## Tables touched

- any table, addressed as `<table>_list.do`

## Related

- [[Export Data with a URL]] · [[List Configuration and List Controls]]
