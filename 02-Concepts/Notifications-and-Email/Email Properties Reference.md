---
type: reference
tags: [reference, email, notifications, platform]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Email Administration", topic "Email properties" (pp. 2438-2456), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Email properties reference

Navigation: **System Properties > Email Properties** (or **System Mailboxes > Email Properties**) for the labelled ones; the "advanced" ones must be added to `sys_properties`. They apply to all email accounts. Concepts: [[Email Architecture and Accounts]]. Grouped and paraphrased.

## Sending

| Property | Default | Notes |
|---|---|---|
| `glide.email.smtp.active` | true | master switch for sending |
| `glide.email.test.user` | none | comma-separated addresses that receive **all** outbound mail. For non-production testing |
| `glide.email.append.timezone` | true | append the time zone to dates in sent mail |
| `glide.email.watermark.visible` | false | watermark visible, or hidden in a div |
| `glide.smtp.defer_retry_ids` | 421,450,451,452 | SMTP codes that cause a resend |
| `glide.smtp.fail_message_ids` | 500-504, 550-554 | SMTP codes that stop resending |
| `glide.smtp.default_retry` | true | resend on unknown SMTP codes |
| `glide.email.journal.lines` | 3 | journal entries included in notifications; -1 = all |
| `glide.email.smtp.max_recipients` | 100 | recipients per email; more are split into several emails |
| `glide.email.smtp.max_recipients_overall` | 100000 | overall cap |
| `glide.email.smtp.max_send` | 100 | emails per SMTP connection |
| `glide.smtp.send_partial` | true | send to valid recipients, retry the invalid ones separately |
| `glide.smtp.precedence_bulk` | true | adds `Precedence: bulk`; some spam filters dislike it |
| `glide.email.outbound.header.auto_submitted` | auto-generated | value of the `Auto-submitted` header; clear to remove it |
| `glide.email.override.url` | instance URL | base URL for links in emails; should end in `nav_to.do` |
| `glide.email.mail_to` | active SMTP address | address used by `${mailto:}` |
| `glide.smtp.dateformat`, `glide.smtp.timeformat` | sender's formats | date and time format in outgoing mail |
| `glide.email.notification.save_when_no_recipients` | false | keep the email record even with no recipients (debugging) |
| `glide.email.smtp.claim.lookback.hrs` | 24 | older outbound mail is not sent |
| `glide.email.outbound.static_translation.enabled`, `glide.notification.translation.dynamic` | true | notification translation |

## Receiving

| Property | Default | Notes |
|---|---|---|
| `glide.email.read.active` | true | master switch for receiving |
| `glide.email.reply_subject_prefix` | `re:,aw:,r:,Accepted:,Tentative:,Declined:` | prefixes that mark a reply. **Case-sensitive**: add `RE:`, `Re:` and so on |
| `glide.email.forward_subject_prefix` | `fw:,fwd:` | prefixes that mark a forward. Case-sensitive too |
| `glide.pop3readerjob.create_caller` | false | create a user for an unknown sender (from a trusted domain); otherwise the caller is Guest |
| `glide.user.trusted_domain` | servicenow.com | domains whose senders may be auto-created; `*` = all |
| `glide.user.default_password` | password | initial password of auto-created users (must reset) |
| `glide.pop3.parse_start`, `glide.pop3.parse_end` | none | markers of the body section parsed for `name:value` pairs |
| `glide.email.name_split` | `.` | delimiter used to match `first.last@` to a user |
| `glide.email.inbound.calendar_behavior` | Attach | calendar data: Attach, Ignore or Inline |
| `glide.email.inbound.convert_html_inline_attachment_references` | true | show inline images in the HTML preview |
| `glide.email.inbound.generate.missing.html.part` / `.text.part` | true | build the missing HTML or text part |
| `glide.email.inbound_action_set_email_ignored_when_user_disabled` | true | ignore mail when the acting user is inactive or locked out |
| `glide.email.allow_duplicate_message_ids` | false | store emails with duplicate message IDs |
| `glide.email.remove_illegal_address_quotes` | false | strip stray quotes from sender addresses |
| `com.glide.email.max_read` | 20 | emails a POP3 reader processes concurrently |
| `glide.email.inbound.attachment_extensions_blacklist` | | block attachment extensions |
| `glide.security.file.mime_type.validation.inbound_email` | false | validate attachment MIME types |

## Inbound images

| Property | Default | Notes |
|---|---|---|
| `glide.email.inbound.image_sys_attachment.filter.minimum_bytes` | 0 | images below this size are filtered; 0 disables filtering |
| `glide.email.inbound.image_sys_attachment.filter.action` | AttachEmail | AttachTarget (attach to the target record), AttachEmail (attach to the email only), AttachNone |

Stops signature logos piling up as attachments on the target record.

## Limits and safety

| Property | Default |
|---|---|
| `glide.email.inbound.max_body_chars`, `glide.email.outbound.max_body_chars` | 524288 |
| `glide.email.inbound.max_attachment_count`, `glide.email.outbound.max_attachment_count` | 30 |
| `glide.email.inbound.max_total_attachment_size_bytes`, `glide.email.outbound...` | 18874368 |
| `glide.email.inbound.check_attachment_availability`, `glide.email.outbound...`, `glide.email.email_client...` | true (block virus-infected attachments) |
| `glide.email_address_filter.max_domains` / `max_exceptions` | 100 / 1000 |
| `glide.email_system_address_filter.max_address_filters` | 100 |

## Display

| Property | Default | Notes |
|---|---|---|
| `glide.ui.activity.email_roles` | itil | roles that see emails in the activity formatter |
| `glide.ui.activity.email.use_display` | false | show user names instead of addresses in headers |
| `glide.ui.incident_activity.max_addresses` | 5 | addresses listed in an email audit record |
| `glide.email.email_with_no_target_visible_to_all` | true | emails without a target record are visible to everyone; false restricts to sender and admin |
| `glide.email.text_plain.strip_xhtml` | true | convert XML to plain text in comments |
| `glide.ui.email_client.email_address.disambiguator` | name | user columns shown in email client auto-complete |

## Recipient logging (why someone did or did not get an email)

`glide.notification.recipient.include_logging` and `glide.notification.recipient.exclude_logging` (both true) switch on the detailed properties below them: included because of delegate, event parm, recipient fields, group membership or manager, users list, subscription; excluded because the device is inactive or out of schedule, the user is the event creator, the email is invalid, the user is inactive, or notifications are disabled on the user.

## Digests and other

`glide.email.digest.default_interval` (sys_id of the default digest interval), `glide.email.digest.max_intervals` (100), `NotifyAffectedCI.max_rel_level` (5; parent CI levels notified by the *Affected ci notifications* business rule), `glide.cms.use_email_override_url`.

## Related

- [[Email Architecture and Accounts]]
