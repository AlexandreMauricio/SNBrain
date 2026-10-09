---
type: concept
tags: [concept, security, users, roles, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Identity (chapter read in full 2026-10-08) - Identity Center, Exploring Identity Center, Activating the Identity Center, Identity Center for users, Viewing Active Sessions, Viewing Login History, Viewing Registered Mobile Devices, Identity Metrics for administrators. https://www.servicenow.com/docs/r/platform-security/identity/explore-identity-center.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Identity Center

**In one line:** Identity Center gives each user a page showing their own active sessions, login history and registered mobile devices, and gives administrators trend metrics on users, privileged users, integration accounts and sessions.

From the Brazil docs. Plugin *Identity Center* (`com.snc.identity_center`), installed from **System Applications > All Available Applications > All** (role `admin`).

## For a user

Open **Self-Service > My Profile** (or the user menu > profile) > related link **View Identity Center**. On Now Support the link is at the bottom of the profile.

| Tab | Shows |
|---|---|
| **Active Sessions** | sessions open on this instance, by browser, IP address and session id; a session can be extended or ended from here |
| **Login History** | logins with time, browser, IP address and status, filterable; 20 rows per page (up to 100); kept **30 days** |
| **Registered Mobile Devices** | devices enrolled for the trusted mobile app: operating system, device id, status, registration time. Only with Adaptive Authentication (`com.snc.adaptive_authentication`) and the Trusted Mobile App feature ([[Adaptive Authentication]]) |

The point for the user: spot a session or login that is not theirs and report it.

## For administrators

*Identity Metrics*: trends for users, privileged users, integration (non-human) accounts, active and inactive sessions, identity types. The same data feeds the Security Center metrics ([[Security Center]]).

## Roles

| Role | Access |
|---|---|
| `user_login_history_viewer` | login history details (timestamps, browser, IP, status) for investigations |
| `role_viewer` | read `sys_icenter_role_config` |
| `privileged_role_config_admin` (printed as `privileged_role_config_admind`) | manage which roles count as privileged in `sys_icenter_role_config`, and its reports |

## Related

- [[Machine Identity Console]] · [[Identity and Access Audit]] · [[Login Controls - IP Access Control, Session Limits and Installation Exits]] · [[Security Center]] · [[Federated ID and Global Identity]]
