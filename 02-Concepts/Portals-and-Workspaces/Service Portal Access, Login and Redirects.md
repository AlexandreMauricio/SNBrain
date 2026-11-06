---
type: concept
tags: [concept, portal, security, access-control, roles, release-specific]
status: documented
source: ServiceNow Brazil docs, ServiceNow AI Platform user interface > Service Portal > Configuring Service Portal > Managing portal access (16 topics: SSO, logins and URL redirects, identifier-first login, early redirection, page security, widget security, user criteria and its plugin, property, records, pages and search sources, e-signature, external self-registration, PIV/CAC, deactivate a portal), read 2026-11-06 through the docs site API (map 7xQNQY92V5DYmBMD7wXg9g). The spEsignatureCustom and spAuthCustom UI script bodies are not reproduced.
sn-release: Brazil
verified:
verified-by:
observed-in:
updated: 2026-11-06
---

# Service Portal Access, Login and Redirects

**In one line:** who reaches a portal and what they see: public pages, roles, user criteria on pages, widgets, instances, announcements and search sources, plus how login, SSO and the after-login redirect are wired through `SPEntryPage`.

From the Brazil docs; not tested. Platform side: [[Multi-Provider SSO - SAML and OIDC]], [[Authentication Console and Identifier-First Login]], [[Multi-Factor Authentication]], [[User Criteria and Catalog Access]].

## Ways to control access

| Control | Where | Effect |
|---|---|---|
| **Public** | page, widget | no login; roles are then ignored. Several base pages are public: filter pages on Public is true |
| **Roles** | page, widget, search source, announcement | page: users without the role see links but get "page not found" |
| **Draft** | page | only `admin` sees it |
| **User criteria** | page, widget, widget instance, announcement, search source | Can View / Cannot View lists |
| MFA | instance | enforced at first login or optional from the profile |

Every page request goes through `$sp`, which must stay in **Public Pages** (`sys_public`) as active; a non-public page sends the user to the portal's login page.

**Widget security** (Service Portal > Widgets): authenticated only = Public cleared and Roles empty; by role = Public cleared plus Roles. For a **public** widget that takes a table option, list the tables guests may read in its **Public Table Allow List** related list and check them in the server script before any `GlideRecord(options.table)`:

```javascript
// Widget server script (server, global scope API)
if (!new global.SPWidgetAccessControl().hasPublicAccess(options.table, $sp, options, input)) {
    gs.warn('Deny access to table which is not public: ' + options.table);
    data.isValid = false;
    return;
}
```

## User criteria

1. Plugin **Service Portal User Criteria Support** (`com.glide.service-portal.user-criteria`): creates criteria for portal records already present, not for records added later by other plugins.
2. Property `glide.service_portal.user_criteria_enabled` = true (Service Portal > Properties). Existing roles on pages, widgets and search sources are **converted** into user criteria; false keeps role-based access.
3. Create **User Criteria** (`user_criteria`) only in the platform UI: Users, Groups, Roles, Companies, Locations, Departments, **Match All** (all populated fields must match; default off = any), Advanced **Script** (slower; do not name a function `answer()`), Active.
4. Apply from the Page Editor (page, widget or instance node > **Who Can View** / **Who Cannot View**) or on a search source (**Who Can View Search Sources**).

`glide.sp.entitlement.override` (default `admin`) lists roles that bypass user criteria. After changes, users may need to log out and in again. The overview note records the property default as true ([[Service Portal Overview and Configuration]]).

## Login, SSO and redirects

- **SSO:** plugin `com.snc.integration.sso.multi.installer`. With auto-redirect to the primary IdP the portal follows it; with several IdPs the login page shows *Use external login*. `glide.service_portal.sso.early_redirect.portals` (suffixes) skips the portal login page; a customised Login widget needs the UI macro `sp_sso_early_redirection` updated. `glide.sp.starting.page.ignore.list` (default `login_with_sso,idp_disco`) skips intermediate pages. Known Okta issue: KB0687717.
- **Per portal:** **Use portal-specific authentication**, **Enable local login**, **Portal Identity Providers** (Okta, Microsoft Azure; one alone sends users straight to it), **Identifier first login** (needs multi-provider SSO and an active IFL policy; clear local login and IdPs; takes precedence; customised login widgets need updating), **Enable early redirection** (to IFL or the portal IdP; mirror custom login logic in `sp_sso_early_redirection`).
- **Portal as the instance login page:** property `glide.entry.page.script` = `new SPEntryPage().getLoginURL()`. `SPEntryPage` redirects to the default portal (Employee Center `esc` by default); change `this.portal` in the script include to force another (a trailing slash may upset SSO; the edited script include no longer upgrades).
- **After login:** `glide.entry.first.page.script` = `new SPEntryPage().getFirstPageURL()`: users without roles go to the portal equivalent of the requested page (for example `nav_to.do?uri=change_request_list.do` becomes `/sp?id=list&table=change_request`), users with roles to the platform. This does not stop role-less users reaching the platform: set `glide.entry.loggedin.page_ess` to the portal suffix for that ([[Local Authentication - Login, Password Policy and Password Reset]]). `admin` always passes `user.hasRoles()`. External IdPs must support **RelayState**.
- **Debug:** set `this.logVariables = true` in `SPEntryPage`, log in from another browser, read System Log > All. FAQ: KB0747432.

## Other access features

- **E-signature:** plugin **Approvals with e-Signature** (`com.glide.e_signature_approvals`) and tables in **System Definition > e-Signature Registry**; approvers re-enter their password (touch ID in the mobile app). SSO re-authentication in a new window (desktop SAML only): property `com.snc.integration.esig.window`, two UI scripts **spEsignatureCustom** and **spAuthCustom** (UI Type Mobile / Service Portal, code on the docs page) added as **JS Includes** on the portal's theme. See [[Classic Approvals]].
- **External self-registration:** after setting up External User Registration, pick the configuration in the portal's **External user registration configuration** field; the Login widget shows the link.
- **PIV/CAC:** once certificate authentication is set up, users register their card from their portal profile, then use *Login with PIV/CAC card* ([[Certificates in Authentication - Certificate Login, Mutual TLS and Outbound Certificate Policies]]).
- **Deactivate a portal:** **Inactive** plus optional **Alternate portal** (the suffix is swapped; use page route maps when page IDs differ; HTTP 302 so search engines keep the pages). Not possible for the default portal, a portal used as an alternate, or `/mesp`. Messages come from `sys_ui_message`.

## Example

Make page *Example Self Service* (`example_self_service`) visible only to users in *Example Location*: enable user criteria, create criteria *Example Location Users* (Locations = Example Location), add it under **Who Can View** on the page, and check as *Test User* in another browser after logging in again.

## Related

- [[Service Portal Overview and Configuration]] · [[Service Portal Portal Record, Branding and Themes]] · [[Service Portal Search Configuration]] · [[Access Control Lists (ACLs)]]
