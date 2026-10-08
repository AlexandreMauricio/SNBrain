---
type: concept
tags: [concept, security, fields, roles, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Encryption > Column Level Encryption (whole chapter, 26 topics, 1,300 cleaned lines, read in full 2026-10-08 through the docs site) - Column Level Encryption, Exploring, Guided Tour, Column Level Encryption Enterprise, Configuring, Activate Column Level Encryption Enterprise, Migrating to Column Level Encryption, Prevent users from attaching unencrypted files, Using, Create cryptographic module, Encrypt data using the Multiple Modules feature, cryptographic specification pages, customer supplied key pages, Encrypting fields and attachments, Set encrypted field configurations, Script access, mass job pages, the two walkthroughs. Most pages are the Field Encryption pages under the older product name; only the differences are recorded here. https://www.servicenow.com/docs/r/platform-security/column-level-encryption-landing.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Column Level Encryption (Legacy)

**In one line:** Column Level Encryption (CLE) and Column Level Encryption Enterprise (CLEE) are the previous names and packaging of what is now Field Encryption; the mechanism (module, encrypted field configuration, module access policy) is the same.

From the Brazil docs. Current product: [[Field Encryption - Modules, Encrypted Fields and Access]].

## Status

- Replaced by Field Encryption from **Yokohama**.
- From **Zurich**, CLE and CLEE are being prepared for deprecation: hidden and no longer activated on new instances, still supported on existing ones (deprecation process: KB0867184).
- Moving over: a CLE Starter customer installs Field Encryption Starter and the existing configuration is taken over, but **the entitlements differ**, so check them first. A CLEE customer needs a new entitlement for Field Encryption Enterprise through the account team; CLEE does not grant it automatically.

## What differs from the Field Encryption pages

| Topic | Column Level Encryption pages |
|---|---|
| Access model as described | role based: a role (directly or through a group) gives access to the module. A user without it does not see the field on a form and sees empty values in a list |
| Standard edition | AES-128 or AES-256; up to **5 modules and 5 access policies**; five encrypted fields; field types String, Date, Date/Time, URL **and attachments**; equality preserving supported, non-deterministic not |
| Enterprise adds | HTML, Journal and Translated field types; more modules and policies; scheduled automatic key rotation; customer-supplied keys; ephemeral keys; `setValue()` / `getValue()` support |
| Enterprise plugin | *Platform Encryption* (`com.glide.now.platform.encryption`). Activating it also activates Encryption Support (`com.glide.encryption`), sets `glide_encryption.set_value_support_cle.disabled` to false, and enables the `autoKeyMigration` and `autoDataMigration` jobs |
| Menus | **System Security > Field Encryption Modules**, **Encrypted Field Configurations**, **Key Management > Module Access Policies** (no *Field Encryption Experience* page) |
| Guided tour | from the help panel of `$pa_dashboards_overview.do` > **Take a Tour**; not available in Next Experience |

Note the difference on attachments: here they are listed for the standard edition, while Field Encryption Starter has no attachment encryption.

Everything else (module and specification forms, multiple modules, mass jobs, clones and key exchange, scripts, customer-supplied keys, the walkthroughs) reads the same as for Field Encryption.

## Related

- [[Field Encryption - Modules, Encrypted Fields and Access]] · [[Field Encryption - Mass Jobs, Clones, Archives and Migration]] · [[Key Management Framework (KMF)]] · [[Module Access Policies (MAPs)]]
