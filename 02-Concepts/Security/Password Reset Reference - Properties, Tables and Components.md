---
type: reference
tags: [reference, security, schema, roles, notifications]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Password Reset > Password Reset reference (Installed with Password Reset, Password Reset global properties, System properties for password expiration), Password Reset and Password Change reports and logs, Unblock a Password Reset user, Specify lockout for failed login attempts, read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/password-reset/password-reset-reference.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Password Reset Reference - Properties, Tables and Components

Lookup lists for [[Password Reset Application Overview]]. From the Brazil docs; not tested. Recommended (hardening) values for several of these: [[Hardening Settings - Authentication and Session Management]].

## Roles

| Role | Can |
|---|---|
| `password_reset_admin` | configure and run Password Reset and Password Change |
| `password_reset_service_desk` | reset for users, track requests, view logs |
| `password_reset_credential_manager` | decide which credential stores are valid; view activity log and reports |

Password Reset tables are protected by deny-unless ACLs for these roles.

## Properties (**Password Reset > Properties** unless noted)

| Property | Default | Meaning |
|---|---|---|
| `password_reset.enroll_reminder.email_template` | | template for enrollment reminders (printed with a space, `password_reset.enroll _reminder...`) |
| `password_reset.wf.refresh_rate` | 500 ms | workflow status polling |
| `password_reset.wf.timeout` | 90000 ms | max wait for the workflow |
| `password_reset.captcha.ignore` | false | true turns CAPTCHA off |
| `password_reset.captcha.google.enabled` | true | Google reCAPTCHA; false = base-system CAPTCHA |
| `password_reset.request.max_attempt` | 3 | failed attempts before blocking |
| `password_reset.request.max_attempt_window` | 1440 min | how long a blocked user waits |
| `password_reset.request.success_window` | | wait after a successful reset or change |
| `password_reset.request.unlock_window` | | wait after a successful unlock |
| `password_reset.request.expiry` | 10 min | time to finish a request |
| `glide.pwd_reset.onetime.token.validity` | 12 h | email link lifetime; wins over `request.expiry` when the URL option is on; not on the properties page (add it) |
| `password_reset.request.max_email` | (max 5) | reset-link emails per 24 h |
| `password_reset.qa.num_reset` | 3 | questions at reset |
| `password_reset.qa.num_enroll` | 5 | questions at enrollment |
| `password_reset.qa.ans_min_len` | 3 | minimum answer length |
| `password_reset.sms.max_per_day` | 10 | SMS codes per 24 h |
| `password_reset.sms.pause_window` | 2 min | between SMS codes |
| `password_reset.sms.default_complexity` | 4 (properties page) / 6 (hardening page) | digits in the SMS code |
| `password_reset.sms.expiry` | 5 min | SMS code lifetime |
| `password_reset.sms.use_notify` | Yes | send SMS through Notify (`com.snc.notify`) |
| `password_reset.softpin.expiration_enabled` | | Soft PIN expiry |
| `password_reset.softpin.expiration_day` | 90 | days before a Soft PIN expires |
| `password_reset.softpin.expiration_reminder_enabled` | | reminder emails (the page's wording reads inverted) |
| `password_reset.softpin.expiration_reminder_time` | 00:00 | HH:MM, system time zone |
| `password_reset.softpin.expiration_reminder_warn_days` | 10 | days before expiry to remind |
| `password_reset.softpin.history_limit` | | 1 to 30 previous PINs refused |
| `password_reset.activity_monitor.incident_window` | 60 min | window for counting blocked users |
| `password_reset.activity_monitor.incident_threshold` | 10 | blocked users in the window that raise a system log event (and the *Activity Monitor Lockout* notification) |
| `password_reset.stylesheet` | `css_pwd_reset_default` | CSS from `content_css` for the end-user pages |
| `password_reset.history.limit` | 10 | ceiling for `password_history_limit` (ServiceNow store) |
| `pwd_reset.enable.password_expiration_reminder` | false | expiration reminders |
| `pwd_reset.enable.dbListener` | false ("which means enabled" on the page) | DB listener that keeps expiration and enrollment-snapshot rows in step with user changes; heavy on bulk imports |
| `pwd_reset.enable.enrollment_snapshot...` | | turns off snapshot sync (name cut off on the page) |
| `pwd_reset.password_expiration.error_count` | 5 | failed fetches before an expiration row is deactivated (create it) |
| `pwd_reset.refresh_expiration_data.duration` | 30 days | refresh for never-expiring passwords |
| `glide.security.password_reset.uri` (sys_properties) | `/$pwd_reset.do?sysparm_url=ss_default` | where **Forgot password?** goes (also mobile) |
| `glide.security.forgot_password.display.link` (sys_properties) | | show the link on the login page |
| `sn_pwdreset_va.supported_channels` | | IVR and/or Microsoft Teams for the VA flows |

Login lockout outside the application (script actions *SNC User Lockout Check*, *... with Auto Unlock*, *SNC User Clear*; `glide.user.max_unlock_attempts`, `glide.user.unlock_timeout_in_mins` default 15; event `login.failed`): already in [[Local Authentication - Login, Password Policy and Password Reset]]; the Password Reset chapter repeats it unchanged.

## Tables

| Table | Holds |
|---|---|
| `pwd_process` | processes |
| `pwd_cred_store`, `pwd_cred_store_param`, `pwd_cred_store_type` | credential stores, their parameters, types |
| `pwd_map_proc_to_cred_store`, `pwd_map_proc_to_group`, `pwd_map_proc_to_verification` | process links |
| `pwd_verification`, `pwd_verification_param`, `pwd_verification_type` | verifications |
| `pwd_identification_type`, `pwd_extension_type` | identification and extension types |
| `pwd_question`, `pwd_active_question`, `pwd_active_answer` | security questions, chosen questions, encrypted answers |
| `pwd_enrollment` | enrollment per verification |
| `pwd_enrollment_snapshot` | reporting snapshot; job *Sync Password Reset Enrollment Snapshot Data Monthly*; **Sync Enrollment Snapshot Data** on a process |
| `pwd_device`, `pwd_dvc_enrollment_code`, `pwd_sms_code`, `pwd_email_code` | SMS devices and codes, email codes |
| `pwd_reset_request`, `pwd_map_request_to_verification` | requests and the verifications used |
| `pwd_reset_activity` | activity log (all requests) |
| `pwd_activity_monitor`, `pwd_user_lockout` | lockout monitoring, blocked users |
| `pwd_history` | past passwords |
| `pwd_access_control`, `pwd_access_log` | desktop (Windows app) access control and log |
| `pwd_expiration` | password expiration rows |

Purge (**Table Cleanup**, the page puts it under *Automated Test Framework > Administration*; or ask Support; see [[Table Cleaner]]): `pwd_reset_request`, `pwd_user_lockout`, `pwd_reset_activity`, `pwd_activity_monitor` 90 days; `pwd_dvc_enrollment_code`, `pwd_sms_code` 1 day. Reports change sharply after a purge.

## UI pages and macros

Pages: `$pwd_reset` (self-service start), `$pwd_reset_serviceDesk`, `$pwd_verify`, `$pwd_new`, `$pwd_success`, `$pwd_error`, `$pwd_confirm` (link sent), `$pwd_change`, `$pwd_change_success`, `$pwd_change_error`, `$pwd_enrollment_form_container`, `$pwd_enrollment_success`, `$pwd_enroll_error`, `$pwd_unlock_success`, `$pwd_reset_downloads_ui` (Windows app download). Macros include `$pwd_csrf_validation`, `$pwd_display_password`, enrollment and verification pairs for email, Google Authenticator, questions and SMS, `$pwd_verify_personal_data_ui`, `$pwd_verify_simple_ui`, `$pwd_process_flow`, `$pwd_reset_stylesheet`. UI scripts (included with `<g:include_script src="<name>.jsdbx"/>`): `$pwd_csrf_common_ui_script`, `$pwd_util`, `$pwdWfManager`, `$pwd_enrollment_submit_event` and enrollment scripts.

## Workflows (legacy, used as models)

Reset (*Pwd Reset - AD / Local ServiceNow / Master / Remote ServiceNow / Mock Fatal / Mock Non Fatal / Mock Success*), connection test (*Pwd Connection Test - ...*), lock state (*Pwd Get Lock State - ...*), unlock (*Pwd Unlock Account - ...*), change (*Pwd Change - ...*). Newer stores use subflows ([[Password Reset Credential Stores]]). SOAP messages *Change Password* and *Reset Password* serve remote ServiceNow stores (Orchestration).

## Notifications

| Notification | Event | Sends |
|---|---|---|
| Password Reset - Send SMS Code | `pwd.send_sms_code.trigger` | SMS code |
| [K] Password Reset - Send Email Code | `pwd.send_email_code.trigger` | email code |
| Password Reset - Enrollment Reminder | `pwd.enrollment_reminder.trigger` | enroll reminder |
| Password Reset - New Password Confirmation | `pwd.email.trigger` | the new password (Email/SMS password processes) |
| Password Reset - Send Verify Code | `pwd.send_verify_code.trigger` | code for reset or enrollment (through Twilio when Notify is active) |
| Password Reset URL | `password.reset.url` | reset link; if nothing arrives check `sys_event`, the user's subscription, and the default self-service process and properties |
| Password Reset-Activity Monitor Lockout | | blocked-user threshold alert (subscribe from a notification device) |

## REST API

*Pwd Reset* (`pwd_reset`), base `/api/now/pwd_reset`, versions v1 and v2 with the same resources: `/init` (session, logs, UI messages), `/identify`, `/verify`, `/reset`, `/success`, `/failure` (page components).

## Reports (**Password Reset > Overview**)

Password Requests (7 days), Blocked Users (7 days), Request Status by process (7 days), Requests by Action (30 days), Top Users (30 days; many requests from one user may mean an attack), Failed Verifications (7 days; many failures may mean a confusing process), Enrollment By Verification, Password Change Top Users (30 days). **Activity Log** (`pwd_reset_activity`) for detail. Windows app debug: `DebugFlag` registry value ([[Password Reset Windows Application]]).

## Business rules worth knowing

*Check unique verifications*, *Deactivate process with no group / no min ver / no verification*, *Google Auth Enabled Check* and *GoogleAuthSysPropertyCheck* (deactivate processes using Google Authenticator when it is disabled), *Handle req_enroll validation/default val*, *Insert/update scheduled job for reminder*, *Order must be unique*, *Personal Data (Confirm) Param Validation* (column must exist on `sys_user`), *Prevent against deletion (when in use)*, *Send SMS code*, *Send SMS Verification Code Via Notify*, *Validate Process*, *Validate ... Name* (unique names), *Validate Security Question*, *VerifyAutoEnroll*.
