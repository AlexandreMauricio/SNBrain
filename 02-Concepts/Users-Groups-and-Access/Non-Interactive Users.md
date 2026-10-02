---
type: concept
tags: [concept, users, api, security, integrations]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Monitoring user activity", topic "Non-interactive sessions" (pp. 457-459) and "Create a user" (p. 353), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Non-interactive users

**In one line:** a user flagged **Web service access only** can authenticate API calls (REST, SOAP, JSON, WSDL) but cannot log in to the UI, a portal, or through single sign-on; it is the right shape for an integration account.

## How it works

- Field **Web service access only** (`web_service_access_only`) on User ([[sys_user]]). Added by the Non-Interactive Sessions plugin, on all instances since Calgary.
- New users are interactive by default.
- Setting **Identity type** to **Machine** ticks the flag automatically; Human or AI clears it.
- A non-interactive user can serve as a MID Server user if also flagged **Internal Integration User**.

| | Interactive user | Non-interactive user |
|---|---|---|
| UI or portal login | yes | no |
| SSO | yes | no |
| API calls | yes | yes |

## Setting one up

1. **User Administration > Users**, open (or create) the integration user.
2. Tick **Web service access only**. Update. Role `user_admin` or admin.
3. Give it only the roles the integration needs. With strict security, SOAP integrations need the `soap` role (or one of the narrower `soap_*` roles).

To make it interactive again, clear the check box.

## Authentication requirement

- By default every non-interactive protocol requires authentication. **System Security > High Security Settings**, *Requires authorization for incoming ... requests*, per protocol (admin elevated to `security_admin`).
- **If a request supplies credentials, they are always verified**, even where authentication is not required. To skip verification the request must send none.

## Gotchas

- Activating the plugin on an old instance can stop existing SOAP or WSDL integration users working unless they have the `soap` role.
- A Machine identity used for the basic-authentication clone fallback can no longer log in to the UI ([[Register a Clone Target Instance]]).

## Related

- [[Base System Roles]] · [[User Sessions and Timeouts]]
