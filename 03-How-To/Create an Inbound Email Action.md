---
type: how-to
tags: [how-to, email, scripting]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Inbound email", topics "Create an inbound email action", "Configure the processing order", "Manage multiple filters", "Inbound email action examples" (pp. 2671-2684), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Create an inbound email action

**Goal:** make the instance create or update a record, or reply, when an email of a given kind arrives.
**Prerequisites:** role admin. Email receiving enabled.
**Navigation:** All > System Policy > Email > Inbound Actions

## Steps

1. Open **System Policy > Email > Inbound Actions** and select **New**.
2. **When to run**: **Name**, **Target table**, **Action type** (*Record Action* or *Reply Email*), **Type** (New, Reply, Forward), **Order**, optional **Required roles**, **From** (a specific sender) and **Condition**. Tick **Active**.
3. **Actions**: use **Field actions** for simple field mapping, and/or write the **Script** inside the provided `runAction` wrapper, ending with `current.insert()` or `current.update()`.
4. To stop later actions when this one runs, tick **Stop processing** (or add `event.state = "stop_processing";`).
5. Submit.

## Result / how to check it worked

Send a test email to the instance. Find it under **System Mailboxes > Inbox / Received** or **System Logs > Emails**; its **Email Log** related list says which actions ran or were skipped and why. To retry after a fix, **Reprocess email**.

## Example

Route by subject prefix, each action with its own order:

| Order | Type | Target table | Condition | Stop processing |
|---|---|---|---|---|
| 100 | New | Change Request | `email.subject.indexOf("Change Request: ") == 0` | yes |
| 200 | New | Problem | `email.subject.indexOf("Problem: ") == 0` | yes |
| 300 | New | Incident | (none) | no |

Script for the problem action:

```javascript
current.description = email.body_text;
current.short_description = email.subject.toString().substring(9);
current.assignment_group.setDisplayValue("Example Group");
if (email.body.assign != undefined)
    current.assigned_to = email.body.assign;
current.insert();
```

An email whose subject starts with *Problem:* creates a problem and stops; anything unmatched becomes an incident.

## Tables / fields involved

- `sysrule`: inbound actions (the **Order** column comes from the Ordered Email Processing plugin)
- [[sys_email]]: the received email; `sys_watermark`: watermarks

## Other ways to do this

[[Inbound Email Flow or Inbound Email Action]]

## Gotchas

- The action runs as the sender (or Guest): they need rights on the target table.
- Use **unique Order values**.
- A forward creates a new record by default even when it carries a watermark.
- If the user in **From** is later deleted or archived, the restriction disappears and anyone can trigger the action.
- A body over the size limit, or an undecryptable S/MIME message, is ignored and no action runs.
- Background: [[Inbound Email Actions]].
