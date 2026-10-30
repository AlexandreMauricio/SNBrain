---
type: concept
tags: [concept, reporting, security, roles, api, release-specific]
status: documented
source: ServiceNow Brazil docs, Platform Analytics guide > Usage Insights (Exploring, Navigating, Configuring, Enable, User privacy and consent, consent policy types, location detection, tracking controls, Conversations, Viewing dashboards, Creating custom events, Bulk export overview, Analytics overlay, roles, properties, durations, domain separation), read 2026-10-30. Retention, cohort, funnel and navigation path steps, tracked field and cookie lists, Mobile and Service Portal pages, and export setup steps listed, not read in detail. https://www.servicenow.com/docs/r/now-intelligence/usage-insights/user-exp-analytics-landing.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Usage Insights

**In one line:** **Usage Insights** (formerly User Experience Analytics; both names and role names with `analytics` survive) tracks how people use Core UI, Next Experience, Service Portal and Mobile applications: users, sessions, events, pages, retention, funnels and paths.

From the Brazil docs; not tested. Plugin **`com.glide.appsee`**, active by default, checks hourly for new applications to register. **Not supported on-premises.** The landing page says it is no longer supported on Xanadu; upgrade to Yokohama or later. **Domain separation: no support.**

Open: **All > Platform Analytics > Usage Insights**, with any viewer role.

## What it shows

| Area | Content |
|---|---|
| **Overview** (All Applications) | Active users, sessions, average screens per session and duration, new or returning users, app versions, hourly usage |
| **Analysis** | **Retention**, **Cohort analysis**, **Conversion funnel** (also cross-application), **Navigation paths** |
| **Data Foundation** | Users, Sessions, Events, Pages: filter, drill in, export |
| **Conversations** | Otto chat: chat users, live agent transfers, event sequence per conversation |
| **Dashboards** | Custom Platform Analytics dashboards |

Counters are aggregated. **Average load time is a sample of 5-10%.**

- **Average duration per page** = page time / (impressions minus exits).
- **Analytics overlay:** utility icon at the bottom left of a portal, workspace or Unified Navigation page: views, users, duration, load time, top 5 events.
- **Custom events:** no code; overlay > **Instrumentation** > **Start instrumentation**, pick a page element, **Add instrumentation** (`analytics_admin`, `analytics_viewer` or `analytics_instrumenter`). For non-click actions use the **SNAnalytics** API. Check the event inventory first to avoid duplicates.
- **Custom visualizations:** Store app *Usage Insights Performance Analytics Integration*. Channel-only viewer roles do not see the data source: `analytics_admin` or `analytics_viewer` is needed.

## Consent

**Privacy review is the customer's job: every country defaults to *No consent required*.** Set under **Platform Analytics Administration > UX Analytics Settings**.

| Policy | Behaviour |
|---|---|
| No consent required | tracked, no message (default) |
| Notice | message that activity is tracked |
| Explicit opt-in | user accepts or declines |
| Basic tracking | usage metrics only; hashed ID and session data still collected for aggregates |
| Disabled | like opting out: no individual tracking |

Notice and opt-in choices expire after 365 days. **The difference between Basic and full tracking is how data is presented, not what is collected.** The docs state that with Disabled user metrics are not tracked *and* that aggregate collection continues.

**Data:** a one-way, **unsalted** SHA256 hash of the user sys_id, on `sys_user`; the IP address becomes a city-level location and is not stored. Geolocation may count as PII.

**Location detection** (**Usage Insights settings > Detection Policy Providers**, ordered): **User country** (`country` on `sys_user`), **Country Customer script** (returns ISO 3166-2), **Policy Customer Script**, **GeoIP** (default if none selected). If a provider is inactive or a script returns nothing, the fallback is stated as **Explicit opt-in**.

**To stop everything:** `glide.analytics.enabled` removes the dashboard but aggregate data continues; **full disable needs a Support case**.

## Bulk export

Store app, asynchronous REST request returning a job ID; JSON batches go to a Kafka topic on a Hermes cluster, consumed with SSL. Events data source only. Limits: 60 requests per hour per instance, 36 hours retention, 90 days per request, 100 GB per account per month. Dashboard export is CSV or JSON for small volumes.

## Roles

| Role | Can | Contains |
|---|---|---|
| `analytics_admin` | all settings, funnels, cohorts | `analytics_viewer`, `mobile_analytics_admin`, `web_analytics_admin`, `chat_analytics_admin`, `sdk_analytics_admin` |
| `web_analytics_admin` | web settings | `core_ui_analytics_admin`, `now_experience_analytics_admin`, `web_analytics_viewer` |
| `analytics_viewer` | view | `mobile_analytics_viewer`, `web_analytics_viewer`, `sdk_analytics_viewer`, `chat_analytics_viewer` |
| `web_analytics_viewer` | view web | `portal_analytics_viewer`, `core_ui_analytics_viewer`, `now_experience_analytics_viewer` |

`portal_analytics_admin` appears on the Enable page, not the role list. Groups: Analytics settings managers, Mobile analytics settings managers.

## Properties

| Property | Meaning | Default |
|---|---|---|
| `glide.analytics.enabled` | track analytics | `false` on the property page, yet the docs say enabled by default: unconfirmed |
| `glide.analytics.user.consent.script_timeout` | consent script, ms, 100 to 5000 | 2000 (one page writes `glide.analytics.consent.script_timeout`: unconfirmed variant) |
| `glide.sp.analytics.enabled.portals` | tracked portals, sys_ids | base Service Portal |
| `glide.analytics.tracking.restricted.portals` | not tracked; overrides the one above | |
| `glide.analytics.tracking.force_allowed.portals` | no consent pop-up | |

Changing a portal sys_id starts a new dashboard.

## Example

Set *Example Country* to **Explicit opt-in**, set the detection order to User country then GeoIP, then tag the button *Example Submit* as a custom event from the overlay.

## Related

- [[Platform Analytics Experience Overview]] · [[Platform Analytics Dashboards]] · [[Platform Analytics Data Visualizations]]
