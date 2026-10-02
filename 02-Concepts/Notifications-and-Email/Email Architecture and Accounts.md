---
type: concept
tags: [concept, email, notifications, admin]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Email Administration" (pp. 2391-2410, 2458-2466), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Email architecture and accounts

**In one line:** an instance sends mail through **one** active SMTP account and reads mail from one or more POP3 or IMAP accounts; every message, in or out, is a record in Email (`sys_email`).

## Out of the box

- Each instance has the address `<instance>@service-now.com`, with a ServiceNow-managed **SMTP** account (sending) and **POP3** account (receiving). These two accounts cannot be modified, only deactivated.
- Basic email is on when both properties are true: `glide.email.smtp.active` (*Email sending enabled*) and `glide.email.read.active` (*Email receiving enabled*), under **System Properties > Email Properties**.
- ServiceNow's mail servers add opportunistic TLS, spam scoring and virus scanning (headers `X-ServiceNow-Spam-Status`, `X-ServiceNow-Virus:INFECTED`). Those are **not** available when you use your own mail servers.

## Email accounts

**System Mailboxes > Administration > Email Accounts** (table `sys_email_account`). Role admin or `email_account_admin`.

- **Only one SMTP account can be active at a time**; all outbound mail goes through it. Several POP3 and IMAP accounts can be active for receiving.
- **Mail read from a POP3 or IMAP account is deleted from that mailbox** after being stored in `sys_email`. Give the instance a mailbox of its own.
- Types: SMTP, POP3, IMAP, Microsoft Graph (Receive), Microsoft Graph (Send). Authentication: None, Password, OAuth 2.0 (plugin `com.glide.email.oauth`; IMAP and SMTP only, not POP3).
- Key fields: **Server**, **User name** (also the From address for SMTP), **From** (overrides User name; a notification's own From overrides both), **Email user label** (sender display name), **Connection Security** (None, STARTTLS, SSL/TLS: prefer SSL/TLS), **Port**, **System Address Filter**, **Enable debug output** (raw exchange in node logs: **System Logs > Utilities > Node Log File Browser**).
- **Test Connection** related link checks an account.
- An SMTP server on localhost or 127.0.0.1 is not accepted.

## Message states

| Direction | Flow |
|---|---|
| Inbound | lands in **Inbox**, becomes **Received**; then **Processed** if an inbound email action matched, otherwise **Ready** |
| Outbound | waits in **Outbox**, then **Sent**, or **Skipped** (e.g. no valid recipient) |

View them under **System Mailboxes** (Inbox, Outbox, Sent, and others). During a restart or upgrade, inbound mail waits on the mail server and outbound mail waits in the database.

## Size limits

- ServiceNow mail servers: about **50 MB before encoding**, 75 MB after, per message including attachments. Own servers may differ.
- Body: 524,288 characters by default (`glide.email.inbound.max_body_chars`, `glide.email.outbound.max_body_chars`). An inbound email over the limit is truncated, set to *received-ignored* and **no inbound action runs**; an outbound one is not sent.
- Attachments: 30 per email and 18,874,368 bytes in total, each direction (`glide.email.<inbound|outbound>.max_attachment_count`, `...max_total_attachment_size_bytes`). Excess inbound attachments are discarded (logged in `sys_email_attachment`, event `inbound.email_attachments.discarded`); excess outbound ones are left off and a warning is logged. `com.glide.attachment.max_size` caps everything.
- A scheduled report or list export too large to attach is emailed without the attachment.

## Things to know

- **Email is switched off on a cloned instance** so delivered mail is not resent ([[Instance Clone Overview]]).
- Instances keep processing mail during an upgrade.
- For instance-to-instance communication use web services, not email.
- Outbound mail older than 24 hours is not sent (`glide.email.smtp.claim.lookback.hrs`); raise it in steps to drain a backlog.

## Checklist after enabling email (from the guide)

1. In sub-production, send everything to a test address: `glide.email.test.user`.
2. Review the baseline notifications, templates and inbound email actions.
3. Decide on email layouts, email filters, a retention policy, and watermarks.
4. Decide whether unknown senders create users (`glide.pop3readerjob.create_caller`, `glide.user.trusted_domain`).
5. Consider `glide.smtp.precedence_bulk` (mail is sent as bulk by default) and a spam filter on custom addresses.

## Many mailboxes

The email reader job (every two minutes) processes accounts one after another. For many accounts, create **Email Account Groups** (`sys_email_account_group`), set `glide.email.inbound.account_group_processing` = true, and if needed add another reader by inserting a copy of the *Email Reader* job in `sys_trigger`. Each group shows **Status** (Claimed, Unclaimed), **Last Processed**, **Processing Duration**.

## Personal corporate mailboxes

Plugin `com.glide.email.user_mailbox.integration`: a user (role `user_email_account`) connects their own company mailbox under **Preferences > Notifications > Advanced Preferences > Delivery Channels**, using a server configuration and template defined by an admin under **User Mailboxes > Administration**.

## Related

- [[Email Properties Reference]] · [[Email Filters, Address Filters and Bounce Management]] · [[Set Up Email with Your Own Mail Servers]] · [[S-MIME Email Encryption]]
