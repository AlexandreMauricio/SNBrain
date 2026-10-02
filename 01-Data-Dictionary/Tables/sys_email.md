---
type: table
tags: [table, schema, email, notifications]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Email Administration" (pp. 2394-2395) and "System notifications", topic "System email log and mailboxes" (pp. 2576-2577), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# sys_email

**Label:** Email
**What it stores:** every email the instance creates or receives. The system mailboxes (Inbox, Outbox, Sent, Skipped, Failed, Junk) are filtered views of this table. Log view: **System Logs > Emails**.
**Rotation:** table extension, a new shard per period ([[Database Rotation - Table Rotation and Table Extension]]). Archived to `ar_sys_email` by Email Retention.

## Key columns

Labels from the guide; column names are not given.

| Label | Name | Meaning | Confidence |
|---|---|---|---|
| Type | ? | `received`, `received-ignored`, `send-ready`, `sent`, `send-ignored`, `send-failed`, `send-translation-ready`, plus retry types | documented |
| State | ? | Error, Ignored, Processed, Ready | documented |
| Mailbox | ? | which system mailbox lists it; derived from Type and State | documented |
| Receive type | ? | None, Forward, New, Reply | documented |
| Target | ? | document ID of the record the email is about | documented |
| Subject, Body, Recipients, Headers, Content type | ? | the message. Body holds raw HTML (related link **Preview HTML Body**) | documented |
| Error string | ? | why sending failed or the email was ignored | documented |
| User | ? | name of the sending user (a string) | documented |
| Notification type | ? | None, SMS, SMTP | documented |
| Weight, Importance | ? | from the notification | documented |
| UID | ? | ID of the message on the mail server | documented |
| Deleted | ? | inbound: whether it was deleted from the mail server | documented |
| Originating Event and Notification | ? | embedded list: the event and notification that produced it | documented |

## Relations

- Related list **Email Log** = Email Log Entry (`syslog_email`): per-email processing messages, kept 7 days
- `sys_email_attachment`: attachment status per email
- `sys_watermark`: watermarks linking outbound email to records
- `email_access_restriction`: conditions limiting who can read emails of a notification

## Gotchas

- Query with a created-date range: the table is sharded by date.
- Creating records here through the Email API needs the role `email_api_send` plus an ACL.
- Emails with no target are visible to everyone unless `glide.email.email_with_no_target_visible_to_all` is false.

## Related

- [[Notification Email Not Sent or Not Received]] · [[Email Architecture and Accounts]]
