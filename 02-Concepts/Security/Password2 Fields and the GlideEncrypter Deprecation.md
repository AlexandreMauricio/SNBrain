---
type: concept
tags: [concept, security, scripting, glide-api, fields, flows, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Encryption > Key Management Framework (chapter read in full 2026-10-08) - Password2 encryption with the KMF, Prepare your instance for GlideEncrypter deprecation, GlideEncrypter deprecation, Deprecate GlideEncrypter usage of 3DES for password2 fields, FlowKMFEncrypter API, FlowKMFEncrypter in a Flow Action. https://www.servicenow.com/docs/r/platform-security/platform-encryption/password-2way-encrypted-fields.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Password2 Fields and the GlideEncrypter Deprecation

**In one line:** a **Password (2 Way Encrypted)** (`password2`) field stores a secret that the instance can decrypt again; since Rome its key is managed by the Key Management Framework with AES, and the old `GlideEncrypter` API and its 3DES algorithm are being retired.

From the Brazil docs. Keys and modules: [[Key Management Framework (KMF)]].

## How Password2 works

- Active by default (`glide.kmf.encrypter.enabled` = true); no Field Encryption Enterprise needed. No domain separation support; works on self-hosted instances.
- Parent module `cm_glide_encrypter` holds a specification and a key able to decrypt legacy values.
- The module has **submodules, one per application scope**, each with its own AES-256-GCM key. Writing to a Password2 field uses the submodule of the scope the field's table belongs to, if there is one. New fields generally use `instance_level_glide_encrypter`.
- You cannot create submodules yourself; they come with application plugins. Submodule keys can be rotated, the parent's cannot.
- A migration job re-encrypts legacy values with the submodule key, only for scopes that have a submodule.

## In scripts

Server side; run the script **in the same scope as the table**.

```javascript
// Server-side (business rule, script include, background script), same scope as the table
var gr = new GlideRecord('u_example_connection');
gr.u_secret.setDisplayValue('<SECRET_VALUE>'); // encrypts; setValue() must not be used
gr.insert();

var clear = gr.getElement('u_secret').getDecryptedValue(); // decrypts
```

- `setValue()` cannot be used on a Password2 field; `GlideEncrypter` must not be used on it.
- The docs say `getDecryptedValue()` is not scoped, "available globally" (whether it can be called from a scoped application is not clear from the wording: ?).

## GlideEncrypter is going away

| Instance | `glide.security.glideencrypter.allow` | Behaviour |
|---|---|---|
| New in Zurich or later | false, cannot be changed | calls return null and log an "Unsupported call to GlideEncrypter" error (KB1320986) |
| Upgraded | changeable by `security_admin` | when true the API still works but uses AES-256-GCM through KMF instead of 3DES |

Finding your own uses: **All > Instance Scan > Suites > GlideEncrypter > Execute Suite Scan > Full Instance** (role `admin`), open the findings, rewrite the scripts, scan again. Only customer-created or modified records are checked; untouched base records are ServiceNow's to fix. Instance Scan: [[Instance Scan]].

## Retiring 3DES for Password2

Possible since Vancouver, following KB1704481 in the *Security Compliance* module (elevated `security_admin`). Afterwards:

- existing 3DES values are still decrypted, never written; a value is re-encrypted with AES the next time it is updated;
- saving may fail with "Password value cannot be saved due to technical issue" (KB1296997).

Check first:

- Password2 values moved between instances (applications, XML export, data sources, anything else) need the keys on the target: enable Key Exchange / Resource Exchange ([[KMF Key Exchange and Key Import]]).
- Cloning down to a release before Vancouver with preserved Password2 fields longer than 125 characters: ask support to disable the deprecation before the clone.
- Conversion to legacy (pre-Rome) Password2 values stops working; a partial deprecation can be requested.

## FlowKMFEncrypter

A script include that replaces `GlideEncrypter` **inside Flow Designer actions only** (not in ordinary scripts). AES, key supplied by the Flow Engine crypto module.

```javascript
// Script step of a Flow Designer action (server side)
var encrypter = new FlowKMFEncrypter();
var cipher = encrypter.encrypt('<SECRET_VALUE>');
var clear = encrypter.decrypt(cipher);
```

"undefined is not a function" from the action means the cross-scope call was not allowed: find or create the Restricted Caller Access Privilege record (**Source Scope** Global, **Source Type** Flow Action, **Source** the action, **Target** script include `FlowKMFEncrypter`, **Operation** Execute API) and set **Status** to *Allowed* (roles `admin` and `security_admin`). Editing the action later sets it to *Invalidated*: allow it again. Background: [[Application Access Settings and Cross-Scope Privileges]].

## Related

- [[Key Management Framework (KMF)]] · [[Module Access Policies (MAPs)]] · [[Flow Data Types and Transform Functions]] · [[Hardening Settings - Validation, Files, Logging and Other]] · [[Connections, Credentials and Aliases]]
