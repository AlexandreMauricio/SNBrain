---
type: concept
tags: [concept, notifications, email]
status: documented
source: ServiceNow Australia Platform Administration PDF, "System notifications", topics "Email templates", "Calendar integration", "Email layouts" (pp. 2539-2550), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Email templates, layouts and calendar invitations

**In one line:** a **layout** wraps every email in common HTML (header, footer, styles, unsubscribe links), a **template** holds a reusable subject and body, and a **notification** picks a template and may override it.

## The three levels

| Level | Table | Module | Holds |
|---|---|---|---|
| Email layout | `sys_email_layout` | **System Policy > Email > Layouts** | static HTML around the body; `${notification:body}` marks where the body goes. Styles in a `<style>` element or inline. No dynamic content (no mail scripts) |
| Email template | `sysevent_email_template` | **System Notification > Email > Templates** | **Subject**, **Message HTML**, **Message Text**, **SMS alternate**, **Table**, optional **Email layout**. Variables and mail scripts allowed |
| Notification | `sysevent_email_action` | **System Notification > Email > Notifications** | **Email template**, and its own Subject or Message that override the template's |

- A common pattern: body in the template, a different subject per notification.
- A notification can only use a template in the same scope with the same table or no table, or a global-scope template on the same table.
- If neither the notification nor the template has content, the layout is not applied.
- HTML cannot restyle what `${comments}` prints.
- Blank lines: `<br/>` or wrap paragraphs in `<p>`.

## Reply links (mailto templates)

A template can contain `${mailto:...}` items that build a pre-addressed reply. The base approval flow uses them: a change approval inserts a row in the approval table, the business rule *approval events* fires `approval.inserted`, the notification *Approval Request* uses the template `change.itil.approve.role`, which includes `mailto.approval` and `mailto.rejection`. The recipient clicks *approve* or *reject*, the mail client opens a ready-made reply, and an inbound action processes it.

## Calendar invitations (iCalendar)

- Notification **Type** = *Meeting Invitation*, **Content type** = *Plain text only*, and a template whose **Message Text** is an iCalendar block.
- Variables come from an **import export map** (`sys_impex_map.list`) named `icalendar.<table>` of type icalendar: `${dtstart}`, `${dtend}`, `${location}`, `${alarm_time}`. Base maps exist for Appointment (`itil_appointment`) and Change Request (`dtstart` = `start_date` Planned start date, `dtend` = `end_date` Planned end date).
- To use other date fields, edit the map's field maps. For a custom table, create the map with `dtstart` and `dtend` (both required), then the template:

```text
BEGIN:VCALENDAR
PRODID:-//Service-now.com//Outlook 11.0 MIMEDIR//EN
VERSION:2.0
METHOD:REQUEST
BEGIN:VEVENT
ATTENDEE;ROLE=REQ-PARTICIPANT;RSVP=TRUE:MAILTO:${to}
DTSTART:${dtstart}
DTEND:${dtend}
UID:${sys_id}
DTSTAMP:${dtstamp}
SUMMARY:${u_example_summary}
END:VEVENT
END:VCALENDAR
```

- Mail scripts are not processed in meeting invitation templates. The summary must have no line breaks.
- Users only get invitations if **Calendar integration** on their user record is Outlook.

## Related

- [[Email Notifications]] · [[Notification Variables and Links]] · [[Inbound Email Actions]]
