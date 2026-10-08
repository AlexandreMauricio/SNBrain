---
type: concept
tags: [concept, security, integrations, instance-admin, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Encryption > Edge Encryption (chapter read in full 2026-10-08). This note draws on - Edge Encryption system requirements, Sizing your environment, Calculate the order-preserving and tokenization database size, Installing Edge Encryption, Request Edge Encryption, Set up an Edge Encryption user account, Download the proxy server, the interactive installer pages (install, CyberArk, signature key, HTTPS certificate, AES 128 and 256 keys, update SSL certificate, proxy database, launch, verify), the command line installer pages (install, RSA key pair, SSL certificate, keystores - Java KeyStore, SafeNet, Unbound, file - web proxy, memory limits, start, obfuscate passwords, additional proxy), Authenticate a proxy server, Stop and uninstall pages, Set up multiple provider SSO, CyberArk integration, Using a load balancer, Upgrading Edge Encryption, Schedule a proxy server upgrade, manual upgrades on Linux and Windows, Roll back. https://www.servicenow.com/docs/r/platform-security/edge-encryption/c_InstallEdgeEncryptionProxy.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Edge Encryption Proxy - Installation, Keystores and Upgrades

**In one line:** the Edge Encryption proxy is a Java service the customer installs, sizes, secures and upgrades on their own servers; every proxy of an instance must share the same keys, signing key pair, known clear text, static IV and (if used) proxy database.

From the Brazil docs. What the proxy is for: [[Edge Encryption Overview]]. The settings file: [[Edge Encryption Proxy Properties Reference]]. Edge Encryption is being deprecated (see the overview).

## Requirements

| Item | Requirement |
|---|---|
| Java | **Java 21 or later** on the proxy host from Brazil (the installation page: Java 17 dropped in Brazil, Java 11 in Yokohama). The older *System requirements* page still says 11.0.6 or later in the 11.x series, and the upgrade page 1.8u144: stale text. One page says only Oracle JRE is officially supported, another that OpenJDK is supported (discrepancy) |
| Host | 64-bit Windows Server (2012, 2012 R2, 2016, 2019 listed) or 64-bit Linux with the 32-bit GNU C library; 3 GHz CPU, 4 cores preferred |
| Memory | 4 GB for the proxy, 6 GB recommended, plus memory for the operating system |
| Network | outbound TCP 443 to the instance; clients must reach the proxy (a DMZ placement may be needed); a web proxy with basic authentication is supported |
| Version | same release family as the instance; proxies are backward compatible so upgrades need no downtime, but upgrade promptly |
| Proxy database | MySQL 5.7 or 8.0, 64-bit, 16 GB RAM, RAID 10 or SAN, high-availability cluster, on a dedicated machine (not the proxy host) |

**Sizing:** at least two proxies behind a load balancer; one proxy per two application nodes; one more per 500 simultaneous users; extra for failover (2,000 users: at least five). Load balancer method *least connections*. CPU above 80% for minutes means add a proxy.

**Database size** in bytes: (order-preserving configurations × records each) × 3 for growth × 1,536, plus the same for tokenized records.

## Who does what

| Person | Tasks |
|---|---|
| Instance administrator (`security_admin`) | download the proxy, create the proxy user with role `edge_encryption`, configure keys and defaults, configurations, jobs, rules, monitoring |
| Network administrator | install and run proxies and the database, key management, DNS or routing so users reach a proxy, load balancer |
| Security administrator | decide the encryption type per field |

## Installing

Download from **All > Edge Encryption Configuration > Installation & Downloads > Downloads** (interactive installer, or the archive for the command line).

| Step | Interactive installer (`java -jar <file>.jar`, as administrator) | Command line |
|---|---|---|
| Install | **Install New**: location, instance URL with port, the `edge_encryption` user; proxy host (FQDN), HTTP and HTTPS ports, unique proxy name, poll and keep-alive intervals | `java -jar edgeencryption-<version>-all.jar -m install -n <proxy_name> --instancehost <instance>.service-now.com -p 443 --protocol https -s <install_path>`; on Windows then `edgeencryption.bat install` to register the service |
| Signature key | RSA pair in a JCEKS keystore: new, existing or imported. **Same pair on every proxy** | `keytool -genkeypair ... -keyalg rsa -keysize 2048` in the shipped keystore after changing its default password; set the signature properties |
| HTTPS certificate | choose or import into a keystore | CSR with OpenSSL, signed certificate into PKCS12, import into the JCEKS keystore; alias in `edgeencryption.proxy.https.cert.alias` |
| AES keys | 128-bit (mandatory) then optionally 256-bit: file store, new or existing Java KeyStore; both in the same keystore | `keytool -genseckey -alias <alias> -keyalg aes -keysize 128` (or 256); or a file of exactly 16 or 32 bytes in `/keys` named as the alias |
| Register the key on the instance | pause in the installer, define the default key on the instance with the same alias, size and type | same ([[Edge Encryption Configuration - Keys, Jobs, Patterns and Integrations]]) |
| Database | URL, name (default `edgeencryption`), user | database properties |
| Start | **Launch**, **Check Status** | Linux `./startup.sh`; Windows `bin\edgeencryption.bat start` |

- The installer also offers **Verify Installation** (run tests) and **Reinstall Existing**. It cannot set up a SafeNet keystore: use the command line.
- Key aliases: lowercase letters and numbers. In a Java KeyStore the key password must equal the keystore password.
- On Linux, ports 80 and 443 need a root install; the installer can drop to an unprivileged user afterwards.
- Windows: change the service name in `conf/wrapper.conf` (`wrapper.ntservice.name`, `.displayname`) **before** first start when adding proxies.
- **Memory:** in `conf/wrapper.conf` add `wrapper.java.additional.<next number>=-Xms<MB>m` and `-Xmx<MB>m`, both to physical memory minus 2 GB; no gaps in the numbering; restart.
- **Additional proxies:** install, copy the keys and `edgeencryption.properties` from the first, change name, host and ports. One proxy per machine.
- **Obfuscating passwords** in the properties file: only once everything works; a passphrase file in `conf`, named by `edgeencryption.encrypter.properties.password`.
- **CyberArk** (optional): with the AIM client on every proxy host, the proxy fetches its passwords (instance user, keystores, database, SafeNet, web proxy) from the vault by credential name instead of storing them.

### Authenticate the proxy on the instance

A new proxy logs "has not yet been authenticated" and browsers get "This site can't be reached". **Edge Encryption Configuration > Proxies** > select it > **Authenticate**: Unauthenticated, Pending, Authenticated. Survives restarts; not required again during an upgrade until it succeeds.

### Reaching the proxy

Users browse to the proxy's host and port (or the load balancer in front) instead of the instance URL.

- **Load balancer on a different port:** redirects break because the proxy writes its own port into the response. Set `edgeencryption.proxy.rewrite.location.host` and `edgeencryption.proxy.rewrite.location.https.port` to the load balancer's.
- **Single sign-on:** the identity provider record must use the proxy URL as homepage, entity id and audience. To let some users in through the proxy and others directly, create **two** identity provider records for the same provider (make the `idp` field of `saml2_update1_properties` non-unique first) and give each user the matching record; with several providers the *MultiSSO* installation exit must be changed and IdP-initiated login stops working. See [[Multi-Provider SSO - SAML and OIDC]].
- Scanners inside the network can be kept off the instance with the proxy's IP deny list.

## Stopping and removing

Linux `./shutdown.sh`; Windows `edgeencryption.bat stop` then `remove` for the service. Make sure nobody is connected; keep a copy of the properties file; delete the directory.

## Upgrades

- **During an instance upgrade** do not add, edit or delete configurations, rules, patterns, jobs, key configurations, upgrade schedules or deny-list entries. A job running at that moment stops; rerun it afterwards and it continues where it was.
- **Scheduled proxy upgrade:** logged in through the proxy as `security_admin`, **Proxies > Upgrade Schedules > New**: proxy, start time, active. One schedule per proxy; not two proxies of one machine at once. Usually under 15 minutes with a short offline moment. A new directory is created and `/conf`, `/keys`, `/keystore` and the Java `cacerts` are copied; nothing else. On failure the proxy rolls back by itself and the schedule shows a **Failure Reason**.
- Prerequisites: `JAVA_HOME` and the Java temp directory outside the proxy directory.
- **Manual:** `java -jar edgeencryption-dist-<version>-...jar -m dist-upgrade -c <proxy directory>`; the old directory is kept as a backup. Roll back by stopping, deleting the new directory, renaming the backup and starting.
- Windows: no open files or shells inside the installation directory, or the upgrade fails on file locks.
- Third-party libraries (SafeNet jars) must live **outside** the installation directory, referenced by `edgeencryption.thirdparty.vendor.library.path`, or an upgrade loses them.
- The **Proxy build** column in **Proxies > All**: green up to date, yellow out of date, orange upgrade failed.
- Mixed proxy versions within the instance's release family work but behave inconsistently.

## Related

- [[Edge Encryption Overview]] · [[Edge Encryption Proxy Properties Reference]] · [[Edge Encryption Configuration - Keys, Jobs, Patterns and Integrations]] · [[External Credential Storage and CyberArk]] · [[Multi-Provider SSO - SAML and OIDC]]
