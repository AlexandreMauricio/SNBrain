---
type: how-to
tags: [how-to, data-management, integrations, admin]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage instance data sources > Instance Data Replication > Replicate data (Set up continuous, bidirectional, discrete and scheduled replication; Cancel scheduled replication; Seed a consumer instance; Modifying replication behavior; Transform replication data; Reconfigure a replication set), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/instance-data-replication-idr/replicating-data.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Set Up Instance Data Replication

**Goal:** replicate chosen tables from a producer instance to a consumer instance. Concepts, modes and limits: [[Instance Data Replication (IDR) Overview]]. Fields and properties: [[Instance Data Replication Reference]].

From the Brazil docs; not tested. Needs the IDR subscription (plugin `com.glide.idr`, activated by ServiceNow). Role `idr_admin` or `admin` on both instances (the bidirectional page says `admin`). Both instances must belong to the same customer.

## Steps

### On the producer

1. **Instance Data Replication > Producer Replication Sets > New**: name (letters, digits and hyphens only; not producer-specific, because the consumer types the same name) and description.
2. Mode options: tick **Bi-Directional**, **Discrete** or **Scheduled** (then a **Schedule Interval** and a start date and time; **Next Schedule Run** is calculated). Leave all unticked for continuous. Optional **Entry set** to reuse outbound entries from an imported update set.
3. **Outbound Entries > New**, one per table:
   - **Source Table Name**.
   - **Filter**, for example Active is true. To keep a parent/child hierarchy add a **Task type** (`sys_class_name`) filter on each entry (Task type is Task on the `task` entry, Task type is Incident on the `incident` entry) and add an entry per child table.
   - **Include Attachments**, **Included Fields** (`sys_id` is always included; encrypted and password fields are not offered).
   - Optional **Enable Custom Coalesce** + **Coalesce Field** (only unique fields).
   - Discrete sets also have a **Discrete Field** (a reference field), then on the **Discrete Mappings** tab one row per consumer subscription: **Discrete Value**, **Outbound Replication Entry**, **Replication Subscription**.
   - Scheduled sets: only one outbound entry; put child tables in separate non-scheduled sets.
4. **Activate** the producer set.

### On the consumer

5. **Instance Data Replication > Consumer Replication Sets > New**: **Producer Instance URL** (`https://<producer_instance>.service-now.com`), **Producer Replication Set Name** (identical), description. Submitting sends an approval request.

### Back on the producer

6. Open the set, **Consumer Subscriptions**, select the consumer, **Actions on selected rows > Approve**. A cross-region consumer shows a data-transfer warning.

### On the consumer again

7. Open the consumer set and **Activate**. Status becomes **Active Replication** and the **Full Seeding** / **Partial Seeding** buttons appear (not on bidirectional or discrete sets).
8. Bidirectional only: **Synchronize Replication Entries** (refresh the page if missing) and confirm.
9. Optional per inbound entry: **Run Business Rule** (business rules on the target table run as `idr.system`), **Preserve Modified By** (keeps the producer's user, shown with an IDR prefix in activity entries; otherwise "Instance Data Replication" appears), **Enable Transform** with a **Target Table Name** and a transform map (unlock the lock icon, map source to target fields, **Add Adapter**).
10. Seed if you need existing records: select inbound entries, **Full Seeding**, or **Partial Seeding > Configure Seeding** (custom filter, Include Attachments, Include History, fields) **> Save Configuration > Request Partial Seeding**. Errors can be retried per table (up to 10,000 errors; above that do a full seeding).

### Changing it later

- Producer changes (tables or columns added or removed) put consumers in **Replication Error** with "Producer Replication Set configuration has been modified": on each consumer **Synchronize Replication Entries**, then **Activate**. Make sure no seeding is running first.
- **Generate New Shared Key** only when the key is compromised or to cut off a consumer; denied consumers must request access again (**Request shared key**).
- Scheduled replication cannot be unticked: **Deactivate** (stops before the next run; in-progress seeding completes) or delete and recreate. Afterwards a data comparison can sync what was missed.

## Example

| Item | Value |
|---|---|
| Producer instance | `https://<producer_instance>.service-now.com` |
| Consumer instance | `https://<consumer_instance>.service-now.com` |
| Replication set name (both sides) | `Example-Incident-Sync` |
| Outbound entry 1 | **Task** (`task`), filter Task type is Task, Active is true |
| Outbound entry 2 | **Incident** (`incident`), filter Task type is Incident, Active is true, Include Attachments ticked |
| Consumer inbound options | Run Business Rule ticked (to send an Example Replication Notification), Preserve Modified By ticked |
| Seeding | Partial: Created on or after a chosen date |

Remember to also replicate the referenced users and groups (or make sure they exist with the same `sys_id`), otherwise **Caller** (`caller_id`) and **Assignment group** (`assignment_group`) arrive empty.

## Related

- [[Instance Data Replication (IDR) Overview]] · [[Instance Data Replication Reference]] · [[Instance Data Replication Errors and Statuses]] · [[Upgrade IDR Replication Sets to V2]]
