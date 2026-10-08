---
type: concept
tags: [concept, security, integrations, instance-admin, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Encryption > Certificates (whole chapter, 6 topics, 210 cleaned lines, read in full 2026-10-08 through the docs site) - Certificates, Exploring Certificates, Generating an LDAP client certificate, Generating a server certificate, Uploading a certificate to an instance, Uploading a trusted server certificate. https://www.servicenow.com/docs/r/platform-security/c_Certificates.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Certificates on the Instance - Formats, Trust and Upload

**In one line:** certificates the instance uses to trust other servers or to prove its own identity (LDAPS, outbound mutual authentication, web service security, MID Server) are records under **System Definition > Certificates**.

From the Brazil docs. How they are used in logins and outbound calls: [[Certificates in Authentication - Certificate Login, Mutual TLS and Outbound Certificate Policies]]. The certificate of the instance's own URL is a different thing: [[Infrastructure Security - TLS Ciphers and Customer-Signed Certificates]].

## Rules

- **Trust:** by default the instance trusts only certificate authorities known to its Java runtime. Self-signed and company-signed certificates are not trusted until uploaded. Properties that change this are among the hardening settings ([[Hardening Settings - API, Architecture, Communications and Configuration]]).
- **Criteria** as printed: key size up to 2048 bits; file formats DER (binary; extensions `.der`, `.cer`, `.crt`) or PEM (base-64 text between the BEGIN and END CERTIFICATE lines).

## LDAP

| Certificate | Type | Needed for |
|---|---|---|
| LDAP server certificate | any supported type | every LDAPS connection |
| LDAP client certificate | Java keystore | mutual authentication only |

With several server certificates the instance tries each until the server accepts; with several LDAP servers upload each server's certificate. See [[LDAP Integration]].

## The certificate record

**All > System Definition > Certificates > New** (role `admin`):

| Field | Notes |
|---|---|
| **Name** | unique |
| **Active** | whether the instance uses it |
| **Format** | PEM or DER |
| **Type** | the container: *Trust Store Cert*, Java keystore, PKCS#12 keystore |
| **PEM Certificate** | paste the text; **Valid from**, **Expires**, **Expires in days**, **Issuer** and **Subject** are filled from it |
| **Expiration notification** | notify before expiry |
| **Short Description** | for example the server or requester |

- **Validate Stores/Certificates** checks the record and reports errors.
- To trust a remote service for outbound calls: a record of type *Trust Store Cert* with the provider's DER file attached or its PEM text pasted.
- When an identity provider (the docs name ADFS) renews its certificate, upload the new one here.

## Making the files (outside the instance)

| Need | Outline |
|---|---|
| LDAP client certificate | with OpenSSL create a certificate and private key, convert both to PKCS#12 (`.pfx` or `.p12`), import that into a Java keystore (`.jks`) with `keytool`, upload the keystore |
| Server certificate signed by a CA | with `keytool` create a keystore and key pair, generate a certificate signing request, import the CA's root or intermediate certificate and then the signed certificate, upload the keystore |

On a self-hosted instance, if a `.jks` upload fails with "No valid certificate found to process the application upload", upload the `.pfx` instead.

## Related

- [[Certificates in Authentication - Certificate Login, Mutual TLS and Outbound Certificate Policies]] · [[LDAP Integration]] · [[Set Up an LDAP Integration]] · [[Infrastructure Security - TLS Ciphers and Customer-Signed Certificates]] · [[Upload a Certificate to the Instance]] · [[S-MIME Email Encryption]]
