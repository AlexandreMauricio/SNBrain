---
type: concept
tags: [concept, notifications, email, data-management]
status: documented
source: ServiceNow Australia Platform Administration PDF, "System notifications", topics "Email retention", "Watermarks on notification emails", "Parse an email thread", "Email digests", "Multilingual email notifications", "Domain separation and Notifications" (pp. 2551-2571), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Email watermarks, digests, retention and translation

**In one line:** four supporting features of notification email: the **watermark** that ties replies to records, **digests** that batch notifications, **retention** that archives old email, and **translation** into the recipient's language.

## Watermarks

- Every notification email ends with `Ref:` followed by a 31-character label: prefix (**MSG** by default), an auto-number, an underscore, and a random string (random since Jakarta, so it cannot be guessed).
- An inbound reply carrying the watermark is matched to the source record.
- Configure:
  - **Prefix per instance**: **System Definition > Number Maintenance**, the MSG record of Email Watermark (`sys_watermark`). Different prefixes for dev, test and prod stop a forwarded mail triggering the wrong instance. No colons.
  - **Omit** on one notification: **Omit watermark** (Advanced view).
  - **Hide** everywhere in HTML: `glide.email.watermark.visible` = false. Plain-text versions always show it.
- **Without a watermark, the system looks for a record number in the subject and body** and updates that record. To prevent replies updating records, also remove `${number}` from the subject and body.

## Reply separators

**System Policy > Email > Email Reply Separators**: strings or regular expressions that mark where the newest message ends in a thread, so only the latest reply is used. Ordered; per language. A regex that takes over 10 seconds is skipped.

## Digests

- One email summarising a notification's activity over an interval, instead of many emails. Email only (not SMS, push or activity streams). Plugin `com.glide.email_digest`, on by default.
- Admin: tick **Allow Digest** on the notification, choose **Digest type** (*Single target record* or *Multiple target record*), optionally **Enable by default** and a **Default Interval**, and fill the digest tab.
- User: enables the digest and picks the interval in notification preferences. A user who is not a recipient gets no digest.
- Intervals: **System Notification > Email > Digest Intervals** (`sys_email_digest_interval`); shipped: 1 hour, 4 hours, 1 day, 7 days. Minimum 1 hour, maximum 7 days.
- The interval starts at the first triggered notification; a job every 15 minutes sends digests whose interval has ended.

## Retention

- Plugin **Email Retention** (needs Data Archiving). Active on new instances; on upgraded ones activate the plugin **and** the rules after reviewing them.
- Default rules: archive email older than 365 days (or ignored) from `sys_email` to `ar_sys_email`; destroy archived email after another 365 days. **Two years in total.**
- Watermarks are never deleted, so inbound replies keep working.
- Side effects: once an email is archived, the activity formatter no longer shows its *Sent Email* entry, and the instance can no longer match replies by the In-Reply-To header (number and watermark still work).
- Do not run this alongside another email clean-up process (e.g. a table cleaner rule).
- Manual run: **System Archiving > Archive Rules**, the email rule, **Run Archive Now**.

## Translation

- Plugin **Glide Notification Translation** (`com.glide.notification.translation`).
- **Static**: a translator provides versions of Subject and Message for notifications, templates and layouts (**Request Translation** on the record, through the Localization Framework). Strings inside mail scripts must use `gs.getMessage()`. Not for meeting invitations.
- **Dynamic**: machine translation at send time. Tick **Enable Dynamic Translation** on the notification. A note banner on translated mail is configurable (`glide.email.translation.dynamic.note.*`).
- Both can combine: existing static translations are used, the rest is translated dynamically.
- `glide.email.translation.honour.user_preference` = true uses the user's preferred language. CC and BCC recipients' languages are ignored.
- A group with a **group email** address gets one language for everyone.

## Domain separation

Notifications are process-separated: a record change or event triggers notifications of the record's domain **and** of global. A domain notification for the same event as a global one sends two emails unless it **overrides** the global one. Email accounts are not domain-separated; inbound actions run in the sender's domain. Subscription-based notifications are not domain-aware.

## Related

- [[Email Notifications]] · [[Inbound Email Actions]] · [[System Archive and Archive Rules]]
