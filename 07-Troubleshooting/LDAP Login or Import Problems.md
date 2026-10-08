---
type: troubleshooting
tags: [troubleshooting, integrations, import-sets, users, security, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Authentication > LDAP integration (read in full 2026-10-08) - LDAP integration troubleshooting, View the LDAP monitor, LDAP error codes, Troubleshooting LDAP integration via MID Server, Send a one-time password when the LDAP server is down, Test an LDAP connection. https://www.servicenow.com/docs/r/platform-security/ldap-integration/c_LDAPIntegrationTroubleshooting.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# LDAP Login or Import Problems

**Symptom:** LDAP users cannot log in; the LDAP server form shows a connection error; an LDAP import brings nothing or stops.
**Cause:** usually the service account (expired, locked), the network path or certificate, a user-specific directory state (password expired, account disabled), or a mismatch between the query field and the User ID.
**Fix:**

1. Service account: not expired, not locked; try `domain\user` or `user@domain` as login.
2. **Test connection** on the server record; read the error code (tables below).
3. One user only: check that user's directory state (codes 49 / 5xx) and that **Source** on the user record starts with `ldap` and **LDAP Server** is right.
4. Nobody after a clone or update set: the `system_id` on the `ldap_server_config` record points at the wrong node.
5. LDAPS: certificate expired or chain not uploaded (codes 104xx).
6. Meanwhile: local admin accounts; one-time password by email if `glide.ldap.onetime.password.enabled` is on.

## How to confirm the cause

- **System LDAP > LDAP Monitor**: connection status, listener state, last message, last change, last error.
- LDAP log (in the node log): standard LDAP codes have two digits, Active Directory data codes three.
- Verbose LDAP logging shows records dropped by the OU filter.
- Debug properties: `glide.authenticate.policy.debug` and friends ([[Multi-Factor Authentication]]) when the login is blocked after the password step.

### Codes seen most

| Code | Meaning |
|---|---|
| 49 | invalid credentials (wrong DN or password, or see the data code) |
| 49 / 52e | user exists, wrong password |
| 49 / 525 | user not found |
| 49 / 530 | not permitted to log on at this time |
| 49 / 531 | not permitted from this machine |
| 49 / 532 | password expired |
| 49 / 533 | account disabled |
| 49 / 701 | account expired |
| 49 / 773 | **user must reset password** (cannot be done through the instance) |
| 775 | account locked |
| 49 / 568 | too many security ids on the account (directory-side problem) |
| 32 | no such object (wrong base or RDN) |
| 34 | invalid DN syntax |
| 3 / 4 | time limit / size limit exceeded: incomplete results (enable paging, narrow the filter) |
| 11 | administrative limit exceeded |
| 8 / 13 | strong authentication / confidentiality required: use LDAPS |
| 50 | insufficient access for the service account |
| 51 / 52 | server busy / unavailable |
| 53 | unwilling to perform (server restrictions) |
| 10 | referral: the entry lives on another server |

Instance-specific codes:

| Code | Meaning |
|---|---|
| 10001 | malformed URL |
| 10002 | unauthenticated bind |
| 10300 to 10305 | communication exception, socket timeout, connection refused, connection reset, no route, unknown host |
| 10400 to 10403 | SSL exception, empty certificate store, certificate not found, certificate expired |
| 10500 | invalid search filter |

### Through a MID Server

Look at the ECC queue (**Discovery > Output and Artifacts > ECC Queue**):

| Action | Topic | Good result |
|---|---|---|
| Test connection | `LDAPConnectionTesterProbe` | input message with name `true` and no error in the payload |
| Browse | `LDAPBrowseProbe` | the same |
| Load | `LDAPProbe` (output, then inputs per batch of 200) and `LDAPProbeCompleted` (total count) | no `LDAPProbeError` |

- Paging fails if the directory's page size is under 1,000: set MID Server property `glide.ldap.max_results` to at most that size.
- Binary attributes (photos) need `glide.ldap.binary_attributes` on both instance and MID Server.
- The connect timeout through a MID Server is fixed at 10 seconds.

## Related

- [[LDAP Integration]] · [[Set Up an LDAP Integration]] · [[Multi-Factor Authentication]] · [[Local Authentication - Login, Password Policy and Password Reset]]
