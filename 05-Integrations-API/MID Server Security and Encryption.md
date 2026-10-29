---
type: concept
tags: [concept, integrations, security, discovery]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage instance data sources > MID Server > Securing and encrypting MID Server data (certificate check policies, encrypt or decrypt config.xml values, configuration file security, DPAPI, CyberArk, change schemes, ISecuredConfigProvider, IMidServerEncrypter, authentication credentials and SOAP requests, unified key store, mutual authentication, Azure Key Vault integration, command audit log, rekey, SSL certificates, SSH algorithms, script file sync, FIPS Enforced Mode, MID Server Governance), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/mid-server/mid-server-security-encryption.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# MID Server Security and Encryption

From the Brazil docs; not tested. Install side: [[Install a MID Server]]; credential vaults: [[External Credential Storage and CyberArk]]; client-accessible secrets: [[Configure Client-Accessible Secrets for a MID Server]].

## How credentials reach the MID Server

On first read the MID Server replaces the clear `mid.instance.password` in `config.xml` with an AES-256 encrypted value. Each MID Server has a **key pair** created at validation; the instance decrypts a stored credential and re-encrypts it with the MID Server's public key, sends it over TLS, and the MID Server decrypts it in memory only.

- **Validate / Invalidate** (related links): only validated MID Servers get automation credentials; invalidate clears memory, restarts and makes a new key pair.
- **Rekey** (related link): new private key, then auto-validated again. Not available with mutual auth or a custom key pair.

## Protecting config.xml

- Any parameter can get `secure="true"`; after restart it reads `value="encrypted:..."`. To decrypt: stop, set `secure="false"`, put the clear value back.
- One **secured configuration provider** at a time: the **default** provider (default encryptor, **Windows DPAPI** with `mid.secure_encrypter = com.service_now.mid.services.config.WindowsDPAPIEncrypter`, tied to the service user, or a custom `IMidServerEncrypter` with `initialize`, `encrypt`, `decrypt`), **CyberArk** (`mid.secure_config.provider = com.service_now.mid.services.config.CyberArkSecuredConfigProvider`, `JavaPasswordSDK.jar` in `agent/extlib`, values like `cyberark: id=<account>, type=<platform>`), or a custom `ISecuredConfigProvider` (`initialize`, `isParameterValueSecured`, `secureParameterValue`, `unsecuredParameterValue`; in `snc-automation-api.jar`).
- Changing scheme: stop, put every encrypted value back in clear text, switch provider, restart.

## Certificate check policies

