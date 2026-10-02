---
type: concept
tags: [concept, notifications, workspace]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Provider notifications" (pp. 2617-2630), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Provider notifications

**In one line:** a newer notification framework, separate from email notifications, that delivers through **providers** (Next Experience banners, Workspace, Virtual Agent) and can carry **action buttons**.

## Terms

| Term | Meaning |
|---|---|
| Provider | the implementation that delivers to one channel |
| Channel | a communication mechanism with the recipient |
| Destination type | a category of destination for a channel; carries the **sent by default** flag (opt-out when true, opt-in when false) |
| Destination | one recipient's actual contact point |

Delivery precedence: the recipient's preference for the notification, then their preference for the destination, then the destination type's default. **Groups are not supported as recipients** directly (an assignment-groups related list exists on the notification).

## The notification record

**System Notification > Provider > Notifications** (roles admin and notifications provider admin). Similar to an email notification: **Category**, **Table**, **Triggered by** (Record Change with Inserted/Updated, or Event), **Conditions**, recipients (**Users**, **Recipients in fields**, event parm1/parm2 with a table to resolve the sys_ids, originator), **Advanced condition** script (`current`, `event`; must return true or set `answer`).

- Recipients can come from tables other than `sys_user`: related list **Additional Recipients** (one active record per recipient table, static list or dynamic conditions).
- A notification needs **content** to be delivered: common (shared) content or provider content; content records live in `sys_notification_content` and one can be the **default**.
- **Mandatory** (add the field to the form): users cannot switch it off. Property `glide.notification.provider.mandatory.honor_auto_opt_in` = true makes auto opt-in win over mandatory.

## Next Experience in-product notifications

Create the notification, then on **Contents** select **New Provider Content > Next Experience**: **Message Heading** and **Message** accept `${field}` variables, and a route. Users see a toast banner and an entry in the Notifications menu. Sent items are listed in `ui_notification_inbox`. Not supported in the legacy Agent Workspace.

Duplicates: the notification has both a Next Experience and a Workspace content provider; remove one.

## Actions

Related list **Notification Actions > New Provider Action** (`sys_notification_action`), types:

- **Scriptable Action**: a script, plus an acknowledgement message.
- **Flow Action**: a flow *or* an action, optionally async; an **Inputs** script returns JSON key/values.
- **Virtual Agent**.

Then **Link Actions to Content** ties an ordered set of actions to a content record. Actionable content applies only to the Virtual Agent and Workspace providers.

## Example

Heading `${number} changed`, message `Short description: ${short_description}` on a record-change notification for Incident.

## Related

- [[Email Notifications]] · [[Notification Preferences and Channels]] · [[Push and Messaging App Notifications]]
