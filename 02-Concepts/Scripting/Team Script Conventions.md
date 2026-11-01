---
type: concept
tags: [concept, scripting, javascript]
status: unverified
source: Team notes shared by the user's manager, file Best Practices.md, read 2026-11-01. Team conventions, not official docs.
sn-release:
verified:
verified-by:
updated: 2026-11-01
---

# Team Script Conventions

**In one line:** naming, value handling and logging habits from the team's notes, for server-side scripts.

Unverified team conventions. They are preferences as much as facts, so check them against the rules of the project you are working on. Official habits are in [[Application Development Good Practices - Plan, Build, Validate, Deploy]].

## Conventions

- **Names:** no acronyms; descriptive lowerCamelCase. `dateTimeUtils`, not `dtu`.
- **Magic values:** give literal strings and numbers a named variable, or better a constant, so `'4'` becomes `cancelState`.
- **Reading a field:** always `getValue()`. On a dot-walk, prefer `toString()`, which the notes say throws if the field is null. Concatenating to get a value is called inefficient.
- **Try and catch:** no empty `catch` without a justification. The notes follow this with a bare *Script actions*; its meaning is unconfirmed.
- **Logging:** use GSLog and add more detail to messages. See [[GlideRecord Queries, GlideRecordSecure and Server Utilities]].

**Unconfirmed variant:** the team example assigns directly (`grOrder.state = cancelState;`), while [[GlideRecord API Reference]] says to use `setValue()` rather than direct assignment before `update()`.

## Example

```javascript
// Server side, for example a business rule, global scope
var cancelState = '4';
var order = new GlideRecord('x_example_order');
if (order.get('<order_sys_id>')) {
    order.setValue('state', cancelState);
    order.update();
}
```

`x_example_order` is an invented table, and this example follows `setValue()`.

## Related

- [[GlideRecord API Reference]] · [[Debugging Scripts]] · [[Scripting Overview - Script Types and Where They Run]]
