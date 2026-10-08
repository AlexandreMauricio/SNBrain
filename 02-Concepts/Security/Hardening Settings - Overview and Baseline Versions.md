---
type: reference
tags: [reference, security, instance-admin, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Platform Security > Hardening settings (16 chapter files, about 19,600 cleaned lines, 328 setting pages in 14 categories plus the baseline pages). Read 2026-10-08 through the docs site - the introduction page in full; the Baseline versions overview and the New and Deleted lists of every baseline in full; the Updated hardening settings pages (about 5,500 lines of old-versus-new wording per setting) only sampled (start of baseline 9.0) and counted by script; the 328 setting pages as described in the four category notes. The lists of highest-scoring, non-default and safe-harbor settings were computed from the parsed data. https://www.servicenow.com/docs/r/platform-security/instance-security-hardening-settings/security-hardening-settings.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Hardening Settings - Overview and Baseline Versions

**What this is:** how to read the Security Center hardening settings catalogue (328 documented settings in Brazil), which settings matter most, which ones a new instance does not meet out of the box, and how the catalogue changed from baseline to baseline.
**Where:** Security Center > Security configuration console > Security hardening
**Role required:** `admin`

The settings themselves, by category:

| Note | Categories | Settings |
|---|---|---|
| [[Hardening Settings - Access Control]] | access control | 101 |
| [[Hardening Settings - Authentication and Session Management]] | authentication; session management | 73 |
| [[Hardening Settings - API, Architecture, Communications and Configuration]] | API and web service; architecture, design and threat modeling; communications; configuration | 67 |
| [[Hardening Settings - Validation, Files, Logging and Other]] | validation, sanitization and encoding; file and resources; malicious code; error handling and logging; data protection; business logic; stored cryptography | 87 |

The tool and its score: [[Security Center]]. Procedure: [[Raise the Hardening Compliance Score]].

## What each setting page gives

| Attribute | Meaning |
|---|---|
| Configuration name | the property, plugin, or (for a few) table record checked |
| Configuration type | where it lives: System Properties (`sys_properties_list.do`), MID Server properties, plugins, a table |
| Data type | Boolean, integer, string, plugin ... |
| Recommended value | what Security Center counts as compliant |
| Default value | what a new instance ships with |
| Fallback value | what the platform uses when the property record does not exist (on older pages called base system value) |
| Security risk | a CVSS-based severity score from 0.0 to 10.0 and the reasoning |
| Functional impact | what may change or break when the recommended value is applied |
| Dependencies and prerequisites | other properties or plugins that must be set for it to matter |

Severity bands: Critical 9.0 to 10.0; High 7.0 to 8.9; Medium 4.0 to 6.9; Low 0.1 to 3.9; None 0.0. Some settings can only be changed by ServiceNow support.

## Reading rules worth remembering

- **Default is not fallback.** Many properties are absent on upgraded instances; the fallback is then often the *insecure* value (for example `glide.security.use_csrf_token`: default true, fallback false). "Exists and is set to" in a recommendation usually means: create the record.
- **Safe-harbor properties cannot be set back** once changed: `glide.security.strict.updates`, `glide.sys.domain.include_domain_condition_on_join`, `glide.enforce_security_scope.sn_hr_core` and `...sn_hr_le`, `glide.soap.require_content_type_xml`, `glide.basicauth.required.databrokerrestapiprocessor`, `glide.enable.password_policy`, `glide.update_set.remote.check_host`, `com.glide.snap.enable_scan`, `glide.cookies.http_only`, `glide.security.manager`, `com.glide.cs.html.sanitizer.enabled`, `glide.ui.escape_html_list_field`, `com.snc.kmf.signature.validation.flag`. A few others are "no database override" (fixed by the platform).
- Settings come in **families** that only make sense together:

| Family | Members |
|---|---|
| Inbound processors need a login | `glide.basicauth.required.<csv, excel, pdf, xml, jsonv2, unl, rss, wsdl, xsd, schema, soap, api, importprocessor, scriptedprocessor ...>`: without them requests run as the guest user |
| CSRF | `glide.security.use_csrf_token`, `...csrf_previous.allow`, `...csrf_previous.time_limit`, `...csrf.strict.validation.mode`, `...csrf.rest.public_csrf.enabled`, `...csrf.processor.all.authenticated.enabled` |
| Application data stays with its application | `glide.enforce_security_scope.<scope>` and `<scope>.impersonateCheck` (HR and about fifty other scopes) |
| Cross-scope dot-walking | `glide.script.dot_walk.enforce_cross_scope_access_all_tables`, `...log_and_allow_violations` (overrides the first), `...add_attribute_on_table_create` |
| Query ACLs against blind inference | `com.glide.security.query_acl.enabled.<sub_lists, list_count, knowledge_quick_links>`, `glide.security.query_acl.enabled.data_table`, `glide.db.encoded_query.check_function_field_query_acls` |
| Outbound TLS trust | `com.glide.communications.httpclient.verify_hostname`, `...verify_revoked_certificate` (gate), `...ocsp_allow_network_error`, `...disable_crl_check`, `...fail_on_non_pass_crl_status` |
| Session lifetime | idle: `glide.ui.session_timeout`, `glide.guest.session_timeout`; absolute: `glide.ui.active.session.life_span`, `glide.guest.active.session.life_span`, `glide.integrations.active.session.life_span`, with `glide.active.session.timeout.invalidate.session` |
| Basic authentication restriction (MFA cannot be bypassed through the API) | `glide.authenticate.basic_auth.restriction.active`, `.allowed_roles`, `.allowed_users`, `.allow_snc_external`, `.restriction.default_decision`; exception table `sys_user_basic_auth_exception` |
| Password reset throttling | `password_reset.request.*` and `password_reset.sms.*` |
| Script sandboxing | `glide.script.use.sandbox`, KittyScript `com.glide.script.sandbox.ks.watchdog.*` and `com.glide.script.kittyscript.validation.mode`, static analysis `com.glide.script.static_analysis.*` |

## Highest-scoring settings (CVSS 8.8 and above)

| Score | Setting | Property or plugin |
|---|---|---|
| 10.0 | Enable script sandbox | `glide.script.use.sandbox` |
| 9.8 | Enable High Security plugin | `com.glide.high_security` |
| 9.8 | Restrict XML external entities | `glide.xml.entity.whitelist.enabled`, `glide.xml.entity.whitelist` |
| 9.8 | Require XMLdoc2 entity validation with allowlist | `glide.stax.whitelist_enabled` |
| 9.1 | Restrict knowledge bases access | `glide.knowman.block_access_with_no_user_criteria` |
| 9.1 | Enforce KittyScript validation for guest sessions | `com.glide.script.kittyscript.validation.mode` |
| 9.0 | Jelly JS interpolation protection (plain and nested) | `glide.ui.jelly.js_interpolation.protect`, `...protect_nested_expressions` |
| 9.0 | Disable entity expansion in the streaming XML parser | `glide.stax.allow_entity_resolution` |
| 8.8 | Validate SOAP content type | `glide.soap.require_content_type_xml` |
| 8.8 | Rotate HTTP session identifiers | `glide.ui.rotate_sessions` |
| 8.8 | Restrict access to background script | `glide.script_processor.admin` |
| 8.8 | Escape XML markup; Escape JavaScript; Enable HTML Sanitizer; no script in `[code]` tags | `glide.ui.escape_text`, `glide.html.escape_script`, `glide.html.sanitize_all_fields`, `glide.ui.security.codetag.allow_script` |

## Settings a new instance does not meet by default

Where the documented default differs from the recommended value, so these are the usual non-compliant findings on a fresh instance (plugin and list-type settings aside):

| Area | Property (recommended value) |
|---|---|
| ACLs and scopes | `com.glide.acl_check_all_filter_on_new` (true); `glide.rest.table_api.admin_only_sys_fields` (true); `glide.cms.dashboards.sharing_with_secure_search` (true); `csm_cmdb_model.customer_visible_flag` (true); `glide.enforce_security_scope.sn_hr_le`, `...sn_hr_va`, `...sn_svc_appl_info` (true); `sn_hr_core.impersonateCheck` (true); `com.snc.platform.security.oauth.mcp.aig_scope_support` (true) |
| Network | `glide.ip.authenticate.strict` (true); `com.glide.communications.httpclient.ocsp_allow_network_error` (false) |
| Authentication | `glide.oauth.inbound.ropc.grant_type.disabled` (true); `glide.authenticate.multifactor.email.otp.enabled` (false); `glide.apply.password_policy.on_login` (true); `glide.authenticate.basic_auth.allow_snc_external` (false); basic authentication default decision (revoke); password length 15 to 64 |
| Sessions | `glide.active.session.timeout.invalidate.session` (true) with the life-span properties (1 to 720 minutes; default 0 = unlimited) |
| Mobile | `glide.sg.device_encryption_enabled`, `glide.sg.blur_ui_when_backgrounded`, `glide.sg.clear_pasteboard_when_backgrounded` (true) |
| Logging and audit | `com.glide.security.protected_table.enabled` (true, through the guided activation); `glide.audit.track_impersonation` (true); `mid.log.command_audit.enable` (true, per MID Server) |
| Files | `glide.security.file.mime_type.validation.inbound_email` (true); `glide.attachment.enable_secure_filename_validation` (true) |
| Scripts and code | `com.glide.script.static_analysis.enable_sync` (true); `com.glide.hub.code_signing.full.validation.enabled` (true); KittyScript phase (3) |
| Chat | `glide.cs.sanitize_inbound_messages.enabled` (true) |
| Cryptography | `glide.security.3des.static_keys_usable` (false, set by the removal job) |

Several of these change behaviour for integrations (CSRF on processors, static analysis in blocking mode, file name validation, basic authentication restriction): read the functional impact on the setting and test on sub-production first.

## Baseline versions

Security Center reads a defined subset of properties; that subset is the *baseline*, versioned with the application.

| Security Center | Baseline | Families | Store release | Installed by default with |
|---|---|---|---|---|
| 3.5 | 9.0 | Brazil | September 2026 | Brazil |
| 3.3 | 8.0 | Australia | March 2026 | Australia |
| 3.2 | 7.0 | Zurich | August 2025 | Zurich |
| 2.2 | 6.0 | Xanadu, Yokohama | May 2025 | Store only |
| 2.0 | 5.0 | Xanadu, Yokohama | November 2024 | Yokohama |
| 1.6 | 4.0 | Washington DC, Xanadu | August 2024 | Store only |
| 1.5 | 4.0 | Washington DC, Xanadu | May 2024 | Xanadu |
| 1.3 | 2.0 | Vancouver, Washington DC | November 2023 | Washington DC |
| 1.2 | 1.0 | Utah, Vancouver | August 2023 | Store only |
| 1.1 | 1.0 | Utah, Vancouver | May 2023 | Vancouver |

### Added

| Baseline | New settings |
|---|---|
| **9.0** (33) | static analysis (enable, synchronous mode, all users); KittyScript sandbox enforcement and guest validation; CSRF for session-authenticated REST APIs and for authenticated processors, anti-CSRF token; cross-scope dot-walk enforcement and no log-and-allow mode; domain access control on all tables; data separation enforcement (Mosaic); strict deny for ACLs with only deleted roles; no unauthenticated roleless scripted ACLs; script authorship restricted to authorized users; basic authentication restriction (allowed users, allowed roles, default decision); CRL revocation checking (enable, enforce); MID Server governance checks, appropriate access levels, registration key retries; least privilege on scoped MCP OAuth tokens; REST API access policy key normalization; Flow Designer signature verification; Code Signing audit records and audit exclusions; sanitization of inbound Virtual Agent messages; validation error details hidden; Platform Analytics export roles; JWT trust for guest embedded sessions; session activity timeout |
| **8.0** (19) | field ACLs on records created from a filtered list; Jelly interpolation protection (plain, nested); Identity and Access Audit; impersonation history and impersonation event tracking; MIME validation for inbound email attachments and for multi-extension file names; AI: Guardian for external agents, role masking for agents, Bedrock boundary checks, default roles on skill ACLs, voice agent MFA and no KBA as single factor, voice chat guest impersonation; REST API sessions not reusable in the UI; anti-CSRF for user preferences; no OAuth implicit grant; scope access controls on new tables |
| **7.0** (15) | cross-scope checks on Service Portal forms; query ACLs on database functions; document classification for public permalinks; system fields writable only by admins in the Table API; approval for agent-made Microsoft 365 group changes; Data Generation exclusions; read roles for catalog variable search; valid choice in query strings; restricted binding for bearer tokens; ROPC disabled; certificate trust (returned); 3DES keys; Impact Workspace link and tag rules; Contextual Search redirect |
| **6.0** (16) | application-specific ACLs only (`glide.enforce_security_scope.<scope>`); `<scope>.impersonateCheck`; legacy jQuery UI; recommendations on risky UI pages; password policy at login; CSRF warning cannot be accepted; password length; high-assurance session length and failed attempts, continuous authentication on mobile; deprecated TLS versions; local login for SSO users; MFA setup bypasses; verbose HTTP logging; SAML relay state; 3DES algorithm |
| **5.0** (14) | HR scope enforcement (core, lifecycle events, virtual agent), service application information; Service Portal widget allow lists; translated HTML sanitizing; empty ACL creation blocked; Virtual Agent embedded client not public; token cleanup; global app development by role; ACLs for Simple List widget queries; session ends with the OAuth token; impersonation restricted to admin |
| **4.0** (9) | Field Service query rules; flow context read access; mobile session access (policy and refresh interval); inactive users cannot log in; Event Management assignment group roles; HR agent workspace and license/permit scope enforcement; explicit role review |
| **2.0** (about 40) | archive table ACLs; Java security manager; certificate revocation and OCSP on network error; protected tables; strict elevate privilege; session life spans and proactive invalidation; MID audit log; secure insertMultiple; dashboard sharing rules; OAuth parameters in POST body; scope fencing legacy behaviour; JMS factories; session audit events; catalog add-item access; device encryption; MIME check in AttachmentCreator; guest walk-up CAPTCHA; target cloning; SVG content security policy; CSRF token validation time; knowledge base access; referrer policy; HR emails from personal addresses; and others |

### Removed

| Baseline | Removed settings |
|---|---|
| 9.0 | Restrict access to specific IP ranges plugin; Hide user comments on articles; Disable embedded HTML code |
| 8.0 | Certificate based authentication not enforced; Enable updated version of Multi SSO plugin; Set allowed MIME child types |
| 7.0 | Disable password-less authentication; Escape XML response; Minimize one-time out-of-band verifier lifetime |
| 6.0 (22) | the individual HR, public sector and playbook scope settings (folded into the generic scope setting); global administrators bypassing scoped restrictions; legacy AngularJS; field ACLs in GlideRecordSandbox; downloadable file types in static content; SAML time constraint; delegated developers read access; password policy on all methods; mobile UI obfuscation (classic); SSL in LDAP; ML attachment size; credentials on the welcome page; allowed Java packages; strict code signing checks |
| 5.0 (9) | Event Management HTTP processor authentication; custom journal entries; no password policy at login; raw database query execution; log HTML sanitization; anti-CSRF token; certificate trust; LDAP initial distinguished name; minimal password length |
| 4.0 (about 30) | many allow-list style settings (read-only tables, GraphQL properties, cross-origin messaging, downloadable file types, script execution roles, record history roles), LDAP one-time passwords, default password complexity, trusted IP addresses for authentication, mobile offline roles, and others |
| 2.0 (5) | Code Signing for configuration data; Glide KMF encrypter; instance-level encrypter; explicit roles internal deny list; direct inserts to the MID ECC queue |

A removed setting is no longer scored; its page often remains in the docs (marked *Removed in Security Center x*), and the property keeps working.

### Updated

Each baseline also revises existing settings (wording, default and fallback values, risk text). Counted by script, not read in detail: 9.0 about 156 changed attributes, 8.0 about 183, 7.0 about 31, 6.0 about 42, 5.0 about 42, 4.0 about 47, 2.0 about 113. In 9.0 most changes fill in previously blank default values; notable rewrites: *Enable protected tables plugin* (now activated through a guided flow, default protected tables listed) and the Jelly interpolation default (true from Australia on).

## Discrepancies in the docs

- Several pages print a recommended value that contradicts their own text: SOAP authorization (`glide.basicauth.required.soap` shown as false), valid query string choice (false in the table, true in the text), Field Service query rules, reset SMS per day (10 recommended, 5 fallback), password length ("at most" and "at least" 64).
- Property names are swapped between the two attachment download pages (`glide.ui.attachment.download_mime_types` and `...force_download_all_mime_types`).
- *Enforce strict user image upload* describes host name verification of outbound TLS, not image uploads; *Enable ACLs for Encoded Query in Simple List Widget* names a different property in its table than in its text.
- A few settings appear twice with an older and a newer page (role-based MFA, CSRF warning bypass, concurrent interactive sessions, public favorites), sometimes with different scores.
- CVSS ratings are occasionally inconsistent with the score band (3.3 labelled High, 3.7 labelled Medium).

## Related

- [[Security Center]] · [[Raise the Hardening Compliance Score]] · [[Security Center Scan Checks and Best Practices]] · [[System Properties Reference]] · [[Access Control Lists (ACLs)]] · [[Multi-Factor Authentication]] · [[Inbound API Authentication and API Access Policies]]
