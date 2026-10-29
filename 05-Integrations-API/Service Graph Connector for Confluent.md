---
type: reference
tags: [reference, integrations, cmdb]
status: documented
source: ServiceNow Brazil docs, Platform Capabilities guide > Integrating third-party data into CMDB > Service Graph Connectors > Confluent (about 220 cleaned lines, read 2026-10-29) - overview, Configure using SGC Central, Targeted CMDB classes, Properties, Accessing connection details. https://www.servicenow.com/docs/r/servicenow-platform/service-graph-connectors/sgc-integration-confluent.html
sn-release: Brazil
verified:
verified-by:
updated: 2026-10-29
---

# Service Graph Connector for Confluent

**In one line:** Store app that imports the structure of a **Confluent** (managed Kafka) estate into the CMDB: organisation, environments, Kafka clusters and topics, with their containment relationships and life cycle stage.

From the Brazil docs (Zurich, Australia, Brazil); SGC Central only; not tested. General: [[Service Graph Connectors Overview]].

## Setting up

SGC Central > **Confluent**: **Create and test connection** (fields not listed) → **Set configuration properties** → **Configure import schedule** → **Confirm connection creation**. Connections: **All > Service Graph Connectors > Confluent > Connections**.

Connection properties: **Page size** (100) and **Environments to include** (comma-separated; empty = all).

## Classes

| Class | Table | Attributes and relationships |
|---|---|---|
| Confluent Organization | `cmdb_ci_confluent_org` | object ID, creation and last-updated dates; **Contains::Contained by** environments |
| Confluent Environment | `cmdb_ci_confluent_env` | object ID, creation and update dates; contains clusters |
| Kafka Cluster | `cmdb_ci_kafka_cluster` | cluster ID, status, HTTP and bootstrap endpoints, cloud provider and region; **Provides::Provided by** topics |
| Kafka Topic | `cmdb_ci_appl_kafka_topic` | topic ID, partition count, replication factor |

All carry operational status, **Life Cycle Stage** and **Life Cycle Stage Status** ([[CSDM Life Cycle Stages and Synchronization]]). Unconfirmed variant: the organisation table is printed `cmdb_ci_confluent_org` and also `cmdb_ci_confluent_organization` on the same page.

## Related

- [[Service Graph Connectors Overview]] · [[CSDM Life Cycle Values Reference]]
