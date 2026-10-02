---
type: concept
tags: [concept, notifications, users]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Notification Preferences" (pp. 2686-2706), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Notification preferences and channels

**In one line:** each user decides which notifications they receive and on which **channel** (device), with optional schedules and filters; admins decide what is subscribable, mandatory or forced.

## Where users set them

| UI | Path |
|---|---|
| Next Experience | user menu > **Preferences > Notifications**: **General** tab (global switch, categories, channels) and **Advanced Preferences** (System Notifications, Custom Notifications, Delivery Channels tabs) |
| Core UI | gear icon > **Notifications** tab of System Settings, or **Self-Service > My Notification Preferences** |

- `glide.ui.polaris.core.notification_preference.enabled` = true: use the Core UI preferences screen from Next Experience.
- `glide.notification.preference.sn_form_enabled` = true: standardised forms in the Next Experience preferences (Yokohama onwards).
- `glide.notification.preference.UI.enabled` = false: revert to the old UI15 screen (link on the user form).
- In Core UI search, typing `**` lists all notifications alphabetically.

## Channels (devices)

- A channel is a record in `cmn_notif_device`: type **Email**, **SMS**, **Voice**, **Instant Message**, or push (created automatically at first mobile login).
- Every user with an email address gets a **primary email** channel automatically, the first time a notification is sent to them.
- A new channel must be **enabled per notification** before it receives anything.
- A channel can have a **Schedule**. Notifications triggered outside the schedule are **dropped, not queued**.
- Users create and edit channels; only admins delete them.
- SMS by email-to-text uses a **service provider** (`cmn_notif_service_provider`): prefix/suffix around the phone number, or a construction script (`current` there is the device). Carriers are retiring email-to-text; the guide points to Notify for SMS.

## Subscriptions (personal / custom notifications)

- An admin marks a notification **subscribable**; it then shows in users' preferences. Plugin Subscription Based Notifications 2.0, table `sys_notif_subscription`.
- A user creates a **personal notification** (Core UI) or **custom notification** (Next Experience): a name, the notification, channels, an optional schedule and filter conditions (for example only priority 1). **One subscription per notification per user.**
- Next Experience custom notifications cannot target a specific **affected record**; use the Core UI screen for those.
- Subscription-based notifications are not domain aware.

## What admins control

| Tool | Effect |
|---|---|
| **Mandatory** (field on the notification, add it to the form) | the user's toggle is locked on; they cannot unsubscribe, filter or schedule it. Sent even if the user disabled notifications. Primary device only |
| **Force delivery** (field, add it to the form) | sent even if the user unsubscribed or their **Notification** field is Disable, but the preference is not locked. Primary device only |
| **Notification filters** (**System Notification > Email > Notification Filters**) | reusable conditions over several tables that users can apply. User filters are evaluated **after** the admin's notification conditions |
| **Notification filter configuration** (**System Notification > Emails > Notification Filter Configuration**, needs property `glide.notification.preference.apply_filter_config` = true) | limits which notifications appear in the preferences page for users matching a user criteria; lowest order wins |

## Search inside preferences

Name search by default. With plugin **AI Search for Notifications** (`com.glide.notification.ais`) and the indexed sources *Platform Notifications V1* and *V2* fully indexed, it also searches inside notification fields.

## Related

- [[Email Notifications]] · [[Email Watermarks, Digests, Retention and Translation]] · [[Push and Messaging App Notifications]] · [[Provider Notifications]] · [[Notification Email Not Sent or Not Received]] · [[Make a Notification Mandatory or Forced]]
