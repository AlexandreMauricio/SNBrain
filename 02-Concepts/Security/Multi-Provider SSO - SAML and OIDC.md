---
type: concept
tags: [concept, security, users, integrations, access-control, admin, scripting, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Authentication > Multi-Provider single sign-on (SSO) (whole section, 86 topics, 3,275 cleaned lines, read in full 2026-10-08 through the docs site) - overview, activation, properties tables and scripts, configuration (properties, identity provider, SP metadata, users, test connection, login URL, federation, Service Portal), account recovery, e-signature, OIDC as identity provider (generic and Facebook), SAML (authentication flow, IdP and SP properties, NameID policy, context class, keystores including BCFKS, certificates, errors and fixes, redirects, cloning, concepts and flows, configuration form, guided tour, deep linking, ADFS, Azure AD, email links, updating old integrations, user provisioning, troubleshooting, login events). The identity-provider-side steps for ADFS and Azure AD and the sample SAML XML are condensed. https://www.servicenow.com/docs/r/platform-security/authentication/c_MultipleProviderSingleSignOn.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Multi-Provider SSO - SAML and OIDC

**In one line:** the instance (the *service provider*) hands login to one or more external **identity providers** (IdPs) over SAML 2.0 or OpenID Connect (or digest tokens); once the IdP vouches for a user, the instance matches a value from the response to a field on the user record and logs that user in.

From the Brazil docs. Step by step: [[Set Up SAML Single Sign-On]]. Errors: [[SSO Login Errors (SAML)]]. Digest tokens and login links: [[Login Links and Digest Tokens - Time Limited Authentication]]. Policies around login: [[Adaptive Authentication]].

- Plugin **Integration - Multiple Provider Single Sign-On Installer** (`com.snc.integration.sso.multi.installer`). Roles `sso_config_admin` (the pages also ask for `business_rule_admin` and `script_include_admin`).
- Tables: Identity Providers (`sso_properties`), `saml2_update1_properties`, `digest_properties`, `oidc_identity_provider`, `sso_federation`.
- Up to 10 IdPs can be shown as buttons on the login page (`glide.authenticate.show.max.sso.login.option`; SAML ones too since Zurich; not shown when the domain extensions plugin is active).

## Which IdP handles a login

In this order:

1. Multi-Provider SSO off: local login.
2. A `glide_sso_id` **cookie** from an earlier successful SSO login: that IdP.
3. The **Auto Redirect IdP**, if one is set: everyone opening the instance URL goes there.
4. Otherwise the user clicks **Use external login** and types their identifier (the user field named in the SSO properties, default `user_name`):
   - user has **SSO Source** `federation:<sys_id>`: the federation's discovery page;
   - user or their company has **SSO Source** `sso:<sys_id of the IdP record>`: that IdP;
   - user unknown and auto-provisioning on: the provisioning IdP (a choice if several);
   - otherwise the **Default** IdP.

A direct link forces one: `https://<instance>.service-now.com/login_with_sso.do?glide_sso_id=<sys_id of the IdP record>`. SSO can be assigned per user or per company, not per group.

## Lock-out protection: account recovery (ACR)

- `glide.sso.acr.enabled` (default on for new instances): **SSO cannot be switched on until at least one admin is registered as an account recovery user**, and once SSO is on, **local password logins are disabled** except for recovery users (policy context *SSO - ACR Context*).
- Becoming a recovery user: set a local password and register MFA, then **Account Recovery > Properties** (or profile > **Enable Account Recovery**). List: **Multi-Provider SSO > Account Recovery > Users**.
- A recovery session is limited to SSO configuration and troubleshooting; timeout `glide.sso.acr.ui.session.timeout` (30 minutes).
- Setting `glide.authenticate.multisso.enabled` to false does not bring local login back while ACR is on.

## SAML identity provider record

**Multi-Provider SSO > Identity Providers > New > SAML**: import the IdP's metadata (URL or XML) or type the values.

| Field | Meaning |
|---|---|
| **Identity Provider URL** | the IdP's entity id; must equal the `Issuer` in responses; unique per record |
| **Identity Provider's AuthnRequest** | the IdP's sign-on URL (HTTP-Redirect binding) |
| **Identity Provider's SingleLogoutRequest** | the IdP's logout URL |
| **ServiceNow Homepage** | `https://<instance>.service-now.com/navpage.do` (where responses are posted) |
| **Entity ID/Issuer**, **Audience URI** | `https://<instance>.service-now.com`; must equal the `Audience` in responses |
| **NameID Policy** | format of the identifier, by default the email address format |
| **User Field** (Advanced) | user table field compared with the NameID (default email) |
| **External logout redirect**, **Failed Requirement Redirect** | where to send users after logout or failure (default page `external_logout_complete.do`) |
| **Default**, **Auto Redirect IdP**, **Active** | **Active** can only be ticked after a successful **Test Connection** |
| Advanced | **Clock Skew** (seconds of tolerance, default 60), **Force AuthnRequest** (always re-authenticate; needed for e-signature and session validation), **Is Passive AuthnRequest**, **Create AuthnContextClass** + **AuthnContextClassRef Method** (forms: `...:PasswordProtectedTransport`; Kerberos: `urn:federation:authentication:windows`), **Single Sign-On Script** (`MultiSSOV2_SAML2_custom`), **Metadata URL from which IDP properties are imported** (lets the instance fetch a new IdP certificate when the old one expires) |
| Encryption And Signing | **Sign AuthnRequest**, **Sign LogoutRequest**, **Encrypt Assertion**, key aliases and passwords of the instance's own keystore |
| User Provisioning | **Auto Provisioning User**, **Update User Record Upon Each Login**, **User groups applied to provisioned users** |

**Generate Metadata** on the record produces the service provider metadata to give to the IdP.

Certificates:

- The **IdP's signing certificate** is stored as an X.509 certificate record in **PEM** format (created automatically by the metadata import). Several may exist; the first active valid one is used. **When the IdP rotates its certificate, the instance must have the new one**, or every SSO login fails.
- The **instance's own keystore** (for signed requests and encrypted assertions): use your own, not the sample. BCFKS (FIPS-compliant, recommended) or Java keystore; in FIPS mode separate ones for signing and encryption. Their record sys_ids go in `glide.authenticate.sso.saml2.keystore` and `glide.authenticate.sso.saml2.encryption.keystore`. Banners and Security Center actions warn before they expire.
- Only the HTTP-Redirect binding to the IdP is supported for requests.
- `glide.ui.rotate_sessions` must be false with the old stand-alone SAML 2.0 plugin.

How a SAML login works: the instance redirects the browser to the IdP with an encoded `AuthnRequest` and a `RelayState` (the page the user wanted: this is what makes **deep links** from emails work); the IdP authenticates and posts back a signed `SAMLResponse`; the instance checks issuer, audience, signature, validity window and `InResponseTo`, reads `Subject/NameID`, finds the user, and keeps the `SessionIndex` for logout.

**User provisioning**: property `glide.authenticate.multisso.user.autoprovision` plus the IdP record's boxes. The first unknown user creates an import table `u_imp_saml_user_<suffix>` and a transform map per IdP (**User Provisioning Transform Map** on the record), editable afterwards.

## OIDC identity provider record

**New > OpenID Connect**: **Name**, **Client ID**, **Client Secret**, **Well-known Configuration URL** from the application registered at the provider; the import fills the rest and creates an OAuth entity (grant type authorization code). Templates for Auth0, Azure AD, Google and Okta come with demo data; a Facebook record `OIDC_Facebook` ships with the instance.

| Field | Meaning |
|---|---|
| **OIDC Entity Profile** | the OAuth entity profile used |
| **Show as login option**, **SSO label**, **Logo URL** | button on the login page |
| User Provisioning | **Automatically provision users**, **Provision using** (ID token, UserInfo endpoint, or both) with its data source and transform map, **Update User on next login** + interval (3,600 s), **User roles applied to provisioned users** |
| Advanced | scripts `MultiSSO_OIDC_custom`, `MultiSSO_OIDC_logout_custom` |

JSON Web Encryption is supported. Several OIDC records may share one well-known URL (since Zurich).

## Federation

**Multi-Provider SSO > Federation**: a federation publishes one metadata file for many IdPs. Fields: **Meta Data URL**, **Discovery Service URL** (where users choose their IdP), **x509 Certificate**, **Type**. Enable the job *Refresh SSO Metadata*; users get **SSO Source** `federation:<sys_id>`. InCommon is preconfigured.

## Redirects and forcing SSO

| Property | Effect |
|---|---|
| `glide.authenticate.honor.sso_record.failed_requirement_redirect` | where a user without SSO credentials is sent when opening a private page (usually the company portal) |
| `glide.authenticate.failed_redirect` | where a failed SSO attempt goes (set it to avoid login loops) |
| `glide.authenticate.external.logout_redirect` | after logout |
| `glide.authentication.external.disable_local_login` | true: the main login page requires SSO (with the first property) |
| `glide.email.override.url` | base URL used for links in notifications, when links must pass through the company portal |

These do **not** force SSO by themselves: `login.do` still accepts a local password. For users who must never log in locally, give them a random password at import (an *onBefore* transform script setting `target.user_password`), and rely on ACR.

## E-signature approvals with SSO

Plugin **Approval with e-Signature** (`com.glide.e_signature_approvals`; needs Code Signing Signatures). The approver re-authenticates at the IdP in a pop-up. SAML: the IdP must honour `ForceAuthn`; tab *eSignature Approval* on the IdP record: **Assertion Consumer URL for eSignature authentication** (`https://<instance>.service-now.com/consumer.do`), consumer index, dialog size; regenerate and re-upload the metadata. OIDC: the same tab.

## Cloning and moving

**Never copy SSO configuration between instances**: it is tied to what is registered at the IdP, and a copied setup makes the target unreachable. Before a clone ([[Instance Clone Overview]]): exclude `sso_properties`, `digest_properties`, `saml2_update1_properties`; preserve the properties starting `glide.authenticate`, `glide.security`, `glide.entry`, `glide.script`, `glide.session`, `glide.saml2`, `com.glide.communications`, `com.snc.integration.saml_esig`; preserve certificates (`sys_certificate`) and include attachments; keep a **local admin** on the target. Do not change the sys_id of an IdP record (users' cookies point at it).

## Monitoring

Events: `external.authentication.succeeded` (user id, URL opened), `external.authentication.failed` (missing requirements; "User does not exist"; "User locked out"), `saml2.logout.validation.failed`. Debug: `glide.authenticate.multisso.debug`, `glide.authenticate.sso.saml2.debug` (validation errors in the log start with `SAML2ValidationError`).

## Provider-specific notes (condensed)

- **ADFS**: export the token-signing certificate (convert DER to PEM); add the instance as a relying party trust from its metadata (no token encryption certificate; identifier = the instance URL; endpoint SAML Assertion Consumer, POST, `.../navpage.do`); claim rules: send the email attribute, then transform it to **Name ID** in email format; a SAML Logout endpoint for single logout; test at the IdP-initiated sign-on page. For Windows-integrated login set the context class to the Kerberos value or stop creating it.
- **Microsoft Entra ID (Azure AD)**: add the ServiceNow gallery application; sign-on URL `.../navpage.do` or the `login_with_sso.do?glide_sso_id=` form; identifier = instance URL; copy the *App Federation Metadata Url* and import it on the instance; assign users; test and activate.
- A **SAML Guided Tour** is available from the help icon of a new SAML record.

## Discrepancies in the docs

- Clock skew default is given as 60 seconds on the form and as 180 (`glide.authenticate.sso.saml2.clockskew`) in the error table.
- `glide.authenticate.show.max.sso.login.option` is listed twice, with defaults 5 and 10.
- One error fix says to set the ADFS hash to SHA-1, while the relying-party page allows SHA-256 or SHA-1.
- The OIDC e-signature page repeats SAML wording (ForceAuthn).

## Related

- [[Set Up SAML Single Sign-On]] · [[SSO Login Errors (SAML)]] · [[Adaptive Authentication]] · [[Multi-Factor Authentication]] · [[Custom Instance URLs]] · [[Login Links and Digest Tokens - Time Limited Authentication]] · [[LDAP Integration]] · [[Instance Clone Overview]]
