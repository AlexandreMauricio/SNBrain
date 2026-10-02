---
type: concept
tags: [concept, users, security, platform]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Monitoring user activity", topic "Managing user sessions" (pp. 453-457), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# User sessions and timeouts

**In one line:** a session is one browser's login (all its windows count as one); admins can end sessions, lock users out or deactivate them, and properties decide when sessions expire.

## Three ways to stop a user

| Action | Effect | How |
|---|---|---|
| **Terminate a session** | that session is logged out at its next transaction; the user can log in again. Other sessions of the user are untouched | **User Administration > Logged in users**, select the session, **Lock Out Session** (admin). You only see sessions on your own application node. Not for mobile sessions |
| **Lock out** | cannot log in, emails they send to the instance trigger nothing, and their sessions end | tick **Locked out** on the user (`user_admin` or admin) |
| **Deactivate** | no longer appears in fields that list active users; **also locked out** by the business rule *Lock Out Inactive Users* and the property `glide.authenticate.only.allow.active.user.login` | clear **Active** on the user (admin) |

In *Logged in users*, **Active** = false just means the session is not running a transaction right now.

## Timeout properties

Edit in `sys_properties.list`; add the property if it is missing. Values in minutes.

| Property | Default | Meaning |
|---|---|---|
| `glide.ui.session_timeout` | 30 | inactivity timeout for authenticated users. Keep to a few hours at most |
| `glide.guest.session_timeout` | 30 | inactivity timeout for guest sessions |
| `glide.ui.active.session.life_span` | not set | **maximum** session length whatever the activity. Must be greater than the inactivity timeout |
| `glide.guest.active.session.life_span` | not set | the same for guest sessions (e.g. Agent Chat) |
| `glide.ui.session_timeleft` | 2 | minutes before expiry at which "Extend your session" appears; 0 turns the prompt off |
| `glide.session.unauthorized.timeout.enabled` | true | shorter timeout for unauthenticated guest sessions |
| `glide.unauthorized.session_timeout` | | minutes a session lives after the user logs out; between 0 and the normal timeout |
| `glide.ui.auto_req.extend.session` | | true extends the session by the homepage refresh interval |
| `glide.security.csrf.handle.ajax.timeout`, `glide.security.auto.resubmit.ajax` | | handle and resubmit timed-out Ajax requests |

- **Remember me** on the login screen exempts the user from the session timeout properties.
- Ajax calls (labels, refreshing dashboards) and chat polling keep a session alive.

## Investigating a user's activity

Transaction logs record browser activity per user. For logins (IP address, success or failure, time window, by user name) the guide points to KB0564981.

## Related

- [[Impersonation]] · [[Non-Interactive Users]] · [[sys_user]]
