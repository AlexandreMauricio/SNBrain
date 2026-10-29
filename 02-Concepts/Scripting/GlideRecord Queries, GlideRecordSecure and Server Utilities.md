---
type: concept
tags: [concept, scripting, glide-api, encoded-query, security]
status: documented
source: ServiceNow docs, Brazil, API implementation and reference > Scripting, topics "Querying tables in script", "Setting a GlideRecord variable to 'NULL'", "Calculating a due date with DurationCalculator", "Parsing and extracting XML data in server-side scripts", and Example scripts > "Server-side script use cases" (GlideRecordSecure, GlideAggregate, user object, GSLog, GlideDateTime, durations, custom event queues), "Scheduling script use cases", "Validation script use cases", https://www.servicenow.com/docs/r/api-reference/scripts/c_UsingGlideRecordToQueryTables.html, read 2026-10-16
sn-release: Brazil
verified:
updated: 2026-10-16
---

# GlideRecord queries, GlideRecordSecure and server utilities

**In one line:** server scripts read and write tables through **GlideRecord** (no SQL); **GlideRecordSecure** does the same while enforcing ACLs; a handful of script includes cover durations, XML and logging.

All snippets are server-side (business rule, script include, Scripts - Background...). Global scope unless noted.

## Querying

```javascript
var gr = new GlideRecord('incident');
gr.addQuery('priority', '>', 1);          // equality needs no operator: addQuery('priority', 1)
gr.addQuery('short_description', 'CONTAINS', 'Error');
gr.query();
while (gr.next()) {
    gs.info(gr.getValue('number'));
}
```

| Operator | Meaning |
|---|---|
| `=`, `!=`, `>`, `>=`, `<`, `<=` | comparisons |
| `STARTSWITH`, `ENDSWITH`, `CONTAINS`, `DOES NOT CONTAIN` | text; `LIKE` is not supported; DOES NOT CONTAIN skips empty values |
| `IN`, `NOT IN` | comma-separated list |
| `INSTANCEOF` | `addQuery('sys_class_name', 'INSTANCEOF', 'cmdb_ci_computer')`: a class and its children |

