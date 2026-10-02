---
type: concept
tags: [concept, email, scripting, incident, flows]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Inbound email" (pp. 2655-2685), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Inbound email actions

**In one line:** when the instance receives an email it classifies it as **forward**, **reply** or **new**, then runs inbound email **flows** and, after those, inbound email **actions** whose type, table and conditions match, to create or update records or to reply.

## Processing order

1. The email reader job (every two minutes) downloads mail and creates `email.read` events.
2. The email is classified (below).
3. **Inbound email flows** (Workflow Studio, **Flow Designer > Inbound Email Flows**) are tried first. A flow can stop processing.
4. If no flow stops it, **inbound email actions** (**System Policy > Email > Inbound Actions**, rules table `sysrule`) run in ascending **Order**.
5. Every email that went through this ends in state **Processed**, even when nothing matched.

## Classification

| Order | Type | Criteria |
|---|---|---|
| 1 | **Forward** | subject has a forward prefix (`fw:`, `fwd:`) **and** the body contains a forward string such as `From:`. Wins even if a watermark or record number is present |
| 2 | **Reply** | not a forward, and any of: a **watermark** (`Ref:MSG...`) in subject or body; no watermark but a reply prefix (`RE:`) plus a recognised record number in the subject; an In-Reply-To header matching a watermarked email; (optional) an Outlook thread-index header, with `glide.inbound.email.classify.by.thread_index` = true |
| 3 | **New** | everything else |

With several watermarks in the body, the last one counts.

## When an action runs

All three must hold: the email type equals the action's **Type**; a watermark or record number, if present, refers to a record of the action's **Target table**; the **Condition** is true. Otherwise the next action is evaluated.

Default actions on Incident:

| Type | Action | Result |
|---|---|---|
| New | Create Incident | new incident; `caller_id` and `opened_by` = the user matching the sender |
| Reply | Update Incident (BP) | updates the matched incident |
| Forward | Create Incident (Forwarded) | **new incident**, even with a watermark |

To treat forwards as replies: put the forward prefixes into `glide.email.reply_subject_prefix` (`re:,Re:,RE:,aw:,r:,fw:,fwd:,Fwd:,FWD:`) and set `glide.email.forward_subject_prefix` to any other text (it must not be empty).

## Record number matching (no watermark)

| Subject | Result |
|---|---|
| `RE: Example INC0005574` | reply; updates that incident if it exists, else a new incident |
| `RE: Example "INC0005574"` or `*INC0005574` or `INC0005574*` | **not matched**: any character other than a space next to the number breaks it; a new incident is created |
| `RE: CHG0008593 and INC000576` | unpredictable which one is matched. Do not put more than one `${number}` in a notification |
| `FW: Example INC0005574` | forward: new incident |
| `Example INC0005574` | new (no reply prefix): new incident |

## Who the action runs as

- The sender's address (`email.from`) is matched to an **active** user; the action runs **impersonating that user**, so they need write access to what the action touches.
- No match: runs as **Guest**. If the impersonated user is locked out, the action fails, unless `glide.pop3.process_locked_out` is true (which also lets untrusted domains trigger actions).
- **Email addresses should be unique per user**; with duplicates the match is arbitrary among active users.
- Auto-create users for unknown senders: `glide.pop3readerjob.create_caller` = true and `glide.user.trusted_domain` (no wildcards such as `*.edu`). The User ID becomes the full email address (plugin Email Automatic User Creation, `glide.email.create_userid_from_email`).
- To stop strangers creating records: a system address filter, or lock out the **guest** user.
- The domain of the action record is ignored: a created incident lands in the caller's domain. Keep inbound actions in global.

## The script

```javascript
(function runAction(/*GlideRecord*/ current, /*GlideRecord*/ event, /*EmailWrapper*/ email, /*ScopedEmailLogger*/ logger) {
    current.comments = "reply from: " + email.origemail + "\n\n" + email.body_text;
    if (email.body.priority != undefined)
        current.priority = email.body.priority;
    current.update();
})(current, event, email, logger);
```

| Object | Use |
|---|---|
| `current` | the target record (new or matched) |
| `email` | `email.subject`, `email.body_text`, `email.body_html`, `email.from`, `email.from_sys_id`, `email.origemail`, `email.to`, `email.direct` (To), `email.copied` (Cc), `email.recipients`, `email.recipients_array`, `email.headers`, `email.importance`, `email.content_type` |
| `email.body.<name>` | value of a `name:value` line in the body. The name is lower-cased, spaces become underscores, the pair must be on its own line. Does not work on reference fields |
| `event` | the event; `event.state = "stop_processing";` stops further actions |
| `logger` | `logger.log("text")` writes to the email log |
| `sys_email` | the received email record |

Route by recipient when several mailboxes forward to the instance:

```javascript
if (email.direct.indexOf('facilities@example.com') > -1)
    current.assignment_group.setDisplayValue('Example Facilities Team');
```

## Other facts

- Attachments go to the first record the action produces. With Column Level Encryption on the target table, they are encrypted; from a sender without access they stay on the email record.
- Give each action a **unique Order**; with equal orders, *Stop processing* may not stop the others.
- **Reprocess**: open a `received` or `received-ignored` email and select **Reprocess email** (or the list action), after fixing the action.
- **Sensitive data redaction**: plugin `com.glide.email_inbound.redaction` plus Data Discovery; the action's **Redact sensitive data** masks things like card numbers in the stored email after processing. Irreversible.
- `gs.createUser()` is no longer supported in these scripts.

## Related

- [[Create an Inbound Email Action]] · [[Email Watermarks, Digests, Retention and Translation]] · [[Email Properties Reference]] · [[Inbound Email Flow or Inbound Email Action]]
