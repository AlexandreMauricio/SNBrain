---
type: concept
tags: [concept, notifications, email, access-control]
status: documented
source: ServiceNow Australia Platform Administration PDF, "System notifications", topic "Email and SMS notifications" (pp. 2485-2503), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Email notifications

**In one line:** a notification record (`sysevent_email_action`) says **when** to send (record change, event, or flow step), **who** receives it, and **what** it contains; it can also go out as SMS, push, or inside a digest.

Module: **System Notification > Email > Notifications**. Role admin or `notification_admin`. Use the **Advanced view** to see all fields.

## When to send

| Field | Notes |
|---|---|
| **Send when** | *Record inserted or updated* (with **Inserted** and **Updated** check boxes), *Event is fired* (with **Event name**), or *Triggered* by the Notification step in Flow Designer |
| **Conditions** | condition builder on the notification's table |
| **Advanced condition** | script that must return true or set `answer = true`. Has `current` and `event`. **Evaluated in addition to Conditions: both must be true** |
| **Weight** | priority among duplicates (below) |

**Do not create notifications on the Task table itself**: it exists to be extended and notifications on it are not supported. Use the child table.

## Duplicates and weight

- Notifications with the same target record and recipients, triggered together, are treated as duplicates. **Only the one with the highest weight is sent**; the others go to the Skipped mailbox. With equal weights, they are duplicates only if subject and body are the same.
- Example: commenting on and then closing an incident triggers *Incident commented* and *Incident Closed*; the caller gets only the higher-weight one.
- Weight 0 (default) always sends, conditions permitting.
- The business rule *Ignore Duplicates* enforces this. The *SMTP Sender* job sends mail every minute.

## Who will receive

| Field | Notes |
|---|---|
| **Users** | fixed list of users or email addresses |
| **Users/groups in fields** | fields of the record that hold users, groups or an email address (e.g. **Opened by**); can dot-walk |
| **Groups** | fixed groups. Members get individual emails only if the group has **Include members** |
| **Send to event creator** | include the person whose action triggered it, **if they are a recipient anyway**. On by default for new notifications. The classic reason a tester does not receive their own notification is this box being cleared |
| **Exclude delegates** | do not send to delegates |
| **Event parm 1 / 2 contains recipient** | for event-based notifications, recipients passed in the event parameters |
| **Subscribable** | users may subscribe themselves. Avoid for sensitive records |

A recipient gets the email only if: the user is **active**, has a **valid email** on the primary notification device (`cmn_notif_device`), and has the notification enabled in their preferences.

**Notifications ignore ACLs.** A recipient can receive details of a record they cannot open in the UI. Check the content against the audience, or link to the record instead of including details.

More than 100 recipients are split into several emails (`glide.email.smtp.max_recipients`); the guide suggests keeping lists under 1,000. The instance never emails its own address.

## What it will contain

- **Email template** (optional, reusable content), **Subject**, **Message HTML**, **Message Text**; a value on the notification overrides the template.
- **Content type**: HTML only (default), HTML and plain text, Plain text only.
- **SMS alternate**: up to 140 characters; otherwise the subject is the SMS text.
- **From** and **Reply to**: override the instance address (may need forwarding or SPF on your side).
- **Include attachments**: all attachments of the triggering record.
- **Omit watermark**, **Importance**, **Push message only**, **Push messages**.
- **Category**: where users find it in their preferences. Do not leave it *Uncategorized*.
- **Allow Digest**: adds the *What Digest will contain* tab (digest subject, HTML, separator, from, reply to).
- **Type**: EMAIL or Meeting Invitation.
- Content uses [[Notification Variables and Links|variables]] and [[Mail Scripts|mail scripts]].
- New notifications use the rich HTML editor; old ones are converted with **Switch to Rich HTML Editor** (inline mail scripts move to `sys_script_email`).

## Useful administration

- **Preview Notification** (form header): shows subject and body for a chosen record or event, and the recipient list with excluded users struck through in red and the reason on hover.
- **Different From address per desk or language**: copy the notification, set **From** (and **Reply to**), and give the copies mutually exclusive conditions (e.g. on Company, or on the recipient's **Language** through related fields).
- **Restrict who can read the generated email records**: **System Notification > Email Access Restriction** (`email_access_restriction`): pick the notification and a condition.
- Time stamps use the **system** time zone; `glide.email.append.timezone` appends it.
- Categories: **System Notification > Email > Notification Categories** (`sys_notification_category`).

## Related

- [[Create an Email Notification]] · [[Notification Variables and Links]] · [[Mail Scripts]] · [[Email Architecture and Accounts]]
