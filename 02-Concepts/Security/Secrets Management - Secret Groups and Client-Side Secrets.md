---
type: concept
tags: [concept, security, integrations, discovery, admin, roles, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Platform Security > Secrets Management (whole chapter, 20 topics, 1,015 cleaned lines, read in full 2026-10-08 through the docs site) - Exploring Secrets Management, About client-side Secrets Management, Configuring client accessible secrets (seven-step example and the WMI test), Cloning and Secrets Management, Secrets Management dashboard, roles, Create a secret group cryptographic module, basic secret group, secret group with criteria, Upload a public key, Run Secrets Management security jobs. https://www.servicenow.com/docs/r/platform-security/secrets-management.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Secrets Management - Secret Groups and Client-Side Secrets

**In one line:** passwords stored in Password2 fields (credentials, email accounts ...) are put into **secret groups**, each encrypted by its own cryptographic module with its own access policies; a *client accessible* group goes further and encrypts with your public key, so that only a MID Server holding the private key, and not the instance or ServiceNow, can decrypt.

From the Brazil docs. Steps for the client-side variant: [[Configure Client-Accessible Secrets for a MID Server]]. Credentials themselves: [[Connections, Credentials and Aliases]]. The alternative of keeping secrets in an outside vault: [[External Credential Storage and CyberArk]].

> **Secrets Management Enterprise is being retired**: end of sale and end of renewal as of Yokohama. For two-way encrypted passwords the docs point to Password2 encryption with the Key Management Framework.

## Two editions

| | Core | Enterprise |
|---|---|---|
| Availability | plugin `com.glide.sm.core`, present by default, no cost | subscription (the first ServiceNow Vault licence), activated by ServiceNow |
| Secret groups with criteria | only on the shipped (non-custom) tables prepared by ServiceNow | any criteria: scope, package, table, column, record |
| Client accessible secrets | no | yes |
| Dashboard | no | yes |

## Why not plain Password2

Password2 access is controlled per application scope: whoever may use the scope's module may decrypt every secret in it. A secret group narrows that to a set of secrets you define, with its own module access policies (who may use the key, and for how long a key is valid).

## Secret groups

| Kind | Contains |
|---|---|
| **Basic secret group** | any secrets you add by hand |
| **Secret group with criteria** | every Password2 value matching the criterion: *Scope*, *Package*, *Target table*, *Secret column*, or *Filter record* (a column and value on the table) |

| Secret type | Decryption |
|---|---|
| **Instance accessible** | by the instance, through the group's cryptographic module |
| **Client accessible** | only with the private key held on the client (the MID Server) |

Form fields (**Secrets Management > Secret Groups > New**): **Group Name** (lowercase letters, digits, underscore), **Secret Type**, **Autogen Module** (create a cryptographic module for the group; on by default), **Crypto Module** (when not generated), **Short Description**, **Criterion Type**, then according to the criterion **Target Scope**, **Target Package**, **Target Table**, **Secret Column**, **Filter Column** + **Filter value**. **A new group is inactive**: tick **Active** afterwards.

- With criterion *Package* and a generated module, an existing Password2 sub-module is used (or the instance-level module); only Enterprise can deselect **Autogen Module** there.
- New records matching the criteria are encrypted with the group from then on; **existing records need a security job**.
- Buttons: **Manage instance access** (the module access policies), **Manage client side access** (identity groups).
- A cryptographic module can also be created first: **Secrets Management > Create Secret Group Crypto Module** (instance accessible or client accessible), with **Default module access policy value** (rely on system default, Reject, Track) and lifecycle state Draft or Published.

## Client-side encryption, in short

1. Each secret is encrypted with a **symmetric key** (the group's module key).
2. That symmetric key is itself encrypted ("wrapped") with your **public key**, uploaded to the instance as the *identity key* of an **identity group**.
3. The **private key** stays in the MID Server's keystore. Only the pair can unwrap the symmetric key, so only a MID Server that is a member of the identity group can read the secret, at the moment it needs it.

No proxy is involved, and the instance never holds usable key material for these secrets.

## Security jobs

**System Security > Security Jobs > Create New > Secrets Management Job** (roles `sn_kmf.admin`, `sn_secrets.admin`, elevated `security_admin`):

| Field | Meaning |
|---|---|
| **Time window start / end** | daily processing window; unfinished work continues in the next window |
| **Enforcement Level** | All Tables (heavy: off-peak), Specific Tables, Specific Fields, Specific Packages |
| **Job Mode** | *Password2 to Secrets Management* (encrypt Password2 values with their group's module); *Secrets Management to Password2* (back to plain Password2 encryption); *Secret Group Enforcement* (bring everything matching one group's criteria into that group) |
| **Force rekeying data** | create a new key and re-encrypt |
| **Summary** | progress and the records that could not be processed |

Data the instance cannot decrypt (client-side secrets) is skipped.

## Tables

| Table | Holds |
|---|---|
| `sn_sm_secret_group` | secret groups (one page calls the criteria group table `sn_sm_criteria_secret_group`) |
| `sn_sm_secret_group_criteria` | their criteria |
| `sn_sm_secret` | wrapped secrets |
| `sn_sm_identity_group` | identity groups (which clients share a public key) |
| `sys_kmf_wrapped_module_key` | symmetric keys wrapped by a public key |
| `sys_kmf_crypto_module`, `sys_kmf_module_key`, `sys_kmf_crypto_caller_policy` | Key Management Framework tables, extended with the new module, key and policy types |

A clean-up job removes orphaned keys every 10 minutes.

## Roles

| Role | Can |
|---|---|
| `sn_secrets.admin` | everything below, and assign the secrets roles (the assignee needs `admin` and `security_admin`) |
| `sn_secrets.secret_manager` | view secrets and groups, usage history; create groups, filters and providers; move secrets between groups; change settings. **Cannot see secrets in clear text** |
| `sn_secrets.viewer` | view secret and group records |

Key work also needs `sn_kmf.admin` and `sn_kmf.cryptographic_manager`.

## Dashboard (Enterprise)

*Secret Group Overview*: groups by type and by criterion type, inactive groups, number of dedicated secrets (in basic groups). *Secret Group Warnings*: instance accessible groups without an active access policy, client accessible groups without an active identity module access policy, identity groups without members.

## After a clone

| Group | On the target after the clone |
|---|---|
| groups (instance or client side) that existed on the target before | work again once the missing cryptographic module is imported by XML |
| instance-side groups copied from the source | do not work until set up by hand |
| client-side groups copied from the source | work after the secret group, identity group, alias and MID Server are configured by hand |

See [[Instance Clone Overview]].

## Discrepancies in the docs

- Role names appear as `sn_secrets.admin` and once as `sn_secret.admin`; one page lists `KMF_admin` where the others say `sn_kmf.admin`.
- The secret group table is `sn_sm_secret_group` in the table list and `sn_sm_criteria_secret_group` in a procedure.
- The dashboard note about Enterprise is garbled in the source.

## Related

- [[Configure Client-Accessible Secrets for a MID Server]] · [[Connections, Credentials and Aliases]] · [[Credential Types Reference]] · [[External Credential Storage and CyberArk]] · [[ServiceNow Vault and Otto for Vault]] · [[Instance Clone Overview]]
