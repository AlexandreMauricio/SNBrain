---
type: troubleshooting
tags: [troubleshooting, notifications, email]
status: documented
source: ServiceNow Australia Platform Administration PDF, "System notifications", topics "Email FAQs and troubleshooting notification emails", "Email diagnostics", "System email log and mailboxes", "Email diagnostics dashboard" (pp. 2529-2539, 2571-2578), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Notification email not sent or not received

**Symptom:** a user did not get an expected notification, or no email leaves or reaches the instance.
**Cause:** one of: sending or receiving disabled, a stuck job, the recipient excluded, the notification skipped as a duplicate, a delivery failure, or a blocked address.
**Fix:**

1. **Is email on?** **System Mailboxes > Email Diagnostics**: *Email Sending* and *Email Receiving* enabled, *SMTP Sender State* and *Email Reader Status* healthy, last run times recent, connection status of each account green. The SMTP Sender and SMS Sender run every minute; processing time should be shorter than the interval.
2. **Is it a clone or sub-production instance?** Email is disabled after a clone, and `glide.email.test.user` may redirect all mail.
3. **Find the email record**: **System Logs > Emails** (table [[sys_email]]) or the mailboxes **Sent**, **Skipped**, **Failed**, **Junk**. Read **Type** and **Error string**:

| Type | Meaning |
|---|---|
| `send-ready` | waiting to be sent (should be brief) |
| `sent` | sent without error |
| `send-ignored` | skipped: no recipient address, or a duplicate. See Error string |
| `send-failed` | the server tried and failed. See Error string (not all servers return one) |
| `send-retry-backoff` | being retried with growing intervals |
| `send-retry-delayed` | address validation error, retried every 30 minutes |
| `received` / `received-ignored` | inbound; ignored ones are usually spam or auto-replies |

4. **Recipient missing?** Open the email record's **Email Log** related list (Email Log Entry, `syslog_email`; kept 7 days). It states why each recipient was included or excluded: inactive user, invalid address, notifications disabled on the user, device inactive or out of schedule, event creator, not subscribed. Also use **Preview Notification** on the notification.
5. **No email record at all?** The notification did not trigger: check its conditions and Advanced condition, **Inserted/Updated**, **Active**, and whether the event fired. Set `glide.email.notification.save_when_no_recipients` = true to keep records with no recipients while debugging.
6. **Skipped as duplicate?** A higher **Weight** notification for the same record and recipients won.
7. **Bounced address?** **System Logs > Bounce Email Addresses**: blocked after repeated bounces.

## How retries work

Failures with 4xx codes are retried at intervals of 1, 5, 10, 20, 40, 60, 120, 120 minutes until `glide.email.smtp.claim.lookback.hrs` (24) has passed. 5xx codes are permanent failures.

## How to confirm the cause

The **Email diagnostics dashboard** (**System Notification > Email > Email notifications dashboard > Diagnostics**) shows the last six hours: queue (send-ready, retry), throughput, latency, failed jobs, top errors, hard and soft bounces, blocked addresses, and connection status of each account. The notifications dashboard itself needs its data collection jobs configured first (**Platform Analytics Administration > Indicators > Automated Indicators**, *Email Notifications Sent* and *Email Notifications Created*).

## Known cases the guide points to

| Symptom | Pointer |
|---|---|
| Email from Outlook creates an empty incident with `winmail.dat` | stop the Outlook client or Exchange sending Rich Text Format to the instance |
| Emails set to send-ignored for no obvious reason | KB0790932 |
| Duplicate emails | KB0529413 |
| SMTP Sender or Email Reader job stuck | KB0755061, KB0679998, KB0755063 |
| Connection to smtp.office365.com failed | KB0825391 |
| IMAP with OAuth: AUTHENTICATE failed | KB0963959 |
| Instance not receiving / not sending | KB0524472, KB0520595 / KB0521382 |

## Related

- [[Email Notifications]] · [[Email Architecture and Accounts]] · [[Email Filters, Address Filters and Bounce Management]]
