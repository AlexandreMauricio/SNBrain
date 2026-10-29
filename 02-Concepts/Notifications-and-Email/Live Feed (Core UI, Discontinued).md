---
type: concept
tags: [concept, notifications, forms-lists, domain-separation]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage people and work capabilities > Live Feed Core UI (106 topics: exploring, browser support, activating, administering: document feeds, record feeds, table notifications and examples, security and table access, CMS pages; using: hashtags, teams, feeds, UI overview, posting; reference: domain separation, tables, roles, script includes, business rules, email notifications), read 2026-10-29; end-user pages skimmed. https://www.servicenow.com/docs/r/servicenow-platform/live-feed/c_GetStartedWithLiveFeed.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Live Feed (Core UI, Discontinued)

**In one line:** Live Feed is a social feed inside the instance (posts, replies, likes, polls, @mentions, hashtags, teams, feeds tied to records); the Brazil docs say it is **discontinued**, works only in **Core UI**, and is switched off automatically when Next Experience is turned on.

From the Brazil docs; not tested. Kept because older instances still have it and its tables and business rules appear in upgrades and clones. For record collaboration in current UIs see [[Working Records in Service Operations Workspace]].

## Feeds

| Feed | What it is |
|---|---|
| Company feed | everyone; public team and feed messages also show here |
| Group feed | created by users around a topic; public or private (optionally findable and requestable) |
| Team | users combined to follow several feeds; creator is team administrator; public or private |
| **Record (document) feed** | a feed group attached to a record (e.g. an incident), named by its number, described by its short description; unlisted and private by default; posts are written to the record's **comments** or **work notes** journal (a plain text comments field is overwritten instead) |

Record feeds: plugin **Live Feed Document** (on by default). A user with write access to `work_notes` who clicks **Show Live Feed** becomes the feed administrator. Feeds honour the record's ACLs (no work notes read = no work-note posts), but ACLs are checked only on first access: remove people by hand to change access. `glide.ui.show_live-feed_activity` (off by default) creates a feed whenever a record is viewed; `glide.live-feed.auto_join_document_group` auto-joins visitors.

Configuration: **Show Live Feed** sits on forms of task tables; to add it elsewhere set `glide.live_feed.task_header_button` = `both` (default `collaboration`, for the Collaboration plugin `com.glide.collaboration`) and tick **Live feed** on the table, or dictionary attribute `live_feed=true`; copy the UI actions *Follow on Live Feed* and *Show Live Feed* (list and form) to the table with **Insert**. Disable: attribute `live_feed=false`, or clear **Live feed** on the table record. Business rule *Live Feed integration* (on `sys_journal_field`) writes journal entries to the feed.

## Table notifications (automatic posts)

**Live Feed > Feed Administration > Table Notifications** (`live_table_notification`; `live_feed_admin` or `chat_admin`): Table, Post to chat rooms, **Post to Live Feed**, Record Feeds (related feeds to post to, e.g. a story's sprint, release, epic; only if they exist), Active, Insert, Update, **Feed** (blank = company feed), Conditions, Description, **Message** (`${field}`, `${URI}` link; HTML stripped), **Before script** (server-side; variables `current`, `changedFields` with `.contains('field')`, `answer` = false cancels, `profileSource` = GlideRecord to post as, `profileID` = a `live_profile` sys_id; your own variables become `${name}`).

Task tables work out of the box (business rule *Live Feed events* fires `live_feed.update`, handled by script action *Live Feed Update*). For another table copy that business rule's script into a new **before** insert, update, delete business rule on that table, then create the notification.

```javascript
// Before script example (server-side): post only when the workaround changes
answer = changedFields.contains('work_around');
```

## Security and administration

- `live_feed_admin` (manage Live Feed, non-task notifications, access, messages) and `chat_admin` (chat rooms, if Chat is active).
- Everybody active has Live Feed by default. To restrict: roles on the **Live Feed** application menu (and **System Definition > Applications (Mobile)**), plus `ui page` read ACLs for `live_feed`, `live_feed_small`, `$live_feed`, `$live_feed_small`.
- Delete inappropriate posts: **Live Feed > Feed Administration > Messages** > State *deleted*. Who can create teams: create ACL on `live_group_profile`; who can rename hashtags: write ACL on `live_tag`.
- CMS / ESS portal: iFrame to `https://<instance>.service-now.com/live_feed.do?sysparm_doctype=true`, or the *Portal - Live* page and Live Feed dynamic blocks.
- Live Feed v2 (default on new instances; v1 for IE 7-9).

## Domain separation (data only, since Eureka)

Parent-domain users see child domains; child users see only their own. Hashtags and teams are separated; teams created from a record take the record's domain and follow it if it changes; email subscriptions only within the domain. See [[Domain Separation Support Levels by Application]].

## Tables

`live_message` (posts), `live_profile`, `live_group_profile` (feeds and teams), `live_group_member`, `live_follow`, `live_favorite`, `live_link`, `live_mention`, `live_tag`, `live_message_tag`, `live_tag_follow`, `live_message_like`, `live_poll`, `live_poll_option`, `live_poll_cast`, `live_feed_search` (search log), `live_table_notification`. Business rules enforce group visibility and membership; one creates a feed group for assessable records (`asmt_assessable_record`). Email notifications cover feed and team membership changes, replies, likes, mentions and subscriptions (e.g. *Live Message Mention*, *Live Message Reply*).

## Example

Table notification *Example Workaround Posted* on `problem`, Update, condition [State] [is] [Open], message "${sys_updated_by} posted a workaround for ${URI}", before script as above, Feed *Example Problem Team*.

## Related

- [[Email Notifications]] · [[Events and the Event Queue]] · [[Dictionary Attributes Reference]]
