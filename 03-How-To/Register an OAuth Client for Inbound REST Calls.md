---
type: how-to
tags: [how-to, integrations, api, security, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Authentication > OAuth authentication (read in full 2026-10-08) - Configure an inbound integration with the authorization code and client credentials grant types, Create an endpoint for clients to access the instance, OAuth authorization code grant flow, Create the Client Credentials system property, Add the OAuth Application User, Manage OAuth tokens, Revoke an OAuth token. https://www.servicenow.com/docs/r/platform-security/authentication/c_OAuthApplications.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Register an OAuth Client for Inbound REST Calls

**Goal:** let an external application call the instance's REST APIs with an OAuth 2.0 access token instead of a stored user name and password.
**Prerequisites:** role `oauth_admin` (and `mi_admin` for the console); plugin OAuth 2.0 (active by default); for machine-to-machine use, a dedicated integration user with only the roles it needs.
**Navigation:** All > Machine Identity Console > Inbound integrations (newer) or All > System OAuth > Application Registry (older)

Concepts, endpoints and every grant type: [[OAuth 2.0 Inbound - The Instance as OAuth Provider]].

## Steps

### A. Machine to machine (client credentials)

1. **Machine Identity Console > Inbound integrations > New integration > OAuth - Client credentials grant**.
2. Fill **Name** and **Provider name**; set the user the token acts as (the pages read say the token represents the application; the exact field label in the console is unconfirmed (?); on the older form it is **OAuth Application User**); add **Auth scopes** and tick **Allow access only to APIs in selected scope** to limit reach.
3. Save; copy the **Client ID** and **Client Secret** into the client's secret store (never into a note or ticket).
4. The client requests a token: POST to `https://<instance>.service-now.com/oauth_token.do`, content type `application/x-www-form-urlencoded`, body `grant_type=client_credentials&client_id=<CLIENT_ID>&client_secret=<CLIENT_SECRET>`.
5. The client calls the API with header `Authorization: Bearer <access_token>`.

Older route for the same result: **Application Registry > New > Create an OAuth API endpoint for external clients**; create system property `glide.oauth.inbound.client.credential.grant_type.enabled` (true | false) = true; add **OAuth Application User** to the form (**Configure > Form Design**) and select the user.

### B. On behalf of a user (authorization code)

1. **New integration > OAuth - Authorization code grant**. Fill **Name**, **Provider name**, **Redirect URL** (the client's callback). Tick the public client box for browser or mobile apps (PKCE, no secret).
2. The client sends the browser to `https://<instance>.service-now.com/oauth_auth.do?response_type=code&client_id=<CLIENT_ID>&redirect_uri=<callback>&state=<random>` (public clients add `code_challenge` and `code_challenge_method=S256`).
3. The user logs in and selects **Allow**; the browser returns to the callback with `code` and `state`.
4. The client posts to `oauth_token.do`: `grant_type=authorization_code`, `code`, `redirect_uri`, client id and secret (or `code_verifier`).
5. When the access token expires: `grant_type=refresh_token` with the refresh token.

## Result / how to check it worked

The token response contains `access_token`, `token_type` Bearer and `expires_in` (1,800 by default). A Table API call with the Bearer header returns data according to the acting user's roles and ACLs. The token appears in **System OAuth > Manage Tokens** (and for a user under **Self-Service > My Connected Apps**).

## Example

Integration *Example Integration*, client credentials, acting as *Test User* (an integration account with role `itil`), auth scope limited to the Table API. The client posts its id and secret to `https://<instance>.service-now.com/oauth_token.do`, receives a token valid for 30 minutes, and reads `https://<instance>.service-now.com/api/now/table/incident?sysparm_limit=1` with the Bearer header. It asks for a new token when a call returns 401.

## Tables / fields involved

- Application Registries (`oauth_entity`): **Client ID**, **Client Secret**, **OAuth Application User** (column names not given in the pages read (?))
- OAuth tokens (`oauth_credential`): **Token**, **Type**, **Expires**
- [[sys_user]]: the acting user

## Gotchas

- Token requests must be form-encoded POSTs; JSON bodies and credentials in the URL are refused (`glide.oauth.allow.parameters.in.post.body.only`).
- `state` is mandatory on newer instances: *Missing State parameter in request*.
- Client credentials tokens have no refresh token: request a new one.
- The token carries the acting user's rights: ACLs, API access policies and auth scopes still apply ([[Inbound API Authentication and API Access Policies]]).
- Revoke a leaked token with **Revoke Access** on the token record, or `oauth_revoke_token.do?token=<token>`; rotate the client secret as well.
- With a custom URL, register it as an additional redirect URL ([[Custom Instance URLs]]).
- Button labels for the grant types in the console are paraphrased here; check the wording on the instance.
