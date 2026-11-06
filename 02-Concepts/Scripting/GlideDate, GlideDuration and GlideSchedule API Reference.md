---
type: reference
tags: [reference, scripting, glide-api, sla]
status: documented
source: ServiceNow Brazil docs, API implementation and reference > Server API reference, pages GlideDate - Global, GlideDuration - Scoped, GlideSchedule - Scoped, read 2026-11-06 through the docs site API (map ooCZhg2g6YDYvKp3oBwAxA). Scoped GlideDate, global GlideSchedule and GlideDuration pages, GlideTime not read.
sn-release: Brazil
verified:
verified-by:
updated: 2026-11-06
---

# GlideDate, GlideDuration and GlideSchedule API Reference

**In one line:** the date-only, duration and business-hours classes that work alongside GlideDateTime on the server.

From the Brazil docs, not tested. GlideDateTime itself: [[GlideDateTime API Reference]]. Practical patterns: [[GlideDateTime Formatting Recipes]] (unverified).

## GlideDate (global)

| Method | Time zone per the docs |
|---|---|
| `GlideDate()` | current date time |
| `getByFormat(format)` | **not stated**; Java SimpleDateFormat pattern, `EEEE` for the weekday name |
| `getDisplayValue()` | UTC (the docs say so, although the name suggests the user's zone) |
| `getDisplayValueInternal()` | user's, `yyyy-MM-dd` |
| `getDisplayValueEx(style)`, `getDisplayValueLang(style[, language])` | user's zone and locale |
| `setDisplayValue(asDisplayed)` | user's format and zone |
| `setDisplayValueEx`, `setDisplayValueLang` | a given style and language |
| `setValue(o)` | internal `yyyy-MM-dd` in the **system** time zone, UTC by default |
| `getDayOfMonthNoTZ()`, `getMonthNoTZ()`, `getYearNoTZ()` | UTC |
| `parseDate(date, language, country)` | locale of that language and country |

In scoped applications use the scoped GlideDate methods, which this note has not read.

## GlideDuration (scoped)

- Constructors: empty, a copy of another duration, milliseconds, or a display value.
- `getDurationValue()` returns `d HH:mm:ss`, so `2 07:00:00` is 2 days and 7 hours.
- `getDayPart()`, `getRoundedDayPart()` (rounds up when the time part is over 12 hours), `getByFormat(format)`, `getValue()`, `setValue()`, `setDisplayValue()`.
- `add(duration)`, `subtract(duration)`.

## GlideSchedule (scoped)

- `new GlideSchedule(sysID, timeZone)` loads a schedule. Without a time zone it uses the **session's**.
- `duration(start, end)`: elapsed **schedule** time between two GlideDateTimes, in the schedule's time zone, or the session's if the schedule has none. Returns a GlideDuration.
- `isInSchedule(time)`, `whenNext(time, timeZone)` (milliseconds until the next schedule start), `isValid()` (has at least one entry), `load()`, `setTimeZone()`, `add(start, offset)`, `getName()`.

Schedules themselves: [[Schedules and Schedule Entries]].

## Example

```javascript
// Server side, scoped or global; business hours between two dates
var schedule = new GlideSchedule('<schedule_sys_id>');
var start = new GlideDateTime('2026-11-02 08:00:00');
var end = new GlideDateTime('2026-11-04 17:00:00');
gs.info(schedule.duration(start, end).getDurationValue());
gs.info(schedule.isInSchedule(new GlideDateTime()));
```

## Related

- [[GlideDateTime API Reference]] · [[Date and Time Fields, Formats and Time Zones]] · [[GlideDateTime Formatting Recipes]]
