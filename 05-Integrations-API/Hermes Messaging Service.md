---
type: concept
tags: [concept, integrations, security, domain-separation]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Manage service capabilities > Hermes Messaging Service (landing; Explore: Exchange data, Advanced High Availability transfer, Hermes Settings page, Encryption at rest; Configure: Activating Hermes, Set up a secure connection, Revoke a certificate, Restricting access, Create an alert, Enable encryption at rest; Produce and consume messages: Prepare Kafka, Create a test topic, Produce, Consume; Manage namespaces and topics: namespaces, create, delete, topics, create, update, delete, rescan, monitoring, view a message; Administer: settings, property values, background jobs, status and connection, data usage, message usage, cloning, log messages; Reference: components, security model, system properties, roles, domain separation), read 2026-10-29. https://www.servicenow.com/docs/r/servicenow-platform/multi-instance-framework-hermes/hermes-messaging-service.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Hermes Messaging Service

**In one line:** a ServiceNow-hosted, multi-tenant **Apache Kafka** service paired across two data centres; instance features (**Stream Connect**, [[Log Export Service (LES)]], [[Instance Data Replication (IDR) Overview]], DEX) and your own Kafka clients exchange messages through it over mTLS.

From the Brazil docs; not tested. Not a standalone plugin: it arrives with the Stream Connect installer (`com.glide.hub.stream_connect.installer`, needs Workflow Data Fabric and Stream Connect subscriptions), Log Export Service, IDR (`com.glide.idr`) from Utah, or Digital End-User Experience (KB1213485).

## Concepts and limits

- **Event / message** in a **topic**, split into **partitions** (same key → same partition, ordered there); **namespace** groups topics (one per domain or per Kafka source); **producer**, **consumer**.
- Limits: message 2 MB; 2 MB per second produced or consumed; topics unlimited; 32 partitions per topic, 960 in total (shared with Stream Connect, LES and internal topics); **retention 36 hours**; compression GZIP, LZ4 or none.
- Topic full name: `snc.<instance_name>.<namespace>.<app_id>.<topic_name>` (namespace optional; app ID `sn_streamconnect` or `sn_logstoanalytics`; case-sensitive; max 200 characters). Licence use is tracked per application from the name.
- Components: Hermes Message Queue, Hermes Gateway (data-centre endpoint), Hermes Glide connector (instance side).

## High availability

A Hermes cluster exists in **both** of the instance's data centres (near and far). Producers write to the near cluster (ports **4000-4050**); topics exist in both; consumers need **two** clients with different bootstrap lists, **4100-4150** and **4200-4250**, and different client IDs. On an AHA transfer or Hermes failover the instance produces to the other cluster; lagging consumers may both process for a while. Ordering across clusters is the consumer's job.

Bootstrap example: `<instance>.service-now.com:4000,<instance>.service-now.com:4001,...`. No proxy support (Kafka TCP, not HTTP; MID proxies do not apply). Test ports with `openssl s_client -connect <instance>.service-now.com:<port> -servername <instance>.service-now.com` for each range.

## Secure connection

Prerequisites: Hermes active, **Key Management Framework** (`com.glide.kmf.global`), an instance root CA in **Certificates** (`sys_kmf_certificate`), no custom URL. Roles `hermes_admin`, `sn_kmf.cryptographic_manager` or `admin`.

1. **Certificate Generator > Instance PKI Certificate Generator**; optional **Configure ACLs**: Read Only or Read/Write per namespace or per existing topic for the certificate holder.
2. Enter a keystore password `<KEYSTORE_PASSWORD>`, **Generate** (certificate, keystore, truststore), **Download Keystore** / **Download Truststore**, copy them to every client. Only keystores from this generator work. Restricted caller access errors need Customer Support.
3. Client `producer.properties` / `consumer.properties`: `security.protocol=SSL`, truststore and keystore location, type `PKCS12`, passwords (placeholders only).
4. **Manage Certificates** > **Revoke** (with reason).

- **IP filtering**: request it from Customer Support, then rules in IP Address Access Control; notification **IP Filter Hermes** alerts on blocked attempts.
- **Encryption at rest** (needs Cloud Encryption subscription; `hermes_admin`): topic record > **Enable Encryption** (override `snc.hermes.encryption.enable` = true). ServiceNow-managed keys or BYOK; per-topic DEK wrapped in the Cloud Encryption KMS; existing messages keep their state; CPU overhead; not for shared or compacted topics; revoking your key can break the instance.

## Namespaces and topics

