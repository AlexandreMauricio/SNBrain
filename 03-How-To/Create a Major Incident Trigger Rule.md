---
type: how-to
tags: [how-to, incident, automation]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Incident Management", topic "Create trigger rules for major incidents" (pp. 2506-2508), read 2026-10-02
sn-release: Australia
verified:
updated: 2026-10-02
---

# Create a major incident trigger rule

**Goal:** have incidents that meet a condition proposed (or promoted) as major incidents automatically.
**Prerequisites:** role `incident_manager` or admin. Plugin Major Incident Management active.
**Navigation:** All > Major Incidents > Administration > Major Incident Trigger Rules

## Steps

1. Select **New**.
2. **Name**, **Table** (Incident), **Execution Order**, **Conditions**.
3. **Action to take**: *Propose Major Incident* (a manager decides) or *Promote Major Incident* (immediate).
4. Tick **Active**. Submit.

## Result / how to check it worked

Create or update an incident matching the conditions: shortly after (the rules run asynchronously) **Major incident state** becomes Proposed or Accepted and it appears under **Major Incidents > Candidates** or **Open**.

## Example

| Order | Condition | Action |
|---|---|---|
| 100 | Service . Business criticality is 1 - most critical | Propose |
| 300 | Priority is 1 - Critical | Propose |

## Tables / fields involved

- `major_incident_trigger_rule`; [[incident]]: **Major incident state**

## Gotchas

- Shipped rules are inactive.
- Not evaluated for child incidents (**Parent Incident** filled), inactive incidents, or ones already proposed or accepted.
- The first rule that matches wins; later ones are not evaluated.
- With the creation property set to *Create new*, *Promote* creates a **new** major incident and makes the triggering incident its child.
- Background: [[Major Incident Management]].
