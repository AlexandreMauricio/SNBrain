---
type: concept
tags: [concept, knowledge, reporting, automation]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Knowledge Management > Exploring > Self-Service Analytics and Self-Service Analytics concepts; Configuring > Configure Self-Service Analytics (Activate, activity contexts, pattern elements, pattern element groups, activity patterns, deflection configuration, scheduled jobs), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/knowledge-management/self-service-analytics.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Self-Service Analytics and Case Deflection

**In one line:** framework (plugin **Self-Service Analytics Core**, `com.snc.self_service_analytics_core`) that watches what a user does in self-service channels (Knowledge, Catalog, Communities, Virtual Agent) and records whether a case was then avoided: **confirmed**, **potential** or **no deflection**.

From the Brazil docs; not tested. Built for Customer Service (dashboard **Self-Service Analytics dashboard for customer service**, plugin `com.snc.pa.self_service_analytics_csm` gives the Consumer and Contact defaults), usable by any app on the **Subscriptions and Activity Feed Framework** (`com.snc.activity_subscriptions`, activated with it). Communities and Virtual Agent data need `com.sn_communities` and `com.glide.cs.chatbot`.

## Building blocks

| Piece | Meaning |
|---|---|
| Activity type | one action, e.g. *Viewed knowledge article* |
| Activity group | activity types on the same kind of object (Knowledge group = viewed + marked helpful) |
| Activity context | the activity groups tracked for one user entity, with its table (Contact `customer_contact`, Consumer `csm_consumer`) |
| Pattern element | one activity type plus an occurrence: **Once**, **Optionally Once**, **Optionally Many**, **At Least Once**, **Range** (min/max) |
| Pattern element group | two elements or groups joined by **And** / **Or**, with an occurrence |
| Activity pattern | ordered elements plus a **Primary Activity** and **Match If** linked to an **Outcome** (e.g. *Customer created a case* not found → Confirmed Deflection) |
| Deflection configuration | activity context plus a **Window**: case created inside it = no deflection; no case = potential; no case and last activity was positive feedback = confirmed |
| Deflection pattern / metric | pattern linked to a configuration; results stored in **Deflection Metric** (`ssa_deflection_metric`) |

Patterns and groups are evaluated as regular expressions. When several table maps match in an activity pattern: one match is used; same order → the oldest; different orders → the highest order.

## Setup (role `sn_ssa_core.self_service_manager` for configuration)

1. `admin` activates `com.snc.self_service_analytics_core` (also installed with the Platform Analytics Solution for Self-Service Analytics for Customer Service).
2. **Self-Service Analytics > Configuration > Activity Context**: Consumer, Contact or New (context table, module, application, domain); related lists **Activity Context Groups** and **Activity Context Types** (activity source context mapping: source table, filter, optional **Advanced Mapping Script**, **Fetch from Activities**).
3. **Pattern Element**, **Pattern Element Group**, **Activity Pattern** under the same menu (defaults exist for the four channels and for *Consumer / Customer created a case*).
4. **Deflection Configuration**: *Contact Case Deflection Configuration* or *Consumer Case Deflection Configuration*, set the window, related lists Deflection Patterns and Deflection Metrics.
5. **System Definition > Scheduled Jobs**: *Deflection Analytics for Consumers* / *for Contacts* (inactive by default). For a custom entity copy one and change `deflectionAnalyticsService.captureDeflectionAnalytics('<sys_id of the deflection configuration>')` (server-side scheduled script, global or the app's scope; [[Scheduled Jobs]]).

## Related

- [[Knowledge Management Overview]] · [[Knowledge Demand Insights and Predictive Intelligence]]
