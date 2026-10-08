---
type: troubleshooting
tags: [troubleshooting, integrations, discovery, automation, security, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Connections and Credentials (read in full 2026-10-08) - Credentials troubleshooting, Create and test your credentials, Credential aliases for Discovery, Credential affinity, External credential storage, CyberArk credential storage integration. https://www.servicenow.com/docs/r/platform-security/connections-and-credentials/r_CredentialTroubleshooting.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Credentials Fail in Discovery or Orchestration

**Symptom:** a probe, pattern, Orchestration activity or flow step reports an authentication failure or "no credentials", although a suitable credential exists on the instance.
**Cause:** the MID Server did not try the credential you expect (filtered out by type, alias, MID Server visibility or the exclusion list), or tried it and the target refused it (wrong secret, missing privileges, lockout).
**Fix:**

| Check | Why |
|---|---|
| The credential is **Active** and of the right **type** for the probe | only matching types are considered |
| **Applies to** includes the MID Server that ran the job | others do not have the credential |
| The schedule's **credential aliases** include one carried by the credential | with aliases on a schedule, untagged credentials are dropped even if they worked before |
| **Order** | many wrong attempts before the right one can lock the account; put the likely one first |
| User name format and stray spaces | Windows: `DOMAIN\user` or `user@domain`; the form warns about spaces |
| Privileges on the target | a login that works may still lack rights (sudo entries, local administrator, UAC) |
| SSH key + sudo | needs `NOPASSWD` in sudoers |
| Wait five minutes or update a credential record | after every credential failed, the MID Server puts the IP address on an **exclusion list** in memory and stops trying; cleared after five minutes, a MID Server restart, or a credential update |
| External storage switched off and on | external credentials were set inactive and must be reactivated by hand |
| Vault lookups by IP address returning several accounts | set `ext.cred.type_specifier` on the MID Server |

## How to confirm the cause

- **Test credential** on the credential record against the target's IP address through the same MID Server. Messages distinguish a TCP connection failure (wrong target or port), an authentication failure, and a wrong MID Server (Windows credentials need a Windows MID Server).
- The `<credentials_debug>` section of the ECC queue input payload: appears automatically when credentials fail for the WMIRunner, PowerShell, JMS or SSHCommand probes, or always when probe parameter `credentials_debug` is true (WMIRunner, PowerShell, SSHCommand). It lists the types, tags and affinities searched, the target IP address, and each credential tried in order (type, classification, tag, name, sys_id, external id). For PowerShell it also says whether the MID Server's own service account was used after the others failed, whether credentials were skipped because the target is the MID Server host, and whether `mid.powershell.use_credentials` is on. For SSH it says whether the search was skipped because the address is excluded.
- Vault problems: MID Server log lines starting `Problem with client's CredentialResolver:`.
- Affinity: table `dscy_credentials_affinity` for the device.

## Related

- [[Connections, Credentials and Aliases]] · [[Credential Types Reference]] · [[External Credential Storage and CyberArk]] · [[LDAP Login or Import Problems]]
