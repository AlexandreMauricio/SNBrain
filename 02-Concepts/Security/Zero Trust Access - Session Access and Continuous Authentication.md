---
type: concept
tags: [concept, security, access-control, roles, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Zero Trust Access (whole section, 23 topics, 806 cleaned lines, read in full 2026-10-08 through the docs site) - Explore ZTA, Activating, Configuring Session Access role, System properties, Session Access Audits, Tutorial, IDP attribute for Session Access, ZTA for Mobile; Continuous Authentication (exploring, policies, metrics, system properties, pre-work, activating, configuring, tutorials for a table and a data class, high assurance sessions for SSO and non-SSO logins, audit logs). https://www.servicenow.com/docs/r/platform-security/session-access.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Zero Trust Access - Session Access and Continuous Authentication

**In one line:** two licensed features built on adaptive authentication policies: **Session Access** starts a risky login (wrong network, country, device) with fewer roles than the user really has, and **Continuous Authentication** makes a logged-in user prove who they are again (MFA or SSO) before touching protected tables.

From the Brazil docs. The policies they use (IP, location, role, group, identity provider attributes): [[Adaptive Authentication]].

## Session Access (policy based session access)

Plugin **Zero Trust - Policy Based Session Access** (`com.snc.zero_trust_session_access`; paid). Configuration needs elevated `security_admin`.

**Zero Trust Access > Session Access Role Configurations > New** (the tutorial writes the menu as *Session Access*):

| Field | Meaning |
|---|---|
| **Name**, **Description** | |
| **Policy** | an adaptive authentication policy; when it evaluates true at login, the action applies |
| **Action** | **Remove Roles**: the listed roles (and their child roles) are dropped for the session. **Limit To Roles**: only the listed roles (and children) are kept |
| **Role List**, **Group List** | the roles, or the groups whose roles, to remove or keep |

What it does and does not do:

- **Evaluated at login only.** A user who changes network mid-session, or was already logged in when the policy was created, keeps their roles until they log in again.
- Nothing is changed in `sys_user_has_role` or group membership: only the session's roles.
- `snc_internal` and `snc_external` are never removed.
- Scripts running in **system context ignore** the reduced roles. Integrations are not supported.
- No effect on a user who does not hold the roles named.
- The user sees a message in their profile with a **correlation id** = the sys_id of the audit record.

With an identity provider: add a **policy input** from a SAML or OIDC attribute (for example a risk score sent by the provider) and a **policy condition** on it.

Properties (shown by label; names given only for some):

| Property | Meaning |
|---|---|
| Enable Zero Trust Session Access | off by default; without it configurations do nothing |
| Enable debug logging | |
| Preference when a role is in both a remove set and a limit set | *Remove Roles* or *Limit Roles* wins |
| Days to keep session access audit data | 30 (max 180) |
| `glide.authenticate.session_access.log_audit_event` | write audit rows |
| `glide.authenticate.session_access.user_info_message` | text shown to the user. Only the default message is translated automatically; for a custom one create `sys_ui_message` rows with code `session_access_info_message_code` and key = the property value |
| `glide.authenticate.session_access.mobile.enabled` | apply to the mobile apps (also tick **Enable Zero Trust Access** on the mobile app's OAuth application registry record) |
| `glide.authenticate.session_access.mobile.refresh_token_interval` | seconds after which the mobile refresh token is revoked when the policy uses provider attributes (default 1,800; between access token and refresh token lifespans) |

**Session Access Audits**: user, session id, policies applied, roles removed or limited to (and through which groups), provider attribute, IP address, mobile client.

## Continuous Authentication (CA)

Plugin **Zero Trust - Continuous Authentication** (`com.snc.zero_trust_continuous_authentication`; licensed). Elevated roles: `ca_admin` (policies, properties, metrics), `ca_policy_admin` (policies), `ca_auditor` (read policies, logs, metrics).

**Continuous Authentication > Policies > New**: **Policy Name**, **Description**, resources = **Table**(s) or a **Data Class** (data classification, later chapter) > **Save & Activate**. The policy **creates ACLs** on the selected tables (**View ACLs** on the policy).

When a user reaches a protected table they must **Authenticate**:

| Logged in with | Asked for |
|---|---|
| local password or LDAP | platform MFA (the factor they used last); a user without MFA must set it up |
| SSO (SAML or OIDC) | the same SSO again, or the provider's MFA. Needs the Multi-Provider SSO plugin and the *Continuous Authentication* tab filled on the identity provider record; OIDC redirects to `api/now/continuous_authentication/high_assurance/oidc/consumer`, which must be registered at the provider. Scripts `ContinuousAuth_Okta_StepUp_Script` and `ContinuousAuth_Azure_StepUp_Script` exist for step-up with those providers |

Success opens a **high assurance session**; when it expires the user is asked again. A user can open one in advance: user menu > **Profile** > related link **Create High-Assurance Session**.

| Property | Meaning |
|---|---|
| `glide.zta.continuous_authentication.enabled` | the feature |
| `glide.zta.continuous_authentication.debug.enabled` | debugging |
| `glide.zta.high_assurance.session.timeout` | minutes a high assurance session lasts (1 to 480). **Default given as 10 on the properties page and 30 on the high assurance page** |
| `glide.zta.default.high_assurance.session.lifespan` | minutes of high assurance granted automatically at login, local logins only (default 5) |
| `glide.zta.high_assurance.session.message` | text shown when asking |
| `glide.zta.high_assurance.session.max.login.failed_attempts` | failed attempts before lock-out (3 to 10) |
| `glide.zta.high_assurance.mobile.session.allowed` | true (default): mobile app sessions are **not** asked; false blocks them |
| `glide.zta.continuous_authentication.audit.lifespan` | days of audit kept (1 to 180) |
| `glide.zta.continuous_authentication.policy.lifespan` | days after which deactivated policies are deleted |

- Cannot be protected: `sys_properties`, `sys_continuous_auth_policy`, `sys_user`. Selecting a metadata table gives an error to make you reconsider.
- Metrics tab: number of policies, protected classifications, failed re-authentications, times policies were invoked (180 days).
- Log: `continuous_auth_log.list` (method, correlation id, session details).

## Related

- [[Adaptive Authentication]] · [[Access Control Lists (ACLs)]] · [[Explicit Roles and Elevated Privilege Roles]] · [[User Sessions and Timeouts]] · [[Security Attributes, Security Data Filters and Field Query Controls]]
