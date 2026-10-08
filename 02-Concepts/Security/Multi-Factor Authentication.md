---
type: concept
tags: [concept, security, users, access-control, admin, api, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Authentication > Multi-factor authentication (whole section, 54 topics, 1,836 cleaned lines, read in full 2026-10-08 through the docs site) - MFA enforcement (changes, properties, troubleshooting, FAQ on requirements, scope, timeline, exceptions, metrics, types, reset), Exploring, Configuring (MFA context, verification methods, web authentication and authenticator configuration, factor policies for FIDO2, SMS and email, providers, Vonage tutorial, system properties, user, role and policy criteria, MFA with SSO, reset, reference tables, metrics), Using (first-time setup, profile setup, log in, authenticator apps, biometric and hardware key registration), MFA Dashboard, Guided Setup. https://www.servicenow.com/docs/r/platform-security/authentication/mfa-landing.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Multi-Factor Authentication

**In one line:** after user name and password, the user must present a second factor (authenticator app code, passkey, biometric or hardware key, emailed or texted code). **Since Yokohama it is enforced by default for every internal user who logs in without SSO**, on every instance, production or not.

From the Brazil docs. The policy machinery behind "who is asked": [[Adaptive Authentication]] (MFA context). Password login itself: [[Local Authentication - Login, Password Policy and Password Reset]].

## What is enforced since Yokohama

A policy named **Enforce MFA for non-SSO logins** is active as the step-up policy of the MFA context.

| Login | MFA by default |
|---|---|
| Local user name and password, or LDAP, internal user | **yes** (web and mobile app) |
| Users with `snc_external` | no (they can enrol themselves; admins can include them by changing the policy conditions) |
| SSO (SAML, OIDC, certificate login) | no: enforce it at the identity provider, or see *MFA with SSO* below |
| REST or SOAP with basic authentication; OAuth password grant | no. `glide.authenticate.multifactor.for_integrations` = true enforces it for integration users **who are already enrolled** |
| OAuth authorization code grant | yes, as part of the interactive login before consent |
| Instance clone setup, update set retrieval | no |
| RPA bots logging in interactively | yes, unless exempted |
| Personal developer instances on Yokohama or later | yes |

An instance that already had an active MFA context policy before the upgrade keeps its own policy.

Timeline for a user without MFA:

- First login after the upgrade starts a **self-enrolment period** (30 days by default): login works, with a reminder. After it, login is impossible until MFA is set up.
- New users appearing more than 90 days after the upgrade get no grace period (that window is the *maximum relaxation period*).

| Property | Meaning |
|---|---|
| `glide.authenticate.multifactor` | MFA as a whole (on by default; switching it off needs a business justification) |
| `glide.authenticate.multifactor.self_enrolment_period` | grace days per user: default 30, max 90, 0 = set up at first login |
| `glide.authenticate.multifactor.enforcement.max_relaxation_period` | days after the upgrade during which new users still get the grace period (max 270) |
| `glide.authenticate.multifactor.setup.bypass.count` | times a user may skip the setup screen (default 0, at most 3) |
| `glide.authenticate.multifactor.enforcement.show_user_info_message` | false hides the reminder shown to users |
| `glide.authenticate.multifactor.enforcement.acknowledged` | true stops the notice shown to admins |
| `glide.authenticate.hybrid_user_tracking.enabled` (create it) | record in *User Login Info* the accounts that are not marked **Web service access only** but log in through APIs with a password |

### Exempting people

In **Multi-factor Authentication > MFA Context**, open the step-up policy and use its inputs:

| Exempt | How |
|---|---|
| Users or groups | add them to the group **MFA Exempted User Group** (input *Is a member of MFA exempted group*) |
| Roles | add roles to the criterion **Has MFA exempted role** |
| A trusted network | create an IP filter criterion, add it as an input, and change the condition so it is false inside the network |
| A country | location filter criterion (paid Zero Trust location plugin) |

Asking less often: **remember this browser** on the validation page skips MFA on that browser for `glide.authenticate.multifactor.browser.fingerprint.validity` (8 hours by default, up to 24). The browser is recognised by a fingerprint of browser and device parameters, so a change such as plugging in another monitor can trigger MFA early. Related: `...remember.browser.enable` (default true), `...remember.browser.default` (checkbox default), `...remembered.browser.max.count`.

## Factors

| Factor | Notes |
|---|---|
| Authenticator app (TOTP) | tested: Google Authenticator, Microsoft Authenticator, LastPass Authenticator, Authy, FreeOTP, Duo, Okta Verify. The QR code pairs an app already installed. Device and instance clocks must agree within about 30 seconds; `glide.authenticate.multifactor.clock_skew` widens the window (seconds, default 10, max 60) |
| Passkey, biometric (Windows Hello, Touch ID, Face ID), hardware key (FIDO2) | plugin **Integration - Web Authentication** (`com.snc.integration.webauthn`, installed by default); `glide.webauthn.enabled`. No phone needed (since Xanadu) |
| Email one-time code | 6 digits, valid `glide.multifactor.onetime.code.validity` minutes (default 5); `glide.authenticate.multifactor.email.otp.enable`. Part of plugin `com.snc.integration.multifactor.authentication` |
| SMS one-time code | plugin **Multi-factor authentication with SMS** (`com.snc.authentication.sms_mfa`; brings Notify - Twilio Direct Driver). Sent to the mobile number on the user record |

FIDO2 and TOTP count as secure; email and SMS as weaker. A user can enrol several factors (recommended, so one lost device does not lock them out); the last one used is offered first. `glide.auth.mfa.ui.v2.enabled` lets users enrol a factor without first setting up an authenticator app.

**Factor policies** (MFA Context > *MFA Factor Policies* tab; role `adaptive_auth_admin`): *Display FIDO2 / SMS OTP / Email OTP as an MFA Factor Policy*, each with inputs (IP, role, group criteria) and conditions (ORed). They decide **which factors a user is offered**, once the MFA context says MFA applies. **FIDO2 is exclusive:** when it is the only factor policy matching a user, other factors, even ones the user enrolled, are hidden and the user must register a FIDO2 authenticator; when another factor policy also matches, FIDO2 is one option among them.

**Providers** (**Multi-factor Authentication > Providers**): email, Twilio and Infobip configurations (the last two arrive with demo data). A custom SMS provider = **Provider** *Custom* with a configuration table and record, a script, the user table and field, and a **Message Template**; the docs' Vonage tutorial builds a REST message (POST to the provider's SMS endpoint, form-encoded) and a small custom table of phone numbers (reference to user + E164 phone field).

