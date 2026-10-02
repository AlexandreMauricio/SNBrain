---
type: how-to
tags: [how-to, automation, scripting, business-rule]
status: documented
source: ServiceNow Australia Platform Administration PDF, "System Events", topics "Create an event", "Register an event", "Reprocess an event" (pp. 2731-2736), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Create and register an event

**Goal:** have your own event that notifications and script actions can react to.
**Prerequisites:** role `events_admin` (and rights to edit business rules).
**Navigation:** All > System Policy > Events > Registry

## Steps

1. **Registry > New**: **Event name**, **Table**, optional **Queue** and **Priority**, **Fired by** (name of the business rule, for reference), **Description**. Submit.
2. Fire it from a business rule:
   - base table: add a condition to the table's existing events rule (for example *sc request events*);
   - custom table: new business rule, **Advanced**, **When** = after, on insert/update/delete as needed.
3. In the script, test the condition and call `gs.eventQueue('<event name>', current, <parm1>, <parm2>)`.
4. Create a notification or a script action that uses the event.

## Result / how to check it worked

Make the change on a record, then open **System Logs > Events**: the event appears and goes from Ready to Processed. **Reprocess Event** on that row fires it again without touching the record.

## Example

Event `x_example_app.attendee.added` on a custom attendee table:

```javascript
(function executeRule(current, previous /*null when async*/) {
    if (current.operation() == 'insert') {
        gs.eventQueue('x_example_app.attendee.added', current, current.getValue('event'), current.getValue('email'));
    }
})(current, previous);
```

## Tables / fields involved

- `sysevent_register`, [[sysevent]], `sys_script` (business rules)

## Gotchas

- Unregistered events cannot be picked in a notification or script action.
- Only tables in the same scope as the event appear in **Table**.
- In a delete rule, pass `current` before it is gone (the guide's example uses `previous` for the moved record).
- Background: [[Events and the Event Queue]].
