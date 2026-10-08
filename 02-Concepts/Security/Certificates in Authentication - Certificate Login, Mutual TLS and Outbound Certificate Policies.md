---
type: concept
tags: [concept, security, api, integrations, access-control, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Authentication (read in full 2026-10-08 through the docs site) - Certificate-based authentication (set up, activate, register CA certificate, map PEM certificate to user, properties, log in with PIV or CAC; 252 lines), Web service security (basic authentication, configure mutual authentication; 154 lines), Outbound certificate policies (overview, add a policy, system properties; 152 lines). https://www.servicenow.com/docs/r/platform-security/certificate-based-authentication/certificate-based-authentication.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Certificates in Authentication - Certificate Login, Mutual TLS and Outbound Certificate Policies

**In one line:** where certificates replace or back up passwords: **inbound**, a client certificate identifies a user (smart card login) or an API caller; **outbound**, the instance presents its own certificate to a remote service (mutual TLS) and decides how strictly to validate the remote one.

From the Brazil docs. Certificates as records (uploading, key stores): Encryption > Certificates, a later chapter of the same guide.

## Inbound: certificate-based authentication

Plugin **Certificate-based authentication** (`com.glide.auth.mutual`); role `sso_config_admin`; menu **Certificate Based Authentication**. Needs the ADCv2 load balancer. **Not supported on-premise or with Edge Encryption.** Tables: `sys_user_certificate`, `sys_ca_certificate`, `sys_ca_certificate_api_track`.

Two uses with one setup:

- **User login** with a PIV or CAC smart card instead of user name and password.
- **Inbound REST and SOAP**: the request's client certificate decides which user the request runs as.

| Step | Where | Notes |
|---|---|---|
| Register the issuing CA | **CA Certificate Chain > New**: **Name**, **Type**, expiry notification fields, **Active**; attach the PEM | Type *CA Cert* (root, may include intermediates; **synced to the load balancer**; preferred) or *Intermediate Cert* (kept on the instance only; for adding to an existing chain). **Validate Stores/Certificates** checks it |
| Map a certificate to a user | **User to Certificate Mapping > New**: **Name**, **User**, **Active**; attach the user's PEM certificate | several certificates per user allowed. The request or login runs as this user. "Verify certificate" fails afterwards because the PEM itself is not stored |
| Or let users self-register | user logs in with password, card inserted > **Profile** > related link **Register client certificate** > **Register** | **Manage your client certificates** lists and deletes them |
| Properties | **Certificate Based Authentication > Properties** | *Enable certificate based authentication* (default true); *Show 'Log in with PIV/CAC' option in login screen* (default false); *Enable auto-redirect for certificate based login* (default false: the user must still click the button) |

Login: insert the card, open the instance, enter the card PIN in the browser prompt, choose the certificate, click **Log in with PIV/CAC card**. Logging out means removing the card and closing the browser.

## Basic authentication on SOAP and WSDL

`glide.basicauth.required` = true makes every WSDL or SOAP request carry an `Authorization` header (HTTP 401 without). Even when not required, sending credentials makes the changes belong to that user instead of Guest (journal entries, audit). `glide.security.script.include.name.case.insensitive.list` lists the script includes that process the header case-insensitively (default `BasicAuth`, `CustomAuth`). See also [[Non-Interactive Users]].

## Outbound: mutual TLS

The instance, as HTTPS client, can present a certificate to the remote server. **Outbound connections only.**

1. Build a **Java key store** holding the private key and the signed certificate with its full chain (root and intermediates imported before, or bundled with, the signed certificate). With the JDK tool: `keytool -genkey` (key pair), `keytool -certreq` (signing request for the CA), `keytool -import -trustcacerts` (chain and signed certificate).
2. **System Definition > Certificates > New**: **Type** *Java Key Store*, **Key store password**, **Active**; attach the file.
3. To trust the remote server's certificate: another Certificates record of type *Trust Store Cert* with the DER file attached or the PEM text pasted.
4. Use it through an HTTPS **protocol profile** on the outbound message.

## Outbound certificate policies

Per-domain exceptions to how the instance validates remote certificates, instead of loosening validation globally. Off by default: `com.glide.communications.httpclient.outbound_cert_policy.enabled` = true. Role `outbound_http_request_admin` (or admin). **System Definition > Outbound HTTPS Security Policies > New**:

| Field | Meaning |
|---|---|
| **Name** | exact host (`api.example.com`) or wildcard with at least two components (`*.example.com`). `*` and `*.com` are rejected |
| **Hostname verification** | the certificate was issued for this host |
| **Certificate chain validation** | the chain leads to the platform trust store (clear for a self-signed certificate in development) |
| **Revocation check (OCSP/CRL)** | the certificate is not revoked |

All three are ticked by default; clear only what the host needs, and treat it as temporary.

- Matching: exact host, else the most specific wildcard, else the global settings.
- A policy affects **every** outbound connection to that host: REST and SOAP messages, Flow Designer REST and SOAP steps, script HTTP client calls. Not affected: calls using mutual TLS, calls through a MID Server, the internal HTTP client.
- One policy per host: the UI lets you create a second one in another scope, but **only the first created is applied**.

| Global property | Default | Meaning |
|---|---|---|
| `com.glide.communications.httpclient.verify_hostname` | true | host name check for hosts without a policy |
| `com.glide.communications.httpclient.verify_revoked_certificate` | true | revocation check |
| `com.glide.communications.trustmanager_trust_all` | false | true trusts every certificate: never in production |
| `...outbound_cert_policy.debug`, `...outbound_cert_policy.max_entries` | false, 100 | debug logging; resolved policies cached |

## Related

- [[Adaptive Authentication]] · [[Non-Interactive Users]] · [[Integration Options and Interfaces Overview]] · [[Login Controls - IP Access Control, Session Limits and Installation Exits]]
