---
type: how-to
tags: [how-to, data-management, integrations, instance-admin, release-specific]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage instance data sources > Instance Data Replication > Configure > Upgrading legacy replication sets to V2, Upgrade legacy replication sets, Rolling back an upgrade, Upgrading your instance with IDR enabled, read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/instance-data-replication-idr/upgrade-legacy-replication-sets.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Upgrade IDR Replication Sets to V2

**Goal:** move a **legacy** Instance Data Replication set (Kafka transport built before Utah; deprecated in **Zurich**) to a **V2** set on the Hermes Messaging Service, without losing replicated changes. Background: [[Instance Data Replication (IDR) Overview]].

From the Brazil docs; not tested. Role `admin`. V2 producers only talk to V2 consumers, so every subscribed consumer must be upgraded.

## Before you start

- Both instances on Utah or later. On the producer set, the **Consumer Subscriptions** related list has an **Upgrade Eligibility** column: every consumer must show **Eligible** (some Utah legacy sets are not eligible; the Utah docs list which).
- Replication keeps running during the upgrade; legacy and V2 topics are fed in parallel. V2 keeps messages 24 hours.

## Steps

1. **Producer**: open the legacy producer set, **Upgrade**, accept the default name (legacy name + `-V2`) or type another valid name, **OK**. A V2 producer set is created and metadata goes to the consumers.
2. **Consumer**: open the legacy consumer set, **Begin upgrade**. If the button is missing: on the producer open the **new V2** set, tick the consumer in Consumer Subscriptions, **Actions on selected rows > Resend Metadata**.
3. **Consumer**: when all entries arrive, **Start dry run** (reads from the Hermes topic without writing to the database; proves connectivity).
4. **Consumer**: **Finish upgrade** (checks the legacy and V2 topics are in sync; if a check fails the upgrade rolls back by itself) or **Finish upgrade without sync** (for lagging consumers or empty V2 topics; may skip or duplicate records, so run a data comparison afterwards). No Finish button: contact ServiceNow support. The V2 consumer set becomes active and the legacy consumer set is deactivated.
5. Repeat 2-4 for every consumer.
6. **Producer**: only after **all** consumers are on V2, open the legacy producer set, **Deactivate**, **OK** (legacy consumers stop consuming at that point). Upgrade status becomes **Up to date**; replication continues from the last message the legacy set processed.

## When it rolls back

- The consumer finds the latest legacy message but not the same one in the Hermes topic (processing delay): retry later.
- The legacy consumer job is still processing records from before the dual feed started: wait about 2 hours, or 24 hours, and retry.
- Nothing has been replicated to the Hermes topic yet: change at least one record on the producer so one message flows, then retry.
- Or use **Finish upgrade without sync** after the dry run.

## Instance upgrades (different thing)

During a ServiceNow family upgrade IDR stops its jobs, neither produces nor consumes, and resumes from the last message recorded in `data_replication_queue`. Running seeding pauses and resumes; new seeding cannot start during the upgrade, so finish seeding first. See [[Upgrades - Process, Upgrade Center and Upgrade Console]].

## Example

| Item | Value |
|---|---|
| Legacy producer set | `Example-Incident-Sync` |
| New V2 producer set | `Example-Incident-Sync-V2` (default suffix) |
| Consumers | two, both Eligible |
| Order | upgrade consumer 1 (dry run, Finish upgrade), consumer 2 (dry run, Finish upgrade without sync because it lagged, then a data comparison for the last day), then deactivate `Example-Incident-Sync` |

## Related

- [[Set Up Instance Data Replication]] · [[Instance Data Replication Errors and Statuses]] · [[Log Export Service (LES)]]
