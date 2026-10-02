---
type: how-to
tags: [how-to, notifications, email]
status: documented
source: ServiceNow Australia Platform Administration PDF, "System notifications", topics "Create an email notification" and "Preview email notifications" (pp. 2487-2501), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Create an email notification

**Goal:** send an email automatically when a record changes or an event fires.
**Prerequisites:** role admin (or `notification_admin`). Email sending enabled. Recipients are active users with a valid email.
**Navigation:** All > System Notification > Email > Notifications

## Steps

1. Open **System Notification > Email > Notifications** and select **New**. Switch to the **Advanced view** if fields are missing.
2. Header: **Name**, **Table** (not Task itself), **Category**, **Active**, optionally **Allow Digest**.
3. **When to send**: choose **Send when**; tick **Inserted** and/or **Updated**, or pick the **Event name**; add **Conditions**; set **Weight** if it competes with other notifications.
4. **Who will receive**: fill **Users**, **Users/groups in fields** and/or **Groups**; decide **Send to event creator**.
5. **What it will contain**: pick an **Email template** or write **Subject** and **Message HTML**, inserting fields from **Select variables**.
6. Submit, reopen, and select **Preview Notification**: check the content against a sample record and see who would and would not receive it, and why.

## Result / how to check it worked

Trigger the condition on a test record, then look in **System Mailboxes > Outbox / Sent** (or **Skipped**). In sub-production, set `glide.email.test.user` so all mail goes to a test address.

## Example

*Example Incident Assigned to Group*: table Incident, **Updated** ticked, condition **Assignment group changes**, recipients **Users/groups in fields** = Assignment group, subject `Incident ${number} assigned to your group`, body with `${short_description}` and `${URI_REF}`.

## Tables / fields involved

- `sysevent_email_action`: the notification
- `sysevent_email_template`: templates; `sys_email_layout`: layouts
- `sys_email`: the generated emails
- `cmn_notif_device`: each user's notification devices

## Gotchas

- You do not get the email for your own change unless **Send to event creator** is ticked **and** you are a recipient.
- Group members only get individual copies if the group has **Include members**.
- Of several notifications triggered together for the same record and recipients, only the highest **Weight** is sent.
- Conditions and Advanced condition must both be true.
- Recipients are not filtered by ACLs.
- Background: [[Email Notifications]].
