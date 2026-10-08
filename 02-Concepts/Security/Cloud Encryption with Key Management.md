---
type: concept
tags: [concept, security, instance-admin, data-management, roles, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Encryption > Cloud Encryption with Key Management (whole chapter, 10 topics, 713 cleaned lines, read in full 2026-10-08 through the docs site) - Cloud Encryption with Key Management, Key management operations (rotate, prepare, switch, schedule, withdraw, resupply), Quorum Control Policy, Configure Quorum Control Policy Settings, Manage Quorum Control, approve or deny pages, Key management transactions, Cloud Encryption logging, Tamper Detection. https://www.servicenow.com/docs/r/platform-security/cloud-encryption/dare-overview.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Cloud Encryption with Key Management

**In one line:** Cloud Encryption encrypts the instance's whole database at the storage block level and lets the customer rotate the key, supply their own key, and (with an add-on) withdraw it, which shuts the instance down until the key is given back.

From the Brazil docs. Part of the Platform Encryption bundle. It protects data at rest; it does not hide anything from logged-in users (that is [[Field Encryption - Modules, Encrypted Fields and Access]]). Predecessors: [[Database Encryption and Full Disk Encryption]]. Choosing between the options: [[Choosing an Encryption Option]].

## Availability

- MariaDB and RaptorDB databases, production and non-production.
- ServiceNow Commercial Cloud, Government Customer Cloud pod 101, ServiceNow Protected Platform Australia.
- New instances of licensed customers come with it. Existing instances: request the catalog item *Enable Cloud Encryption* on Now Support (KB1117369; customer admin or partner admin there); needs a **one-hour maintenance window**.
- The menu **Cloud Encryption Key Management** is visible to a `security_admin` user who also has `sn_kmf.admin`. Most operations: `sn_kmf.admin` or `sn_kmf.cryptographic_manager`.

## Keys

- Exactly **one active key** at a time. The default is a ServiceNow-managed key.
- **Customer-managed key**: your key material, but held on ServiceNow infrastructure; you perform the operations (bring your own key, rotate, withdraw). It is not hosted on your side.
- **Key Management Operations** lists every key (table Cloud Encryption Metadata, `dare_key_metadata`): alias, life-cycle state, origin, version. Entries appear after the first rotation.

| Operation | How |
|---|---|
| Rotate a ServiceNow-managed key | open the active key > **Rotate Key** > OK. Old key becomes *Rotated*, new key *Active* with the next version. Up to 20 minutes |
| Switch to a customer-managed key | active key > related link **Switch To Customer Managed Key** > **Upload Managed Key** > **Download Wrapping Certificate**, upload the wrapped key, confirm. The new key has origin `customer_supplied` |
| Rotate a customer-managed key | active key > **Rotate Key** > download a fresh wrapping certificate, upload the new wrapped key |
| Switch back | related link **Switch To ServiceNow Managed Key** |
| Schedule rotation | **Scheduled Key Rotation Settings** (`sn_kmf.admin`): enable, months between rotations (default 12, maximum 60), weekday and time, reminder days before (maximum 15), recipients. For customer-managed keys it only reminds |

### Preparing your own key

- AES, 256 bit (32 bytes), from any library or HSM.
- Wrapped with the public key of the downloaded wrapping certificate using RSAES_OAEP_SHA_256, then Base64 encoded. OpenSSL 1.1.1 or later; on Windows use a Bash shell such as Git Bash.
- **Download a new wrapping certificate for every rotation or switch.**
- Keep your own copy of the key safe: without it the instance can become inaccessible.

The scheduled rotation job carries a signature unique to the instance; after a clone it fails validation on the target. Untick and re-tick **Enable scheduled key rotation** to re-create it (KB1247113).

## Withdraw and resupply (add-on)

Needs the *Cloud Encryption Withdraw and Resupply* SKU, a signed legal addendum, activation by support, and a customer-managed key.

- **Withdraw Key** on the active key deletes it from the HSM and **shuts the instance down**.
- Restore is only possible with **the same key**; rotate afterwards if you want another.
- If the key is not resupplied within the backup retention period, the database backups become unreadable for good.
- Resupply: on Now Support, catalog item **Instance Restore - Resupply Managed Key**: choose the instance, download the wrapping certificate, wrap and upload the key, **Rotate key**.

### Quorum control

**Quorum Control Policy Settings** (visible only when withdrawal is activated; `sn_kmf.admin`): **Quorum control enabled**, **Approvers** (any number), **Minimum number of approvers** (at least two), expiry of requests in hours.

- A withdrawal then starts an approval workflow: email and tasks to all approvers; approve from the email, **My Approvals**, or **Key Management Transactions > Quorum Control Approvers**.
- Request state Open or Closed Complete; approval Requested, Approved (key withdrawn, instance shut down) or Denied (start again). The requester is emailed the outcome.
- **Tamper detection**: each quorum setting (`dare_property`) carries an HMAC, checked daily by a job and before every withdrawal. A failure blocks withdrawal, shows a warning on the settings page, logs `HMAC_VALIDATION_FAILED` with the record's sys_id in the node and security logs, and notifies security and KMF admins. Only support can clear it.

## Following a request

**Key Management Transactions** (`dare_key_request`): every operation is one **Request ID** with numbered steps.

- Step 0 carries the overall **Request status**: Processing, Completed or Failed. One failed step fails the whole request.
- Rotation steps: `request_preparation`, `request_integrity_check`, `request_validation` (one rotation at a time), `attachment_process` (customer key only), `hsm_<key type>_upload`, `key_metadata_rotate`, `post_rotate_request`, `post_rotate_response`.
- Withdrawal steps: quorum request, then preparation, integrity check, validation, `hsm_key_delete`, `key_metadata_withdraw` (state becomes destroyed), `post_withdraw` (shuts the instance down).
- For a failure, give support the request ID and the step.

Changes to `dare_key_metadata` are audited in `sys_audit` (who, when, old and new value): [[Auditing and Record History]].

## Related

- [[Key Management Framework (KMF)]] · [[Database Encryption and Full Disk Encryption]] · [[Field Encryption - Modules, Encrypted Fields and Access]] · [[Choosing an Encryption Option]] · [[ServiceNow Vault and Otto for Vault]]
