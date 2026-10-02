---
type: how-to
tags: [how-to, email, forms-lists]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Email client", topic "Enable the email client for a table" (p. 2634), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Enable the email client for a table

**Goal:** let users send email from records of a table other than Incident or Change.
**Prerequisites:** role admin. Users need `email_composer`.
**Navigation:** a record of the table > form context menu > Configure > Dictionary

## Steps

1. Open any record of the table, then the form menu > **Configure > Dictionary**.
2. Open the entry of type **Collection** (no column name).
3. Under Related Links select **Advanced view**.
4. In **Attributes** add `email_client=true` (comma-separated from existing attributes).
5. Update.

## Result / how to check it worked

The form's **More options** menu shows **Email**.

## Example

On the Problem (`problem`) collection entry, attributes become `<existing attributes>,email_client=true`.

## Tables / fields involved

- [[sys_dictionary]]: the collection entry, **Attributes** (`attributes`)

## Gotchas

- Not inherited: setting it on Task does not enable Incident or Problem.
- Background: [[Email Client]] · [[Dictionary Attributes Reference]].
