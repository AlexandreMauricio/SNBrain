---
type: concept
tags: [concept, security, users, notifications]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Password Reset > Password Reset verifications (Personal data identification types and confirmation type verifications, SMS Code Verification type, Use Notify to send SMS codes, Specify the number of required security questions), Configure your process to auto-enroll users, Enable users to enroll, Add a custom question to the Security Questions verification, Create a verification from an existing verification, Create a custom verification type, Create a custom verification, Create a custom identification type, Verification types in the base system, Password Reset Verification Type form, Password Reset Verification form, Enrolling in the Password Reset application (authenticator, SMS, email, questions, Soft PIN, reset on Windows), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/password-reset/c_PWRVerifications.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Password Reset Verifications and Enrollment

**In one line:** a **verification** (`pwd_verification`, **Password Reset > Verifications**) is one way of proving identity, built on a **verification type** (`pwd_verification_type`) that supplies the UI macros and processor scripts; users **enroll** (or are auto-enrolled) in the verifications their process uses, and an **identification type** decides what they type on the first page.

From the Brazil docs; not tested. Part of [[Password Reset Application Overview]]. Neither the Windows application nor Virtual Agent supports **custom** verifications.

## Identification types

*Email Identification* (`PwdIdentifyViaEmail`) and *Username Identification* (`PwdIdentifyViaUsername`). Custom ones (e.g. an employee ID) under **Password Reset > Extensions > Identification Types**: Identification field label and an Identification processor ([[Password Reset Extension Scripts]]). Set per process in **Identification type**.

## Base-system verifications and their types

| Verification | Type | Enrollment | Notes |
|---|---|---|---|
| QA verification | Security Questions | user picks questions and answers | questions shown in the user's login language; answers stored encrypted (`pwd_active_answer`) |
| Email verification | Email Code | authorise one or more addresses (profile email by default) | 6-digit code, valid 10 minutes, resend after 2 minutes, max 10 per day |
| SMS verification | SMS Code | authorise a device | 6-digit code, valid 5 minutes, resend after 2 minutes, max 10 per day; can be sent through Notify |
| Authenticator verification | Google Authenticator (authenticator type) | pair by QR code | apps listed: Google Authenticator, Microsoft Authenticator, Cisco Duo (enrollment page adds Okta Verify) |
| Personal Data - Confirm Email Address | Personal Data | none | not allowed on processes with public access |
| Personal Data - Enter User Name | Personal Data | none | |
| Soft PIN Verification | Soft PIN | user sets a 6-digit PIN | not supported by the default VA templates *Reset Password (Template)* and *Unlock Account (Template)* |
| (none) | Personal Data Confirmation | none | data from `sys_user` shown to a service desk agent who confirms it; for service desk processes |
| (none) | Mock | | demonstration only (workflows *Pwd Reset - Mock ...*) |

Each verification has **Order** (position on the enrollment and reset pages) and a **Password Reset Verification Parameters** related list (`pwd_verification_param`) that overrides the global properties for that verification. Parameter names cannot be renamed after creation.

### Parameters per type

| Type | Parameter | Default | Meaning |
|---|---|---|---|
| Personal Data / Personal Data Confirmation | `label`, `column` | | label shown and the `sys_user` column compared (e.g. `label=Email`, `column=email`); one pair per verification, extra ones ignored; add more verifications for more fields |
| SMS Code | `expiry` | 5 | minutes the code is valid |
| | `complexity` | 6 | digits in the code |
| | `pause_window` | 2 | minutes before another code |
| | `max_per_day` | 10 | codes per day |
| Security Questions | `num_enroll` | | questions answered at enrollment (overrides `password_reset.qa.num_enroll`; cannot exceed the questions available) |
| | `num_reset` | | questions asked at reset, random and in random order, all must be right (overrides `password_reset.qa.num_reset`; not more than `num_enroll`) |

Add a custom security question: **Password Reset > Security Questions** > New, text in **Question (Translated field)** (`pwd_question`). For other languages either log in in that language and create it, or create the English one and add a `sys_translated` record (table `pwd_question`, element `question_translated`, the language). See [[Languages, Translation Tables and Locale]].

## Enrollment

- **Automatic**: on the verification type (**Password Reset > Extensions > Verification Types**) tick **Automatic enrollment**; the **Enrollment check** script must return true (default script if empty). For SMS and email, auto-enrollment only works when the mobile number or email is already on the user record; without auto-enrollment users must enroll even if the data is there.
- **Manual**: the type needs an **Enrollment UI** macro and an **Enrollment processor** script (example `pwd_enroll_sms_ui` + `PwdEnrollSMSProcessor`), plus a **Verification UI** macro and **Verification processor** (example `pwd_verify_sms_ui` + `PwdVerifySMSProcessor`).
- Users enroll at **Password Reset > Enroll** (also on mobile): one tab per verification, an asterisk marks required ones.
  - Authenticator: scan the QR code, enter the code, **Pair Device**, **Submit**; later **Generate New QR Code** or **Disable Multi-factor Authentication**. Cannot be used to enroll for the Windows app.
  - SMS: **Add Device**, verify, tick **Authorized**.
  - Email: **Add Email**, **Verify** with the emailed code, tick **Authorized**.
  - Questions: pick and answer the required number.
  - Soft PIN: six digits; repetition and sequence thresholds 2; last five PINs refused (rules configurable). Expiry and reminders by `password_reset.softpin.*` properties.
- Email and SMS enrollment rows are written to **Password Reset Enrollment for Verifications** (`pwd_enrollment`) as soon as the code is verified, before **Submit**.
- Reminder emails to enroll: **Enrollment Reminder** tab of the process ([[Configure a Password Reset Process]]).

## Custom verifications

1. Copy and adjust an existing verification (**Password Reset > Verifications**, change parameters), or
2. create a **verification type** (fields: Enrollment check, Automatic enrollment, Enrollment UI, Enrollment processor, Verification UI, Verification processor; set its **security level**, default *low*, which feeds the process security score), then a verification of that type.

## Unconfirmed variants

- Number of Personal Data verifications in the Windows app: "only a single instance" (verification form page) vs "multiple verifications of the Personal Data type" (verification types page).
- The Google Authenticator row on the verification types page carries a note about "a single verification of the SMS Code type" (apparently copied from the SMS row); the Security Questions verification is "single" on one page and "multiple instances" for the Windows app on another.
- SMS code length: 6 digits (verification parameter default and the hardening page) vs `password_reset.sms.default_complexity` default **4** on the properties page.

## Example

Process *Example Self-Service Reset* uses *Example SMS Check* (SMS Code, `expiry` 5, `complexity` 6) as mandatory and *Example Questions* (Security Questions, `num_enroll` 5, `num_reset` 2) as optional; the SMS Code type has **Automatic enrollment** ticked, so users with a mobile number on their record are enrolled without visiting **Password Reset > Enroll**.

## Related

- [[Password Reset Reference - Properties, Tables and Components]] · [[Multi-Factor Authentication]] (separate MFA for login)
