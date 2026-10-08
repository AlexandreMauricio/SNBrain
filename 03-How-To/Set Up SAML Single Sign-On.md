---
type: how-to
tags: [how-to, security, users, integrations, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Authentication > Multi-Provider single sign-on (SSO) (read in full 2026-10-08) - Activate Multi-Provider SSO, Configure Multi-Provider SSO properties, Account recovery and Configure an ACR user, SAML 2.0 configuration using Multi-Provider SSO, Generate instance SP metadata, Test IdP connections, Configure users for Multi-Provider SSO, Log in using Multi-Provider SSO, Administer SAML user provisioning. https://www.servicenow.com/docs/r/platform-security/authentication/t_CreateASAML2Upd1SSOConfigMultiSSO.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Set Up SAML Single Sign-On

**Goal:** let users log in to the instance through a SAML 2.0 identity provider (IdP).
**Prerequisites:** roles `admin` and `sso_config_admin`; plugin *Integration - Multiple Provider Single Sign-On Installer*; an administrator at the IdP who can register the instance as an application; a user field whose values match what the IdP sends (usually email).
**Navigation:** All > Multi-Provider SSO

How it works and every field: [[Multi-Provider SSO - SAML and OIDC]].

## Steps

1. **Safety first:** make sure your admin account has a local password and MFA registered, then enrol it as an **account recovery** user (**Account Recovery > Properties** > follow the dialog). SSO cannot be enabled without one.
2. At the IdP, register the instance as a SAML application. Typical values: entity id and audience `https://<instance>.service-now.com`, assertion consumer URL `https://<instance>.service-now.com/navpage.do`, NameID = the user's email address.
3. **Multi-Provider SSO > Identity Providers > New > SAML**: paste the IdP's **metadata URL** (or XML) and import. Check **Identity Provider URL**, **Identity Provider's AuthnRequest**, **ServiceNow Homepage**, **Entity ID/Issuer**, **Audience URI**, **NameID Policy**.
4. *Advanced* tab: **User Field** = the user table field to match (default `email`).
5. Certificate: the import created an X.509 certificate record for the IdP; open it and confirm it is active, PEM, and not about to expire.
6. If the IdP wants it: **Generate Metadata** and give the result to the IdP administrator.
7. **Test Connection**: log in at the IdP in the pop-up; read *SSO Test Results*. Fix errors ([[SSO Login Errors (SAML)]]) until it passes, then **Activate**.
8. **Multi-Provider SSO > Administration > Properties**: tick **Enable multiple provider SSO**; set the user identification field.
9. Decide how users reach this IdP: **Set as Auto Redirect IdP** (everyone), or **SSO Source** = `sso:<sys_id of the IdP record>` on users or companies, or the direct link `login_with_sso.do?glide_sso_id=<sys_id>`.
10. Optional: user provisioning (*User Provisioning* tab + **Enable Auto Importing of users**), then adjust the generated transform map after the first new user logs in.

## Result / how to check it worked

In a private browser window, opening the instance URL (or the direct link) leads to the IdP's login page and back into the instance as the right user. Event `external.authentication.succeeded` is logged. Open an emailed record link while logged out: after the IdP login you land on that record (deep link through RelayState).

## Example

IdP *Example IdP* with metadata at `https://idp.example.com/metadata`. After import the record shows **Identity Provider URL** `https://idp.example.com`, NameID policy email. *Test User* has **Email** `test.user@example.com` on the instance and the same address at the IdP. Test Connection succeeds; the record is activated and set as Auto Redirect IdP. *Test User* opens the instance, is sent to *Example IdP*, signs in, and arrives on the homepage. The admin keeps a recovery login for the day the IdP certificate expires.

## Tables / fields involved

- Identity Providers (`sso_properties`); SAML settings (`saml2_update1_properties`); certificates (`sys_certificate`)
- [[sys_user]]: **Email** (`email`) or another matching field; **SSO Source** (added to the form; column name not given in the pages read (?))

## Gotchas

- With account recovery on, **enabling SSO disables local password login** for everyone except recovery users.
- The IdP's certificate expiring or rotating breaks all logins: set the metadata URL on the record so the instance can fetch the new one, and keep the expiry notification on.
- Clock difference between IdP and instance causes "valid in the future" or "expired" errors: raise **Clock Skew**.
- SSO settings do not survive being cloned or moved by update set in a usable way: configure each instance separately.
- SSO logins are exempt from the default MFA policy; enforce MFA at the IdP or enable MFA with SSO ([[Multi-Factor Authentication]]).
- With a custom URL, register that URL at the IdP too ([[Custom Instance URLs]]).
