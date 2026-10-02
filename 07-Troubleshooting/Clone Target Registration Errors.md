---
type: troubleshooting
tags: [troubleshooting, instance-admin, security]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Instance Clone reference", topic "Troubleshooting for registering target instance" (pp. 731-732), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Clone target registration errors

**Symptom:** registering a target instance for cloning fails with a credentials error, a system property error, or an IP authentication error.
**Cause:** one of three things, below.
**Fix:**

| Error | Cause | Remedy |
|---|---|---|
| Credentials | wrong credentials for the target. Before Australia Patch 5 the user must exist in `sys_user` on the target (a local record or via LDAP); SSO redirection only works when both instances are on Australia Patch 5 or later | give credentials of a target user with the admin role; with OAuth, check the OAuth configuration and that the provider is reachable from both instances |
| System property | `glide.db.clone.allow_clone_target` is false on the target | **System properties > All properties**, set it to true. It is true by default only on instances named ...Dev, Test, Stage, UAT or QA. On a production instance, set it back to false afterwards |
| IP authentication | the target uses IP range based authentication and the request comes from outside the allowed range | allow the range `10.0.0.0` to `10.255.255.255` on the target |

## How to confirm the cause

Read the error text on the registration form, then check the property value and the IP access rules on the target.

## Related

- [[Register a Clone Target Instance]] · [[Instance Clone Overview]]
