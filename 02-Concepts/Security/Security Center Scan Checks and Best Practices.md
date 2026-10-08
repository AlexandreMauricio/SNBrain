---
type: reference
tags: [reference, security, access-control, instance-admin, admin, scripting, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Platform Security > Security Center (chapter read in full 2026-10-08 through the docs site) - Access Controls Auditor checks, Auditor checks, Best Practices (the table of best practices in the Security posture console). Descriptions are shortened. https://www.servicenow.com/docs/r/platform-security/security-center/auditor.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Security Center Scan Checks and Best Practices

**What this is:** the security checks shipped in the Security Center scanner's Auditor suite, and the list of best practices in the Security posture console. Useful as a review checklist even without opening the tool.
**Where:** Security Center > Security configuration console > Security scanner > Suites > Auditor; Security Center > Security posture console > Best Practices
**Role required:** `admin` or `sn_vsc.security_center_admin`

The tool itself: [[Security Center]].

## Access Controls Auditor checks

| Check | Finds | Why it matters |
|---|---|---|
| Processors of type SCRIPT must be protected with CSRF token | script processors without the CSRF option | the processor could be invoked by a forged request |
| Can Contribute / Cannot Contribute user criteria on each knowledge base | knowledge bases with no contribute criteria | anyone can add content |
| Empty ACLs | ACLs with no role, no security attribute (no script or condition), or the `public` role | open access to whatever they cover ([[Access Control Lists (ACLs)]]) |
| Access controls on client-callable script includes | client-callable script includes with no ACL of their own | they fall under the default `*` ACL |
| Access controls on UI pages | UI pages with no ACL | every logged-in internal user can open them |
| Access controls on tables | tables without ACLs | |
| User account should not have both internal and external roles | users holding both kinds | external roles are for customers and partners ([[Explicit Roles and Elevated Privilege Roles]]) |
| Publicly accessible knowledge bases and articles | public knowledge content | |

## Other Auditor checks

| Check | Finds | Type |
|---|---|---|
| Identify out of date store apps | installed applications with newer versions | Resolution recommended |
| Insecure GlideRecord calls | user-invokable scripts (client-callable script includes, widgets, processors, REST endpoints) that query without honouring ACLs: use `GlideRecordSecure`, or `GlideRecord` with `canRead()` / `canWrite()` / `canCreate()` / `canDelete()` | Resolution recommended |
| Review allowed JavaScript libraries | allow rules for third-party libraries (check last use in `sys_js_content_provider_access_tracking`; instances created on Tokyo or later deny by default) | Resolution recommended |
| Review client-callable script includes with no corresponding ACL | | Resolution recommended |
| Review custom tables with record producers and no business rule | record producers writing to custom tables with no server-side validation | Resolution recommended |
| Review empty ACLs | | Resolution recommended |
| Review fields with HTML sanitization disabled | HTML fields with sanitizing off | Resolution recommended |
| Review UI pages without corresponding ACLs | | Resolution recommended |
| Rotate passwords stored with outdated hashing algorithms | accounts whose password was last set on an old release | Resolution recommended |
| Securing record producers | record producers without role restrictions | Resolution recommended |
| UI action visibility | UI actions reachable by a user with no roles and no read access to the table | Resolution recommended |
| Review large allowed IP address ranges | IP access control ranges covering very many addresses (tunable through the check's `largestExpectedCIDRBlock` variable) | Review and decide |
| Review public GraphQL schemas | `sys_graphql_schema` records usable without authentication | Review and decide |
| Review public REST API endpoints | scripted REST resources (`sys_ws_operation`) not requiring authentication | Review and decide |
| Review public Service Portal pages | portal pages with **Public** true | Review and decide |
| Review public UI pages | UI pages listed in public pages (`sys_public`) | Review and decide |
| Review public knowledge base articles | | Review and decide |
| Review roles that contain the admin role | roles in `sys_user_role` that include `admin` | Review and decide |
| Review users with valid local passwords | users who could authenticate locally (for example through APIs) even when interactive local login is off; expected for integration accounts | Review and decide |
| Review inactive security feature plugins | optional security plugins not installed | Inform |

## Best practices

| Goal | Best practices |
|---|---|
| Initial configuration | change the default credentials of built-in accounts (admin, itil, employee); appoint a security contact (KB0621516); make sure the High Security plugin is active; harden the instance with the hardening tool and monitor the compliance level (aim near 100%, minimum 83%); read the shared responsibility model and the security resources; point developers to the Secure Coding Guide |
| Access | activate ServiceNow Access Control (support staff need explicit, temporary approval: [[SNC Access Control (Support Staff Access to an Instance)]]); use SAML single sign-on and integrate MFA ([[Multi-Provider SSO - SAML and OIDC]], [[Multi-Factor Authentication]]); enforce strong passphrases by password policy ([[Local Authentication - Login, Password Policy and Password Reset]]); disable password-less authentication; remove the *Remember me* check box; restrict access by IP address ([[Login Controls - IP Access Control, Session Limits and Installation Exits]]); review the guidance on password spray attacks; secure access to knowledge bases; allow automatic user creation by email only if needed and only for trusted domains; validate access with Access Analyzer ([[Access Analyzer, Access Findings and Access Observer]]) |
| Transport and attachments | browsers on TLS 1.2 or higher; limit attachment uploads and downloads by role, extension, MIME type and size; disable SQL error messages in the browser; certificate-based (mutual) authentication with integration providers ([[Certificates in Authentication - Certificate Login, Mutual TLS and Outbound Certificate Policies]]) |
| Email | let your mail systems accept instance mail through SPF (KB0535456); limit accepted sender domains with address filters; use email filters on the antivirus and spam headers; consider your own mail infrastructure ([[Email Architecture and Accounts]]) |
| Logs and monitoring | audit tables holding important data; monitor event, system, transaction, import and outbound web service logs; monitor failed login rates with threshold alerts; monitor security events (privilege changes, new admins); export logs for retention beyond the default rotation (web services, export, MID Server, Log Export Service); send logs to a SIEM with the syslog probe |
| Encryption | encrypt data at rest (database, cloud or full-disk encryption according to the risk); use encryption modules with role-based access through the Key Management Framework |
| Staying current | install patches and hot fixes promptly |

## Related

- [[Security Center]] · [[Raise the Hardening Compliance Score]] · [[Access Control Lists (ACLs)]] · [[ACL Not Working as Expected]]
