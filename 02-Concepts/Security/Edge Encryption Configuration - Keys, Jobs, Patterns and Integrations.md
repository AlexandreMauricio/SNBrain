---
type: concept
tags: [concept, security, integrations, service-catalog, data-management, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Encryption > Edge Encryption (chapter read in full 2026-10-08). This note draws on - Configuring Edge Encryption, Configure encryption keys on the instance, Rotate encryption keys (single, mass and attachment key rotation jobs), Encrypt fields using encryption configurations (field and variable configurations, deactivate, encryption and decryption jobs), Encrypt attachments using standard encryption, Change a field or attachment's encryption type, Tokenize strings using encryption patterns, Repair or recover order-preserving encrypted data, Configure the IP address deny list, Encrypt data from a record producer, Data integration with Edge Encryption, ODBC driver integration, MID Server integration, Edge Encryption diagnostics and performance, Increase debug logging. https://www.servicenow.com/docs/r/platform-security/edge-encryption/edge-config.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Edge Encryption Configuration - Keys, Jobs, Patterns and Integrations

**In one line:** once a proxy is running, everything else about Edge Encryption is set on the instance under **Edge Encryption Configuration**, by a `security_admin` who is **logged in through the proxy**: key aliases, what to encrypt, the jobs that convert existing data, patterns, and how integrations are routed.

From the Brazil docs. Concepts and limits: [[Edge Encryption Overview]]. The proxy itself: [[Edge Encryption Proxy - Installation, Keystores and Upgrades]]. Steps: [[Encrypt a Field with Edge Encryption]]. Edge Encryption is being deprecated. Test changes on a non-production instance first.

## Keys on the instance

The instance knows keys only by **alias**; the key material stays on the proxies.

**Encryption Key Configuration > Set Up Keys**:

1. *Add New Keys*: alias (lowercase letters and numbers, unique; for Unbound the key file's name), **Key size** (128 or 256 bits), **Type** (File, Keystore, SafeNet, Unbound). **Next Step**.
2. *Keys Status*: wait for **Available** (all online proxies have the key). *Unavailable* after a few minutes means some proxy lacks it. An alias must have the same size and type on every proxy.
3. *Change Default Keys*: choose the default 128-bit and 256-bit keys. With SafeNet versioned keys pick the latest version (related links **Retrieve latest key versions**, **Update default keys to latest version**).
4. *Schedule Key Rotation*.

Keys that were ever a default, or are Available, cannot be deleted from the list.

### Rotation

After changing a default key, existing data stays under the old key until it is next written. Until a rotation job has run, **filters match only records encrypted with the current key and sorts show two groups**.

| Job (**Maintenance** menu) | Re-encrypts |
|---|---|
| **Schedule Single Key Rotation** | data under one named (retired) key |
| **Schedule Mass Key Rotation** | data under any previous key |
| **Schedule Attachment Key Rotation** | attachments of one table |

Data is decrypted and re-encrypted by the proxy. Audit history is processed too. Never remove a key from the proxies before a rotation has cleared its data.

## Encryption configurations

| What | Where | Fields |
|---|---|---|
| Field | **Encryption Configurations > Create New** | **Table**, **Type** = Column, **Column**, **Encryption type** |
| Attachments of a table | same form | **Type** = Attachment; only Standard AES128 or AES256 |
| Catalog variable | **Variable Encryption Configuration > New** | **Variable**, **Encryption type** |

- One active configuration per table and field. Date and Date/Time configurations only on a parent table, and creating them can take minutes: do it when the instance is quiet.
- Before encrypting a field: check which features and scripts use it, and fix its length (it cannot change afterwards).
- The encryption type can be changed on the record; existing values follow at their next change or with a job.
- **Deactivate** (untick **Active**) to stop encrypting; the record cannot be deleted. Then run a decryption job, or values are decrypted as they change.
- Encryption configuration records are audited, deletions included; the jobs are not.

With attachment encryption, a user **not** going through the proxy sees that attachments exist and their names but cannot open them or add new ones.

## Jobs for existing data

From the configuration record, related links; table `sysauto_encryption_job`. Role `security_admin`.

| Job type | Does |
|---|---|
| Encryption | encrypts unencrypted values of the field with the default key. Without it only new or changed values are encrypted |
| Decryption | clears encryption; the configuration must be inactive first |
| Attachment Encryption / Attachment Decryption | the same for a table's attachments (decryption does nothing while the configuration is active) |
| Order Token Repair | recreates missing order tokens after the proxy database was offline; all fields or one table and column |
| Database Recovery | resends all order-preserving values to the proxy to rebuild a proxy database that lost data |

- Form: **Name**, **Job Type**, **Table**, **Column**, **Run**, **Starting**, **Active**, **Process Historical Records** (also converts the Audit table's old and new values for an audited field). **Estimate Record Count** and **Execute Now** buttons; no estimate for audited fields or key rotations.
- The work is done by the proxies: schedule when few users are on, or add proxies. Failures: Job Failures (`sys_encryption_job_execution`).

## Encryption patterns

**Encryption Patterns > Create New** (or **Advanced Patterns** to activate a shipped one); needs the proxy database.

- **Basic**: build the pattern from character types with **Add**, grouping with **New Block**. **Advanced**: a Java regular expression with a **Sample match** and **Validate** (cannot switch back to basic).
- Rules: not letters only; at least five characters (`glide.edge.pattern.min.size`); no `*` or `+` quantifiers; matches whole words only.
- Exact-match text search works on tokenized values (the query is tokenized on the way); stemming does not.

## Getting data in by other routes

Everything must pass through a proxy to be encrypted.

| Route | Notes |
|---|---|
| REST and SOAP web services, JSONv2 | supported with the shipped rules, attachments included (REST, SOAP). No batch REST |
| Record producers | a producer writing to an encrypted field fails with an invalid insert until it has rules: on the record producer, related link **Create Edge Encryption Rule** creates two inactive rules, `<name>` (Service Catalog POST) and `<name>Json` (Service Portal JSON). Activate the one needed under **Rules > All**, and map by hand any variable that reaches its field through a script |
| MID Server | set the `url` parameter in the MID Server's `config.xml` to the proxy URL (not the web proxy settings); restart. ECC queue fields cannot be encrypted and encrypted data is not usable by Discovery or Service Mapping |
| ODBC driver | set **DataSourceIPProperties** in the ODBC management console to the proxy URL; the driver's truststore must trust the proxy's (or load balancer's) certificate, imported with `keytool` if self-signed |
| File import or export (Excel, CSV, XML) | not supported for encrypted fields |
| Anything custom | write a rule: [[Edge Encryption Rules and Rule APIs]] |

## Protecting and watching the proxies

- **Maintenance > Denylist IP Addresses** (`edge_encryption_ip_blacklist`): per proxy, an IP, range (`10.10.10.1-15`) or mask (`10.10.10.0/24`), IPv4 or IPv6, whose connections the proxy drops, for example internal vulnerability scanners. A listed user address is locked out of that proxy.
- **Proxies > All**: registered proxies, status, build.
- **Diagnostics and Troubleshooting > Proxy Error Reports**: error codes of the last seven days (one report per minute); drill down to the text in `edge_encryption_stat`. Two proxies with the same name produce only `DUPLICATE_PROXY_NAME` and no statistics.
- *Edge Proxy* graphs on the instance performance page: processing times (proxy request, rules, proxy-instance round trip, proxy response, total), host CPU, memory and disk, latency to the instance.
- **Invalid Insert Attempts** (`sys_edge_encryption_invalid_insert_log`): rejected saves of clear text, or of data that did not come through a proxy, into encrypted fields.
- The system log records proxies that stopped pinging and the case where no proxy is online.

## Related

- [[Edge Encryption Overview]] · [[Edge Encryption Rules and Rule APIs]] · [[Edge Encryption Proxy Properties Reference]] · [[Encrypt a Field with Edge Encryption]] · [[Auditing and Record History]]
