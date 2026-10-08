---
type: concept
tags: [concept, security, access-control, roles, instance-admin, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Platform Security > High Security Settings (3 topics, 255 cleaned lines) - Exploring High Security Settings with its property table, Activating High Security Settings, read in full 2026-10-08 through the docs site. https://www.servicenow.com/docs/r/platform-security/c_HighSecuritySettings.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# High Security Settings

**In one line:** the plugin behind default-deny access, the separate `security_admin` role with per-session elevation, role-protected system properties, and one page of security switches; active on every new instance.

From the Brazil docs. The same switches with recommended values and risk scores: [[Hardening Settings - Overview and Baseline Versions]].

Plugin **High Security Settings** (`com.glide.high_security`), active on new instances; older instances request it (test on a clone first: default-deny and added ACLs change who can reach what). It also activates Contextual Security.

What it brings:

| Feature | Meaning |
|---|---|
| Default deny | `glide.sm.default_mode` = deny: no matching ACL means no access ([[Access Control Lists (ACLs)]]) |
| `security_admin` | a role not contained in `admin`; must be granted explicitly and **elevated** per session to change ACLs and security properties ([[Explicit Roles and Elevated Privilege Roles]]) |
| Property access control | columns `read_roles` and `write_roles` on `sys_properties`; security properties are readable by `admin`, writable by `security_admin` |
| Read-only system logs | |
| Security warning messages | on-screen notices after certain actions |
| One page of switches | **System Security > High Security Settings** (Yes/No; the same properties show true/false in `sys_properties.list`) |

The properties on that page, all Yes by default unless noted: escaping (`glide.ui.escape_text`, fixed to true since Vancouver; `glide.ui.escape_all_script`; `glide.ui.escape_html_list_field`; `glide.html.escape_script`); sessions and cookies (`glide.ui.rotate_sessions`, set No only with the old stand-alone SAML 2.0 plugin; `glide.ui.secure_cookies`; `glide.ui.forgetme`); request checks (`glide.security.strict.updates`, `glide.security.strict.actions`, `glide.security.use_csrf_token`); web services (`glide.soap.strict_security`, and `glide.basicauth.required.` for wsdl, csv, excel, importprocessor, pdf, rss, scriptedprocessor, soap, unl, xml, xsd); `glide.cms.catalog_uri_relative`; `glide.set_x_frame_options`; `glide.ui.attachment.download_mime_types` (`text/html,image/svg,image/svg+xml`); `glide.security.groupby_acl_check`; `glide.security.diag_txns_acl` (default No); `glide.ui.security.codetag.allow_script` (No); `glide.script.allow.ajaxevaluate` (No); `glide.security.password_reset.uri` (mobile password reset link).

Not on the page but part of the set: `com.glide.communications.httpclient.verify_hostname` (true), `glide.basicauth.required.schema` (true), `glide.security.csrf_previous.allow` (false), `glide.security.csrf_previous.time_limit` (86400), `glide.security.csrf.strict.validation.mode`, `com.glide.security.check_unsanitized_html` (enforce).

## Discrepancies in the docs

- `glide.security.csrf.strict.validation.mode` is listed with default false here and true on its hardening page; `glide.security.diag_txns_acl` No here, true there.

## Related

- [[Hardening Settings - Overview and Baseline Versions]] · [[Hardening Settings - Access Control]] · [[Access Control Lists (ACLs)]] · [[Explicit Roles and Elevated Privilege Roles]] · [[Security Center]] · [[HTML Sanitizer]] · [[Antivirus Scanning]]
