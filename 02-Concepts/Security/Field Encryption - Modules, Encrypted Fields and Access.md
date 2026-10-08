---
type: concept
tags: [concept, security, fields, access-control, scripting, glide-api, roles, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Encryption > Field Encryption (whole chapter, 55 topics, 2,761 cleaned lines, read in full 2026-10-08 through the docs site). This note draws on - Field Encryption, Exploring Field Encryption, Field Encryption Enterprise, Configuring Field Encryption, Activate Field Encryption, Role requirements, Configure Field Encryption modules, Cryptographic specifications for Field Encryption, Module keys, Module lifecycle policy exceptions, Configure encrypted field configurations, Configure multi-module encrypted field configurations, Configure module access policies for Field Encryption, Prevent users from attaching unencrypted files, Using Field Encryption, Create cryptographic module for Field Encryption, Using multiple encryption modules, Encrypt data using Row Conditions, Encrypt data using the Multiple Modules feature, Create a cryptographic specification, Configure advanced algorithms, Encrypting fields and attachments, Set encrypted field configurations, Script access for cryptographic modules, Configure script access to encrypted data, View declined cryptographic module usage requests, Upload attachments for encryption, Field Encryption Enterprise examples. https://www.servicenow.com/docs/r/platform-security/field-encryption.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Field Encryption - Modules, Encrypted Fields and Access

**In one line:** Field Encryption encrypts chosen columns (and, in Enterprise, attachments) inside the instance with a key held by a cryptographic module; only callers that a **module access policy** lets through can read or write the clear value, and everyone else sees an empty field.

From the Brazil docs. Replaces Column Level Encryption since Yokohama ([[Column Level Encryption (Legacy)]]). Built on [[Key Management Framework (KMF)]] and [[Module Access Policies (MAPs)]]. Operations (mass jobs, clones, archives, migration): [[Field Encryption - Mass Jobs, Clones, Archives and Migration]]. Own keys: [[Field Encryption - Customer-Supplied Keys and External Key Management]]. Steps: [[Encrypt a Field with Field Encryption]].

## Three records working together

| Record | Says | Where |
|---|---|---|
| **Field Encryption module** | which algorithm and key | **System Security > Field Encryption > Field Encryption Experience** (tiles per module), or **Field Encryption Modules** |
| **Encrypted field configuration (EFC)** | which table column, or a table's attachments, the module encrypts | *Encrypted Fields* on the module tile, or **Configurations > Create new**, or **Encrypted Field Configurations** |
| **Module access policy** | who or what may encrypt and decrypt | *Access Policies* on the module tile |

By default everything (users, scripts, system processes) is locked out. Works alongside ACLs; meant to be combined with them and with database-level encryption.

The *Field Encryption Experience* page has a **Modules** tab (one tile per module with its state and the status of its fields, policies and keys) and a **Configurations** tab (all encrypted fields, access policies and keys).

## Starter and Enterprise

| | Starter (free) | Enterprise (ServiceNow Vault or Platform Encryption bundle) |
|---|---|---|
| Encrypted fields | up to 5 | unlimited |
| Attachment encryption | no | yes |
| Key management | none: rotation through support | in the instance: rotate, renew, revoke, suspend |
| Customer-supplied key, external key management | no | yes |
| Module access policy types | Role only (per the KMF pages) | Scope, Role, Script, System user, Resource Exchange |

- The comparison table says Starter has no limit on modules or access policies; the KMF pages and warning messages speak of five modules and five policies for the non-enterprise product (discrepancy; the five-**field** limit is the one stated consistently for Starter).
- Install from **System Definition > Plugins**, searching *Field Encryption* (role `admin`). The Enterprise plugin id is given as `com.glide.now.platform.encryption` on most pages and as `com.glide.field.encryption.enterprise` on the EKMS page.
- No domain separation support; works on self-hosted instances.

## The module

Created with **Create new module** (name and algorithm). Purpose is always *Symmetric Data Encryption/Decryption*; the default specification is **AES 256 CBC** (128 also possible); parent module `column_level_encryption`. A key is generated with **Generate Key**, or automatically the first time something must be encrypted.

**Equality preserving** (deterministic): the same clear text always gives the same cipher text, which keeps equality filters and grouping working. Without it, equality comparisons on the encrypted column do not work. The pages describe this flag inconsistently, some calling the ticked state "non-deterministic"; the name, the algorithm page and the Column Level Encryption overview agree that ticked means deterministic.

## Encrypted field configuration

| Field | Notes |
|---|---|
| **Type** | Column or Attachment (Enterprise) |
| **Table**, **Column** | be in the table's application scope to see it |
| **Active** | from this moment new values are encrypted and access policies enforced. Existing values stay clear until a mass encryption job runs |
| **Crypto Module** / **Field Encryption module** | the module |
| **Method** | Single Module or Multiple Modules |
| **Encrypt by default** | with row conditions: records matching no condition are encrypted with this module (ticked by default when created from a module tile) |
| **Algorithm Equality Preserving** | read only, from the module |

Supported column types: String (also full UTF-8), Date, Date/Time, Email, Phone Number (E164), URL, HTML, Journal, Journal Input, Translated Field, Translated HTML, Translated Text.

Limits:

- **Not on system tables** (names starting `sys_`), fields or attachments.
- Date and Date/Time configurations go on a parent table only, not on a child.
- An **attachment** configuration does not cover child tables: one on `task` does not encrypt attachments on `incident`. Create one per table.
- Service Catalog item variables cannot be encrypted.
- **Encrypted fields are not audited and not shown in the activity stream or record history**; not configurable ([[Auditing and Record History]]).

An encrypted field shows a lock icon by its label.

## What a user sees

| Access through policies | Field behaves as |
|---|---|
| none | empty, in forms and lists |
| encrypt only | editable; what is typed shows as asterisks |
| decrypt only | clear value, read only |
| both | normal |

Policy fields, results (Track, Reject, StrictReject) and the debugger are in [[Module Access Policies (MAPs)]]. Field Encryption specifics:

- Types: Scope, Role, Script, *System Access* (processes in the system context), Resource Exchange.
- Script policies name a **Script Table** (access control, business rule, inbound email action, record producer, scheduled script execution, script include, UI action, widget, workflow activity, activity designer) and a **Target Script**; **Check Script Version** warns when the script has changed since.
- **Impersonation** ticked: an impersonating user gets the policy rights of both users; unticked: only their own.
- Forgetting the policies for scripts and system processes breaks end-to-end workflows that touch the field.
- Keep the KMF admin role to one person where possible.

## Several modules on one column

| Way | Who picks the module | Status |
|---|---|---|
| **Row Conditions** | a condition on the record (for example a department field) chooses the module; several conditions per configuration, plus the default | preferred; deterministic |
| **Multiple Modules** method | the first user to write the value: the module of their role | legacy; "non-deterministic" in the sense that the user decides |

- Either way, each record's field is encrypted by exactly one module, and a list can mix modules. Users see only the rows their module covers.
- Row conditions: columns and attachments only; no dot-walking in the condition; not on `sc_item_option`, `question_answer`, `sc_multi_row_question_answer`. After adding a condition run a *Mass Encryption* job; after changing one, a *Mass Rekeying* job.
- Multiple Modules: no mass encryption; cannot be switched back to single (deactivate and create a new configuration). One page says it is for columns only, another describes it for attachments (the user picks a module on upload).

## Attachments (Enterprise)

- Tables with an active attachment configuration encrypt uploads by default. Opting out needs a support case with a risk-acceptance statement.
- With several modules the upload dialog shows **Encrypt with Module** (only through the paperclip, not drag and drop; not when row conditions decide).
- `com.glide.encryption.enable_attachment_key_ui` = false removes the option to upload **unencrypted** (role `security_admin`).
- Encrypted attachments carry a lock icon and are listed only for users with module access.

## Scripts

Server side. A script that reads or writes an encrypted field, or uses a module directly, needs a Script-type policy (or a role, scope or system policy that covers it).

| Method | Behaviour on an encrypted field |
|---|---|
| `getDisplayValue()` / `setDisplayValue()` | clear value out / encrypted value in |
| `getValue()` / `setValue()` | the same while `glide_encryption.set_value_support_cle.disabled` is false (the default once the plugin is installed); when true, `getValue()` returns cipher text and `setValue()` writes **unencrypted** data |
| `changeCryptoModule(sourceTable, sourceID, attachmentID, newCryptoModuleId)`, `changeEncryptionContext(...)` | re-encrypt an attachment with another module (global scope only) |
| `disableEncryption(sourceTable, sourceID, attachmentID)` | remove encryption from an attachment |

The class that carries the attachment methods is not named on these pages (?). Without module access `getValue()` returns cipher text or null.

Using a module directly (business rule or script include, global scope in the docs' example):

```javascript
// Server side; needs a Script-type module access policy for this script
var cm = global.GlideCryptoModule.getModule('global.example_module');
var cipher = cm.encryptData('sample text');
var clear = cm.decryptData(cipher);
```

Requirements: the purpose exists in the module, an active key exists, the policy type is Script. Refusals are listed under **Key Management > Module Key Policies > Module Key Rejections** (one row per module and key type, **Last enforced** updated), for instance when the key is suspended or compromised.

## Roles

`admin` to elevate; `security_admin` for encrypted field configurations; `sn_kmf.admin` or `sn_kmf.cryptographic_manager` for modules, keys, policies and jobs; `sn_kmf.cryptographic_operator` for customer-supplied key properties.

## Related

- [[Key Management Framework (KMF)]] · [[Module Access Policies (MAPs)]] · [[Field Encryption - Mass Jobs, Clones, Archives and Migration]] · [[Field Encryption - Customer-Supplied Keys and External Key Management]] · [[Encrypt a Field with Field Encryption]] · [[Encrypted Field Shows Empty or Unreadable]] · [[Access Control Lists (ACLs)]] · [[ServiceNow Vault and Otto for Vault]]
