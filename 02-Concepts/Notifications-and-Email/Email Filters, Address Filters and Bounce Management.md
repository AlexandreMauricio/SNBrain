---
type: concept
tags: [concept, email, security, roles]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Email Administration", topics "Email bounce management", "System address filters", "Email filters", "Granular admin roles for Notifications" (pp. 2410-2417, 2466-2469, 2482-2484), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Email filters, address filters and bounce management

**In one line:** three separate mechanisms control which mail the instance accepts or sends: **system address filters** (allowed and denied domains per direction), **email filters** (ignore or junk inbound mail by condition), and **bounce management** (stop sending to addresses that keep bouncing).

## System address filters (who may send to or receive from the instance)

- **Email address filter** (**System Mailboxes > Administration > Email Address Filters**, `sys_email_address_filter`, role `email_account_admin`): a named **Allow List** or **Deny List** of domains, with **Exceptions** (addresses, `sys_email_address_filt_except`). Wildcards allowed (`*.com`). Domains are written without `@`. Limits: 100 domains and 1,000 exceptions per filter.
- **System address filter** (**System Address Filters**): combines address filters and has a **Type**: **Outbound** (who can receive mail from the instance, for SMTP) or **Inbound** (who can send to it, for IMAP and POP3).
  - One **Default** inbound and one default outbound filter apply automatically to all active accounts of that kind.
  - A non-default filter is applied by choosing it on an email account.
- **A domain or address is blocked only if it appears on a denied list and on no allowed list.**

## Email filters (what to do with an inbound email)

- **System Mailboxes > Administration > Filters** (plugin `com.glide.email_filter`, active by default since Kingston). Fields: **Order** (lower wins), **Conditions**, **Condition script**, **Action script**, and **Filter Actions**: *Mark as Ignored* or *Move to Junk*.
- An ignored email is still saved in `sys_email` but not processed.
- Shipped filters: *Ignore VCAL* (calendar replies, detected by the script include `EmailUtils`), *Ignore header*, *Ignore subject* (these two override `glide.pop3.ignore_headers` and `glide.pop3.ignore_subjects`), *Junk email - sender equals recipient*, *Move spam to junk folder* (header `X-ServiceNow-Spam-Status:Yes`).

## Bounce management

- A bounce is a delivery failure reported with a status code `class.subject.detail` (e.g. `5.1.1` = mailbox does not exist).
- An address is **blocked after 10 bounces** (default). Codes that count by default: `5.0.*`, `5.1.*`, `5.7.*`.
- View and unblock: **System Logs > Bounce Email Addresses**: set **State** to Unblock, then **Resend All Blocked Emails** (or select emails on the Blocked Emails tab). Fix the cause first.
- Tune which codes block: **System Mailboxes > Administration > Bounce Email Address Status** (Type blocked or unblocked, Class, Subject, Detail). Example: with `5.1.*` blocked, an *unblocked* entry for 5, 1, 2 exempts only `5.1.2`.
- Some providers use non-standard codes, which can block good addresses.
- The guide advises against disabling bounce management: providers may slow or block your mail.

## Granular admin roles

| Role | Access |
|---|---|
| `email_account_admin` | email accounts, address filters, account groups |
| `email_bounce_admin` | bounce tables |
| `email_log_viewer` | email logs and S/MIME logs |
| `smime_certificate_admin` | CA and email certificates |
| `email_digest_admin` | digest tables |
| `notification_admin` | notifications (`sysevent_email_action`), layouts (`sys_email_layout`), templates (`sysevent_email_template`) |
| `notification_category_admin`, `notification_classification_admin` | categories, classifications |
| `push_admin` | push credentials |
| `email_api_send` | use the Email API (with an ACL on `sys_email`) |

## Related

- [[Email Architecture and Accounts]] · [[Email Properties Reference]]
