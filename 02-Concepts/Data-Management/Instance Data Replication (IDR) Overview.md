---
type: concept
tags: [concept, data-management, integrations, release-specific]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage instance data sources > Instance Data Replication (whole chapter, about 3,050 cleaned lines, read 2026-10-29) - Explore (continuous, bidirectional, discrete, scheduled), Configure (subscription, preparing, table hierarchy, upgrading legacy sets to V2, instance upgrades), Replicate data, Administer, Reference. https://www.servicenow.com/docs/r/servicenow-platform/instance-data-replication-idr/instance-data-replication.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Instance Data Replication (IDR) Overview

**In one line:** a separately licensed plugin (`com.glide.idr`) that copies record inserts and updates from a **producer** instance to one or more **consumer** instances, near real time or on a schedule, optionally back again, filtered per consumer and transformed on the way.

From the Brazil docs; not tested. Set-up steps: [[Set Up Instance Data Replication]]. Tables, adapters, properties, roles: [[Instance Data Replication Reference]]. Errors: [[Instance Data Replication Errors and Statuses]].

## What it is for and not for

- For: keeping chosen tables consistent across instances of the same company, between business units, or with another company's instance.
- **Not a clone**: metadata and most system tables cannot be replicated (business rules `sys_script`, catalogs `sc_catalog`, workflows `wf_workflow`...). For copying instances use [[Instance Clone Overview]].
- Avoid **continuous** replication of CMDB tables (volume); use scheduled replication with filters if you must.
- Avoid regular large attachments (over 10 MB) and watch the lag if you do.
- Cannot replicate Edge Encrypted, Field Encryption or Password (2-way) fields.
- Archiving is not synchronised: each instance needs its own archive rules ([[System Archive and Archive Rules]]).
- Limits: record max **10 MB**; continuous replication about **1 million records a day**; seeding must finish within **7 days**; only **one scheduled replication set**, with one outbound entry.
- Runs only in ServiceNow data centres (no on-premises instances). Producer and consumer should belong to the same customer, ideally in the same region (lower latency); cross-region approval raises a data-transfer warning.

## Pieces

| Piece | Where | Meaning |
|---|---|---|
| **Producer replication set** | producer: **Instance Data Replication > Producer Replication Sets** | name (letters, digits, hyphens; same name on the consumer), options Bi-Directional, Discrete, Scheduled, optional **Entry set**; an auto-generated producer ID |
| **Outbound entry** | producer set | source table, filter, include attachments, **included fields** (`sys_id` always), optional **custom coalesce** field, optional transform and adapters |
| **Consumer replication set** | consumer: **Consumer Replication Sets** | producer instance URL + producer set name; requests approval |
| **Inbound entry** | consumer set | target table, **Run Business Rule**, **Preserve Modified By**, transform |
| **Consumer subscription** | producer set related list | approve, deny, revoke; upgrade eligibility |
| **Entry set** (`idr_entry_set`) and **replication entries** (`idr_replication_entry`) | either | instance-independent definition, captured by **Track in Update Set** |
| **Shared key** | producer | encryption key handed to approved consumers (uses [[Key Management Framework (KMF)]]) |

Jobs: **IDRProducerJob** on the producer detects changes, **IDRConsumerJob** on consumers applies them (plus `IDRDeltaConsumerJob-<instanceid>` when the producer is in another data centre). Replicated writes are done by the user **`idr.system`**, so its roles, ACLs, data policies and business rules on the consumer matter.

## Replication modes

| Mode | Behaviour | Notes |
|---|---|---|
| **Continuous** | inserts and updates flow one way in near real time | default |
| **Bidirectional** | each side replicates back; the system creates a read-only reverse set named `<set>-<number>-reverse` | no automatic conflict resolution (last update wins); only the **Number** (task number) adapter; **no seeding**; an update made by a business rule after a replicated insert is not sent back. Use two one-way sets if you need adapters or seeding in both directions |
| **Discrete** | per consumer, a **discrete field** (a reference field, e.g. company or assigned to) with a **discrete value** per subscription decides which records each consumer gets | every subscribed consumer needs a discrete value; with bidirectional, the consumer's discrete value overwrites what the consumer record had; no seeding |
| **Scheduled** | historical changes sent at an interval each day from a start date; continuous until the first run | cannot be switched off once set (deactivate or delete the set) |

