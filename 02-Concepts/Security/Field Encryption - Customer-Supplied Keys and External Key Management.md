---
type: concept
tags: [concept, security, integrations, roles, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Encryption > Field Encryption (chapter read in full 2026-10-08) - Configure Customer-supplied keys for Field Encryption Enterprise, Configure properties for customer-supplied key(s) (two pages), Wrap your customer-supplied key (two pages), Using customer-supplied keys with Field Encryption Enterprise, Configure and upload your customer supplied key, External Key Management Service, Configuring EKMS, Activate EKMS, Configure an external key definition, Create a cryptographic module with external key wrapping, Create Encrypted Field Configurations, Set up Module Access Policies, Test an external key definition, Using EKMS, Change the status of an AWS KMS Key, Check EKMS Key Status. https://www.servicenow.com/docs/r/platform-security/ekms-external-key-management.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Field Encryption - Customer-Supplied Keys and External Key Management

**In one line:** Field Encryption Enterprise offers two ways to control the key yourself: upload a key you generated (customer-supplied key, "bring your own key") or keep a wrapping key in your own AWS KMS so that the instance cannot decrypt without it (External Key Management Service, "hold your own key").

From the Brazil docs. Enterprise only. The feature: [[Field Encryption - Modules, Encrypted Fields and Access]]. Keys in general: [[Key Management Framework (KMF)]].

## Customer-supplied key (CSK)

1. Generate a symmetric key outside the instance, as a **binary** file of 32 bytes (256 bit) or 16 bytes (128 bit); the docs use `openssl rand 32`.
2. **System Security > Field Encryption > Field Encryption Settings**: **Key Source** = *Customer Supplied Keys*.
3. Open the module (**Field Encryption Experience > View module details**) > **Encryption Keys** > the bring-your-own-key option > **Download wrapping key**. A zip named `token_publickey...` arrives, holding an import token (text) and a public key (PEM). Do not rename it.
4. Wrap your key with that public key (RSA OAEP with SHA-256 in the docs' OpenSSL example); the result is a wrapped key file.
5. Tick that the offline steps are done, upload the wrapped key and the import token, name the key, **Complete provisioning**.

- The wrapping key pair is ephemeral. Its properties are not visible in the properties list and are changed only by support:

| Property | Default |
|---|---|
| `glide.kmf.ephemeral_key.key_padding` | OAEP with SHA-256 (SHA-1 also supported) |
| `glide.kmf.ephemeral_key.key_size` (printed once as `glide.kmf.ephemeral.key_size`) | 4096 (2048 also supported) |
| `glide.kmf.ephemeral_key.key_validity_period` | 2 hours |

- A key in another format than binary fails with "Token failed validation. Please reattach the unmodified token."
- **A customer-supplied key cannot be revoked.**
- Once imported, the key is wrapped by the instance's key encryption key like any module key.
- Roles: `security_admin` and `sn_kmf.cryptographic_manager` or `sn_kmf.admin`.

## External Key Management Service (EKMS)

Plugin *Platform Encryption External Key Management* (`com.glide.encryption.external_kms`); needs Field Encryption Enterprise and the *Key Management Framework Scoped App*. Supported provider: **AWS KMS** only.

### How the chain works

1. The instance generates an External Key Encryption Key (EKEK).
2. The EKEK is wrapped by the Instance Root Key, and that result is wrapped again by **your AWS KMS key**; it is stored in the External Instance Keys table.
3. The module's data encryption keys are wrapped by the EKEK.
4. Field data is encrypted with those data keys.

Without the AWS key the instance cannot unwrap anything. Disabling or deleting the key in AWS makes the data cryptographically unreachable.

Limits: one EKMS configuration per instance; symmetric AWS keys only; no multi-region keys.

### Setting up

Roles `admin`, `security_admin`, `sn_kmf.cryptographic_manager`. In AWS: a key, and an IAM user allowed `kms:DescribeKey`, `kms:Encrypt`, `kms:Decrypt`.

1. **System Security > Field Encryption > EKMS Configurations > New**: **EKMS Integration Name**, **Key Region**, **External Key Identifier** (the key's ARN), **Primary Region URL**, and the IAM user's access key and secret key (`<AWS_ACCESS_KEY_ID>`, `<AWS_SECRET_ACCESS_KEY>`). Provider is fixed to AWS, application to Global.
2. **Test EKMS Config**: success reads "Validation passed for the configuration"; wait for the key status *Active*.
3. **Field Encryption Modules > New**: tick **External wrap key** and choose the configuration in **External KMS Configuration**. Ticking it on an existing module rewraps all its keys; a security task "Module key rewrap process for crypto module ..." tracks that in the Security Center task manager.
4. Create the encrypted field configuration with **that** module (a module without the flag encrypts with internal keys only) and the access policies.

### Key status

A background job copies the AWS key status every **30 minutes** (interval configurable). **External Key Status** on the configuration:

| Status | Effect |
|---|---|
| Enabled | normal |
| Disabled | no encryption or decryption of the encrypted fields. Records can still be created if the encrypted field is not mandatory, and other fields updated. A banner and a high-priority security task in [[Security Center]] alert administrators |
| Pending deletion | unusable; cancel the deletion in AWS within the waiting period (7 to 30 days), then re-enable (cancelling does not enable) |
| Deleted | data encrypted under it is unrecoverable; a new configuration is needed. Shown at least seven days after the deletion request |
| Unavailable | the instance cannot reach AWS: credentials, network or AWS outage. Use **Test EKMS Config** |

Coordinate any status change with the application teams first; it takes effect in the instance within 30 minutes.

## Related

- [[Field Encryption - Modules, Encrypted Fields and Access]] · [[Key Management Framework (KMF)]] · [[KMF Key Exchange and Key Import]] · [[Security Center]] · [[Encrypted Field Shows Empty or Unreadable]]
