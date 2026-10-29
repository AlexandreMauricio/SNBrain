---
type: how-to
tags: [how-to, security, users, admin, portal, notifications]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Password Reset > Configure your Password Reset process, Password Reset Process form, Configure password expiration reminder (View scheduled jobs, View a password expiration table, System properties for password expiration, Password Expiration Configuration form), Send email to remind users to enroll, Customize the enrollment reminder email, Configure properties, Configure Google reCAPTCHA, Add a custom header or footer, Reset a password or unlock a user account with service desk assistance, View user requests for password reset, Unblock a Password Reset user, Integrate with a Service Portal widget, Integrate with a CMS integration, read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/password-reset/t_CreateAPasswordResetProcess.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Configure a Password Reset Process

**Goal:** create a Password Reset process (`pwd_process`) for a group of users, then run, monitor and support it. Concepts: [[Password Reset Application Overview]]. Untested; from the Brazil docs.

Role: `password_reset_admin` (or `admin`). Before starting: a credential store ([[Password Reset Credential Stores]]) and the verifications you want ([[Password Reset Verifications and Enrollment]]).

## 1. Create the process

1. **Password Reset > Processes** > **New**: Name, Description, **Credential store**, tick **Password reset**, **Password change** or both.
2. **Apply to all users**: ticked = everyone; cleared = only the groups in the **Groups** related list (shown after saving).
3. **Password Reset Details** tab:

| Field | Meaning |
|---|---|
| Public access | self-service through a public URL; cleared = service desk only |
| Public URL / URL suffix | the page users open; the default self-service process uses `/$pwd_reset.do?sysparm_url=ss_default` |
| Display CAPTCHA | CAPTCHA on the Identify page (Google reCAPTCHA by default, see step 6) |
| Identification type | Email or Username identification, or a custom one |
| Redirect URL | where to go after a successful reset (full URL, or `/...` on the same domain) |
| Minimum verifications | how many must pass; mandatory ones always count, extra optional ones fill the gap |
| Allow user to choose from optional verifications | user picks which optional ones (only when the minimum exceeds the mandatory count); otherwise **Order** decides |
| Email/SMS Password Reset URL | send a reset link (the secure default for self-service); without it, QA alone, or only personal data plus QA, is refused because anyone could reset any account |
| Enable account unlock | unlock without resetting (not in the default self-service process) |
| Unlock user account | unlock after a reset |
| Auto-generate password | generate the new password (only with Password reset ticked and the URL option cleared); then tick **Display password** and/or **Email/SMS password** (business rule *Password Reset Validate Auto-generate*). Clear it to use the history policy on local or AD stores |
| User must reset password | force a change at first login with the generated password (local store prompts; AD users must change from a domain computer) |

4. **Advanced** tab: Entry, Success, Failure UI macros; **Post reset script** ([[Password Reset Extension Scripts]]); Header and Footer UI macros.
5. Save, add **Verifications** in the related list, then tick **Active** (only possible after the first save) and **Update**. A process loses Active automatically if its verifications or groups are removed or fall under the minimum.

## 2. Properties, CAPTCHA, page look

- **Password Reset > Properties**: limits and texts ([[Password Reset Reference - Properties, Tables and Components]]). Docs advice: about 3 verification attempts, 5 to 7 security questions.
- **reCAPTCHA**: instances on `service-now.com` work as shipped. Other domains need their own key pair from Google (reCAPTCHA **v2** "I'm not a robot"; v3 not supported): `password_reset.captcha.google.enabled` = true, `google.captcha.site_key` = `<SITE_KEY>`, `google.captcha.secret` = `<SECRET>` (password2 type). On-premises instances (no internet): set `password_reset.captcha.google.enabled` = false to use the base-system CAPTCHA. `password_reset.captcha.ignore` = true switches CAPTCHA off.
- **Header or footer**: **System UI > UI Macros** > New (XML), then pick it in Header / Footer UI macro on the Advanced tab; check through the Public URL (public processes) or as an end user.

## 3. Enrollment reminders

