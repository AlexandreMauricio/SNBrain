---
type: concept
tags: [concept, integrations, security, discovery, flows, automation, admin, domain-separation, scripting, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Access Management > Connections and Credentials (whole chapter, 59 topics, 4,912 cleaned lines, read in full 2026-10-08 through the docs site). This note covers Explore credentials connections and aliases, Scope protections, Domain separation, Get started with connections (basic, HTTP(s), JDBC, JMS, connection attributes), Get started with credentials, Create a Connection & Credential alias, Credential aliases for Discovery and for Orchestration, Create and test your credentials, Credential affinity, Authentication Algorithms (configure, Amazon Signature, custom), Check IP service affinity. https://www.servicenow.com/docs/r/platform-security/connections-and-credentials/credentials-connections-alias.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Connections, Credentials and Aliases

**In one line:** a **connection** says *where* (host, URL, database), a **credential** says *with what* (user and password, key, token), and an **alias** is the stable name that flows, actions, Discovery schedules and Orchestration activities refer to, so the where and the what can change per environment without touching what uses them.

From the Brazil docs. Each credential type: [[Credential Types Reference]]. Keeping secrets out of the instance: [[External Credential Storage and CyberArk]]. One-form setup for spokes: [[Connection and Credential Configuration Templates]]. Steps: [[Create a Connection and Credential Alias]]. OAuth records behind an OAuth credential: [[OAuth 2.0 Outbound - The Instance as OAuth Client]].

## Tables and roles

| Label | Name | Notes |
|---|---|---|
| Connection | `sys_connection` | base table; children `http_connection`, `jdbc_connection`, `orch_jms_ds`, and the basic (PowerShell and SSH) connection |
| Credentials | `discovery_credentials` | base table; one child per type (for example `windows_credentials`, `oauth_2_0_credentials`) |
| Connection & Credential Aliases | `sys_alias` | |
| Connection & Credential Templates | `sys_alias_templates` | |
| Credential Affinity | `dscy_credentials_affinity` | which credential worked on which device |

Roles: `admin` creates aliases and credentials; `connection_admin` creates connections and sets attribute values; `credential_admin` and `connection_admin` can read aliases; `action_designer` uses connection attributes in actions; `flow_designer` can fill in configuration templates.

Menus (the pages use several names for the same module): **Connections & Credentials** (or *Credentials & Connections*), also under **IntegrationHub > Connections & Credentials** and the **Connections Dashboard**; credentials also under **Discovery > Credentials**, **Service Mapping > Credentials**, **Orchestration > Credentials**.

Used by: Flow Designer / Workflow Studio, Integration Hub (separate subscription), Discovery, Service Mapping, Orchestration, Cloud Management.

## Alias

| Field | Meaning |
|---|---|
| **Name** | letters, digits, underscore only. Old credential *tags* migrated at upgrade keep odd characters but cannot be edited until renamed |
| **ID** | `scope_name.alias_name`; in Global just the alias name (for example `x_example_app.example_alias`) |
| **Type** | *Connection and Credential* (default) or *Credential* (credentials only: Discovery, Orchestration) |
| **Connection type** | Basic, HTTP (default), JDBC, JMS, Kafka |
| **Support Multiple Active Connections** | otherwise **one active connection per alias** |
| **Default Retry Policy** | |
| **Configuration Template** | the template behind **Create New Connection & Credential** |
| **Parent Alias** | makes this a **child alias**: inherits the parent's properties, holds its own connection and credential (several connections for one integration) |

Related lists: **Connections**, **Connection Attributes**, **Child Aliases** (for type *Credential*: **Credentials**).

**Connection attributes** (Integration Hub): variables defined on the alias (label and type, like dictionary entries), given values on each connection's *Attributes* tab, and shown as data pills in an action step that uses the alias (for example a page size used as a REST query parameter). With several active connections the value comes from the connection used at run time. Label or type changes are not picked up by a step until the alias is removed from the step and added again.

## Connection

Common fields: **Name** (unique), **Credential** (optional; a credential may be used by only one active connection), **Connection alias**, **Active**, **Domain** (Flow Designer ignores it), **Use MID Server** with **MID Selection** (*Auto-Select MID Server* by **Capabilities** and **MID Application**, *Specific MID Server*, *Specific MID Cluster*).

| Type | Own fields | Notes |
|---|---|---|
| **Basic Connection for PowerShell & SSH** | **Host** (FQDN), **Override default port** | PowerShell always needs a MID Server |
| **HTTP(s) Connection** | **Connection URL**, or **URL builder** (**Mutual authentication**, **Protocol** or **Protocol profile** from `sys_protocol_profile`, **Host**, **Port**, **Base path**); **Connection Timeout** (milliseconds; never 0); attributes `additional_http_headers` (`name=value` pairs separated by `;`) and `odata_ping_url` (default `/sap/bc/ping`) | |
| **JDBC Connection** | **Format** (MySQL, Oracle, SQLServer, None; Sybase and DB2 Universal after uploading their driver JAR), **Host**, **Port**, **Database name**, **Instance name** (SQL Server), **Oracle sid** (default `orcl`), **Oracle port** (1521), **Query timeout**, **Connection timeout** (seconds; also the idle time before closing), **Connection URL** (generated and read-only for the built-in formats, manual otherwise), **JDBC driver** | MySQL, SQL Server and Oracle drivers ship with the instance |
| **JMS Connection** | **Initial Context Factory** (JNDI class), **Provider URL** (for example `tcp://<host>:61616`) | allowed factories in MID Server property `mid.property.jms.command.allowed_factory_names` |

Upgrade history: `jdbc_connection` and `orch_jms_ds` used to extend `sys_metadata` in the Orchestration runtime plugin; they now extend `sys_connection`, and JDBC *server* / *database port* became `host` / `port`.

## Credentials: storage, order, affinity

- Stored encrypted in `discovery_credentials`; **cannot be viewed after entry**. On request by a MID Server they are decrypted on the instance (password2 key), re-encrypted with that MID Server's public key, sent over TLS, and decrypted with its private key. No separate keys per tenant.
- **Every MID Server keeps a copy of all credentials** that apply to it: an ECC queue job `credentials_reload` makes it fetch the whole table by SOAP, including custom fields and the records behind custom reference fields. Tuning properties (create them): `com.snc.credentials_user_fields` (true; false leaves custom fields out) and `com.snc.credentials_recursion_depth` (3; reference levels followed).
- Windows MID Servers use their own **service account** for Windows targets unless Windows credentials exist; SSH and SNMP always come from the table.
- **Order**: lower numbers are tried first; equal or empty order means random. Give the few credentials that open most devices the lowest numbers, and anything with strict lockout a low number too.
- **Affinity**: after the first success the pair (credential, device) is stored in `dscy_credentials_affinity` and tried first next time; when it stops working everything is tried again and a new affinity is written.
- **Applies to**: *All MID servers* or *Specific MID servers* (visibility of the credential, not MID Server selection; not supported for Orchestration activities). Limit credentials to the MID Servers and schedules that need them.
- **Test credential** (related link): for SSH private key, Windows, SNMPv3, VMware, JDBC, JMS. Inputs: **Target** (an IP address; host URL for VMware; provider URL for JMS; not a MID Server), **Port**, **MID Server** (Windows credentials need a Windows MID Server; only Up and Validated ones), **DB Type** / **DB Name**, **Initial Context Factory**. A successful test proves the login, not that the account has the privileges the job needs.

## Credential aliases in Discovery

Without aliases a Discovery schedule can try every credential on the instance. With aliases on the schedule it uses only credentials carrying one of them.

Mechanics: business rule *Insert Discovery Affinity & Cred Aliases* runs when a probe is inserted in the ECC queue and may add two parameters: `credential_tag` (the alias IDs of the schedule) and `credential_id` (the affinity credential for that device). The MID Server then:

1. keeps credentials of the probe's type (SSH, Windows, SNMP ...);
2. keeps those linked to one of the tags (all, if there is no `credential_tag`);
3. puts the affinity credential first, then the rest by **Order**, and tries until one works.

Consequences: a credential that worked before is **not tried** if it lacks the schedule's alias; changing a schedule's aliases changes which credential is chosen; tags apply to the schedule and its IP ranges, not to single devices.

Setup: alias of type *Credential*; on the credential record unlock **Credential alias** and select it (a credential can carry several aliases, an alias several credentials).

Orchestration and Flow Designer use the same idea per activity or action: each occurrence can name its own alias, and the affinity lookup respects it.

## Scope protection and domain separation

- **Application** exists on `sys_connection` and `discovery_credentials` (not on the forms by default in Brazil; add it). In **protected scopes** (the docs name HR Service Delivery and Security Operations) records are covered by scoped ACLs and are **invisible to queries from other scopes**, including Global and `admin`, unless access is granted with Restricted Caller Access ([[Application Access Settings and Cross-Scope Privileges]]). Child tables inherit this. A connection made in an ordinary custom scope is not restricted automatically.
- Domain separation: support level *Standard*. Credentials have no domain of their own: they follow the application or the MID Server that uses them. Connections carry a **Domain**.

## Authentication algorithms

For web services whose authentication is not plain basic, API key or OAuth: a script computes headers, query parameters or a signature for each outbound request. Supported by the *REST*, *SOAP* and *Get Connection Info* steps.

- **Credentials & Connections > Authentication Algorithms > New**: **Name**, **Algorithm** (*Amazon Signature Version 4* or *Custom Authentication*), **Instance Authentication Script** (a script include, `sys_script_include`), **MID Authentication Script** (a MID Server script include, `ecc_agent_script_include`).
- Shipped scripts: `RequestAuthInternal` (read-only base), `RequestAuthAWSV4Signer` (on the MID: `RequestAuthAWSV4MIDSigner`), `RequestAuthTwitterSigner` (OAuth 1.0a), `RequestAuthSampleCustomSigner` (sample to copy; MID: `RequestAuthSampleMidCustomSigner`). They run server side, on the instance or on the MID Server.
- JavaScript APIs: `AuthCredential`, `HttpRequestAuthedData`, `HttpRequestData`, `RequestAuthAPI`.
- Then select the algorithm in **Authentication Algorithm** on the credential (for AWS: an AWS credential with access key id and secret access key).
- AWS error "Credential should be scoped to a valid region ... correct service": create property `com.glide.aws.auth.calculate.region.and.service` = true.

## IP service affinity

**Discovery Definition > IP Services** maps ports to protocols (80 HTTP, 22 SSH, 161 SNMP). Property `glide.discovery.ip_service_affinity` lets Discovery remember the last working port per IP address (tab *IP Service Affinities*). Change IP services only for custom ports.

## Discrepancies in the docs

- The module is called *Connections & Credentials* and *Credentials & Connections* on different pages.
- The credentials table is written `discovery_credentials` everywhere except once as `discovery_credential`.
- The Discovery page calls the business rule *Insert Discovery Affinity & Cred Aliases*; the Orchestration page still uses the older names.
- The HTTP connection note about how the URL is built swaps *Protocol* and *Protocol profile* relative to the field descriptions (protocol profile is the one used with mutual authentication).
- In the "OAuth via MID Server" alias table the **Application** row carries the description of **ID**.

## Related

- [[Credential Types Reference]] · [[External Credential Storage and CyberArk]] · [[Connection and Credential Configuration Templates]] · [[Create a Connection and Credential Alias]] · [[Credentials Fail in Discovery or Orchestration]] · [[OAuth 2.0 Outbound - The Instance as OAuth Client]] · [[Personal OAuth Authentication and Web Embeddables Sessions]] · [[Spoke Generator]] · [[Flow Spokes Shipped with the Platform]] · [[Certificates in Authentication - Certificate Login, Mutual TLS and Outbound Certificate Policies]]
