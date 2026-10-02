---
type: concept
tags: [concept, scripting, notifications, email, glide-api]
status: documented
source: ServiceNow Australia Platform Administration PDF, "System notifications", topics "Scripting for email notifications", "Mail script variables", "Example scripting for email notifications", "Advanced conditions for email notifications" (pp. 2496-2497, 2512-2515), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Mail scripts

**In one line:** a mail script is server-side JavaScript that runs while a notification is being built, to print dynamic content into the email or change its sender, subject, body and recipients.

## How it works

- Stored in Email Script (`sys_script_email`), managed at **System Notification > Email > Notification Email Scripts**.
- Embedded in a notification, template or layout with `${mail_script:script_name}`. With the HTML sanitizer configured, use `${{mail_script:script_name}}` so the output is sanitised.
- Typing `<mail_script> ... </mail_script>` directly in the body prompts to convert it into an Email Script record.
- One script can be reused in many notifications.

## Objects available

| Object | What it is |
|---|---|
| `current` | the record the notification is about |
| `template` | prints to the body: `template.print("text")`, `template.space(n)` |
| `email` | the outbound email: `setSubject()`, `setBody()`, `setFrom()`, `setReplyTo()`, `addAddress("cc" or "bcc", address, displayName)` |
| `email_action` | the notification record (`sysevent_email_action`) |
| `event` | the event that fired it (`sysevent`), with `event.parm1` and `event.parm2` |

`setFrom` and `setReplyTo` take `address` or `Display Name <address>`.

## Examples

Print a list of related records:

```javascript
template.print("Summary of requested items:<br />");
var item = new GlideRecord("sc_req_item");
item.addQuery("request", current.sysapproval);
item.query();
while (item.next()) {
    template.print(item.number + ": " + item.quantity + " x " + item.cat_item.getDisplayValue() + "<br />");
}
```

Copy the watch list in CC:

```javascript
if (!current.watch_list.nil()) {
    var user = new GlideRecord("sys_user");
    user.addQuery("sys_id", current.watch_list.split(","));
    user.addQuery("notification", 2);       // email enabled
    user.addQuery("email", "!=", "");
    user.query();
    while (user.next())
        email.addAddress("cc", user.email, user.getDisplayValue());
}
```

Link to the record in a workspace (`${URI}` does not do this):

```javascript
var url = gs.getProperty('glide.servlet.uri') + 'now/workspace/agent/record/' + current.getTableName() + '/' + current.sys_id;
template.print('<a href="' + url + '">' + current.number + '</a><br />');
```

Change the sender and subject:

```javascript
email.setFrom(current.caller_id.email);
email.setSubject("Placeholder subject");
```

## Advanced condition (related, on the notification itself)

Decides whether to send at all. Return true or set `answer`:

```javascript
(function() {
    return !gs.getUser().isMemberOf('Example Group');
})();
```

## Related

- [[Email Notifications]] · [[Notification Variables and Links]]
