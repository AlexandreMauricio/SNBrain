---
type: concept
tags: [concept, users]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage service capabilities > Service Administration > Geolocation (landing, Activate geolocation, Installed with geolocation, Geolocation Google key, Geolocation history, Location tracking), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/c_Geolocation.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Geolocation and Location Tracking

**In one line:** plugin **Geolocation** (`com.snc.geolocation`) records the position of users who have **Geolocation tracked** ticked, from their browser or mobile app, into **Geolocation History** (`geo_history`), and uses Google Maps for routing and travel times (mainly Field Service / work management).

From the Brazil docs; not tested. Configured by `admin`.

## Pieces

- Field **Geolocation tracked** on User (`sys_user`) (default view). Coordinates update when the user loads any Task (`task`) record or child, then at an interval while the record stays open; only if the browser shares location.
- Business rule *GeoLocation Data updated* (on `sys_user`, writes `geo_history` when Latitude / Longitude change); client script *Update Geolocation on Task*; script includes `GeolocationAJAX`, `GeolocationUtils`.
- **Geolocation > Geolocation History**: time-stamped positions; nothing is logged if the user stayed in about the same place.
- Google: **System Properties > Google Maps** with a Google Maps API for Business licence or a JavaScript API key `<GOOGLE_MAPS_KEY>`. Without it, Field Service auto-routing and dispatch use rough or fixed travel times.

## Properties (**Geolocation > Administration > Geolocation Properties**)

| Property | Default | Meaning |
|---|---|---|
| `glide.geolocation.tracking.frequency` | 60 | seconds between position captures (the tracking page says the update interval default is 300 s; unconfirmed) |
| `glide.geolocation.proximity` | 500 | metres an agent must move to count as a new location |
| `glide.geolocation.proximity.location` | 200 | metres from a location still counted as being there |
| `glide.geolocation.history.cleanup` | 30 | days of history kept |
| `glide.geolocation.allow.toll.roads` | true | routing may use toll roads |
| `glide.geolocation.default.start.time` | 08:00 | agents' start time with no schedule |
| `glide.geolocation.morning.rush.hours`, `glide.geolocation.evening.rush.hours` | | ranges like `06:30-08:00`; the page also refers to them as `work.management.*.rush.hours` (unconfirmed variants) |
| `glide.geolocation.rush.travel.buffer`, `glide.geolocation.travel.buffer` | | % added to (rush) travel times |
| `glide.geolocation.work.spacing` | | minutes between the end of a task and travel to the next |

How capture works: at each frequency interval a coordinate is taken and kept only if it is farther than the proximity threshold from the previous one; stored points are sent to the server by a separate service. **Mobile**: iOS saves only on significant moves (proximity in metres, frequency in minutes, both honoured); Android sends every minute (fixed). Mobile defaults: manual tracking 1 minute / 100 m, action-based tracking 5 minutes / 500 m.

## Related

- [[Users, Groups and Roles Overview]] · [[Walk-up Experience]] · [[Adaptive Authentication]] (also uses location)
