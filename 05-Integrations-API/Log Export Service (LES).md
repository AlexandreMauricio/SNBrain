---
type: concept
tags: [concept, integrations, security, instance-admin, admin, roles, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Platform Security > Log Export Service (LES) (whole chapter, 20 topics, 1,076 cleaned lines, read in full 2026-10-08 through the docs site) - Explore, Log sources, Administer (source configuration, multiple topics, export existing logs on demand, forwarding switch), Configure (Kafka consumer and MID Server consumer guided setups, multi-consumer support, secure Hermes connection), Use (reports), Reference (roles, actions and roles, properties). https://www.servicenow.com/docs/r/platform-security/les-intro.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Log Export Service (LES)

**In one line:** LES copies instance log events, as they are written, onto Kafka topics of the instance's **Hermes Messaging Service**; an external system (your Kafka, a Kafka connector of a log product such as Splunk, or a dedicated MID Server that pushes by REST) reads them from there for security analytics and long-term retention.

From the Brazil docs. Steps: [[Set Up Log Export Service]]. What the logs are: [[System Logs, Log Files and Protected Tables]]. LES is part of the Vault subscription: [[ServiceNow Vault and Otto for Vault]].

- Store application, scope `sn_logstoanalytics` (plugin `com.sn_logstoanalytics`). Installing it provisions Hermes, which can take a couple of hours.
- Menu **Log Export Service (LES)**: Sources, Export Historical Data, Destination Configurations, Consumers, Consumer Status, Reports, the two guided setups.
- Hermes is also used by Stream Connect and Instance Data Replication.

## What can be exported

| Source | Content |
|---|---|
| `syslog` | system log: warnings, errors, script logs |
| `syslog_transaction` | every transaction (browser and API activity) |
| `sys_outbound_http_log` | outbound REST and SOAP requests and responses |
| `sys_audit`, `sys_audit_delete`, `sys_audit_relation` | field changes on audited tables, snapshots of deleted audited records, changes of tracked references |
| `sys_flow_log` | flow execution details |
| `sys_user_login_history` | login attempts |
| Node log | the application node log files (`localhost` logs) |

Only tables listed in property `com.glide.script.glide_record_logger.forward_tables` (default `syslog,sys_outbound_http_log,syslog_transaction,sys_audit`) can be chosen as a table source.

## Source record

**Log Export Service > Sources > New**:

| Field | Meaning |
|---|---|
| **Source Type** | *Node Log* or *Table* |
| **Table** | for type Table |
| **Log Level** | for node log and `syslog`: forwards that level and worse (INFO all; WARN warnings and errors; ERROR errors only) |
| **Filter Type** | for `syslog` and the audit tables |
| **Topic** | the Hermes topic (pick or create) |
| **Accepts** | JSON or plain text |
| **Active** | |

- `syslog` can have several **source topics**, each with a filter: *All*, or one *Application Family*, *Package* or *Scope*. At most 10 topics for syslog (`glide.log.forwarding.syslog.topics.limit`).
- `sys_audit` with filter type *Log table* can have a source topic per audited table.
- Since Yokohama each source may use its own topic (needs `sn_logstoanalytics.kafka.multi_topics` = true); before, all sources shared one. A new topic: **Name**, **Application ID** `sn_logstoanalytics`, **Namespace** *Default Namespace*, **Partition** 4. Deleting a source keeps its topic (`sys_kafka_topic`) for reuse.

## Consumers

| Option | How |
|---|---|
| Your own Kafka | native Kafka protocol against Hermes |
| Kafka connector of the log product (for example Splunk Connect for Kafka) | the connector subscribes to the topics |
| Dedicated MID Server | the LES MID Server extension reads Hermes and pushes to a REST endpoint |

Facts for any Kafka client:

- Hermes runs **two Kafka clusters for failover: two consumer processes are needed**, same topic, same consumer group id, different bootstrap addresses: `<instance>.service-now.com:4100` to `:4103` and `<instance>.service-now.com:4200` to `:4203` (open ports 4100-4150 and 4200-4250).
- From outside, the topic name is prefixed `snc.<instance name>.`.
- Authentication is by client certificate: **Certificate Generator > Instance PKI Certificate Generator** (roles `hermes_admin`, `sn_kmf.cryptographic_manager` or `admin`): optional topic ACLs per namespace or topic (*Read Only* / *Read/Write*), a keystore password, **Generate**, then **Download Keystore** and **Download Truststore**. Needs the Key Management Framework and an instance root CA certificate in `sys_kmf_certificate`. **Not supported on instances with a custom URL.** Only keystores made by this generator are supported.
- A message larger than the configured buffer is rejected by Hermes with an error.

MID Server route:

- MID Server properties `mid.les.kafka.*`: bootstrap servers (both sets), `client.id` (instance name), `group.id` (`snc.<instance>.group1`), `security.protocol` SSL, keystore and truststore location, type (PKCS12) and passwords; `mid.les.consumer.threads.count` (4), `mid.les.processor.threads.count` (4), `mid.les.kafka.poll.duration.millis` (1000), `mid.les.kafka.enable.auto.commit` (keep false: offsets are committed after successful processing), `mid.les.metrics.frequency.millis` (60000).
- **Destination Configuration**: **Name**, **Destination URL**, **Destination Credentials** (basic or OAuth only), **Transform Script** (shipped `SplunkTransform` as a model).
- **LES Consumer Context** (**MID Server > Extensions**): which MID Server runs it (*Specific MID Server*).
- **Consumer**: **Name**, **Topic**, **Destination Configuration**, **Consumer Context**. UI action **Test MID Connection** must succeed before starting. **Consumer Status** shows state and errors.
- **One consumer reads one topic, with its own context on its own MID Server** (since Zurich). Several consumers run in parallel. Throughput of one MID Server consumer: about 27,000 messages per second sustained (31,500 peak).

## Replaying old logs

**Export Historical Data > New** (a *Backfill Run*): **Table**, **Log level** (syslog), **Topic**, **Range Start**, **Range End**, optional **Max Rows**, **Batch Size** (1000), **Throttle Ms** (0; 10 to 100 if the instance is busy). **Start** queues it (picked up about every minute); fields lock; **Cancel** while queued or running. One active run per table. Status fields report rows published and failed, first and last timestamp and sys_id. The table must be in the forward list and the topic in the LES scope.

## Operating it

- **Reports**: megabytes exported per month, per source (drill to week and day; 395 days kept; about 4 hours behind), last 24 hours per source, daily events per table.
- **Pause forwarding** during a migration or database reseed (which would replay old rows as duplicates): `glide.les.disable_logs_forwarding` = true, and **back to false afterwards** or downstream systems silently stop receiving logs.
- Hermes health: **Hermes Messaging Service > Diagnostics** (bootstrap addresses, instance PKI, connectivity tests, topic list); **Hermes Topic Inspector** shows messages in a topic.
- Clones: the docs point to a list of LES tables to preserve and exclude (not in the pages read).

| Property | Default | Meaning |
|---|---|---|
| `glide.log.les.async_enabled` | true | forward asynchronously |
| `glide.les.max_queue_size` | 4096 | entries waiting to be forwarded; raise if entries are dropped under load |
| `glide.les.queue_slot_wait_time` | 0 | milliseconds to wait for a free slot before dropping an entry |
| `glide.log.forwarding.num_topic_partitions` | 4 | partitions per topic |
| `sn_logstoanalytics.debug` | false | verbose application logging |

## Roles

| Role | For |
|---|---|
| `admin` | installing, guided setups, Hermes diagnostics, MID Server properties and context, the forwarding switch |
| `sn_logstoanalytics.admin` | sources, topics, destinations, consumers, test connection, backfill runs, reports |
| `hermes_admin` | generating the certificates |

## Related

- [[Set Up Log Export Service]] · [[System Logs, Log Files and Protected Tables]] · [[ServiceNow Vault and Otto for Vault]] · [[Security Center]] · [[Connections, Credentials and Aliases]] · [[Custom Instance URLs]]
