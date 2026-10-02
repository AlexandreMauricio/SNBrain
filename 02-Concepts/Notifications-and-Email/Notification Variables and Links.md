---
type: reference
tags: [reference, notifications, email]
status: documented
source: ServiceNow Australia Platform Administration PDF, "System notifications", topics "Notification variables", "Links to records in email notifications", "Email unsubscribe links", "Document attachments on an email notification" (pp. 2498-2512), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Notification variables and links

Variables go in the subject or body of a notification, template or layout. Syntax: `${variable-name+parameters}`. Concepts: [[Email Notifications]]. Grouped and paraphrased.

## Variables

| Variable | Produces |
|---|---|
| `${field_name}` | the field's value, e.g. `Incident ${number} - comments added` |
| `${reference_field.field}` | a dot-walked value |
| `${image_field}` | an image field, used as an `<img>` source: `<img src='${picture}?t=medium'/>` |
| `${URI}` | link to the record, link text **LINK** |
| `${URI_REF}` | link to the record, link text = its **display value** (the incident number) |
| `${reference_field.URI}` / `${reference_field.URI_REF}` | link to the referenced record, e.g. `${problem_id.URI_REF}` on an incident, `${sysapproval.URI_REF}` on an approval |
| `${URI+&sysparm_view=<view>}` | the link with extra URL parameters |
| `${CMS_URI+<site>/<page>}` | link to a CMS page for the record, e.g. `${CMS_URI+ess/incident_detail}` |
| `${comments:n}` | the last *n* comments (`${comments}` = all) |
| `${comments_and_work_notes:n}` | the last *n* comments and work notes |
| `${mail_script:script_name}` | output of a [[Mail Scripts|mail script]] |
| `${notification:body}` | in an **email layout**, where the notification body goes |
| `${NOTIF_UNSUB}` | unsubscribe-by-email link; `${NOTIF_UNSUB+link_text="click here"}` |
| `${NOTIF_PREFS}` | link to the user's notification preferences for this notification |
| `${report:reportID:<sys_id>}` | attaches a report; also `gaugeID`, `dashboardID`, `chartID`. Not multilevel pivot |
| `${mailto:...}` | a reply link using `glide.email.mail_to` |

## Links to records

- Clicking a `${URI}` link asks the user to log in if needed, then opens the record.
- `${URI+...}` can carry a scriptlet: `${URI+&sysparm_scriptlet=current.assigned_to=gs.getUserID()&sysparm_scriptlet_condition=current.assigned_to.nil()&sysparm_view=incident_active}` assigns the record to the person who clicks, if unassigned.
- **`${URI}` and `${URI_REF}` do not point to workspaces.** For a workspace link, print the URL from a mail script: `https://<instance>/now/workspace/<workspace>/record/<table>/<sys_id>`.
- Links use the instance URL unless `glide.email.override.url` is set.

## Unsubscribe links

| Macro | Works how | Login needed |
|---|---|---|
| `${NOTIF_UNSUB}` | a mailto link creating an email to the instance with subject starting `Unsubscribe from` and a JSON body (`notification_id`, `unsub_token`). Processed by the inbound action *Unsubscribe from Notification* | no |
| `${NOTIF_PREFS}` | opens the notification preferences page | yes |

- Can be placed in layouts, templates or notifications. Base notifications already include them.
- For translated emails that fail to unsubscribe: property `glide.email.translation.unsubscribe.prefix` = true and the inbound action *Unsubscribe from Translated Notifications*.
- Unsubscribing from the primary address unsubscribes all the user's addresses.

## Attachments

- **Include attachments** on the notification sends all attachments of the triggering record (subject to the size limits).
- Or link to an attachment from a mail script: `/sys_attachment.do?sys_id=<sys_id>`.

## Line breaks

In mail scripts for rich HTML notifications, print `<br />` rather than `\n`, and clear **Newlines to HTML** on the email script.

## Related

- [[Email Notifications]] · [[Mail Scripts]]
