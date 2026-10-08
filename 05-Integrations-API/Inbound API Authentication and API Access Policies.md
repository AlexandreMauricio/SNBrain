---
type: concept
tags: [concept, api, integrations, security, access-control, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Authentication (read in full 2026-10-08 through the docs site) - API Authentication (certificate, OAuth pointer, token-based authentication with API key and HMAC, token expiry clean-up, basic authentication and its restriction and exceptions; 464 lines) and API access policy (REST API access policies, authentication profiles, policy prioritization, REST API Auth Scope with properties, configuration, troubleshooting and FAQ, SOAP API access policies, filter criteria, API authentication policies, global blocking policy, processor access policies; 879 lines); External authorization servers for the ServiceNow MCP Server (118 lines). https://www.servicenow.com/docs/r/platform-security/authentication/api-authentication.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Inbound API Authentication and API Access Policies

**In one line:** how a caller proves who it is to the instance's REST and SOAP APIs (basic authentication, OAuth token, API key, HMAC signature, client certificate), and how **API access policies** restrict which of those methods, from which addresses or roles, each API accepts.

From the Brazil docs. Overview of interfaces: [[Integration Options and Interfaces Overview]]. Integration accounts: [[Non-Interactive Users]]. Certificates: [[Certificates in Authentication - Certificate Login, Mutual TLS and Outbound Certificate Policies]]. The filter criteria and policies reused here: [[Adaptive Authentication]].

## Ways to authenticate an inbound call

| Method | Notes |
|---|---|
| Basic authentication (user name and password) | legacy; discouraged; being restricted (below) |
| OAuth 2.0 access token | an application registry gives the client an id and secret (OAuth chapter, not yet in the vault) |
| OIDC ID token | from an external identity provider |
| Client certificate (mutual TLS) | certificate mapped to a user |
| **API key** | a token tied to a user, sent in a header or query parameter |
| **HMAC** | a signature computed with a shared secret |

## API key and HMAC

Plugin **API Key and HMAC Authentication** (`com.glide.tokenbased_auth`; depends on `com.glide.rest.auth.scope`, `com.glide.rest.policy`, `com.glide.auth.scope`). Roles `api_service_admin` and `adaptive_auth_policy_admin`. Meant for webhooks, so that no user name and password sits in a URL. Three records are always needed, under **System Web Services > API Access Policies**:

| Step | API key | HMAC |
|---|---|---|
| 1. **Inbound Authentication Profiles > New** | *Create API Key authentication profiles*: **Auth Parameter** `x-sn-apikey` as header or as query parameter (an optional **Prefix** is set on the auth parameter record) | first an **HMAC Configuration** (**Hash Algorithm** HmacSHA256, 384 or 512; **HMAC util script**; a default *HMAC SHA256 Base64 Encoding* exists); then *Create HMAC authentication profiles*: that configuration, **Auth Parameter** `x-sn-hmac-signature-256` (header or query), optional **Default Key ID of Shared Secret** |
| 2. The credential | **REST API Key > New**: **User** (the call runs as this user), optional **Auth Scope**, **Expiry**; the platform generates the **Token** (reopen the record to copy it) | **REST API HMAC Secret > New**: **User**, **Shared Secret**, **Expiry**; the platform generates the **Key ID** to send with the call |
| 3. **REST API Access Policies > New** | the API (and method, version, resource) with the profile from step 1 attached | the same |

- Token authentication is **not allowed in a Global** REST API policy: it must be per API.
- A policy covers one API version unless **Apply to all versions** is ticked.
- Signing only body, timestamp and secret without a key id needs a custom HMAC util script include (name starting `HMAC`).
- Send sensitive data with POST, not in a query string.
- Expired keys and secrets are deleted 7 days later by job *Clean expired Token Auth Credentials*: `com.snc.platform.security.token.auth.cleanup` (true), `com.snc.platfrom.security.token.auth.days.expired.api_key.is.kept` and `...hmac_key.is.kept` (7; the names are printed with "platfrom").

## Basic authentication restriction

**Basic Auth Restriction > Properties** (elevated `security_admin`). New instances restrict basic authentication by default; upgraded ones keep working while a tracking period identifies who uses it.

**Basic Auth Restriction > Basic Auth User Exceptions** lists each account seen using basic authentication (**Usage Count**, **Last Seen**) with a **Decision**:

| Decision | Result once enforcement starts |
|---|---|
| Maintain current login | role `snc_basic_auth_api_access` granted: API and UI login both keep working |
| Revoke Basic Auth API login | basic authentication fails; UI login works |
| Convert to web service access only account | basic authentication works; UI login blocked |
| Apply default from system property | follows `glide.authenticate.basic_auth.restriction.default_decision` |

Under enforcement a basic-authentication request passes only for an account that is **Web service access only**, or holds `snc_basic_auth_api_access`, or presents a valid MFA one-time code. Two switches: the feature toggle (off = nothing happens; the emergency stop) and the enforcement toggle `glide.authenticate.basic_auth.restriction.enforce` (off = tracking only). The start date is on the enforcement scheduled job.

## API access policies

Restrict, per API, **which authentication types are accepted and under what conditions**. Plugins `com.glide.rest.policy`, `com.glide.soap.policy`, `com.glide.processor.policy`, `com.glide.rest.auth.scope`. Tables: `sys_api_access_policy`, `inbound_auth_profile`, `std_http_auth`, `sys_auth_profile_mapping`, `auth_policy_mapping`.

Three layers:

1. **Filter criteria** (IP, role, group): the same records as adaptive authentication.
2. **API authentication policy** (**System Web Services > API Authentication Policy**): inputs + conditions (ORed). Built-in *Global Blocking Policy*. **Never attach *Allow Access Policy* or *Deny Access Policy*: those are for user logins.**
3. **Inbound authentication profile**: a **Type** (Basic Auth, ID Token, Certificate based Auth, OAuth; WSSE for SOAP; API key; HMAC), for token types the **OAuth Entity**, and one or more authentication policies.

Then the **REST API access policy** (**System Web Services > REST API Access Policies**): **REST API**, and either specific **HTTP Method**, **Version**, **Resource** (and **Table** for the Table API) or the *Apply to all ...* boxes, or **Global** (every REST API); plus its list of authentication profiles. A request must match one of the profiles (type and policy conditions) or it is refused. Example from the docs: accept only OAuth, and only from a given IP range.

Which policy applies when several match (**a specific policy always beats a global one**):

| Priority | Policy matches on |
|---|---|
| 1 | method + resource + version |
| 2 | method + resource |
| 3 | resource + version |
| 4 | resource |
| 5 | method + version |
| 6 | method |
| 7 | version |
| 8 | global, not all methods |
| 9 | global, all methods |

`WWW-Authenticate` on a refused call names only the most recently mapped profile unless **Advertise all auth schemes** is ticked (or `glide.security.response.authenticate.header.auth_profile.first_scheme_only` = false).

**SOAP**: **API Access Policies > SOAP API Access Policies** (the **SOAP API**, profiles of standard or WSSE type), for table and scripted SOAP services. One policy for all SOAP: **System Security > Processor Access Policies** with processor *SOAPProcessor* and the *Global SOAP Auth Profile*; a per-API policy overrides it.

**Processors** (exports such as CSV, PDF, XML, RSS; script processors): **System Security > Processor Access Policies**: **Processor** + **Authentication Profile**. Non-public processors only. Uses: require an OAuth token for CSV export; allow exports only from a trusted network; **block an unused processor** by attaching a profile whose policy can never be true (an IP criterion covering every address with the condition set to false).

## REST API auth scope (OAuth tokens only)

Limits which REST APIs an OAuth client may call. Plugin `com.glide.rest.auth.scope` (since Tokyo).

1. An **authentication scope** (`sys_auth_scope`; unique name).
2. **API Auth Scopes > REST API Auth Scope > New** (`sys_api_access_scope`): the **REST API**, the **Auth Scope**, and method, version and resource or the *Apply auth scope to all ...* boxes.
3. Add the same scope to the **OAuth entity** (application registry) of each client that should have access.

Behaviour:

- An API **without** an auth scope record is open to any valid OAuth token. Once one exists, **every existing token loses access to that API** until its OAuth entity gets the scope.
- Scopes are read from the OAuth entity at run time: changing them affects tokens already issued, and all tokens of one entity share the same scopes.
- The special scope `useraccount` opens every API. If its record is deleted, recreating one with the same name is not enough: import it from another instance or set `glide.oauth.token.scope.useraccount` to the new sys_id.
- Not checked for basic authentication, session cookies or certificates.
- A failure is HTTP 403 with "Missing required api access scope".
- `com.glide.rest.api.auth.scope.check.enable` = false turns the check off.

## External authorization servers for the ServiceNow MCP Server

By default an MCP client authenticates with a token from the instance's own authorization server. A company identity provider can be registered as a trusted issuer instead (role `oauth_admin`):

| Record | Fields |
|---|---|
| **OIDC Provider Configuration** | **OIDC Provider** (name), **Issuer URI** (matched against the token's issuer claim), **OIDC Metadata URL** (discovery endpoint for keys), **User Claim** and **User Field** (which claim identifies the user and which user field it matches, for example email), optional **Enable JTI claim verification** + **JTI Claim**, **OIDC Configuration Cache Life Span**, **Active** |
| **OAuth Protected Resource** | **Resource Name**, **Resource Identifier**, **Allowed Glide APIs**, **Scopes Supported**, **Bearer Methods Supported** (header), **Allow Glide as Authorization Server** (the instance may issue tokens too), **Active** |

Sequence: the client calls without a token and gets HTTP 401 with a `WWW-Authenticate` header naming the resource metadata URL; reads `.well-known/oauth-protected-resource` (resource, authorization servers, scopes); obtains a token from the external server (OAuth 2.1 authorization code with PKCE); calls again with the bearer token. The instance validates locally: trusted issuer, signature, audience, expiry. Tokens from unregistered or inactive issuers are rejected. See also [[ITSM MCP Server]].

## Related

- [[Integration Options and Interfaces Overview]] · [[Non-Interactive Users]] · [[Adaptive Authentication]] · [[Multi-Factor Authentication]] · [[Certificates in Authentication - Certificate Login, Mutual TLS and Outbound Certificate Policies]] · [[Security Attributes, Security Data Filters and Field Query Controls]]
