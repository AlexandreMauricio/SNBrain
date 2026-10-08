---
type: reference
tags: [reference, security, instance-admin, admin, access-control, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Platform Security > Hardening settings, the access control category (101 settings). All 101 setting pages were parsed by script for the property or plugin name, recommended and default values and CVSS score; the description, security risk, functional impact and dependency text of every page was then read 2026-10-08 in a condensed form (repeated boilerplate and the generated summary blocks removed, very long introductions cut at 900 characters, risk and impact text at 600). The Remark column is our own summary. https://www.servicenow.com/docs/r/platform-security/instance-security-hardening-settings/sc-access-control.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Hardening Settings - Access Control

**What this is:** the Security Center hardening settings of the access control category (101 settings): the property, plugin or record each one checks, the value Security Center expects, the base-system default, the CVSS score ServiceNow assigns to non-compliance, and what the setting does.
**Where:** Security Center > Security configuration console > Security hardening > All settings; properties themselves under `sys_properties.list`
**Role required:** `admin` (many properties need elevation to `security_admin` to change)

How the score works, baseline versions and reading rules: [[Hardening Settings - Overview and Baseline Versions]]. Working the list: [[Raise the Hardening Compliance Score]]. Other categories: [[Hardening Settings - Authentication and Session Management]] · [[Hardening Settings - API, Architecture, Communications and Configuration]] · [[Hardening Settings - Validation, Files, Logging and Other]].

Reading the tables: *Default* is the value shipped on a new instance; many properties are absent from `sys_properties` and then use a fallback, which is sometimes the insecure value. *Safe-harbor* means the property cannot be set back once changed. `?` or *not stated* means the page did not give the value.

## Access control (101)

Who may reach what: ACL evaluation, scopes, roles, public access.

### CSRF and cross-origin requests

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Anti-CSRF token validation time | `glide.security.csrf_previous.time_limit` | 86400 | 86400 | 5.3 Medium | Seconds an expired CSRF token may still be reused (only relevant if reuse is allowed). |
| Block Expired Anti-CSRF Tokens | `glide.security.csrf_previous.allow` | false | false | 6.5 Medium | Never accept an expired CSRF token. |
| CSRF enforcement for session-authenticated REST APIs | `glide.security.csrf.rest.public_csrf.enabled` | true | true | 4.3 Medium | Public REST APIs called with a session cookie must send a CSRF token; exempt paths go in `sys_rest_csrf_allow_list`. May break scripts relying on cookies without a token. |
| Enable anti-CSRF token | `glide.security.use_csrf_token` | true | true | 8.1 High | Master switch: embed and validate a CSRF token. Requests without a valid token go to a warning page. |
| Enable CSRF enforcement for authenticated processors | `glide.security.csrf.processor.all.authenticated.enabled`; `glide.security.csrf.httpauth_processor_allowlist` | true; empty | false; empty | not stated | CSRF check on POST, PUT, DELETE to authenticated processors using a session cookie (HTTP 401 without a valid `X-UserToken`); second property is an exemption list. Off by default: test integrations. |
| Prevent Users From Accepting Warning To Bypass CSRF Validation | `glide.security.csrf.strict.validation.mode` | true | true | 3.7 Medium | No "Continue" button on the CSRF warning page when the token belongs to another of the user's sessions. (Older page for the same property as the entry below.) |
| Restrict allowed domains for cross-origin iframe communication | `glide.ui.concourse.onmessage_enforce_same_origin` | true | true | 4.2 Medium | Validate the origin of `window.postMessage` messages between frames. |
| Enforce oauth state parameter validation | `glide.oauth.state.parameter.required` | true | true | 4.2 Medium | OAuth authorization code requests must carry `state`. |
| Restrict JSONP requests to trusted URLs | `angular.jsonp.inclusion_list.enabled` | true | true | 5.4 Medium | AngularJS JSONP requests only to URLs in `angular.jsonp.inclusion_list.urls`. |
| Prevent users from accepting warning to bypass CSRF validation | `glide.security.csrf.strict.validation.mode` | true | true | 3.7 Low | Same property as above, current page. |
| Specify URL allow list for cross-origin iframe communication | `glide.ui.concourse.onmessage_enforce_same_origin_whitelist` | trusted origins or empty | empty | 4.2 Medium | Origins allowed for cross-frame messages; empty blocks all. |

### How ACLs are evaluated

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Apply domain separation on dot walked fields | `glide.sys.domain.include_domain_condition_on_join` | true (only where domain separation is installed) | false | 6.5 Medium | Adds domain conditions to joins so dot-walked fields respect domain separation. Safe-harbor: cannot be reverted. Test first. |
| Check UI action conditions before execution | `glide.security.strict.actions` | true | true | 3.3 Low | Re-checks UI action conditions on the server before running the action. |
| Deny unauthorized access to request items | `glide.sc.req_for.roles.default` | deny | deny | 4.2 Medium | With no roles in `glide.sc.req_for.roles`, deny use of the address lookup for other users (`ScriptServiceCatalogGetLocation`). |
| Display recommendations for high risk UI pages | `glide.script.ui_page.customer_scoped.security_msgs_enabled` | true | true | 5.3 Medium | Shows warnings to people editing UI pages: missing ACL, `GlideRecord` instead of `GlideRecordSecure`, page made public. |
| Double check inbound transactions | `glide.security.strict.updates` | true | true | 8.1 High | Second security check when a form is submitted: users cannot update fields they merely see. Safe-harbor: cannot be reverted. |
| Enable work order management query rules for service organizations | `sn_fsm.use_query_rules` | false (table) / true (text) | false | 4.3 Medium | Field Service: filter work orders and tasks by `sn_query_rule` territory rules. The page recommends false in the table and true in the text. |
| Enable ACLs to Control Live Profile Details | `glide.live_profile.details` | ACL | ACL | 4.3 Medium | Live profile detail fields shown according to ACLs (alternatives: `hide`, `show`). |
| Enable ACLs for Encoded Query in Simple List Widget | `glide.service_portal.enable_acls_for_encoded_query_in_list` | true | true | 4.3 Medium | Simple List widget evaluates ACLs on fields used in its encoded query. The page names another property in its table; the text names this one. |
| Enable report view ACLs | `glide.report.report_view.check_published` | true | true | 7.5 High | Checks `report_view` ACLs for published reports. |
| Enforce field-level ACLs on records created from the filtered list view UI query string | `com.glide.acl_check_all_filter_on_new` | true | false | 4.8 Medium | Creating a record from a filtered list copies filter values into fields; this makes field ACLs apply to them. Per-field attributes `ignore_filter_on_new`, `acl_check_filter_on_new`, `allow_filter_on_new` refine it. |
| Enforce Read Roles for Catalog Variable Search | `glide.ais.ingestion.ignore_catalog_variables_read_roles` | false | false | 2.6 Low | AI Search indexes only catalog variables without read roles. |
| Enforce security rules to sharing dashboards | `glide.cms.dashboards.sharing_with_secure_search` | true | false | 3.5 Low | When sharing a dashboard, the user, group and role pickers respect ACLs. |
| Enforce strict deny for ACLs referencing only deleted or non-existent roles | `glide.security.acl_with_invalid_roles_strict_deny` | true | true | 5.1 Medium | An ACL whose only roles were deleted denies access (and logs an error) instead of falling back to "any authenticated user". |
| Enforce field level ACLs in GlideRecordSandbox | `glide.sandbox.fields.check_acl` | true | true | 7.5 High | Field ACLs apply inside sandboxed scripts (for example in `sysparm_query`). Cannot be overridden in the database. |
| Enforce GroupBy ACLs | `glide.security.groupby_acl_check` | true | true | 3.7 Low | ACLs checked on group-by columns; a table attribute `groupby_acl_check` takes precedence. |
| Ensure archive table ACLs are checked | `glide.security.enable_archive_table_acls` | true | true | 3.0 Low | Read ACLs written for archive tables are honoured in addition to the source table's. |
| Ensure dashboards creation/deletion requires access check | `glide.processors.check_access_before_process` | true | true | 6.3 Medium | Access check before a processor creates or deletes dashboards. |
| Exclude Sensitive Tables and Fields from Data Generation | `glide.data.generation.excluded.tables`; `glide.data.generation.excluded.fields.<table>` | your sensitive tables and fields | empty | 2.6 Low | Tables and fields the Data Generation feature must not copy from. |
| Require AJAXGlideRecord ACL checking | `glide.script.secure.ajaxgliderecord` | true | true | 8.1 High | Client-side GlideRecord (AJAXGlideRecord) queries are checked against ACLs (KB0550828 for auditing impact). |
| Restrict write access on system fields to admin users | `glide.rest.table_api.admin_only_sys_fields` | true | false | 2.7 Low | Table API: only admins may set `sys_id`, `sys_created_*`, `sys_updated_*` (integrations that pass `sysparm_suppress_auto_sys_field` are affected). |
| Honor admin override ACLs | `glide.security.admin.override.accessterm` | true | true | 3.8 Low | Each ACL's own *admin overrides* setting is honoured when several ACLs apply. |
| Restrict access to emails with empty target table | `glide.email.email_with_no_target_visible_to_all` | false | false | 6.5 Medium | Emails with no target record visible only to the sender and admins. |
| Restrict permissions for CMDB model | `csm_cmdb_model.customer_visible_flag` | true | false | 6.5 Medium | External customer users need the visible flag to see CMDB models. |
| Restrict access to custom journal entries | `glide.live_feed.custom_journal.acl_check_enabled` | true | true | Medium | Live Feed shows custom journal entries according to ACLs. Removed in 2.0. |
| Restrict flow context read access | `com.snc.process_flow.reporting.require_flow_access` | true | true | 2.7 Low | Reading a flow context requires read access to the flow. |
| Validate query ACLs on Glide DB functions | `glide.db.encoded_query.check_function_field_query_acls`; `glide.db.encoded_query.force_query_range_on_functions` | true; the five default functions | the same | 5.3 Medium | Query ACLs (`query_range`, `query_match`) apply to database functions such as substring and concat, closing blind inference. |

### Roles, administrators and impersonation

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Block access for delegated developers | `com.glide.sys.security.delegateddev.block_grant_roles` | true | true | 6.7 Medium | Delegated developers cannot insert or update user role rows by script unless they also hold `user_admin`. |
| Configure event management assignment group admin roles | `evt_mgmt.connector_assignment_group_admin_roles` | admin,evt_mgmt_admin,sn_sow_srm.srm_admin | admin,evt_mgmt_admin,sn_sow_srm.srm_admin | 3.1 Low | Roles allowed to administer the assignment group field on Event Management connector instances. |
| Deny internal access to explicit external roles | `glide.security.explicit_roles.enable_internal_user_blacklist` | true | true | 5.4 Medium | Enforces the list of user classes that always get `snc_external` (Explicit Roles plugin). |
| Enable policy based session access for mobile | `glide.authenticate.session_access.mobile.enabled` | true | true | 4.7 Medium | Session access policies (reduced roles) also apply to mobile logins. |
| Enforce strict elevate privilege | `glide.security.strict_elevate_privilege` | true | true | 6.7 Medium | Privileged roles must be elevated by hand in each session. |
| Restrict delegated developers read access | `com.glide.dd_allow_global_access_tables` | the seven workflow and portal tables (default list) | the same list | 2.7 Low | Global tables a delegated developer may read. |
| Prevent impersonating user from viewing application data | `<scope>.impersonateCheck` | true | true | 3.8 Low | Pattern `<scope>.impersonateCheck`: an admin impersonating a user does not see that user's data in the application (HR Core and about ten other scopes). |
| Prevent inactive users from logging in | `glide.authenticate.only.allow.active.user.login` | true | true | 7.5 High | Inactive users cannot log in. |
| Restrict access to background script | `glide.script_processor.admin` | background_script_admin | background_script_admin | 8.8 High | Role needed for Scripts - Background. |
| Restrict platform analytics export to authorized roles | `glide.par.export.allowed_roles` | the roles you authorise | empty | not stated | Roles allowed to export Platform Analytics dashboards (only with `glide.par.export.enabled`). Empty = anyone who can view. |
| Restrict Impersonation to Admin | `glide.sys.permissive.impersonate` | false | false | 6.7 Medium | Only admins (and holders of the impersonation role) can impersonate. |
| Restrict script authorship to authorized users only | `glide.security.scripting_governance.enabled` | true | true | 4.3 Low | Scripting governance: only users with the script-writer role can author or import script content. |
| Restrict Global App Development by Role | `sn_g_app_creator.allow_global` | false | absent (= false) | 3.3 Low | Guided App Creator: global-scope apps only with role `sn_g_app_creator.global`. |
| Review extraneous explicit role access control conditions | (review of ACLs) | n/a | n/a | not stated | Review task, not a property: ACLs where `snc_internal` or `snc_external` was added beside a stricter role. Removed in 1.5. |

### Public and unauthenticated access

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Configure service portal widgets allow list | `glide.service_portal.widget.allow_list` | empty | empty | 3.7 Low | Widgets allowed to try any table for public users (only with `glide.service_portal.widget.enforce_public_check` = true and widgets using `SNCACLWidgetUtil`). Keep empty. |
| Configure service portal widgets table allow list | `glide.service_portal.widget.table_allow_list` | empty | empty | 3.7 Low | Tables that public Service Portal widgets may read under the same check. Empty or as short as possible. |
| Disable inbound emails for locked out users | `glide.pop3.process_locked_out` | false | false | 7.5 High | Inbound email from locked-out users is not processed. |
| Enforce strict user image upload | `glide.security.strict.user_image_upload` | true | true | 3.7 Low | Stricter checks on user image uploads (?). The page's text describes outbound TLS host name verification instead: unreliable page. |
| Restrict email domains for external user registration | `sn_ext_usr_reg.allowed_email_domains` | a list of your allowed domains | empty | 7.5 High | Email domains allowed to self-register. Empty means any domain. |
| Prevent unauthenticated roleless ACL in scripted ACLs | `glide.security.allow_unauth_roleless_acl` | false | false | 7.5 High | Scripted ACLs without roles do not admit unauthenticated users. |
| Prevent Unauthenticated Access to Virtual Agent Embedded Web Client | UI page `sn_va_web_client_app_embed` in `sys_public` | public page record absent or inactive | n/a | 7.5 High | The Virtual Agent embedded web client page should not be public unless guests need it (deactivate its Public Pages record). |
| Require authentication by default for client-callable script includes | `glide.script.ccsi.ispublic` | false | false | 7.5 High | Client-callable script includes are not public unless they say so. |
| Restrict knowledge bases access | `glide.knowman.block_access_with_no_user_criteria` | true | true | 9.1 Critical | Knowledge bases without *can read* or *can contribute* criteria are closed instead of open to all. |
| Restrict unauthenticated access to attachments | `glide.image_provider.security_enabled` | true | true | 6.5 Medium | Image attachments need a login; exceptions through the security allow/deny list and public knowledge articles. |
| Disable public access to favorites | `glide.ui.magellan.favorites.allow_public` | false | not stated | Medium | Unauthenticated users do not see navigator favorites. |
| Use Document Classification to limit publicly accessible documents | `com.snc.documents.permalink.allowed_classifications` | public | public | 5.3 Medium | Document classifications whose permalinks are public. Not part of the scored baseline. |

### MID Server and integrations

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Configure unique MID Server users | `sys_user` / `ecc_agent` records | a unique user per MID Server | n/a | 3.8 Low | One user record per MID Server (role `mid_server`), so actions can be attributed. No property: a data check on `ecc_agent` **Logged in user**. |
| Enforce credential alias usage | `alias_filtering_behavior` | strict | loose | 2 Low | MID Server property: Discovery uses only credentials matching the schedule aliases. Deprecated. |
| Ensure MID Server Users Have Appropriate Access Levels | `sys_user_has_role` records | `mid_server` plus needed custom roles | `mid_server` | 5.7 Medium | MID Server users hold `mid_server` and only what integrations need, never admin-type roles. A data check on `sys_user_has_role`. |
| Restrict MID Server users from authenticating using UI | `sys_user` field `web_service_access_only` | true | true | 3.8 Low | MID Server users have **Web service access only** ticked. |
| Use of secure insert multiple operation within import set API | `com.glide.import_set_api.insert_multiple_optimize` | false | false | 6.5 Medium | false = Import Set API insertMultiple uses GlideRecordSecure, so table ACLs apply. If true, the caller needs `import_transformer`. |
| Enforce SOAP request strict security | `glide.soap.strict_security` | true | true | 6.8 Medium | SOAP callers need a SOAP role for non-public pages. |
| Required JMS connection factories | `mid.property.jms.command.allowed_factory_names` | the three default factories | the same | 4.1 Medium | JMS connection factories a MID Server may use: keep to the three defaults. |
| Set guest user for soap requests | `com.glide.soap.guest_user` | soap.guest | soap.guest | 8.1 High | User under which unauthenticated SOAP requests run. |

### AI agents and newer features

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Disable adding default roles to skill ACLs | `com.glide.one_extend.include_default_roles_for_skill_acl` | false | false | 4.2 Medium | Do not auto-add the default roles to generative AI skill ACLs. |
| Disable Voice Chat Guest Impersonation | `com.glide.cs.voice.chat.disable.guest.impersonate` | true | true | 1.9 Low | Voice interactions are recorded under the integration user, not the guest user. |
| Enable Guardian for External Agents | `sn_aia.external_agent_guardian_check` | true | true | 4.1 Medium | Guardian screens prompts and responses of external AI agents (harmful content, prompt injection, filtered subjects). Can block legitimate requests. |
| Enable Role Masking for Agents | `identity.agent.role_masking.enabled` | true | true | 5 Medium | AI agents run with a masked, reduced set of roles instead of all roles of the invoking user. |
| Enable IAM and boundary checks for Amazon Bedrock access | `sn_ai_security.bedrock_priviledge.permission_policy` | false | false | 4.8 Medium | false = check both the IAM policy and the Bedrock boundary before treating a role as privileged. |
| Enforce least privilege on scoped MCP OAuth tokens | `com.snc.platform.security.oauth.mcp.aig_scope_support` | true | false | 4.3 Medium | MCP OAuth: cache outbound tokens per scope combination, so a broad token is not reused for a narrow request. |
| Require Multi-Factor Authentication for AI Voice Agent | `glide.voice.authenticate.mfa_mandatory` | true | true | 3.3 Low | AI voice agent authentication requires more than one factor. |
| Require approval for agent-based Office 365 group membership changes | `sn_itsm_aia.office_365_group_member_approval.required` | true | true | 4.9 Medium | An approver group must approve Microsoft 365 group membership changes made by the AI agent. |

### Application scopes and cross-scope access

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Disable log-and-allow mode for cross-scope dot-walk access | `glide.script.dot_walk.log_and_allow_violations` | false | false | 6.4 Medium | If true, cross-scope dot-walk violations are only logged, and this overrides the enforcement property below. |
| Enable scoped admin application ACLs | `glide.security.scoped_administration.honor_global_acl` | true | not set | 3.8 Low | Scoped administration applications fall back to global ACLs when they define none. |
| Enable Cross Scope Privilege Checks on Service Portal Form | `glide.service_portal.enforce_cross_scope_check_in_form` | true | true | 3.1 Low | Service Portal form checks cross-scope privileges before reading a record (Yokohama and later). |
| Enforce ACL on HR lifecycle events data | `glide.enforce_security_scope.sn_hr_le` | true | false | 6.5 Medium | Only ACLs of scope `sn_hr_le` decide access to HR Lifecycle Events data in shared tables. Safe-harbor. |
| Enforce ACL on HR Core Data | `glide.enforce_security_scope.sn_hr_core` | true | true | 6.5 Medium | Same for HR Core (`sn_hr_core`): keeps IT administrators out of HR data in tables such as attachments and email. Safe-harbor. |
| Enforce ACL on HR Virtual Agent Data | `glide.enforce_security_scope.sn_hr_va` | true | false | 6.5 Medium | Same for HR Virtual Agent conversations (`sn_hr_va`). |
| Enforce application specific ACLs only for application data | `glide.enforce_security_scope.<scope>` | true | true | 4.1 Medium | Pattern `glide.enforce_security_scope.<scope>`: for application data kept in shared tables, evaluate only that application's ACLs. About 50 scopes (HR, legal, public sector, health ...). Changeable only by the scoped admin. |
| Enforce application scope restrictions | `glide.record.legacy_cross_scope_access_policy_in_script` | false | true when the property is absent | 3.5 Low | false = scoped apps cannot call global-only APIs through the legacy cross-scope policy. Removed from the baseline in 1.5. |
| Enforce cross-scope table access when performing dot-walk | `glide.script.dot_walk.enforce_cross_scope_access_all_tables` | true | true | 6.4 Medium | Authorization checks on every cross-scope dot-walk, unless a table opts out with attribute `enforce_dot_walk_cross_scope_access=false`. New behaviour since Zurich: may break apps reaching outside their scope. |
| Enforce scope security for public sector digital services | `glide.enforce_security_scope.sn_gsm` | true | true | 4.2 Medium | Scope enforcement for Public Sector Digital Services (`sn_gsm`). |
| Enforce scoped ACL access for information request playbooks | `glide.enforce_security_scope.sn_gsm_info_req` | true | true | 4.3 Medium | Scope enforcement for Information Request playbooks. |
| Enforce security scope license and permit playbook | `glide.enforce_security_scope.sn_gsm_lic_prmt` | true | true | 2.7 Low | Scope enforcement for License and Permit playbooks. |
| Enforce Security Scope for Agent Workspace for HR Case Management | `glide.enforce_security_scope.sn_hr_agent_ws` | true | true | 2.7 Low | Scope enforcement for Agent Workspace for HR Case Management. |
| Enforce Security Scope for Service Application Information | `glide.enforce_security_scope.sn_svc_appl_info` | true | false | 4.3 Medium | Scope enforcement for Service Application Information. |
| Enforce Scope Access Controls on New Tables | `glide.script.dot_walk.add_attribute_on_table_create` | true | true | 5.3 Medium | New tables get the dot-walk cross-scope attribute automatically. |

### Plugins and instance-level switches

| Setting | Property, plugin or record | Recommended | Default | CVSS | Remark |
|---|---|---|---|---|---|
| Enable contextual security plugin | `com.glide.role_management` | plugin active | see instance | 8.1 High | Contextual security: ACLs replace dictionary roles. |
| Enable High Security plugin | `com.glide.high_security` | plugin active | active on new instances | 9.8 Critical | High Security Settings: default-deny, `security_admin` elevation, hundreds of settings. |
| Disable raw database query execution | `glide.db.allow_unsafe_dbi_execute_sql` | false | false | 7.2 High | No raw SQL from scripts. Removed from the baseline in 2.0. |
| Enforce production instance behavior | `glide.installation.production` | true | true | 6.3 Medium | Marks the instance as production (blocks zboot and similar). |
| Restrict access to specific IP ranges plugin | `com.snc.ipauthenticator`; `ip_access` records | plugin active and at least one active rule | plugin active, no rules | 5.3 Medium | IP address access control active with at least one rule. Removed from the baseline in 9.0. |
| Enable security jump start plugin (ACL Rules) | `com.snc.system_security` | plugin active | active on new instances | 8.1 High | Security Jump Start: baseline ACLs on key system tables. |
| Enable SNC access control plugin | `com.snc.snc_access_control` | plugin active | not installed | 3.3 Low | ServiceNow support staff need your approval to log in. Must be requested; may affect support response. |

## Related

- [[Hardening Settings - Overview and Baseline Versions]] · [[Security Center]] · [[Raise the Hardening Compliance Score]] · [[Hardening Settings - Authentication and Session Management]] · [[Hardening Settings - API, Architecture, Communications and Configuration]] · [[Hardening Settings - Validation, Files, Logging and Other]]
