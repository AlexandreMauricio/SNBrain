---
type: how-to
tags: [how-to, integrations, security, instance-admin, admin, release-specific]
status: documented
source: ServiceNow docs, Brazil, Platform security > Platform Security > Log Export Service (LES) (chapter read in full 2026-10-08) - Guided setup for Kafka consumers, Guided setup for MID Server consumers, Set up a secure connection to the Hermes Messaging Service for LES, Create a log source configuration, Create source type and multi topics. https://www.servicenow.com/docs/r/platform-security/les-guided-setup-kafka.html
sn-release: Brazil
verified:
updated: 2026-10-08
---

# Set Up Log Export Service

**Goal:** stream instance logs to an external log analytics system.
**Prerequisites:** role `admin`; the Log Export Service application installed (entitlement needed; Hermes provisioning can take a couple of hours); a network administrator to open ports 4100-4150 and 4200-4250 from the consumer to the instance; an administrator of the consuming system. The instance must not use a custom URL for certificate generation.
**Navigation:** All > Log Export Service (LES) > Kafka Consumer > Guided Setup, or MID Server Consumer Guided Setup

Concepts and every field: [[Log Export Service (LES)]].

## Steps

1. **Check Hermes**: in the guided setup, *Review Hermes Messaging Service Diagnostics*: note *Consumer Bootstrap 1* and *2*; run the *Bootstrap Connectivity* and *Instance Connectivity* tests. A "Page not found" here means Hermes is not installed.
2. **Certificates**: **Certificate Generator > Instance PKI Certificate Generator** > enter a keystore password > **Generate** > **Download Keystore** and **Download Truststore**. Store the password in your secret store, not in a note.
3. **Sources**: **Log Export Service > Sources > New**, one per log source: **Source Type**, **Table**, **Log Level** or filter, **Topic**, **Accepts** (JSON), **Active**. Write down each topic name.
4. **Check the producer**: **Hermes Messaging Service > Hermes Topic Inspector** > *External Topics* > **List Topics** > your topic > **View**: a recent log message should appear.
5. **Consumer**, one of:
   - **Kafka or a Kafka connector**: import the keystore and truststore; create **two** consumer processes with the same group id and topic `snc.<instance name>.<topic>`, one per bootstrap set (`<instance>.service-now.com:4100,...:4103` and `<instance>.service-now.com:4200,...:4203`). For JSON converters that expect schemas, set `key.converter.schemas.enable=false` and `value.converter.schemas.enable=false`.
   - **MID Server**: install and validate a MID Server dedicated to LES; copy keystore and truststore to it; add the `mid.les.kafka.*` properties (**MID Server > Properties**); create a **Destination Configuration** (URL, basic or OAuth credential, transform script); set the **LES Consumer Context** to that MID Server; create a **Consumer** (topic, destination, context); **Test MID Connection**; start the consumer.
6. Confirm arrival in the target system, then mark the guided setup steps complete.

## Result / how to check it worked

Log events appear in the analytics system within seconds of being written. **Consumer Status** (MID Server route) shows the process started without errors. **Log Export Service > Reports** shows exported megabytes per source (with about four hours of delay).

## Example

Instance `<instance>.service-now.com`. Sources: `syslog` at level WARN to topic `example_syslog`, and `syslog_transaction` to topic `example_transactions`, both JSON. A dedicated MID Server *Example MID LES* runs a consumer for `example_syslog` with destination *Example SIEM* (`https://siem.example.com/collector`, a basic auth credential, the Splunk transform script as a starting point). A second consumer for `example_transactions` needs its own consumer context on a second MID Server. After **Test MID Connection** succeeds and the consumer starts, a failed login on the instance shows up in the SIEM search a few seconds later.

## Tables / fields involved

- Sources and source topics, consumers, destination configurations (LES application tables; names not given in the pages read (?))
- `sys_kafka_topic`: Hermes topics
- `sys_kmf_certificate`: the instance-signed certificate
- MID Server properties (`ecc_agent_property`)

## Gotchas

- Two Kafka clusters: a single consumer process misses data during a failover.
- One consumer, one topic, one consumer context, one MID Server.
- Certificate generation fails with a cross-scope access error if Restricted Caller Access is not allowed for the generator: support has to allow it.
- Use only the generated keystore; self-made keystores are not supported.
- If the **Topic** list on the consumer form is empty, no active source exists yet.
- Before a migration or database reseed set `glide.les.disable_logs_forwarding` = true, and set it back afterwards.
- Volume: `syslog_transaction` and node logs are large; start with levels and filters that match what the security team will actually use.
