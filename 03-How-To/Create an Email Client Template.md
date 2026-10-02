---
type: how-to
tags: [how-to, email]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Email client", topic "Create an email client template" (pp. 2641-2644), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Create an email client template

**Goal:** pre-fill subject, body, recipients and sender when a user opens the email client on a record.
**Prerequisites:** role admin. Email client enabled on the table.
**Navigation:** All > Email Client > Email Client Templates

## Steps

1. Select **New**. Fill **Name**, **Table**, optional **Conditions** and **Execution Order** (lowest matching wins).
2. **Content** tab: **Subject**, **Content Type** (HTML or plain text), body with `${field}` variables.
3. **Recipients** tab: **To**, **Cc**, **Bcc** as comma-separated field names or addresses.
4. **Sender Configuration** tab: **From Generation Type**, only if the sender must differ from the SMTP account.
5. Submit.

## Result / how to check it worked

Open a matching record, **More options > Email**: the window opens pre-filled.

## Example

| Field | Value |
|---|---|
| Name | Example incident reply |
| Table | Incident |
| Subject | `${number}: ${short_description}` |
| Body HTML | `Hello ${caller_id.first_name}, ... Regards, ${current_user}` |
| To | `caller_id` |
| Cc | `assignment_group.manager` |

## Tables / fields involved

- `sys_email_client_template`, `sys_email_client_from_address`

## Gotchas

- The From address only shows if the table's email client configuration has **Display From** ticked.
- A `javascript:` expression in a recipient field must be the only content of that field.
- Background: [[Email Client]].
