---
type: concept
tags: [concept, notifications, forms-lists]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > ServiceNow AI Platform Additional Capabilities > Connect (46 topics: supported browsers, activate Connect and Connect Support with their properties, Connect interface, notifications, profile picture, drag files, Visual Task Boards, mentions, Connect administration: properties, polling, overlay, audio, Connect actions, record cards, URL TLDs; Connect Chat use and administration; Connect Support), read 2026-10-29; end-user and Connect Support agent pages skimmed. https://www.servicenow.com/docs/r/servicenow-platform/connect/c_Connect.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Connect Chat and Connect Support (Core UI)

**In one line:** **Connect** (`com.glide.connect`, on by default) is the Core UI chat overlay: **Connect Chat** for direct, group and **record conversations** (messages become comments or work notes), and the deprecated **Connect Support** for queue-based help-desk chat; neither works in Next Experience.

From the Brazil docs; not tested. Brazil says some Connect Chat functions are available in Next Experience through the **Sidebar** (not covered in this chapter). Do not run Connect alongside **legacy chat**. Record conversations and Live Feed record feeds are the same thing: [[Live Feed (Core UI, Discontinued)]].

## Connect Chat

- Sidebar (toggle in the banner) and mini windows over the UI, or the full-screen **Connect workspace** (**Collaborate > Connect Chat**) with tools: Info (record, related records, links), Members, Attachments, Notification preferences.
- Direct (2 people, cannot add more later), group (3+), and **record conversations**: **Follow** in the form header; messages go to the record as **work notes** by default (switch with the message type icon); attachments go to the record too. Visual Task Boards can open a conversation whose members stay synced with the board.
- Enabled for task tables when the dictionary attribute `live_feed=true` (default on `task`) and `glide.live_feed.task_header_button` is `collaboration` (default) or `both`; `live_feed` shows only the Live Feed icon, `none` hides both. Set the attribute false on a table to remove Follow there.
- Offline users: event `collaboration.new_offline_message`, then after `collaboration.email_interval` minutes (default 3) `collaboration.notify_offline_user` / `.group` build one email of unread messages (notifications *Collaboration Offline Message Bundle*, *Collaboration Offline Group Message(s)*; users count as offline 90 seconds after logout). Push notifications *ConnectMessagePushNotification*, *ConnectNotificationPushNotification*. Users set mobile, desktop (must be switched on), email and audio per conversation.

## Administration (**Connect > Administration > Properties**, admin)

| Property | Default | Meaning |
|---|---|---|
| `collaboration.frameset` | true | show the overlay; false = workspace only |
| `collaboration.polling_interval` | 10 s | polling for messages (below 2 taxes the instance, above 10 feels slow) |
| `collaboration.email_interval` | 3 min | wait before emailing offline users |
| `connect.notification.audio_alert` | `connect_alert.mp3` | name of a `db_audio` record (**System UI > Audio Files**) |
| `connect.roles` | empty | roles allowed to use Connect (empty = everyone); align module roles too |
| `connect.search.conversation_limit` | 50 | conversations shown in search |
| `connect.retrieve_external_link_content`, `glide.ui.url.external`, `glide.ui.url.external.content` | | rich previews of external links |
| `glide.ui.url.external.top_level_domains` | top 200 TLDs | remove a TLD to make such links unclickable |
| `glide.ui.presence.disabled` | false | turns presence off platform-wide |
| `glide.connect.enabled` | | hides legacy chat's *Create or Join Chat Room* link; do not change |
| `glide.connect.chat.disabled` | false | true hides all Connect UI |

- **Connect actions** (**Connect > Administration > Actions**): Condition (JavaScript, e.g. `conversation.type === "support"`), Icon Class Name (**Collaborate > Administration > Action Icons**), Order, Script (e.g. `response.newRecord("incident", {short_description: conversation.document.short_description || "", caller_id: conversation.document.opened_by});`, APIs GlideConversation and ConnectActionResponse), slash **Shortcut**, unique Title. Shown in the actions menu by the message field.
- **Record cards**: list view named *Connect* on the table defines the fields on the card (Short description always on top; Author and Updated always shown).
- Profile pictures come from the Live Feed profile (**Collaborate > Live Feed**) or the user's **Photo**.

## Connect Support (deprecated)

Plugin `com.glide.connect.support` is no longer available for new activation (deprecated from Utah; no enhancements since Paris); move to Advanced Work Assignment and Agent Chat. Where still present: chat queues with agents, a **Support** tab in the sidebar, transfers, knowledge tool, records created from the chat (`chat_queue_entry`), `glide.connect.support.enabled` routing the ESS *Service Desk Chat* button to it. Properties `connect.support.conversation_limit` (-1 unlimited), `connect.support.idle.delay` (120 s), `connect.support.idle.count_down` (60 s), `connect.support.show_agent_avatar`, `connect.support.user.closed.conversation_limit` (0 = all), `glide.connect.support.reflect_system_messages`. Add-on plugins: Service Portal integration `com.glide.connect.support.service-portal`, manager homepage `com.glide.connect.managers_dashboard`, HR Connect `com.snc.hr.hr_connect`, PA content pack Service Desk Chat `com.snc.pa.chat`, context-sensitive analytics `com.snc.pa.chat.context_sensitive_analytics`. Activating it closed all open legacy chat queue entries.

## Example

Connect action *Example Create Incident* with condition `conversation.type === "support"`, shortcut `incident`, script creating an incident from the conversation's document.

## Related

- [[Collaboration Services (Slack, Teams and Zoom on Tasks)]] · [[Interaction Management]]
