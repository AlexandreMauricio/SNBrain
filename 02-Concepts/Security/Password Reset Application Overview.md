---
type: concept
tags: [concept, security, users, admin, domain-separation]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage service capabilities > Password Reset (landing, Exploring Password Reset, Password Reset, Password Reset for Virtual Agent, Password Reset Windows Application, Request to reset the default admin password, Setting up Password Reset, Configuring Password Reset, Plan your Password Reset processes, Calculating the security score, Domain separation and the Password Reset application, Actions in Password Reset for Virtual Agent), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/password-reset/password-reset-landing-page.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Password Reset Application Overview

**In one line:** the **Password Reset** application (`com.glideapp.password_reset`, active by default) lets users reset, change or unlock a password on a **credential store** (the instance itself, Active Directory, Microsoft Entra ID, Okta, Google Directory or a custom store), either **self-service** or through a **service desk agent**, after proving who they are with one or more **verifications**.

From the Brazil docs; not tested. The local-login view of the same feature (Forgot Password? link, password policy) is in [[Local Authentication - Login, Password Policy and Password Reset]]; this note covers the full application. Not available during an upgrade.

## Building blocks of a process

A **Password Reset Process** (`pwd_process`, **Password Reset > Processes**) ties together:

| Element | What it is | Detail |
|---|---|---|
| Credential store | where the user name and password live | [[Password Reset Credential Stores]] |
| User groups | who may use the process (or **Apply to all users**) | groups related list |
| Identification type | how the user claims an identity (user name, email, custom) | [[Password Reset Verifications and Enrollment]] |
| Verifications | how the identity is proven (questions, email code, SMS code, authenticator, personal data, Soft PIN) | same note |
| Process type | **Password reset**, **Password change** or both | check boxes on the process |

Set-up procedure: [[Configure a Password Reset Process]]. Properties, tables, roles and components: [[Password Reset Reference - Properties, Tables and Components]].

## Two operating models

| Model | Who resets | How it is set |
|---|---|---|
| **Self-service** | the user, in a browser (also mobile) | **Public access** ticked on the process; reached through a public URL such as `/$pwd_reset.do?sysparm_url=ss_default` |
| **Service desk-assisted** | an agent with `password_reset_service_desk`, by phone or in person; users cannot reset themselves | **Public access** cleared; agent uses **Password Reset > Service Desk** |

Default self-service flow (Identify > Verify > Reset): **Forgot Password** on the login page, the Identify page (user name or email, plus CAPTCHA), the Verify page (the configured verifications), then either an email or SMS with a reset link (lifetime from `password_reset.request.expiry`, or `glide.pwd_reset.onetime.token.validity` for links) or a generated password shown on screen, depending on the process.

**Password Change** extends the application: a logged-in user opens **Password Reset > Change Password** (or the link on the profile), picks a process tied to a credential store, enters old and new password; the password policy and a strength bar guide the new one. No service desk model for change. Agent-side reset from Service Operations Workspace is a separate path: [[Working Records in Service Operations Workspace]].

## Other channels

- **Virtual Agent** (plugin `com.snc.password_reset.virtual_agent`; topics listed in [[ITSM Virtual Agent Topics and Setup]]): reset a password, change a password, unlock an account, enroll. Reset and unlock work without being logged in. Verifications offered there: personal data, authenticator app, SMS, email, security questions (no custom verifications). The enrollment topic has blocks per verification (security questions, Soft PIN, authenticator app, email and SMS); copy the default topic before changing it. Soft PIN expiry is handled in the VA topics. Reset by **interactive voice response** (phone) supports authenticator app, SMS and email verifications; channels set by `sn_pwdreset_va.supported_channels` (IVR, Microsoft Teams or both). Teams can also unlock and reset.
- **Windows login screen**: [[Password Reset Windows Application]].
- **Service Portal** widget and **CMS** page: in [[Configure a Password Reset Process]].
- **Default instance admin password**: users with `customer_admin` or `partner_admin` on Now Support request it through a Now Support catalog item; this creates a change that automation completes (no manual step).

