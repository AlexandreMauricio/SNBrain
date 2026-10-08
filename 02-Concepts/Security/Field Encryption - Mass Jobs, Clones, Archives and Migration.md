---
type: concept
tags: [concept, security, data-management, instance-admin, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Encryption > Field Encryption (chapter read in full 2026-10-08) - Schedule mass encryption, decryption, and rekeying jobs, Run mass encryption or decryption, Field Encryption and system clones, Cloning considerations (Exploring Field Encryption), Archive tables and Field Encryption, Migrating to Field Encryption, Field Encryption migration status page, Migrate from Edge Encryption to Field Encryption, Configure Field Encryption for your Edge Encrypted fields. https://www.servicenow.com/docs/r/platform-security/schedule-mass-jobs.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Field Encryption - Mass Jobs, Clones, Archives and Migration

**In one line:** activating an encrypted field only affects new values; existing data, rotated keys, cloned instances, archived records and data from older encryption products each need a job or a deliberate setup.

From the Brazil docs. The feature itself: [[Field Encryption - Modules, Encrypted Fields and Access]].

## Security jobs

**All > System Security > Security Jobs > New** (role `sn_kmf.cryptographic_manager`; also listed under **High Security Settings > Security Jobs**). Table `sys_mass_encryption_job`.

| Type | Does |
|---|---|
| **Mass Encryption** | encrypts the values already in the column of a configuration |
| **Mass Encryption Attachment** | encrypts all attachments of the records of one table |
| **Mass Decryption Module** / **Mass Decryption Multi Module** | decrypts existing values of a single-module / multiple-module configuration |
| **Mass Decryption Attachment** | decrypts all attachments of one table |
| **Mass Rekeying** | re-encrypts existing values with the module's current active key |
| **Key Migration Context to Module** | turns legacy encryption context keys into module keys and creates the access policies |
| **Data Migration Context to Module** | re-encrypts context-encrypted data with the module key |
| **Migrate Attachment Context to Module** | the same for attachments |

- Fields: **Name**, **Type**, **Table**, **Field**, **Time window start** / **end** (24-hour), **State** (starts New), **Summary**. A job that does not finish in the window continues in the next one.
- Buttons: **Start** (now), **Cancel Job**, **Update**, **Delete**.
- Shortcut: on an encrypted field configuration, related links **Schedule Mass Encryption job** / **Schedule Mass Decryption job** (role `security_admin`).
- Mass **encryption** needs a single-module configuration; mass decryption exists for both methods and only decrypts what the user running it has module access to.
- Heavy on the instance: run off-peak.

Typical uses named in the docs: *Mass Encryption* after activating a configuration on a column that already holds data or after adding a row condition; *Mass Rekeying* after changing a row condition or to bring a cloned instance down to a single key.

## Clones

- The clone copies the encrypted values and the modules. The keys arrive wrapped by a key unique to the source, so **encrypted fields on the target look empty or unreadable until a key exchange completes**. This is expected, not data loss. See [[KMF Key Exchange and Key Import]].
- During the clone the target also generates a **new** key for each module the user has access to that has none. A module on the target can therefore hold two keys: a new *active* one for new data, and a *deactivated* one from the automatic key exchange that still decrypts the cloned data.
- To end up with a single key, run a *Mass Rekeying* job on the target.

## Archive tables

Archive tables are named `ar_` plus the table name (`ar_incident`). See [[System Archive and Archive Rules]].

- Put encrypted field configurations **on the base table only**. Archived values travel as cipher text.
- With no configuration on the archive table, nobody sees clear text there: users without key access see an empty field, users with key access see cipher text. To read archived values in clear, restore the records to the base table.
- Since Brazil a migration may **auto-create an inactive configuration on an archive table** when it finds legacy data there. Leave it inactive; a user with `admin` and `security_admin` may activate it briefly to read historical data, then deactivate it. Active configurations on both base and archive table mean two gates and are discouraged.
- Access policies belong to the module, not the table, so they apply to both.
- The page's closing "access control" list says users with a policy granting key access can decrypt in archive tables, which contradicts the scenario description above unless a configuration is active on the archive table (my reading).

## From encryption contexts (Encryption Support)

Installing Field Encryption starts the migration by itself, through two scheduled jobs:

| Job | Does |
|---|---|
| `autoKeyMigration` | context keys become KMF module keys |
| `autoDataMigration` | already-encrypted data is re-encrypted with the module key |

- They can be rescheduled, paused and restarted. Afterwards context keys only decrypt; all new encryption uses module keys.
- Check under **Encrypted Field Configurations**: **Method** is Single Module and **Crypto module** names the module the system created (it and its access policy are active and published).
- The *Field Encryption Migration* status page shows three cards, one per step, each with a status, a description and a link to the job record.

## From Edge Encryption

Outline: configure Field Encryption for each edge-encrypted column and attachment, migrate, stop and disable the proxy servers, de-tokenize, decrypt catalog item variables.

- Per field: a published module with parent `column_level_encryption` and a generated key; a single-module configuration on the same table and column; a role policy for a role that must encrypt and decrypt. The field then shows the lock icon.
- Field Encryption has no tokenization like Edge Encryption (tokenized data must go into an encrypted field configuration) and cannot encrypt Service Catalog item variables.

Edge Encryption itself: [[Edge Encryption Overview]].

## Related

- [[Field Encryption - Modules, Encrypted Fields and Access]] · [[KMF Key Exchange and Key Import]] · [[Instance Clone Overview]] · [[System Archive and Archive Rules]] · [[Column Level Encryption (Legacy)]] · [[Encrypted Field Shows Empty or Unreadable]]
