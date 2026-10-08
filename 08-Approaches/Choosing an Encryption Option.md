---
type: approach
tags: [approach, security, fields, instance-admin, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Encryption, all chapters (landing, Key Management Framework, Field Encryption, Column Level Encryption, Cloud Encryption, Full disk encryption, Edge Encryption, Database Encryption; each read in full 2026-10-08). The comparison and the recommendation are assembled by us from those chapters; the docs do not present this table. https://www.servicenow.com/docs/r/platform-security/encryption-landing.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Choosing an Encryption Option: ways to do it

**Problem:** "the data must be encrypted" can mean protecting disks, hiding a field from some logged-in users, or keeping the provider itself from reading the data. Each ServiceNow encryption product answers a different one of these.

Two questions sort them: **who must be kept from reading?** and **who holds the key?**

| Option | Encrypts | Protects against | Logged-in users see | Server logic can read | Key held by | Status |
|---|---|---|---|---|---|---|
| Full disk encryption | storage devices | loss or theft of disks | everything | yes | not stated (done by the storage hardware) | available |
| Database Encryption | whole database, in the engine | access to database files, backups, replication | everything | yes | ServiceNow; customer-controlled switch variant | being deprecated |
| Cloud Encryption | whole database, block level | same, with customer key operations | everything | yes | ServiceNow-managed or customer-managed (held by ServiceNow); withdrawal add-on | current |
| Field Encryption | chosen columns and attachments | logged-in users, scripts and processes without a module access policy | only what their policies allow | yes, with a policy | instance (KMF); Enterprise: customer-supplied or external AWS KMS | current |
| Edge Encryption | chosen fields and attachments, before they leave the customer network | the provider and anyone not on the customer's proxy | clear text only through the proxy | **no** | customer only | being deprecated |

## Options

### A. Infrastructure encryption at rest (Cloud Encryption; formerly Database Encryption or full disk)
- **How:** see [[Cloud Encryption with Key Management]], [[Database Encryption and Full Disk Encryption]]
- **Pros:** nothing changes for users, scripts, reports or integrations; covers everything including backups; key rotation and customer-managed keys; withdrawal as a last resort
- **Cons:** hides nothing from anyone who can log in; withdrawal stops the whole instance
- **Status:** documented
- **Best when:** the requirement is "data at rest must be encrypted" (regulation, contract)

### B. Field Encryption
- **How:** see [[Encrypt a Field with Field Encryption]]
- **Pros:** per-field, per-role control inside the instance; server logic keeps working when given a policy; no customer infrastructure; Starter is free for five fields
- **Cons:** encrypted fields lose audit history and activity stream entries; filtering needs equality-preserving encryption; not on `sys_` tables or catalog variables; clones need a key exchange; every script and integration touching the field needs a policy
- **Status:** documented
- **Best when:** a few sensitive fields (identifiers, bank details, case notes) must be hidden from most users and administrators

### C. Edge Encryption
- **How:** see [[Encrypt a Field with Edge Encryption]]
- **Pros:** the instance never holds clear text or keys; tokenization of patterns; order-preserving sorting
- **Cons:** proxies and possibly a database to run, size, secure and upgrade; server-side logic, email, reports, global search, import and archiving stop working on the field; being deprecated from Zurich
- **Status:** documented
- **Best when:** already in place, or a hard requirement that the provider must never be able to read the data; otherwise plan the migration to Field Encryption

## Recommendation

Our reading of the docs, not a statement from them:

- At-rest requirement: **Cloud Encryption** (option A). It combines with B.
- Hiding specific data from people inside the instance: **Field Encryption** (option B), Enterprise if more than five fields, attachments, or own keys are needed. Where the provider must not be able to decrypt, look at its external key management (AWS KMS) before considering Edge.
- **Do not start new work** on Edge Encryption, Column Level Encryption or Database Encryption: all three are on a deprecation path.
- None of these replaces access control: ACLs decide who reaches a record ([[Access Control Lists (ACLs)]]). For masking sensitive data in free text and AI prompts see [[Data Privacy Overview]].

Keys for options A and B are managed through [[Key Management Framework (KMF)]].
