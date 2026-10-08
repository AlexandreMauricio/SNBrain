---
type: reference
tags: [reference, security, instance-admin, admin, access-control, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Platform Security > Hardening settings, the authentication (50) and session management (23) categories. All 73 setting pages were parsed by script for the property or plugin name, recommended and default values and CVSS score; the description, security risk, functional impact and dependency text of every page was then read 2026-10-08 in a condensed form (repeated boilerplate and the generated summary blocks removed, very long introductions cut at 900 characters, risk and impact text at 600). The Remark column is our own summary. https://www.servicenow.com/docs/r/platform-security/instance-security-hardening-settings/sc-authentication.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Hardening Settings - Authentication and Session Management

**What this is:** the Security Center hardening settings of the authentication (50) and session management (23) categories: the property, plugin or record each one checks, the value Security Center expects, the base-system default, the CVSS score ServiceNow assigns to non-compliance, and what the setting does.
**Where:** Security Center > Security configuration console > Security hardening > All settings; properties themselves under `sys_properties.list`
**Role required:** `admin` (many properties need elevation to `security_admin` to change)

How the score works, baseline versions and reading rules: [[Hardening Settings - Overview and Baseline Versions]]. Working the list: [[Raise the Hardening Compliance Score]]. Other categories: [[Hardening Settings - Access Control]] · [[Hardening Settings - API, Architecture, Communications and Configuration]] · [[Hardening Settings - Validation, Files, Logging and Other]].

Reading the tables: *Default* is the value shipped on a new instance; many properties are absent from `sys_properties` and then use a fallback, which is sometimes the insecure value. *Safe-harbor* means the property cannot be set back once changed. `?` or *not stated* means the page did not give the value.

## Authentication (50)

Passwords, lockout, password reset, MFA, basic authentication, SSO.

### Multi-factor authentication and basic authentication restriction

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Activate role-based multi-factor authentication | `glide.authenticate.multifactor` | true | not stated | 7.2 High | Older page for the same property as the next row. |
| Activate role based multi-factor authentication | `glide.authenticate.multifactor`; active role-based record in `multi_factor_criteria` | true; record active | false; record inactive | 5.7 Medium | MFA for users holding roles listed in Multi-factor Criteria (admin, security_admin, user_admin); the criteria record must be active too. |
| Enable basic authentication restriction | `glide.authenticate.basic_auth.restriction.active` | true | true | 8.1 High | The basic authentication restriction gate: API calls with user name and password from interactive accounts are tracked (exception table `sys_user_basic_auth_exception`) and later refused unless exempt. Set false only in an emergency. |
| Disable email OTP for multi-factor authentication | `glide.authenticate.multifactor.email.otp.enabled` | false | true | 3.1 Low | Email is a weak second factor: hide the email one-time code option. Make sure users have another factor first. |
| Limit basic authentication restriction allowed roles | `glide.authenticate.basic_auth.allowed_roles` | snc_basic_auth_api_access | snc_basic_auth_api_access | 8.1 High | Roles exempt from the basic authentication restriction, unlogged. Keep to the dedicated role (MID Servers inherit it). |
| Limit basic authentication restriction allowed users | `glide.authenticate.basic_auth.allowed_users` | empty or reviewed service accounts | empty | 8.1 High | User sys_ids exempt from the restriction, unlogged. Empty or individually reviewed service accounts. |
| Minimize failed login attempts for high assurance sessions | `glide.zta.high_assurance.session.max.login.failed_attempts` | 5 | 5 | 3.3 Low | Failed re-authentication attempts before logout in continuous authentication. |
| Minimize one-time out of band verifier lifetime duration | `glide.multifactor.onetime.code.validity` | 10 | 10 | 3.9 Low | Minutes an emailed one-time code stays valid. Removed from the baseline in 7.0. |
| Prohibit Use of KBA as Single Factor for AI Voice | `glide.voice.authenticate.allow_kba_as_only_factor` | false | false | 3.3 Low | Security questions cannot be the only factor for the AI voice agent. |
| Reduce allowed bypasses for multifactor setup | `glide.authenticate.multifactor.setup.bypass.count` | 0 | 0 | 3.9 Low | Times a user may skip MFA enrollment. |
| Restrict basic authentication external role exemption | `glide.authenticate.basic_auth.allow_snc_external` | false | true | 8.1 High | false = external users (`snc_external`) are not automatically exempt from the basic authentication restriction. Check external integrations first. |
| Set basic authentication restriction default decision | `glide.authenticate.basic_auth.restriction.default_decision` | Revoke Basic Auth API login | Maintain current login | 8.1 High | What happens to accounts nobody reviewed when the restriction is enforced: revoke API login by password, keep UI login. Review the exception table first. |

### Registration, mobile and other

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Anti-CSRF token (instance security hardening) | `glide.security.use_csrf_token` | true | not stated | 8.1 High | Listed here as well as under access control. |
| Disable creating users from incoming emails | `glide.pop3readerjob.create_caller` | false | false | 5.4 Medium | Do not create users from inbound email senders (they would share a default password). |
| Enable CAPTCHA for customer registration | `sn_customerservice.captchaEnabled` | true | true | 3.7 Low | CAPTCHA on customer self-registration (Customer Service portal). |
| Enable CAPTCHA for external user registration | `sn_ext_usr_reg.captchaEnabled` | true | true | 3.7 Low | CAPTCHA on external user registration. |
| Enforce device encryption and passcode requirements | `glide.sg.device_encryption_enabled` | true | false | 4.2 Medium | Mobile app refuses devices without encryption and passcode. |
| Minimize external user registration link expiration duration | `sn_ext_usr_reg.Reg_link_expiration_days` | 3 or less | 3 | 6.6 Medium | Days a registration link stays valid. |
| Remove credentials from Welcome page | `sys_home` demo records | absent | n/a | Medium | Delete the demo *How to login* records showing default credentials (only with CMS demo data). |
| Require CAPTCHA for guest walk-up experience in customer service application | `sn_guest_walkup_cs.captcha.enabled` | true | true | 3.7 Low | CAPTCHA on guest walk-up check-in (Customer Service). |
| Require obfuscation of classic mobile app UI | `glide.ui.m.blur_ui_when_backgrounded` | true | not stated | 2.4 Low | Classic mobile app blurs its screen in the app switcher. |
| Require obfuscation of mobile app UI | `glide.sg.blur_ui_when_backgrounded` | true | false | 2.4 Low | Mobile app blurs its screen in the app switcher. |
| Restrict MID IPKI registration key retry attempts | `sn_mid_infra.registration_key.max_use_count` | 3-5 | 5 | 5.4 Medium | Failed uses of a MID Server registration key before it is revoked. |

### Password reset

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Control lockout time for invalid password reset attempts | `password_reset.request.max_attempt_window` | 1440 or more | 1440 | not stated | Minutes a user waits after exhausting password reset attempts. |
| Enable CAPTCHA in password reset | `password_reset.captcha.ignore` | false | false | 5.6 Medium | false = CAPTCHA is used in password reset. |
| Enable SMS code notification for enrollment and verification | `password_reset.sms.use_notify` | true | true | 3.7 Low | SMS code notification for enrollment and verification. |
| Limit Invalid Password Reset Attempts | `password_reset.request.max_attempt` | 3 or less | 3 | 7.5 High | Failed password reset attempts before lockout. |
| Maximize reset password request retry window duration | `password_reset.request.retry_window` | 1440 or more | 1440 | 7.5 High | Minutes before the reset attempt counter restarts. |
| Maximize reset password request unlock window duration | `password_reset.request.unlock_window` | 1440 or more | 1440 | 5.9 Medium | Minutes to wait before a new reset after an account unlock. |
| Maximize reset password SMS complexity | `password_reset.sms.default_complexity` | 6 or higher | 6 | not stated | Digits in the SMS reset code. |
| Maximize reset password SMS pause window duration | `password_reset.sms.pause_window` | 2 or more | 2 | 4.8 Medium | Minutes between SMS reset codes. |
| Maximize reset password verification delay duration | `password_reset.verification.delay` | 1000 or more | 1000 | 5.9 Medium | Milliseconds of delay on verification, against automated guessing. |
| Minimize reset password max SMS per day | `password_reset.sms.max_per_day` | 10 | not set (fallback 5) | 5.9 Medium | SMS reset codes per user per day. The page prints 10 as recommended and 5 as fallback. |
| Minimize reset password request expiration duration | `password_reset.request.expiry` | 10 or less | 10 | 4.2 Medium | Minutes a reset request stays valid (takes precedence over the link validity below). |
| Minimize reset password request success window duration | `password_reset.request.success_window` | 1440 or less (as printed) | 1440 | not stated | Minutes before a user may reset again after a successful reset. |
| Minimize reset password SMS expiry duration | `password_reset.sms.expiry` | 5 or less | 5 | 5.6 Medium | Minutes an SMS code stays valid. |
| Notify users during password reset/change process | pwd_process.change, pwd_process.reset | true | true | 8.1 High | Users are notified when their password is changed or reset. Removed in 1.5. |
| Set OTP lifetime for password reset to 1 hour | `glide.pwd_reset.onetime.token.validity` | 1 | 1 | 4.6 Medium | Hours the password reset link stays valid. |

### SSO, OAuth and LDAP

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Disable resource owner password credentials (ROPC) in OAuth 2 token grants | `glide.oauth.inbound.ropc.grant_type.disabled` | true | false | 3.3 Low | Turn off the OAuth password grant (ROPC); applications using it stop getting tokens. |
| Enable account recovery | `glide.sso.acr.enabled` | true | true | 6.5 Medium | Account recovery must exist before Multi-Provider SSO can be turned on; recovery sessions can only change SSO settings. |
| Enable relay state in SAML requests to prevent replay attacks | `glide.authenticate.sso.saml2.enable_relay_state_with_id` | true | true | 3.8 Low | SAML relay state carries a record id instead of a URL, against replay. |
| Enable SSL in LDAP authentication | `glide.ldap.use.ssl` | true | true | 8.1 High | LDAP over TLS. |
| Minimize SAML notBefore or notOnOrAfter constraint duration | `glide.authenticate.sso.saml2.clockskew` | less than 60 | 180 | 7.5 High | SAML clock skew in seconds; the default 180 is above the recommended value. Removed in 6.0. |

### Login, lockout and password policy

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Do not apply password policy at login | `glide.apply.password_policy.on_login` | false | false | 4.4 Medium | Removed in 2.0: old advice not to enforce complexity at login. Superseded by the opposite setting below. |
| Enable a deny-list password validation check | `glide.enable.blacklist_password`; `blacklisted_password` records | true; 5,000 or more records | true; 5,000 shipped | 5.9 Medium | New passwords checked against the Excluded Password table (at least the shipped 5,000 entries). |
| Enable password reset policy checks | `glide.enable.password_policy` | true | true | 7.4 High | Password policy checked when users change their password in the UI (not when an admin or a script sets it). Safe-harbor. |
| Enforce current password policy compliance requirements on login | `glide.apply.password_policy.on_login` | true | false | 4.4 Medium | At login, users whose password no longer meets the policy must change it. May hit many users at once. |
| Limit Allowed Number of Failed Login Attempts Before Lockout | script action *SNC User Lockout Check* (or *with Auto Unlock*); `glide.user.max_unlock_attempts` | script action active; 5 or less | not set (fallback 5) | 7.3 High | Failed logins before lockout: a lockout script action active and at most 5 attempts. |
| Maximize failed login unlock timeout duration | `glide.user.unlock_timeout_in_mins`; script action *SNC User Lockout Check with Auto Unlock* | 15 or more; active | 15 | 6.8 Medium | Minutes before a locked-out account unlocks itself (needs the *with Auto Unlock* script action). |
| Require Minimum and Maximum Password Length | `pwd_cred_store` and `password_policy` records | policy enforced; minimum 15; maximum 64 | minimum 8; maximum 100 | 5.9 Medium | Every password credential store enforces a policy with minimum length 15 and maximum 64. The page says "at most 64" in the table and "at least 64" in the text. |

## Session management (23)

Timeouts, cookies, concurrent sessions.

### Timeouts and session lifetime

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Apply continuous authentication policies to mobile sessions | `glide.zta.high_assurance.mobile.session.allowed` | false | false | 3.9 Low | false = continuous authentication policies also apply to mobile sessions. |
| Minimize absolute session timeout duration | `glide.ui.user_cookie.max_life_span_in_days` | 30 or less | 30 | 4.2 Medium | Maximum days a *Remember me* cookie can live in total. |
| Define active session timeout exception roles | `glide.active.session.timeout.exception.roles` | the default three roles | edge_encryption,mid_server,maint | 6.4 Medium | Roles exempt from the active-session lifetime: integration-type roles only. |
| Limit guest's active session life span | `glide.guest.active.session.life_span` | 1 to 720 | 0 | 4.2 Medium | Maximum minutes a guest session lives however active; 0 = no limit. Expired guest sessions are silently replaced. |
| Limit integrations' active session life span | `glide.integrations.active.session.life_span` | 1 to 720 | 0 | 4.2 Medium | Maximum minutes an integration session lives; silently replaced when exceeded. |
| Limit the policy-based mobile refresh token interval | `glide.authenticate.session_access.mobile.refresh_token_interval` | 1800 or less | 1800 | 4.3 Medium | Seconds before a mobile SSO user must re-authenticate under session access policies using IdP attributes. |
| Limit UI active session life span | `glide.ui.active.session.life_span` | 1 to 720 | 0 | 4.2 Medium | Maximum minutes an authenticated UI session lives even if active; the user is logged out. Must be at least the idle timeout. |
| Limit session length for high assurance sessions | `glide.zta.high_assurance.session.timeout` | 30 or less | 30 | 3.3 Low | Minutes before re-authentication in a high-assurance (continuous authentication) session; 1 to 480 allowed. |
| Proactively invalidate sessions after defined durations | `glide.active.session.timeout.invalidate.session` | true | false | 4.6 Medium | Timed-out sessions are invalidated by the platform at once; needs at least one of the three life-span properties. |
| Minimize session activity timeout duration | `glide.ui.session_timeout` | 30 or less | 30 | 7.5 High | Idle timeout in minutes for logged-in users (hard cap 1440 by `glide.ui.max_session_timeout`). |
| Minimize session window timeout duration | `glide.ui.user_cookie.life_span_in_days` | 15 or less | 15 | 4.9 Medium | Days until the *Remember me* cookie expires after a login (cap 30). |

### Cookies, tokens and other

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Enable UserCookie version 3.1 | `glide.ui.secure.cookies.use_kmf` | true | true | 7.1 High | User cookie signed with a key held in the Key Management Framework instead of a shared built-in key. |
| Enforce password reset on API requests | `glide.authenticate.api.user.reset_password.mandatory` | true | true | 8.1 High | Accounts flagged *Password needs reset* cannot call APIs until the password is changed. |
| Enable HTTP Only Cookie Flag | `glide.cookies.http_only` | true | true | 8.0 High | `HttpOnly` on sensitive cookies. Safe-harbor. |
| Enable MID Server governance checks | `mid.inactivity.timeout.enabled` | true | true | 4.6 Medium | MID Servers unused for a period (30 days by default) are decommissioned. |
| Invalidate Session After OAuth Token Expiration | `glide.authenticate.oauth.post.token.expiration.cookie_auth.disabled` | true | true | 6.8 Medium | A session created from an OAuth token ends when the token expires; clients must refresh or log in again (cookie-based extensions break). |
| Require JWT trust verification for guest embedded sessions | `glide.embedded.session.trust.verification.enabled` | true | true | 5.3 Medium | Guest sessions of web embeddables require a JWT proving the embedding site is trusted. |
| Rotate HTTP session identifiers | `glide.ui.rotate_sessions` | true | true | 8.8 High | New session id after login. May conflict with the old stand-alone SAML 2.0 plugin or proxies pinning the id. |

### Concurrent sessions

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Minimize concurrent interactive session quantity | `glide.authenticate.max.concurrent.interactive.sessions` | 1 | 1 | 3.7 Low | Concurrent interactive sessions per user (with the Limit Concurrent Sessions plugin). |
| Limit concurrent sessions across all nodes | `glide.authenticate.limit.concurrent.sessions.across.all.nodes` | true | true | 3.7 Low | Sessions counted across all application nodes. |
| Activate Limit Concurrent Sessions Plugin | plugin com.glide.limit.concurrent.sessions; `glide.authenticate.limit.concurrent.interactive.sessions`; `glide.authenticate.max.concurrent.interactive.sessions` | plugin active; true; a number you choose | not active | 3.7 Low | Limit Concurrent Sessions plugin active and configured. |
| Minimize Concurrent Interactive Sessions with Limit Concurrent Sessions Plugin | `glide.authenticate.limit.concurrent.interactive.sessions` | 1 | not set (fallback 1) | 3.7 Low | Turns the limit on. The page describes it as a count (1) but the plugin page describes it as a Boolean. |
| Minimize concurrent interactive session quantity | `glide.authenticate.max.concurrent.interactive.sessions` | 1 | 1 | 3.7 Low | Second page for the same property as above. |

## Related

- [[Hardening Settings - Overview and Baseline Versions]] · [[Security Center]] · [[Raise the Hardening Compliance Score]] · [[Hardening Settings - Access Control]] · [[Hardening Settings - API, Architecture, Communications and Configuration]] · [[Hardening Settings - Validation, Files, Logging and Other]]
