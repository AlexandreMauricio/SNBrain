---
type: concept
tags: [concept, security, instance-admin, api, roles, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Encryption > Key Management Framework (chapter read in full 2026-10-08) - Key Management Framework Resource Exchange, Key Exchange, Configure Key Exchange, Rekey ciphertext with Key Exchange, Recurring Key Exchange walkthrough, Import a key from a web service (wrapping key pair and wrapped key). https://www.servicenow.com/docs/r/platform-security/platform-encryption/resource-exchange.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# KMF Key Exchange and Key Import

**In one line:** a clone copies encrypted data and the module definitions but **not the keys**; *Key Exchange* (the only function of KMF *Resource Exchange* so far) sends the keys from the source to the target instance, and *key import* brings a key you created outside into a module.

From the Brazil docs. Modules and keys: [[Key Management Framework (KMF)]]. Clones: [[Instance Clone Overview]].

## Key Exchange

- **Key source** = the instance that owns the keys; **key target** = the instance asking for them. Requests are created on the **target**.
- Cloned: cryptographic modules, specifications, access policies. Not cloned: keys.

| Mode | How |
|---|---|
| Automatic (default) | all keys are sent during the clone, nothing to configure. Property `glide_encryption.auto_key_exchange.enabled` = true (it is cloned to the target too) |
| Configurable | a request of frequency *One Time Clone* or *Recurring Clone* names the specifications whose keys travel; the source auto-approves at clone time through a Resource Exchange access policy it creates itself |
| Manual | *Adhoc* request from the target, approved by hand on the source |
| Rekey | **Enable Rekeying after Key Imported**: after import an encryption job rotates the key and re-encrypts the cloned cipher text with a key of the target (an active key must exist there) |

Set `glide_encryption.auto_key_exchange.enabled` to **false** when using recurring requests or rekey.

**Key Management > Resource Exchange Requests > New** (role `sn_kmf.cryptographic_manager`; a module with a key must exist on both sides):

| Field | Notes |
|---|---|
| **Exchange Frequency** | Adhoc, One Time Clone, Recurring Clone |
| instance **sys_id** and **Host** | for Adhoc the source's, otherwise the target's. The instance id is shown on `stats.do` |
| **Crypto Specifications** | whose keys |
| **Enable Rekeying after Key Imported** | not with Adhoc |

- Approving an Adhoc request on the source: open the *Request Pending* record, set **Status** to *Request Approved*, select **Update Request** (the ordinary **Update** button does not complete it).
- Requests can expire: an expired request is rejected and its key deleted. After import the transported key is marked expired.
- The request record shows the imported and total key counts.
- After an attempt, the non-production instance sets property `protected.script.values.kmf.rekeyed`: true if encryption with the exchanged key worked; if false it retries the next day.

## Import a key through the REST endpoint

For symmetric keys and asymmetric public keys. The key must arrive **wrapped** by a public key whose private half is already on the instance.

1. Locally, create a certificate and private key and put both in a PKCS12 keystore with an alias.
2. **Key Management > Import Settings > Key Import Settings** (role `sn_kmf.cryptographic_manager`): purpose *Asymmetric Key Unwrapping*, a matching RSA algorithm, **Origin** = *Import from PKCS12* (or *Import from BCFKS*), **Key Alias** equal to the keystore alias, then **Import Key** to upload the keystore.
3. Locally, wrap the key with the public key (RSA OAEP with SHA-256 in the docs' example).
4. Create the target module with a specification whose **Key Origin** is *Import from web service*.
5. `POST https://<instance>.service-now.com/api/sn_kmf/key/import?cryptoSpecSysID=<sys_id of the specification>`, header `Content-Type: application/octet-stream`, body the wrapped key file, basic authentication as a user with `sn_kmf.cryptographic_operator` (printed once as `sn_kmf_cryptographic_operator`). HTTP 200 on success; check the module's keys.

## Related

- [[Key Management Framework (KMF)]] · [[Module Access Policies (MAPs)]] · [[Password2 Fields and the GlideEncrypter Deprecation]] · [[Instance Clone Overview]] · [[Clone Options and States]]
