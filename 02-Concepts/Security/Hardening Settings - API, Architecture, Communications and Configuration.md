---
type: reference
tags: [reference, security, instance-admin, admin, access-control, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Platform Security > Hardening settings, the API and web service (19), architecture design and threat modeling (26), communications (7) and configuration (15) categories. All 67 setting pages were parsed by script for the property or plugin name, recommended and default values and CVSS score; the description, security risk, functional impact and dependency text of every page was then read 2026-10-08 in a condensed form (repeated boilerplate and the generated summary blocks removed, very long introductions cut at 900 characters, risk and impact text at 600). The Remark column is our own summary. https://www.servicenow.com/docs/r/platform-security/instance-security-hardening-settings/sc-api-and-web-service.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Hardening Settings - API, Architecture, Communications and Configuration

**What this is:** the Security Center hardening settings of the API and web service (19), architecture design and threat modeling (26), communications (7) and configuration (15) categories: the property, plugin or record each one checks, the value Security Center expects, the base-system default, the CVSS score ServiceNow assigns to non-compliance, and what the setting does.
**Where:** Security Center > Security configuration console > Security hardening > All settings; properties themselves under `sys_properties.list`
**Role required:** `admin` (many properties need elevation to `security_admin` to change)

How the score works, baseline versions and reading rules: [[Hardening Settings - Overview and Baseline Versions]]. Working the list: [[Raise the Hardening Compliance Score]]. Other categories: [[Hardening Settings - Access Control]] · [[Hardening Settings - Authentication and Session Management]] · [[Hardening Settings - Validation, Files, Logging and Other]].

Reading the tables: *Default* is the value shipped on a new instance; many properties are absent from `sys_properties` and then use a fallback, which is sometimes the insecure value. *Safe-harbor* means the property cannot be set back once changed. `?` or *not stated* means the page did not give the value.

## API and web service (19)

Authentication and input checks on inbound web service processors.

### Other API controls

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Normalise REST API access policy key generation | `glide.rest.policy.normalize_apply_all_fields` | true | true | not stated | REST API access policies: when *apply to all* is ticked but a stale specific value remains, ignore the value so the policy really covers everything. Review policies before enabling. |
| Validate SOAP content type | `glide.soap.require_content_type_xml` | true | true | 8.8 High | Inbound SOAP must be `text/xml` (CSRF defence). Safe-harbor: cannot be reverted. Other content types will fail. |
| Prevent OAuth Clients from Using Implicit Grant | `glide.oauth.clients.allowed.for.implicit.grant` | empty | empty | 3.9 Low | Client ids still allowed to use the OAuth implicit grant; implicit requests fail for everyone else. Keep empty. |

### Authentication required per inbound processor

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Require authorization for PDF requests | `glide.basicauth.required.pdf` | true | true | 7.5 High | Basic authentication (or another login) required for PDF export requests; otherwise they run as the guest user. |
| Require Authentication on Event Management HTTP Processor | `glide.basicauth.required.evtmgmthttpprocessor` | true | true | 7 High | Authentication for inbound Amazon SNS requests to Event Management. Removed in 2.0. |
| Require authorization for SOAP requests | `glide.basicauth.required.soap`; `glide.soap.require_ws_security` | false; false as printed (text implies true for the first) | true; false | 8.1 High | SOAP: basic authentication and optional WS-Security headers. The page prints recommended value false for both, against its own text. |
| Require authorization for unload requests | `glide.basicauth.required.unl` | true | true | 7.5 High | Basic authentication (or another login) required for unload (UNL) requests; otherwise they run as the guest user. |
| Require authorization for csv requests | `glide.basicauth.required.csv` | true | true | 7.5 High | Basic authentication (or another login) required for CSV requests; otherwise they run as the guest user. |
| Require authorization for excel requests | `glide.basicauth.required.excel` | true | true | 7.5 High | Basic authentication (or another login) required for Excel requests; otherwise they run as the guest user. |
| Require authorization for import requests | `glide.basicauth.required.importprocessor` | true | true | 5.3 Medium | Import processor requests need authentication (ACLs still apply afterwards). |
| Require authorization for JSONv2 request | `glide.basicauth.required.jsonv2` | true | true | 7.5 High | Basic authentication (or another login) required for JSONv2 requests; otherwise they run as the guest user. |
| Require authorization for WSDL request | `glide.basicauth.required.wsdl` | true | true | 5.3 Medium | WSDL (table schema descriptions) not served without login. |
| Require authorization for XML requests | `glide.basicauth.required.xml` | true | true | 7.5 High | Basic authentication (or another login) required for XML requests; otherwise they run as the guest user. |
| Require authorization for XML output requests | `glide.basicauth.required.xmloutputprocessor` | true | true | 7.5 High | Basic authentication (or another login) required for XMLOutputProcessor requests; otherwise they run as the guest user. |
| Require Authorization for XSD Requests | `glide.basicauth.required.xsd` | true | true | 5.3 Medium | XSD schema requests need authentication. |
| Require authorization for script requests | `glide.basicauth.required.scriptedprocessor` | true | true | 7.2 High | Scripted processors need authentication. |
| Require authorization for SCHEMA requests | `glide.basicauth.required.schema` | true | true | 5.3 Medium | Table schema processor needs authentication. |
| Require authorization for RSS requests | `glide.basicauth.required.rss` | true | true | 7.5 High | Basic authentication (or another login) required for RSS requests; otherwise they run as the guest user. |
| Require authorization for API requests | `glide.basicauth.required.api` | true | true | 8.6 High | REST API requests need authentication. |

## Architecture, design, and threat modeling (26)

Design-level controls: IP allow lists, query ACLs, legacy behaviours.

### Legacy behaviours and miscellaneous

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Capture audit records for Code Signing-protected records | `sn_cse.com.snc.csf.vault_audit_enabled` | true | true | 5.1 Medium | Audit every create, update and delete of Code Signing-protected records (production only). |
| Check impersonation on ACL evaluation in HR App | `sn_hr_core.impersonateCheck` | true | false | 2.7 Low | Admin impersonating a user cannot see that user's HR data. |
| Disable legacy JQuery behavior | `glide.jquery.legacy` | false | false | 7.1 High | Use the patched jQuery versions. |
| Disable GlideRecord scope fencing legacy behavior | `glide.record.legacy_cross_scope_access_policy_in_script` | false | false | 5.0 Medium | false = scoped apps cannot create or update in tables that did not grant it (true restores the old leak). Absent = true. |
| Disable legacy AngularJS behavior | `glide.angular.legacy` | false | not stated | 7.1 High | Use the patched AngularJS. Removed from the baseline in 2.2. |
| Disable local login for users with Single Sign-On (SSO) enabled | (review of users) | n/a | n/a | 4.2 Medium | Review task (KB1649420): users set up for SSO who still have a usable local password. |
| Disable public access to favorites | `glide.ui.magellan.favorites.allow_public` | false | false | 4.3 Medium | Guests do not see the shared guest favorites. |
| Enable Anti-CSRF Token for Userperf | `glide.security.userpref_csrf_check.enable` | true | true | 4.3 Medium | User preferences set through URL parameters need a CSRF token. |
| Enforce valid query string choice | `glide.ui.query_string.enforce_valid_choice_on_create` | true per the text (table prints false) | false | 2.2 Low | A choice value passed in the URL when creating a record must be a valid active choice. The table says false, the text says set it to true. |

### IP allow lists and outbound trust

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Reduce the scope of the IP allow List for an instance | glide.ip.authenticate.strict (with glide.ip.authenticate.allow.secured, managed by ServiceNow) | true | false | 4.3 Medium | Strict mode: a narrower ServiceNow-managed list of company IP ranges may reach the instance; grant others case by case in `ip_access`. |
| Enable CRL-based certificate revocation checking for outbound HTTP requests | `com.glide.communications.httpclient.disable_crl_check` | false | false | 7.5 High | Keep CRL checking available for outbound TLS (only acts when `com.glide.communications.httpclient.verify_revoked_certificate` is true). |
| Enforce CRL certificate revocation checking for outbound HTTP requests | `com.glide.communications.httpclient.fail_on_non_pass_crl_status` | true | true | 2.3 Low | Fail the outbound call when a CRL check cannot determine revocation status. |
| Ensure An Instance is Allowed to Connect to Only Trusted IP Addresses | `glide.custom.ip.outbound.authenticate.allow` | empty or trusted ranges only | empty | 4.3 Medium | Extra IP ranges the instance may call out to. Empty or minimal. |
| Ensure only Trusted IP Addresses are Allowed to Connect to An Instance | `glide.custom.ip.authenticate.allow` | empty or trusted ranges only | empty | 4.3 Medium | Extra IP ranges allowed to connect in. Empty or minimal. |
| For Self-Hosted Instance, Ensure only Trusted IP Addresses are Allowed to Connect to An Instance | glide.ip.authenticate.allow.self_hosted_enabled and three related properties | self-hosted: true with your ranges; hosted: defaults | false; 127.0.0.1 | 4.3 Medium | Self-hosted instances only: replace the default ServiceNow-oriented allow lists with your own. Do not set on ServiceNow-hosted instances. |

### ACLs on queries and reports

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Disable unauthenticated published reports | `glide.report.published_reports.enabled` | false | false | 6.5 Medium | No reports published without authentication (users can no longer publish). |
| Enforce domain access control on all tables | `glide.sys.domain.access_handler.included_tables` | * | * | 5.6 Medium | Domain separation: cross-domain write protection on all tables (`*`). |
| Enforce field ACLs for inbound query requests | `glide.export.query.enforce_field_acl` | true | true | 4.4 Medium | Inbound export queries are rejected when they filter on fields the user may not read. |
| Enforce read ACLs on report views | `glide.report.report_view.read_acl` | enforce | enforce | 7.1 High | Table read ACL applies to reports where no `report_view` ACL exists. |
| Enforce Query ACLs for Knowledge Quick Links | `com.glide.security.query_acl.enabled.knowledge_quick_links` | true | true | 5.3 Medium | Query ACLs on Knowledge quick links (third value `external_and_guests`). |
| Enforce Query ACLs for SubLists, List Counts and Widget Data Tables | `com.glide.security.query_acl.enabled.sub_lists`; `com.glide.security.query_acl.enabled.list_count`; `glide.security.query_acl.enabled.data_table` | true (all three) | true | 5.3 Medium | Query ACLs on related and grouped lists, list counts and widget data tables. |
| Prevent disabling of data separation enforcement | `glide.one_extend.mosaic.sync.disable_data_separation_enforcement` | false | false | 5.4 Medium | Keep per-domain visibility filtering for Mosaic sync consumers. |
| Deny by default with empty ACLs | `glide.sm.default_mode` | deny | deny | 6.3 Medium | No matching ACL means deny. |

### Authentication required per inbound processor

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Require authorization for data broker rest API | `glide.basicauth.required.databrokerrestapiprocessor` | true | true | 8.6 High | Data broker REST API needs authentication. Safe-harbor. |

### Other API controls

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Restricted Binding functionality in Case Bearer authorization | `glide.oauth.enforce_restricted_binding_for_ui` | true | true | 5.0 Medium | With *restricted binding* on an OAuth entity, its tokens cannot be used for UI pages. |
| Set automatic token cleanup for token credentials | com.snc.platform.security.token.auth.cleanup and two retention properties | true; 7 or less; 7 or less | true; 7; 7 | 5.1 Medium | Delete expired API keys and HMAC secrets within 7 days. |

## Communications (7)

TLS and certificate checks on outbound connections.

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Enforce certificate trust | `com.glide.communications.trustmanager_trust_all` | false | false | 5.7 Medium | false = outbound HTTPS trusts only certificates verifiable against the Java trust store (applies when host name verification is off). Do not change. |
| Disable outbound SSLv2/SSLv3 connections | `glide.outbound.sslv3.disabled` | true | true | 6.5 Medium | Outbound connections (also through MID Servers) never use SSLv2 or SSLv3. |
| Do not use demo certificates for active SAML configurations | `glide.authenticate.sso.saml2.keystore` | sys_id of your own keystore | not set | 3.9 Low | SAML signing or encryption must use your own keystore, not the shipped demo keystores (their passphrase is public). |
| Disable deprecated TLS versions | `com.glide.communications.disable.deprecated.tls` | true | true | 4.4 Medium | Only TLS 1.2 and later when talking to other servers; old servers will fail. |
| Enforce OCSP check on network error | `com.glide.communications.httpclient.ocsp_allow_network_error` | false | true | 5.9 Medium | false = if the OCSP responder cannot be reached the outbound call fails, instead of treating the certificate as good. Watch responder availability. |
| Verify certificate chain and hostname | `com.glide.communications.httpclient.verify_hostname` | true | true | 7.4 High | Outbound HTTPS validates certificate chain and host name; mismatched certificates stop integrations. |
| Verify certificate revocation | `com.glide.communications.httpclient.verify_revoked_certificate` | true | true | 6.5 Medium | Master switch for revocation checking (OCSP or CRL) on outbound TLS. |

## Configuration (15)

HTTP headers, debug switches and other instance-level configuration.

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Allow CORS origins for OAuth endpoints | `glide.oauth.cors.allowed.origin` | empty, or the one host you need | empty | 3.5 Low | Origin allowed to call the OAuth endpoints from a browser (empty, one host, or `*`). Used by browser-only MCP clients. |
| Auto set content type options | `glide.security.header.auto_set_x_content_type_options` | true | false | 7.3 High | `X-Content-Type-Options` header. Removed from the baseline in 1.3.3; cannot be overridden in the database. |
| Cache-Control HTTP Header Value | `glide.http.cache_control` | private | private | 4.3 Medium | `Cache-Control` for static content: `private` keeps it out of proxies and CDNs. Removed in 1.5. |
| Enable HTTP response headers configuration | `glide.http.headers_config.enabled` | true | true | 5.5 Medium | Use the HTTP Response Headers table (`sys_response_header`), which carries the Content Security Policy. |
| Disable legacy JQuery UI usage | `glide.jquery_ui.legacy` | false | false | 3.9 Low | Use the patched jQuery UI. |
| Disable locked form elements debugging | `glide.security.explain.write.locks` | false | false | 3.3 Low | No debug explanation on locked form fields. |
| Disable Multi-SSO debugging | `glide.authenticate.multisso.debug` | false | false | 4.0 Medium | Multi-Provider SSO debug logging off outside troubleshooting. |
| Disallow target cloning | `glide.db.clone.allow_clone_target` | false | false on production; true elsewhere | 4.4 Medium | Production cannot be chosen as a clone target (default false on production, true on sub-production). |
| Disable soap fault stack trace display | `glide.soapfault.display_stack_trace` | false | false | 4.3 Medium | No stack trace in SOAP faults. |
| Restrict performance monitoring access | `glide.security.diag_txns_acl` | true | true | 5.3 Medium | Diagnostic pages (`stats.do`, `threads.do`, `replication.do`) need authentication. |
| Enforce secure referrer policy | `com.glide.security.referrerpolicy` | default | default | 4.3 Medium | Referrer-Policy header: `default`, `same-origin`, `origin-when-cross-origin` or `strict-origin-when-cross-origin`. Stricter values can break embedded content. |
| Ensure minimum private key size | `sn_disco_certmgmt.private_key_size` | 2048 or more | 2048 | 3.1 Low | Key size for certificate requests from Certificate Inventory Management. |
| Implement the x-frame-options: SAMEORIGIN security header | `glide.set_x_frame_options` | true | true | 5.9 Medium | `X-Frame-Options: SAMEORIGIN`: the instance cannot be framed by other sites (breaks intentional embedding). |
| Require write access to access service catalog add item page | `glide.sc.request.add_item_write_access` | true | true | 4.3 Medium | The catalog *add item* page requires write access to the record. |
| Set Xframe options to prevent embedding third-party websites | `com.glide.cs.embed.xframe_options` | DENY or SAMEORIGIN | sameorigin | 3.1 Low | Framing rule for the embeddable conversational client. |

## Related

- [[Hardening Settings - Overview and Baseline Versions]] · [[Security Center]] · [[Raise the Hardening Compliance Score]] · [[Hardening Settings - Access Control]] · [[Hardening Settings - Authentication and Session Management]] · [[Hardening Settings - Validation, Files, Logging and Other]]
