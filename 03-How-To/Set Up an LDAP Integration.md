---
type: how-to
tags: [how-to, integrations, import-sets, users, security, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Authentication > LDAP integration (read in full 2026-10-08) - LDAP integration setup, Install the LDAP X.509 SSL certificate, Define an LDAP server, Enable an LDAP listener, Specify the LDAP attributes, Test an LDAP connection, Define LDAP organizational units, Create a data source for LDAP, Auto provision LDAP users, LDAP transform maps, Verify LDAP mapping, Configure LDAP connection monitoring. https://www.servicenow.com/docs/r/platform-security/ldap-integration/c_LDAPIntegrationSetup.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Set Up an LDAP Integration

**Goal:** import users and groups from an LDAP directory and let those users log in with their directory password.
**Prerequisites:** role `admin`; an LDAP v3 directory reachable from the instance (firewall opened for the instance's addresses, or a MID Server for import only); a read-only service account in the directory; for LDAPS the server's public certificate.
**Navigation:** All > System LDAP

Concepts and options: [[LDAP Integration]].

## Steps

1. **Certificate (LDAPS only):** **System LDAP > Certificates > New**: name, paste the **PEM Certificate** or attach the file, keep expiry notification on. **Validate Stores/Certificates**.
2. **Server:** **System LDAP > Create New Server**: name, server URL (`ldaps://<host>:636` or `ldap://<host>:389`), **Login distinguished name** and **Login password** of the service account, **Starting search directory** (for example `DC=example,DC=com`). Optional: more URLs for redundancy, **MID Server**, **Paging** (recommended for Active Directory), **Listener**.
3. Set **Attributes** to the list actually needed (include `manager` and `dn` if managers are imported).
4. **Test connection** (related link), then **Browse** to confirm the directory tree is visible. The form shows a green dot per URL when the server is active and reachable.
5. **OU definitions** (related list; adapt the two samples): for users **RDN** (for example `OU=Staff`), **Query field** `sAMAccountName`, **Table** User, a **Filter**; the same for groups. **Browse** shows what each returns.
6. **Data source** (related list on each OU definition): **Type** LDAP, **LDAP target** = the OU definition, an import set table name. **Test Load 20 Records** (server and OU definition must be active).
7. **Transform map:** check *LDAP User Import* and *LDAP Group Import* (**System LDAP > Transform Maps**): coalesce on `user_name`, `u_source` mapped to `source`, and the **Choice action** of each reference field (create, ignore or reject).
8. **Schedule:** **System LDAP > Scheduled Loads**: adapt and activate the example user and group imports (off-peak). **Execute Now** to verify.
9. Put people in the **LDAP Admins** group: they are emailed when the job *LDAP Connection Test* (every 15 minutes) fails.

## Result / how to check it worked

- Imported users have **Source** starting with `ldap:` followed by their DN, and can log in with the directory password.
- A directory user without a record can log in and gets one created (auto-provisioning).
- **System LDAP > LDAP Monitor** shows connection and listener status.

## Example

Directory `DC=example,DC=com` with `OU=Staff` (people) and `OU=Groups`. Server record *Example Directory* with URL `ldaps://ldap.example.com:636` and start directory `DC=example,DC=com`. User OU definition: RDN `OU=Staff`, query field `sAMAccountName`, the default person filter. Group OU definition: RDN `OU=Groups`, filter `(objectClass=group)`. After the scheduled user import, *Test User* (`test.user` in the directory) exists with **Source** `ldap:CN=Test User,OU=Staff,DC=example,DC=com` and is a member of *Example Group* after the group import.

## Tables / fields involved

- [[sys_user]]: **User ID** (`user_name`), **Source** (`source`), **LDAP Server** (column name not given in the pages read (?))
- LDAP Server (`ldap_server_config`); import tables `ldap_import`, `ldap_group_import`

## Gotchas

- The **Query field** value must equal the User ID of the user record, or login fails.
- An update set or clone can carry the wrong `system_id` on the `ldap_server_config` record: requests then go to a node that does not exist on the target.
- Only one active transform map per import table and target table.
- Through a MID Server: import only, no password authentication, no SSL flag; the MID Server user needs `user_admin`.
- LDAP logins fall under the default MFA policy ([[Multi-Factor Authentication]]).
- Keep at least one local admin account for when the directory is unreachable.
