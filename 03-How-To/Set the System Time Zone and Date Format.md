---
type: how-to
tags: [how-to, platform, instance-admin]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Time configuration", topics "Set a system time zone", "Global date and time field format", "Change the time zone choice list" (pp. 2041-2042, 2097-2098), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Set the system time zone and date format

**Goal:** make the instance show dates and times the way the organisation expects by default.
**Prerequisites:** role admin. Do it outside business hours (property change flushes caches).
**Navigation:** All > System Properties > System

## Steps

1. Open **System Properties > System**.
2. In *System timezone for all users unless overridden in the user's record* (`glide.sys.default.tz`) enter a zone as Region/City.
3. In the date format property (`glide.sys.date_format`) and time format property (`glide.sys.time_format`) enter the patterns.
4. Save.
5. Optional: on a user form, right-click **Time zone** > **Configure Choices** to add the zones your users need.

## Result / how to check it worked

A user with no personal time zone sees *System (<zone>)* in their profile and times in that zone. Lists show the new format.

## Example

| Property | Value |
|---|---|
| `glide.sys.default.tz` | `Europe/Lisbon` |
| `glide.sys.date_format` | `dd-MM-yyyy` |
| `glide.sys.time_format` | `HH:mm:ss` |

## Tables / fields involved

- `sys_properties`; `sys_user`: **Time zone** (`time_zone`), **Date format** (`date_format`)

## Gotchas

- Users with their own time zone or format are not affected.
- Use `yyyy`, never `yy`.
- Changing the date format affects all-day schedule entries; check schedules afterwards.
- Background: [[Date and Time Fields, Formats and Time Zones]].
