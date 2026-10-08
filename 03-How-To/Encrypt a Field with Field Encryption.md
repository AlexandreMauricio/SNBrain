---
type: how-to
tags: [how-to, security, fields, access-control, roles, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Encryption > Field Encryption (chapter read in full 2026-10-08) - Role requirements, Create cryptographic module for Field Encryption, Cryptographic specifications for Field Encryption, Configure encrypted field configurations, Configure module access policies, Schedule mass encryption jobs, Field Encryption Enterprise examples (walkthrough). https://www.servicenow.com/docs/r/platform-security/configure-fe-fields-attachments.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Encrypt a Field with Field Encryption

**Goal:** store one column encrypted and let only one role read and write it.
**Prerequisites:** Field Encryption (Starter covers five fields) installed; `admin` able to elevate to `security_admin`; `sn_kmf.cryptographic_manager` or `sn_kmf.admin`. The column is of a supported type and not on a `sys_` table.
**Navigation:** All > System Security > Field Encryption > Field Encryption Experience

Background: [[Field Encryption - Modules, Encrypted Fields and Access]].

## Steps

1. Switch to the application scope of the table. Elevate to `security_admin`.
2. **Create new module**: a name and the algorithm (AES 256 CBC by default), **Create**, **Submit**.
3. On the module, **View module details** > **Manage Specification Settings**: step through with **Next** to *Key Creation* and select **Generate Key** (otherwise a key is generated on first use). Tick **Equality preserving** on the algorithm step if the column must stay filterable by exact value.
4. **Access Policies** on the module tile: **Policy Name**, **Type** = Role, **Target Role**, **Result** = Track, **Active**, **Submit**. Add policies for any script or system process that reads or writes the field.
5. **Encrypted Fields** on the module tile > **Configure**: **Type** = Column, the **Table** and **Column**, **Method** = Single Module. Leave **Active** off until the policies are in place, then tick it and **Save**.
6. If the column already holds data: **System Security > Security Jobs > New**, **Type** = Mass Encryption, the table and field, a time window off-peak, **Submit** (or the related link **Schedule Mass Encryption job** on the configuration).

## Result / how to check it worked

The field label shows a lock icon. A user with the role sees and edits the value; a user without it sees an empty field in the form and the list. `Diagnostics > Session Debug > Debug Module Access Policies` shows which policy decided.

## Example

On *Example Requests* (`u_example_request`) the column **Bank reference** (`u_bank_reference`) must be visible only to the finance team. Module `example_finance` (stored as `global.example_finance`), AES 256 CBC, key generated. Policy *Example finance readers*: role `u_example_finance`, Track. Configuration: Column, `u_example_request`, `u_bank_reference`, Single Module, active. A Mass Encryption job encrypts the 300 existing values overnight. *Test User* (no finance role) now sees the column empty; a member of *Example Group*, which carries the role, sees the values.

## Tables / fields involved

- `sys_kmf_crypto_module`, `sys_kmf_module_key`, `sys_kmf_crypto_caller_policy`
- the encrypted field configuration record (table name not given on these pages: ?)
- `sys_mass_encryption_job`

## Gotchas

- Activating the configuration **before** the policies locks everyone out, integrations and business rules included.
- Existing values are not encrypted until the mass job runs.
- The field's changes are no longer audited or shown in the activity stream.
- After a clone the target cannot read the values until the key exchange has run ([[Field Encryption - Mass Jobs, Clones, Archives and Migration]]).
- Without **Equality preserving**, filters such as "is" on the column stop matching.
- A module cannot be deleted.
- Attachments need the Enterprise edition and one configuration per table (child tables are not covered by the parent's).
