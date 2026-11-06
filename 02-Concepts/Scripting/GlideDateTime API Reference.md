---
type: reference
tags: [reference, scripting, glide-api, javascript]
status: documented
source: ServiceNow Brazil docs, API reference > Server API reference > GlideDateTime - Global and GlideDateTime - Scoped (method lists and notes), read 2026-10-30. Parameter tables and examples not copied. https://www.servicenow.com/docs/r/api-reference/server-api-reference/
sn-release: Brazil
verified:
verified-by:
updated: 2026-11-06
---

# GlideDateTime API Reference

**In one line:** the server-side date and time object. Stored in UTC, internal format `yyyy-MM-dd HH:mm:ss`.

From the Brazil docs; not tested. `yyyy-MM-dd'T'HH:mm:ss.SSSZ` is **not** supported by the constructor.

**Time zones:** most methods come in three flavours: plain (JVM time zone), `LocalTime` (the user's), `UTC`. Prefer the last two. Plain variants are **not on the scoped page**.

| Purpose | Methods |
|---|---|
| Create | `new GlideDateTime()`, `(String)`, `(GlideDateTime)` |
| Add | `add` (ms or GlideTime), `addSeconds`; `addDays`, `addWeeks`, `addMonths`, `addYears` with LocalTime or UTC |
| Subtract | `subtract(time or ms)`, `GlideDateTime.subtract(start, end)` returns a duration |
| Compare | `compareTo`, `equals`; scoped pages also list `before`, `after`, `onOrBefore`, `onOrAfter` |
| Read value | `getValue`, `toString` (UTC internal), `getDisplayValue`, `getDisplayValueInternal`, `getDisplayValueLang`, `getNumericValue`, `getDate`, `getTime`, `getLocalDate`, `getLocalTime`, `getInternalFormattedLocalTime`, `getUserFormattedLocalTime` |
| Parts | `getDayOfMonth`, `getDayOfWeek`, `getDaysInMonth`, `getMonth`, `getYear`, each with LocalTime and UTC; `getWeekOfYearLocalTime`, `getWeekOfYearUTC` |
| Set | `setValue`, `setValueUTC`, `setDisplayValue`, `setDisplayValueInternal`, `setDisplayValueLang`, `setGlideDateTime`, `setNumericValue`, `setTZ`; parts with LocalTime and UTC |
| Time zone | `getTZOffset`, `getDSTOffset`, `isDST`, `getUserTimeZone` |
| Midnight | `getInternalMidnight`, `getUTCMidnight`, `getSpanTime` |
| Validate | `isValid`, `hasDate`, `getErrorMsg` |

## Example

```javascript
// Server side, scoped or global
var gdt = new GlideDateTime();
gdt.addDaysUTC(7);
gs.info(gdt.getValue() + ' / ' + gdt.getDisplayValue());
var dur = GlideDateTime.subtract(new GlideDateTime('2026-01-01 00:00:00'), gdt);
gs.info(dur.getDisplayValue());
```

## Related

- [[GlideDateTime Formatting Recipes]] (unverified team notes) · [[GlideDate, GlideDuration and GlideSchedule API Reference]]
- [[GlideSystem API Reference]] · [[GlideRecord Queries, GlideRecordSecure and Server Utilities]]
