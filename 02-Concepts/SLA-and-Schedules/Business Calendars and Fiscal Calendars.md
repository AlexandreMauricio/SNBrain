---
type: concept
tags: [concept, reporting, admin]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Using time configuration", topics "Creating business calendars", "Create a business calendar group", "Define business calendar entries", "Define business calendar filtering options", "Pair business calendars with packages", "Defining fiscal calendars" (pp. 2082-2097), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Business calendars and fiscal calendars

**In one line:** a business calendar is a list of named periods (fiscal years, quarters, periods, work weeks) with explicit start and end dates, used for reporting periods, filters such as "last fiscal quarter", and scheduling jobs at period boundaries.

## How it differs from a schedule

A schedule ([[Schedules and Schedule Entries]]) has repeating and excluded spans and answers "is this time working time?". A business calendar has **one entry per period, no repetition**, and answers "which period is this date in?".

## Pieces (menu Business Calendar, role `business_calendar_admin`)

| Piece | Table | Holds |
|---|---|---|
| Business calendar | `business_calendar` | **Name**, **Label** / **Plural label** (used in filters), **Parent**, **Time zone** |
| Entry | `business_calendar_span` | **Start**, **End** for one period |
| Entry name | `business_calendar_span_name` | **Short name**, **Long name**, **Label**, **Calendar type** (business or fiscal) |
| Filter option | `business_calendar_filter_option` | **Period** offset: 0 = current, -1 = last, 1 = next |
| Calendars for package | `calendars_for_package` | enables a calendar in a functional area (package) |
| Business calendar group | | several calendars together; required by Performance Analytics and reports |

- Parent/child calendars model hierarchy: Fiscal Year > Fiscal Quarter > Fiscal Period.
- A calendar is only a definition until it is paired with at least one **package**.
- Base group *Gregorian Calendar* holds Week, Month, Quarter, Year.
- For Performance Analytics do not use calendars with periods shorter than a day; changing spans can invalidate collected scores.
- Entries can be generated with the script include `BusinessCalendarGeneratorUtil`.

## Fiscal calendars (legacy generator)

Plugin Fiscal Calendar (`com.snc.fiscal_calendar`), **Fiscal Calendar > Generate** (role `fiscal_calendar_admin`).

| Type | Periods |
|---|---|
| Regular | 12 monthly periods |
| Period | 13 periods of four weeks (no quarters) |
| 445 / 454 / 544 | quarters of 4+4+5, 4+5+4 or 5+4+4 weeks |

Result in `fiscal_period` (**System Definition > Fiscal Periods**, **Validate Periods** checks for gaps). Once financial data uses a calendar type it cannot be changed. Strategic Portfolio Management requires calendars generated this way. Legacy calendars show in the Business Calendar lists but are edited only with the legacy function.

## Example

Calendar *Example FY26* (1 October to 30 September) with child *Example FY26 Quarter* (four entries). Filter options -1, 0, 1 give users "last / this / next fiscal quarter" in condition builders. A scheduled job with **Run** = *Business Calendar: Entry End* and an offset of one day in the past runs the day before each quarter ends.

## Related

- [[Scheduled Jobs]] · [[Date and Time Fields, Formats and Time Zones]]
