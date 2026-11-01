---
type: concept
tags: [concept, scripting, glide-api, javascript]
status: unverified
source: Team notes shared by the user's manager, file GlideDateTime.md, read 2026-11-01. They reproduce a ServiceNow Community post, The secrets of GlideDateTime, https://www.servicenow.com/community/in-other-news/the-secrets-of-glidedatetime/ba-p/2290801. Summarised here, the post itself not read. Not tested.
sn-release:
verified:
verified-by:
updated: 2026-11-01
---

# GlideDateTime Formatting Recipes

**In one line:** format and parse dates with Java SimpleDateFormat patterns through `setDisplayValue()` and `getByFormat()`, and avoid JavaScript `Date`, which ignores the user's time zone.

Unverified community material, not tested. Everything here is server side; the examples ran as background scripts in the post, and scope is not stated. Method lists are in [[GlideDateTime API Reference]], formats and zones in [[Date and Time Fields, Formats and Time Zones]].

## Parse and format

`setDisplayValue(value, format)` reads a string in any pattern, in the session time zone. `getByFormat(format)` on a `GlideDate` writes one out.

| Incoming text | Pattern |
|---|---|
| `20-5-2011 12:00:00` | `dd-MM-yyyy HH:mm:ss` |
| `20171216 01:23:45` | `yyyyMMdd HH:mm:ss` |
| `Friday, August 18, 2017 8:00 AM` | `E, MMMM dd, yyyy K:mm a` |
| `10 Jul 2018 12:30:00` | `dd MMMM yyyy HH:mm:ss` |

```javascript
var gdt = new GlideDateTime();
gdt.setDisplayValue('10 Jul 2018 12:30:00', 'dd MMMM yyyy HH:mm:ss');
gdt.addDays(7);

var gd = gdt.getLocalDate();
var gt = gdt.getLocalTime();
gs.info(gd.getByFormat('dd MMM yyyy') + gt.getByFormat(' HH:mm:ss'));
```

## Local parts

The post copies local time into a `GlideDate` to read it in the user's zone. `localTime` is used as a property here and does not appear in [[GlideDateTime API Reference]], so it is unconfirmed.

```javascript
var gdt = new GlideDateTime();
var gd = new GlideDate();
gd.setValue(gdt.localTime);
var hour = parseInt(gd.getByFormat('HH'));
```

`new GlideDateTime().getDate().getByFormat('EEEE dd MMMMM')` gives the day name, day and month.

## Avoid JavaScript Date

`new Date()` does not use the user's time zone, so `getDay()` can return the wrong day. In the post, it reported PST for a user in Perth, and a weekday check fired on the wrong days. Use the day name instead:

```javascript
(function isWeekday() {
    var day = new GlideDate().getByFormat('EEEE') + '';
    return day != 'Saturday' && day != 'Sunday';
})();
```

The post's version uses a `switch`; this is the same check, shortened. The `+ ''` converts a Java string to JavaScript.

**Unconfirmed variants in the source:** one section shows `new GlideDate().getByFormat(...)` returning **GMT**, and the weekday section says `new GlideDate()` **uses your time zone**. Test before relying on it, near midnight in a zone far from UTC.

## Business duration

```javascript
function getBusinessDuration(scheduleID, gdtStart, gdtEnd) {
    var schedule = new GlideSchedule(scheduleID);
    return schedule.duration(gdtStart, gdtEnd).getDurationValue();
}
```

With an 11-hour, Monday to Friday schedule, the last 7 days return `2 07:00:00`, which reads as 55 hours because each day counts as 24. See [[Schedules and Schedule Entries]]. The post's example used a real sys_id; pass your own schedule's.

## Example

On *Example Test Instance*, as *Test User* with a time zone far from the instance's, run the weekday check in Scripts - Background and compare with `new Date().getDay()`.

## Related

- [[GlideDateTime API Reference]] · [[Date and Time Fields, Formats and Time Zones]] · [[GlideForm and GlideAjax Client API Reference]] (client-side date comparison)
