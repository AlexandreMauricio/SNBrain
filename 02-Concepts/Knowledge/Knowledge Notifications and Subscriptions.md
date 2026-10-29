---
type: reference
tags: [reference, knowledge, notifications]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Knowledge Management > Exploring > Knowledge subscriptions; Using > Managing email notifications in Knowledge Management, Set knowledge notification preferences, Use knowledge subscriptions (Subscribe / Unsubscribe to a knowledge base and article, Manage knowledge subscriptions), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/knowledge-management/email-notifications-km.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Knowledge Notifications and Subscriptions

From the Brazil docs; not tested. Subscription properties: [[Knowledge Bases and Categories]]. Notification engine: [[Email Notifications]], [[Notification Preferences and Channels]].

## Notifications

| Notification | Sent when | To | Needs |
|---|---|---|---|
| KM Feedback Task: Created / Commented / Reassigned / Resolved / Resolution Accepted / Resolution Rejected | feedback task events | assignee (reassigned: new assignee) | Knowledge Management Core `com.glideapp.knowledge` |
| KM Feedback Task: Info from Submitter | more info requested | submitter | same |
| KM Subscription Group: Article checkout / Article commented | subscribed article checked out or commented | author (no ownership group) or ownership group manager and members; revisers; not the person who checked out | Core, plus KM Advanced for ownership groups |
| KM Subscription: Article published | new article in a subscribed base | base owner, base subscribers | Core |
| KM Subscription: Article revised | subscribed article edited | base owner, article subscribers, author | Core |
| KM Subscription: Article revised in subscribed KB | article in a subscribed base edited | base subscribers | Core |
| KM: Approve article for publishing | approval needed | base owner and managers, or ownership group manager and members when groups are on | Core |
| KM: Article approved for publish / rejected for publish | decision | author or reviser who submitted | Core |
| KM Translation Task: Assigned to me / Closed | translation task assigned / closed after publish | assignee (closed: also submitter) | KM Advanced + `com.glideapp.knowledge.i18n2` |
| KM: Article Expiry Warning | 1st of each month, articles expiring next month | base owner and managers, revisers of updated or checked-out versions, or ownership group | `glide.knowman.enable_article_expiry_notification` = true (default false) |
| KM: AQI on Article / AQI on Ownership Group Article | AQI review submitted | last updater (and author/creator on later versions) or the ownership group | KM Advanced |

Expiry email: up to 10 articles listed by Valid to date; more than 10 → a link to the list. Articles drop out of search after **Valid to**.

## Subscriptions (users)

- Need KM Advanced; role `knowledge` to subscribe to a base.
- **Base**: **Subscribe** on the base tile (portal homepage or Knowledge > Homepage). Subscribing to a base covers its articles; unsubscribing from an article in a subscribed base also asks to unsubscribe from the base.
- **Article**: **Subscribe** at the top of the article. From `/sp` you must go through the knowledge pages (`/sp?id=kb_home`). Emails link to the Knowledge Portal and carry number and short description.
- Manage: **Knowledge > Notification Settings** module or portal user menu > **Notification Settings**: *Subscriptions* tab (Knowledge Base / Knowledge Articles) and *Notification Preferences* tab (turn knowledge base and article notifications on or off).
- Owners are auto-subscribed to their bases and authors to their articles; with versioning on, checkout, revision and new-version publishes also notify.

## Related

- [[Knowledge Feedback, Ownership Groups and Article Quality]] · [[Knowledge Article Versioning]]
