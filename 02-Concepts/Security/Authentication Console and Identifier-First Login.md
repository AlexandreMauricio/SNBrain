---
type: concept
tags: [concept, security, users, access-control, portal, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Authentication > Authentication Console (whole section, 16 topics, 637 cleaned lines, read in full 2026-10-08 through the docs site) - console overview, policy-based login experience, IFL policies, evaluation order, activation, creating policies for SSO and password, managing policies, settings, field reference, technical reference. https://www.servicenow.com/docs/r/platform-security/authentication/authentication-console.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Authentication Console and Identifier-First Login

**In one line:** a no-code console where the login page becomes **identifier-first**: the user types only a user name or email, and ordered **IFL policies** (conditions on IP address, role, group) decide whether that person is sent to an SSO provider or to the local password page.

From the Brazil docs. The SSO providers it routes to: [[Multi-Provider SSO - SAML and OIDC]]. The older allow/deny/MFA rule framework: [[Adaptive Authentication]] (a different mechanism; this one only chooses the *first* authentication method).

- **All > Authentication > Authentication Console**; role `user_authn_admin`.
- Why: the traditional login page shows every option to everyone and supports one auto-redirect IdP for the whole instance. Policy-based login supports several IdPs for different populations without the user having to choose.

## Turning it on

1. `glide.authenticate.policy_based_login_experience.enabled` = true (`sys_properties.list`).
2. Console > *Settings* > **Enable policy-based login**.
3. At least one **active** IFL policy. Until then the login flow does not change.

`login.do` and `oauth_login.do` keep working unchanged. Service Portal logins are not affected unless the portal is explicitly configured for identifier-first login (then IFL takes precedence over the portal's own login options). The Now Mobile app uses the same policies.

## IFL policy

Console > *Policies* > create:

| Field | Meaning |
|---|---|
| **Name**, **Description** | |
| **Authentication Method** | **SSO login** + **Select an Identity Provider** (needs the Multi-Provider SSO plugin and a configured IdP), or **Use Password** |
| **Conditions** | field, operator, value rows on IP address, role, group; rows combined with *and* / *or*, plus condition sets. (The overview also lists department, company, domain and location; the technical reference lists only IP address, role and group) |
| **Active** | inactive policies are kept but skipped |
| **Policy order** | number; **lower is evaluated first; the first match wins** |

## What happens at login

1. The user opens the login page. Auto-redirect rules based on non-user attributes (such as IP address) may already apply.
2. The user enters an identifier: `user_name`, or the additional field set in `glide.authenticate.multisso.login_locate.user_field`.
3. The instance finds the user and evaluates active policies in order.
4. Match: the user goes to that IdP (the identifier is passed as `login_hint` so the IdP page is pre-filled) or to the password page.
5. No match: the user's or company's **SSO Source**, then the default IdP, then the local password page.
6. Unknown identifier: an IdP with auto-provisioning (a choice if several); otherwise the password page, **so the page never reveals whether a user exists**.

## Settings tab

| Setting | Default | Meaning |
|---|---|---|
| Enable policy-based login | off | master switch |
| Enable identifier-first login | on | the identifier-first page |
| Additional login options | off | show IdP tiles so users can pick a provider directly |
| Recent identifiers; number to display | on; 3 | tiles of identifiers used before on this browser (mind shared devices) |
| SSO source-based IdP routing | off | honour `sso_source` on the user, else on the company |
| IdP routing evaluation order | before policy evaluation | whether `sso_source` routing runs before the policies (explicit assignments win) or only as a fallback after them |
| Pre-fill identifier on the IdP login page | on | send `login_hint` |
| Override cookie-based redirects | off | evaluate policies at every login instead of following the stored `glide_sso_id` cookie |
| Debug logs | off | log policy evaluation, routing decisions and outcomes |

The SSO-related settings are unavailable without the Multi-Provider SSO plugin.

## Example

Policy 100 *Staff through SSO*: group is *Example Group*, method SSO login to *Example IdP*. Policy 200 *Contractors by password*: role is `x_example_contractor`, method Use Password. *Test User*, a member of *Example Group*, types their email and lands on *Example IdP* with the address pre-filled; a contractor gets the password page (and then MFA, by the default MFA policy: [[Multi-Factor Authentication]]).

## Related

- [[Multi-Provider SSO - SAML and OIDC]] · [[Adaptive Authentication]] · [[Multi-Factor Authentication]] · [[Local Authentication - Login, Password Policy and Password Reset]]