Process > **Enrollment Reminder** tab (only with Password reset ticked): **Send reminder**, **Sender alias** (a no-reply address put in To and From so recipients go in Bcc; default `do-not-reply@ServiceNow.com`), **Send** Monthly (day) or Weekly (weekday; default Monday 00:00), **Time**, **Starting**. Default email "Reminder: Enroll in the Password Reset program". Change the subject in the email template *Password reset enrollment reminder* (**System Policy > Email > Templates**, needs `com.glide.email_client`), the body in the notification email script `pwd.enrollment_reminder`; or copy the template and name it in the property `password_reset.enroll_reminder.email_template`. Notification: *Password Reset - Enrollment Reminder* (event `pwd.enrollment_reminder.trigger`).

## 4. Password expiration reminders (non-local stores)

Not for the local ServiceNow store (e.g. for Entra ID). Turn on `pwd_reset.enable.password_expiration_reminder` (default false), then process > **Password Expiration Configuration** tab > **Send expiration reminder**:

| Field | Default |
|---|---|
| Days password is valid | 90 |
| Days prior to start reminders | 10 |
| Schedule Frequency | Daily, or Periodically with **Repeat Interval** |
| Time zone, Time, Start time | |

Two scheduled jobs appear (**System Definition > Scheduled Jobs**): *Sync password expiration records for pwd_process_<sys_id>* (runs once, an hour later, creates rows in `pwd_expiration` without dates) and *pwd_expiration_reminder_<sys_id>* (periodic: fetches dates from the store, sends reminders). **Sync Expiration data** on active processes re-runs the sync. `pwd_expiration.list` columns: User, Password Reset Process, Last Password Reset Date, Password Expiration Date, Send Notification, Active (false when the user left the process), Error Count, Last Refresh Date, Last Error Log. Related properties: `pwd_reset.enable.dbListener`, `pwd_reset.password_expiration.error_count` (default 5, create it yourself), `pwd_reset.refresh_expiration_data.duration` (30 days, for passwords that never expire). Reminders can go out by email, SMS or actionable Virtual Agent messages.

## 5. Service desk-assisted reset

Agent with `password_reset_service_desk` (or `password_reset_admin`), process with **Public access** cleared: **Password Reset > Service Desk** > select the user and process > **Verify Identity** > enter the user's answers > **Continue** > **Reset password** (new password) or, if locked, **Unlock account** (only with **Enable account unlock**). For another user, leave the page and reopen Service Desk. Works on mobile and in the dark theme.

## 6. Monitor and unblock

- **Password Reset > Reset Requests** (`pwd_reset_request`): User, Process, Type (Change Password, Help Desk, Self Service), Action Type (Change Password, Reset and Unlock Account, Reset Password, Unlock Account), Status (Completed With Failure, Completed With Success, Expired, In Progress, Max Number of Attempts, Verified, Pending With External System), Active, Retry.
- **Password Reset > Blocked Users** (`pwd_user_lockout`): users blocked for too many failures, resetting again before the wait time, or wrong information. Self-service: select > **Delete**. After a **service desk** reset the block is not cleared (agents have unlimited retries): set **Blocked** to false by hand, or it clears only after `password_reset.request.max_attempt_window` when the user tries self-service again.
- **Password Reset > Overview** reports and **Activity Log**: [[Password Reset Reference - Properties, Tables and Components]].

## 7. Put it in a portal or CMS site

- **Service Portal** (`admin` or `sp_admin`): in the Designer create a page, drop a 12-column layout, add the **Pwd reset** widget, save. Point the portal login page's reset link to the page with `sysparm_show_custom_header_footer=false` (required) and optionally `sysparm_redirect_url=<portal>?id=<page>`, e.g. `https://<instance>.service-now.com/<portal>?id=<reset_page>&sysparm_show_custom_header_footer=false&sysparm_redirect_url=<portal>?id=<login_page>`.
- **CMS** (`content_admin`; one page per process): **Content Management > Specialty Content > iFrames** record, a site without a login page, a page in that site with the iFrame as content block.

## Example

Process *Example Employee Reset*: credential store *Example Local Store*, not for all users but group *Example Staff*, Public access with suffix `example_reset`, Display CAPTCHA, Username identification, Minimum verifications 2 with *Example Email Code* mandatory and *Example Questions* optional, Email/SMS Password Reset URL ticked, Enrollment Reminder weekly on Monday 08:00 from `do-not-reply@example.com`. Test as *Test User*: Forgot Password > Identify > Verify > email link > new password.

## Related

- [[Local Authentication - Login, Password Policy and Password Reset]] · [[Hardening Settings - Authentication and Session Management]] · [[Scheduled Jobs]]
