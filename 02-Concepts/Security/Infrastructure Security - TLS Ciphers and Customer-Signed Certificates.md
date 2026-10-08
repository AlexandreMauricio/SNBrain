---
type: concept
tags: [concept, security, instance-admin, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Encryption > Key Management Framework (chapter read in full 2026-10-08) - Infrastructure Security, Generate a Certificate Signing Request. https://www.servicenow.com/docs/r/platform-security/platform-encryption/infrastructure-security.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Infrastructure Security - TLS Ciphers and Customer-Signed Certificates

**In one line:** the Infrastructure Security plugin lets an administrator choose the TLS 1.2 ciphers offered by the instance's load balancer and install a certificate signed by the company's own certificate authority for the instance URL.

From the Brazil docs. Plugin *ServiceNow Infrastructure Security Settings* (`com.glide.infrastructure_security`). Certificates used *by* the instance for outbound trust are another matter: [[Certificates on the Instance - Formats, Trust and Upload]].

## What it offers

| Module under **All > Infrastructure Security Settings** | Use |
|---|---|
| **TLS Settings** | which TLS 1.2 ciphers are used and in what order. TLS 1.3 ciphers are fixed. Custom ciphers only through support |
| **Generate CSR** | create a certificate signing request |
| **Upload Certificate** | upload the signed certificate to the load balancer |
| **TLS Settings History**, **View SYOC Settings** | status of the changes |

"Sign your own certificate" needs property `sn_infra_sec.syoc.enabled` = true (create it if missing; the docs expand SYOC as "Sign Your Own Security").

## Generating the request

**Generate CSR** (role `admin`): **Add** each domain, fill the optional certificate fields, **Submit**; copy the text from **Generated CSR**, have the certificate authority sign it, then upload the result.

Only one request at a time: a second one fails with "Resource in Conflict" until the first finishes or is cancelled.

The page refers to custom instance URLs for the domains to request (no vault note on custom URLs yet).

## Related

- [[Certificates on the Instance - Formats, Trust and Upload]] · [[Hardening Settings - API, Architecture, Communications and Configuration]] · [[Key Management Framework (KMF)]]
