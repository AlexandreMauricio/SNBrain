---
type: concept
tags: [concept, incident, request, portal, assets, integrations]
status: documented
source: ServiceNow Australia IT Service Management PDF, "Walk-up Experience" (pp. 3792-3872), read in full 2026-10-02 (the quick start test table continues onto the next chapter's first page)
sn-release: Australia
verified:
updated: 2026-10-02
---

# Walk-up Experience

**In one line:** Walk-up Experience runs an on-site (or remote) IT help desk ("tech lounge"): people check in at a tablet, by badge, online or in the mobile app, or book an appointment; each visit is an **interaction** routed to a technician through Advanced Work Assignment.

Plugin `com.snc.walkup` (activates `com.glide.interaction`; needs Asset Management and Service Portal; appointments need `com.snc.appointment_booking`). Menu **Walk-up Experience** (Administration, Agent / Technician, Dashboard).

## Tables

| Table | Label | Content |
|---|---|---|
| `wu_location_queue` (extends `awa_queue`) | Walk-up Location Queue | one walk-up location with all its settings |
| `wu_reason` | Walk-up Reason for Visit | reasons users can choose |
| `wu_m2m_location_queue_reason` | Walk-up Reason | which reasons a location offers, and their order |
| `wu_context` | Walk-up context | the requester and description of a check-in |
| `wu_appointment` (extends [[task]]) | Walk-up Appointment | booked appointments |
| `interaction` | Interaction | the visit itself (type Walk-up); states New, Queued, Work in Progress, On Hold, Closed Complete, Closed Abandoned |

A walk-up interaction is valid only when created by check-in or appointment booking; creating one by hand in the table is not supported, and an agent cannot check in on a user's behalf.

## Roles

| Role | For | Contains |
|---|---|---|
| `sn_walkup.walkup_login` | the **account** (not a person) that logs the check-in tablet into the on-site portal; must have no other role; the portal cannot be opened as admin | |
| `sn_walkup.walkup_technician` | agents | `interaction_agent`, `workspace_agent`, `awa_agent`, `sn_apptmnt_booking.appointment_booking_user` |
| `sn_walkup.walkup_manager` | dashboard, locations | technician, `sn_apptmnt_booking.appointment_booking_manager` |
| `sn_walkup.walkup_admin` | configuration | `inventory_admin`, `schedule_admin`, `sp_admin`, `sn_apptmnt_booking.appointment_booking_admin`, `awa_admin` |

Security: with the Explicit Roles plugin (`com.glide.explicit_roles`) the kiosk account should be `snc_external`. After an upgrade it ends up `snc_internal`: remove that and add `snc_external` by hand (new installs are correct).

## Walk-up location form

**Walk-up Experience > Administration > Walk-up Locations**.

| Tab | Fields |
|---|---|
| Main | **Name**, **Schedule** (opening hours), **Appointment Booking**, **Service channel** (Walk-up), routing condition (simple or advanced), **Active**, **Enable away state** + **Away message**, **Stockroom**, **Location**, image |
| Management | **Position notification** (queue position at which the user is told they are close), **Last check-in** (minutes before closing), **Enable online check-in**, **Enable kiosk** / **Show kiosk**, **Enable appointment delegation** + group (book for someone else), **Maximum appointments per user** (default 1; changes affect future bookings only), **Name configuration** (first name; first and last; first name with initial), **Appointment routing time** (minutes before the appointment that it is routed to an agent), **Hold time**, **Show estimated wait time** (queue average wait × people ahead; needs AWA), **Audio Playback** and **Audio File** (mp3 only; default `walkup_checkin.mp3`) |
| Administration | **Queue time display** (none, check-in time, time waited), **Queue message**, **Check-in greeting**, **Closed message**, **Closed phone number** + label, **Closed record producer** (for example Create Incident), **Badge Check-in Reason**, contextual search configuration and maximum results, **Appointment type** (In-person, Remote, Both), **Enable unregistered user entry** (guests), **Enable lookup user entry**, **Enable technician info** / **avatar**, logos |
| Related lists | Interactions, Walk-up Appointments, **Reasons for Visit** (with *Walk-up Skills for Reasons*), Walk-up Location Kiosks, Assignment Eligibility, Work Item Sort Order, Location Queues Badge Readers |

Other administration: Portal Configurations (base *Walk-up Portal* with pages `walkup_online_checkin`, `walkup_queue_on_site`, `walkup_home`, `walkup_survey`, `walkup_check_in`: copy pages and widgets to customise), Schedules, Walk-up Stockrooms (stockroom **Type** = Walk-up), Notifications (*Walk-up Assigned*, *Walk-up Threshold Notification*, *Walk-up Abandoned*, *Walk-up Closed*), Surveys (*Walk-up CSAT survey*: on-site, three faces, 1-3; *Walk-up Experience Satisfaction Survey*: emailed at closure, 1-5).

- **Kiosks**: named service points inside a location (for example laptop refresh). An agent checks in to one kiosk at a time from the workspace; requesters are directed to the kiosk for their need.
- **Skill-based routing**: on a reason, related list *Walk-up Skills for Reasons* (**Skill**, **Mandatory**); activate business rule *Skill determination for interaction* on `interaction`. Without an available skilled agent, and if no skill is mandatory, the location's assignment rule applies.
- **Online check-in**: module **Self-Service > Walk-up Check-in** is hidden by default (activate it under **System Definition > Application Menus**, also for mobile); or put the `walkup_online_checkin` page behind an icon on the portal home page. Geolocation picks the nearest location, falling back to the user's latitude and longitude.
- Devices: tablet or desktop for check-in and survey, a large screen for the queue display (not a tablet).

## Appointments

Two levels under **Appointment Booking > Appointment Booking Configuration**: the application configuration *Walk-up Experience* (task table `wu_appointment`; **Availability Method** number per slot or scripted; **Portal View** day or week; **Active**) and one **service configuration per location**. Both must be active.

Each location needs its own **record producer** on `wu_appointment` with variable sets `sn_appointment_variable_set` and `sn_walkup_variable_set`.

| Service configuration field | Meaning (default) |
|---|---|
| **Catalog item** | that record producer |
| **Location**, **Timezone** | set **Location** so the calendar uses the location's time zone; the schedule used is always the location queue's |
| **User contact** | Contact |
| **Holiday Schedule** | days excluded (can be a custom "off hours" schedule with the holiday schedule as child) |
| **Appointments per window** | capacity per slot |
| **Lead time** | earliest bookable from now (4 hours) |
| **Future bookable max days** | (14) |
| **Reschedule / Cancel by time** | (4 hours) |
| **Appointment window**, **Work duration** (1 hour), **Travel duration** (set 0) | |
| **Bookable days**, **Daily start time** (9:00), **Daily end time** (18:00), **Include daily break** | should match the location schedule |
| **Enable day level configuration** | different slots per part of day (related list *Appointment Booking Day Configuration*) |
| **Enable advanced configurations** | variable slot lengths per reason: *Service Configuration Rules* + *Advance Configurations* (must not overlap), mapped on the location's Reasons for Visit |

To block hours, add *Excluded* schedule entries. Reminders: activate scheduled job *Appointment Booking Reminders* and add field **Appointment reminder** (hours before) to the service configuration form.

Outlook calendar invites (Microsoft 365 only): Exchange Online spoke (`sn_ex_online_spke`), an Entra ID app registration with Microsoft Graph permission, **System OAuth > Application Registry > Microsoft Exchange Online** (client id and secret as `<CLIENT_ID>` / `<CLIENT_SECRET>`; URLs `https://login.microsoftonline.com/<tenant-ID>/oauth2/v2.0/authorize` and `.../token`; redirect `https://<instance>.service-now.com/oauth_redirect.do`), OAuth 2.0 credential, connection `https://graph.microsoft.com` on alias *Microsoft_Exchange_Online*, then activate flows *Create Walk-up Appointment Calendar Event* and *Update/Delete Walk-up Appointment Calendar Event*.

## Badge reader check-in

Plugin `com.snc.badge_reader` (role `sn_badge.badge_admin`). **Not an authentication mechanism.**

| Table | Content |
|---|---|
| `sn_badge_badge_reader` (extends task) | a reader: **Device Identifier** (serial), **Secret Key**, **Badge Event Handler**, **User Badge Configuration**, status New / Activated / Deactivated |
| `sn_badge_event_handler` | script run on a scan (GlideScopedEvaluator, server-side) |
| `sn_badge_user_badge` | user ↔ badge number + facility code |
| `sn_badge_scan_log` | scan errors |

You write your own badge reader client (macOS or Linux); it calls REST `api/sn_badge/v1/reader/scan` with the device identifier and card data. Assisted registration: properties `sn_badge.enable_scan_registration` = true and `sn_badge.disable_access_token` = true, then swipe an admin badge. **Request Activation** starts an approval by itil users in the badge reader approvers group (empty group = activated at once). Map readers to a location in *Location Queues Badge Readers* (one location per reader; optional check-in reason). Extension points: `sn_badge.BadgeReader`, `sn_badge.BadgeReaderParser`, `sn_badge.BadgeReaderUser` (use your own badge data model), `sn_badge.BadgeReaderScanProcessor`.

## Agents and users

- Agents: inbox status Available → interactions are pushed first come, first served (they may also pull any queued one; VIPs are flagged); **Put on Hold** keeps the person's place and frees capacity; **Create Incident**, **Create Request**, **Associate Record**, **Abandon**, close. Stockroom fulfilment: related link **Stockroom Consumables** > **Consume** (quantity, asset, user). Appointments list: **Accept appointment**. In Service Operations Workspace: [[Working Records in Service Operations Workspace]].
- Users: Employee Center **IT > Walk-up: Plan your visit** (join the queue or **Schedule an appointment**: reason, slot, in-person or remote), the Now Mobile app (*Visit a Tech Lounge*: Make Appointment, Join Queue, Leave queue; *My Tech Visits*; needs `com.glide.mobile-employee`), Virtual Agent topic *Walk-up Check-in*, iCalendar download. When the location is closed the tablet shows the phone number and a link to create an incident.
- **Dashboard** (manager, admin): completed walk-ups, exit and email CSAT, volumes by location, reason, weekday and hour, consumables used, average wait and service time, share with incidents or requests, remote versus in-person, abandoned share by check-in type.

Domain separation: Basic. `wu_location_queue`, `wu_reason`, `wu_m2m_location_queue_reason`, `wu_context` and `interaction` are separated; portal pages are not (build one portal per tenant); each queue's routing condition must reference its domain; appointment data (`itil_appointment`) is **not** separated.

## Related

- [[ITSM Virtual Agent Topics and Setup]] · [[Asset Management Common Applications]] · [[Schedules and Schedule Entries]]
