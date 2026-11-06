---
type: reference
tags: [reference, forms-lists, encoded-query, release-specific]
status: documented
source: ServiceNow Brazil docs, ServiceNow AI Platform user interface > Working in Core UI > Lists in the classic environment > Filters and breadcrumbs (quick filters, create a filter, related list conditions, OR conditions, multiple string values, dynamic operators, saved filters, filter admin functions, scripted filters, dynamic filter options, encoded query strings), Search a list, and Common UI elements > Condition builder (empty fields, date/time values, comparing field values) and Operators available for filters and queries (10 tables), read 2026-11-06 through the docs site API (map 7xQNQY92V5DYmBMD7wXg9g, chapter X1oo9mYeLZGrF1oDFABlYg).
sn-release: Brazil
verified:
verified-by:
observed-in:
updated: 2026-11-06
---

# Filters, Condition Builder and Query Operators

**In one line:** a filter is a list of conditions (field, operator, value) joined by AND and OR, built in the **condition builder**, shown as **breadcrumbs**, and stored as an **encoded query** string that also works in URLs, reference qualifiers and `GlideRecord.addEncodedQuery()`.

From the Brazil docs; not tested. URL parameters around the query: [[Filter and Sort a List with URL Parameters]]. Qualifiers: [[Reference Qualifiers]]. Script side: [[GlideRecord API Reference]].

## Building a filter

- **Dependent** AND/OR (button beside a condition): `A and (B or C)`. **Top-level** OR (toolbar): `(A and B) or (C and D)`, encoded as `^NQ`. With any OR, the column quick-search magnifier is no longer offered.
- **Empty values are excluded** by most operators: `[Assignment group] [is] [Hardware]` misses empty groups; add `OR [Assignment group] [is empty]`. The quick filter **Filter Out** builds `[field] [is not] [value] OR [field] [is] [empty]` itself; a hand-built *is not* does not.
- **Quick filters** (right-click a cell): Show Matching, Filter Out; for dates Show Before / Show After.
- **Breadcrumbs:** left = most general. Clicking a crumb removes everything to its right; clicking the `>` before one removes only it. Right-click: Open new window, Copy URL, **Copy query** (the way to get an encoded query). Users with no role see no breadcrumbs or filter by default. Truncation: `glide.ui.breadcrumb_max_entries` (10), `glide.ui.export.choice_list_max_characters` (80).
- **New from a filtered list** pre-fills the filtered fields; stop it per field with dictionary attribute `ignore_filter_on_new=true` ([[Dictionary Attributes Reference]]).
- **is one of** with comma-separated or line-separated values (paste from a spreadsheet); not for values that contain commas.
- **Related list conditions** (List v3 and reports only): one related table, a quantifier (>=, >, <=, <, =, None, Between; default >= 1) and optional conditions on it; no keyword search there. Needs *Allow related list query conditions to be added through the filter* in the List v3 properties. A List v2 list with such a condition cannot have its filter edited until it is removed.
- **Pin filter** (List v2 only) keeps the builder open.
- **Sort:** choice fields sort by **value**, other fields by label; no sorting on array fields (glide_list); in translated instances only translated_text, translated_field and translated_html columns sort.

## Saved filters (`sys_filter`)

Save as **Me** (needs write on the User field), **Everyone** (`filter_global`), **Group** (`filter_group`). Brazil adds a Create ACL that lets all users save filters and overrides custom restrictions. Admins: **System Definition > Filters**; a filter with no user or group is global.

## Dynamic filter options (`sys_filter_option_dynamic`, inference for the table name)

Operator **is (dynamic)**. Defaults: on `sys_user` references **Me**, **One of My Assignments** (includes users the current user is a delegate for), **One of My Approvals**, **Users With Roles**; on `sys_user_group` references **One of My Groups**.

**System Definition > Dynamic Filter Options**: Label, **Script** (function name, JavaScript, or a full call such as `new MyUtil().myQualifier()`), Field type Reference, Referenced table, Order, Roles, Active, Reference script (client-callable script include or business rule), **Available for filter**, **Available for default**, **Available for ref qual**. Supported in scoped apps; **not in UI policy conditions**. A script using Table API GET only works for the user of its basic auth profile; use GlideRecord or GlideQuery.

**Scripted filter:** a client-callable, active script include whose function (same name as the include) returns an array of sys_ids, called as `[Caller] [is] [javascript:myFunction()]`. Grouping a list on such a filter can be slow.

```javascript
// Script include (server, global, Client callable), named exampleIntensiveCareCallers
function exampleIntensiveCareCallers() {
    var ids = [];
    var gr = new GlideRecord('u_example_care');   // invented table
    gr.query();
    while (gr.next()) {
        ids.push(gr.getValue('u_customer'));
    }
    return ids;
}
```

## Encoded query syntax

