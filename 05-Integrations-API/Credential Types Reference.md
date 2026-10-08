---
type: reference
tags: [reference, integrations, security, discovery, automation, cmdb, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Connections and Credentials > Get started with credentials > Create and test your credentials (read in full 2026-10-08 through the docs site) - Ansible Tower, API key, Applicative, Basic authentication, Chef server, CIM, Cloud (AWS, Azure, Cloud Management), Container image repository, Infoblox, JDBC, JMS, OAuth 2.0, SAP, SNMP, SSH, VMware and Windows credentials. The repeated common-field tables are merged into one; the sample private keys are left out. https://www.servicenow.com/docs/r/platform-security/connections-and-credentials/t_CreateCredential.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Credential Types Reference

**What this is:** the credential types that can be created in the Credentials (`discovery_credentials`) table, what each is for, and the fields and target-side requirements specific to each.
**Where:** All > Connections & Credentials > Credentials > New (also Discovery, Service Mapping or Orchestration > Credentials)
**Role required:** `admin`

How credentials are stored, ordered and chosen: [[Connections, Credentials and Aliases]]. Storing them in a vault: [[External Credential Storage and CyberArk]].

## Fields most types share

| Field | Meaning |
|---|---|
| **Name** | unique, descriptive |
| **Active** | |
| **User name**, **Password** | no leading or trailing spaces (the form warns) |
| **Credential alias** | the alias or aliases that may use this credential; for Service Mapping and Discovery patterns it can also hold a CI type table name (for example `cmdb_ci_apache_web_server`) |
| **External credential store**, **Credential ID**, **Credential storage vault** | replace user name and password by an identifier resolved in a vault |
| **Applies to**, **MID servers** | all MID Servers or specific ones |
| **Order** | lower is tried first |
| **Windows MID Server Service Account** | marks the record as representing the MID Server's own service account |
| **Authentication Algorithm** | a signing script, on types that support it |

## Types

| Type | Used by | Specific fields and notes |
|---|---|---|
| **Ansible Tower** | Cloud Management | user name and password of an Ansible Tower administrator |
| **API key** | flows and workflows (through the alias) | **API Key** |
| **Applicative** | Discovery, Service Mapping | a second login for an application on top of the host credential; **CI type** it belongs to. Needed only where a pattern's prerequisites say so. Tables to use: SAP ASCS, SCS, Central Instance, ERS, Java Cluster, NetWeaver Dialog Instance `cmdb_ci_appl_sap_ascs`; Microsoft SQL `cmdb_ci_db_mssql_instance`; MySQL `cmdb_ci_db_mysql_instance`; Oracle database, Advanced Queue, E-Business Suite `cmdb_ci_db_ora_instance`; WebLogic `cmdb_ci_app_server_weblogic`; IBM Security Access Manager `cmdb_ci_app_server_webseal`; Exchange mailbox `cmdb_ci_exchange_mailbox`; Tibco EMS `cmdb_ci_appl_tibco_message` |
| **Basic authentication** | not stated on the page (?) | user name and password for basic authentication |
| **Chef server** | Cloud Management | **Admin Name**, **Admin Key**, **Validator Name**, **Validator Key**, **Cert Name**, **Cert Key** (RSA private keys from the Chef installation) |
| **CIM** | Discovery | access to a CIM server about storage and VMware ESX hosts; the user needs admin rights there. NetApp: install the SMI-S provider on the storage host and create a CIM credential for its agent account |
| **AWS** | Discovery, Cloud Management | **Access Key ID**, **Secret access key**. A MID Server running on EC2 with an **IAM role** uses the role's temporary credentials instead, and stored ones are ignored |
| **Azure Service Principal** | Discovery, Cloud Management | **Tenant ID**, **Client ID**, **Authentication Method** = Client secret (client assertion not supported), **Secret key** |
| **Azure Enterprise Agreement** | Cloud Management billing | **Enrollment number**, **Access Key** |
| **Cloud Management**, **CMP node**, **CMP SSH key pair** | Cloud Management | mostly created automatically for provisioned machines; deactivate, reorder or limit to a MID Server rather than edit |
| **Container image repository** | Discovery | read-only user and password, **Repository** (FQDN and path) |
| **Infoblox** | Cloud Management (IP pools) | **wAPI Version**, user name and password |
| **JDBC** | Discovery, Orchestration | database user and password |
| **JMS** | Discovery, Orchestration | user and password for the JMS provider |
| **OAuth 2.0** | HTTP services (flows, REST) | **OAuth Entity Profile** (grant type + scopes); **Connect to Auth Server via MID Server** (for client credentials, authorization code, resource owner password; choose MID Servers in **Applies to**: at least one Up, Validated, with capability REST or ALL, and able to reach the token URL; the MID Server user needs `oauth_admin`); **Integration Type** *System* or *Personal* (per-user tokens; the flow must run as the user who initiates the session: [[Personal OAuth Authentication and Web Embeddables Sessions]]) |
| **SAP** | Discovery, Orchestration | SAP JCo user and password |
| **SNMP community** | Discovery, Service Mapping, Orchestration | only a community string (no user). `public` is tried automatically; all configured strings are tried |
| **SNMPv3** | Discovery, Orchestration | **User name**, **Authentication protocol** (MD5, SHA-1, SHA-224, SHA-256, SHA-384, SHA-512), **Authentication Key**, **Privacy protocol** (3DES, AES128, AES192, AES256, DES), **Privacy key**, **Use Context** + **Context Name** (not with external storage), **Privacy Credential ID** (CyberArk) |
| **SSH** | Discovery, Orchestration, Integration Hub | user and password |
| **SSH private key** | the same | **SSH private key** (RSA, DSA, ECDSA or ED25519, PEM as produced by OpenSSH `ssh-keygen`, starting `-----BEGIN`; ED25519 only in OpenSSH format; convert PuTTY keys with PuTTYgen > Conversions > Export OpenSSH key), **SSH passphrase**, **Password** (the sudo password if needed), **SSH Certificate** (RSA or ED25519 OpenSSH certificate; OpenSSH 7.8 or later). Preferred over passwords |
| **VMware** | Discovery, Cloud Management | a vCenter account with the read-only role. Not for work inside guest machines (use SSH or Windows there) |
| **Windows** | Discovery, Orchestration | table `windows_credentials`; see below |

## SSH: root privileges

Commands need root. Either give root credentials (simplest, weakest), or an ordinary account allowed specific commands through **sudo** (`/etc/sudoers`, edited with `visudo`); probes use sudo when their `must_sudo` parameter is true (default false). **sudo does not work with private key credentials unless the sudoers entry has `NOPASSWD`**, because there is no password to supply. Example line: `disco ALL=(root) NOPASSWD:/usr/sbin/dmidecode,/usr/sbin/lsof,/sbin/ifconfig` (paths must match the system).

| Command | Platform | Why |
|---|---|---|
| `dmidecode` | Linux | hardware details, serial number |
| `fdisk -l` | Linux | disks and sizes |
| `multipath -ll` | Linux | MPIO device mappings |
| `ls` | Linux | directory contents |
| `dmsetup table`, `dmsetup ls` | Linux, Solaris | low-level volumes |
| `lsof` | all UNIX | which process holds which connection |
| `adb` | HP-UX | CPU speed and memory |
| `iscsiadm`, `fcinfo`, `prtvtoc`, `pfiles`, `pgrep`, `/usr/bin/ps`, `/usr/ucb/ps` | Solaris | iSCSI names, port WWPNs, partitions, TCP connections, processes (`/usr/ucb/ps` must be installed on Solaris 11; KB0564262; a `proc_owner` role is an alternative to root for `ps`) |
| `chage`, `chpasswd` | Linux, UNIX | password ageing and changes (Orchestration, Integration Hub) |
| read access to `oratab` | UNIX | Oracle home |

Without root, the account needs read access to application configuration files, for example `httpd.conf` (Apache), `nginx.conf`, `my.cnf` (MySQL), `server.xml` / `web.xml` / `catalina.jar` (Tomcat), `jboss-service.xml`, `cell.xml` / `serverindex.xml` (WebSphere), `oratab` and `listener.ora` plus execute on `lsnrctl` (Oracle), and `/etc/*release`, `/etc/profile`, `/etc/bashrc`, `/proc/cpuinfo`, `/var/log/dmesg`.

## Windows

- A MID Server installed on a Windows host as a service. Credentials come from `windows_credentials` or, failing that, the MID Server service account.
- The account must be a **domain user with local administrator rights on the targets**, or a local administrator on the target; no interactive logon right is needed. With UAC enabled, administrative calls may fail (the docs recommend disabling UAC on targets). Just Enough Administration (JEA) profiles can narrow the rights.
- Name formats: `DOMAIN\user`, `user@example.domain.com`, `WORKGROUP\user`, `.\user` (local).
- Other domain than the MID Server host: PowerShell 3.0 to 5.1 on the MID Server host. `mid.use_powershell` = true makes the MID Server use PowerShell.
- Workgroup computers: the built-in administrator or a domain user on that computer.

## Related

- [[Connections, Credentials and Aliases]] · [[External Credential Storage and CyberArk]] · [[Credentials Fail in Discovery or Orchestration]] · [[OAuth 2.0 Outbound - The Instance as OAuth Client]]
