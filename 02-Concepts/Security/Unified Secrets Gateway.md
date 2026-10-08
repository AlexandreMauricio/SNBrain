---
type: concept
tags: [concept, security, integrations, access-control, roles, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Encryption > Unified Secrets Gateway (whole chapter, 9 topics, 207 cleaned lines, read in full 2026-10-08 through the docs site) - Unified Secrets Gateway, Exploring, Configuring, Role requirements, Create an alias group, Create an identity group, Create consumer grants, Add members to an identity group, Using. The Secrets API reference itself is not part of this guide and was not read. https://www.servicenow.com/docs/r/platform-security/usg-landing.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Unified Secrets Gateway

**In one line:** Unified Secrets Gateway (USG) is a deny-by-default front door for reading secrets stored on the instance (credentials, API keys, tokens): a caller gets a secret only if a *consumer grant* links an *identity group* it belongs to with the *alias group* holding the secret, and every attempt is logged.

From the Brazil docs. Built on [[Key Management Framework (KMF)]]. Credential records themselves: [[Connections, Credentials and Aliases]]. The older, retiring feature with a similar aim: [[Secrets Management - Secret Groups and Client-Side Secrets]].

## The three records

| Record | Answers | Table | In the base system |
|---|---|---|---|
| **Alias group** | which secrets | `sys_secret_alias_group` | `mid-creds`, `outbound-security` |
| **Identity group** (and members) | who | `sys_secret_identity_group`, `sys_secret_identity_group_member` | `mid-all` (all MID Servers, system managed) |
| **Consumer grant** | the link between them | `sys_secret_alias_consumer` | *Default MID alias consumer*, *Outbound Security Alias Consumer* |

Several grants give different groups different rights (production MID Servers to database credentials, an integration service to API keys).

### Alias group fields

| Field | Notes |
|---|---|
| **Alias Group Name** | the logical name used in API calls |
| **Target Table** | the table that holds the secrets, for example `discovery_credentials` |
| **Alias Field** | the column that identifies one secret, for example the name |
| **Value Field** | the column holding the secret; `*` returns the whole credential object |
| **Filter Mode** | *none* (instance level) or *mid_scoped* (MID Servers only) |
| **Glide Access Policy** | *configurable* (default) or *lockdown* (deny everything) |

### Identity group and members

**Name**, **Managed By** (*manual* or *system*). Member: **Identity Group**, **Member Table** (for example `ecc_agent` for MID Servers), **Member Record**. Create a custom group only to restrict access to a subset.

### Consumer grant

**Alias Group**, **Consumer Type** (*identity_group* or *sys_service*), **Consumer Location** (*external*, such as MID Servers, or *glide* for the platform itself).

There are no menu modules in these pages: each list is opened by typing `<table>.list`. Roles: `admin` or `sn_kmf.cryptographic_manager`.

## Reading a secret

- Java API: `SecretsAPI.getSecret()` and `SecretsAPI.getSecrets()`.
- Server API: a scriptable equivalent for business rules, flows and background scripts (signature not given in this guide: ?).
- The call names the alias group and the alias. The caller's identity is taken from the execution context, so it cannot be passed in or faked. Granted and denied attempts are both logged (where is not stated: ?).

## Related

- [[Key Management Framework (KMF)]] · [[Connections, Credentials and Aliases]] · [[External Credential Storage and CyberArk]] · [[Secrets Management - Secret Groups and Client-Side Secrets]]