| Need | Syntax |
|---|---|
| AND / OR / new query | `a=1^b=2` · `a=1^ORa=2` · `a=1^NQb=2` |
| Choice field | the **value**, not the label: `install_status=1` |
| Dot-walk | `assigned_to.roles=itil` |
| Contains / in | `rolesLIKEit` · `rolesINitil,admin` |
| Sort | `^ORDERBYfield`, `^ORDERBYDESCfield` (not in reference qualifiers; use `ref_ac_order_by`) |
| JavaScript part | `javascript:'active=true^' + getGroupQualifier()` |
| Related list | `^RLQUERYincident.problem_id,>=1,priority=1^ENDRLQUERY` |
| Search term / text index group | `123TEXTQUERY321=email` · `123TEXTINDEXGROUP321=portal_index_group` (`ts_index_group`) |
| Contains typed in the list search | becomes `GOTOnumberLIKE123` |

## Operators by field type

| Field type | Query operators |
|---|---|
| String | `STARTSWITH`, `ENDSWITH`, `LIKE`, `NOT LIKE`, `=`, `!=`, `ISEMPTY`, `ISNOTEMPTY`, `ANYTHING`, `EMPTYSTRING`, `<=`, `>=`, `BETWEEN` (`a@b`), `SAMEAS`, `NSAMEAS` |
| Reference | as string, plus `DYNAMIC<option sys_id>`, `IN_HIERARCHY<hierarchy sys_id>@<record sys_id>`, `IN_HIERARCHY_DYNAMIC` (needs a record hierarchy, [[Record Hierarchies and Hierarchical Queries]]) |
| Choice (string) | `=`, `!=`, `IN`, `NOT IN`, `LIKE`, `STARTSWITH`, `ENDSWITH`, `NOT LIKE`, `ANYTHING`, `SAMEAS`, `NSAMEAS` |
| Choice (integer), numeric | `=`, `!=`, `IN`/`NOT IN` (choice), `EMPTY`, `NOTEMPTY`, `<`, `>`, `<=`, `>=`, `BETWEEN`, `ANYTHING`, `SAMEAS`, `NSAMEAS`; numeric adds `GT_FIELD`, `LT_FIELD`, `GT_OR_EQUALS_FIELD`, `LT_OR_EQUALS_FIELD` |
| Date-time | `ON` (`ONToday@javascript:gs.daysAgoStart(0)@javascript:gs.daysAgoEnd(0)`), `<`, `<=`, `>`, `>=`, `BETWEEN`, `DATEPART` (trend, `gs.datePart('dayofweek','monday','GE')`), `RELATIVEGT@hour@ago@1`, `RELATIVELT`, `ISEMPTY`, `ISNOTEMPTY`, `ANYTHING`, `SAMEAS<field>@day`, `NSAMEAS`, `MORETHAN<field>@day@before@1`, `LESSTHAN` |
| Boolean | `=`, `!=`, `ISEMPTY`, `ISNOTEMPTY`, `ANYTHING`, `SAMEAS`, `NSAMEAS` |
| Email notification conditions | `VALCHANGES`, `CHANGESFROM`, `CHANGESTO` |
| Tags | `=`, `DOESNOTHAVE`, `EXCLUDING` |

The empty operators are spelled `ISEMPTY`/`ISNOTEMPTY` for strings, references, dates and booleans but `EMPTY`/`NOTEMPTY` for integer choices and numbers (as printed).

## Dates and field comparison

- Relative values: Today (midnight to midnight), Yesterday, Tomorrow, This week/month/quarter/year, Last n minutes to years (from the **start** of that period: *Last 3 months* on 15 April = from 1 January; *Last 12 months* runs January to January), Next n, One year ago, Current hour/minute. *Last week* = Sunday to Sunday, not up to today. *at or after* / *at or before* use midnight boundaries.
- **Week start disagrees:** one page says *This week* starts the previous **Monday**; the values table's example (15 to 21 April 2018) is **Sunday to Saturday**, and field comparison defines a week as Sunday to Saturday. *Tomorrow* is described as "midnight to the current time" but the example shows the whole next day (docs slip). Both kept.
- **Field comparison:** *is same* / *is different* need the same field type on the right; *is more than* / *is less than* only on dates, with a unit (Hours to Years), before/after/before or after, and a number of at most two digits. Date comparisons use the viewer's time zone. *is same Day* compares the day of the month, not the date. Not for journal, keyword, script, duration, list or HTML fields.

## List search box

*Go to* a field searches **greater than or equal** by default (number fields: values **ending with** the digits; any field named `number` or `u_number` counts as numeric); choice labels match exactly, values search >=. Wildcards: `*x` or `%x%` contains, `%x` ends with, `x%` starts with, `=x` equals, `!*x` not contains, `!=x` not equal. Change the default: create `glide.ui.goto_use_contains` or `glide.ui.goto_use_starts_with` = true (slower), or per field dictionary attribute `goto_use_starts_with=true`.

## Example

Saved filter *Example My Open P1s* on `incident`: `active=true^priority=1^assigned_toDYNAMIC<Me option sys_id>^NQactive=true^assignment_groupDYNAMIC<One of My Groups sys_id>^assigned_toISEMPTY`, visible to group *Example Service Desk*.

## Related

- [[Filter and Sort a List with URL Parameters]] · [[Reference Qualifiers]] · [[List Configuration and List Controls]] · [[Dictionary Attributes Reference]] · [[Date and Time Fields, Formats and Time Zones]] · [[Core UI Lists, Forms and Related Lists]]
