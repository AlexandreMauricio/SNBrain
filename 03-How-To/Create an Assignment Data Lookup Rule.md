---
type: how-to
tags: [how-to, incident, automation]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Table administration", topic "Create an assignment data lookup rule" (pp. 532-533), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Create an assignment data lookup rule

**Goal:** assign incidents from a lookup table of category, subcategory, configuration item and location.
**Prerequisites:** role `assignment_rule_admin` or admin.
**Navigation:** All > System Policy > Rules > Assignment Lookup Rules

## Steps

1. Open **All > System Policy > Rules > Assignment Lookup Rules** and select **New**.
2. Fill the matcher fields you need: **Category**, **Subcategory**, **Configuration item**, **Location**.
3. Fill the setter fields: **Assignment group** and/or **Assigned to**.
4. Set **Active** and **Order** (the lowest-order row with matching values is used).
5. Submit.

## Result / how to check it worked

An incident whose values match the row gets the group and assignee from it.

## Example

Row with **Category** = Inquiry / Help, **Subcategory** = Email, **Assignment group** = *Example Messaging Team*. An incident with that category and subcategory is assigned to that team.

## Tables / fields involved

- `incident`: the matcher and setter fields above

## Other ways to do this

[[Approaches to Auto-Assigning Tasks]]

## Gotchas

- A valid row needs at least one matcher field and one setter field.
- Whether a lookup replaces an existing assignment depends on the data lookup definition ([[Assignment Rules and Data Lookup Rules]]).
