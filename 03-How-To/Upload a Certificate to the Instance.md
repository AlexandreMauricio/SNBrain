---
type: how-to
tags: [how-to, security, integrations, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Encryption > Certificates (chapter read in full 2026-10-08) - Uploading a certificate to an instance, Uploading a trusted server certificate, Generating an LDAP client certificate. https://www.servicenow.com/docs/r/platform-security/t_UploadACertificateToAnInstance.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Upload a Certificate to the Instance

**Goal:** make the instance trust a remote server's certificate (or hold a keystore for mutual authentication).
**Prerequisites:** role `admin`; the certificate as PEM text or a DER file (or a keystore file).
**Navigation:** All > System Definition > Certificates

Background: [[Certificates on the Instance - Formats, Trust and Upload]].

## Steps

1. **Certificates > New**.
2. **Name** (unique), **Active** ticked, optionally **Expiration notification** and **Short Description**.
3. **Format**: PEM or DER. **Type**: *Trust Store Cert* for a server to trust; a keystore type for a client certificate with its private key.
4. PEM: paste the text into **PEM Certificate**. DER or keystore: attach the file to the record.
5. **Submit**. The validity dates, issuer and subject are filled in.
6. Open the record > **Validate Stores/Certificates**.

## Result / how to check it worked

No error after validation, and **Expires** shows the expected date. The feature using it (LDAPS connection test, outbound REST call) now connects.

## Example

The directory server `ldap.example.com` presents a certificate signed by *Example Company Internal CA*. Record *Example Internal CA*: format PEM, type *Trust Store Cert*, the CA certificate pasted, expiration notification on. After validation the LDAP server's connection test succeeds over LDAPS.

## Tables / fields involved

- Certificate (`sys_certificate`; table name from earlier notes, not from these pages): **Name**, **Format**, **Type**, **PEM Certificate**, **Valid from**, **Expires**, **Issuer**, **Subject**, **Active**

## Gotchas

- Self-signed and company-signed certificates are not trusted until uploaded.
- When the other side renews its certificate, upload the new one before the old one expires.
- With several LDAP servers, upload every server's certificate.
- Mutual authentication for LDAP needs a Java keystore; on a self-hosted instance try the `.pfx` if the `.jks` is refused.
- This does not change the certificate of the instance's own URL: see [[Infrastructure Security - TLS Ciphers and Customer-Signed Certificates]].
