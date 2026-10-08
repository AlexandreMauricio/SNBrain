---
type: how-to
tags: [how-to, security, update-sets, integrations, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Platform Security > Code Signing (chapter read in full 2026-10-08) - Assign the Code Signing Administrator Role, Configure Code Signing Enterprise on your trusted instance, Upload your Code Signing configuration file to your protected instance, Configure Code Signing Enterprise on your protected instance, Create Code Signing key pairs and certificates, Sign the JDBC data source records, Turn off Code Signing. https://www.servicenow.com/docs/r/platform-security/config-code-signing.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Set Up Code Signing with a Trusted Instance

**Goal:** make production MID Servers execute only content signed on a separate trusted instance.
**Prerequisites:** Code Signing Enterprise licensed and opted in by support on both instances; roles `admin`, `security_admin` (elevated), `codesigning_admin`, `sn_kmf.cryptographic_manager`; RSA 4096 key pairs in `.p12` files issued by a certificate authority (not self-signed): customer signing and COT administration for the trusted instance, runtime/notarization for the protected one; an hour of uninterrupted time.
**Navigation:** All > Code Signing > Configuration > Guided Setup

Concepts: [[Code Signing and the Circle of Trust]].

## Steps

1. **Role**: on each instance, **Code Signing > Administration > Role Administration**: move the user to *Selected User(s)* and save. Work in the Global scope; log out and in again.
2. **Trusted instance**: Guided Setup > **Instance type** *trusted instance* > **Action** *Turn on Code Signing* > upload the *customer signing* key pair (**+Add File**, password, **Import**) > **Continue** > upload the *COT administration* key pair > **Continue** > **Export**. An XML configuration file is downloaded. **It must be installed on the protected instance within an hour.**
3. **Protected instance, import**: **System Update Sets > Retrieved Update Sets > Import Update Set from XML** > the file > open *Codesigning configuration* > **Preview Update Set Batch** (resolve with *Accept remote update* or *Resolve known CS conflicts*) > **Commit Update Set Batch**.
4. **Protected instance, setup**: Guided Setup > *protected instance* > confirm the update set was committed > wait for the certificate installation > upload the *runtime/notarization* key pair > **Continue**.
5. **Guardrail check**: the instance scans for invalid or missing signatures (do not leave the page). If any are found, **Download Report**, fix them (sign on the trusted instance and import; the batch signature generator helps), refresh to rescan.
6. **Complete setup** and wait for the configuration jobs: "Code Signing configuration completed successfully".
7. From now on, change signed content only on the trusted instance and move it in signed update sets (security job type *Sign Update Set*, or signatures generated at source control commit).

## Result / how to check it worked

On the protected instance `com.snc.kmf.signature.validation.flag` is true and `com.snc.kmf.signature.validation.certificate_trust` has a value. **Code Signing > System Health > Dashboard** shows validation enforced and signatures trusted. Editing a signed JDBC data source directly on production makes its next run through the MID Server fail with a signature validation error, and the attempt is listed under **System Logs > System Log > Code Signing**.

## Example

Trusted instance `<trusted>.service-now.com`, protected instance `<instance>.service-now.com`. Key pairs `example-signing.p12`, `example-cot-admin.p12`, `example-runtime.p12` from the company certificate authority. After setup, a new data source *Example Import* is created in update set *Example signed change* on the trusted instance; the update set is completed, a signing job *Sign Example signed change* (type *Sign Update Set*) is started, the update set is exported, imported and committed on the protected instance. The import runs through MID Server *Example MID 01* without error. A colleague who alters the SQL statement on production sees the next run rejected.

## Tables / fields involved

- `sn_kmf_record_signature`: signatures; `sys_certificate`: certificates (type *Trusted CodeSigning Cert*)
- `sys_kmf_crypto_module`: modules `cm_code_signing`, `cm_code_attest`
- `sys_properties`: the validation properties
- `sn_cse_vault_codesigning_audit_data`: change audit

## Gotchas

- The key pair passwords are secrets: type them into the form only; never store them in a note or ticket.
- **+Add File** missing: wrong scope (must be Global) or `sn_kmf.cryptographic_manager` missing.
- The exported configuration expires (one hour); export again if it does.
- Update sets above 10,000 records are split into a batch: commit the whole batch.
- Turning it off is also done from the trusted instance (*Turn off Code Signing* exports a file to install on the protected instance); it cannot be switched off by editing a property on production.
- After instance upgrades, check the dashboard for invalid signatures and expiring certificates before integrations start failing.
- Direct edits on production of anything signed will break it by design: agree the change process with integration owners first.
