---
type: concept
tags: [concept, security, access-control, users, scripting, update-sets, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Authentication (read in full 2026-10-08 through the docs site) - IP range based authentication (IP address access control, find denied IP addresses; 123 lines), Limit concurrent sessions (explore, plugin, set and disable per user or role; 115 lines), Installation exits (139 lines). https://www.servicenow.com/docs/r/platform-security/authentication/c_IPRangeBasedAuthentication.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Login Controls - IP Access Control, Session Limits and Installation Exits

**In one line:** three older, simple controls around login: allow and deny rules by IP address, a cap on how many sessions a user may have open, and **installation exits**, the scripts the platform calls at login, logout, password validation and external authentication.

From the Brazil docs. The newer, more flexible way to restrict by address, role or country: [[Adaptive Authentication]] (the docs recommend its pre-authentication context over IP access control). Sessions: [[User Sessions and Timeouts]].

## IP address access control

Plugin **IP Range Based Authentication** (`com.snc.ipauthenticator`). **System Security > IP Address Access Control** (admin). No restrictions by default.

| Field | Meaning |
|---|---|
| **Type** | *Allow* or *Deny* |
| **Direction** | *Inbound* (requests arriving at the instance), *Outbound* (requests the instance makes), *Bidirectional* |
| **Range Start**, **Range End** | the addresses. No asterisks, no CIDR |
| **Specify ports**, **Ports** | limit the rule to ports (comma-separated); empty = all |
| **Enforce on MID Server** | also apply to outbound connections of MID Servers |
| **Active**, **Description** | |

Rules of the game:

- An address is blocked only if a Deny rule matches **and no Allow rule matches**: **Allow always wins**.
- To admit only known ranges: one Deny for `0.0.0.0` to `255.255.255.255` plus Allow rules for the ranges.
- You cannot lock yourself out: a rule that would block your own current address is refused. Some ServiceNow internal addresses can never be blocked.
- Inside a company network the address you see locally is not the one the instance sees (proxy, NAT): ask the network team for the outbound ranges.
- A blocked client gets HTTP 403 and uses no transaction or semaphore.
- With forwarded proxy addresses, allow rules are tried against each address in the chain, then deny rules.
- **Side effects:** MID Servers connect from their own host address: add those as Allow (direction Outbound) or they are cut off. Update set retrieval between instances needs the other instance's application node addresses allowed ([[Update Sets]]); the instance's own addresses are found through the *My IP Information* catalog item on the support portal.
- Blocked addresses are not in the system log but in the **node log** (**System Logs > Utilities > Node Log File Browser**): lines containing `Security restricted: Access restricted (<address> not authorized)`.
- Stricter mode: property `glide.ip.authenticate.strict` (hardening settings, later chapter).

## Limit concurrent sessions

Plugin **Limit Concurrent Sessions** (`com.glide.limit.concurrent.sessions`). When a user at the limit logs in again, the **oldest session is ended**; that browser is sent to the login page. Works with every interactive login method (local, LDAP, SAML, MFA).

| Property | Default | Meaning |
|---|---|---|
| `glide.authenticate.limit.concurrent.interactive.sessions` | false | switch |
| `glide.authenticate.max.concurrent.interactive.sessions` | | the maximum |
| `glide.authenticate.session.types.to.limit.concurrency` | `1` | session types counted: 1 web browser, 2 mobile browser (`1,2` for both). The mobile app (3) and non-interactive sessions (10) can never be limited |
| `glide.authenticate.limit.concurrent.sessions.across.all.nodes` | true | false counts per node only |

The limit applies only to users whose record, or one of whose roles, has **Limit Concurrent Sessions** ticked (**User Administration > Users** or **Roles**). The session type is the **Type** column of `sys_user_session`.

## Installation exits

**System Definition > Installation Exits** (admin): server-side scripts the Java platform calls and whose return value it uses. Names `Login`, `Logout`, `ValidatePassword` and `ExternalAuthentication` are reserved; another exit can **override** one of them with its own script.

| Exit | Does | Can be overridden by |
|---|---|---|
| `Login` | checks user name and password against the user record | |
| `Logout` | sends the user to the welcome page | `LogoutRedirect` (a URL of your choice) |
| `ExternalAuthentication` | authenticates from a header, parameter or cookie | `DigestSingleSignOn`, `PGPSingleSignOn` (decrypt digest or PGP tokens) |
| `ValidatePassword` | custom password validation (active since Helsinki) | `ValidatePasswordStronger` (8 characters with a digit, an upper-case and a lower-case letter) |
| `GetIntegrationSessionTimeout` | default timeout of integration sessions | |

Typical customisation, in the `Login` exit's `process` function after a successful `GlideUser.authenticate(userName, userPassword)`: set a session timeout per user or per client address before returning the user.

```js
// Login installation exit (server side, global). Fragment of process():
var clientIP = gs.getSession().getClientIP().toString();
if (clientIP.indexOf('<address prefix>') == 0)
    request.getSession().setMaxInactiveInterval(60 * 60 * 10);   // seconds; values over one day are treated as one day
return GlideUser.getUser(userName);
```

On failure the stock exit queues the `login.failed` event and returns `"login.failed"`. Password rules are better set with the password policy than with these exits ([[Local Authentication - Login, Password Policy and Password Reset]]).

## Related

- [[Adaptive Authentication]] · [[Local Authentication - Login, Password Policy and Password Reset]] · [[User Sessions and Timeouts]] · [[Update Sets]] · [[Non-Interactive Users]]
