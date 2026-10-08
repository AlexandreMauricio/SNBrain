---
type: concept
tags: [concept, security, integrations, instance-admin, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Platform Security > Virtual Private Network (VPN) (4 topics, 138 cleaned lines, read in full 2026-10-08 through the docs site) - Exploring VPN, Activating a VPN service, Configuring an address for VPN communication. https://www.servicenow.com/docs/r/platform-security/c_SetUpAVPN4SNowBusNet.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# VPN between the Instance and a Company Network

**In one line:** ServiceNow can build site-to-site IPsec tunnels from its data centres into your network so that the instance can call systems that are not exposed to the Internet; it carries **outbound calls from the instance only**, and the docs themselves recommend alternatives where possible.

From the Brazil docs. The usual alternative: a MID Server ([[Connections, Credentials and Aliases]]) or encrypted protocols over the Internet ([[LDAP Integration]], [[Certificates in Authentication - Certificate Login, Mutual TLS and Outbound Certificate Policies]]).

## What it is and is not

- A tunnel between ServiceNow's VPN devices (pairs of Cisco ASA) and your existing IPsec-capable equipment; no hardware to install.
- For protocols without their own encryption (LDAP instead of LDAPS, HTTP instead of HTTPS).
- **Inbound traffic never uses the tunnel**: users, administrators, web services calling the instance and MID Servers all reach the instance by HTTPS over the Internet. Only the instance's own outbound requests, and the replies to them, go through.
- Warning from the docs: the tunnel is site-to-site, so the endpoint you expose is reachable by **any instance in the same data centre** (your other instances included), not just one.

## Addressing

- Both ends must use public (non-RFC 1918) addresses inside the tunnel, owned by your organisation; ServiceNow gives one source address for its calls, and you provide a NAT address for each of your hosts.
- The encryption domain (the addresses reachable through the tunnel) must not contain the VPN peer's own address, and should list only the hosts the integrations need.

## Redundancy

Two to four tunnels are provisioned (between ServiceNow's two data centres and your primary and recovery sites).

| Method | How | Verdict |
|---|---|---|
| Same encryption domain behind both of your peers | the same NAT address leads to your server through either tunnel | preferred: invisible to the instance |
| Different encryption domain per peer | the instance is configured with two targets (for example two LDAP servers) and fails over after a timeout | only if the first is impossible; not every feature supports two addresses |

Several tunnels to reach different regions or subsidiaries are not supported: route inside your own network.

## Alternatives the docs prefer

- **Single sign-on plus a MID Server** for directory integration: SSO for login, the MID Server (with the LDAP listener) for near real-time user synchronisation. No firewall openings, routes or tunnels.
- **LDAPS over the Internet**: a read-only domain controller in the DMZ, reachable only from the instance's source addresses; encryption end to end with a certificate you control, stronger than a tunnel's pre-shared key.
- For other integrations: certificate-based encryption.

A VPN outage can make the integration, and with LDAP the logins, unavailable.

## Requesting one

Role `admin`. On Now Support: *Automation Store* > Service catalog > Cloud Infrastructure > **VPN Requests**, choose the request type and answer its questions. ServiceNow then works with your network engineers to build and test. Typical lead time: a week or less.

## Related

- [[LDAP Integration]] · [[Set Up an LDAP Integration]] · [[Multi-Provider SSO - SAML and OIDC]] · [[Connections, Credentials and Aliases]] · [[Login Controls - IP Access Control, Session Limits and Installation Exits]]
