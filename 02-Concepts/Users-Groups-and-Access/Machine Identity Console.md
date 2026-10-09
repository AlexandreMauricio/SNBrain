---
type: concept
tags: [concept, security, integrations, api, users, roles, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Identity (chapter read in full 2026-10-08) - Machine Identity Console, Exploring Machine Identity Console, Inbound integrations, Security findings (and its four finding pages), Metrics, Machine Identity Console Settings, Activating Machine Identity Console, Using Machine Identity Console. https://www.servicenow.com/docs/r/platform-security/identity/explore-machine-identity-console.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Machine Identity Console

**In one line:** the Machine Identity Console is the place to see and tidy the instance's **non-human accounts**, the integration users that external applications log in with: how many there are, how they authenticate, which look risky, and where to register a new inbound integration.

From the Brazil docs. Plugin *Machine Identity Management* (`com.glide.identity.machine_identity_management`). Role `mi_admin`. Menu **All > Machine Identity Console**. Integration users: [[Inbound API Authentication and API Access Policies]].

## Tabs

| Tab | Content |
|---|---|
| **Overview** | number of machine identity accounts and how many have high-privilege roles; unique API calls and authentication methods of the last 7 days; the security score and findings |
| **Inbound integrations** | register external applications that call the instance's APIs and store their credentials. Connection types: OAuth authorization code, client credentials, JWT bearer, resource owner password, and third-party ID token from an OIDC provider. Details in [[OAuth 2.0 Inbound - The Instance as OAuth Provider]] and [[Register an OAuth Client for Inbound REST Calls]] |
| **Security findings** | the four findings below, each listing the accounts and a recommendation |
| **Metrics** | unique API calls in the last 7 days, machine identity accounts, high-privilege machine accounts (real time) |
| **Settings** | which findings count towards the score |

Accounts with **Internal Integration User** set on the user record are left out of the console entirely.

## Findings and score

A lower score means higher risk.

| Finding | Meaning | Window |
|---|---|---|
| Accounts with no login for 100 days | non-human accounts that have called no API for 100 days | changes show at once, the score the next day |
| Accounts using Basic Authentication | accounts authenticating with user name and password | last 30 days |
| Integration accounts with Web Service Access disabled | accounts calling APIs with web service access not enabled on the user record (presumably the **Web service access only** flag: my reading) | changes show at once, the score the next day |
| Accounts performing both UI and API logins | one account used interactively and by a machine | last 30 days; a change shows after 30 days |

In **Settings** only the 100-day finding can be switched off.

What the findings point to (my summary of their intent): retire unused accounts, move from basic authentication to OAuth, mark integration users as web-service-only, and never share an account between a person and a machine.

## Related

- [[Identity Center]] · [[Inbound API Authentication and API Access Policies]] · [[OAuth 2.0 Inbound - The Instance as OAuth Provider]] · [[Security Center]] · [[Access Analyzer, Access Findings and Access Observer]]
