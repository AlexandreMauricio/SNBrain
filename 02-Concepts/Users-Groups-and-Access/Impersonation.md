---
type: concept
tags: [concept, users, roles, security, release-specific]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Monitoring user activity", topics "Impersonating users", "Impersonation logs", "User impersonation auditing" (pp. 446-453), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# Impersonation

**In one line:** impersonating lets an administrator (or a user with `impersonator`) use the instance exactly as another user, with that user's menus, roles and preferences, mainly for testing.

## How it works

- User menu (profile picture), **Impersonate User**, pick from recent impersonations or type a name. **End Impersonation** returns. **Impersonate another user** switches.
- Role: `impersonator` (cannot impersonate admins) or admin.
- **Everything done while impersonating is recorded as done by the impersonated user.**
- It ends when you impersonate someone else or the session ends.
- The target account must have a **User ID**, otherwise: "The user you selected could not be impersonated".
- Impersonating a locked-out or inactive user logs you out at the next action.
- Stuck on a broken page: go to `https://<instance>.service-now.com/logout.do` and log in again.
- The button's visibility: **System properties > UI properties**, *Enable impersonation button in the banner line*. Admins can still use the `impersonate_dialog` UI page.

## Limits

- Scope-protected roles and encryption module roles only come with impersonation if the module access policy allows impersonation.
- Impersonating a user with an **application-specific admin role** (HR admin, Security Incident Response) does not give access to that application's protected data unless the impersonating admin already has those roles. Admins also cannot change the password of such users.
- A user with `snc_read_only` stays read-only even when impersonating an admin ([[Role Management]]).

## Testing accounts the guide recommends

An admin account to do the work, an `itil` (or similar) account to test as a technician, and an end-user account with no roles.

## Logging and auditing

| Mechanism | Setting | Where |
|---|---|---|
| Start and end events | *Impersonate Begin* and *Impersonate End* in the system log | |
| Interactive sessions | `glide.sys.log_impersonation` | system log |
| Non-interactive sessions (scripts, applications) | `glide.sys.log_impersonation.non_interactive` (off by default); exclude users with `glide.sys.log_impersonation.non_interactive.exclusion`. The default users `system`, `soap.guest` and `guest` are never logged | impersonate log |
| **User impersonation auditing** | plugin `com.glide.security.audit`, property `glide.audit.user.impersonation.enabled` | **System Logs > User Impersonation**: per session **Impersonated by**, **Impersonated to**, start and end time, and every action in order (URL, SQL count, business rule count, response time) |

Impersonation audit records follow the transaction log retention (seven days by default).

## Related

- [[Users, Groups and Roles Overview]] · [[User Sessions and Timeouts]]
