---
type: concept
tags: [concept, security, api, integrations, flows, glide-api, roles, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Authentication (read in full 2026-10-08 through the docs site) - Personal authentication (activate dashboard, configuration, get OAuth token, generate auth URL; 169 lines), Web Embeddables (overview, configure client session access role; 70 lines). https://www.servicenow.com/docs/r/platform-security/authentication/personal-authentication.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Personal OAuth Authentication and Web Embeddables Sessions

**In one line:** two special session situations: **personal authentication**, where an outbound OAuth integration uses a token belonging to the logged-in user instead of one shared integration account; and **embedded sessions**, where ServiceNow components shown inside another website run with reduced roles.

From the Brazil docs. OAuth in general (application registries, grant types) is a later chapter of the same guide.

## Personal authentication (outbound, per user)

For integrations such as cloud file storage where each person must act as themselves at the external system.

- An OAuth 2.0 credential (`oauth_2_0_credentials`) with **IntegrationType** = *Personal* (add the field to the form). Role `oauth_admin`.
- Grant types supported: **Authorization Code** and **Resource Owner Password Credentials**. Not Client Credentials, not JWT Bearer. Also works through a MID Server.
- Dashboard for users to connect, renew and revoke their own authentications: plugin **Personal Authentication** (`com.snc.sn_ihub_personal_auth`, needs an Integration Hub subscription), role `sn_personal_auth.personal_auth_user`.

Setup for a Flow Designer REST step:

1. **Application Registries**: an OAuth registry for the external endpoint.
2. **Connection & Credential Aliases**: an alias; set the endpoint on its **HTTP(s) Connection**.
3. **OAuth 2.0 Credentials**: a credential linked to the registry's profile, **IntegrationType** *Personal*.
4. Each user obtains a token: on the credential, **Get OAuth Token** (and **Manage Tokens**). Only admins can open the credential form, so give users a UI action or a link (below).
5. An action with a **REST step** using the alias; a **subflow** containing it with **Run As** = *User who initiates session* (**not** System User).

Behaviour: no token for the session user = HTTP 401 from the step; an expired access token is renewed automatically while the refresh token is valid. Testing the action alone may fail because it runs as the system.

Checking for a token (server side; global or scoped):

```js
var client = new sn_auth.GlideOAuthClient();
client.setPersonal(true);                       // token of the logged-in user
var token = client.getToken('<credential_sys_id>', '<oauth_profile_sys_id>');
if (token) gs.info('expires in ' + token.getExpiresIn());
```

Link a user without credential access can open to get their first token:

```text
Authorization code:
https://<instance>.service-now.com/oauth_initiator.do?oauth_requestor_context=oauth_2_0_credentials&oauth_requestor=<credential sys_id>&oauth_provider_profile=<profile sys_id>&response_type=code&personal=true

Password grant:
https://<instance>.service-now.com/oauth_password_input.do?sysparm_oauth_requestor_context=oauth_2_0_credential&sysparm_oauth_requestor=<credential sys_id>&sysparm_oauth_provider_profile=<profile sys_id>&sysparm_oauth_personal=true
```

With the plugin installed, the scoped `PersonalAuthAPI` (`getInitiatorURL(aliasId)`) builds the link instead.

## Web Embeddables sessions

ServiceNow web components embedded in a third-party site authenticate through `/now/client/authenticate` with a bearer JWT. Requirements: a dedicated **custom URL** for the instance; property `glide.uxf.lib.embeddables.enabled` = true.

- The resulting session is an **embedded session**: `admin` and `security_admin` are removed from it automatically.
- Plugin **Embedded client access** (`com.glide.security.client_access`), installed with Web Embeddables. **Client Access > Client Access Role Configurations > Embedded Session Role Configuration**: add more roles to remove. Its policy (*Remove high privilege roles Policy*) uses the *Embedded Session* input; with the Zero Trust plugin, IP, location, role, group and provider attribute inputs can be added ([[Zero Trust Access - Session Access and Continuous Authentication]]).
- Further hardening: set the OAuth entity's client type to *Embedded* (needs Zero Trust Access); use a security attribute for embedded sessions in ACLs (this page calls it `IsEmbeddedSession`; the attribute list says `SessionIsEmbeddedGuest` and `IsIframeEmbeddedSession`: [[Security Attributes, Security Data Filters and Field Query Controls]]).

## Related

- [[Adaptive Authentication]] · [[Zero Trust Access - Session Access and Continuous Authentication]] · [[Flows, Subflows and Actions Overview and Architecture]] · [[Integration Options and Interfaces Overview]]
