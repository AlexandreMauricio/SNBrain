---
type: concept
tags: [concept, integrations, api, security, users, access-control, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Authentication > OAuth authentication (whole section, 59 topics, 2,917 cleaned lines, read in full 2026-10-08 through the docs site). This note covers the inbound half - overview, setup and properties, Machine Identity Console inbound integrations (authorization code, client credentials, third-party ID token, JWT bearer, resource owner password, implicit), Client ID Metadata Documents, the older Application Registry forms, token requests and responses, client type, client credentials property and OAuth Application User, managing and revoking tokens. Field-by-field form tables are condensed to the fields that matter. https://www.servicenow.com/docs/r/platform-security/authentication/c_OAuthApplications.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# OAuth 2.0 Inbound - The Instance as OAuth Provider

**In one line:** an external client is registered on the instance, gets a client id (and usually a secret), exchanges a grant at `oauth_token.do` for an **access token**, and then calls the instance's REST APIs with `Authorization: Bearer <token>` instead of a user name and password.

From the Brazil docs. The other direction (the instance calling out): [[OAuth 2.0 Outbound - The Instance as OAuth Client]]. Steps: [[Register an OAuth Client for Inbound REST Calls]]. What a token may reach afterwards: [[Inbound API Authentication and API Access Policies]].

- Plugin **OAuth 2.0** (`com.snc.platform.security.oauth`), active by default; switch `com.snc.platform.security.oauth.is.active` (true).
- Role `oauth_admin` (the pages also name `mi_admin` for the Machine Identity Console, `admin`, and in overviews `security_admin`).
- Registered clients: Application Registries (`oauth_entity`). Issued tokens: `oauth_credential`.
- The client secret is stored encrypted (password2, Key Management Framework). Self-signed certificates are not supported.

## Endpoints on the instance

| Endpoint | Use |
|---|---|
| `https://<instance>.service-now.com/oauth_auth.do` | authorization endpoint (browser, GET): `response_type=code`, `client_id`, `redirect_uri`, `scope`, `state`; public clients add `code_challenge` and `code_challenge_method=S256` |
| `https://<instance>.service-now.com/oauth_token.do` | token endpoint (POST, `application/x-www-form-urlencoded`; a JSON body fails) |
| `https://<instance>.service-now.com/oauth_revoke_token.do?token=<token>` | marks an access or refresh token expired; **needs no authentication** |
| `https://<instance>.service-now.com/api/now/oauth/jwks` | the instance's public keys (rotated keys stay listed for 105 days) |
| `https://<instance>.service-now.com/.well-known/openid-configuration` | issuer metadata |

Token response: `access_token`, `refresh_token` (not for every grant), `token_type` = Bearer, `expires_in`, and `scope`, which is always `useraccount` unless authentication scopes are used.

## Defaults and properties

| Item | Default |
|---|---|
| Access token lifespan | 1,800 seconds (30 minutes) |
| Refresh token lifespan | 8,640,000 seconds (100 days) |
| `glide.oauth.allow.parameters.in.post.body.only` | true on instances new since Madrid: client credentials only in the POST body, never in the URL |
| `glide.oauth.state.parameter.required` | true on instances new since Madrid: without `state` the request fails with *Missing State parameter in request* |
| `glide.oauth.inbound.client.credential.grant_type.enabled` | false; must be created and set true for client credentials on a registry record made the old way |
| `glide.oauth.inhouse.httpclient.enabled` | set false for providers that send a lowercase content-type header |
| `glide.session_timeout.iframe_embedded`, `.integration_as_a_user`, `.integration_as_a_service` | session timeout by the record's **Client Type** |

## Grant types

| Grant | Who the token represents | Request to `oauth_token.do` | Notes |
|---|---|---|---|
| **Authorization code** | the user who logged in and pressed **Allow** | `grant_type=authorization_code`, `code`, `redirect_uri`, client id (+ secret, or `code_verifier` for a public client) | the recommended interactive flow; public clients must use PKCE |
| **Client credentials** | the application itself (a chosen user record) | `grant_type=client_credentials`, client id and secret | machine to machine; no user interaction |
| **JWT bearer** | the user named in the token's `sub` | `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer`, `assertion=<signed JWT>` | no refresh token; a public client may omit id and secret |
| **Third-party ID token** | the user or service account matching a claim | none: the client sends the identity provider's JWT directly as the Bearer token | the instance verifies it against an OIDC provider configuration |
| **Resource owner password** | the user whose password is sent | `grant_type=password`, `username`, `password` | discouraged: the client handles the password |
| **Implicit** | the logged-in user | `response_type=token` at the authorization endpoint | legacy, no refresh token; use authorization code with PKCE |
| Refresh | as the original | `grant_type=refresh_token`, `refresh_token` | |

## Registering a client: Machine Identity Console (newer)

**Machine Identity Console > Inbound integrations > New integration**, then the grant type.

| Field | Meaning |
|---|---|
| **Name**, **Provider name** (mandatory), **Active** | |
| **Client ID**, **Client Secret** | generated; the secret is hidden for a **public client** |
| **Redirect URL** | where the authorization code is sent (authorization code) |
| **Auth scopes** | REST API auth scopes the token is limited to; **Allow access only to APIs in selected scope** |
| Advanced | **Enforce token restriction**, **Token Format** (JWT or Opaque), access and refresh token lifespans, **Login URL**, **Logo URL** |

Extra for **JWT bearer**: **User field** (the `sys_user` column compared with `sub`), **JTI verification** (on by default, blocks replay), **JWKS URL** or a **JWT verifier map** (**Kid**, **Sys certificate** or **Shared key**), clock skew (300 seconds), JWKS cache. Required claims: `iss`, `sub`, `aud`, `exp`, `iat`. Algorithms: RS256/384/512, ES256/384/512, HS256/384/512.

Extra for **third-party ID token**: an **OIDC provider configuration** (metadata URL, cache lifespan in hours, **User claim** default `sub`, **User field**, JTI verification). A service account is a `sys_user` record with **Web service access only** whose field equals the claim.

## Registering a client: Application Registry (older)

**System OAuth > Application Registry > New** shows a chooser:

| Choice | Creates |
|---|---|
| **Create an OAuth API endpoint for external clients** | an `oauth_entity` of type OAuth Client (fields include **Redirect URL**, **Enforce Token Restrictions**, **Subject Claim**, **Client Type**) |
| **Create an OAuth JWT API endpoint for external clients** | a JWT bearer client: public key in `sys_certificate`, **JWT Verifier Maps**, **OAuth JWT Claim Validations** |
| **Configure an OIDC provider to verify ID tokens** | type External OIDC Provider; templates for ADFS, Auth0, Azure AD, Google, Okta; optional user provisioning |
| **Connect to a third party OAuth Provider** | an outbound provider record ([[OAuth 2.0 Outbound - The Instance as OAuth Client]]) |

Client credentials on such a record: create the property above, then add the **OAuth Application User** field to the OAuth entity form (form design) and pick the user the token acts as. Without the user, or with the property false, the request is refused. Limit what the client reaches with a REST API auth scope.

**Client Type**: *Iframe Embedded*, *Integration as a User*, *Integration as a Service* (drives the session timeout properties).

## Client ID Metadata Documents (CIMD)

Since Zurich Patch 7 and Australia Patch 1; replaces Dynamic Client Registration; used by MCP clients ([[ITSM MCP Server]]).

- The `client_id` is an **HTTPS URL** of a JSON document describing the client: required `client_id`, `redirect_uris`; recommended `client_name`, `client_uri`; optional `logo_uri`.
- Public clients only, authorization code with PKCE only.
- The client must still be registered: **System OAuth > CIMD Clients > New**. **Metadata Sync Mode** *Live* (default, cached 3,600 seconds) or *Static*; localhost redirection allowed; **Token Format** Opaque by default; **Scope Restriction** *Securely scoped* by default (*Broadly scoped* for an MCP server).

## Tokens

- The user sees a consent page with **Allow** / **Deny**; granted tokens are listed under **Self-Service > My Connected Apps**, where **Revoke Access** removes them.
- Administrators: **System OAuth > Manage Tokens**. Columns of `oauth_credential`: **Token**, **Type** (access or refresh), **Expires**, **Token Received** (a token from an external provider, encrypted).
- Scheduled job *Clean Expired OAuth Credentials* removes old rows, steered by `com.snc.platform.security.oauth.hours.expired.credential.is.kept` and `com.snc.platform.security.oauth.day.old.credential.is.kept`.

## Release notes inside the chapter

- Zurich: longer client secrets, JWKS URL for the JWT grant, ES256/384/512, custom JTI claim name.
- Third-party provider tokens (outbound) default to 30 days access and 365 days refresh according to one page.

## Discrepancies in the docs

- Maximum client secret length is given as 2,048 characters on one page and 4,096 on another.
- The role needed is `oauth_admin` on the task pages and `security_admin` on the overview pages.
- The revoke page says the endpoint needs no authentication, which means anyone holding a token value can expire it (harmless, but worth knowing).

## Related

- [[OAuth 2.0 Outbound - The Instance as OAuth Client]] · [[Register an OAuth Client for Inbound REST Calls]] · [[Inbound API Authentication and API Access Policies]] · [[Personal OAuth Authentication and Web Embeddables Sessions]] · [[Multi-Provider SSO - SAML and OIDC]] · [[Certificates in Authentication - Certificate Login, Mutual TLS and Outbound Certificate Policies]] · [[Custom Instance URLs]] · [[sys_user]]
