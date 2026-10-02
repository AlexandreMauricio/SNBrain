---
type: concept
tags: [concept, email, forms-lists]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Email client" (pp. 2631-2654), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Email client

**In one line:** a compose window opened from a record (form **More options > Email**, or a workspace) that sends an email tied to that record; admins control recipients, From addresses, templates and quick messages.

## Basics

- Plugin Email Client (`com.glide.email_client`), active by default. Users need the role `email_composer`.
- Enabled by default on Incident and Change. Other tables need the dictionary attribute `email_client=true` on the table's **collection** entry. **Not inherited by child tables.** See [[Enable the Email Client for a Table]].
- The subject box allows more characters than `sys_email.subject`; if subjects are truncated, raise that column's **Max length**.

## Configuration pieces (application menu Email Client)

| Piece | Table | Purpose |
|---|---|---|
| Email client configuration | `sys_email_client_configuration` | **one per table**: recipient qualifiers, show From / Reply-To, attachment handling, address filters, **To is optional** |
| Recipient qualifier | `sys_recipient_qualifier` | what the To/Cc/Bcc auto-complete searches: table, email and display-name fields, extra display fields to tell namesakes apart, and a condition or script (`recipientQuery`, `targetRecord`). Defaults: active users and active groups with email |
| From address | `sys_email_client_from_address` | allowed From addresses |
| Email client template | `sys_email_client_template` | default subject, body, recipients and sender per table and condition |
| Quick message | `sys_email_canned_message` | reusable snippets inserted at the cursor |

Attachment handling: **Attach to Target Record** (default), **Attach to Email Record**, or **Conditionally Attach to Target Record**. Status in `sys_email_attachment`.

## Templates

- Chosen by table, **Conditions** and lowest **Execution Order**. Conditions only apply on initial load.
- Body: `${field}` variables, `${current_user}`, `${mail_script:name}`. Line breaks of multi-line fields are not kept.
- **To / Cc / Bcc**: comma-separated field names or addresses, or a single `javascript:` expression calling a script include that returns a comma-separated string. The same address cannot be in two of them.
- **From Generation Type**: None, SMTP Email Account, Select From List, Script (query on the From address table with `fromAddressQuery`, `targetRecord`), Text, User Email Addresses (plugin `com.glide.email.user_mailbox.integration`). A From domain different from the SMTP account's needs an **SPF** record on that domain.
- **Response templates** (reply, reply all, forward; received or sent) are templates on `sys_email` with conditions; workspace only for the attachment option.
- Unsaved form changes are reflected in the composed body, up to 2,000 characters in total.

## Quick messages

**Email Client > Quick Messages**. Restrict by **User**, **Group**, **Table**, **Conditions**. Role `email_client_quick_message_author` lets managers write them. Attachments on a quick message are not sent. `glide.email_client.quick_message.insert` = false makes a quick message replace the whole draft.

## Roles

`email_composer` (use; contains `email_client_template_read`), `email_client_admin` (configure; contains quick message author and `email_client_template_write`), `email_client_template_write` (includes scripting, grant with care).

## Other

- SMS option in the client: `glide.email_client.show_sms_option` = true; falls back to the primary email device.
- International (non-ASCII) addresses: `glide.email_address.rfc6530.enabled`, only if the SMTP server supports SMTPUTF8. Related: `glide.email_address.inbound.rfc6530`, `glide.inbound.rfc6530.support.encoded.from.address`, `glide.inbound.rfc6530.supported.encoding.formats`.

## Related

- [[Email Architecture and Accounts]] · [[Email Templates, Layouts and Calendar Invitations]] · [[Mail Scripts]] · [[Create an Email Client Template]]
