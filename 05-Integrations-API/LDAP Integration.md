---
type: concept
tags: [concept, integrations, import-sets, users, security, scripting, business-rule, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Authentication > LDAP integration (whole section, 58 topics, 3,092 cleaned lines, read in full 2026-10-08 through the docs site) - overview, FAQ, requirements, setup (certificate, server, listener, attributes, test, OU definitions, data source, auto provisioning, MID Server with monitoring, binary data and troubleshooting), import and map data (transform maps, scripting, choice action, verify), troubleshooting (monitor, error codes, one-time password), record synchronization (refresh filters, extraction, inactive accounts, script examples), Active Directory Application Mode (ADAM) with LDAPS and ADAMSync, Microsoft AD LDAPS certificates, global catalog, OpenLDAP schema change, deletions. The Windows-side procedures (ADAM, ADAMSync, certificate authority) and the ADAMSync XML samples are condensed to what matters on the instance side. https://www.servicenow.com/docs/r/platform-security/ldap-integration/c_LDAPIntegration.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# LDAP Integration

**In one line:** the instance reads users and groups from the company directory (Active Directory or another LDAP v3 server) through import sets, and lets those users log in with their directory password; it never writes to the directory and never stores the password.

From the Brazil docs. Step by step: [[Set Up an LDAP Integration]]. Problems and error codes: [[LDAP Login or Import Problems]]. Users: [[Users, Groups and Roles Overview]], [[sys_user]].

## What it does

| Feature | How |
|---|---|
| **Authentication** | at login the instance finds the user's distinguished name (DN) with the service account, then binds as that DN with the password typed. Directory lockout and expiry policies therefore apply. A user is checked against LDAP when **Source** (`source`) on the user record starts with `ldap`; otherwise the local password is used. **LDAP Server** on the user says which server |
| **Scheduled refresh** | scheduled imports (normally nightly, off-peak) compare directory attributes with user and group records |
| **Listener** | a persistent search: changes reach the instance in about 10 seconds. Needs Active Directory with ADNotify or a server supporting persistent search control. Only users and groups; records outside the OU filter are ignored |
| **On-demand login** | a directory user without a record yet logs in: the record is created from LDAP through the *LDAP User Import* transform map. Needs `glide.ldap.authentication` and `glide.ldap.user.autoprovision` (both true by default) |

Limits worth knowing:

- **A user forced by Active Directory to change password at next logon cannot log in**: the instance cannot change directory passwords.
- **MFA**: LDAP logins are non-SSO, so the default MFA enforcement applies ([[Multi-Factor Authentication]]).
- Nothing is deleted when an entry disappears from the directory (deleting a user or department would break history and references). Deactivate instead.
- Departments are not synchronised by default (no transform map for them).
- Directory down = LDAP users cannot log in: keep local admin accounts. `glide.ldap.onetime.password.enabled` (default on) emails a one-time password valid `glide.authenticate.onetime.password.validity` minutes (10) to users with notifications enabled.

## Connection options

| Channel | Port | Import | Authentication |
|---|---|---|---|
| LDAP | 389 | yes | yes |
| LDAPS (the server's certificate uploaded to the instance) | 636 | yes | yes |
| VPN (IPSEC tunnel) | | yes | yes |
| **MID Server** (no inbound firewall opening) | MID to instance over 443 | yes | **no** |

Global catalog: 3268 (LDAP) and 3269 (LDAPS) expose a partial copy of every domain of a forest. `sAMAccountName` is then no longer unique: choose another user id and coalesce attribute (`userPrincipalName`, email, `objectSid`), and import the new key values before switching the coalesce.

Several domains: one LDAP server record per domain, each pointing at a domain controller of that domain. Several forests through one account are not supported.

Query limit: Active Directory returns at most 1,000 objects per query. Without **Paging** the instance splits the query by first letter; with paging the server splits the result (more efficient).

## Records

| Record | Where | Key fields |
|---|---|---|
| LDAP server (`ldap_server_config`) | **System LDAP > LDAP Servers** | **LDAP Server URLs** (primary and redundant, tried in order, up servers first), **Login distinguished name** and **Login password** (read-only service account; empty password = anonymous bind), **Starting search directory**, **MID Server**, **SSL**, **Listener** + **Listen interval**, **Paging**, **Connect timeout**, **Read timeout**, **Attributes** |
| OU definition | related list on the server (two samples: Users, Groups) | **Name**, **RDN** (appended to the starting directory), **Query field** (`sAMAccountName` on AD, often `cn` elsewhere; **must equal the User ID**), **Table**, **Filter**, **Active** |
| Data source | related list on the OU definition | **Type** LDAP, **LDAP target** (the OU definition), **Import set table name** |
| Transform maps | **System LDAP > Transform Maps** | *LDAP User Import* (`ldap_import` to `sys_user`) and *LDAP Group Import* (`ldap_group_import` to `sys_user_group`) |
| Scheduled imports | **System LDAP > Scheduled Loads** | *Example LDAP User Import* and *Example LDAP Group Import*, inactive by default |
| Certificate | **System LDAP > Certificates** | PEM, expiry notification (at least 20 days ahead) |

**Attributes** on the server limits what each query returns: without it every readable attribute is loaded (slow, and exposes more than needed; transactions can freeze when the directory gains new attributes). For manager lookups include `manager` and `dn`.

Default user filter (people with a surname, not computers, not disabled):

```text
(&(objectClass=person)(sn=*)(!(objectClass=computer))(!(userAccountControl:1.2.840.113556.1.4.803:=2)))
```

## Transform maps

Only **one active transform map per source and target table**, or duplicates appear. A custom map must contain:

| Source field | Target | Coalesce | Why |
|---|---|---|---|
| `u_source` | `sys_user.source` | no | holds the DN: marks the user for LDAP authentication, finds the manager, builds group membership |
| `u_samaccountname` (AD) or `u_dn` / `u_cn` | `sys_user.user_name` | **yes** | must be unique |

Default mapping without a map: `sAMAccountName` to `user_name`, `mail` to `email`, `telephoneNumber`, `homePhone`, `mobile`, `givenName`, `sn`, `title`, `department`, `manager`, `initials` to `middle_name`.

- Reference fields: an unmatched value creates a new referenced record (for example a location) unless the field map's **Choice action** is *ignore* (leave empty, continue) or *reject* (skip the whole row).
- `manager` arrives as a DN. Script include `LDAPUtils` resolves it: `setManager(source, target)` in the map script, `processManagers()` in an *onComplete* script for managers imported after their staff, `addMembers(source, target)` in *onAfter* for group members. An *onStart* script creates the helper:

```js
// transform script (server side, global), onStart
gs.include('LDAPUtils');
var ldapUtils = new LDAPUtils();
ldapUtils.setLog(log);
```

- Target fields must be long enough for a DN (default string length 40 truncates). The test load sizes the import table from 20 sample records; User ID is cut at 40 characters.
- Skip a row in a map script by emptying `user_name`; or set `ignore = true` in an *onBefore* script.
- Binary attributes (`objectSID`, `objectGUID`, photos) need a custom script; through a MID Server list them in `glide.ldap.binary_attributes` (system property and MID Server property).
- **Run business rules** applies to the target table only.

## Deactivating users disabled in the directory

The default filter hides disabled accounts, so the instance never learns they were disabled. Options from the docs:

| Approach | How |
|---|---|
| Widen the filter and decide in the transform | remove the `userAccountControl` clause; in the map: bit 2 set = disabled (values 514, 546). Never insert a user that is already disabled |
| A second data source containing only inactive accounts (a "disabled" OU or a filter on the flag) | its transform map sets `target.active = false`. Simple, no effect on the main import |
| A field on the user storing `userAccountControl` plus a before business rule on change | deactivates and locks out when the bit is set |

```js
// onBefore transform script (server side, global)
var uac = parseInt(source.u_useraccountcontrol, 10);
if (uac & 2) {                      // disabled in Active Directory
    target.active = false;
    target.locked_out = true;
    if (action == 'insert') ignore = true;
}
```

Or by OU: `source.u_dn.indexOf('OU=Disabled Accounts') > -1`.

## Listener properties

| Property | Default | Meaning |
|---|---|---|
| `glide.ldap.listener.use_background_transaction` | false | run the listener start as a background transaction so a quota rule can cancel it after 5 minutes |
| `glide.ldap.listener.mid.use_background_transaction` | false | the same through a MID Server |
| `glide.ldap.listener.mid.one_listener` | true | a single ECC queue message to start or stop the listener |

Read timeout with SSL: the lower of the server field and `com.glide.ssl.read.timeout`.

## Directory-side material in the docs (condensed)

- **LDAPS for Active Directory**: the domain controller needs a certificate (internal CA or bought); export the public certificate (and the issuing CA's chain if it is not a public CA) in DER or Base-64 and upload it under **System LDAP > Certificates**. **When that certificate expires all LDAPS logins fail**: renew ahead (Microsoft CA default validity is one year).
- **ADAM / AD LDS**: a lightweight directory used as a buffer when policy forbids outsiders from reaching domain controllers, or to consolidate several domains. *userProxy* objects (no password, linked to the AD account by `objectSID`) let it authenticate against AD; *ADAMSync* copies accounts from AD on a schedule. The instance then points at the ADAM partition with the full DN of an ADAM account as login. ServiceNow does not support its configuration.
- **OpenLDAP 2.3 with back-bdb**: limited inequality indexing; a customer workaround adds a custom indexed attribute. Unsupported.

## Related

- [[Set Up an LDAP Integration]] · [[LDAP Login or Import Problems]] · [[Multi-Factor Authentication]] · [[Local Authentication - Login, Password Policy and Password Reset]] · [[Users, Groups and Roles Overview]] · [[Integration Options and Interfaces Overview]] · [[Business Rules]]
