---
type: concept
tags: [concept, security, instance-admin, data-management, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Encryption > Full disk encryption (1 topic, 18 cleaned lines) and Database Encryption (4 topics, 105 cleaned lines), both read in full 2026-10-08 through the docs site - Full disk encryption, Database Encryption, Exploring Database Encryption, Requesting database key rotation, Database Encryption with Customer Controlled Switch. The KB articles they cite were not read. https://www.servicenow.com/docs/r/platform-security/database-encryption-with-customer-controlled-switch/db-full-disk-encryption.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Database Encryption and Full Disk Encryption

**In one line:** two infrastructure-level ways of encrypting data at rest that ServiceNow operates for the customer: full disk encryption on the storage hardware, and Database Encryption inside the database engine; Database Encryption is on its way out in favour of Cloud Encryption.

From the Brazil docs. Replacement: [[Cloud Encryption with Key Management]]. Comparison of all options: [[Choosing an Encryption Option]]. In both cases the platform itself sees clear data, so neither restricts what a logged-in user can read.

## Full disk encryption (FDE)

- Encrypts the whole storage system of the database servers, the only component that stores customer data.
- Protects **only against loss or theft of the physical storage**. While the servers are running and serving data it adds nothing.
- Commercial environments use FDE on FIPS 140 validated hardware (or hardware in validation); a dedicated-hardware option exists at extra cost. Because it is on the hardware, it covers every instance assigned to the customer.
- Relevant mainly to heavily regulated organisations; can add significant cost. Arranged through the ServiceNow representative.

## Database Encryption (DBE)

**Status:** being prepared for deprecation since Washington DC. The variant with a customer-controlled switch reached end of sale and end of renewal as of Yokohama.

- AES-256, performed by the database engine: data is encrypted when written to disk and decrypted in memory when read. Also covers the bin, redo, undo and error logs, replication traffic and backups.
- Transparent to users; cloning still works; performance cost up to 5%.
- Not available for self-hosted instances. A paid infrastructure offering, independent of the release.

Key hierarchy, managed by ServiceNow:

1. a customer-specific AES-256 key created by the database engine encrypts the data;
2. a second customer-specific key protects the first;
3. a third key, unique per instance and kept in FIPS 140 validated key management appliances in the data centres, protects the second.

### Key rotation

Requested from support (role `admin` to ask): enrol for annual rotation, order an early rotation, or get a report of the last three rotations (instance, key name and version, dates). Rotation happens at night within the 24 hours before expiry, without interruption. Only in the Commercial, Government Community Cloud, France and Singapore environments.

### Customer-controlled switch (DBE-CCS)

- Uses the database's native tablespace encryption (MariaDB).
- The customer runs an **HTTPS REST endpoint** that periodically hands the secret key to the instance, encrypted with the database instance's public key. Presumably the "switch" is that the customer can stop supplying the key (my reading; the page does not spell out what happens then).
- Building and running the endpoint is entirely the customer's responsibility (specification: KB0789788; architecture: KB0993681). The docs name Fortanix as a partner who can provide it.

## Related

- [[Cloud Encryption with Key Management]] · [[Choosing an Encryption Option]] · [[Key Management Framework (KMF)]] · [[Security Center Scan Checks and Best Practices]]