## Integrations (store apps and plugins)

| Target | What to activate | Notes |
|---|---|---|
| Local instance | nothing (base system) | the only store type enabled by default |
| Active Directory | **Password Reset Windows App (Password Reset Orchestration)** `com.glideapp.password_reset_desktop` plus store app **Microsoft AD for Password Reset** (also called *Microsoft AD Spoke for Password Reset*) | needs a MID Server; requested through Now Support (**Activate Plugin**, at least two business days ahead) |
| Remote ServiceNow instance (SOAP) | same Orchestration plugin | legacy workflows |
| Microsoft Entra ID | store app **Microsoft Entra ID Integration for Password Reset** plus the Entra ID spoke | requested from Now Support or **System Applications > All Available Applications > All > Request Plugin** |
| Okta | store app **Password Reset integration with Okta** (1.1.2) with Okta spoke 4.1.3 | needs an Integration Hub or Workflow Data Fabric subscription; samples *Service-Desk Process for Okta*, *Employee Self-Service Process for Okta*; **User must reset password** not supported |
| Google Directory | store app **Password Reset integration with Google Directory** (1.0.3) with Google Directory spoke 1.3.1+ | samples for service desk and self-service; **Password change** not supported |

Plugin names seen in the chapter: Password Reset `com.glideapp.password_reset`, Self Service Password Reset `com.snc.password_reset` (depends on a *Password Reset Basic* plugin; self-service intended for the local instance only), Password Reset Windows App `com.glideapp.password_reset_desktop`. The basic Password Reset plugin **cannot change an AD password**; the Windows App plugin can.

## Planning (from the docs)

Decide self-service or service desk; analyse how each group accesses the system (remote workers, roles with access to sensitive data need stronger or more verifications); check whether SSO is in use (a compromised password opens every linked system, so use several verifications); decide optional or required enrollment and whether to auto-enroll; decide how SSO and off-site users reset when they cannot log in. For a public self-service process, create a dedicated process with **Public access**.

## Security score (process strength)

Shown on public processes in the **Process Strength Configuration** section, 0 to 100, from four parts:

| Part | Max | How to score high |
|---|---|---|
| Identification | 20 | several identification methods (+5) and CAPTCHA (+10) |
| Verification | 40 | at least two verifications of medium or high security (up to 15 points each for medium, 25 for high); custom verification types default to *low* unless you set their level |
| Configuration | 20 | Email/SMS Password Reset URL or auto-generated passwords (neither: 10) |
| Password policy | 20 | password policy on the credential store, history policy (`password_history_limit`), a *High* strength policy |

Colour bands as stated: 0-40 red (low), 40-75 orange (medium), 76-100 green (high); the bands overlap at 40 on the page. **Enable security score notification** plus one or more **Process owner** users (`password_reset_admin` only; required when the notification is on): the weekly job *Send password reset process security score notification* emails the score and recommendations for active processes (not service-desk-only or change-only processes).

## Domain separation (Standard)

Applied at **process** level: credential store connections, identification types and verifications inherit the domain of their *type* record; names are unique within a domain; every Password Reset table has a domain column; users only see processes of their own domain (password change: their domain or child domains). Built on Orchestration, which supports data-only separation. Expiration records (`pwd_expiration`) are data-separated too. See [[Domain Separation Support Levels by Application]].

## Unconfirmed variants

- Plugin naming for AD: *Microsoft AD for Password Reset* vs *Microsoft AD Spoke for Password Reset*; the Windows App plugin is also called *Password Reset Orchestration*.
- The local-authentication pages say self-service reset is only for locally authenticated users; this chapter adds AD, Entra ID, Okta and Google stores. Both hold for their scope (base system vs store apps); not tested.
- Reset link notification: *Password Reset - Reset Link* (local authentication pages) vs *Password Reset URL*, event `password.reset.url` (this chapter).

## Related

- [[Multi-Factor Authentication]] · [[Hardening Settings - Authentication and Session Management]] (recommended values for `password_reset.*`) · [[Notify Overview, Twilio and Providers]] (SMS codes)
