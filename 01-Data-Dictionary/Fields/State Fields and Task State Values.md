---
type: reference
tags: [reference, choice-list, task, incident, problem, change, business-rule]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Field administration", topics "Integer values for default choice lists", "Configure state field choice values", "State modification examples", "Troubleshoot change states and business rules" (pp. 891-893), read 2026-10-01. Values are the base-system defaults named in the guide; they can differ per instance
sn-release: Australia
verified:
updated: 2026-10-01
---

# State fields and task state values

State fields are choice fields that store **integers**. Business rules test those integers, so the numbers matter more than the labels.

## Values the guide gives

| Table | Field | Value = label |
|---|---|---|
| Task (`task`) | State (`state`) | 1 = Open, 2 = Work in Progress (default work state), 3 = Closed Complete (default close state), 4 = Closed Incomplete |
| Incident (`incident`) | Incident state (`incident_state`) | 2 = Active, 6 = Resolved, 7 = Closed |
| Problem (`problem`) | State | 1 = Open, 2 = Known Error, 3 = Pending Change, 4 = Closed/Resolved |
| Change Request (`change_request`) | `phase_state` | 8 = Complete |

Other values exist but are not listed in the guide (`?`). Check with **System Definition > Choice Lists**, filter Table and Element.

## The rule for adding states

- **Incident**: any `incident_state` of **7 or higher is treated as inactive**. New inactive state: a value above 7. New **active** state (e.g. Awaiting Vendor): a **negative** value such as -1 or -2.
- **Change `phase_state`**: 8 or higher is inactive. Same approach.
- General guidance: negative values for new active states; values above 8 for new inactive states.

## Business rules that tie state and Active together

| Business rule | Table | Does |
|---|---|---|
| `mark_closed` | incident | `incident_state` changes to 7: **Active** = false |
| `incident reopen` | incident | `incident_state` below 7 and Active is false: Active = true |
| `mark closed` | task | `state` changes to 3 or 4: Active = false |
| `task closer` | task | Active changes true to false and state is not 3 or 4: state = 3 |
| `task reopener` | task | Active changes false to true and state is 3 or 4: state = 1 |

On Incident, **`incident_state` drives Active and State, not the other way round.**

## Dictionary attributes on a state field (used by `TaskStateUtil`)

| Attribute | Meaning | Default |
|---|---|---|
| `close_states` | inactive state values, separated by `;`. Required to use `TaskStateUtil` | |
| `default_close_state` | state used by rules that auto-close | 3 |
| `default_work_state` | state used by rules that start work | 2 |

## Finding the rules that depend on a value

**System Definition > Business Rules**, filter: Table is incident, Active is true, and Script contains 7 or Condition contains 7 (or 6). Then use **Debug Business Rule** and watch the trace (`==> 'mark_closed' on incident` ... `<==`) while resolving a test incident.

## Related

- [[task]] · [[Choice Lists]] · [[Dictionary Attributes Reference]]
