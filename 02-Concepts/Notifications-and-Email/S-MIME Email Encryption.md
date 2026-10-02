---
type: concept
tags: [concept, email, security]
status: documented
source: ServiceNow Australia Platform Administration PDF, "Email Administration", topic "Email encryption - S/MIME protocol" (pp. 2469-2477), read 2026-10-01
sn-release: Australia
verified:
updated: 2026-10-01
---

# S/MIME email encryption

**In one line:** S/MIME lets the instance digitally sign and encrypt outbound email and verify and decrypt inbound email, using key pairs and certificates you supply.

## How it works

| Direction | Signing | Encryption |
|---|---|---|
| Outbound | the instance signs with the **private key of its email account**; recipients verify with the public key | the instance encrypts with **each recipient's public key**; recipients decrypt with their private key |
| Inbound | the sender signs with their private key; the instance verifies with the sender's public key | the sender encrypts with the instance's public key; the instance decrypts with its private key |

- Plugin **S/MIME Email** (`com.glide.email.smime`).
- **ServiceNow does not issue S/MIME certificates.** Obtain them from a third-party provider.
- With several recipients, an encrypted email goes only to those with a valid certificate.
- If an inbound message cannot be decrypted, it becomes *received-ignored* and no inbound action runs.
- To ignore inbound mail whose signature cannot be verified, create `email.inbound.smime.ignore_unverified_emails` = true.

## Setup

Roles: `email_account_admin` and `sn_kmf.cryptographic_manager` for the key pair; admin (or `smime_certificate_admin`) for certificates.

1. **Import the key pair** for the instance's email address: open the email account, related link **Import SMIME Key Pair** (PKCS12 file created with a key alias; origin *Import from PKCS12*). The key pair belongs to the email address, not the account record. Do not tick *Enroll module for resource exchange*.
2. **Upload the CA certificate**: **System Notification > SMIME > CA Certificate**.
3. **Upload email certificates** (PEM) for recipients you will encrypt to: **System Notification > SMIME > Email Certificate**. Both have expiry warnings.
4. **Enable the properties** (Email Properties page):

| Property | Does |
|---|---|
| `email.outbound.smime.signing.enabled` | sign outbound mail |
| `email.outbound.smime.signing.send_public_cert` | include the public certificate |
| `email.outbound.smime.encryption.enabled` | encrypt body and attachments |
| `email.outbound.smime.encryption.algo` | AES-CBC or AES-GCM (check the mail client supports GCM) |
| `email.inbound.smime.verify_sign` | verify inbound signatures |
| `email.inbound.smime.decrypt` | decrypt inbound mail |

5. Per message: on a notification or in the email client, tick **Digitally sign your emails** and **Encrypt emails**.

## Related

- [[Email Architecture and Accounts]] · [[Email Filters, Address Filters and Bounce Management]]
