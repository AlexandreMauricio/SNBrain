---
type: concept
tags: [concept, access-control, security, roles, platform, scripting, schema, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Access Control Lists (ACLs) (whole section, 30 topics, 1,657 cleaned lines, read in full 2026-10-08 through the docs site) - Explore Access Control Lists, ACL types, Datatype ACL, ACL control of function fields, Security jump-start ACL rules plugin, Configure an ACL, Deny-Unless ACL, Allow ACL, Query ACLs, Secure records in an embedded list, Related record access, Contextual Security Manager, Role Management V2 (prevent duplicates, upgrade, patcher job, role auditing), Double-check form submission, Default deny property, Advanced ACL configuration, Provide external users access to a table, Apply ACL script conditions to reference fields, Apply ACLs to AJAXGlideRecord, Evaluate the admin override at the access level, ACL debugging tools, troubleshooting reference, configuration watcher, execution plan. https://www.servicenow.com/docs/r/platform-security/access-control/access-control-rules.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Access Control Lists (ACLs)

**In one line:** an ACL (Access Control, `sys_security_acl`) says who may perform **one operation** on **one object** (a table, a field, a UI page, a script include, a REST endpoint); the user must satisfy every requirement of a matching ACL (role, security attribute, data condition, script), and a record needs both its table ACL and its field ACL.

From the Brazil docs. Creating one: [[Create an ACL]]. When it does not behave: [[ACL Not Working as Expected]]. Roles themselves: [[Users, Groups and Roles Overview]], [[Role Management]].

- **System Security > Access Control (ACL)**. Any admin can read and debug ACLs; creating or changing one needs elevation to `security_admin`.
- ACLs replaced roles on dictionary entries (the old Simple Security Manager): under the **Contextual Security Manager**, active in the base system, roles written on a dictionary entry do nothing. Role arrays still control application menus, modules, catalog items and catalog variables ([[Application Menus and Modules]]).

## Parts of an ACL

| Part | Meaning |
|---|---|
| **Type** | kind of object: `record`, `ui_page`, `processor`, client-callable script include, `REST_Endpoint` ... Read-only after creation |
| **Operation** | exactly one per ACL |
| **Decision type** | **Allow If** (grants when the requirements are met) or **Deny Unless** (blocks unless they are met) |
| **Name** | `incident` (table, field *None*), `incident.active` (field), `incident.*` (every field), `*.number` (that field on any table), `*` and `*.*` (wildcards). No partial wildcard: `inc*` is invalid |
| **Applies To** | a filter choosing **which records the ACL applies to** (for example only priority 1 incidents). Empty = all records. Case-sensitive. Not available on names starting with `*` |
| **Requires role** | any one of the listed roles. Empty list = passes. admin always passes role checks |
| **Security Attribute Condition** | properties of the user or session (authenticated, group membership, network location ...), since Vancouver. *Local* (this ACL only, the default) or *existing* (shared) |
| **Data Condition** | condition on the record's values. Case-sensitive |
| **Script** (tick **Advanced**) | server-side; must evaluate to true or set `answer = true`. Can use `current`, `previous` and properties. Runs even when the field is not on the form. In a related list `current` is the **parent** record of the list, not the row |
| **Admin overrides** | ticked: admins pass regardless of role, condition and script. Cleared: admins must pass condition and script (they still pass the role check). The `nobody` role beats it |
| **Controlled by References** | related record access: apply the parent table's ACL to records reached through a reference or relationship |
| **Active**, **Protection Policy**, **Description** | |

*Applies To* decides whether the ACL is in play for a record; *Data Condition* is evaluated once it is.

## Operations on records

| Operation | Failing it means |
|---|---|
| `read` | the row or field is not shown; not returned by web services |
| `write` | field read-only in forms and lists; API updates rejected |
| `create` | no **New**; API inserts rejected. A condition on a field value can fail because **fields of a new record are empty until saved** |
| `delete` | no **Delete**; API deletes rejected (also dropping a table) |
| `execute` | cannot run the script include, UI page script or REST endpoint |
| `list_edit` | cannot edit cells in a list |
| `add_to_list` | cannot see or add the column in list personalisation (no conditions or scripts) |
| `report_on`, `report_view` | cannot create a report on the table; cannot see report content for the table or field |
| `personalize_choices` | no *Configure Choices* on a field |
| `save_as_template` | which fields are saved into a template |
| `edit_task_relations`, `edit_ci_relations` | cannot define relationships (the ACL types page instead says: extend `task` / `cmdb_ci`) |
| `query_match`, `query_range` | query ACLs, below |
| `conditional_table_query_range` | partial query access derived from read ACLs that have no data condition or script (?) |
| `data_fabric` | lets a data fabric table reference a local table |

UI pages support only `read`; processors, script includes and REST endpoints `execute`.

## How access is decided

1. The system looks for ACLs matching the object and operation. **No matching ACL at all = access granted**; rare for records, because base wildcard ACLs cover every table.
2. **Deny Unless** ACLs are evaluated first. If several match, **all** must pass. Failing one denies access outright.
3. Then **Allow If** ACLs: within one ACL every requirement must be met; among several ACLs **at the same point of the processing order, passing any one is enough**. If the user fails those, the next point in the order is tried.
4. Records: the user must pass a **table** ACL and then a **field** ACL.

A passed Deny Unless does not itself grant: an Allow If must still permit (but the page also says that if no Allow If matches, access is granted by default).

### Processing order

Table ACLs: `incident` > parent `task` > `*`. Failing all of them hides every field.

Field ACLs, after the table passed; **the first one passed stops the search**:

1. `incident.number`
2. `task.number` (parent table, same field)
3. `*.number`
4. `incident.*`
5. `task.*`
6. `*.*`

Base system wildcards: table `*` for create, read, write, delete; field `*.*` for personalize_choices, create and save_as_template (the `*.*` create rule reuses the write conditions unless an explicit create ACL exists). **A new custom table without its own ACLs falls to the `*` table rules, which with default deny admit only admins.**

Other object types: UI pages, processors and client-callable script includes use the first ACL matching the name, else the `*` ACL of that type (none exist for script includes or processors by default, apart from `EmailClientProcessor` restricted to `itil`). REST resources use **hierarchical scope ACLs**: for `a/b/c/d` the system tries `a/b/c/d`, `a/b/c`, `a/b`, `a`, then `*`, stopping at the first level that has an ACL; execute only; roles and security attributes only.

### Deny by default

An ACL denies everyone when it is **empty** (no role, security attribute, data condition or script) or **invalid**: none of its roles exist on the instance, its security attribute does not exist, or its script is just `answer = true` / `true`. A mix of existing and missing roles still works. The form prompts for a role or attribute when you try to save an empty one. Invalid role references are listed in the Access Management Console / Access Findings.

`glide.sm.default_mode` (**Security manager default behavior**): *Deny Access* makes the wildcard table ACLs refuse read, write, create and delete to everyone but admins unless another table ACL lets the user in; *Allow Access* lets them through. **Once set to Deny it cannot be set back.** Only the wildcard table rules consult it.

### Before and after the query

- **Pre-query**: per field, roles only (there is no record yet, so conditions and scripts are not evaluated). No access = the value is not shown.
- **Post-query**: per returned record, with roles, conditions and scripts. Failing here hides the value but the label stays if the roles allowed the field.

This is why a field can show in a list and not in a form, or the reverse.

## Special kinds

| Kind | What |
|---|---|
| **Query ACLs** | protect against *blind queries* (filtering or sorting on a column whose values the user cannot read, to infer them). `query_match` governs the exact operators (is, is not, in, same as, is empty ...); `query_range` governs the rest (starts with, contains, greater than ...) **and sorting**. Without a query ACL on the column, a `*.*` rule delegates to read access; a defined one overrides that. Use on sensitive columns where users see only some rows (salary, national id) |
| **Datatype ACL** | name `*.[<field type>]`: one ACL for every field of a type on every table. Create by switching the **Name** field to manual entry. List them by searching names starting `*.[`. The Scripting Governance Tool uses them |
| **Function fields** | since Brazil, reading a function field needs read on the field **and on every contributing field**. `report_view` needs report_view on all of them plus a role-only read ACL (no condition, no script): a read ACL with any script on a contributing field blocks report_view even for a user holding the role ([[Function Fields]]) |
| **Related record access** | *Controlled by References* (above) |
| **Embedded lists** | edit and delete in an embedded list follow the write and delete ACLs of the listed table |

## Scoped applications

- An ACL can secure objects of its own scope, and fields of its own scope on other tables.
- Table in another scope: no script conditions; and you cannot change ACLs (or add roles to them) belonging to another scope than the one selected.
- `*` table rules only in global; `*` field rules only for tables of the ACL's scope.
- Shared global tables (`sys_attachment`, `sys_question_answer`): `glide.enforce_security_scope.<scope_name>` = true makes scope-specific ACLs win over global ones.

## Properties

| Property | Effect |
|---|---|
| `glide.sm.default_mode` | above |
| Double check security on inbound transactions during form submission (System Properties > Security; property name not given) | off by default: a field rendered read-only can still be written if the client sends it (useful when client scripts set read-only fields). On: write ACLs are checked again on submit |
| `glide.sys_reference_row_check` | false by default: **script conditions of ACLs are not applied to reference fields** (the ACL passes on its other criteria). True applies them, at a performance cost |
| Apply standard security ACLs to AJAXGlideRecord calls (System Properties > Security) | enforced by default: client-side GlideRecord queries only return what the user may read. `sys_class_name`, `sys_id` and `sys_domain` are not checked. Server side, prefer `GlideRecordSecure` for sensitive data |
| `glide.security.admin.override.accessterm` | true on new instances, false on upgraded ones (absent = false). False: if any ACL on a field has **Admin overrides** cleared, the override is lost for all ACLs of that field |
| `glide.security.access_acl_as_impersonator` | true: while impersonating you can still read `sys_security_acl`, `sys_security_operation`, `sys_security_type` and `sys_user_role`, to debug |

## Giving `snc_external` users a table

For users holding only `snc_external` to see a table's list, as `security_admin`:

1. ACL type `ui_page`, operation read, name `<table>_list`, role `snc_external`.
2. Add `snc_external` to the table's read ACL (create it if missing).
3. ACL type `ui_page`, operation read, name `<table>`, role `snc_external`.
4. For each writable field: ACL type `record`, operation create, name `<table>.<field>` (or `*` for all), role `snc_external`.

## Role Management V2

Covered in [[Role Management]]; the Brazil pages add:

- Plugins `com.glide.role_management` (base) and `com.glide.role_management.inh_count` (V2, default on new instances): V2 keeps one row per user and role in User Roles (`sys_user_has_role`) with a read-only **Inheritance Count** (`inh_count`); the *Role Inheritance Map* column visualises it. Optional REST plugin `com.glide.role_management.inh_count.rest_api`.
- Deprecated by V2 but kept: `granted_by` (only Role Delegation uses it), `included_in_role`, `included_in_role_instance`. **Custom scripts using them: do not upgrade.**
- Before upgrading, in Scripts - Background (server side, global scope; it only reports, but may run for hours on a large table, during which roles must not be edited): `new RoleManagementVerify().verifyInheritedRoles();`
- `glide.security.inh_count_patcher.enabled` = true runs the *UserHasRoleInhCountPatcher* job, which repairs counts broken by simultaneous role or group changes.
- `glide.role_management.v2.audit_roles` = true makes Audit Roles (`sys_audit_role`) record role changes from then on (no backfill).

## Security jump-start (ACL rules) plugin

Installed on every new instance; not meant for existing ones (test first). It adds role-based ACLs on system tables, roughly:

| Role required | Tables (operations) |
|---|---|
| admin | scripts and UI logic (`sys_script`, `sys_script_include`, `sys_script_client`, `sys_script_ajax`, `sys_ui_action`, `sys_ui_policy`, `sys_ui_script`, `sys_processor`), navigation (`sys_app_application`, `sys_app_module`, `sys_app_category`), `sys_properties`, `sys_security_acl` and its role, operation and type tables, `sys_user_role`, `sys_user_token`, `syslog`, `sys_audit`, `sysevent_register`, `sysevent_script_action`, `sysrule`, portal and gauge tables, `sys_job`, `sys_status`, `sys_installation_exit` |
| user_admin | `cmn_department`, `cmn_location`, `core_company`, `sys_user_grmember`, LDAP server and OU tables |
| itil | read `sys_user_has_role`, `sys_group_has_role`, `sys_user_role_contains`; create and write `sys_user_group` |
| asset or itil | write, create, delete `cmdb_ci` |
| catalog_admin | `sc_category`, `sc_cat_item` |
| knowledge | create `kb_knowledge` |
| personalize_dictionary | `sys_dictionary`, `sys_documentation` |
| template_editor | `sys_template` |
| itil_admin | `sys_home` |
| everyone | read `sysevent_email_action` (for subscriptions); a user without roles can update only their own `sys_user` record |

## Discrepancies in the docs

- "Allow ACL" is described on its own page as granting access by default unless a rule denies, which does not match the Allow If description elsewhere (access only when the requirements are met).
- `edit_task_relations` / `edit_ci_relations` are described two ways (define relationships; extend the table).
- The function fields page says "in Rome and earlier" then "in Brazil and later", leaving the releases in between unstated.
- The property behind *Double check security on inbound transactions* is not named.

## Related

- [[Create an ACL]] · [[ACL Not Working as Expected]] · [[Role Management]] · [[Users, Groups and Roles Overview]] · [[Base System Roles]] · [[Impersonation]] · [[Function Fields]] · [[Business Rules]] · [[Data Policies]]
