---
type: reference
tags: [reference, security, instance-admin, admin, access-control, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Platform Security > Hardening settings, the validation sanitization and encoding (42), file and resources (11), malicious code (6), error handling and logging (16), data protection (4), business logic (5) and stored cryptography (3) categories. All 87 setting pages were parsed by script for the property or plugin name, recommended and default values and CVSS score; the description, security risk, functional impact and dependency text of every page was then read 2026-10-08 in a condensed form (repeated boilerplate and the generated summary blocks removed, very long introductions cut at 900 characters, risk and impact text at 600). The Remark column is our own summary. https://www.servicenow.com/docs/r/platform-security/instance-security-hardening-settings/sc-validation-sanitization-and-encoding.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Hardening Settings - Validation, Files, Logging and Other

**What this is:** the Security Center hardening settings of the validation sanitization and encoding (42), file and resources (11), malicious code (6), error handling and logging (16), data protection (4), business logic (5) and stored cryptography (3) categories: the property, plugin or record each one checks, the value Security Center expects, the base-system default, the CVSS score ServiceNow assigns to non-compliance, and what the setting does.
**Where:** Security Center > Security configuration console > Security hardening > All settings; properties themselves under `sys_properties.list`
**Role required:** `admin` (many properties need elevation to `security_admin` to change)

How the score works, baseline versions and reading rules: [[Hardening Settings - Overview and Baseline Versions]]. Working the list: [[Raise the Hardening Compliance Score]]. Other categories: [[Hardening Settings - Access Control]] · [[Hardening Settings - Authentication and Session Management]] · [[Hardening Settings - API, Architecture, Communications and Configuration]].

Reading the tables: *Default* is the value shipped on a new instance; many properties are absent from `sys_properties` and then use a fallback, which is sometimes the insecure value. *Safe-harbor* means the property cannot be set back once changed. `?` or *not stated* means the page did not give the value.

## Validation, sanitization, and encoding (42)

Escaping and sanitizing input and output; XML parsing; script sandboxing.

### HTML, script and Jelly output

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Allow HTML Links to Trusted Domains in the Description Fields of the Impact Workspace Module | `sn_impact_common.whitelisted.url_HTML_injection` | the default list of trusted domains | the same | 4.4 Medium | Domains allowed in links inside Impact Workspace description fields (empty removes all links). Not part of the scored baseline. |
| Enable HTML Sanitizer | `glide.html.sanitize_all_fields` | true | true | 8.8 High | Sanitize all HTML fields (allow and deny lists in the HTMLSanitizer configuration). Custom markup may be stripped. |
| Enable sanitization of inbound virtual agent chat messages | `glide.cs.sanitize_inbound_messages.enabled` | true | false | 3.5 Low | Strip unsafe HTML from inbound Virtual Agent chat messages (requester and agent are told). Needs `com.glide.cs.html.sanitizer.enabled`. |
| Enforce HTML sanitization | `com.glide.security.check_unsanitized_html` | enforce | enforce | 7.3 High | Unsanitized content assigned to translated HTML fields is rejected (`log_only` is the fallback). |
| Disable JavaScript tags in embedded HTML | `glide.ui.security.codetag.allow_script` | false | false | 8.8 High | No script inside `[code]` tags in journal fields. |
| Enable HTML sanitizer within Virtual Agent | `com.glide.cs.html.sanitizer.enabled` | true | true | 8.0 High | HTML sanitizer for the Virtual Agent web client. Safe-harbor. |
| Enable Jelly JS interpolation protection | `glide.ui.jelly.js_interpolation.protect` | true | true (Australia and later); false before | 9.0 Critical | Jelly expressions inside JavaScript must be recognised as safe or marked `SAFE`; otherwise a URL parameter could be evaluated as server script. Test custom UI pages and macros. |
| Enable Jelly JS interpolation protection for nested expressions | `glide.ui.jelly.js_interpolation.protect_nested_expressions` | true | true | 9 Critical | The same protection for nested Jelly expressions. |
| Escape HTML in list views | `glide.ui.escape_html_list_field` | true | true | 3.1 Low | HTML fields are escaped in lists. Safe-harbor. |
| Escape JavaScript | `glide.html.escape_script` | true | true | 8.8 High | Embedded JavaScript removed from HTML field output. |
| Escape jelly script | `glide.ui.escape_all_script` | true | true | 7.3 High | Jelly output escaped by default; `NOESC:` exempts an expression deliberately. |
| Escape scripts in scratchpad | `glide.ui.escape_scratchpad` | true | true | 6.5 Medium | `g_scratchpad` content escaped. |
| Escape XML markup | `glide.ui.escape_text` | true | true | 8.8 High | XML values escaped by the UI parser (not Service Portal). |
| Sanitize All Translated HTML Fields | `glide.translated_html.sanitize_all_fields` | true | true | 4.6 Medium | All translated HTML fields sanitized, not only those with attribute `html_sanitize`. |
| Sanitize HTML in the Description Fields of the Impact Workspace Module | `sn_impact_common.blacklist_tags_HTML_injection` | at least the default tag list | script, iframe, object, embed, form and others | 4.4 Medium | HTML tags stripped from Impact Workspace description fields. Not part of the scored baseline. |

### Script sandbox and server-side script execution

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Enable the hardened java security manager | `glide.security.manager` | com.glide.sys.security.ContextualSecurityManager | com.glide.sys.security.ContextualSecurityManager | 7.2 High | Java security manager class. Safe-harbor: do not change. |
| Enable script sandbox | `glide.script.use.sandbox` | true | true | 10 Critical | Scripts sent by clients (filters such as `javascript:` conditions, system API) run in a sandbox: only client-callable business rules and sandbox-enabled script includes, no inserts, updates or deletes. |
| Enable KittyScript sandbox security enforcement | `com.glide.script.sandbox.ks.watchdog.enabled`; `.auto.advance`; `.phase.duration.days`; `.phase` | true; true; 14; 3 | true; true; 14; 0 | 8 High | KittyScript sandbox for untrusted-scope scripts: master switch, automatic advance through enforcement phases, days per phase, and the phase (3 = full enforcement). |
| Enforce KittyScript validation for guest sessions | `com.glide.script.kittyscript.validation.mode` | block | block | 9.1 Critical | Guest (unauthenticated) scripts outside a minimal safe syntax are rejected. Test guest-facing reference qualifiers and scripted defaults. |
| Disable AJAXEvaluate | `glide.script.allow.ajaxevaluate` | false | false | 7.3 High | AJAXEvaluate processor (client-sent script evaluation) off. |
| Restrict access to GlideSystemUserSession scriptable API | `glide.sandbox.usersession.allow_unsanitized_messages` | false | false | 8.1 High | Sandboxed scripts cannot call the unsanitized message methods of the user session. |
| Restrict allowed Java packages | `sys_whitelist_member`, `sys_whitelist_package` | empty | n/a | 8.2 High | Tables `sys_whitelist_member` and `sys_whitelist_package` (Java packages exposed to scripts) stay empty. Removed in 6.0. |
| Packages call removal tool | `com.glide.script.packages_call_removal` | plugin active | not stated | Medium | Plugin that finds `Packages.` calls in scripts and proposes Glide API replacements (suggestions in `packages_call_item`). |

### Redirects, cookies and other

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Ensure Contextual Search Do Not Contain An Unvalidated Redirect | `com.snc.contextual_search.cxs_new_window.force_relative_link` | true | true | 3.1 Low | Contextual Search new-window page accepts only relative links. |
| Disable external content URL | `glide.ui.url.external.content` | false | false | 7.2 High | Connect Chat does not fetch previews of external links (server-side request forgery). |
| Enforce relative links | `glide.cms.catalog_uri_relative` | true | true | 2.6 Low | Legacy CMS catalog page accepts only relative URLs. |
| Enforce URL allowlist check | `glide.security.url.whitelist.strict_check`; `glide.security.url.whitelist` | true; your permitted hosts | true; empty | 6.3 Medium | Redirects (for example after logout) only to relative URLs or hosts listed in `glide.security.url.whitelist`. SSO setups must list the IdP host. |
| Unset LDAP Initial distinguished name | `glide.ldap.initial.dn` | blank | blank | 2.7 Low | LDAP initial distinguished name left blank. Removed in 2.0. |
| Enforce strict security of session cookies | `glide.ui.secure_cookies` | true | true | 7.1 High | Strict cookie validation; malformed cookies force a new login. |
| Prevent empty ACL creation | `glide.security.empty_acl.popup_window.enabled` | true | true | 6.5 Medium | Saving an ACL with no role, condition, script or security attribute is blocked with a prompt. (Since Xanadu an empty ACL denies; before, it allowed.) |
| Prevent Reuse of REST API Sessions in UI/Web | `com.glide.processors.aprocessor.donot_reuse_api_session` | true | true | 4.3 Medium | A session created through the REST API cannot be reused as a browser session, which would bypass SSO and MFA. |

### XML parsing

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Disable Entity Expansion within the XMLDocument2 Streaming Parser | `glide.stax.allow_entity_resolution` | false | false | 9.0 Critical | Streaming XML parser (XMLDocument2) does not expand entities. Absent = true, so create it. |
| Escape xml response | `glide.soaprequest.unescape_xml_response` | false | false | 6.4 Medium | SOAP responses keep XML escaping. Removed from the baseline in 7.0. The page text contradicts itself on which value is safe. |
| Minimize entity expansion threshold for GlideXMLUtil scriptable | `glide.xmlutil.max_entity_expansion` | 3000 or less | 3000 | 5.3 Medium | Entity expansion limit for `GlideXMLUtil` (minimum 500). |
| Restrict XML external entities | `glide.xml.entity.whitelist`; `glide.xml.entity.whitelist.enabled` | http://java.sun.com/j2ee/dtds/; true | the same | 9.8 Critical | External XML entities only from the listed source. |
| Require XMLdoc2 entity validation with allowlist | `glide.stax.whitelist_enabled` | true | true | 9.8 Critical | The entity allow list also applies to the streaming parser (billion-laughs defence). |

### Attachments and MIME types

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Restrict downloadable MIME types | `glide.ui.attachment.force_download_all_mime_types` | true | true | 6.4 Medium | true = every attachment is downloaded, never rendered in the browser. The docs print this property name on the list page and the other one here; the names appear swapped. |
| Escape Excel formulas | `glide.export.escape_formulas` | true | true | 6.4 Medium | Exports escape cells starting with `+`, `-`, `=`, `@` (formula injection). |
| Define restricted downloadable MIME types | `glide.ui.attachment.download_mime_types` | text/html, image/svg, image/svg+xml, application/xml, application/xhtm ... | the same | 6.3 Medium | MIME types always downloaded instead of rendered (HTML, SVG, XML). Property names appear swapped with the row above. |
| Restrict uploaded MIME types | `glide.security.file.mime_type.validation` | true | true | 5.4 Medium | Uploads checked for a mismatch between MIME type and content. |
| Set safe content security policy for SVG files | `com.glide.csp.self_script_src_svg` | true | true | 7.1 High | SVG files served with a Content-Security-Policy that forbids scripts. |
| Validate MIME type for multi-extension filenames and polyglot files | `glide.attachment.enable_secure_filename_validation` | true | false | 4.6 Medium | Strict file name validation: blocks double extensions, null bytes and polyglot files. Off by default; uploads with unusual names will start failing. |

## File and resources (11)

Attachments: scanning, size and type.

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Disallow infected file download | `com.glide.snap.infected_download_allowed` | false | false | 6.7 Medium | false = attachments that could not be scanned (antivirus service down) cannot be downloaded. |
| Enable email spam scoring and filtering | plugin com.glide.email_filter; `glide.email.read.active` | plugin active; true | see instance | 8.1 High | Email Filters plugin active (when inbound email is on): spam and virus scores arrive as headers and filtering is done on the instance. |
| Enable antivirus scan | `com.glide.snap.enable_scan` | true | true | 7.7 High | Antivirus scanning of attachments. Safe-harbor. |
| Restrict downloadable files types in static content | `glide.ui.strict_customer_uploaded_static_content` | true | true | 3.1 Low | Restricts which uploaded static content types can be downloaded (list in `glide.ui.strict_customer_uploaded_content_types`). Cannot be overridden in the database. Removed in 6.0. |
| Limit attachment size in training and prediction flows for GraphQL endpoints | `glide.platform_ml_di.max_attachment_size_graphql` | 5,242,880 or less | 5,242,880 | 4.3 Medium | Bytes: attachment size cap in machine-learning training and prediction through GraphQL. |
| Limit attachment size in training and prediction flows | `glide.platform_ml_di.max_attachment_size` | 4,000,000 or less | 4,000,000 | 4.3 Medium | Bytes: attachment size cap in machine-learning training and prediction flows. Removed in 6.0. |
| Limit HTTP response body size | `glide.http.response.get_body.limit.enabled`; `glide.http.response.get_body.limit` | true; 524,288,000 or less | true | 3.1 Low | Cap on the size of an HTTP response body read into memory (against out-of-memory conditions). |
| Limit maximum number of attachments in email | `glide.email.inbound.max_attachment_count` | 30 or less | 30 | 5.3 Medium | Attachments accepted per inbound email. |
| Maximum allowed attachment size | `com.glide.attachment.max_size` | 1024 or less | 1024 | 6.5 Medium | Maximum attachment size in megabytes. |
| Validate file MIME type in AttachmentCreator web service | `glide.attachment.enforce_security_validation` | true | true | 6.7 Medium | Upload checks that the MIME type matches the file extension. |
| Validate MIME Type of Attachments from Inbound Emails | `glide.security.file.mime_type.validation.inbound_email` | true | false | 3.7 Low | The same MIME check for attachments of inbound emails; mismatches are not stored. |

## Malicious code (6)

Static analysis and code signing.

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Apply static analysis to all users | `com.glide.script.static_analysis.only_check_unauthenticated_users` | false | false | 6.8 Medium | false = script static analysis covers authenticated users too. Scripts using patterns such as `Array.prototype` access may be flagged: test first. |
| Block rooted or jailbroken mobile devices | `glide.sg.allow_rooted_jailbroken_device` | false | false | 4.5 Medium | Mobile app refuses rooted or jailbroken devices (client-side check). |
| Enable Code Signing for application configuration data and scripts | `com.snc.kmf.signature.validation.flag` | true | false | 6 Medium | Code Signing switched on. Safe-harbor. Removed from the baseline in 1.3. |
| Enable static analysis | `com.glide.script.static_analysis.disabled` | false | false | 6.8 Medium | false = static analysis of sandboxed scripts is on (detects sandbox escape attempts). |
| Enable synchronous mode for static analysis | `com.glide.script.static_analysis.enable_sync` | true | false | 6.8 Medium | true = a violation blocks the script with a SecurityException; false only logs it. Small latency cost; load-test. |
| Enforce signature verification for Flow Designer artifacts | `com.glide.hub.code_signing.full.validation.enabled` | true | false | 4.4 Medium | Flow Designer artifacts must pass full Code Signing validation; unsigned or altered flows are flagged. Needs Code Signing fully enabled and `security_admin`. |

## Error handling and logging (16)

What is logged, what is audited, and what errors reveal.

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Disable logger for low privilege users in script sandbox | `glide.security.sandbox_no_logging` | true | true | 2.2 Low | Sandboxed scripts of low-privilege users cannot write log entries. |
| Disable secure cookie debugging | `glide.secure_cookie.debug` | false | false | 4.2 Medium | Cookie debug logging off. |
| Disable SQL error messages | `glide.db.loguser` | false | false | 3.1 Low | No SQL error details shown to users. |
| Enable Identity and Access Audit tool | plugin com.glide.security.audit; `glide.identity.security.audit.enabled` | plugin active; true | active; true | 4.6 Medium | Identity and Access Audit: successful changes to users, groups and roles recorded in `sys_security_table_level_audit`. |
| Enable MID audit log | `mid.log.command_audit.enable` | true | false | 4.4 Medium | MID Server property: audit of commands run (`ecc_agent_command_audit_log`), per MID Server. |
| Enable protected tables plugin | `com.glide.security.protected_table.enabled` | true | false | 4.0 Medium | Protected Tables: log tables (syslog, sys_audit, sysevent, transaction and outbound HTTP logs) cannot be tampered with, even by maintenance users. Activate through the guided flow, not by editing the property; integrations writing to those tables will fail. |
| Log all outbound http request fields | `glide.outbound_http.security.log.allow.all.fields` | false | false | 6.8 Medium | Do not log all outbound HTTP fields in plain text. Removed in 1.3.2. |
| Log html sanitization | `glide.html_sanitize.discarded_log.enable` | true | true | 2.4 Low | Log what the HTML sanitizer discards. Removed in 2.0. |
| Log Impersonation History | `identity.impersonation.history.enabled` | true | true | 4.9 Medium | Impersonation sessions recorded in `sys_user_impersonation_history`. |
| Log session audit events | `glide.authenticate.session_access.log_audit_event` | true | true | 6.3 Medium | Zero Trust session access: audit events in `sys_session_access_audit`. |
| Log user impersonation | `glide.sys.log_impersonation` | true | true | 6.4 Medium | Impersonation events logged. |
| Prevent verbose HTTP request logging | `glide.outbound_http_log.override`; `glide.outbound_http_log.override.level` | false; basic | false; empty | 5.0 Medium | Outbound HTTP log level stays *basic*: *elevated* and *all* store headers such as Authorization. |
| Restrict exposure of validation error details to end users | `glide.cs.enable_validation_error_messages` | false | false | 4.3 Medium | Conversational AI returns a generic message, not internal validation details. |
| Restrict vault code signing audit exclusion to defaults | `com.glide.codesigning.tables.excluded_from_audit` | the default list of internal tables | the same | 5.1 Medium | Tables excluded from Code Signing audit: keep to the shipped internal list. |
| Track Impersonation Events | `glide.audit.track_impersonation` | true | false | 4.9 Medium | Audit records show the impersonating user in `sys_audit.user`; otherwise changes look made by the impersonated user. |
| Turn off verbose SQL error messages for import processor | `glide.import.error_message.generic` | true | true | 3.1 Low | Import processor returns a generic error instead of SQL details. |

## Data protection (4)

Confidentiality of cached or copied data.

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Remove remember me | `glide.ui.forgetme` | true | true | 3.5 Low | true hides *Remember me* on the login page. |
| Clear pasteboard when app backgrounds | `glide.sg.clear_pasteboard_when_backgrounded` | true | false | 3.5 Low | Mobile app clears copied text when it goes to the background. |
| Restrict HR case updates from personal emails | `sn_hr_core.restrict_guest_email` | true | true | 3.5 Low | Replies from personal email addresses do not update HR cases. (The functional-impact text states the reverse.) |
| Restrict oauth parameters to POST body | `glide.oauth.allow.parameters.in.post.body.only` | true | true | 4.2 Medium | `oauth_token.do` accepts credentials only in the POST body (or headers), never in the URL. |

## Business Logic (5)

Limits that stop abuse of ordinary features.

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Limit max comments per user per day | `sn_kb_social_qa.max_comments_per_user_daily` | 500 or less | 500 | 3.7 Low | Social Q&A comments per user per day. |
| Limit max subscriptions per user per day | `sn_kb_social_qa.max_subscriptions_per_user_daily` | 500 or less | 500 | 3.7 Low | Social Q&A subscriptions per user per day. |
| Minimize SMTP Recipient Quantity | `glide.email.smtp.max_recipients` | 100 or less | 100 | 4.9 Medium | Recipients per notification email; larger lists are split into several emails. |
| Timeout guest sessions | `glide.guest.session_timeout` | 1 to 30 | 5 on new instances (absent = 0) | 4.3 Medium | Idle timeout for guest (unauthenticated) sessions in minutes; 0 or absent means the general UI timeout applies. |
| Validate remote host | `glide.update_set.remote.check_host` | true | true | 6.3 Medium | Team Development remote instance test validates the host, so it cannot be used to scan internal ports. Safe-harbor. |

## Stored cryptography (3)

Encryption of stored data.

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Enable glide KMF encrypter | `glide.kmf.encrypter.enabled` | true | false | 4.9 Medium | KMF encrypter for Password2 fields instead of the legacy one. Removed in 1.3.2. |
| Disable use of TripleDES/3DES encryption algorithm | `glide.security.3des.encryption.allow` | false | false | 4.2 Medium | 3DES no longer used for encryption. Follow KB1704481 before changing. |
| Prevent usage of 3DES keys | `glide.security.3des.static_keys_usable` | false | true | 5 Medium | 3DES static keys unusable; set by a scheduled job (status in `glide.security.3des.removal_job_status`). |

## Related

- [[Hardening Settings - Overview and Baseline Versions]] · [[Security Center]] · [[Raise the Hardening Compliance Score]] · [[Hardening Settings - Access Control]] · [[Hardening Settings - Authentication and Session Management]] · [[Hardening Settings - API, Architecture, Communications and Configuration]]
