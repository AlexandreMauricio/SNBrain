---
type: concept
tags: [concept, security, integrations, update-sets, scripting, admin, roles, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Platform Security > Code Signing (whole chapter, 49 topics, 2,261 cleaned lines, read in full 2026-10-08 through the docs site) - overview and Circle of Trust, Explore, Configure (administrator role, trusted and protected instance guided setup, configuration file, certificate validation, quorum-controlled certificate revocation, turning off, the older manual procedure with key pairs, certificates and scheduled jobs, key specifications, ECC firewall rules, Root of Trust), Using (standalone signing tool and arguments, JDBC, REST and SOAP, flows and actions, specific records, signatures at source control commit, signature verification), Health and Status Dashboard and utilities, properties, roles, actions and roles, change audit data, logs. Screens of the dashboards are summarised. https://www.servicenow.com/docs/r/platform-security/code-signing-landing.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Code Signing and the Circle of Trust

**In one line:** records whose content ends up being executed by a MID Server (data source SQL, REST and SOAP messages, flow steps, scripts) carry a digital signature; the MID Server refuses work whose signature is missing, altered or not from a trusted certificate, and signatures can only be produced on a separate **trusted instance**, never on the **protected** (production) one.

From the Brazil docs. Steps: [[Set Up Code Signing with a Trusted Instance]]. Part of the Vault subscription: [[ServiceNow Vault and Otto for Vault]]. Related hardening settings (static analysis, flow signature verification, audit): [[Hardening Settings - Validation, Files, Logging and Other]].

## The threat it answers

Without it, someone who can edit records on production (a stolen admin session is enough) can change the SQL of a JDBC data source or the script behind an integration, and the MID Server, sitting inside the company network, executes it. With Code Signing:

1. Content is created or changed on the **trusted instance** and signed there.
2. It travels to the protected instance in a **signed update set**.
3. On every ECC queue request the MID Server checks the signature against trusted certificates; invalid or missing means rejected, logged, and reported back.

Even the most powerful administrator on the protected instance cannot sign, cannot switch validation off there, and cannot change the governing properties directly.

## Pieces

| Piece | Meaning |
|---|---|
| Plugin **Code Signing** (`com.glide.code_signing`) | signs shipped metadata at build time; brings *Code Signing OOB App Signatures* (`com.glide.code_signing.oob_apps_signatures`) with signatures for Store application versions |
| Plugin **Code Signing Enterprise** (`com.glide.code_signing_enterprise`) | the customer feature; scope prefix `sn_cse`. Access must be granted by support (`com.snc.kmf.signature.validation.optin`) |
| **Trusted instance** | where signing keys live and jobs are created; at least one, several possible |
| **Protected instance** | where validation is enforced |
| **Circle of Trust (COT)** | the certificate relationship that makes the protected instance accept update sets signed by the trusted one |
| Key Management Framework | holds the keys: cryptographic modules `cm_code_signing` and `cm_code_attest` |
| **KMF Signature Configuration** | per table: **Table Name**, **KMF Signature Purpose** (for example *ECC Queue*), **Signature Generation Fields** (changing any of them invalidates the signature), **Signature Generation Filter**, **Sign Attachment**, **Instance Key** |
| KMF Signature Records (`sn_kmf_record_signature`) | the signatures |
| X.509 Certificates (`sys_certificate`) | verification certificates; type *Trusted CodeSigning Cert* once installed |
| **Root of Trust** | which certificates are believed: by default also ServiceNow's build certificates; optionally only your own |

Key pairs: RSA 4096, signing algorithm RSASSA-PKCS1-v1_5 with SHA-512, in a `.p12` file, **issued by a public or your internal certificate authority, not self-signed**. Three uses: customer signing and COT administration (trusted instance; separate pairs advised), runtime/notarization (protected instance).

Since Australia: script includes and business rules are signed with a predefined *Wild Card Purpose* (reserved for those two tables); and verification groups a record's signatures by certificate and accepts the record if the latest signature of **any** trusted certificate is valid (before, only the single most recent signature counted, which broke records after upgrades).

## Security jobs

**System Security > Security Jobs** (type *Signing Job*), created on the trusted instance, exported with **Export Code Signing job to production**, imported on the protected instance and started there:

| Type | Does |
|---|---|
| **Sign Update Set** | signs the matching records in an update set and adds signature records and certificates to it |
| **Mass Sign Records** | signs every record of a table that matches the signature configuration |
| **Mass Sign Attachments** | the same for attachments |
| specific records (since Vancouver) | signs only chosen records, so unreviewed code is not signed by accident; attaches a log |

Limits and timing: an update set holds at most 10,000 records (`com.snc.csf.maximum_update_size`, 6,000 to 10,000; larger ones are split into a batch); a signed export is valid for a limited window (`com.snc.kmf.signature.validity_window`; the configuration file must be installed within an hour, a signed Root of Trust job within 10 minutes).

Typical uses, always the same two patterns:

| Content | Existing records | New records |
|---|---|---|
| JDBC data sources (file data sources do not go through the MID Server; LDAP ones cannot be signed) | Mass Sign Records on *Data Source* | build in an update set on the trusted instance > complete it > Sign Update Set > import |
| REST and SOAP messages | a signature configuration, then Mass Sign Records | signed update set |
| Flows, subflows, actions | Mass Sign Records on *Step Instance* | publish on the trusted instance, signed update set |

Other ways to sign:

- **At source control commit** (trusted instance, ServiceNow Studio): property `sn_cse.com.snc.csf.generate_signature_commit` = true. Each eligible selected record gets a signature in the same update set, and both are pushed together (five records become ten files). The commit cannot finish while a signature is missing. Silently inactive if the instance is not eligible (not opted in, enforcing validation, no active signing key). Deleted records are not signed.
- **Standalone Signing Tool** (requested from support): `signRecords.sh -d <application directory> -f <keystore.p12>` on a local clone of the application's Git repository; writes `sys_certificate` and `sn_kmf_record_signature` files to push back. Options: `-a` key alias, `-c` one signature file, `-k` key password, `-p` keystore password, `-o` new certificate, `-w` wipe existing signatures.
- **Batch signature generator** (Utilities dashboard): upload the CSV of missing or invalid signatures from the guardrail scan, get ready-made signed update sets.

## MID Server side

- Validation applies to all MID Servers. To allow or reject by protocol regardless of signatures, write **ECC firewall rules** in `agent/boot-config.yaml` (copy `boot-config-sample.yaml`; restart):

```yaml
security:
  eccFirewall:
    mode: enforcing
    rules:
      - tags: [rest]
        action: accept
      - tags: [jdbc]
        action: reject
```

- Tags are hierarchical (a parent covers its children): `http` (rest, soap), `ssh` (scp, sftp), `windows` (cim, powershell, wmi, winrm), `itom` (discovery, service_mapping, event_management, health_log_analytics, cloud_provisioning_governance), `directory_services` (ldap), `databases` (jdbc), `javascript`, `groovy`, `vcs` (git), `dns`, `snmp`, `syslog`, `data_sources`, `integration_hub`, `orchestration`.
- An invalid configuration file stops the MID Server from starting.

## Root of Trust

| `com.snc.csf.servicenow_root_of_trust.disabled` | false (default) | true |
|---|---|---|
| Signatures by ServiceNow build certificates | trusted | not trusted |
| Signing without your own key | the instance key is used | nothing is signed |
| `api/sn_kmf/signature/certificates` | includes build certificates | excludes them |

Changing it: first re-sign everything with your certificate (scheduled job *ROT - Generate Updateset of records to migrate signatures using customer certificate* on the protected instance, a *Sign Update Set* job carried through the trusted instance and back), then the signed scheduled job **Disable ServiceNow Root of Trust**. Expect MID Server validation failures for anything missed.

## Certificate revocation by quorum

A Code Signing certificate is revoked through a request that several people must approve: on the trusted instance (guided setup > *Certificate Revocation*) choose the certificate, **Minimum approvals**, **Time window**, approver email addresses, a reason, and export; on the protected instance import and commit the update set, then **Trigger Quorum Approval**; approvers act from email links. Optionally MID Servers restart afterwards (forces certificate resynchronisation; unprocessed events can be lost). Roles `sn_cse.quorum_requester`, `approver_user`.

## Monitoring

**Code Signing > System Health > Dashboard**:

| Tab | Shows |
|---|---|
| Overview | plugin and opt-in status, whether validation is enforced, signatures trusted / untrusted / orphan, MID Servers active or inactive, signed records by type and application |
| Signature Verification Status | per script: type, application, **Valid**, **Invalid** or **Missing** (eligible but unsigned), last scan; **Rescan** reruns the guardrail check |
| MID Server Configuration | name, status, version, last check-in |
| Key Pair and Certificates | certificate, crypto module, type, expiry, **Valid / Expiring Soon / Expired**, chain |
| Configuration | the governing properties and when they changed |
| Utilities | batch signature generator |

**Change audit** (production only, on by default with `sn_cse.com.snc.csf.vault_audit_enabled`): every create, update and delete on a record covered by a signature configuration goes to `sn_cse_vault_codesigning_audit_data` (scope, package, document id, table, modified by, modified on, operation). Read-only for everyone; visible with `codesigning_auditor`. A cleaner job runs every 12 hours: retention 90 days (30 to 360), and at most 9,000 rows, whichever cuts first, so export what must be kept.

Logs: **System Logs > System Log > Code Signing** lists untrusted ECC queue records; `com.glide.codesigning.tracking.debug` for node log detail; MID Server parameter `mid.log.level` = TRACE for firewall decisions (messages start *ECC message execution denied*); REST message and data source records show the validation error.

## Properties

| Property | Meaning |
|---|---|
| `com.snc.kmf.signature.validation.optin` | feature enabled for the instance (support only) |
| `com.snc.kmf.signature.validation.flag` | **validation enforced** (true after setup on the protected instance); `com.snc.kmf.signature.validation.certificate_trust` must then be non-empty |
| `com.glide.codesigning.tracking.enabled`, `.tracking.logging.enabled`, `.tracking.debug` | caller tracking and its logging |
| `com.glide.codesigning.expanded.tracking.enabled`, `.length` (3), `com.glide.codesigning.expanded_tracking.topic.list` | deeper call-stack validation for listed ECC topics |
| `com.glide.codesigning.tracking.agent.validation.exclusion.list` | ECC agents skipped |
| `com.glide.codesigning.tracking.validation.fail_fast` | stop at the first failing script |
| `com.glide.codesigning.tracking.unsupported_script_tracking.enabled` | do not notarize ECC records inserted by unsupported scripts |
| `glide.jdbcprobeloader.tracking`, `glide.rest.codesigning.tracking`, `com.glide.web_service_outbound.impl.codesigning.tracking` | signing checks for JDBC, RESTMessageV2, SOAPMessageV2 |
| `com.glide.codesigning.tables.excluded_from_audit` | tables left out of the change audit (internal tables by default) |
| `sn_cse.com.snc.csf.vault_audit_data_retention_days`, `...vault_audit_data_max_size` | audit retention |

Most need elevated security to change; several can only be changed by a signed job from the trusted instance.

## Roles

| Role | Can |
|---|---|
| `codesigning_admin` (also written `sn_cse.codesigning_admin`) | configure; assign the two roles below. Assigned under **Code Signing > Administration > Role Administration** by someone with `admin` and `security_admin`; the user must be in the Global scope and log in again |
| `codesigning_manager` | signature configurations and signing jobs |
| `codesigning_auditor` | read configurations, jobs and audit data |
| `sn_kmf.cryptographic_manager`, `security_admin` | needed with the above for anything touching keys and enforcement |

## Discrepancies in the docs

- Two setup procedures coexist: the guided setup (current) and an older manual one with certificate export buttons and *Turn on Code Signing Property* scheduled jobs.
- Property names are printed with underscores in one procedure (`com_snc_kmf_signature.validation.flag`), and the table as `sys_property`.
- The configuration file name on the MID Server appears as `boot-config.yaml` and once as `boot-config.xml`.

## Related

- [[Set Up Code Signing with a Trusted Instance]] · [[ServiceNow Vault and Otto for Vault]] · [[Update Sets]] · [[Move an Update Set between Instances]] · [[Connections, Credentials and Aliases]] · [[ServiceNow Studio Source Control, Fluent Apps and Deployment]] · [[Hardening Settings - Validation, Files, Logging and Other]]