- **Hermes Messaging Service > Namespaces** (`sys_kafka_namespace`; `hermes_admin` or `kafka_namespace_admin`): Name, **Topic Prefix** (do not start with `sn_`), Allowed Application Scopes. Topics found in Hermes are assigned by the **longest matching prefix**, else to **Default Namespace** (empty prefix). Delete or deactivate the Default Namespace once yours exist, to force prefixes. A namespace with active topics cannot be deleted; a topic's namespace cannot change (delete and recreate).
- **Topics** (`sys_kafka_topic`, unique by Full Name; `kafka_admin`): Name (without `snc.<instance>`), Application ID (default Stream Connect), Namespace, Partitions (1-32, default 1, can only grow; **Synchronize Partition Count** across clusters), Active. Created in both clusters. Externally created topics should include the app ID or they land in the default namespace. Deleting a record deletes the topic everywhere (not if it has Stream Connect subscriptions); CLI deletes need each cluster. Topic records cannot be migrated between instances.
- **Rescan Topics** (also automatic every 10 minutes) creates missing records, e.g. after enabling `com.glide.hub.kafka_consumer` or after accidental deletion.

## Monitoring and administration

- **Topic inspector** (`hermes_admin`, `kafka_namespace_admin`, `admin`; the namespace admin sees all domains): service, **List Topics**, data centre, date range (UTC), body filter (text or regex), **Inspect Topic**, **Load Partition Info** (beginning offset rises as messages expire, end offset rises as they arrive), **View Consumer Info** (current offset, **lag**), **Audit Info** (`hermes_topic_audit_records`, refreshed every 30 minutes). Base64 display: `glide.hermes.topic.inspector.payload.format` / `.key.format` = `binary`.
- **Diagnostics** (`hermes_admin` or `admin`): component tests for 7 days, sent / received counts, bootstrap addresses, Instance PKI, **Bootstrap Connectivity** (ports 4000-4003, 4100-4103, 4200-4203), **Instance Connectivity** (test send / receive), last message per topic.
- **Settings** (`maint` all; `hermes_admin` a subset): categories Client Connection, Health Status, High Availability and Failover, IP Access Control, Kafka Integration, Logging and Health Metrics, System Resources, Tokens, Topic Management; values validated against ranges; linked background jobs (e.g. *Hermes Active Cluster Heartbeat* every 10 minutes, *Hermes IP ACL Publish Job*, *Hermes Kafka Client Metrics Collection*) can be Paused or rescheduled.
- **Usage Dashboard** (`hermes_admin`): MB in / out by application (`idr`, `cnc` = ITSM DEX, `sn_streamconnect`, `sn_logstoanalytics`; multi-select), topic, source (Instance, Customer, Other); from `hermes_usage_metrics`, hourly, kept 12 months.
- Logs: **System Log > All**, [Source] [contains] [Hermes].

## Cloning

Before a clone, check the lists ([[Instance Clone Overview]]): **preserve** `hermes_app_services`, `hermes_audit_operational_metadata`, `hermes_audit_records`, `hermes_client_metrics`, `hermes_ip_filtering_audit`, `hermes_metrics_collection`, `hermes_operation_metadata`, `hermes_shared_topic_acl`, `hermes_shared_topic_connection`, `hermes_system_status`, `hermes_topic_audit_records`, `hermes_usage_metrics`, `sys_kafka_namespace`, `sys_kafka_topic`; **exclude** list cut off on the page. `hermes_cluster_config`, `hermes_topics_state`, `hermes_topic_location`, `hermes_topics_metrics`, `hermes_metrics` are also named, and `hermes_cluster_config` and `hermes_topic_location` must be preserved. Cloning from an instance without Hermes removes the target's Hermes tables.

## Roles (as listed)

| Role | Can | Contains |
|---|---|---|
| `hermes_viewer` | view topics and namespaces | |
| `hermes_admin` | topic inspector, settings, diagnostics | `kafka_namespace_admin`, `hermes_viewer` |
| `kafka_namespace_admin` | namespace definitions; sees messages across domains | `kafka_admin` |
| `kafka_admin` | Kafka integration, topics, Kafka subscriptions | `stream_connect_alert_viewer`, `view_changer`, `fd_read_flows` |

## Domain separation (Basic)

Namespaces are assigned to domains by `kafka_namespace_admin`; topics inherit their namespace's domain (Default Namespace topics go to global). `sys_kafka_topic` and `sys_kafka_namespace` are domain separated. Needs `com.glide.domain.msp_extensions.installer`.

## Example

A Kafka admin creates namespace *Example Fulfilment* with prefix `examplefulfilment`, a topic *example_orders* with 3 partitions, generates a certificate with Read/Write on that namespace, and runs `kafka-console-producer` against ports 4000-4003 and two `kafka-console-consumer` clients against 4100-4103 and 4200-4203.

## Related

- [[Set Up Log Export Service]] · [[Flow Trigger Types Reference]] (Kafka trigger) · [[Digital End-User Experience Overview and Architecture]]
