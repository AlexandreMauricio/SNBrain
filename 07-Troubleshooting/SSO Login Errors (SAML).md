---
type: troubleshooting
tags: [troubleshooting, security, users, integrations, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Authentication > Multi-Provider single sign-on (SSO) (read in full 2026-10-08) - Common IdP connection errors, Troubleshoot script issues with SAML, Multi-SSO (SAML 2.0) errors and fixes, SAML 2.0 troubleshooting, Monitor the event queue for login activities, Update your existing SAML 2.0 integration. https://www.servicenow.com/docs/r/platform-security/authentication/saml-errors.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# SSO Login Errors (SAML)

**Symptom:** **Test Connection** on an identity provider record fails, or users are bounced back from the IdP with an error, loop between instance and IdP, or land on the wrong page.
**Cause:** almost always a mismatch between what the IdP sends and what the instance expects (certificate, issuer, audience, NameID value, time), found in the log.
**Fix:**

| Message in the log or test result | Cause | Fix |
|---|---|---|
| `NotAfter: <date>`; *Failure to check the validity of the certificate* | the IdP certificate stored on the instance expired | upload the current PEM certificate; check clocks |
| *Unable to locate SAML 2.0 certificate*; *Could not find a digital signature* | no active certificate record | add or activate the PEM certificate |
| *Certificates do not match*; *Failure to validate signature profile*; *Signature did not validate against the credential's key* | the IdP signs with a different certificate (rotated), or wrong format | compare with the certificate inside the SAMLResponse; replace |
| *Assertion issuer is invalid. Expect ... actual ...* | **Identity Provider URL** differs from the response's `Issuer` | correct the record (must be unique per IdP) |
| *Assertion audience mismatch*; *AudienceRestriction validation failed* | **Audience URI** differs from what the IdP sends | make both the instance URL |
| *User Field validation failed* | the field named in **User Field** does not exist | fix the field name |
| user "does not exist" although the IdP login worked | no user whose field equals the NameID | align values, or enable provisioning |
| *Subject / Assertion is valid in the future* or *is expired* | clock difference | raise **Clock Skew** (`glide.authenticate.sso.saml2.clockskew`; try 300); check the IdP's time |
| *InResponseTo ... mismatch* | response answers another request: bookmarked login URL, or a load balancer problem | have users bookmark the instance URL, not the IdP redirect; check with the IdP admin |
| *SessionIndex value not found* | the IdP omits `SessionIndex` | IdP must include it |
| *No valid SubjectConfirmation found* | IdP error: status `Responder` instead of `Success`, or conditions missing | read the full response; IdP admin |
| `urn:oasis:names:tc:SAML:2.0:status:Requester` | the IdP rejected the request itself | review the AuthnRequest settings with the IdP admin (signing, context class) |
| signature algorithm rsa-sha256 "not the expected" rsa-sha1 | algorithm mismatch | align the IdP's hash algorithm with the instance setting |
| *Cannot logout of IdP's session* | wrong **SingleLogoutRequest** URL | fix it |
| endless loop between instance and IdP | failure page is itself protected; or `glide.security.url.whitelist` is set without the IdP host | set `glide.authenticate.failed_redirect`; add the IdP host to the allow list |
| `... AuthnRequestBuilder] is not a function` | plugin not loaded on every node | support must restart the nodes |
| after login the user lands on the wrong page | `RelayState` not returned by the IdP | watch the browser's network trace through the round trip |
| portal (CMS) pages not protected by SSO | `view_content.do` is a public page | set its public-page record inactive |
| cannot return to a portal path after login | relative URLs are ignored in `uri` | use `nav_to.do?uri=...`, or build `RelayState` in the login script |

## How to confirm the cause

1. Turn on debug: `glide.authenticate.multisso.debug` (and `glide.authenticate.sso.saml2.debug` on older setups). Performance cost: turn it off afterwards.
2. Reproduce with **Test Connection**: *SSO Test Results* and *Testing SSO Logs*.
3. System log: lines starting `SAML2ValidationError`; the raw SAMLResponse is logged, so issuer, audience, NameID and dates can be read directly.
4. Events `external.authentication.failed` with the reason in parameter 2 ("User does not exist", "User locked out", or the missing requirement).
5. If nobody can log in at all: use an account recovery login ([[Multi-Provider SSO - SAML and OIDC]]).

Old customised setups: if the SAML installation exits were modified, back them up, revert to baseline, upgrade the plugin, then re-apply the changes in `MultiSSO_SAML2_Update1` and `SAML2_update1`.

## Related

- [[Multi-Provider SSO - SAML and OIDC]] · [[Set Up SAML Single Sign-On]] · [[Adaptive Authentication]] · [[LDAP Login or Import Problems]]
