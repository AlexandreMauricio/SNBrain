---
type: how-to
tags: [how-to, data-integrity, fields, automation]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Field administration", topic "Create custom data lookups" (pp. 852-856), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Create a custom data lookup

**Goal:** set fields on a record automatically from a lookup table you maintain as data.
**Prerequisites:** role admin. Plugin Data Lookup and Record Matching Support.
**Navigation:** System Definition > Tables, then System Policy > Rules > Data Lookup Definitions

## Steps

1. **Create the lookup table**: a custom table that **extends Data Lookup Matcher Rules (`dl_matcher`)**, with a module if you want one.
2. **Add columns** to it for the matcher and setter values (configure its list and create the fields).
3. **Add rows**: one per combination, each unique.
4. **Create the definition**: **System Policy > Rules > Data Lookup Definitions > New > Data Lookup Rule**. Set **Name**, **Source Table**, **Matcher Table**, **Active**, and the triggers **Run on form change**, **Run on insert**, **Run on update**. Save.
5. In **Matcher Field Definitions**, add one row per matcher: **Source table field**, **Matcher table field**, **Exact lookup match**.
6. In **Setter Field Definitions**, add one row per field to set: **Source table field**, **Matcher table field**, **Always replace**.
7. **Update**.

## Result / how to check it worked

On the source table's form, set the matcher fields to a combination that exists in the lookup table: the setter fields fill in (at once with *Run on form change*, otherwise on save).

## Example

Table *Example VIP Caller Lookup* (`u_example_vip_caller_lookup`, extends `dl_matcher`) with columns Caller (reference to User), Priority (integer), Assignment Group (reference to Group). Rows: *Test User A*, 2, *Example VIP Team*; *Test User B*, 1, *Example VIP Team*. Definition on Incident: matcher Caller to Caller; setters Priority and Assignment group, **Always replace** ticked.

## Tables / fields involved

- `dl_matcher`: parent of every lookup table
- the source table's matcher and setter fields

## Other ways to do this

For assignment only: [[Approaches to Auto-Assigning Tasks]].

## Gotchas

- The definition must be on the exact source table; it is not inherited by child tables.
- Empty matcher cells are wildcards unless **Exact lookup match** is ticked.
- Not for Journal fields.
- If it does not fire: [[Data Lookup Rule Not Working]].
