---
type: concept
tags: [concept, integrations, flows, roles, schema, release-specific]
status: documented
source: ServiceNow Brazil docs, Workflow Data Fabric > Integration Hub > Using Stream Connect for Apache Kafka (overview, quick start, topic aliases, Stream Producer, Message Replication, Direct Kafka, alerting, dashboard, schema management, consumers, Kafka streams, subscriptions and producer statistics, MID Hermes API extension) and Reference (roles, Direct Kafka usage metrics), read at overview depth 2026-10-30. About 170 KB of pages; step-by-step and field tables mostly not read. https://www.servicenow.com/docs/r/integrate-applications/create-integrations-applications.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-30
---

# Stream Connect for Apache Kafka

**In one line:** connects your Kafka environment to the instance so that flows, scripts and imports can publish and consume events at high volume, through [[Hermes Messaging Service]] or directly.

From the Brazil docs; not tested. Needs **Workflow Data Fabric and Stream Connect** subscriptions; installer `com.glide.hub.stream_connect.installer`. Security, topics, limits and ports are in the Hermes note.

## Producers and consumers

| Direction | Option | Build with |
|---|---|---|
| Out | **Kafka Producer step** | [[Flow Action Steps Reference]] |
| Out | **ProducerV2 API** | server-side script, `new sn_ih_kafka.ProducerV2()`; scope of the caller not read |
| Out | **Stream Producer** | configuration: change data capture of inserts, updates and deletes on chosen tables, no business rules |
| In | **Kafka Message trigger** | flow, see [[Flow Trigger Types Reference]] |
| In | **ETL consumer** | [[Robust Import Set Transformers and ETL Definitions|robust transformer]] |
| In | **Transform Map consumer** | transform map |
| In | **Script consumer** | your script |

The quick start says two producers and four consumers, without Stream Producer; the Stream Producer page describes a third way out.

ETL, Transform Map and Script consumers each need a **Kafka stream** (`sys_kafka_stream`; role `integration_hub_admin`). Activating the stream creates a **subscription**, which holds the statistics: records added, processed and remaining.

## Other pieces

- **Topic alias:** a stable name connected to a Hermes or Direct Kafka topic, and movable to another one. Qualified by application scope: `Incoming-Messages [Global]`.
- **Direct Kafka:** a **Direct Kafka Cluster** uses a connection alias to reach your own Kafka, without Hermes. Topics sync every 5 minutes to `sys_kafka_external_topic`; **Test Direct Kafka** is on the form.
- **Message Replication:** a MID Server with a replicator extension copies between local Kafka and Hermes; no extra hosting. Records in `sys_kafka_topic_replication`. The firewall must open the Hermes port ranges.
- **Schema management:** Avro messages. Tables `stream_connect_schema`, `confluent_stream_connect_schema`, `standalone_stream_connect_schema`.
- **MID Hermes API extension:** a MID script include pushes messages to Hermes without Stream Connect.
- **Alerting:** event-type alerts on errors, threshold alerts on values such as lag.
- **Stream Connect Dashboard:** producers, consumers, replicators, and 13 months of data use.

**ServiceNow Kafka Consumer** is a different, older spoke built on Confluent REST Proxy API v2. **From Brazil it is being prepared for future deprecation:** not activated on new instances and hidden from the catalog, but supported for existing deployments. The docs recommend Stream Connect for new work.

## Tables

| Table | Holds |
|---|---|
| `sys_kafka_topic` | Hermes topics |
| `sys_kafka_direct_topic` | Direct Kafka topics |
| `sys_kafka_producer`, `sys_kafka_producer_statistics` | producers; read only, need `kafka_admin` |
| `sys_kafka_undelivered_messages` | messages that could not be delivered |
| `sys_kafka_unprocessed_messages` | batches that timed out |
| `sys_kafka_flow_trigger` | Kafka flow triggers |

Direct Kafka usage metrics are read only, hourly or more, with `BytesProduced` and `BytesConsumed`, kept 13 months.

## Roles

| Role | Can | Contains |
|---|---|---|
| `stream_connect_admin` | manage subscriptions, topics and settings | `message_replication_admin`, `stream_connect_api`, `kafka_admin`, `stream_connect_viewer`, `kafka_namespace_admin`, `connection_admin` |
| `kafka_admin` | Kafka integration, topics, subscription settings | `sn_help_setup_player`, `pd_author`, `hermes_viewer`, `pd_operator`, `stream_connect_alert_viewer`, `canvas_user`, `view_changer`, `fd_read_flows` |
| `kafka_namespace_admin` | namespaces | `kafka_admin` |
| `stream_connect_viewer` | read configuration and statistics | `message_replication_user`, `hermes_viewer`, `stream_connect_readonly_api`, `stream_connect_alert_viewer` |
| `stream_connect_api` | all scriptable APIs | |
| `stream_connect_readonly_api` | read-only scriptable APIs | |
| `stream_connect_alert_viewer` | read alerts and logs | |

Unconfirmed variants: the roles table writes `Kafka_admin`, other pages `kafka_admin`. Consumer pages require `integration_hub_admin`, which this table does not list. The Hermes guide gives `kafka_admin` a shorter contains list.

## Example

Stream Producer *Example Incident Changes* watches *Incident* (`incident`) and sends to topic alias *example-incident-events*. Outside, a Kafka client consumes it. Coming back, Transform Map consumer *Example Asset Consumer* loads *example-asset-updates* through a Kafka stream.

## Related

- [[Hermes Messaging Service]] · [[Integration Hub Overview and Subscription]] · [[Log Export Service (LES)]] · [[MID Server Extensions, Profiles and Containers]]
