---
type: concept
tags: [concept, security, access-control, roles, admin, api, domain-separation, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Authentication (chapter introduction) and Adaptive authentication (whole section, 42 topics, 1,658 cleaned lines, read in full 2026-10-08 through the docs site) - overview, activation, filter criteria (IP, role, group, location with its tutorials, identity provider attributes for SAML and OIDC), authentication policy contexts (pre, post, MFA, account recovery, session validation with activation and tutorial), authentication policies (configure, add to a context), events, properties, tutorial, Trusted Mobile apps (activate, register, manage, details, troubleshooting). https://www.servicenow.com/docs/r/platform-security/authentication/adaptive-authentication.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Adaptive Authentication

**In one line:** a rule framework around login: **filter criteria** supply facts (IP range, role, group, country, identity provider attribute), a **policy** combines them into conditions, and a **policy context** decides when the policy runs (before the login page, after credentials, for MFA, during the session) and what a true result means (allow or deny).

From the Brazil docs. Built on it: [[Zero Trust Access - Session Access and Continuous Authentication]]. Authentication methods overall (SSO, OAuth, LDAP, MFA, certificates, digest tokens, self-registration): later chapters of the same guide.

- Plugin **Adaptive Authentication** (`com.snc.adaptive_authentication`); role `adaptive_auth_admin`. Menu **Adaptive Authentication**.
- Nothing is enforced until **Enable Authentication Policy** (`glide.authenticate.auth.policy.enabled`) is on: configure first, enable last.
- Domain separation: applies per **policy condition** (its domain field); conditions in global affect every domain.
- The same filter criteria can restrict inbound REST APIs (API access policies, later chapter).

## The three parts

### Filter criteria (policy inputs)

**Adaptive Authentication > Filter Criteria**.

| Criterion | Content | Notes |
|---|---|---|
| IP | start and end address rows (single address: same value twice, or leave end empty), or network and netmask rows (CIDR) | IPv4 and IPv6 |
| Role | a condition on roles | no dot-walking; operators *is not*, *does not contain*, *is empty* and similar are not supported |
| Group | a list of groups | |
| Location | a list of countries | plugin **Zero Trust - Location Based Access** (`com.snc.zero_trust_location_access`; paid). Instance must be on ADCv2. Country comes from a third-party geolocation service using the client address (the `x-forwarded-for` header when present, otherwise the VPN exit) |
| Identity provider attribute | an attribute of the SAML response or a claim of the OIDC ID token | Zero Trust feature. SAML: run **Test connection** on the identity provider record, the attributes appear in an *Identity Provider Attributes* tab; OIDC: add them by hand. Per attribute: **Name**, **Display Name**, **Default Value** (used when missing), **Use in Adaptive Authentication** = true makes it a generic criterion |
| Generic (selectable only inside a policy) | **Authentication Scheme** (user name and password, or SSO), **Identity Provider** (reference to `sso_properties`), **Role-based MFA**, **User-based MFA** (booleans), **Trusted mobile app** | the first two need the Multi-Provider SSO plugin |

### Policies

**Adaptive Authentication > Authentication Policies > All Policies** (`sys_authentication_policy`). A policy = **Policy Inputs** (criteria picked from the collection) + **Policy Conditions** (each a logical expression over the inputs, such as *input is true*). **Several conditions are ORed**: the policy is true when any one is.

Built-in: *Allow access policy*, *Allow access pre-auth policy*, *Deny access policy*, *Global blocking policy* (blocks users and APIs before authentication; an alternative to IP Address Access Control), *Session Validation Policy*, *Step-up MFA policy*, *Step-down MFA policy*, *Allow non local login users* and *Local login deny policy* (both for SSO recovery flows). Three `DEMO POLICY` records show finished examples (local login for admins only, from a trusted range only, restricting password login for specific users).

### Contexts

**Adaptive Authentication > Auth Policy Contexts**. Each context has a **Default Policy** choice and the policy to use; its *Policy Input* and *Policy Conditions* tabs only mirror the policy (edit on the policy itself).

| Context | Runs | Default policy options | Criteria usable |
|---|---|---|---|
| **Pre authentication** | before the login page is shown | *Allow Policy* = everyone denied unless the policy is true; *Deny Policy* = everyone allowed unless it is true | only IP, location, trusted mobile app (nothing is known about the user yet) |
| **Post authentication** | after credentials or the SSO response | the same pair | all, including role and group |
| **MFA** (also under **Multi-factor Authentication > MFA Context**) | decides whether a second factor is asked; never denies | *Step-Up MFA Policy* = MFA only when true; *Step-Down MFA Policy* = MFA always, except when true | all |
| **Account recovery** (**Multi-Provider SSO > Account Recovery > Account Recovery Context**) | who may use local login to repair SSO | *Allow Policy* by default | |
| **Session validation** | every request after login | *Allow Policy* only | IP, role, group |

- The MFA context **overrides** user-based and role-based MFA settings. It covers interactive logins only: not API, basic authentication or the OAuth password grant. MFA after SSO needs `glide.authenticate.mfa.with.multisso.enabled` = true.
- An allow and a deny policy never run together in one context.
- **Lock-out risk in the pre-authentication context:** an IP range that does not include your own address blocks you, admin included. Validate before saving; the form refuses conditions that are not absolute.

### Session validation (against cookie theft)

The address of the login request is stored with the session; a later request from another address, or outside the allowed ranges, is rejected and the session ended. Authenticated sessions only; not guests, not native mobile apps.

1. **All Policies** > *Session Validation Policy*: add inputs (IP, role, group) and conditions, tick **Active**.
2. With SSO: tick **Force AuthnRequest** on the default identity provider.
3. **Properties** > `session.validation.enabled` = Yes.
4. **Session Validation Context** stays on *Allow Policy*.

## Properties

| Property | Meaning |
|---|---|
| `glide.authenticate.auth.policy.enabled` | master switch |
| `glide.authenticate.policy.debug` | debug logging |
| `glide.authenticate.global.blocking_policy.error_code` | 403 or 404 returned by the global blocking policy |
| `glide.authenticate.global.blocking_policy.error_message` | text for the 403 |
| `glide.auth.policy.ui.error.message` | message shown when a policy refuses a login |
| `glide.authenticate.preauth.allow.trusted.device` | trusted device flow |
| `glide.trusted.device.max.count` | devices per user |
| `glide.authenticate.preauth.skip.user.registration` | skip device registration for users on the trusted network |
| `session.validation.enabled` | session validation |
| `glide.adaptive.auth.log.success.event`, `glide.adaptive.auth.log.mfa.relax.event` | also log successes (post-authentication and API) and MFA relaxations |

Events table: failures are logged by default (pre-authentication can only log failures); MFA enforcement is logged by default, a relaxation appears as the same event with result false. Custom login messages in other languages: `sys_ui_message` records.

## Trusted mobile app

Lets the mobile app reach an instance that is otherwise fenced to a trusted IP range. Enable the master switch and the device trust flow, then in the **pre-authentication** policy add a condition on the *Trusted Mobile App* input (true, under an allow policy). To switch the flow off again, remove those conditions first.

User side: **on the trusted network**, profile > related link **Register a trusted mobile device** > **Add a new trusted mobile device** > scan the QR code with the app (valid 5 minutes) > log in. Afterwards the app works from any network. Devices are listed and revoked on the same page; admins see them under **Adaptive Authentication > Device Trust > Device Registration** (app id, device id, user, name, OS, app version, model). Typical failures: clock difference between phone and instance, expired QR code, device limit reached.

## Example

Deny login to everyone in *Example Group* (after the docs' tutorial):

1. **Filter Criteria > Group Filter Criteria > New**: name *Denied Groups*, add *Example Group*.
2. **All Policies > New**: name *Deny by Group*, save; *Policy Inputs* > **Edit** > add *Denied Groups*; *Policy Conditions* > **New**: *Denied Groups is true*.
3. **Auth Policy Contexts > Post Authentication Context** (the group is only known after login): **Default Policy** = *Deny Policy*, **Deny Policy** = *Deny by Group*.
4. Make sure the master switch is on.

Other patterns from the docs: allow `itil` users only from one country (allow policy with a role input and a location input); ask MFA only outside a country (step-up policy with a location input); block untrusted devices using a provider attribute.

## Discrepancies in the docs

- The filter criteria page says there are seven types and lists five, then says "four generic" and lists five.
- Creating group filter criteria is given role admin, the other criteria `adaptive_auth_admin`.
- The CIDR example gives `255.255.255.0` as *Network IP* and `25` as netmask, which looks like a mistake (?).

## Related

- [[Zero Trust Access - Session Access and Continuous Authentication]] · [[User Sessions and Timeouts]] · [[Explicit Roles and Elevated Privilege Roles]] · [[Non-Interactive Users]] · [[Access Control Lists (ACLs)]]