**Seeding** copies existing records: **full** or **partial** (custom filter, attachments, history, fields). One request at a time per producer; existing consumer records with the same `sys_id` (or coalesce value) are overwritten. Max 3 million records per seeding request on this page, while the status messages page mentions a default limit of 10 million and the properties page a property `idr.max.seeding.limit` that is unlimited by default on V2 sets: unconfirmed which applies.

## Planning rules worth remembering

- The producer is the source of truth; consumer target tables should be empty, or records must share `sys_id`s, or use a **custom coalesce** field (unique in `sys_dictionary`, same name, type and length on the consumer; changing it means recreating the entry). Otherwise duplicates appear (for example users imported by LDAP on both sides).
- Do not replicate `sys_` tables such as `sys_user` into a consumer that already has data; exclude auto-updated `sys_` columns (they inflate message counts, which count against the subscription).
- Include referenced tables, or references arrive empty.
- **Table hierarchy**: (1) one outbound entry per child table, each with a `sys_class_name` filter, keeps child columns; (2) parent only with **Class Name** included keeps the class but not child columns; (3) parent only without Class Name turns everything into parent records. Missing `sys_class_name` filters on a parent with child entries cause insert and update failures (sets created before a certain release).
- One set per table (independent pausing, parallel, clearer errors) versus one set per group of up to five related tables (simpler, but one error stops all).

## Transport and versions

V2 replication sets use the **Hermes** messaging service (Kafka) ([[Log Export Service (LES)]] uses it too); producer messages are kept **24 hours**. **Legacy** sets (pre-Utah Kafka implementation) are **deprecated in Zurich** and must be upgraded: [[Upgrade IDR Replication Sets to V2]]. During an instance upgrade IDR pauses itself and resumes from the last message (`data_replication_queue`); seeding pauses too and new seeding cannot start.

Domain separation: **not explicitly supported** (IDR works at data level; filter by domain in the set if needed). Roles: `idr_admin`, `idr_read`, `idr_rest`.

## Access, comparison, deployment and cloning

- **Access**: consumers request access; approve from **Instance Data Replication > Consumers Pending Approval** or the set's **Consumer Subscriptions**; setting **Consumer Approval Status** to Denied stops a consumer. **Revoke** generates a new shared key sent only to approved consumers; others stop. A revoked consumer uses **Request Shared Key**, then **Synchronize Replication Entries** and activates its inbound entries.
- **Data comparison** (producer set > **IDR Data Comparison Requests > New**: replication set, target instance name and URL, table, start and end on `sys_updated_on`, **Auto Seed**): pie chart of missing and mismatched records, **Compare records** shows differences, then **Reseed** (All or Mismatched). Needs an active set, no seeding and no other comparison running. Journal fields and **Sys Audit** (`sys_audit`) are excluded; fields changed by adapters (except task number) and mapped fields with different definitions are skipped. Full support from Washington DC on both sides (Vancouver partial, Utah none). Requests are purged after three months, but results and logs after five days (two different retention statements, unconfirmed).
- **Deploying configuration**: **Track in Update Set** is the only supported way; it captures the **Entry Set** (`idr_entry_set`, no producer ID) and **Replication Entries** (`idr_replication_entry`). On the target, accept remote updates for `sys_record_transform` preview errors, commit, then activate the generated producer set, subscribe the generated consumer set, or create a bidirectional / discrete producer set from the imported entry set ([[Update Sets]]).
- **Cloning**: a clone copies IDR configuration with the data. Three use cases need different preserve and exclude lists in the clone profile: **recurring clone** (keep the target's own IDR configuration), **true clone** (target inherits everything; re-create sets from cloned entry sets and resubscribe consumers), **migration clone** (capture the target's sets with Track in Update Set, true clone, re-import and re-create). The exact table lists are on the docs page. See [[Instance Clone Overview]].

## Related

- [[Set Up Instance Data Replication]] · [[Instance Data Replication Reference]] · [[Instance Data Replication Errors and Statuses]] · [[Instance Clone Overview]]
