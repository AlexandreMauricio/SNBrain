---
type: troubleshooting
tags: [troubleshooting, data-management, integrations]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage instance data sources > Instance Data Replication > Administer (Monitoring replication status, Monitoring queues, Avoiding errors, Resolving errors, Run diagnostics, Review synchronization errors, Discover replication delays, Fix seeding errors, Identify errors, Configure notifications, Consumer replication set status, XML stats, Comparing replicated data, Manage consumer access) and Warning and error messages, read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/instance-data-replication-idr/common-issues-idr.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Instance Data Replication Errors and Statuses

From the Brazil docs; not tested. Background: [[Instance Data Replication (IDR) Overview]]; set-up: [[Set Up Instance Data Replication]].

## Checklist when nothing replicates

1. **Diagnostics** (**All > Instance Data Replication > Diagnostics**, `admin` or `idr_admin`; REST diagnostics need `idr_rest`). Runs automatically: **Key Management Framework** (valid certificates in `sys_certificate`, the EJBCA PKI service), **IDR Scheduled Jobs** (duplicates or missing jobs in **Scheduled Job** `sysauto` and **Schedule Item** `sys_trigger`), **Hermes** (plugin `com.glide.hermes` active, `hermes_cluster_config` populated). Then **Run Message Queue Connection Test**. See [[Key Management Framework (KMF)]].
2. Scheduled jobs that must exist and run: Hermes Metrics Collection, Hermes Periodic Purge, Hermes Topics Util, IDRConsumerJob, `IDRDeltaConsumerJob-<instanceid>` (only for a producer outside the local data centre), IDRHeartbeatJob, IDRMetadataConsumerJob, IDRProducerJob, IDRSeedingProducerJob. Missing ones: contact ServiceNow support.
3. Producer set **In Draft**: Activate. Consumer subscription approved?
4. Consumer set **In Draft**: Activate. Status **Replication Error**: see the tables below.
5. Logs: **Replication Metadata Logs** (related link on either set), **Instance Data Replication > Replication Payload Error** (Source = Seeding means a seeding error; one broken column breaks the transform of the whole table), **Instance Data Replication > Replication Log**.

### Synchronisation check

On the consumer, Replication Metadata Logs sorted by **Log Sequence** descending: the latest `REPL_SET_DETAIL_REQUEST` should show the right producer instance ID in **To** and **Sent** in **Status**. On the producer, the same payload type should show the right consumer ID in **From** and **Received**. Wrong ID: correct it and Activate.

## Consumer set statuses

| Status | Meaning / action |
|---|---|
| In Draft | Activate |
| Activation Requested | waiting for the producer; long wait: check the log |
| Subscription Requested | approve on the producer |
| Seeding / Seeding Paused | seeding must finish or resume |
| Active (Active Replication) | normal |
| Replication Paused | resume |
| Replication Stopped / Replication Error | see the status message |
| Replication Deactivated | activate producer and consumer |

## Status messages

| Message | Fix |
|---|---|
| Producer Replication Set configuration has been modified | consumer: **Synchronize Replication Entries**, then **Activate** |
| Approval was denied by producer instance | producer changed the shared key and revoked this consumer: **Request shared key** and get approved again |
| Shared key not matching | copy the shared key from the producer set into the consumer set, activate |
| Producer Replication Set has been deactivated | activate producer, then consumer |
| Producer Replication Set is inactive | activate producer, then synchronise and activate consumer |
| Producer Replication Set has been deleted / not found | delete the consumer set |
| Replication Set Paused | Resume or Activate |
| Replication set was in pause/error/seeding pause state for more than 7 days | the set is disabled; fix the cause and reactivate |
| Error while seeding data. Please refer to the Replication Payload Error table | fix the payload errors, activate |
| Error while seeding data. Please retry seeding this table | reseed the table |
| Producer has encountered an error while seeding | ask the producer admin |
| Seeding has been terminated due to timeout | retry or contact support |
| Seeding request ... containing more than X number of records is not supported | narrow the filter or use partial seeding; **default limit 10 million**, support can change it (compare the 3 million in [[Instance Data Replication Reference]]) |
| Seeding was cancelled by a consumer / producer admin | activate the consumer set (only queued, paused or started requests can be cancelled) |
| Consumer replication set received out of order messages | contact support; see `idr.message.gap.order_enforcement.enabled` |
| All Producer Replication Sets have been deactivated due to fatal replication error / Producer Replication Set has been deactivated due to replication error | contact support |

Schema messages on the consumer: unknown **table** (error, nothing processed) or unknown **column** / column type or length mismatch (warning, data may be lost): enable a transform for that table.

## Insert and update failures in a table hierarchy

For producer sets created **before Utah**: if parent and child tables are both replicated and the parent entry has no `sys_class_name` filter, child records cause a duplicate-key insert on the parent (failed insert) or exist only in the parent on the consumer (failed update). Fix: add **Task type is Task** (the parent's own class) to the parent's outbound entry.

## Seeding errors

Consumer set > **Seeding Requests** > failed request > **Payload Errors** (read **Message**) > **Retry All Errors** or **Retry Selected Errors**. Up to 10,000 errors; more means a full seeding. Do not retry when records exceed 10 MB or seeding exceeds 7 days: reduce the tables, the records, or use partial seeding.

## Delays and stats

- **Instance Data Replication > Monitoring Dashboard**: producer **Replication Queue Reading Lag**; consumer **Data Lag** (producer change to consumer record) and **Network Lag** (queue to consumer); **Message Queue Version** (default V2 Hermes). Other dashboards named in the chapter: IDR Overall Monitoring, IDR License and Usage SMv2, Scheduled Replication, Queue Dashboard.
- `https://<instance>.service-now.com/xmlstats.do?include=idr` (timestamps GMT): producer `producer_last_run`, `replication_queue_reading_lag`, per set `last_message_sent_on`, `topic_name`; consumer `consumer_last_run`, `data_lag`, `last_heartbeat_received_on` (heartbeat about every minute), `last_message_received_network_time`.
- Missed records (for example after a deactivation): run a **data comparison** request and reseed the missing or mismatched records; journal fields and `sys_audit` are not compared; fields in `idr.dct.comparison.skip.fields` are ignored.

## Notifications

On either set, related link **Notification Configuration**: When to send (inserted/updated, event, or triggered from a flow; default condition **Status is Replication Error**), Who will receive, What it will contain. See [[Notification Email Not Sent or Not Received]] if mails do not arrive.

## Related

- [[Instance Data Replication (IDR) Overview]] · [[Instance Data Replication Reference]] · [[Upgrade IDR Replication Sets to V2]]
