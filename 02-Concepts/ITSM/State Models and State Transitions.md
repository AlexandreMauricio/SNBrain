---
type: concept
tags: [concept, task, choice-list, admin]
status: documented
source: ServiceNow Australia Platform Administration PDF, "State Management" (pp. 2741-2746), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# State models and state transitions

**In one line:** State Management lets an admin declare, for a task table, which state can follow which, with conditions; the **State** choice list then only offers the allowed moves, and invalid moves are rejected from any source.

## Pieces

| Piece | Table | Holds |
|---|---|---|
| State model | `sys_state_model` | **Name**, **Table** (must extend [[task]]), **Order**, **Active**, **Condition** (which records it applies to), **Common Exit Condition** (required for any move) |
| State transition | `sys_state_transition` | per state: **State**, **Order**, **Terminal State** (no way out), **Enter Condition**, **Exit Condition** |

- Several models can target one table, told apart by **Condition** (for example Category is Networking vs Security) and evaluated by **Order**.
- Enforcement is server-side: form input, scripts, REST and SOAP are all denied if they break a transition.
- Active on all instances. Role `state_model_admin`. Module **State Management > State Models**.

## Example

Custom table with states Held, Confirmed, Completed, Canceled. Transition for **Completed** has enter condition *State is Confirmed*: a record in Confirmed only offers Completed; one in Held cannot jump to Completed.

## Steps to build one

1. **State Management > State Models > New**: name, table, order; leave **Active** off. Save.
2. In the **State Transitions** related list, add one transition per state with enter/exit conditions (leave gaps in **Order**: 10, 20...).
3. Tick **Active**.
4. Optional: add a process flow formatter ([[Formatters]]) and [[UI Actions]] that move the state; the model alone only filters the choice list.

## Gotchas

- The shipped example models are copies of the normal, emergency and standard **change** models and are inactive. **Do not enable them on change requests**: that breaks the real change transitions.
- Build and test in a sub-production instance first.
- Check the State choices exist on the table before writing transitions ([[State Fields and Task State Values]]).

## Related

- [[Choice Lists]] · [[State Fields and Task State Values]]
