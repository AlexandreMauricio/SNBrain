---
type: concept
tags: [concept, security, users, access-control, admin, scripting, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Authentication > Local authentication (whole section, 24 topics, 1,055 cleaned lines, read in full 2026-10-08 through the docs site) - Login and authentication security, Define login scenarios, Logins and the employee self-service portal, Specify a login landing page, Specify lockout for failed login attempts, Make UI pages public or private, Password complexity requirements (explore, enable, properties, configure, set a password for a user, excluded passwords, unsupported characters), Password Reset (default flow, notification, properties), Remember me, logout confirmation prompt, Implement a nonce (flow and installation exit script). https://www.servicenow.com/docs/r/platform-security/authentication/local-authentication.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Local Authentication - Login, Password Policy and Password Reset

**In one line:** everything around logging in with the user name and password stored on the user record: where the user lands, account lockout, public pages, the password policy, the self-service "Forgot password" flow and the *Remember me* cookie.

From the Brazil docs. Sessions and timeouts: [[User Sessions and Timeouts]]. Rules about who may log in from where: [[Adaptive Authentication]]. Users: [[Create a User]].

## Where the user lands

| Situation | Result |
|---|---|
| Direct login | property `glide.login.home` = page for **all** users: `<page>.do`, `$pa_dashboards.do?id=<sys_id>` (Platform Analytics dashboard, the standard since Xanadu), `$dashboards.do?dashboard=<sys_id>` (Core UI dashboard), `/sp` (Service Portal). `glide.entry.loggedin.page_ess` does the same for users **without roles** |
| URL of a record while logged out | login page, then that record (or an access denied message) |
| Portal or CMS site URL | the site's **Login page** if set (login rules apply), else its **Home page** |
| Several attempts before logging in | the system remembers the **first** page asked for and goes there after login, even if the user later typed the portal URL |

With the Content Management plugin (`com.glide.cms`): **Content Management > Configuration > Configuration Page** > **Login page** forces one entry page (property `glide.entry.page.script`, script include `CMSEntryPage`). Do not put a login page there: users would log in twice. Empty = `navpage.do`.

**Public pages** (`sys_public.list`): a record with **Page** (for example `$sp`) and **Active** makes the page reachable without login. Do not deactivate the base system's public pages: many features need them.

Logout confirmation (**System Properties > System** > *Prompt user to confirm a logout request*) only works in UI versions older than Core UI.

## Lockout after failed logins

**System Policy > Script Actions** (role `password_reset_admin`):

| Script action | Does |
|---|---|
| *SNC User Lockout Check with Auto Unlock* | locks after `glide.user.max_unlock_attempts` failures; unlocks after `glide.user.unlock_timeout_in_mins` (15 minutes if unset) |
| *SNC User Lockout Check* | locks after a number of failures (default 5), no automatic unlock |
| *SNC User Clear* | on a successful login resets the failure count and sets the last login date |

Since Kingston the first and third are active on new instances. Failed attempts: **System Policy > Event Logs**, name `login.failed` (login name, time, IP address).

## Password policy

Plugin **Password Policy** (`com.glide.password_policy`), on by default; role `password_policy_admin`. Enforced when a password is **created or changed** (and at login only if the property below is on). **Password Policy > Password Policies**; the policy in force is the one on the credential store (**Password Reset > Credential Stores** > **Password policy**).

| Preset | Upper | Lower | Digits | Special | Length |
|---|---|---|---|---|---|
| Default | 1 | 1 | 1 | 0 | 8 to 100 |
| Medium | 1 | 1 | 1 | 1 | 12 to 40 |
| High | 1 | 2 | 1 | 3 | 8 to 100 |
| **Default Strong** (the default) | 1 | 1 | 1 | 1 | 8 to 100; sequence and repetition thresholds 4 |
| Custom | 1 | 1 | 1 | 1 | editable, plus an editable *Password Policy Script* |
| Advanced | | | | | *Password Rule Script* and *Password Strength Script* written by you |

Other fields: each minimum from 0 to 10; **Included Special Characters** (only these are allowed), **Excluded Special Characters**, **Disallow User Data** (no user name and similar), **Sequence Length Threshold** and **Repetition Length Threshold** (up to 8: blocks runs such as `123456`, `qwerty`, `aaaaa`). Use **Test Your Password** before submitting.

- **Password Policy > Excluded Passwords**: banned passwords (company names, locations, product names); *Exclusion List Management* ships about 5,000 common ones.
- Characters must be in the Basic Multilingual Plane; emojis are not accepted.
- Setting a user's password as admin: user record > **Set Password** > **Generate**, copy, **Save Password**; **Password needs reset** is ticked automatically so the user changes it at first login.

| Property | Default | Meaning |
|---|---|---|
| `glide.enable.password_policy` | true | the policy applies |
| `glide.enable.blacklist_password` | true | excluded passwords apply |
| `glide.apply.password_policy.on_login` | false | true forces everyone whose current password does not comply to change it at next login (can hit many users at once) |
| `glide.password_policy.user_excluded_special_char` | | enables the excluded characters field (the form pages write it `...use_excluded_special_char`) |
| `glide.validate.sys_user.password.field` | | validate when an admin edits the password on the user form or list |
| `glide.user.show.password.field` | | show the **Password** field on the user form |
| `glide.password.policy.generate.password.field.disabled` | | disable the field in the Set Password dialog |
| `glide.password_policy.debug` | | debug logging |

Instances that customised the `ValidatePasswordStronger` installation exit or the credential store may have to create `glide.enable.password_policy` themselves.

## Self-service password reset

Plugin `com.glideapp.password_reset`; role `password_reset_admin`. **Only for locally authenticated users**: not SSO, not LDAP.

1. **Forgot Password?** on the login page (target `glide.security.password_reset.uri`, default `/$pwd_reset.do?sysparm_url=ss_default`).
2. *Identify*: user name.
3. *Verify*: by default the email address on the user record (other or additional verifications can be configured, such as personal questions).
4. An email with a link arrives (notification *Password Reset - Reset Link*; link lifetime `password_reset.request.expiry`).
5. The user sets a new password under the policy.

Settings: **Password Reset > Properties**. The docs' advice on limits: about 3 verification attempts; 5 to 7 security questions.

## Remember me

Ticking it stores a cookie that logs the user in automatically on later visits; logging out destroys it.

| Property | Meaning |
|---|---|
| `glide.ui.user_cookie.life_span_in_days` | days until the cookie expires **if the user does not come back** (each visit renews it) |
| `glide.ui.user_cookie.max_life_span_in_days` | hard limit regardless of activity |
| `glide.ui.remember.me.default` | whether the box is ticked by default |
| `glide.ui.forgetme` | true removes the box, **invalidates existing cookies** and disables the feature (`security_admin`) |

If it does not persist: cookies blocked, a private window, or the maximum life span reached.

## Nonce for digest single sign-on (custom, developer work)

For digest-token SSO, a nonce makes each login token usable once and so blocks replay. The portal appends a random value to the request (for example `...&NONCE=<value>`); the instance refuses a value it has seen before with `failed_missing_requirement`. Nonces are checked for login requests only.

Pieces: property `glide.authenticate.header.nonce_key` = the parameter name; a custom table `u_authentication_nonce` with a field `u_nonce`; an **installation exit** `DigestSingleSignOnNonce` (**System Properties > Installation Exits**; server side, global scope) overriding `ExternalAuthentication`; and the stock `DigestSingleSignOn` exit set inactive. The exit reads user, digest and nonce from headers, then URL parameters, then cookies; recomputes the HMAC-SHA1 of `<user>|<nonce>` with the shared key from `glide.authenticate.secret_key`; on a match looks up the user by the field named in `glide.authenticate.header.value` (default `user_name`); then records the nonce. The full script is on the docs page (not copied here).

## Related

- [[User Sessions and Timeouts]] · [[Adaptive Authentication]] · [[Create a User]] · [[Users, Groups and Roles Overview]] · [[Explicit Roles and Elevated Privilege Roles]] · [[Email Notifications]]
