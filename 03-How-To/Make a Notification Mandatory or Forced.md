---
type: how-to
tags: [how-to, notifications]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Notification Preferences", topics "Make a notification mandatory" and "Force a notification to be sent" (pp. 2702-2703), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Make a notification mandatory or forced

**Goal:** make sure users receive a notification whatever their preferences say.
**Prerequisites:** role admin.
**Navigation:** All > System Notification > Email > Notifications

## Steps

1. Open the notification.
2. Form context menu > **Configure > Form Layout**; add **Mandatory** and/or **Force delivery** (neither is on the form by default). Save.
3. Tick the one you need and update.

## Result / how to check it worked

- **Mandatory**: in the user's notification preferences the toggle is on and read-only.
- **Force delivery**: the user can still switch it off in preferences, but it is delivered anyway.

## Example

Notification *Example major incident declared*: tick **Mandatory** so nobody can unsubscribe.

## Tables / fields involved

- `sysevent_email_action`: **Mandatory** (`?`), **Force delivery** (`?`)

## Gotchas

- Both apply to the user's **primary** device only.
- Mandatory is sent even if the user disabled all notifications; forced is sent even when the user's **Notification** field is Disable.
- Background: [[Notification Preferences and Channels]].