**Authenticator Configuration** (**Web Authentication > Authenticator Configuration**): **Allowed authenticator type** (*platform* = built into the device; *roaming* = removable keys), **Attestation Type** (none, direct, indirect; the last two need authenticator metadata imported), self-attestation switches, **User verification** and **Resident key** (preferred or required), **Verify user presence**, **Timeout**. Restricting a type stops new registrations only; deactivate existing rows in *User Public Credentials* to block them.

## Who is asked (three mechanisms)

| Mechanism | Where | Note |
|---|---|---|
| **Policy** (recommended) | MFA context: *Step-Up MFA Policy* (ask when true) or *Step-Down MFA Policy* (always ask except when true) | **overrides the other two** |
| Role | **Multi-factor Criteria** > record *Role-based multi-factor authentication* > *Multi-factor Roles* list (`multi_factor_criteria`; the record must be active) | |
| User | **Enable Multi-factor Authentication** on the user record | |

**MFA with SSO** (available since San Diego): the platform's MFA is asked after the identity provider has authenticated the user. **Multi-factor Authentication > Properties**: tick *Enable Multi-factor authentication* and *Enable Multi-factor Authentication with SSO* (`glide.authenticate.mfa.with.multisso.enabled`); then add conditions to the MFA policy on **Authentication Scheme** and **Identity Provider**. Roles `adaptive_auth_admin` and `sso_config_admin`.

## User side

- First login when required: the setup screen offers an authenticator app, a biometric, passkey or hardware key, or an emailed code; **Bypass Setup** / **Postpone setup** works as many times as the admin allows.
- Voluntarily or to add factors: profile > related link **Configure Multi-factor Authentication** (register biometric, hardware key, change authenticator app). **A user cannot switch MFA off again**; only an admin can.

## Resetting a locked-out user

Role `adaptive_auth_admin`:

1. **Multi-factor Authentication > User Multi-factor Setup**: set **Validated** to false on the user's row (or delete it) to drop the authenticator app pairing.
2. **Web Authentication > User Public Credentials** (`sys_user_public_credential`): delete the user's rows (passkeys, biometrics, keys).
3. **User Recent Used Factors**: delete the user's rows.

At next login the user sees the setup page. If the locked-out person is the only admin, another admin does it; if nobody can log in, there is a self-service MFA reset catalog item on the support portal. The troubleshooting page names the tables `user_multifactor_auth`, `sys_user_public_credential` and `sys_user_multi_factor_setup`.

Other causes of "code incorrect": clock difference (app); notification preferences or outbound email (email code); SMS provider inactive or wrong mobile number (SMS). Debug properties: `glide.webauthn.debug.enabled`, `glide.authenticate.policy.debug`, `glide.authenticate.multifactor.enforcement.debug` (create it).

## Monitoring

- **Multi-factor Authentication > MFA Dashboard** (refreshed daily): share of password-login users enrolled; **privileged admins without MFA** (users holding a role listed in `sys_icenter_role_config`); factors used; share of password logins without MFA.
- Security Center > Security Metrics: users enrolled, users using bypass, high-privileged users without MFA, locked-out MFA users, local logins not protected by MFA.
- Reference lists: *Multi-factor Browser Fingerprints* (remembered browsers), *User Multi-factor Setup* (**Bypasses remaining**, **Validated**).
- **Adoption Services > Guided Setup > Multi-factor Authentication** walks through the configuration.

## Discrepancies in the docs

- The exemption FAQ first says members of the MFA Exempted User Group are "enforced with MFA", then (correctly, by the rest of the page) that they are not.
- The MFA context page here is a duplicate of the one in the adaptive authentication chapter.

## Related

- [[Adaptive Authentication]] · [[Local Authentication - Login, Password Policy and Password Reset]] · [[Zero Trust Access - Session Access and Continuous Authentication]] · [[Explicit Roles and Elevated Privilege Roles]] · [[Non-Interactive Users]] · [[Create a User]]
