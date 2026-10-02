---
type: concept
tags: [concept, notifications, integrations]
status: documented
source: ServiceNow Australia Platform Administration PDF, "System notifications", topics "Push notifications" and "Notifications in messaging applications" (pp. 2578-2616), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Push and messaging app notifications

**In one line:** besides email and SMS, the same notification engine can deliver **push** messages to mobile apps and messages to **Slack or Microsoft Teams**, including buttons that act on the record.

## Push notifications

How a push travels: record activity triggers the notification; the instance finds the recipients' push devices; sends to Apple (APNs) or Google (FCM), through a ServiceNow **push proxy** for the ServiceNow mobile app; the provider delivers to the app; a response button calls back to `https://<instance>/api/now/v1/push/<application>/action/<action>`, where a **push action** script runs.

- Plugins: Push Notification, Notification System Push Addon, Push Feedback (activated with the Mobile UI plugin). Role `push_admin`. Not supported for the ServiceNow mobile app on on-premise instances.
- Pieces, under **System Notification > Push**:

| Piece | Table | Purpose |
|---|---|---|
| Push application | `sys_push_application` | one record per mobile app (e.g. `ServiceNowPushApp`). Custom apps need a certificate (iOS, PKCS12) or FCM key |
| Push message | `sys_push_notif_msg` | the text for a notification, with optional attribute values |
| Push message content | `sys_push_notif_msg_content` | script building the JSON payload (layout, buttons). Has `current`, `message`, `attributes` |
| Push action | `sys_push_notif_act_script` | server script run on a button response (shipped: Approval - Approve, Approval - Reject) |
| Push default registrations | `sys_push_notif_default_reg` | notifications users of the app are subscribed to automatically |
| Push installations | `sys_push_notif_app_install` | device plus app tokens of users who accepted push |
| Push notifications log | `sys_push_notification` | what was sent: **System Logs > Push Notifications**, types failure, pending, success |

- A push notification is an ordinary notification record with **Push messages** set (and optionally **Push message only**). The push message and the notification must be on the same table. Create with **System Notification > Create Push Notification**, then add it to the app's **Push Default Registrations**.
- Limits: payload 2,048 bytes for Apple, 4,096 for Google; oversize messages are not sent. Delivery is never guaranteed or confirmed. Failed ones can be re-queued from the log.
- Properties: `glide.push.enabled` (true), `glide.push.notification.ttl_seconds` (21600: a queued push older than this is dropped), `glide.push.debug`, `glide.push.apns.version` (2).
- Logged-out users can still receive push with the maint-only plugin `com.glide.push.logged_out.users` and **Push to inactive users** on the notification (10 days by default). Do not put sensitive or actionable content in those.
- Retention: plugin `com.glide.push_retention` archives after 365 days and destroys after another 365, like email.

## Slack and Microsoft Teams

- Needs Integration Hub (Starter) and the plugin **Messaging Notification** (`com.glide.notification.messaging`), plus the **Now Actions** app installed in Slack or Teams by someone who is admin on both sides (role admin or `messaging_admin`). Configure at **System Notification > Messaging > Messaging Integration Configuration**.
- **Messaging content** (`messaging_content`, **System Notification > Messaging Content**): type **Simple** (informative, to a channel) or **Buttons** (to an individual user, with a script).

```javascript
if (actions.get('button') == 'Approve') {
    target.state = 'approved';
    target.update();
}
```

- **Messaging notification** (**System Notification > Messaging > Messaging Notifications**): a notification record with a messaging content. **Messaging Channels** for simple messages; **Users** for actionable ones. Not on the Task table itself.
- **Actionable notifications go to individual users, who must first link their accounts** by talking to the Now Actions bot and confirming (the link expires in five minutes). Unlinked users still see channel messages but cannot act. Unlink under **Self-Service > My Profile > View Linked Accounts**.
- Public channels are synchronised at install; channels are listed under **System Notification > Messaging Channels**.
- A custom Slack app can be registered by pasting its JSON configuration in the same page. Keep tokens and secrets out of notes.

## Related

- [[Email Notifications]] · [[Notification Preferences and Channels]]
