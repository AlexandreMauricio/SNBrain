---
type: concept
tags: [concept, security, integrations, fields, domain-separation, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Encryption > Edge Encryption (whole chapter, 88 topics, 6,062 cleaned lines, read in full 2026-10-08 through the docs site). This note draws on - Edge Encryption, Exploring Edge Encryption, Edge Encryption components, Edge Encryption clients, Key management for Edge Encryption, SafeNet key versioning, Encryption configurations and patterns, Installed with Edge Encryption, Planning for Edge Encryption, Edge Encryption limitations, Edge Encryption dictionary attributes, Domain separation and Edge Encryption. https://www.servicenow.com/docs/r/platform-security/edge-encryption/c_EdgeEncryptionOverview.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Edge Encryption Overview

**In one line:** Edge Encryption puts a proxy server **in the customer's own network** between users and the instance; the proxy encrypts chosen fields and attachments on the way out and decrypts them on the way back, with keys that never leave the customer, so the instance (and ServiceNow) only ever holds cipher text.

From the Brazil docs. **Status:** from Zurich, Edge Encryption and Edge Encryption Core are being prepared for deprecation: hidden and not activated on new instances, still supported (KB0867184). The successor is [[Field Encryption - Modules, Encrypted Fields and Access]]; migration outline in [[Field Encryption - Mass Jobs, Clones, Archives and Migration]]. Comparison: [[Choosing an Encryption Option]].

The other Edge notes: [[Edge Encryption Proxy - Installation, Keystores and Upgrades]], [[Edge Encryption Proxy Properties Reference]], [[Edge Encryption Configuration - Keys, Jobs, Patterns and Integrations]], [[Edge Encryption Rules and Rule APIs]], [[Encrypt a Field with Edge Encryption]].

## Pieces

| Piece | Where | Role |
|---|---|---|
| Edge Encryption plugin (`com.glide.edgeencryption`) | instance; separate subscription | configuration: which fields, patterns, rules, jobs, keys by alias |
| **Proxy server** | customer network (Windows or Linux, Java) | reads each HTTP request, applies encryption rules, encrypts; reads each response and decrypts. Browser, SOAP and REST traffic must all pass through it |
| **Proxy database** (MySQL) | customer network | only for order-preserving encryption and encryption patterns; shared by all proxies. Tables `db_id`, `token_map` (order tokens), `edge_token_map` (pattern clear text) |
| Keystore | customer network | the AES keys, the RSA signing pair and the proxy's HTTPS certificate |

The proxy runs three clients towards the instance: a **heartbeat** (drives the proxy's online status; `edgeencryption.proxy.keepalive.interval`), a **polling/sync** client (fetches configurations, keys by alias, jobs, rules, patterns; `edgeencryption.config.poll.interval`, do not change) and the **user traffic** client.

Who sees clear text: only a user connected **through a proxy**. Only a `security_admin` connected through a proxy can configure Edge Encryption. A proxy connects to one instance only.

## Two ways of protecting data

### Encryption configurations (per field or per table's attachments)

| Encryption type | Same input gives same output | Filter and sort | Needs proxy database |
|---|---|---|---|
| **Standard** (AES 128 or 256) | no | none: cannot filter, sort or group | no |
| **Equality preserving** | yes | *is*, *is not*, *is empty*, *is not empty*; group by | no (the installer page lists it as possibly needing one: discrepancy) |
| **Order preserving** | yes, with order tokens | also *greater than* / *less than* for strings, *before* / *after* (*or on*) for dates; sort | yes |

- AES 256 needs unlimited-strength cryptography enabled in the Java runtime. A default AES 128 key must exist even if unused.
- Field types: String, single and multi-line text, Date, Date/Time, Email, IP Address, Journal, Journal Input, URL; multi-byte characters allowed. Attachments: standard encryption only.
- Service Catalog variables: string types, single-line, multi-line and wide single-line text, date, date/time, URL, email, HTML, IP address.
- If the proxy database is down, order-preserving fields can still be updated but sort and group wrongly until an *order token repair* job runs.

### Encryption patterns (tokenization)

A pattern (a regular expression) is looked for in requests; a match is stored in clear in the proxy database and replaced on the instance by a **token of the same size**. For data such as card or social security numbers that turn up outside encrypted fields; a supplement, not the main method. The same string always gets the same token. Encrypted fields are not checked for patterns.

Because the clear text of tokens exists only in the proxy database: back it up every 24 hours and keep the binary logs at least two days. If it is lost, the values cannot be restored.

## Keys

- The customer supplies and manages them. At most **two** active keys (the default 128-bit and the default 256-bit); no key per column set, category or role.
- Stores: plain **file** (unencrypted, protect it yourself), **Java KeyStore** (JCEKS, password protected, many keys by alias; ships as `keystore/keystore.jceks`), or enterprise key management: **SafeNet KeySecure** or **Unbound Technology** (the proxy must run on the Unbound client machine). Nothing else is supported.
- The shipped keystore holds the ServiceNow public key (alias `servicenow`) that validates ServiceNow-signed rules: import it if you use another keystore.
- SafeNet **key versioning**: one alias, incrementing versions, instead of a new alias per key (proxies from London on).
- Before removing a key, re-encrypt everything that used it with a key rotation job; otherwise that data is unreadable.

## Limits

Cannot be encrypted: choice fields, HTML fields, virtual fields, number or auto-numbered fields, system fields, fields on system tables (except some on `sys_user`), anything not listed above.

| Area | Limit |
|---|---|
| Server-side logic | business rules, scripts and back-end features cannot evaluate or change encrypted values (equality checks against an identically encrypted value still work) |
| Email | bypasses the proxy: inbound data arrives unencrypted, outbound mail carries cipher text |
| Search and reporting | no global search; **not usable in reports**; text search does not cover encrypted attachments |
| Import and export | cannot import into an encrypted field; exports contain cipher text, even through the proxy |
| Other features | not with data archiving; no batch REST (set `glide.uxf.disable_rest_batching` = true); cannot paste encrypted data into an unencrypted field |
| Forms and lists | encrypted fields are missing from *Go to* and column header filters; an encrypted journal field disables the **Post** button; list *Show Matching* / *Filter Out* match exactly |
| Configuration | a configuration can be deactivated, never deleted; field size cannot change afterwards (encrypting widens the column, which can take long); indexed fields only with equality or order preserving |
| Inheritance | a parent field's configuration covers the child tables; a field encrypted on a child cannot also be encrypted on the parent; inherited Date and Date/Time fields cannot be encrypted on the child; String and URL on parent **or** child, not both |
| Oracle instances | strings over 2,925 characters cannot be sorted; only the AL32UTF8 character set |
| Operations | each proxy is managed separately (no cluster management); extra network hop and CPU cost |
| MID Server | ECC queue fields cannot be encrypted; encrypted data cannot be used by Discovery or Service Mapping |

**Domain separation:** no support. The proxy is not domain aware; usable only where no domain-specific keys, configurations or rules are needed ([[Domain Separation Support Levels by Application]]).

## What the plugin installs

| Table | Holds |
|---|---|
| `sys_encryption_configuration` | encrypted fields and attachment tables |
| `sys_encryption_rule` | encryption rules (name, condition, script, order) |
| `sys_encryption_proxy` | registered proxies |
| `sys_encryption_key`, `sys_encryption_key_configuration`, `sys_encryption_proxy_key` | key aliases, default keys, keys per proxy |
| `sysauto_encryption_job`, `sys_encryption_job_execution`, `sys_encryption_job_execution_chunk` | scheduled jobs and their runs |
| `sys_edge_encryption_invalid_insert_log` | rejected attempts to save clear text into an encrypted field |
| `sys_proxy_encryption_type` | encryption types offered on the form |

| Property | Default | Meaning |
|---|---|---|
| `sn_edge_encryption.cleartext.allowed` | false | true lets clear text be saved in an encrypted field by someone not going through the proxy |
| `glide.edge.pattern.min.size` | 5 | minimum pattern length |
| `glide.edge.pattern.disallowed.chars` | | characters not allowed in patterns |
| `sn_edge_encryption.logging.destination` / `.verbosity` | file / info | logging |
| `sn_edge_encryption.encryption.proxy.buildtag` | | proxy version registered with the instance |

Role `edge_encryption`: for the account the proxies log in with.

Dictionary attributes ([[Dictionary Attributes Reference]]):

| Attribute | On | Effect |
|---|---|---|
| `edge_encryption_excluded=true` | field or table | can never be encrypted |
| `edge_encryption_enabled` | field | system attribute: the field is *eligible* (true for string fields); not editable, not shown |
| `edge_encryption_clear_text_allowed=true` | field | server-side scripts may append clear text to the encrypted string |
| `edge_encryption_clear_attachment_allowed=true` | table (collection entry) | unencrypted attachments may be added to a table with attachment encryption |

## Related

- [[Edge Encryption Proxy - Installation, Keystores and Upgrades]] · [[Edge Encryption Configuration - Keys, Jobs, Patterns and Integrations]] · [[Edge Encryption Rules and Rule APIs]] · [[Edge Encryption Proxy Properties Reference]] · [[Choosing an Encryption Option]] · [[Field Encryption - Modules, Encrypted Fields and Access]]