**MID Server > MID Security Policy** (`mid_cert_check_policy`) controls all HTTPS from the MID Server: checks = certificate chain, hostname (SAN dNSName, legacy CN), revocation by **OCSP** or **CRL** (CRLs cached locally; Let's Encrypt dropped OCSP on 2025-05-07, hence CRL). Policies: **ServiceNow endpoint** (system default), **Internet**, **Intranet** (reserved subnets; checks off by default for upgraded customers), **Overridden** (highest precedence). Self-signed endpoints: import into the trust store or relax that policy.

`config.xml` bootstrap parameters `mid.ssl.bootstrap.default.check_cert_hostname` (true), `.check_cert_chain`, `.check_cert_revocation` (false); `mid.ssl.use.instance.security.policy` (false = keep bootstrap values, avoids breaking new installs that cannot reach OCSP). Self-hosted instances add `mid.ssl.bootstrap.default.target_endpoint = <instance FQDN>`.

## Trust store

Add CA certificates to the bundled JRE `cacerts` with `keytool -import -alias <alias> -file <cert> -keystore <agent>\jre\lib\security\cacerts` (default password `changeit`), or point to an **external trust store** that upgrades do not overwrite (`wrapper.java.additional.N=-Djavax.net.ssl.trustStore=...` and `...trustStorePassword=...` in `wrapper-override.conf`; import the bundled certificates into it first). Upgrade migration: `mid.truststore.migration.strategy` = `migrate_delta` (default), `migrate_non_ca`, `do_not_migrate`; backups in `agent\work\truststore_migration\<epoch>\` (`cacerts_before`, `cacerts_from_upgrade`).

## Unified key store and mutual authentication

- `agent_keystore` holds certificates and key pairs shared by all MID features. `bin/scripts/manage-certificates.(bat|sh)` from the agent folder: `-a <alias> <PEM>` add, `-g` show, `-l` list, `-d` delete, `-r` remove all except `DefaultSecurityKeyPairHandle`, `-m` switch to mutual auth, `-b <user> <password>` back to basic auth. A custom certificate disables **Rekey** and adds **Remove custom keypair** (invalidate also reverts). Linux installs can hang on low entropy (`/proc/sys/kernel/random/entropy_avail`; install rngd or haveged). Since Tokyo, automatic backups go to `security_backup` with `keystore_backup_audit_trail.log` (properties `mid.keystore.max_backups`, `mid.keystore.max_live_backups`, `mid.keystore.backup_overwrite_timespan`); restoring needs `keypairs.mid_id` to match and the `delete_mid_keypair` ECC outputs marked processed before revalidating.
- **Mutual authentication** (client certificate instead of user and password): certificate-based authentication must be enabled on the instance (ask ServiceNow support; not on on-prem or Edge Encryption instances). RSA 2048 only, PEM bundle with PKCS#8 key, CA-signed (no self-signed; private CA only if its OCSP/CRL endpoints are reachable by the instance). Upload intermediate + root to **CA Certificate Chain** (`sys_ca_certificate`, type CA Cert, wait for Publish Status = Exists), create a **`sys_user_certificate`** record named after the MID Server with User Role = MID Server and only the leaf certificate attached, invalidate if validated, then `manage-certificates -m` on the host. New mutual-auth MID Servers get no capabilities automatically; they cannot be rekeyed or validated by UI action.

## Azure Key Vault (External Credential Storage)

Plugin **External Credential Storage and Management** (`com.sn_mid_extcredstrg`). Inside Azure: give the VM a system-assigned identity with the Key Vault administrator role on the vault. Outside Azure: an app registration with Key Vault API permission and `config.xml` parameters `ext.cred.azure.vault_name` (optional), `ext.cred.azure.tenant_id`, `ext.cred.azure.client_id`, `ext.cred.azure.secret_key` (all `secure="true"`), or a PEM certificate added as alias `AzureKeyVaultSecurityKeyPairHandle` (app v1.1.1+). Credential ID = `<secret_name>` if the vault name is set, else `<secret_name>:<vault>`. Each secret is JSON with a `type` (`ssh`, `windows`, `vmware`, `snmpv3`, `aws`, `azure`, `gcp`, `api_key`, `basic_auth`, `jms`, `keystore`, ...). Government clouds override `ext.cred.azure.vault_auth_endpoint` and `ext.cred.azure.endpoint_scope`.

## Other controls

| Control | How |
|---|---|
| **Basic auth on SOAP** | **System Properties > Web Services > Require basic authorization for incoming SOAP requests**; with strict security, the MID user needs access to the tables it writes. NTLM-only proxies are not supported |
| **Command audit log** | MID Server property `mid.log.command_audit.enable = true`; **MID Server > Command Audit Logs** (`ecc_agent_command_audit_log`, role `agent_security_admin`, rotated every 7 days): command or script name and content hash, success = ran (not = worked), JEA profile if any; Discovery only, PowerShell and SNC SSH |
| **SSH algorithms** | properties `mid.ssh.algorithms.kex`, `.host_key`, `.cipher`, `.mac`; plain list replaces the default, `+` appends, `-` removes, `^` puts first. Glide Import (SFTP/SCP on the instance) ignores them |
| **Script file sync** | **MID Server > Script Files** (`ecc_agent_script_file`, domain separated), **Use attachment**; the last attachment wins and syncs to `\scripts\<parent>` on each MID Server; avoids browser download blocking |
| **FIPS Enforced Mode** | Rome+ with JRE 11.0.9+; `agent/bin/scripts/set-fips-enforced-mode.(bat|sh) on` while stopped (external JRE: convert trust store to BCFKS, `keystore.type=bcfks`, `-Dorg.bouncycastle.fips.approved_only=true`). Disables SNMP v1/v2, SNMPv3 none/MD5/DES, some SSH algorithms; `ecc_agent` shows FIPS Enforced |
| **Governance** (off by default) | system property `mid.inactivity.timeout.enabled = true`, `mid.inactivity.timeout.days` (default 30; per-MID config parameter override, 0 = never). Hourly activity check on ECC traffic; inactive MID Servers are invalidated and shut down; warnings 3-7 days and under 3 days before; **Clear auto invalidated** to bring one back. **Purpose** field is descriptive only |

Windows SMB hardening and the `mid_server` / `security_admin` conflict are in [[Install a MID Server]].

## Related

- [[MID Server Overview and Architecture]] · [[Certificates on the Instance - Formats, Trust and Upload]] · [[Certificates in Authentication - Certificate Login, Mutual TLS and Outbound Certificate Policies]] · [[External Credential Storage and CyberArk]]
