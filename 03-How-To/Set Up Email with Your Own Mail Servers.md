---
type: how-to
tags: [how-to, email, integrations, security]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Email Administration", topics "Advanced email setup", "OAuth email authentication", "Read or send emails using Microsoft Graph", "Sending email using client credential flow", "Create an email account" (pp. 2398-2434, 2458-2461), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Set up email with your own mail servers

**Goal:** send and receive instance email through your own SMTP, POP3 or IMAP servers (or Microsoft 365), instead of ServiceNow's.
**Prerequisites:** role admin (or `email_account_admin`). Basic email properties enabled. A dedicated mailbox for the instance.
**Navigation:** All > System Mailboxes > Administration > Email Accounts

## Steps: own SMTP server (sending)

1. Open **Email Accounts**, find **ServiceNow SMTP** and set **Active** to false (only one SMTP account may be active).
2. **New**: **Type** SMTP, **Server**, **Authentication**, **User name** (a full email address), password or OAuth profile, **Connection Security** SSL/TLS, **Port**. Submit.
3. Related link **Test Connection**.
4. On your mail system, forward mail from your custom address to the instance address if you still receive through ServiceNow's POP3.

## Steps: own POP3 or IMAP server (receiving)

1. Create a mailbox on your server (e.g. a service desk address).
2. Optionally deactivate **ServiceNow POP3**; left active, the instance also keeps receiving at its default address.
3. **New**: **Type** POP3 or IMAP, server, credentials, security, port. Submit and **Test Connection**.

## Steps: OAuth 2.0 (e.g. Gmail, Microsoft 365)

1. Activate the plugin *Email: OAUTH support for IMAP, Microsoft Graph (Receiving), and SMTP* (`com.glide.email.oauth`).
2. At the provider, register an application and note the client ID, client secret, authorization URL, token URL, redirect URL (`https://<instance>.service-now.com/oauth_redirect.do`) and revocation URL.
3. **System OAuth > Application Registry > New > Connect to a third party OAuth Provider**; fill those values; add the scopes.
4. Create the SMTP and IMAP email accounts with **Authentication** = OAuth 2.0 and the **OAuth Profile**, then select **Authorize Email Account Access**.

## Steps: Microsoft Exchange Online

Two routes, both with an app registered in Microsoft Azure (Entra ID) and admin consent:

| Route | Azure permission | Account type on the instance | Notes |
|---|---|---|---|
| Microsoft Graph, receive | `Mail.ReadWrite` (application) | **Microsoft Graph (Receive)**, with **Inbox email address** | plugin `com.glide.email.graph`. OAuth scope `.default`, grant type Client Credentials |
| Microsoft Graph, send | `Mail.Send` and `Mail.ReadWrite` | **Microsoft Graph (Send)** | same plugin |
| SMTP with client credentials | `SMTP.SendAsApp` | **SMTP**, OAuth 2.0 | OAuth scope `https://outlook.office365.com/.default`. Also register the service principal in Exchange with PowerShell (`New-ServicePrincipal`, `Add-MailboxPermission`) |

Each route can authenticate with a client secret or with a certificate (JWT provider plus an OAuth API script copied from `GraphCertificateOAuthTemplate` or `EmailCertificateOAuthTemplate`; the copy's name must start with `OAuth`).

## Result / how to check it worked

**Test Connection** succeeds, and test messages appear in **System Mailboxes > Sent** and **Inbox**.

## Example

Outbound through *smtp.example.com* on port 465 with SSL/TLS as `servicedesk@example.com`; inbound from an IMAP mailbox of the same address with OAuth 2.0.

## Tables / fields involved

- `sys_email_account`: the accounts
- `sys_email`: the messages

## Gotchas

- **The instance deletes messages from the mailbox after reading them.** Never point it at a person's mailbox.
- With your own servers you lose ServiceNow's spam scoring and virus scanning: put your own filter on the address.
- Anti-spam for Microsoft Graph accounts is your responsibility.
- Use `<CLIENT_ID>` and `<CLIENT_SECRET>` placeholders in any notes; secrets live only in the Application Registry.
- A password field of 40 characters may be too short for long app passwords.
- Background: [[Email Architecture and Accounts]].
