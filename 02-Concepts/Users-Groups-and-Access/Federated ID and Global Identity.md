---
type: concept
tags: [concept, users, roles, instance-admin, fields, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Identity (chapter read in full 2026-10-08) - Identity (landing), Global Identity, Exploring Federated ID, Configuring Federated ID Criteria, Updating ID fields. https://www.servicenow.com/docs/r/platform-security/identity/federated-id.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Federated ID and Global Identity

**In one line:** every user record gets a **Federated ID**, a hash computed from chosen fields (by default **User ID** and **Email**), so that the same person can be recognised across a customer's instances and counted once, which matters for licensing.

From the Brazil docs. User records: [[Users, Groups and Roles Overview]]. Subscription counting: [[Subscription Management]].

## How it works

- Plugin *Federated ID Generation* (`com.glide.identity.globalid`), installed automatically on all instances. It adds column **Federated ID** (`federated_id`) to User (`sys_user`) and a configuration table `iamsync_type` with a default row for `sys_user`. A criteria record exists for Role as well as User.
- The value is a hash of the configured **ID Fields**. Same field values on two instances give the same Federated ID.
- *Global Identity* is described as the store application that uses this to resolve users across instances and consolidate their attributes; the pages document only the Federated ID part.

## Rules for the ID fields

- At least **one unique field** is required; several are allowed. **User ID** (`user_name`) is no longer mandatory, though it qualifies.
- A field counts as unique only if uniqueness is enforced on that single column: marked unique in the dictionary, or a single-column unique database index. A non-unique index, or uniqueness only as part of a multi-column index, does not count.
- Secondary, non-unique fields (such as Email) can be added or removed freely but never satisfy the requirement alone.
- A record gets a Federated ID only if at least one of its selected unique fields has a value; otherwise the ID is null.
- If two users share the same values in all selected fields, only one of them gets an ID.
- Not selectable: system fields, Edge-encrypted fields, password fields. Fields should be of string type.
- Saving criteria without a unique field is blocked ("At least one unique field is required for Federated Id generation"); a generation run without one is skipped, not failed.

## Changing or regenerating

**All > Manage Federated ID > Federated ID Criteria** (role `iamsync_admin`): the record shows **Type Name**, **Table Name**, **ID Fields** and **Status** (Ready, Running, Completed, Error).

| Button | When |
|---|---|
| **Update** | after moving fields in or out of *Selected*: recalculates with the new criteria |
| **Regenerate Federated IDs** | same criteria, fresh calculation: after XML imports, low-level data fixes or a misbehaving instance |

- **Changing any ID field changes the Federated ID of every user.** Anything downstream that stored the old values breaks, and there can be performance, compliance and licensing consequences.
- Wait for the completion percentage to reach 100 before another run.

## Related

- [[Users, Groups and Roles Overview]] · [[Identity Center]] · [[Identity and Access Audit]] · [[Subscription Management]]
