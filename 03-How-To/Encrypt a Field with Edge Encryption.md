---
type: how-to
tags: [how-to, security, fields, integrations, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Encryption > Edge Encryption (chapter read in full 2026-10-08) - Configure encryption keys on the instance, Create a field encryption configuration, Schedule an encryption job, Authenticate an Edge Encryption proxy server, Edge Encryption limitations. https://www.servicenow.com/docs/r/platform-security/edge-encryption/c_ConfigureCloudEdge.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Encrypt a Field with Edge Encryption

**Goal:** have one field stored as cipher text on the instance, readable only by users who connect through the company's Edge Encryption proxy.
**Prerequisites:** Edge Encryption plugin active; at least one proxy installed, running and authenticated ([[Edge Encryption Proxy - Installation, Keystores and Upgrades]]); role `security_admin`, **logged in through the proxy URL**. Edge Encryption is being deprecated: for new work prefer [[Encrypt a Field with Field Encryption]].
**Navigation:** All > Edge Encryption Configuration

Background: [[Edge Encryption Overview]], [[Edge Encryption Configuration - Keys, Jobs, Patterns and Integrations]].

## Steps

1. **Check the field.** A supported type (string, date, date/time, email, IP address, journal, URL), not on a system table, final length decided. List the scripts, reports, filters and integrations that read it: they will see cipher text.
2. **Key.** **Encryption Key Configuration > Set Up Keys**: add the alias exactly as it exists on the proxies, size and type; wait for *Available*; set it as default.
3. **Configuration.** **Encryption Configurations > Create New**: **Table**, **Type** = Column, **Column**, **Encryption type** (Standard if nobody filters on it; Equality preserving to filter by exact value; Order preserving to sort, which needs the proxy database). **Submit**.
4. **Existing data.** Open the configuration > related link **Schedule Mass Encryption Job**: **Estimate Record Count**, tick **Process Historical Records** if the field is audited, set **Starting** to a quiet time (or **Execute Now**).
5. **Other entry points.** For record producers use **Create Edge Encryption Rule** on the producer and activate the rule; point MID Servers and integrations at the proxy URL.

## Result / how to check it worked

Through the proxy URL the field shows clear text. Through the instance URL directly the same record shows cipher text, and trying to save a value there is rejected and listed under **Invalid Insert Attempts**.

## Example

*Example Company* encrypts **Bank reference** (`u_bank_reference`) on *Example Requests* (`u_example_request`). Key alias `examplekey128` (128 bit, type Keystore) is Available and default. Configuration: Column, Equality preserving AES 128, so agents can still filter "Bank reference is ...". A mass encryption job scheduled for Saturday night converts the 12,000 existing values. *Test User*, connected through `https://edge.example.com`, sees the value; opened directly on `<instance>.service-now.com` it is unreadable.

## Tables / fields involved

- `sys_encryption_configuration` (configuration), `sys_encryption_key`, `sys_encryption_key_configuration` (keys), `sysauto_encryption_job` (jobs), `sys_edge_encryption_invalid_insert_log`

## Gotchas

- The configuration can never be deleted, only deactivated (then run a decryption job).
- Business rules, flows and other server logic cannot read the value; outbound email shows cipher text; the field cannot be used in reports, global search, imports or archiving.
- A parent-table field encrypts the same field on every child table.
- Without the encryption job, old values stay in clear until they are next changed.
- After changing the default key, run a key rotation or filters and sorts split by key.
- Losing the key, or for tokens the proxy database, loses the data: back both up.
