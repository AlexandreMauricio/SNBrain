---
type: concept
tags: [concept, integrations, security, discovery, automation, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Connections and Credentials > External credential storage (read in full 2026-10-08 through the docs site) - overview, Request the plugin, External credential storage configuration (resolver JAR, import, credential identifier, AWS), CyberArk credential storage integration and its configuration (vault and AIM API, JAR import, MID Server for AIM and for CCP, SNMPv2, credential identifier, AWS and Azure accounts in the vault), OAuth 2.0 authentication via MID Server using external credential storage. The sample Java resolver and the click-by-click CyberArk console steps are condensed. https://www.servicenow.com/docs/r/platform-security/connections-and-credentials/c_ExternalCredentialStorage.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# External Credential Storage and CyberArk

**In one line:** the credential record on the instance holds only an **identifier**; the MID Server hands that identifier to a **credential resolver** (a Java JAR) which fetches the real user name, password or key from a vault at the moment a probe or step needs it.

From the Brazil docs. The credential model itself: [[Connections, Credentials and Aliases]]. Types: [[Credential Types Reference]].

- Plugin **External Credential Storage** (`com.snc.discovery.external_credentials`), on request through Now Support (**System Applications > All Available Applications > All > Request plugin**).
- Switch: **Enable External Credential Storage** (`com.snc.use_external_credentials`), under **Discovery Definition > Properties** and **Orchestration > MID Server Properties**. **Turning it off sets every external credential inactive; turning it on again does not reactivate them** (do it by hand).
- Changing the switch runs business rule *External Credential Storage*: the credential list and form move to the **External Storage** view (shows **Credential ID**) and MID Servers refresh their credential cache.
- Supported out of the box: **CyberArk** (one overview page also names BeyondTrust; another says CyberArk is the only one). Anything else through a custom resolver; open-source resolver templates for HashiCorp and CyberArk are published on the ServiceNow GitHub.
- At most two vaults at a time: the default CyberArk resolver plus **one** custom resolver. One MID Server cannot serve CyberArk and a custom vault together.

## How a credential is resolved

1. The MID Server downloads the credential records, which carry the **Credential ID** instead of secrets.
2. For each probe, pattern or step it calls the resolver with the id, the target IP address, the credential type and the MID Server name.
3. The resolver (often through a vendor agent on the same machine, which does the caching) returns user, password, private key, passphrase, or SNMPv3 protocols and keys.
4. The MID Server uses it and keeps it only for seconds, encrypted in memory. Affinity and order work as usual.

Errors are logged on the MID Server with the prefix `Problem with client's CredentialResolver:`.

## Custom resolver

- A Java class `com.snc.discovery.CredentialResolver` with `resolve(Map args)`: input keys `id`, `ip`, `type`, `mid`; output keys `user`, `pswd`, `passphrase`, `pkey`, `authprotocol`, `authkey`, `privprotocol`, `privkey`; and `getVersion()`. The docs' sample reads a properties file and is a template only, not for production. It runs in the MID Server's Java process.
- Upload: **MID Server > JAR Files > New** (**Name**, **Version**, **Source**, **Description**), attach the JAR, restart the MID Server service; it is distributed to every MID Server. Roles `agent_admin` or `admin`.
- Register the vault name: **Vault Configurations** (`vault_configuration.list`), a record named after the resolver.

## The credential record

**External credential store** ticked (if the box is missing: form menu > **View > External Storage**):

| Field | Meaning |
|---|---|
| **Credential ID** | the key passed to the resolver as `id` |
| **Credential storage vault** | *None*, *CyberArk*, or a custom vault |
| **Lookup key** (CyberArk) | Credential ID, IP Address, FQDN, or All of the above (slower: several vault calls) |
| **Privacy Credential ID** | SNMPv3 with a privacy key in CyberArk: the name of the privacy account |

Length: the generic pages say 40 characters; the CyberArk page says the instance supports 180 and CyberArk 160.

## CyberArk

Requirements: the CyberArk Credential Provider (AIM) installed **on the same machine as each MID Server**, the same version everywhere, Credential Providers 12.0.1 or later; or the agentless Central Credential Provider (CCP) web service.

Vault side: an application id `ServiceNow_MID_Server` (overridable) allowed to read the safes; the accounts Discovery, Orchestration or Service Mapping need, with the provider and application users as safe members.

Instance side: import `JavaPasswordSDK.jar` from the AIM installation as a MID Server JAR file (even if it already exists on the host; it must match the installed AIM version), restart the MID Server.

MID Server `config.xml` parameters (set on the host, not from the instance):

| Parameter | Value | Meaning |
|---|---|---|
| `ext.cred.use_cyberark` | true | required |
| `ext.cred.safe_folder` | folder, for example `root` | required |
| `ext.cred.safe_name` | default safe | optional if every id names its safe |
| `ext.cred.app_id` | `ServiceNow_MID_Server` | application id |
| `ext.cred.safe_timeout` (AIM) / `ext.cred.timeout` (CCP) | 5 / 30 seconds | lookup timeout |
| `ext.cred.type_specifier` | true | an IP lookup must also match the platform id prefix (`Win` Windows, `Unix` SSH, `VMWare` VMware): needed when one address hosts several credentialed things |
| `ext.cred.check_ssh_type` | false | true: an SSH password request must not be answered with a key, and the reverse |
| `ext.cred.ccp_endpoint` | `https://<ccp host>/AIMWebService/api/Accounts` | CCP only; HTTPS |
| `ext.cred.cyberark.cert_path`, `ext.cred.cyberark.cert_password` | client certificate file and its password | CCP only |
| `ext.cred.verify_ssl`, `ext.cred.check_revocation` | true | CCP: validate the server certificate and its revocation status |
| `ext.cred.snmpv2_community_property` | attribute name | CCP: where the community string lives if not in the password field (AIM: file `CredMap.properties` in the MID Server `agent` directory with `SNMPv2.Community=<attribute>`) |

**Credential ID formats** (the id must equal the account **Name** in CyberArk):

| Format | Meaning |
|---|---|
| `<credential id>` | in the default safe |
| `<safe>:<credential id>` | in a named safe |
| `<safe>:<credential id>:<platform id>` | also restricted by platform |
| `<safe>:` | look up by IP address in that safe |
| `::<platform id>` | default safe, by IP address, that platform |
| empty | look up by the target's IP address in the default safe: **one record on the instance serves every server that has its own account in the vault** |

The separator can be changed with `safe.cred.split.string=<string>` in `CredMap.properties`.

Lookup order: by id against the account name; if none, by IP address; an IP match on more than one account fails unless `ext.cred.type_specifier` is on. The resolver can also use host name and FQDN (reverse DNS).

Supported types: Windows, SSH password, SSH private key (the vault returns the decrypted key, no passphrase needed), SSH key pair, SNMP community, SNMPv3, VMware, CIM, JMS, basic auth, applicative, Azure, AWS, GCP (needs a modified resolver). Usable from SOAP, REST, JDBC, SSH, PowerShell and SFTP steps and the matching Orchestration activities.

Cloud accounts in the vault: AWS as a *Cloud Service* account on platform *Amazon Web Services - AWS - Access Keys* (access key id, secret, 12-digit account number); Azure from a duplicated *Cloud Provider* platform template with properties `Username` shown as Client ID and `Address` shown as Tenant ID. The account name becomes the Credential ID. AWS with a vault also needs the Discovery and Cloud Provisioning and Governance plugins and role `cloud_admin`.

Upgrading the library when `mid.secure_config.provider` is the CyberArk provider: rename the new client JAR `JavaPasswordSDK_<major>_<minor>_<patch>.jar`, add it as a new MID Server JAR record, then delete the old record.

## OAuth 2.0 client secret in the vault

For the **client credentials** grant only (needs the Integration Hub standard pack). The client id and secret live in a CyberArk account (a duplicated platform template with `Username` shown as Client ID; the secret in the password field); scope and token URL stay on the instance. The MID Server resolves them, requests the token itself and caches the token in memory, refreshing it on expiry.

- With a template: **IntegrationHub > Configuration Templates > New > HTTP Connection with OAuth Client Credentials grant type (External Storage)**; attach it to an alias; on the **Connections Dashboard** open the alias > **View Details** > **Configure**: **Connection URL**, **Use MID** (a MID Server on the same machine as the AIM client), **External Credential Store**, **Credential ID**, **OAuth Token URL**.
- By hand: **System OAuth > Application Registry > New > Connect to a third party OAuth Provider using an external vault** (grant type fixed to Client Credentials; **Token URL**, scopes); an OAuth 2.0 credential in the External Storage view with **OAuth Entity Profile**, **External credential store**, **Credential ID**, vault *CyberArk*; an alias; an HTTP(s) connection using that credential through the MID Server.

Without a vault, the same routing through a MID Server uses template **HTTP Connection with OAuth Client Credentials grant type** and the boxes **Use MID** and **Connect to Auth Server via MID Server** ([[Connection and Credential Configuration Templates]]).

## Discrepancies in the docs

- Supported vaults: "CyberArk or BeyondTrust" on the overview, "CyberArk only" on the credential pages.
- Credential ID length: 40, 160 and 180 characters on different pages.
- The CyberArk introduction says the plugin is found under System Definition > Plugins, the request page says it must be requested.

## Related

- [[Connections, Credentials and Aliases]] · [[Credential Types Reference]] · [[Connection and Credential Configuration Templates]] · [[Credentials Fail in Discovery or Orchestration]] · [[OAuth 2.0 Outbound - The Instance as OAuth Client]]
