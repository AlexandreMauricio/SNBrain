---
type: concept
tags: [concept, integrations, api, security, admin, scripting, glide-api, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Authentication > OAuth authentication (whole section, 59 topics, 2,917 cleaned lines, read in full 2026-10-08 through the docs site). This note covers the outbound half - OAuth Outbound, Workload Identity Federation (overview, Microsoft Azure, Google Cloud), Connect to a third-party OAuth provider, JWT Bearer (keystore, JWT signing key, JWT provider), Generate a JWT, OAuth client APIs, OAuth parameters for default profile support, Private Key JWT (OIDC SSO and outbound), Create an outbound REST message. https://www.servicenow.com/docs/r/platform-security/authentication/oauth-outbound.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# OAuth 2.0 Outbound - The Instance as OAuth Client

**In one line:** the instance is registered as a client at an external OAuth provider, stores that provider's endpoints and client credentials in an **Application Registry** record of type *OAuth Provider*, obtains tokens through an **OAuth entity profile**, and uses them in outbound REST messages, spokes and flows.

From the Brazil docs. The other direction: [[OAuth 2.0 Inbound - The Instance as OAuth Provider]]. Per-user tokens in flows: [[Personal OAuth Authentication and Web Embeddables Sessions]].

- Role `oauth_admin` (overview: `security_admin`); plugin OAuth 2.0 (`com.snc.platform.security.oauth`).
- Records: Application Registries (`oauth_entity`, type OAuth Provider), OAuth entity profiles (`oauth_entity_profile`), OAuth entity scopes, JWT keys (`jwt_keystore_aliases`), JWT providers (`jwt_provider`), tokens in `oauth_credential`.

## Grant types available outbound

| Grant | Use |
|---|---|
| Authorization code | a person logs in at the provider once; the instance keeps the refresh token. Needs the provider's **Authorization URL** |
| Client credentials | client id and secret only; no refresh token |
| Resource owner password credentials | a user name and password sent to the provider |
| JWT bearer | the instance signs a JWT and exchanges it for a token: server to server, no person involved |
| SAML2 bearer | the instance generates a SAML assertion and exchanges it (the docs name SuccessFactors) |
| Workload Identity Federation | Azure and Google Cloud, no stored secret (below) |

Through a MID Server: authorization code, resource owner password, SAML bearer, JWT bearer, and personal OAuth.

## The provider record

**System OAuth > Application Registry > New > Connect to a third-party OAuth provider**.

| Field | Meaning |
|---|---|
| **Name**, **Client ID**, **Client Secret** | from the application registered at the provider |
| **Default Grant type** | one of the grants above |
| **Authorization URL**, **Token URL**, **Token Revocation URL** | the provider's endpoints |
| **Redirect URL** | the callback; left blank, the instance fills in `https://<instance>.service-now.com/oauth_redirect.do` |
| **Refresh Token Lifespan** | seconds; default 8,640,000 (100 days) |
| **Public Client**, **Code challenge method** | PKCE (S256 default, Plain, None); only with authorization code |
| **Send Credentials** | *In Request Body (Form URL-Encoded)*, *Basic Authorization header*, or *As Private Key JWT* |
| **Use mutual authentication** | mutual TLS for token request and revocation; needs a mutual authentication profile ([[Certificates in Authentication - Certificate Login, Mutual TLS and Outbound Certificate Policies]]) |
| **OAuth API Script** | script that customises requests to and responses from the provider (see `OAuthUtil`) |
| **Client Type**, **Logo URL**, **Comments**, **Application**, **Accessible from**, **Active** | |

Related lists: **OAuth Entity Profiles** (a default profile without scopes is generated), **OAuth Entity Scopes** (one record per scope, names taken from the provider's documentation), **OAuth Entity Resources**.

Using it: on an outbound REST message (**System Web Services > Outbound > REST Message**) set **Authentication type** = OAuth 2.0 and the **OAuth profile**, then **Get OAuth Token**: log in at the provider (password, IdP, MFA as it requires) and press **Allow**. After that first interactive step the instance refreshes tokens by itself until the refresh token expires.

## JWT bearer outbound

1. Upload the keystore: **Multi-Provider SSO > x509 Certificate** (a Java KeyStore with its password; **one entry only**, because the first alias is the one used).
2. **System OAuth > JWT Keys**: the signing key.

   | Field | Meaning |
   |---|---|
   | **Key Source** | *Signing Keystore* (an uploaded certificate) or *KMF Cryptographic Module* (a private key held in the Key Management Framework; needs `sn_kmf.*` roles) |
   | **Signing Keystore**, **Signing Key** | the keystore record and its key password |
   | **Key Id** | sent as `kid` if filled |
   | **X.509 Certificate SHA-1 Thumbprint (x5t)** | adds `x5t` to the header; the field must be added to the form |
   | **Signing Algorithm** | RSA 256 (default) or ES256 (new in Brazil); with a KMF module it is read from the module |
3. **System OAuth > JWT Provider**: **Name**, **Expiry Interval (sec)**, **Signing Configuration** (the JWT key), plus the claims to send.
4. The provider record with **Default Grant type** = JWT Bearer.
5. On its OAuth entity profile, select the JWT provider.

## Private Key JWT (client authentication)

Instead of sending a client secret, the instance authenticates to the token endpoint with a signed JWT: parameters `client_assertion` and `client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer`. The provider must hold the matching public key.

- Outbound OAuth: on the provider record add the fields **Send Credentials** and **JWT Provider** to the form; set *As Private Key JWT*, grant type Client Credentials.
- OIDC single sign-on: the same two fields on the OIDC identity provider's registry record ([[Multi-Provider SSO - SAML and OIDC]]).
- Prerequisites as for JWT bearer: keystore, JWT key, JWT provider.

## Workload Identity Federation (Azure, Google Cloud)

The instance signs a JWT with a private key that stays in the Key Management Framework; the cloud provider fetches the public key from the instance's JWKS endpoint, validates the signature and issues an access token. **No client secret is stored.** It is additive: existing secret-based records keep working.

Needs on the instance: a KMF cryptographic module, a JWT key with **Key Source** = KMF Cryptographic Module, a JWT provider. The cloud side needs the instance's issuer URL (`/.well-known/openid-configuration`) and JWKS URL.

**System OAuth > Workload Identity Connections > New**, choose the cloud; business rules create the OAuth entity and profile (shown on tabs *OAuth Entity*, *OAuth Entity Profile*, *OAuth Entity Scopes*, *JWT Provider*, *JWT Key*). Afterwards add the scopes and confirm the JWT key is KMF-backed.

| | Microsoft Azure | Google Cloud |
|---|---|---|
| Grant | client credentials with the JWT as `client_assertion` | token exchange (`urn:ietf:params:oauth:grant-type:token-exchange`) with the JWT as `subject_token`, sent to Google's STS endpoint |
| Cloud-side setup first | app registration with a **federated credential**: issuer `https://<instance>.service-now.com`, a subject, audience `api://AzureADTokenExchange` | a Workload Identity Pool and an OIDC provider inside it |
| Form fields | **Connection Name**, **Application (Client) ID**, **Directory (Tenant) ID**, **Subject to send in the token**, optional **Azure URL Override** | **Connection Name**, **Project Number**, **Identity Pool Name**, **Identity Provider Name** |
| Trap | the subject must match the federated credential exactly; a mismatch fails without a clear error | scopes are per target resource, for example `https://www.googleapis.com/auth/cloud-platform` |

## Scripting

Server-side APIs; in a scoped application use the `sn_auth` namespace.

| Class | Purpose |
|---|---|
| `GlideOAuthClient` | request and revoke access and refresh tokens |
| `GlideOAuthClientRequest` | build the request (`setParameter`, `setScope`, `setGrantType`) |
| `GlideOAuthClientResponse` | read the response |
| `GlideOAuthToken` | the token and its details |
| `sn_auth.GlideJWTAPI` | `generateJWT(<JWT provider sys_id>, <header JSON string>, <payload JSON string>)` returns a signed JWT |

- Script include `OAuthUtil` can be customised to intercept request parameters and parse unusual provider responses.
- To have the token saved in the instance database under a default profile, set three parameters on `GlideOAuthClientRequest`: `oauth_requestor` (sys_id of the owner, such as a user or an email account), `oauth_requestor_context` (by convention the table name of that owner), `oauth_provider_profile` (sys_id of the profile). Grant type and scope then come from the profile.
- JWT API scripts selectable on a JWT provider: `JWTTokenRestricted` (administrators decide who may generate) and `JWTTokenInternal` (read-only; any logged-in user).

Example, server side (Scripts - Background or a script include; global or scoped):

```javascript
var jwtAPI = new sn_auth.GlideJWTAPI();
var header = JSON.stringify({ kid: 'example-key-id' });
var payload = JSON.stringify({ iss: 'example-issuer', sub: 'example-subject', jti: 'example-jti' });
var jwt = jwtAPI.generateJWT('<JWT_PROVIDER_SYS_ID>', header, payload);
gs.info('JWT generated, length ' + jwt.length);
```

## Discrepancies in the docs

- The third-party provider form gives the refresh token default once as "8,640,0000" and once as 8,640,000 seconds; the second matches the 100 days stated elsewhere.
- The JWT key form lists only RSA 256 and ES256 for signing outbound, while the inbound JWT grant accepts the wider RS/ES/HS families.
- The outbound REST message page describes the endpoint as "the instance that is the authorization server", written for instance-to-instance use; for another provider it is that provider's API URL.

## Related

- [[OAuth 2.0 Inbound - The Instance as OAuth Provider]] · [[Personal OAuth Authentication and Web Embeddables Sessions]] · [[Inbound API Authentication and API Access Policies]] · [[Certificates in Authentication - Certificate Login, Mutual TLS and Outbound Certificate Policies]] · [[Multi-Provider SSO - SAML and OIDC]] · [[Integration Options and Interfaces Overview]]