- `addNullQuery('field')`, `addNotNullQuery('field')`; OR with `addOrCondition()` on the returned condition (see [[Business Rules]]).
- Full-text: `addQuery('123TEXTQUERY321', 'email')` (or encoded `123TEXTQUERY321=email`) searches all indexed fields, case-insensitive; needs a text index on the table. Add `addQuery('123TEXTINDEXGROUP321', '<group>')` to score results with an index group's settings (V4 indexes; one table per query, merge the results yourself). See [[Zing Text Search and Global Search]].
- Insert: `initialize()`, set fields, `insert()`. Update: change fields, `update()`. Delete: `deleteRecord()`. (The docs' update example has a typo `rec.number = ' closed'`.)
- Catalog variables cannot be queried on `sc_req_item` directly: query `sc_item_option_mtom` with `sc_item_option.item_option_new.name` and `sc_item_option.value`, then dot-walk to `request_item`. See [[Find Requested Items by Catalog Variable Value]].
- Aggregates (COUNT, SUM, MIN, MAX, AVG): **GlideAggregate**, an extension of GlideRecord.

## Clearing a field

Setting `''`, `' '` or `null` does not return a field to its initial database null; set the string `'NULL'` then `update()`. Admin only per the page. (Same reserved word as in [[Business Rules]].)

## GlideRecordSecure

- Same API as GlideRecord plus ACL enforcement on read and write: no need for `canRead()` / `canWrite()` checks in the loop; fields the user cannot write are saved as NULL.
- **Query ACLs are not enforced by default.** Opt in: `addUserEncodedQuery(userInput)` for conditions built from user input, `addSystemEncodedQuery('active=true')` for trusted fixed conditions, or `addEncodedQuery(query, true / false)`.
- In scoped code the object reports `[object ScopedGlideRecordSecure]` via `toString()`; the type differs when a scoped function returning a GlideRecord is called from global.
- The platform's security recommendations for Glide AJAX script includes and UI pages ask for GlideRecordSecure.

## Durations: DurationCalculator (global script include)

```javascript
// Scripts - Background, read only. "8-5 weekdays excluding holidays" is a base schedule
var dc = new DurationCalculator();
var sched = new GlideRecord('cmn_schedule');
if (sched.get('name', '8-5 weekdays excluding holidays'))
    dc.setSchedule(sched.getUniqueValue(), 'GMT');
dc.setStartDateTime(new GlideDateTime('2026-05-04 15:00:00'));
if (dc.calcDuration(4 * 3600))               // 4 working hours
    gs.info(dc.getEndDateTime());              // next working day 10:00 with an 8-5 schedule
gs.info(dc.calcScheduleDuration('2026-05-04 12:00:00', '2026-05-05 12:00:00')); // working seconds between two times
```

- Without a schedule time is added continuously. `setTimeZone()` shifts how the schedule is read.
- **Relative durations** (`cmn_relative_duration`, **System Scheduler > Schedules > Relative Durations**) are scripts that receive the calculator as `calculator`; call `calcRelativeDuration(<sys_id>)` (e.g. "2 business days by 4pm if before 10am"). SLA percentage timers can use them. See [[SLA Definitions and Task SLAs]] and [[Schedules and Schedule Entries]].

## XML

- `XMLDocument` (global) / `XMLDocument2` (scoped and global): `new XMLDocument(xml, true)` for namespace-aware parsing; `getNodeText('//xpath')`, `getNodeInt()`, `getNode()`, `getNodes()`, `getAttribute(xpath, name)`, `createElement()`, `setCurrent()`. Typical input: web service responses, ECC queue payloads. In business rules `gs.getXMLText(current.payload, '//name')` also works.
- `XMLHelper`: `toObject()` turns XML into a JavaScript object, `toXMLDoc()` the reverse; unescaped `&` makes the conversion fail silently.

## Logging and other helpers

- **GSLog** script include: log levels debug, info, notice (default), warning, err, crit, chosen per caller through a system property. Logpoints in the Script Debugger use the same format ([[Debugging Scripts]]).
- Current user: `gs.getUser()` (GlideUser: `getFirstName()`, `isMemberOf('<group>')`...); another user: `gs.getUser().getUserByID('<user_name or sys_id>')`.
- GlideDateTime: internal format `yyyy-MM-dd HH:mm:ss` in UTC; get the object of a field with `getGlideObject()` (the field itself gives a string); prefer the LocalTime / UTC methods over those using the JVM time zone. `new GlideDateTime(glideDate)` converts a GlideDate. See [[Date and Time Fields, Formats and Time Zones]].
- Duration fields: `GlideDateTime.subtract(start, end)` returns a duration (`.getNumericValue()` for milliseconds; inputs in the user's format and time zone); add time with `current.duration.dateNumericValue()` / `setDateNumericValue(ms)`; client side `g_form.setValue('<duration>', '11 01:02:03')` (days hours:minutes:seconds). Negative durations are not supported. Dictionary attribute `format=glide_duration` shows integer fields such as Resolve Time as durations.
- Custom event queue: give the event a **Queue** in the registry, copy the scheduled job **text index events process** with `GlideEventManager('<queue>')`, and send events with the fifth parameter of `gs.eventQueue(name, record, parm1, parm2, '<queue>')` (the registry queue applies even without it). See [[Events and the Event Queue]].
- Validation script for date/time fields (type `glide_date_time`): `return getDateFromFormat(value, 'yyyy-MM-dd HH:mm:ss') != 0;` (client side; must match the instance format).

## Related

- [[Script Includes and GlideAjax]] · [[Scripting with Catalog Variables]] · [[Script Sandbox and Guarded Script]] (methods blocked in the sandbox)
