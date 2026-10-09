---
type: concept
tags: [concept, security, users, roles, access-control, data-integrity, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Identity (chapter read in full 2026-10-08) - Identity and Access Audit, Exploring Identity and Access Audit, Identity Audit Results, User Trails, Group Trails, Role Trails, ACL Trails, Security Auditable Fields, Configuring Tables and Fields, Configuring Retention Period, Supported and unsupported fields. https://www.servicenow.com/docs/r/platform-security/identity/explore-identity-audit.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Identity and Access Audit

**In one line:** a built-in trail, on by default, of who changed users, groups, roles, their memberships and ACLs, kept for at most 30 days and presented per user, group, role or ACL.

From the Brazil docs. Separate from the general field auditing in [[Auditing and Record History]]: this one is specific to the access model and is on by default. The objects it watches: [[Users, Groups and Roles Overview]], [[Role Management]], [[Access Control Lists (ACLs)]].

- Plugin *Identity Security Audit* (`com.glide.security.audit`), installed automatically. Switch: `glide.identity.security.audit.enabled` (true by default).
- Menu: **All > System Security > Identity and Access Audit**.

## What is watched

| Table | |
|---|---|
| User (`sys_user`) | attributes |
| Group (`sys_user_group`) | attributes |
| Role (`sys_user_role`) | attributes |
| Access Control (`sys_security_acl`) | attributes |
| User Role (`sys_user_has_role`) | role membership |
| Group Member (`sys_user_grmember`) | group membership |
| Group Role (`sys_group_has_role`) | roles of groups |
| Contained Role (`sys_user_role_contains`) | role hierarchy |
| Access Roles (`sys_security_acl_role`) | roles required by ACLs |

## Modules

| Module | Shows |
|---|---|
| **Audit Results** (*Security Table Audits*) | every audited change: **Source Table**, **Action**, **Sys_id**, **Created by** (who did it), **Changed for user**, **Transaction ID** (groups the actions of one transaction), **Created**. Open a row for the changed values |
| **User Trails** | per user: attribute, role membership and group membership changes |
| **Group Trails** | per group: attribute, membership and role changes |
| **Role Trails** | per role: attribute and parent-child changes |
| **ACL Trails** | per ACL: attribute and required-role changes |
| **Configure Tables & Fields** (*Security Auditable Fields*) | per table: **Field List**, which of **Create**, **Update**, **Delete** are audited, **Audit Storage Destination**, **Active**. Role `security_admin` (elevated). Table `sys_sec_field_audit_config` |
| **Configure Retention Period** | **Age in seconds**; maximum 30 days (2,592,000). Role `admin` |

Reading the trails: role `identity_access_audit_viewer`, which contains `role_viewer` and `group_viewer` (per the granular roles table).

## Limits

- **30 days at most.**
- Auditing more fields or more operations slows bulk imports of users.
- Fields that cannot be audited:

| Table | Not auditable |
|---|---|
| all | `sys_created_on`, `sys_created_by`, `sys_updated_on`, `sys_updated_by` |
| `sys_user` | `last_login`, `last_login_time`, `last_login_device`, `enable_multifactor_authn`, `default_perspective`, `calendar_integration`, `federated_id`, `password_needs_reset`, `failed_attempts`, `last_password`, `ldap_server`, `locked_out`, `notification`, `roles`, `sys_domain`, `sys_domain_path`, `time_format`, `hashed_user_id`, `sys_class_name`, `sys_mod_count` |

On `sys_user_has_role` the auditable fields are user, role, inherited and count.

## Related

- [[Auditing and Record History]] · [[Access Analyzer, Access Findings and Access Observer]] · [[Security Center]] · [[Role Management]] · [[Identity Center]] · [[Granular Admin Roles]]
